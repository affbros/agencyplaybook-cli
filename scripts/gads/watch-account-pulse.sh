#!/usr/bin/env bash
# name: watch-account-pulse
# binary: apb-gads
# tier: 1
# cadence: daily
# description: Daily pulse on Google Ads account health. Runs the account-health playbook over the lookback and thresholds its own severity-coded findings and recommended actions, surfacing anything the binary judges HIGH/CRITICAL/WARNING (delivery, spend, and status signals in one bundle). The analysis is the playbook's; this script only reports what it returns and flags it for weekly review. Strictly read-only — it never proposes or applies a change.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"

WATCH_NAME="watch-account-pulse"
LOOKBACK=30
parse_common_args "$@"

health="$(run_gads playbook account-health --lookback-days "$LOOKBACK")"
status_write account-pulse "$health"

flagged="$(printf '%s' "$health" | jq -c '
  [ .. | objects
    | select((((.severity? // .status? // .level? // "") | tostring) | ascii_upcase)
        | test("HIGH|CRITICAL|SEVERE|WARN|ERROR|URGENT"))
    | { label: (.title? // .message? // .name? // .slug? // .finding? // "finding"),
        severity: (.severity? // .status? // .level?) }
  ] | unique' 2>/dev/null || echo '[]')"

count="$(printf '%s' "$flagged" | jq 'length' 2>/dev/null || echo 0)"
if [ "${count:-0}" -gt 0 ]; then
  attn "${count} account-health finding(s) at WARN+ severity — for weekly review:"
  printf '%s' "$flagged" | jq -r '.[] | "         - [\(.severity)] \(.label)"'
fi

finish
