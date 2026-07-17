#!/usr/bin/env bash
# name: budget-rebalance
# binary: apb-gads
# tier: 3
# cadence: weekly
# description: Pacing-driven reallocation proposal. Reads the budget-pacing playbook, picks the single most off-pace ACTIVE campaign that carries real spend, resolves its campaign_budget resource name via a read-only gaql query, and renders a Track-A dry-run plan doc via `mutate campaign-budget-update --plan` (proposed daily budget aligned to the window's expected run-rate) — zero API mutation. Sufficiency-gated: the campaign must clear the spend floor (thresholds.conf min_spend_usd); otherwise it writes a "no reallocation" report explaining why (an explicitly good outcome), never a plan. Plan doc only — apply is a separate, deliberate step via plan-then-apply.sh. Exit 0 = no reallocation, 10 = a plan was proposed.
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

pacing="$(run_gads playbook budget-pacing --lookback-days "$LOOKBACK")"
status_write budget-pacing "$pacing"

# Single most off-pace ACTIVE campaign carrying real spend.
top="$(jq -c '[ (.findings // [])[]
  | select((.status // "") != "REMOVED")
  | select((.actual_cost_micros // 0) > 0)
  | . + {dev: (((.pace_ratio // 1) - 1) | if . < 0 then -. else . end)} ]
  | sort_by(-.dev) | .[0] // empty' <<<"$pacing" 2>/dev/null || echo "")"

out="${OUT_DIR}/budget-rebalance.md"
_none() { # <reason>
  { printf '# Budget rebalance — %s — %s\n\n## No reallocation this run\n\n' "$(review_subject)" "$(date +%F)"
    printf 'An explicitly good outcome — no reallocation is justified.\n\n- %s\n' "$1"; } >"$out"
  _log "-> no reallocation: $1"; exit 0
}

[ -n "$top" ] && [ "$top" != "null" ] || _none "No active campaign with spend and an off-pace signal this window."

cid="$(jq -r '.campaign_id // empty' <<<"$top")"
cname="$(jq -r '.campaign_name // .campaign_id // "campaign"' <<<"$top")"
expected="$(jq -r '.expected_cost_micros // 0' <<<"$top")"
cur_budget="$(jq -r '.daily_budget_micros // 0' <<<"$top")"
spend_usd="$(awk -v a="$(jq -r '.actual_cost_micros // 0' <<<"$top")" 'BEGIN{printf "%.2f", (a+0)/1000000}')"
enough="$(awk -v s="$spend_usd" -v m="${MIN_SPEND_USD:-50}" 'BEGIN{print (s+0>=m+0)?"pass":"fail"}')"
# Proposed daily budget micros: the window's expected run-rate (a pacing correction).
amt="$(awk -v e="$expected" -v l="$LOOKBACK" 'BEGIN{v=(e+0)/(l+0); printf "%d", (v<1?0:v)}')"

[ "$enough" = "pass" ] || _none "Sufficiency: fail — \$$spend_usd over ${LOOKBACK}d below floor \$${MIN_SPEND_USD:-50} (${cname})."
{ [ -n "$cid" ] && [ "${amt:-0}" -gt 0 ]; } || _none "Could not derive a positive proposed budget for ${cname}."

# Resolve the budget resource name (campaign-budget-update targets the budget).
q="SELECT campaign.id, campaign_budget.resource_name FROM campaign WHERE campaign.id = ${cid}"
rn="$(run_gads gaql query --query "$q" | jq -r '(.results[0].campaignBudget.resourceName) // empty')"
[ -n "$rn" ] || _none "Could not resolve the budget resource name for ${cname}."

plan="$(plans_dir)/budget-rebalance.md"
run_gads mutate campaign-budget-update --budget-resource-name "$rn" --amount-micros "$amt" --plan "$plan" >/dev/null

{ printf '# Budget rebalance — %s — %s\n\n' "$(review_subject)" "$(date +%F)"
  printf 'Sufficiency: **pass** ($%s over %sd, floor $%s).\n\n' "$spend_usd" "$LOOKBACK" "${MIN_SPEND_USD:-50}"
  printf 'Single top pacing-justified reallocation (dry-run plan; apply via `plan-then-apply.sh`):\n\n'
  printf -- '- campaign: %s (%s)\n' "$cname" "$cid"
  printf -- '- budget resource: %s\n' "$rn"
  printf -- '- current daily budget micros: %s → proposed: %s (aligned to %sd expected run-rate)\n' "$cur_budget" "$amt" "$LOOKBACK"
  printf -- '- plan: %s\n' "$plan"; } >"$out"
_log "-> reallocation proposed (see ${out})."
exit 10
