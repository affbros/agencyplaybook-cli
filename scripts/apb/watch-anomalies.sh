#!/usr/bin/env bash
# name: watch-anomalies
# binary: apb
# tier: 1
# cadence: daily
# description: Statistical anomaly watch over the account's daily spend series. Pulls the account-level daily insight series over the lookback and computes a z-score per day against the window mean and standard deviation in jq, flagging any day (and especially the latest) whose spend deviates beyond the z threshold. This is the numeric complement to watch-account-pulse's simple average test. It reports outlier days for weekly review and makes no changes.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"

WATCH_NAME="watch-anomalies"
LOOKBACK=30
: "${Z_THRESHOLD:=2.5}"           # |z| beyond this = outlier day
parse_common_args "$@"

series="$(run_apb report insights --level account --days "$LOOKBACK" --time-increment 1)"
status_write anomalies "$series"

# Build [{date, spend}], compute population mean/std, emit outlier days as z-scores.
outliers="$(printf '%s' "$series" | jq -r --argjson z "$Z_THRESHOLD" '
  (if type=="object" and has("data") then .data else . end)
  | (if type=="array" then . else [.] end)
  | map({ date: (.date_start? // .date? // "?"),
          spend: ((.spend // .spend_usd // 0) | tonumber? // 0) }) as $rows
  | ($rows | length) as $n
  | if $n < 3 then empty
    else
      ($rows | map(.spend) | add / $n) as $mean
      | ($rows | map((.spend - $mean) | . * .) | add / $n | sqrt) as $std
      | if $std == 0 then empty
        else $rows[]
          | ((.spend - $mean) / $std) as $zc
          | select(($zc | if . < 0 then -. else . end) > $z)
          | "\(.date)\tz=\(($zc*100|round)/100)\tspend=\(.spend)"
        end
    end' 2>/dev/null || true)"

if [ -n "$outliers" ]; then
  count="$(printf '%s\n' "$outliers" | grep -c .)"
  attn "${count} daily-spend outlier(s) beyond z=${Z_THRESHOLD} — for weekly review:"
  printf '%s\n' "$outliers" | while IFS=$'\t' read -r d zc sp; do
    printf '         - %s: %s (%s)\n' "$d" "$zc" "$sp"
  done
fi

finish
