#!/usr/bin/env bash
# name: scan-structure-hygiene
# binary: apb-gads
# tier: 2
# cadence: weekly
# description: Weekly ranked opportunity scan for account structural hygiene. Runs the duplicate-keywords playbook (same text+match-type keyword appearing in multiple ad groups — real, non-empty on even a small test account) as the primary candidate source, and the naming-convention-audit playbook for secondary status-write context (campaign/ad-group naming drift). Duplicate keywords carry no performance metrics of their own (Google doesn't attribute spend to a "duplicate" as a unit — it attributes to each instance separately), so candidates structurally land in insufficient_data; a dedup decision (which instance to keep) is a judgment call this script deliberately does not automate. No mutate surface cleanly collapses "N duplicate instances -> 1" in a single call, so every surviving item gets a suggested_command pointing at a read for manual triage, never a plan doc.
# writes: never
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

dup="$(run_gads playbook duplicate-keywords --lookback-days "$LOOKBACK")"
status_write structure-hygiene-duplicates "$dup"

naming="$(run_gads playbook naming-convention-audit --lookback-days "$LOOKBACK")"
status_write structure-hygiene-naming "$naming"

candidates="$(printf '%s' "$dup" | jq -c '
  [ (.duplicates // [])[]
    | { entity_type: "duplicate_keyword",
        entity_id: ((.keyword_text // "keyword") + "|" + (.match_type // "?")),
        entity_name: ((.keyword_text // "keyword") + " (" + (.match_type // "?") + ")"),
        metric_summary: "occurrences=\(.occurrences // 0)",
        impact_hint: "same keyword+match-type live in \(.occurrences // 0) ad groups — consolidate to avoid internal auction competition",
        conversions: 0, spend_usd: 0, impressions: 0 }
  ]' 2>/dev/null || echo '[]')"

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
    suggested_command: ("apb-gads keyword list --customer " + $cust + " --pretty")}]')"

scan_write_report scan-structure-hygiene "$opportunities" "$insufficient" "$cooling" "$deferred"
scan_finish "$opportunities"
