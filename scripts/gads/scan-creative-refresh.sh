#!/usr/bin/env bash
# name: scan-creative-refresh
# binary: apb-gads
# tier: 2
# cadence: weekly
# description: Weekly ranked opportunity scan for creative refresh candidates. Extends watch-fatigue.sh's daily-alert extraction of the rsa-quality-audit playbook into a ranked weekly view (its `refresh_candidates` array is already the binary's own POOR-ad-strength / serious-finding / low-score shortlist) and adds the ad-rotation-audit playbook's zero/single-ad ad-group findings (no rotation surface at all). Both signal sets are build-completeness/quality signals, not performance metrics — Google exposes no per-ad spend/conversion breakdown here (see rsa-quality-audit's own notes), so candidates carry zero conversions/spend/impressions and structurally land in insufficient_data rather than opportunities; this is intentional, not a bug — a fatigued or empty ad group has nothing to "collect more data" on, but this scan's sufficiency gate is the same shared primitive as every other Tier-2 scan, and a creative swap always needs a human copywriting judgment call regardless. No plan-doc mapping: refreshing an ad means writing new creative, not a mechanical mutation this script can safely author. suggested_command points at `orchestrate ad-refresh`.
# writes: never
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

rsa="$(run_gads playbook rsa-quality-audit --lookback-days "$LOOKBACK")"
status_write creative-refresh-rsa "$rsa"

rot="$(run_gads playbook ad-rotation-audit --lookback-days "$LOOKBACK")"
status_write creative-refresh-rotation "$rot"

rsa_candidates="$(printf '%s' "$rsa" | jq -c '
  [ (.refresh_candidates // [])[]
    | { entity_type: "rsa_ad", entity_id: (.ad_id // "unknown"),
        entity_name: ("ad_group " + (.ad_group_id // "?")),
        metric_summary: "ad_strength=\(.ad_strength // \"?\") score=\(.score // 0)",
        impact_hint: (.reason // "quality-decay refresh candidate"),
        conversions: 0, spend_usd: 0, impressions: 0 }
  ]' 2>/dev/null || echo '[]')"

rotation_candidates="$(printf '%s' "$rot" | jq -c '
  [ ((.zero_ad_ad_groups // []) + (.single_ad_ad_groups // []))[]
    | { entity_type: "ad_group", entity_id: (.ad_group_id // "unknown"),
        entity_name: (.name // .ad_group_id // "ad group"),
        metric_summary: "active_ad_count=\(.active_ad_count // 0)",
        impact_hint: "insufficient rotation surface — add ad variants",
        conversions: 0, spend_usd: 0, impressions: 0 }
  ]' 2>/dev/null || echo '[]')"

candidates="$(jq -cn --argjson a "$rsa_candidates" --argjson b "$rotation_candidates" '$a + $b')"

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
ranked="$survivors"
opportunities="$(printf '%s' "$ranked" | jq -c --argjson k "$CHANGE_BUDGET" '.[0:$k]')"
deferred="$(printf '%s' "$ranked" | jq -c --argjson k "$CHANGE_BUDGET" '.[$k:]')"

opportunities="$(printf '%s' "$opportunities" | jq -c --arg cust "$CUSTOMER" '
  [.[] | . + {plan_doc: null,
    suggested_command: ("apb-gads orchestrate ad-refresh --customer " + $cust + " --ad-group-id " + .entity_id + " --headline <new-headline> --description <new-description> --plan <path>")}]')"

scan_write_report scan-creative-refresh "$opportunities" "$insufficient" "$cooling" "$deferred"
scan_finish "$opportunities"
