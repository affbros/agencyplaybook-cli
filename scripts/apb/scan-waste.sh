#!/usr/bin/env bash
# name: scan-waste
# binary: apb
# tier: 2
# cadence: weekly
# description: Weekly opportunity scan for dormant/leaky spend. Runs the waste-audit playbook (the same one watch-account-pulse's siblings watch daily, but here the full flagged-entity list is ranked and gated for action rather than just alerted on) and renders a Track-A plan doc from the same invocation via --plan — the binary's own dry-run pipeline, zero API mutation. Every flagged entity is passed through the shared sufficiency gate (insufficient-data entities are reported as "keep collecting", never as an opportunity) and the cooldown gate (recently-touched entities deferred), then ranked by wasted spend and capped at the change budget; the remainder is listed for next review.
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
LOOKBACK=30
parse_common_args "$@"
suff_load_thresholds

PLAN_PATH="$(plans_dir)/scan-waste.md"
raw="$(run_apb playbook waste-audit --days "$LOOKBACK" --plan "$PLAN_PATH")"
status_write waste-audit "$raw"

candidates="$(printf '%s' "$raw" | jq -c '
  [ (.findings.flagged_items // [])[]
    | { entity_type: "adset",
        entity_id: (.adset_id? // .id? // .adset_name? // "unknown"),
        entity_name: (.adset_name? // .name? // "adset"),
        metric_summary: ("wasted $" + ((.wasted_spend? // .spend? // 0) | tostring)
          + "/period at cpa $" + ((.cpa? // 0) | tostring)),
        impact_hint: (.recommendation? // "pause or reallocate wasted spend"),
        conversions: (.conversions? // 0),
        spend_usd: (.spend? // .wasted_spend? // 0),
        impressions: (.impressions? // 0),
        impact: (.wasted_spend? // .spend? // 0)
      }
  ]' 2>/dev/null || echo '[]')"

gated="$(scan_gate_rank_cap "$candidates")"
opportunities="$(jq -c '.opportunities' <<<"$gated")"
insufficient="$(jq -c '.insufficient_data' <<<"$gated")"
cooling="$(jq -c '.deferred_cooldown' <<<"$gated")"
deferred="$(jq -c '.deferred_next_review' <<<"$gated")"

# apb's --plan renders a Track-A doc for the whole waste-audit run above (apb has
# no per-entity --plan targeting inside a playbook) — every surviving opportunity
# shares that one doc, which covers the account's flagged waste for this window.
opportunities="$(printf '%s' "$opportunities" | jq -c --arg p "$PLAN_PATH" 'map(. + {plan_doc: $p})')"

scan_write_report scan-waste "$opportunities" "$insufficient" "$cooling" "$deferred"
scan_finish "$opportunities"
