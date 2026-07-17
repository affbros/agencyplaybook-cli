#!/usr/bin/env bash
# name: scan-query-mining
# binary: apb-gads
# tier: 2
# cadence: weekly
# description: Weekly ranked opportunity scan for search-query mining (the promotion angle — converting search terms not yet added as keywords; scan-waste.sh covers the negation angle from the same underlying search-term data). Runs search-term-analysis (status-write context: it ties each term to the triggering keyword and computes per-term CPA/ROAS) and search-term-promotion (candidate source: min-conversions-filtered terms with real per-candidate impressions/clicks/conversions/cost, intent-classified match type, and a historical-CPC suggested bid). search-term-promotion's candidate shape ({ad_group_id, text, metrics:{...}}) is a clean field-rename away from `mutate keyword-add-bulk --from-file`'s {items:[{ad_group_id, text, match_type}]} schema, so surviving candidates get a real dry-run plan doc.
# writes: plan-doc
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"
# shellcheck source=lib/sufficiency.sh
source "${HERE}/lib/sufficiency.sh"
# shellcheck source=lib/cooldown.sh
source "${HERE}/lib/cooldown.sh"

WATCH_NAME="scan-query-mining"
LOOKBACK=90
parse_common_args "$@"
suff_load_thresholds

analysis="$(run_gads playbook search-term-analysis --lookback-days "$LOOKBACK")"
status_write query-mining-analysis "$analysis"

promo="$(run_gads playbook search-term-promotion --lookback-days "$LOOKBACK")"
status_write query-mining-promotion "$promo"

candidates="$(printf '%s' "$promo" | jq -c '
  [ (.candidates // [])[]
    | { entity_type: "search_term_promotion",
        entity_id: (.ad_group_id // "unknown"),
        entity_name: ((.campaign_name // "campaign") + " / " + (.text // "term")),
        metric_summary: "impressions=\((.metrics.impressions) // 0) clicks=\((.metrics.clicks) // 0) conversions=\((.metrics.conversions) // 0) cpa_micros=\((.metrics.cpa_micros) // 0)",
        impact_hint: (.reason // "converting search term not yet promoted to keyword"),
        conversions: ((.metrics.conversions) // 0), spend_usd: (((.metrics.cost_micros) // 0) / 1000000),
        impressions: ((.metrics.impressions) // 0),
        ad_group_id: .ad_group_id, text: .text, match_type: .match_type }
  ]' 2>/dev/null || echo '[]')"

opportunities="[]"; insufficient="[]"; cooling="[]"
n="$(printf '%s' "$candidates" | jq 'length')"
for i in $(seq 0 $((n - 1))); do
  cand="$(printf '%s' "$candidates" | jq -c ".[$i]")"
  metrics_json="$(printf '%s' "$cand" | jq -c '{conversions, spend_usd, impressions}')"
  verdict="$(sufficient "$metrics_json")"
  if [[ "$verdict" == fail* ]]; then
    insufficient="$(jq -cn --argjson arr "$insufficient" --argjson c "$cand" --arg v "$verdict" \
      '$arr + [ ($c + {sufficiency: $v} | del(.ad_group_id, .text, .match_type)) ]')"
    continue
  fi
  cool="$(cooldown_check "$(printf '%s' "$cand" | jq -r '.entity_id')")"
  if [ "$cool" = "cooling" ]; then
    cooling="$(jq -cn --argjson arr "$cooling" --argjson c "$cand" '$arr + [ ($c | del(.ad_group_id, .text, .match_type)) ]')"
    continue
  fi
  candidates="$(printf '%s' "$candidates" | jq -c --argjson i "$i" --arg cool "$cool" \
    'to_entries | map(if .key == $i then .value + {sufficiency: "pass", cooldown: $cool} else .value end) | map(.value)')"
done

survivors="$(printf '%s' "$candidates" | jq -c '[.[] | select(.sufficiency == "pass")]')"
ranked="$(printf '%s' "$survivors" | jq -c 'sort_by(-.conversions, -.impressions)')"
opportunities="$(printf '%s' "$ranked" | jq -c --argjson k "$CHANGE_BUDGET" '.[0:$k]')"
deferred="$(printf '%s' "$ranked" | jq -c --argjson k "$CHANGE_BUDGET" '.[$k:] | map(del(.ad_group_id, .text, .match_type))')"

plans="$(plans_dir)"
opp_count="$(printf '%s' "$opportunities" | jq 'length')"
if [ "$opp_count" -gt 0 ]; then
  from_file="${plans}/scan-query-mining-promote.json"
  printf '%s' "$opportunities" | jq -c '{items: [.[] | {ad_group_id, text, match_type}]}' >"$from_file"
  plan_path="${plans}/scan-query-mining-$(date +%s).md"
  run_gads mutate keyword-add-bulk --from-file "$from_file" --plan "$plan_path" >/dev/null
  opportunities="$(printf '%s' "$opportunities" | jq -c --arg p "$plan_path" '[.[] | . + {plan_doc: $p} | del(.ad_group_id, .text, .match_type)]')"
else
  opportunities="[]"
fi

scan_write_report scan-query-mining "$opportunities" "$insufficient" "$cooling" "$deferred"
scan_finish "$opportunities"
