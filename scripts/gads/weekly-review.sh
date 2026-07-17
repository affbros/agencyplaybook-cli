#!/usr/bin/env bash
# name: weekly-review
# binary: apb-gads
# tier: 3
# cadence: weekly
# description: The hands tier. Consumes the week's Tier-2 opportunity-scan reports (scan-*.json under the last 7 dated status dirs) — or, if none ran this week, runs the scans fresh via bash — merges every candidate opportunity, dedupes by entity, then re-applies the gates as ONE consolidated set: sufficiency + cooldown were already enforced per scan, so this pass applies ONE global change budget (largest-impact-first) across the union. Survivors become a single consolidated weekly-review.md that links the per-action dry-run plan docs the scans already rendered (zero API mutation here); if nothing survives it writes an explicit "no changes this week — here's why" report with the deferred/insufficient/cooling bucket counts (an explicitly good outcome). This is deliberately NOT scheduled by default — a human runs it. Exit 0 = no changes, 10 = changes proposed.
# writes: plan-doc
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"
# shellcheck source=lib/sufficiency.sh
source "${HERE}/lib/sufficiency.sh"

WATCH_NAME="weekly-review"
LOOKBACK=30
parse_common_args "$@"
suff_load_thresholds

# 1. Collect this week's scan opportunity reports (today back 7 days).
mapfile -t files < <(review_recent_reports 'scan-*.json')

if [ "${#files[@]}" -eq 0 ]; then
  _log "no scan reports in the last 7 days — running the Tier-2 scans fresh."
  for s in "$HERE"/scan-*.sh; do
    [ -e "$s" ] || continue
    _log "  -> $(basename "$s")"
    bash "$s" --customer "$CUSTOMER" --lookback "$LOOKBACK" --out-dir "$OUT_DIR" --quiet || true
  done
  mapfile -t files < <(ls "$OUT_DIR"/scan-*.json 2>/dev/null || true)
  sources="fresh Tier-2 scans ($(date +%F))"
else
  sources="${#files[@]} scan report(s) from the last 7 days"
fi

if [ "${#files[@]}" -eq 0 ]; then
  review_write_weekly '[]' '[]' '[]' '[]' "no scan data available" >/dev/null
  _log "-> no scan data; wrote no-changes weekly review."
  exit 0
fi

# 2. Merge every bucket across all reports.
opps="$(review_merge_field opportunities "${files[@]}")"
insuff="$(review_merge_field insufficient_data "${files[@]}")"
cooling="$(review_merge_field deferred_cooldown "${files[@]}")"
scan_deferred="$(review_merge_field deferred_next_review "${files[@]}")"

# 3. Dedupe opportunities by entity (keep the highest-impact instance), then apply
#    ONE global change budget across the union, largest-impact first.
merged="$(jq -c 'group_by(.entity_id) | map(max_by(.impact // .spend_usd // 0))
  | sort_by(-(.impact // .spend_usd // 0))' <<<"$opps")"
budget="${CHANGE_BUDGET:-3}"
survivors="$(jq -c --argjson k "$budget" '.[0:$k]' <<<"$merged")"
over_budget="$(jq -c --argjson k "$budget" '.[$k:]' <<<"$merged")"
# The scans' own over-budget deferrals fold into this week's global deferred bucket.
deferred="$(jq -cn --argjson a "$over_budget" --argjson b "$scan_deferred" '$a + $b')"

# 4. Render the ONE consolidated review (links each survivor's per-action plan doc).
review_write_weekly "$survivors" "$deferred" "$insuff" "$cooling" "$sources" >/dev/null

n="$(jq 'length' <<<"$survivors")"
if [ "$n" -gt 0 ]; then
  _log "-> ${n} change(s) proposed this week (see weekly-review.md)."
  exit 10
fi
_log "-> no changes this week (an explicitly good outcome)."
exit 0
