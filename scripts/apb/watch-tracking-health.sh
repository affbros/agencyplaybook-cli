#!/usr/bin/env bash
# name: watch-tracking-health
# binary: apb
# tier: 1
# cadence: daily
# description: Watches measurement health by reading pixel health and flagging pixels that are stale, not firing, or reporting no recent events — the failure that silently zeroes out conversion optimisation. It thresholds the health read's own status/recency signals (no re-derivation) and surfaces any unhealthy pixel for weekly review. Strictly read-only; it never creates, shares, or edits a pixel.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"

WATCH_NAME="watch-tracking-health"
LOOKBACK=7
parse_common_args "$@"

health="$(run_apb pixel health)"
status_write tracking-health "$health"

# Flag pixels the health read marks unhealthy / silent, or with no recent events.
flagged="$(printf '%s' "$health" | jq -c '
  [ .. | objects
    | select(
        (((.status? // .health? // .state? // "") | tostring) | test("inactive|stale|unhealthy|no.?event|silent|error|down";"i"))
        or (.active? == false)
        or (((.recent_events? // .events_last_7d? // .event_count? // null) | tonumber? // 1) == 0)
      )
    | { pixel: (.name? // .id? // .pixel_id? // "pixel"),
        status: (.status? // .health? // .state? // "no-recent-events") }
  ] | unique' 2>/dev/null || echo '[]')"

count="$(printf '%s' "$flagged" | jq 'length' 2>/dev/null || echo 0)"
if [ "${count:-0}" -gt 0 ]; then
  attn "${count} pixel/tracking signal(s) look unhealthy or silent — for weekly review:"
  printf '%s' "$flagged" | jq -r '.[] | "         - \(.pixel): \(.status)"'
fi

finish
