#!/usr/bin/env bash
# name: watch-learning-phase
# binary: apb-gads
# tier: 1
# cadence: daily
# description: Watches which campaigns are still learning and must be protected from edits. Runs the pmax-maturity-gate playbook, whose per-campaign verdict includes a learning-band approximation and a collect_data state (immature / still gathering signal); this watchdog thresholds that to build the hands-off list. Each flagged campaign is annotated with a cooldown verdict from the shared cooldown library (was it changed recently via change_event). It reports for weekly review and never edits a campaign or bid strategy. Note: Google exposes no first-class learning flag, so this keys off the PMAX maturity gate's learning band; Search learning is approximated by smart-bidding readiness in the weekly tier.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"
# shellcheck source=lib/cooldown.sh
source "${HERE}/lib/cooldown.sh"

WATCH_NAME="watch-learning-phase"
LOOKBACK=30
parse_common_args "$@"

maturity="$(run_gads playbook pmax-maturity-gate --lookback-days "$LOOKBACK")"
status_write learning-phase "$maturity"

# Campaigns still in learning: learning band red/yellow, or a collect_data verdict.
flagged="$(printf '%s' "$maturity" | jq -c '
  [ .. | objects
    | select(
        ((((.learning? // .learning_band? // "") | tostring) | ascii_downcase) | test("red|yellow"))
        or ((((.verdict? // .recommendation? // "") | tostring) | ascii_downcase) | test("collect_data|collect data|not_ready|immature"))
      )
    | { name: (.name? // .campaign_name? // .campaign? // .id? // "campaign"),
        id: (.id? // .campaign_id? // ""),
        learning: (.learning? // .learning_band? // .verdict? // "learning") }
  ] | unique' 2>/dev/null || echo '[]')"

count="$(printf '%s' "$flagged" | jq 'length' 2>/dev/null || echo 0)"
if [ "${count:-0}" -gt 0 ]; then
  attn "${count} campaign(s) in/near learning — protect from edits — for weekly review:"
  while IFS=$'\t' read -r name id learning; do
    cd_verdict="$(cooldown_check "$id")"
    printf '         - %s: %s (cooldown: %s)\n' "$name" "$learning" "$cd_verdict"
  done < <(printf '%s' "$flagged" | jq -r '.[] | [.name, .id, .learning] | @tsv')
fi

finish
