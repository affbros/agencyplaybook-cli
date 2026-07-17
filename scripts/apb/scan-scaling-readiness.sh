#!/usr/bin/env bash
# name: scan-scaling-readiness
# binary: apb
# tier: 2
# cadence: weekly
# description: Weekly opportunity scan for scale candidates — stable CPA, headroom, sufficiency-passed. Runs the scale-roadmap playbook (budget scaling projections with diminishing returns) and renders a Track-A plan doc from the same invocation via --plan, zero API mutation. Cross-checks the rebalance playbook's top-quartile adsets as a second scaling-readiness signal (read-only, status-file only — no second plan doc). Candidates are gated by sufficiency (insufficient-data candidates are reported as "keep collecting", never as an opportunity) and cooldown, then ranked by projected daily-conversion upside and capped at the change budget.
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

PLAN_PATH="$(plans_dir)/scan-scaling-readiness.md"
roadmap="$(run_apb playbook scale-roadmap --days "$LOOKBACK" --plan "$PLAN_PATH")"
status_write scale-roadmap "$roadmap"

rebalance="$(run_apb playbook rebalance --days "$LOOKBACK")"
status_write rebalance "$rebalance"

candidates="$(jq -c -n --argjson a "$roadmap" --argjson b "$rebalance" '
  ( ($a.findings.candidates? // $a.findings.scale_candidates? // $a.recommendations? // [])
    + ($b.findings.top_quartile? // []) )
  | [ .[]
      | { entity_type: "adset",
          entity_id: (.adset_id? // .id? // .adset_name? // "unknown"),
          entity_name: (.adset_name? // .name? // "adset"),
          metric_summary: ("cpa $" + ((.cpa? // .this_cpa? // 0) | tostring)
            + ", daily spend $" + ((.daily_spend? // .spend? // 0) | tostring)),
          impact_hint: (.recommendation? // .action? // "candidate for budget scale-up"),
          conversions: (.conversions? // 0),
          spend_usd: (.daily_spend? // .spend? // 0),
          impressions: (.impressions? // 0),
          impact: (.projected_additional_conversions_per_day? // .daily_spend? // .spend? // 0)
        }
    ]' 2>/dev/null || echo '[]')"

gated="$(scan_gate_rank_cap "$candidates")"
opportunities="$(jq -c '.opportunities' <<<"$gated")"
insufficient="$(jq -c '.insufficient_data' <<<"$gated")"
cooling="$(jq -c '.deferred_cooldown' <<<"$gated")"
deferred="$(jq -c '.deferred_next_review' <<<"$gated")"

# Shared plan doc from the scale-roadmap --plan call above (apb has no
# per-entity --plan targeting inside a playbook).
opportunities="$(printf '%s' "$opportunities" | jq -c --arg p "$PLAN_PATH" 'map(. + {plan_doc: $p})')"

scan_write_report scan-scaling-readiness "$opportunities" "$insufficient" "$cooling" "$deferred"
scan_finish "$opportunities"
