#!/usr/bin/env bash
# name: watch-policy-flags
# binary: apb-gads
# tier: 1
# cadence: daily
# description: Scans for ad policy problems by running the policy-compliance playbook, which buckets ads by approval status and surfaces policy topic entries. This watchdog thresholds that output to flag ads that are DISAPPROVED or APPROVED_LIMITED (limited by policy) — including PMAX and Search — the silent delivery killers. It reports the count and the offending entities for weekly review and never edits, resubmits, or appeals anything.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"

WATCH_NAME="watch-policy-flags"
LOOKBACK=30
parse_common_args "$@"

policy="$(run_gads playbook policy-compliance --lookback-days "$LOOKBACK")"
status_write policy-flags "$policy"

flagged="$(printf '%s' "$policy" | jq -c '
  [ .. | objects
    | select((((.approval_status? // .policy_status? // .status? // "") | tostring) | ascii_upcase)
        | test("DISAPPROVED|LIMITED|UNDER_REVIEW|AREA_OF_INTEREST_ONLY"))
    | { entity: (.name? // .ad? // .ad_id? // .id? // "ad"),
        status: (.approval_status? // .policy_status? // .status?),
        topics: (.policy_topic_entries? // .policy_topics? // null) }
  ] | unique' 2>/dev/null || echo '[]')"

count="$(printf '%s' "$flagged" | jq 'length' 2>/dev/null || echo 0)"
if [ "${count:-0}" -gt 0 ]; then
  attn "${count} ad(s) disapproved or limited by policy — for weekly review:"
  printf '%s' "$flagged" | jq -r '.[] | "         - \(.entity): \(.status)"'
fi

finish
