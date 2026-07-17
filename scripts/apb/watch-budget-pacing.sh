#!/usr/bin/env bash
# name: watch-budget-pacing
# binary: apb
# tier: 1
# cadence: daily
# description: Watches budget pacing across the account by running the delivery-pacing playbook and thresholding its findings. Surfaces campaigns/ad sets the binary judges to be under-delivering (spend well below budgeted pace) or effectively budget-capped (delivering at the budget ceiling, a scale signal). The intelligence lives in the playbook; this script only counts and reports what it returns and flags it for weekly review. Read-only — never proposes a budget change.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"

WATCH_NAME="watch-budget-pacing"
LOOKBACK=7
parse_common_args "$@"

pacing="$(run_apb playbook delivery-pacing --days "$LOOKBACK")"
status_write budget-pacing "$pacing"

# Pull any object the playbook tags with a pacing-risk status (under-delivering /
# budget-capped / overspend). Tolerant of the exact result shape.
flagged="$(printf '%s' "$pacing" | jq -c '
  [ .. | objects
    | select(((.pacing_status? // .status? // .verdict? // .flag? // "") | tostring)
        | test("under|cap|overspend|pressure";"i"))
    | { name: (.name? // .campaign_name? // .id? // "entity"),
        status: (.pacing_status? // .status? // .verdict? // .flag?) }
  ] | unique' 2>/dev/null || echo '[]')"

count="$(printf '%s' "$flagged" | jq 'length' 2>/dev/null || echo 0)"
if [ "${count:-0}" -gt 0 ]; then
  attn "${count} entity(ies) with a pacing signal (under-delivery / budget-capped) — for weekly review:"
  printf '%s' "$flagged" | jq -r '.[] | "         - \(.name): \(.status)"'
fi

finish
