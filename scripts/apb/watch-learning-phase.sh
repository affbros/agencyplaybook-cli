#!/usr/bin/env bash
# name: watch-learning-phase
# binary: apb
# tier: 1
# cadence: daily
# description: Watches which ad sets are in (or have bounced back into) Meta's learning phase by running the learning diagnose read and thresholding its per-ad-set learning status. Entities in learning are edit-fragile — a change resets their learning — so this watchdog is the "hands-off list": it reports them, annotates each with a cooldown verdict from the shared cooldown library (was it changed in the last N days), and flags the set for weekly review. It never edits an ad set.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"
# shellcheck source=lib/cooldown.sh
source "${HERE}/lib/cooldown.sh"

WATCH_NAME="watch-learning-phase"
LOOKBACK=14
parse_common_args "$@"

learning="$(run_apb learning diagnose --days "$LOOKBACK")"
status_write learning-phase "$learning"

# Ad sets whose learning status is still LEARNING / LEARNING_LIMITED / re-learning.
flagged="$(printf '%s' "$learning" | jq -c '
  [ .. | objects
    | select(((.learning_status? // .learning_stage? // .status? // .phase? // "") | tostring)
        | test("learning|relearn|re-learn|LIMITED";"i"))
    | { name: (.name? // .adset_name? // .id? // "adset"),
        id: (.id? // .adset_id? // ""),
        status: (.learning_status? // .learning_stage? // .status? // .phase?) }
  ] | unique' 2>/dev/null || echo '[]')"

count="$(printf '%s' "$flagged" | jq 'length' 2>/dev/null || echo 0)"
if [ "${count:-0}" -gt 0 ]; then
  attn "${count} ad set(s) in/near learning — protect from edits — for weekly review:"
  while IFS=$'\t' read -r name id status; do
    cd_verdict="$(cooldown_check "$id")"
    printf '         - %s: %s (cooldown: %s)\n' "$name" "$status" "$cd_verdict"
  done < <(printf '%s' "$flagged" | jq -r '.[] | [.name, .id, .status] | @tsv')
fi

finish
