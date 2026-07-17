#!/usr/bin/env bash
# name: watch-policy-flags
# binary: apb
# tier: 1
# cadence: daily
# description: Scans active ads for policy problems by reading the ad list and thresholding each ad's effective delivery status. Flags ads that Meta has disapproved, limited, or held in review (effective_status in DISAPPROVED / WITH_ISSUES / PENDING_REVIEW / CAMPAIGN_PAUSED-with-issues), which silently starve delivery. It reports the count and the offending ad names for weekly review and never edits or resubmits anything.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"

WATCH_NAME="watch-policy-flags"
LOOKBACK=30
parse_common_args "$@"

ads="$(run_apb ad list --all --status ACTIVE)"
status_write policy-flags "$ads"

# effective_status values that mean "not cleanly delivering for policy reasons".
flagged="$(printf '%s' "$ads" | jq -c '
  (if type=="object" and has("data") then .data else . end)
  | (if type=="array" then . else [.] end)
  | [ .[] | select(((.effective_status? // .status? // "") | tostring)
        | test("DISAPPROVED|WITH_ISSUES|PENDING_REVIEW|PENDING_PROCESSING|LIMITED";"i"))
      | { name: (.name? // .id? // "ad"), status: (.effective_status? // .status?) } ]' \
  2>/dev/null || echo '[]')"

count="$(printf '%s' "$flagged" | jq 'length' 2>/dev/null || echo 0)"
if [ "${count:-0}" -gt 0 ]; then
  attn "${count} active ad(s) flagged by Meta review (disapproved / limited / pending) — for weekly review:"
  printf '%s' "$flagged" | jq -r '.[] | "         - \(.name): \(.status)"'
fi

finish
