#!/usr/bin/env bash
# name: scan-waste
# binary: apb-gads
# tier: 2
# cadence: weekly
# description: Weekly ranked opportunity scan for wasted spend. Runs the waste-audit playbook (status-write only, for context — its `opportunities` array is competitor-term-only and carries no ad_group_id to target a mutation against) and the search-term-cleanup playbook, whose `candidate_actions` array (competitor-like queries + expensive zero-conversion queries) IS this script's opportunity source. This is the primary "real plan-doc" scan in the Tier-2 set: search-term-cleanup's own output shape is natively consumable by `mutate negative-keyword-add-bulk --from-file` (the binary accepts either {items:[...]} or the raw {candidate_actions:[...]} envelope), so surviving candidates get a real dry-run plan doc, not just a suggested_command.
# writes: plan-doc
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"
# shellcheck source=lib/sufficiency.sh
source "${HERE}/lib/sufficiency.sh"
# shellcheck source=lib/cooldown.sh
source "${HERE}/lib/cooldown.sh"

WATCH_NAME="scan-waste"
LOOKBACK=365
parse_common_args "$@"
suff_load_thresholds

waste="$(run_gads playbook waste-audit --lookback-days "$LOOKBACK")"
status_write waste-audit "$waste"

cleanup="$(run_gads playbook search-term-cleanup --lookback-days "$LOOKBACK")"
status_write waste-search-term-cleanup "$cleanup"

candidates="$(printf '%s' "$cleanup" | jq -c '
  [ (.candidate_actions // [])[]
    | select((.bulk_eligible // false) == true)
    | { entity_type: "search_term",
        entity_id: (.ad_group_id // "unknown"),
        entity_name: ((.campaign_name // "campaign") + " / " + (.search_term // "term")),
        metric_summary: "clicks=\(.clicks // 0) cost_micros=\(.cost_micros // 0) conversions=\(.conversions // 0) (\(.reason // \"waste\"))",
        impact_hint: .recommendation // "review for negative keyword addition",
        conversions: (.conversions // 0), spend_usd: ((.cost_micros // 0) / 1000000),
        impressions: 0,
        raw: . }
  ]' 2>/dev/null || echo '[]')"

opportunities="[]"; insufficient="[]"; cooling="[]"
n="$(printf '%s' "$candidates" | jq 'length')"
for i in $(seq 0 $((n - 1))); do
  cand="$(printf '%s' "$candidates" | jq -c ".[$i]")"
  metrics_json="$(printf '%s' "$cand" | jq -c '{conversions, spend_usd, impressions}')"
  verdict="$(sufficient "$metrics_json")"
  if [[ "$verdict" == fail* ]]; then
    insufficient="$(jq -cn --argjson arr "$insufficient" --argjson c "$cand" --arg v "$verdict" \
      '$arr + [ ($c + {sufficiency: $v} | del(.raw)) ]')"
    continue
  fi
  cool="$(cooldown_check "$(printf '%s' "$cand" | jq -r '.entity_id')")"
  if [ "$cool" = "cooling" ]; then
    cooling="$(jq -cn --argjson arr "$cooling" --argjson c "$cand" '$arr + [ ($c | del(.raw)) ]')"
    continue
  fi
  candidates="$(printf '%s' "$candidates" | jq -c --argjson i "$i" --arg cool "$cool" \
    'to_entries | map(if .key == $i then .value + {sufficiency: "pass", cooldown: $cool} else .value end) | map(.value)')"
done

survivors="$(printf '%s' "$candidates" | jq -c '[.[] | select(.sufficiency == "pass")]')"
ranked="$(printf '%s' "$survivors" | jq -c 'sort_by(-.spend_usd)')"
opportunities="$(printf '%s' "$ranked" | jq -c --argjson k "$CHANGE_BUDGET" '.[0:$k]')"
deferred="$(printf '%s' "$ranked" | jq -c --argjson k "$CHANGE_BUDGET" '.[$k:] | map(del(.raw))')"

plans="$(plans_dir)"
opp_count="$(printf '%s' "$opportunities" | jq 'length')"
if [ "$opp_count" -gt 0 ]; then
  from_file="${plans}/scan-waste-negatives.json"
  printf '%s' "$opportunities" | jq -c '{candidate_actions: [.[].raw]}' >"$from_file"
  plan_path="${plans}/scan-waste-$(date +%s).md"
  run_gads mutate negative-keyword-add-bulk --from-file "$from_file" --plan "$plan_path" >/dev/null
  opportunities="$(printf '%s' "$opportunities" | jq -c --arg p "$plan_path" '[.[] | . + {plan_doc: $p} | del(.raw)]')"
else
  opportunities="[]"
fi

scan_write_report scan-waste "$opportunities" "$insufficient" "$cooling" "$deferred"
scan_finish "$opportunities"
