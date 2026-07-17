#!/usr/bin/env bash
# name: scan-scaling-readiness
# binary: apb-gads
# tier: 2
# cadence: weekly
# description: Weekly ranked opportunity scan for scale-readiness. Runs the pmax-scaling-plan playbook (per-PMAX-campaign Go/No-Go budget-scaling decision, already maturity+profitability+halt-band+no-stacking gated by the binary) and the smart-bidding-readiness playbook (per-campaign 0-90 readiness score for a manual-CPC -> Smart Bidding transition). Candidates clearing this script's own data-sufficiency + cooldown + change-budget gates are ranked by spend/conversions and capped at CHANGE_BUDGET per run; the rest are deferred. PMAX budget-scale-up candidates get a real dry-run plan doc via `mutate campaign-budget-update` (the playbook's own budget_increase_candidates already carry the exact budget_resource_name + amount_micros to apply); Smart Bidding transition candidates are advisory only (a strategy-type flip needs an operator's target-CPA/target-ROAS judgment call) and get a suggested_command instead.
# writes: plan-doc
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"
# shellcheck source=lib/sufficiency.sh
source "${HERE}/lib/sufficiency.sh"
# shellcheck source=lib/cooldown.sh
source "${HERE}/lib/cooldown.sh"

WATCH_NAME="scan-scaling-readiness"
LOOKBACK=30
parse_common_args "$@"
suff_load_thresholds

pmax="$(run_gads playbook pmax-scaling-plan --lookback-days "$LOOKBACK")"
status_write scaling-pmax "$pmax"

sbr="$(run_gads playbook smart-bidding-readiness --lookback-days "$LOOKBACK")"
status_write scaling-smart-bidding "$sbr"

