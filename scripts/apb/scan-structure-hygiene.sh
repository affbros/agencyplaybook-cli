#!/usr/bin/env bash
# name: scan-structure-hygiene
# binary: apb
# tier: 2
# cadence: weekly
# description: Weekly opportunity scan for overlapping ad sets and campaign fragmentation. Runs the duplicate-detect playbook (auction self-competition via targeting overlap) and renders a Track-A plan doc from the same invocation via --plan, zero API mutation — duplicate-detect has no machine-actionable operation shape yet, so the rendered doc documents the finding rather than a concrete mutation (the binary's own "not yet plannable" outcome, a valid result, not an error). Cross-checks the consolidation-advisor playbook for ad-set fragmentation (read-only, status-file only). Candidates are gated by sufficiency (insufficient-data candidates are reported as "keep collecting", never as an opportunity) and cooldown, then ranked by targeting-overlap percentage and capped at the change budget.
# writes: plan-doc
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"
# shellcheck source=lib/sufficiency.sh
source "${HERE}/lib/sufficiency.sh"
# shellcheck source=lib/cooldown.sh
source "${HERE}/lib/cooldown.sh"

WATCH_NAME="scan-structure-hygiene"
LOOKBACK=30
parse_common_args "$@"
suff_load_thresholds

PLAN_PATH="$(plans_dir)/scan-structure-hygiene.md"
dup="$(run_apb playbook duplicate-detect --days "$LOOKBACK" --plan "$PLAN_PATH")"
status_write duplicate-detect "$dup"

consolidation="$(run_apb playbook consolidation-advisor --days "$LOOKBACK")"
status_write consolidation-advisor "$consolidation"

candidates="$(printf '%s' "$dup" | jq -c '
  [ (.findings.duplicates // [])[]
    | { entity_type: "adset",
        entity_id: (.adset_id? // "unknown"),
        entity_name: (.adset_name? // "adset"),
        metric_summary: ((.overlap_pct? // 0 | tostring) + "% targeting overlap with \""
          + (.duplicate_of_name? // "another adset") + "\""),
        impact_hint: (.recommendation? // "consider consolidating overlapping ad sets"),
        conversions: 0,
        spend_usd: (.this_spend? // 0),
        impressions: 0,
        impact: (.overlap_pct? // 0)
      }
  ]' 2>/dev/null || echo '[]')"

gated="$(scan_gate_rank_cap "$candidates")"
opportunities="$(jq -c '.opportunities' <<<"$gated")"
insufficient="$(jq -c '.insufficient_data' <<<"$gated")"
cooling="$(jq -c '.deferred_cooldown' <<<"$gated")"
deferred="$(jq -c '.deferred_next_review' <<<"$gated")"

# Shared plan doc from the duplicate-detect --plan call above (apb has no
# per-entity --plan targeting inside a playbook; this playbook is analysis-only
# so the doc records the finding rather than a concrete mutation).
opportunities="$(printf '%s' "$opportunities" | jq -c --arg p "$PLAN_PATH" 'map(. + {plan_doc: $p})')"

scan_write_report scan-structure-hygiene "$opportunities" "$insufficient" "$cooling" "$deferred"
scan_finish "$opportunities"
