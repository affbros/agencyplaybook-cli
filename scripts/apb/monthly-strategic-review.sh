#!/usr/bin/env bash
# name: monthly-strategic-review
# binary: apb
# tier: 3
# cadence: monthly
# description: The long-lookback strategic pass (default 90d). Runs apb's strategic playbook set — bid-strategy, consolidation-advisor, scale-roadmap, segment-performance, advantage-adoption — read-only, and assembles each one's grade + headline recommendation into a single narrative monthly-strategic-review.md. Emits AT MOST one structural plan doc: the top structural item (account consolidation) rendered via --plan, and only when consolidation-advisor actually surfaced a recommendation (the playbook's own thresholds are the sufficiency gate — it will not recommend consolidation on thin data). Plan doc is dry-run by construction; zero API mutation. Exit 0 = narrative only, 10 = a structural plan was proposed.
# writes: plan-doc
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"

WATCH_NAME="monthly-strategic-review"
LOOKBACK=90
parse_common_args "$@"

# Run the strategic set read-only (literal slugs so parity validates each).
bid="$(run_apb playbook bid-strategy --days "$LOOKBACK")";            status_write bid-strategy "$bid"
con="$(run_apb playbook consolidation-advisor --days "$LOOKBACK")";   status_write consolidation-advisor "$con"
scale="$(run_apb playbook scale-roadmap --days "$LOOKBACK")";         status_write scale-roadmap "$scale"
seg="$(run_apb playbook segment-performance --days "$LOOKBACK")";     status_write segment-performance "$seg"
adv="$(run_apb playbook advantage-adoption --days "$LOOKBACK")";      status_write advantage-adoption "$adv"

_summary() { # <label> <json>
  local grade rec
  grade="$(jq -r '.grade // "N/A"' <<<"$2")"
  rec="$(jq -r '(.recommendations // [])[0] | (.action? // .recommendation? // . // "no action recommended")' <<<"$2" 2>/dev/null || echo "no action recommended")"
  printf -- '- **%s** — grade %s — %s\n' "$1" "$grade" "$rec"
}

# The single structural plan doc: consolidation, rendered dry-run. The gate is
# real and universal — the binary writes a JSON twin ONLY when the plan carries
# machine-actionable operations (plan_doc: no twin for an empty plan), so a twin
# next to the doc is the signal that something is actually proposable.
structural_plan="$(plans_dir)/monthly-consolidation.md"
run_apb playbook consolidation-advisor --days "$LOOKBACK" --plan "$structural_plan" >/dev/null
[ -f "${structural_plan}.json" ] || structural_plan=""

out="${OUT_DIR}/monthly-strategic-review.md"
{
  printf '# Monthly strategic review — %s — %s\n\n' "$(review_subject)" "$(date +%F)"
  printf '_Lookback: %sd. Read-only strategic bundle._\n\n' "$LOOKBACK"
  printf '## Narrative\n\n'
  _summary "Bidding strategy" "$bid"
  _summary "Consolidation" "$con"
  _summary "Scale roadmap" "$scale"
  _summary "Segment performance" "$seg"
  _summary "Advantage+ adoption" "$adv"
  printf '\n## Structural change\n\n'
  if [ -n "$structural_plan" ]; then
    printf 'One structural plan proposed (dry-run) — review and apply with `plan-then-apply.sh`:\n\n'
    printf -- '- consolidation plan: %s\n' "$structural_plan"
  else
    printf 'No structural change proposed this month — consolidation-advisor produced no machine-actionable plan over the %sd window (nothing to apply: below its data-sufficiency thresholds, or already well-structured).\n' "$LOOKBACK"
  fi
} >"$out"
_log "-> wrote ${out}"

if [ -n "$structural_plan" ]; then exit 10; fi
exit 0
