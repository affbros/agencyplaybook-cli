#!/usr/bin/env bash
# name: watch-tracking-health
# binary: apb-gads
# tier: 1
# cadence: daily
# description: Watches conversion-tracking health by running the conversion-tracking-check playbook, which lists configured conversion actions and flags REMOVED, HIDDEN, or unverified ones plus tag-health issues. This watchdog thresholds that output and surfaces any conversion action that would silently break Smart Bidding's signal for weekly review. It also cross-checks doctor for account-level config drift. Strictly read-only — it never edits a conversion action or tag.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"

WATCH_NAME="watch-tracking-health"
LOOKBACK=30
parse_common_args "$@"

track="$(run_gads playbook conversion-tracking-check --lookback-days "$LOOKBACK")"
status_write tracking-health "$track"

flagged="$(printf '%s' "$track" | jq -c '
  [ .. | objects
    | select(
        ((((.status? // .conversion_status? // .state? // "") | tostring) | ascii_upcase)
          | test("REMOVED|HIDDEN|UNVERIFIED|NO_RECENT|INACTIVE|PENDING|UNTAGGED"))
        or (.verified? == false)
      )
    | { action: (.name? // .conversion_action? // .id? // "conversion_action"),
        status: (.status? // .conversion_status? // .state? // "unverified") }
  ] | unique' 2>/dev/null || echo '[]')"

count="$(printf '%s' "$flagged" | jq 'length' 2>/dev/null || echo 0)"
if [ "${count:-0}" -gt 0 ]; then
  attn "${count} conversion action(s) look unhealthy (removed/hidden/unverified/silent) — for weekly review:"
  printf '%s' "$flagged" | jq -r '.[] | "         - \(.action): \(.status)"'
fi

# doctor is a general account-config sanity read (best-effort; non-fatal signal).
doc="$(run_gads doctor check)"
status_write tracking-doctor "$doc"
doc_bad="$(printf '%s' "$doc" | jq -r '
  [ .. | objects | select((((.status? // .ok? // "") | tostring) | ascii_downcase) | test("fail|error|false")) ] | length' \
  2>/dev/null || echo 0)"
if [ "${doc_bad:-0}" -gt 0 ]; then
  attn "${doc_bad} doctor check(s) failing — account/credential config drift — for weekly review."
fi

finish
