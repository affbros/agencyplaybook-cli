#!/usr/bin/env bash
# name: scan-audience-health
# binary: apb-gads
# tier: 2
# cadence: weekly
# description: Weekly ranked opportunity scan for audience/user-list signal coverage. Runs the audience-performance playbook (per-audience-type aggregation across in-market/remarketing/demographics with real impressions+clicks+cost+conversions) and the pmax-asset-coverage playbook (per-asset-group audience-signal presence, among other completeness checks — used here only for its audience-signal advisory, not the full asset scorecard). audience-performance's `impressions` field doubles as the audience-size/volume proxy for the MIN_AUDIENCE_SIZE gate since Google exposes no first-class user-list-size metric on this view. Advisory only — Google exposes no mutate surface to reassign an audience type's bid-only/observation setting per-type in one call, so every surviving opportunity gets a suggested_command, never a plan doc.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"
# shellcheck source=lib/sufficiency.sh
source "${HERE}/lib/sufficiency.sh"
# shellcheck source=lib/cooldown.sh
source "${HERE}/lib/cooldown.sh"

WATCH_NAME="scan-audience-health"
LOOKBACK=90
parse_common_args "$@"
suff_load_thresholds

aud="$(run_gads playbook audience-performance --lookback-days "$LOOKBACK")"
status_write audience-health-performance "$aud"

pmax="$(run_gads playbook pmax-asset-coverage --lookback-days 30)"
status_write audience-health-pmax-asset-coverage "$pmax"

aud_candidates="$(printf '%s' "$aud" | jq -c '
  [ (.by_audience_type // [])[]
    | { entity_type: "audience_type", entity_id: .audience_type,
        entity_name: .audience_type,
        metric_summary: "impressions=\(.impressions // 0) clicks=\(.clicks // 0) cost_micros=\(.cost_micros // 0) cpa=\(.cpa // 0)",
        impact_hint: "audience-type volume/CPA signal for \(.audience_type // \"unknown\") — verify vs account CPA target",
        conversions: (.conversions // 0), spend_usd: ((.cost_micros // 0) / 1000000),
        impressions: (.impressions // 0) }
  ]' 2>/dev/null || echo '[]')"

sig_candidates="$(printf '%s' "$pmax" | jq -c '
  [ (.findings // [])[]
    | select((.has_audience_signal // true) == false)
    | { entity_type: "asset_group", entity_id: .asset_group_id,
        entity_name: (.asset_group_name // .asset_group_id // "asset group"),
        metric_summary: "coverage_pct=\(.coverage_pct // 0) missing audience signal",
        impact_hint: "PMAX asset group with no audience signal attached — slows learning",
        conversions: 0, spend_usd: 0, impressions: 0 }
  ]' 2>/dev/null || echo '[]')"

candidates="$(jq -cn --argjson a "$aud_candidates" --argjson b "$sig_candidates" '$a + $b')"

opportunities="[]"; insufficient="[]"; cooling="[]"
n="$(printf '%s' "$candidates" | jq 'length')"
for i in $(seq 0 $((n - 1))); do
  cand="$(printf '%s' "$candidates" | jq -c ".[$i]")"
  metrics_json="$(printf '%s' "$cand" | jq -c '{conversions, spend_usd, impressions}')"
  verdict="$(sufficient "$metrics_json")"
  # Audience-size gate: impressions also stand in for list-size volume here.
  impr="$(printf '%s' "$cand" | jq -r '.impressions // 0')"
  if [[ "$verdict" == fail* ]] || awk -v i="$impr" -v m="$MIN_AUDIENCE_SIZE" 'BEGIN{exit !(i+0 < m+0)}'; then
    [[ "$verdict" == pass ]] && verdict="fail — insufficient data — keep collecting (audience volume ${impr} below floor ${MIN_AUDIENCE_SIZE})"
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
ranked="$(printf '%s' "$survivors" | jq -c 'sort_by(-.impressions)')"
opportunities="$(printf '%s' "$ranked" | jq -c --argjson k "$CHANGE_BUDGET" '.[0:$k]')"
deferred="$(printf '%s' "$ranked" | jq -c --argjson k "$CHANGE_BUDGET" '.[$k:]')"

opportunities="$(printf '%s' "$opportunities" | jq -c --arg cust "$CUSTOMER" '
  [.[] | . + {plan_doc: null,
    suggested_command: ("apb-gads playbook audience-performance --customer " + $cust + " --lookback-days 90 --pretty")}]')"

scan_write_report scan-audience-health "$opportunities" "$insufficient" "$cooling" "$deferred"
scan_finish "$opportunities"
