#!/usr/bin/env bash
# name: monthly-strategic-review
# binary: apb-gads
# tier: 3
# cadence: monthly
# description: The long-lookback strategic pass (default 90d). Runs apb-gads's strategic playbook set — campaign-bid-strategy-audit (bidding), account-structure-audit (structure), budget-rebalance (budget allocation), audience-performance (audience) — read-only, and assembles each one's headline into a single narrative monthly-strategic-review.md. Emits AT MOST one structural plan doc: account-structure-audit rendered via --plan; the gate is real and universal — the binary writes a JSON twin ONLY when the plan carries machine-actionable operations, so a twin next to the doc is the pass signal. Plan doc is dry-run by construction; zero API mutation. Exit 0 = narrative only, 10 = a structural plan was proposed.
# writes: plan-doc
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"

WATCH_NAME="monthly-strategic-review"
LOOKBACK=90
parse_common_args "$@"

# Run the strategic set read-only (literal slugs so parity validates each).
bid="$(run_gads playbook campaign-bid-strategy-audit --lookback-days "$LOOKBACK")"; status_write campaign-bid-strategy-audit "$bid"
struct="$(run_gads playbook account-structure-audit --lookback-days "$LOOKBACK")";   status_write account-structure-audit "$struct"
budg="$(run_gads playbook budget-rebalance --lookback-days "$LOOKBACK")";            status_write budget-rebalance "$budg"
aud="$(run_gads playbook audience-performance --lookback-days "$LOOKBACK")";         status_write audience-performance "$aud"

_summary() { # <label> <json>
  local rec
  rec="$(jq -r '((.recommendations // [])[0]) // (.summary?) // "read the JSON for detail"
    | if type=="object" then (.action? // .recommendation? // (tojson)) else tostring end' <<<"$2" 2>/dev/null || echo "read the JSON for detail")"
  printf -- '- **%s** — %s\n' "$1" "$rec"
}

# The single structural plan doc: account structure, rendered dry-run. Twin
# existence (plan_doc: only written for machine-actionable plans) is the gate.
structural_plan="$(plans_dir)/monthly-account-structure.md"
run_gads playbook account-structure-audit --lookback-days "$LOOKBACK" --plan "$structural_plan" >/dev/null
[ -f "${structural_plan}.json" ] || structural_plan=""

out="${OUT_DIR}/monthly-strategic-review.md"
{
  printf '# Monthly strategic review — %s — %s\n\n' "$(review_subject)" "$(date +%F)"
  printf '_Lookback: %sd. Read-only strategic bundle._\n\n' "$LOOKBACK"
  printf '## Narrative\n\n'
  _summary "Bidding strategy" "$bid"
  _summary "Account structure" "$struct"
  _summary "Budget allocation" "$budg"
  _summary "Audience performance" "$aud"
  printf '\n## Structural change\n\n'
  if [ -n "$structural_plan" ]; then
    printf 'One structural plan proposed (dry-run) — review and apply with `plan-then-apply.sh`:\n\n'
    printf -- '- account-structure plan: %s\n' "$structural_plan"
  else
    printf 'No structural change proposed this month — account-structure-audit produced no machine-actionable plan over the %sd window (nothing to apply).\n' "$LOOKBACK"
  fi
} >"$out"
_log "-> wrote ${out}"

if [ -n "$structural_plan" ]; then exit 10; fi
exit 0
