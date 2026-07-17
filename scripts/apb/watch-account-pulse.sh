#!/usr/bin/env bash
# name: watch-account-pulse
# binary: apb
# tier: 1
# cadence: daily
# description: Daily pulse on account delivery and spend. Pulls the account-level daily insight series over the lookback and flags a latest-day spend anomaly versus the trailing-day average (a spike or collapse beyond the tolerance), plus a zero-delivery day where the account spent nothing while the trailing window was live. Purely observational — it reads report insights and thresholds the JSON; it never proposes or applies a change, and any finding is flagged for weekly review.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"

WATCH_NAME="watch-account-pulse"
LOOKBACK=7                         # daily pulse: short trailing window
: "${PULSE_DEV:=0.5}"              # flag |today-mean|/mean beyond this (50%)
parse_common_args "$@"

series="$(run_apb report insights --level account --days "$LOOKBACK" --time-increment 1)"
status_write account-pulse "$series"

# Normalise to a spend array (tolerant of field naming / envelope).
spends="$(printf '%s' "$series" | jq -c '
  (if type=="object" and has("data") then .data else . end)
  | (if type=="array" then . else [.] end)
  | map((.spend // .spend_usd // 0) | tonumber? // 0)' 2>/dev/null || echo '[]')"

n="$(printf '%s' "$spends" | jq 'length')"
if [ "$n" -lt 2 ]; then
  _log "  only ${n} day(s) of data — not enough to judge a trend."
  finish
fi

read -r last mean <<<"$(printf '%s' "$spends" | jq -r '
  . as $s | ($s[-1]) as $last
  | ($s[:-1] | add / (length)) as $mean
  | "\($last) \($mean)"')"

# Zero-delivery: nothing spent today while the trailing window was live.
if awk -v l="$last" -v m="$mean" 'BEGIN{exit !(l+0==0 && m+0>0)}'; then
  attn "zero-delivery: account spent \$0 on the latest day while the trailing ${LOOKBACK}d avg was \$$(printf '%.2f' "$mean") — check delivery."
elif awk -v l="$last" -v m="$mean" -v d="$PULSE_DEV" 'BEGIN{ if(m+0<=0) exit 1; r=(l-m)/m; if(r<0)r=-r; exit !(r>d) }'; then
  dir="$(awk -v l="$last" -v m="$mean" 'BEGIN{print (l+0>m+0)?"spike":"drop"}')"
  attn "spend ${dir}: latest day \$$(printf '%.2f' "$last") vs trailing ${LOOKBACK}d avg \$$(printf '%.2f' "$mean") (>${PULSE_DEV} deviation) — for weekly review."
fi

finish