# --- candidate extraction ----------------------------------------------------
# Type A: PMAX budget-scale-up candidates. budget_increase_candidates is
# already the binary's pre-filtered "go" list; join to campaigns[] by
# campaign_id for a human name + conversions (spend comes from cost_micros on
# the candidate itself).
pmax_candidates="$(printf '%s' "$pmax" | jq -c '
  (.campaigns // []) as $camps
  | [ (.budget_increase_candidates // [])[]
      | . as $c
      | ($camps[] | select(.campaign_id == $c.campaign_id)) as $camp
      | { slug: "pmax_budget_scale",
          entity_type: "campaign", entity_id: $c.campaign_id,
          entity_name: ($camp.campaign_name // $c.campaign_id // "campaign"),
          metric_summary: "cost_micros=\($c.cost_micros // 0) recommended +\($c.increment_pct // 0)% (\($c.reason // \"pmax_scale_up\"))",
          impact_hint: "budget scale-up candidate: \($camp.conversions // 0) conversions, current budget \($c.current_budget_micros // 0) micros -> \($c.amount_micros // 0) micros",
          conversions: ($camp.conversions // 0), spend_usd: (($c.cost_micros // 0) / 1000000),
          impressions: 0,
          budget_resource_name: $c.budget_resource_name, amount_micros: $c.amount_micros }
  ] | unique_by(.entity_id)' 2>/dev/null || echo '[]')"

# Type B: Smart Bidding transition candidates — score >= 80 (per the
# playbook's own "strong candidate" bar, echoed in its `recommendations`).
sbr_candidates="$(printf '%s' "$sbr" | jq -c '
  [ (.campaigns // [])[]
    | select((.readiness_score // 0) >= 80)
    | { slug: "smart_bidding_upgrade",
        entity_type: "campaign", entity_id: .campaign_id,
        entity_name: (.campaign_name // .campaign_id // "campaign"),
        metric_summary: "readiness_score=\(.readiness_score // 0)/\(.readiness_score_max // 90) verdict=\(.readiness_verdict // \"unknown\")",
        impact_hint: "smart-bidding transition candidate: \(.conversions_30d // 0) conversions/30d, current strategy \(.current_strategy // \"unknown\") -> \(.recommended_next_strategy // \"unknown\")",
        conversions: (.conversions_30d // 0), spend_usd: 0, impressions: 0,
        recommended_next_strategy: .recommended_next_strategy }
  ]' 2>/dev/null || echo '[]')"

candidates="$(jq -cn --argjson a "$pmax_candidates" --argjson b "$sbr_candidates" '$a + $b')"

# --- sufficiency + cooldown gating -------------------------------------------
opportunities="[]"; insufficient="[]"; cooling="[]"
n="$(printf '%s' "$candidates" | jq 'length')"
for i in $(seq 0 $((n - 1))); do
  cand="$(printf '%s' "$candidates" | jq -c ".[$i]")"
  metrics_json="$(printf '%s' "$cand" | jq -c '{conversions, spend_usd, impressions}')"
  verdict="$(sufficient "$metrics_json")"
  if [[ "$verdict" == fail* ]]; then
    insufficient="$(jq -cn --argjson arr "$insufficient" --argjson c "$cand" --arg v "$verdict" \
      '$arr + [ ($c + {sufficiency: $v}) ]')"
    continue
  fi
  cool="$(cooldown_check "$(printf '%s' "$cand" | jq -r '.entity_id')")"
  if [ "$cool" = "cooling" ]; then
    cooling="$(jq -cn --argjson arr "$cooling" --argjson c "$cand" '$arr + [$c]')"
    continue
  fi
  candidates="$(printf '%s' "$candidates" | jq -c --argjson i "$i" --arg cool "$cool" \
    'to_entries | map(if .key == $i then .value + {sufficiency: "pass", cooldown: $cool} else .value end) | map(.value)')"
done

survivors="$(printf '%s' "$candidates" | jq -c '[.[] | select(.sufficiency == "pass")]')"
ranked="$(printf '%s' "$survivors" | jq -c 'sort_by(-(.spend_usd + .conversions))')"
opportunities="$(printf '%s' "$ranked" | jq -c --argjson k "$CHANGE_BUDGET" '.[0:$k]')"
deferred="$(printf '%s' "$ranked" | jq -c --argjson k "$CHANGE_BUDGET" '.[$k:]')"

# --- render plan docs / suggested commands for surviving opportunities -------
plans="$(plans_dir)"
opp_count="$(printf '%s' "$opportunities" | jq 'length')"
final_opps="[]"
for i in $(seq 0 $((opp_count - 1))); do
  [ "$opp_count" -gt 0 ] || break
  o="$(printf '%s' "$opportunities" | jq -c ".[$i]")"
  slug="$(printf '%s' "$o" | jq -r '.slug')"
  eid="$(printf '%s' "$o" | jq -r '.entity_id')"
  if [ "$slug" = "pmax_budget_scale" ]; then
    brn="$(printf '%s' "$o" | jq -r '.budget_resource_name')"
    amt="$(printf '%s' "$o" | jq -r '.amount_micros')"
    plan_path="${plans}/scan-scaling-readiness-${eid}.md"
    run_gads mutate campaign-budget-update --budget-resource-name "$brn" --amount-micros "$amt" --plan "$plan_path" >/dev/null
    o="$(printf '%s' "$o" | jq -c --arg p "$plan_path" '. + {plan_doc: $p} | del(.budget_resource_name, .amount_micros, .slug)')"
  else
    strat="$(printf '%s' "$o" | jq -r '.recommended_next_strategy')"
    cmd="apb-gads mutate campaign-update-bidding-strategy --customer ${CUSTOMER} --campaign-id ${eid} --strategy-type ${strat} --plan <path>"
    o="$(printf '%s' "$o" | jq -c --arg cmd "$cmd" '. + {plan_doc: null, suggested_command: $cmd} | del(.recommended_next_strategy, .slug)')"
  fi
  final_opps="$(jq -cn --argjson arr "$final_opps" --argjson o "$o" '$arr + [$o]')"
done
opportunities="$final_opps"

insufficient="$(printf '%s' "$insufficient" | jq -c '[.[] | del(.slug, .budget_resource_name, .amount_micros, .recommended_next_strategy)]')"
cooling="$(printf '%s' "$cooling" | jq -c '[.[] | del(.slug, .budget_resource_name, .amount_micros, .recommended_next_strategy)]')"
deferred="$(printf '%s' "$deferred" | jq -c '[.[] | del(.slug, .budget_resource_name, .amount_micros, .recommended_next_strategy)]')"

scan_write_report scan-scaling-readiness "$opportunities" "$insufficient" "$cooling" "$deferred"
scan_finish "$opportunities"
