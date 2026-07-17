#!/usr/bin/env bash
# name: scan-query-mining
# binary: apb
# tier: 2
# cadence: weekly
# description: Weekly opportunity scan for placement performance mining. Runs the placement-audit playbook (performance by placement with exclusion recommendations) and renders a Track-A plan doc from the same invocation via --plan, zero API mutation. Cross-checks the Ads Library (competitor creative/copy research) for the account's active campaigns as a read-only market-mining signal (status-file only, not gated as an opportunity — it has no per-entity sufficiency shape). Placement candidates are gated by sufficiency (insufficient-data candidates are reported as "keep collecting", never as an opportunity) and cooldown, then ranked by wasted-spend share and capped at the change budget.
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
LOOKBACK=30
: "${LIBRARY_QUERY:=}"
parse_common_args "$@"
suff_load_thresholds

PLAN_PATH="$(plans_dir)/scan-query-mining.md"
placement="$(run_apb playbook placement-audit --days "$LOOKBACK" --plan "$PLAN_PATH")"
status_write placement-audit "$placement"

# Ads Library competitor research is opt-in (needs a query term); skip quietly
# if the operator hasn't set one — this cross-check is informational only.
if [ -n "$LIBRARY_QUERY" ]; then
  library="$(run_apb library search --terms "$LIBRARY_QUERY" --limit 25 || echo '[]')"
  status_write library-search "$library"
fi

candidates="$(printf '%s' "$placement" | jq -c '
  [ (.findings.placements? // .findings.exclusion_candidates? // [])[]
    | { entity_type: "placement",
        entity_id: (.placement? // .placement_name? // .id? // "unknown"),
        entity_name: (.placement_name? // .placement? // "placement"),
        metric_summary: ("cpa $" + ((.cpa? // 0) | tostring) + " on $"
          + ((.spend? // 0) | tostring) + " spend"),
        impact_hint: (.recommendation? // "exclude or reduce this placement"),
        conversions: (.conversions? // 0),
        spend_usd: (.spend? // 0),
        impressions: (.impressions? // 0),
        impact: (.spend? // 0)
      }
  ]' 2>/dev/null || echo '[]')"

gated="$(scan_gate_rank_cap "$candidates")"
opportunities="$(jq -c '.opportunities' <<<"$gated")"
insufficient="$(jq -c '.insufficient_data' <<<"$gated")"
cooling="$(jq -c '.deferred_cooldown' <<<"$gated")"
deferred="$(jq -c '.deferred_next_review' <<<"$gated")"

# Shared plan doc from the placement-audit --plan call above (apb has no
# per-entity --plan targeting inside a playbook).
opportunities="$(printf '%s' "$opportunities" | jq -c --arg p "$PLAN_PATH" 'map(. + {plan_doc: $p})')"

scan_write_report scan-query-mining "$opportunities" "$insufficient" "$cooling" "$deferred"
scan_finish "$opportunities"
