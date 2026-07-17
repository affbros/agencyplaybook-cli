#!/usr/bin/env bash
# name: watch-anomalies
# binary: apb-gads
# tier: 1
# cadence: daily
# description: Statistical anomaly watch driven by the anomaly-detection playbook, which computes week-over-week spend/clicks/conversion change alerts and flags newly-active and newly-dark campaigns. This watchdog thresholds that output and surfaces every anomaly the binary raises for weekly review. The change-detection math lives in the playbook (the numeric complement to watch-account-pulse). Strictly read-only — it makes no changes.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"

WATCH_NAME="watch-anomalies"
LOOKBACK=14
parse_common_args "$@"

anom="$(run_gads playbook anomaly-detection --lookback-days "$LOOKBACK")"
status_write anomalies "$anom"

flagged="$(printf '%s' "$anom" | jq -c '
  [ .. | objects
    | select(
        ((((.alert? // .anomaly? // .status? // .severity? // .change? // "") | tostring) | ascii_downcase)
          | test("alert|anomal|spike|drop|newly|dark|surge|collapse|high|critical"))
      )
    | { entity: (.name? // .campaign_name? // .campaign? // .id? // "entity"),
        signal: (.alert? // .anomaly? // .status? // .severity? // .change? // "anomaly") }
  ] | unique' 2>/dev/null || echo '[]')"

count="$(printf '%s' "$flagged" | jq 'length' 2>/dev/null || echo 0)"
if [ "${count:-0}" -gt 0 ]; then
  attn "${count} week-over-week anomaly(ies) — for weekly review:"
  printf '%s' "$flagged" | jq -r '.[] | "         - \(.entity): \(.signal)"'
fi

finish
