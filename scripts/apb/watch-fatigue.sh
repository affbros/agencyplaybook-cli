#!/usr/bin/env bash
# name: watch-fatigue
# binary: apb
# tier: 1
# cadence: daily
# description: Watches creative fatigue on the account's top spenders by running the fatigue-index playbook and thresholding its output. Surfaces ads/ad sets the playbook scores as fatiguing — frequency creep paired with CTR decay — the leading indicator of rising CPMs before performance visibly cracks. The scoring is the binary's; this script only reports the flagged entities and their fatigue signal for weekly creative-refresh review. Read-only — it never pauses or swaps a creative.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"

WATCH_NAME="watch-fatigue"
LOOKBACK=14
parse_common_args "$@"

fatigue="$(run_apb playbook fatigue-index --days "$LOOKBACK")"
status_write fatigue "$fatigue"

# Entities the playbook scores as fatigued / at-risk (frequency + CTR-decay signal).
flagged="$(printf '%s' "$fatigue" | jq -c '
  [ .. | objects
    | select(((.fatigue_status? // .fatigue? // .status? // .verdict? // .flag? // "") | tostring)
        | test("fatigu|decay|at.?risk|creative_tired|refresh";"i"))
    | { name: (.name? // .ad_name? // .adset_name? // .id? // "entity"),
        signal: (.fatigue_status? // .fatigue? // .status? // .verdict? // .flag?) }
  ] | unique' 2>/dev/null || echo '[]')"

count="$(printf '%s' "$flagged" | jq 'length' 2>/dev/null || echo 0)"
if [ "${count:-0}" -gt 0 ]; then
  attn "${count} entity(ies) showing creative fatigue — for weekly refresh review:"
  printf '%s' "$flagged" | jq -r '.[] | "         - \(.name): \(.signal)"'
fi

finish
