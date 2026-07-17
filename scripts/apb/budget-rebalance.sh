#!/usr/bin/env bash
# name: budget-rebalance
# binary: apb
# tier: 3
# cadence: weekly
# description: Pacing-driven, budget-neutral reallocation proposal. Runs the rebalance playbook (which derives a budget-neutral shift from the bottom-quartile CPA ad sets toward the stable top-quartile scalers) and renders it as a Track-A dry-run plan doc via --plan — zero API mutation. Sufficiency-gated: the account must clear the spend floor over the window (thresholds.conf min_spend_usd) AND have both a top and a bottom quartile to shift between; otherwise it writes a "no reallocation" report explaining why (an explicitly good outcome), never a plan. Plan doc only — apply is a separate, deliberate step via plan-then-apply.sh. Exit 0 = no reallocation, 10 = a plan was proposed.
# writes: plan-doc
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"
# shellcheck source=lib/sufficiency.sh
source "${HERE}/lib/sufficiency.sh"

WATCH_NAME="budget-rebalance"
LOOKBACK=30
parse_common_args "$@"
suff_load_thresholds

reb="$(run_apb playbook rebalance --days "$LOOKBACK")"
status_write rebalance "$reb"

top_cnt="$(jq -r '.findings.top_quartile_count // 0' <<<"$reb")"
bot_cnt="$(jq -r '.findings.bottom_quartile_count // 0' <<<"$reb")"
daily_spend="$(jq -r '.findings.total_daily_spend // 0' <<<"$reb")"
spend_win="$(awk -v d="$daily_spend" -v l="$LOOKBACK" 'BEGIN{printf "%.2f", (d+0)*(l+0)}')"
enough="$(awk -v s="$spend_win" -v m="${MIN_SPEND_USD:-50}" 'BEGIN{print (s+0>=m+0)?"pass":"fail"}')"

out="${OUT_DIR}/budget-rebalance.md"
if [ "$enough" = "pass" ] && [ "${top_cnt:-0}" -gt 0 ] && [ "${bot_cnt:-0}" -gt 0 ]; then
  plan="$(plans_dir)/budget-rebalance.md"
  run_apb playbook rebalance --days "$LOOKBACK" --plan "$plan" >/dev/null
  # A JSON twin next to the doc means the plan carries applicable operations.
  [ -f "${plan}.json" ] || { \
    printf '# Budget rebalance — %s — %s\n\n## No reallocation this run\n\nSufficiency passed ($%s over %sd) but the rebalance produced no machine-actionable shift (nothing to apply).\n' \
      "$(review_subject)" "$(date +%F)" "$spend_win" "$LOOKBACK" >"$out"; \
    _log "-> sufficiency passed but no actionable shift."; exit 0; }
  {
    printf '# Budget rebalance — %s — %s\n\n' "$(review_subject)" "$(date +%F)"
    printf 'Sufficiency: **pass** ($%s spend over %sd, floor $%s) · quartiles: %s top / %s bottom.\n\n' \
      "$spend_win" "$LOOKBACK" "${MIN_SPEND_USD:-50}" "$top_cnt" "$bot_cnt"
    printf 'A budget-neutral reallocation is proposed (dry-run, zero mutation). Review and apply with `plan-then-apply.sh`:\n\n'
    printf -- '- plan: %s\n\n' "$plan"
    printf '## Recommendations\n\n'
    jq -r '(.recommendations // [])[] | "- \(.action? // .recommendation? // .)"' <<<"$reb" 2>/dev/null || true
  } >"$out"
  _log "-> reallocation proposed (see ${out})."
  exit 10
fi

{
  printf '# Budget rebalance — %s — %s\n\n' "$(review_subject)" "$(date +%F)"
  printf '## No reallocation this run\n\n'
  printf 'An explicitly good outcome — no budget shift is justified by the data.\n\n'
  printf -- '- Sufficiency: **%s** ($%s spend over %sd, floor $%s)\n' \
    "$enough" "$spend_win" "$LOOKBACK" "${MIN_SPEND_USD:-50}"
  printf -- '- Quartiles to shift between: %s top / %s bottom (both must be > 0)\n' "$top_cnt" "$bot_cnt"
} >"$out"
_log "-> no reallocation (see ${out})."
exit 0
