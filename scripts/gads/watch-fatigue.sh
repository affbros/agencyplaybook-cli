#!/usr/bin/env bash
# name: watch-fatigue
# binary: apb-gads
# tier: 1
# cadence: daily
# description: Watches creative decay by running the rsa-quality-audit playbook, which scores every live responsive search ad on copy quality and pairs it with ad_strength and approval status, emitting refresh candidates. This watchdog thresholds that output to flag RSAs with POOR/LOW ad strength or quality decay — the Google equivalent of creative fatigue. The scoring is the binary's; this script reports the flagged ads for weekly creative-refresh review. Read-only — it never edits or swaps an asset.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"

WATCH_NAME="watch-fatigue"
LOOKBACK=30
parse_common_args "$@"

rsa="$(run_gads playbook rsa-quality-audit --lookback-days "$LOOKBACK")"
status_write fatigue "$rsa"

flagged="$(printf '%s' "$rsa" | jq -c '
  [ .. | objects
    | select(
        ((((.ad_strength? // .strength? // "") | tostring) | ascii_upcase) | test("POOR|LOW|AVERAGE"))
        or ((((.quality? // .quality_label? // .verdict? // "") | tostring) | ascii_downcase) | test("decay|poor|weak|refresh"))
        or (.refresh_candidate? == true)
      )
    | { ad: (.name? // .ad? // .ad_id? // .id? // "rsa"),
        signal: (.ad_strength? // .strength? // .quality? // .verdict? // "refresh-candidate") }
  ] | unique' 2>/dev/null || echo '[]')"

count="$(printf '%s' "$flagged" | jq 'length' 2>/dev/null || echo 0)"
if [ "${count:-0}" -gt 0 ]; then
  attn "${count} RSA(s) with weak/declining ad strength — for weekly refresh review:"
  printf '%s' "$flagged" | jq -r '.[] | "         - \(.ad): \(.signal)"'
fi

finish
