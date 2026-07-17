#!/usr/bin/env bash
# name: scan-audience-health
# binary: apb
# tier: 2
# cadence: weekly
# description: Weekly opportunity scan for audience sizing and lookalike-seed sufficiency. Reads the account's custom audiences (audience list) and estimates pairwise overlap for the top few by size (audience overlap) — both pure reads. Audiences below the audience-size floor are gated by sufficiency (reported as "keep collecting", never as an opportunity). Audience health has no clean --plan-capable mutation mapping (creating a lookalike or refreshing a custom audience needs operator judgment on seed/geo/ratio this scan can't infer), so surviving opportunities carry a suggested_command instead of a rendered plan doc — the operator runs it, or points a future weekly-review at it.
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
LOOKBACK=30
parse_common_args "$@"
suff_load_thresholds

audiences="$(run_apb audience list)"
status_write audience-list "$audiences"

ids="$(printf '%s' "$audiences" | jq -r '[.[].id] | .[0:10] | join(",")' 2>/dev/null || echo '')"
overlap='{}'
if [ -n "$ids" ]; then
  overlap="$(run_apb audience overlap --audience-ids "$ids" || echo '{}')"
  status_write audience-overlap "$overlap"
fi

candidates="$(printf '%s' "$audiences" | jq -c '
  [ .[]
    | { entity_type: "audience",
        entity_id: (.id? // "unknown"),
        entity_name: (.name? // "audience"),
        size: (.approximate_count_upper_bound? // .approximate_count_lower_bound? // 0),
        subtype: (.subtype? // "unknown")
      }
  ]' 2>/dev/null || echo '[]')"

# Audience health is gated on SIZE, not conversions/spend (audiences carry no
# performance metrics) — sufficient_audience_size(), not the generic
# sufficient(); scan_gate_rank_cap isn't used here for that reason.
opportunities="[]"; insufficient="[]"; cooling="[]"
n="$(printf '%s' "$candidates" | jq 'length' 2>/dev/null || echo 0)"
if [ "${n:-0}" -gt 0 ]; then
  for i in $(seq 0 $((n - 1))); do
    c="$(printf '%s' "$candidates" | jq -c ".[$i]")"
    eid="$(printf '%s' "$c" | jq -r '.entity_id')"
    size="$(printf '%s' "$c" | jq -r '.size')"
    suf="$(sufficient_audience_size "$size")"
    entry="$(printf '%s' "$c" | jq -c '
      { entity_type, entity_id, entity_name,
        metric_summary: ("size " + (.size | tostring) + ", subtype " + .subtype),
        impact_hint: "at/above the lookalike-seed floor — good LAL seed / periodic refresh candidate" }')"
    if [ "$suf" != "pass" ]; then
      insufficient="$(jq -cn --argjson arr "$insufficient" --argjson e "$entry" --arg s "$suf" \
        '$arr + [$e + {sufficiency: $s}]')"
      continue
    fi
    cdv="$(cooldown_check "$eid")"
    if [ "$cdv" = "cooling" ]; then
      cooling="$(jq -cn --argjson arr "$cooling" --argjson e "$entry" \
        '$arr + [$e + {sufficiency: "pass", cooldown: "cooling"}]')"
      continue
    fi
    opportunities="$(jq -cn --argjson arr "$opportunities" --argjson e "$entry" --arg cd "$cdv" \
      '$arr + [$e + {sufficiency: "pass", cooldown: $cd}]')"
  done
fi

ranked="$(printf '%s' "$opportunities" | jq -c 'sort_by(-(.size // 0))')"
capped="$(printf '%s' "$ranked" | jq -c --argjson k "${CHANGE_BUDGET:-3}" '.[0:$k]')"
deferred="$(printf '%s' "$ranked" | jq -c --argjson k "${CHANGE_BUDGET:-3}" '.[$k:]')"

# No safe generic --plan mapping (see manifest description) — attach an
# operator-runnable suggested command instead of rendering a doc.
capped="$(printf '%s' "$capped" | jq -c --arg acct "$ACCOUNT" '
  map(. + {plan_doc: null,
    suggested_command: ("apb audience create-lookalike --account " + $acct
      + " --source " + .entity_id + " --ratio 0.01 --country US --name \"" + .entity_name + " LAL 1%\" --plan <path>")})')"

scan_write_report scan-audience-health "$capped" "$insufficient" "$cooling" "$deferred"
scan_finish "$capped"
