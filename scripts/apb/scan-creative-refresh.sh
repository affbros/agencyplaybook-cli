#!/usr/bin/env bash
# name: scan-creative-refresh
# binary: apb
# tier: 2
# cadence: weekly
# description: Weekly opportunity scan for fatigue-ranked creative-refresh candidates plus creative-coverage gaps. Runs the fatigue-index playbook (frequency creep + CTR decay scoring) and renders a Track-A plan doc from the same invocation via --plan, zero API mutation. Cross-checks the creative-mix playbook for structural format-diversity gaps (read-only, status-file only). Candidates are gated by sufficiency (insufficient-data candidates are reported as "keep collecting", never as an opportunity) and cooldown, then ranked by fatigue severity and capped at the change budget.
# writes: plan-doc
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"
# shellcheck source=lib/sufficiency.sh
source "${HERE}/lib/sufficiency.sh"
# shellcheck source=lib/cooldown.sh
source "${HERE}/lib/cooldown.sh"

WATCH_NAME="scan-creative-refresh"
LOOKBACK=30
parse_common_args "$@"
suff_load_thresholds

PLAN_PATH="$(plans_dir)/scan-creative-refresh.md"
fatigue="$(run_apb playbook fatigue-index --days "$LOOKBACK" --plan "$PLAN_PATH")"
status_write fatigue-index "$fatigue"

mix="$(run_apb playbook creative-mix)"
status_write creative-mix "$mix"

candidates="$(printf '%s' "$fatigue" | jq -c '
  [ (.findings.flagged_ads? // .findings.candidates? // .findings.ads? // [])[]
    | { entity_type: "ad",
        entity_id: (.ad_id? // .id? // .ad_name? // "unknown"),
        entity_name: (.ad_name? // .name? // "ad"),
        metric_summary: ("fatigue score " + ((.fatigue_score? // .score? // 0) | tostring)
          + ", frequency " + ((.frequency? // 0) | tostring)),
        impact_hint: (.recommendation? // .verdict? // "refresh creative"),
        conversions: (.conversions? // 0),
        spend_usd: (.spend? // 0),
        impressions: (.impressions? // 0),
        impact: (.fatigue_score? // .score? // .spend? // 0)
      }
  ]' 2>/dev/null || echo '[]')"

gated="$(scan_gate_rank_cap "$candidates")"
opportunities="$(jq -c '.opportunities' <<<"$gated")"
insufficient="$(jq -c '.insufficient_data' <<<"$gated")"
cooling="$(jq -c '.deferred_cooldown' <<<"$gated")"
deferred="$(jq -c '.deferred_next_review' <<<"$gated")"

# Shared plan doc from the fatigue-index --plan call above (apb has no
# per-entity --plan targeting inside a playbook).
opportunities="$(printf '%s' "$opportunities" | jq -c --arg p "$PLAN_PATH" 'map(. + {plan_doc: $p})')"

scan_write_report scan-creative-refresh "$opportunities" "$insufficient" "$cooling" "$deferred"
scan_finish "$opportunities"
