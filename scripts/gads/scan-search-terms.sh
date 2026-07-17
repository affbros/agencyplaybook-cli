#!/usr/bin/env bash
# name: scan-search-terms
# binary: apb-gads
# tier: 2
# cadence: weekly
# description: The gads-only 7th scan — no apb (Meta) equivalent, since Meta has no keyword-planning surface. Seeds Google's KeywordPlanIdeaService from the account's own live keyword texts (`keyword list`, top distinct terms) and runs `plan keyword-ideas` for net-new keyword-idea harvest (avg monthly searches, competition, top-of-page bid range) — genuinely new terms the account isn't running yet. These ideas structurally carry zero conversions/spend and no in-account impressions (they aren't live keywords), so they always land in insufficient_data under the shared sufficiency gate — which is the correct read here: an idea with no run history has nothing to judge performance on yet, no matter how large its external search volume. Advisory only; adding an idea as a keyword is a human relevance call this script does not make, so opportunities (on the rare account where an idea DOES clear gating some other way) get a suggested_command, never a plan doc.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"
# shellcheck source=lib/sufficiency.sh
source "${HERE}/lib/sufficiency.sh"
# shellcheck source=lib/cooldown.sh
source "${HERE}/lib/cooldown.sh"

WATCH_NAME="scan-search-terms"
LOOKBACK=30
parse_common_args "$@"
suff_load_thresholds

kw="$(run_gads keyword list --limit 50)"
status_write search-terms-existing-keywords "$kw"

seeds="$(printf '%s' "$kw" | jq -r '
  [ (.results // [])[] | .adGroupCriterion.keyword.text // empty ]
  | unique | .[0:5] | .[]' 2>/dev/null || true)"

if [ -z "$seeds" ]; then
  _log "  no existing keywords to seed keyword-ideas from — nothing to harvest this run"
  scan_write_report scan-search-terms "[]" "[]" "[]" "[]"
  scan_finish "[]"
fi

seed_args=()
while IFS= read -r s; do
  [ -n "$s" ] && seed_args+=(--seed-keyword "$s")
done <<<"$seeds"

ideas="$(run_gads plan keyword-ideas "${seed_args[@]}" --limit 20)"
status_write search-terms-keyword-ideas "$ideas"

candidates="$(printf '%s' "$ideas" | jq -c '
  [ (.results // [])[]
    | { entity_type: "keyword_idea", entity_id: (.text // "idea"),
        entity_name: (.text // "idea"),
        metric_summary: "avg_monthly_searches=\(.avg_monthly_searches // 0) competition=\(.competition // \"?\") top_of_page_bid_usd=\((.low_top_of_page_bid_usd) // 0)-\((.high_top_of_page_bid_usd) // 0)",
        impact_hint: "keyword-idea harvest candidate — not yet running in this account",
        conversions: 0, spend_usd: 0, impressions: (.avg_monthly_searches // 0) }
  ]' 2>/dev/null || echo '[]')"

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
ranked="$(printf '%s' "$survivors" | jq -c 'sort_by(-.impressions)')"
opportunities="$(printf '%s' "$ranked" | jq -c --argjson k "$CHANGE_BUDGET" '.[0:$k]')"
deferred="$(printf '%s' "$ranked" | jq -c --argjson k "$CHANGE_BUDGET" '.[$k:]')"

opportunities="$(printf '%s' "$opportunities" | jq -c --arg cust "$CUSTOMER" '
  [.[] | . + {plan_doc: null,
    suggested_command: ("apb-gads mutate keyword-add-bulk --customer " + $cust + " --from-file <ad-group-mapped-idea.json> --plan <path>")}]')"

scan_write_report scan-search-terms "$opportunities" "$insufficient" "$cooling" "$deferred"
scan_finish "$opportunities"
