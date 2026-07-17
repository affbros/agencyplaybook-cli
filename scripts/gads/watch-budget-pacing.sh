#!/usr/bin/env bash
# name: watch-budget-pacing
# binary: apb-gads
# tier: 1
# cadence: daily
# description: Watches budget pacing and impression-share-lost-to-budget across the account. Runs the budget-pacing playbook and thresholds its per-campaign pace verdicts (over/under-pacing, capped), and cross-checks the impression-share-loss playbook for campaigns bleeding impression share to budget — the two-sided signal that a campaign is either wasting or being throttled by its budget. Reports the flagged campaigns for weekly review; the pacing math is the binary's. Read-only — never proposes a budget change.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"

WATCH_NAME="watch-budget-pacing"
LOOKBACK=30
: "${LOST_IS_BUDGET_PCT:=10}"     # flag lost-IS-to-budget beyond this (%)
parse_common_args "$@"

pacing="$(run_gads playbook budget-pacing --lookback-days "$LOOKBACK")"
status_write budget-pacing "$pacing"

pace_flagged="$(printf '%s' "$pacing" | jq -c '
  [ .. | objects
    | select((((.pacing_status? // .pace? // .status? // .verdict? // "") | tostring) | ascii_downcase)
        | test("over|under|capped|ahead|behind|pressure"))
    | { name: (.name? // .campaign_name? // .campaign? // .id? // "campaign"),
        pace: (.pacing_status? // .pace? // .status? // .verdict?) }
  ] | unique' 2>/dev/null || echo '[]')"

pc="$(printf '%s' "$pace_flagged" | jq 'length' 2>/dev/null || echo 0)"
if [ "${pc:-0}" -gt 0 ]; then
  attn "${pc} campaign(s) off budget pace — for weekly review:"
  printf '%s' "$pace_flagged" | jq -r '.[] | "         - \(.name): \(.pace)"'
fi

# Impression share lost to budget — a scale/throttle signal.
isl="$(run_gads playbook impression-share-loss --lookback-days "$LOOKBACK")"
status_write budget-impression-share-loss "$isl"

isl_flagged="$(printf '%s' "$isl" | jq -c --argjson t "$LOST_IS_BUDGET_PCT" '
  [ .. | objects
    | (((.search_budget_lost_impression_share? // .lost_is_budget? // .budget_lost_is? // .lost_to_budget? // 0) | tonumber? // 0)) as $v
    # value may be a fraction (0..1) or a percent (0..100); normalise to percent.
    | ($v * (if $v <= 1 then 100 else 1 end)) as $pct
    | select($pct > $t)
    | { name: (.name? // .campaign_name? // .campaign? // .id? // "campaign"), lost_is_pct: ($pct*100|round)/100 }
  ] | unique' 2>/dev/null || echo '[]')"

ic="$(printf '%s' "$isl_flagged" | jq 'length' 2>/dev/null || echo 0)"
if [ "${ic:-0}" -gt 0 ]; then
  attn "${ic} campaign(s) losing >${LOST_IS_BUDGET_PCT}% impression share to budget — for weekly review:"
  printf '%s' "$isl_flagged" | jq -r '.[] | "         - \(.name): \(.lost_is_pct)% lost-IS(budget)"'
fi

finish
