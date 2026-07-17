# sufficiency.sh — the data-sufficiency gate shared by the batch scripts.
#
# `sufficient '<json>'` takes a JSON object carrying {conversions, spend_usd,
# impressions} and returns "pass" or "fail — insufficient data — keep collecting
# (X of Y conversions over Zd)" against the thresholds in ../thresholds.conf.
#
# Tier 1 watchdogs report raw and do NOT gate on this (per the operating
# doctrine: watchdogs observe, they never propose). The gate lives here so the
# Tier 2/3 opportunity/change scripts (and a future `check-sufficiency`) share one
# definition of "enough data" with the binary's own compiled constants.
#
# writes: never. Pure local computation (jq + awk); no CLI calls.
#
# S5b: suff_load_thresholds() also exposes CHANGE_BUDGET (thresholds.conf key
# `change_budget`, default 3) — the max opportunities a Tier-2 scan proposes
# per run (doctrine: "max K proposed changes per run", largest-impact first;
# the rest are reported under `deferred_next_review`).

_SUFF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${THRESHOLDS_FILE:=${_SUFF_DIR}/../thresholds.conf}"

_suff_get() { grep -E "^$1=" "$2" 2>/dev/null | head -1 | cut -d= -f2 | tr -d '[:space:]'; }

# Load + validate thresholds.conf (schema-versioned from day one).
suff_load_thresholds() {
  local f="$THRESHOLDS_FILE" schema
  [ -f "$f" ] || { echo "sufficiency: thresholds.conf not found at $f" >&2; return 2; }
  schema="$(_suff_get thresholds_schema "$f")"
  [ "$schema" = "1" ] || { echo "sufficiency: unsupported thresholds_schema='${schema}' (expected 1)" >&2; return 2; }
  MIN_CONVERSIONS="$(_suff_get min_conversions "$f")"
  MIN_SPEND_USD="$(_suff_get min_spend_usd "$f")"
  MIN_IMPRESSIONS="$(_suff_get min_impressions "$f")"
  MIN_AUDIENCE_SIZE="$(_suff_get min_audience_size "$f")"
  LOOKBACK_DAYS_DEFAULT="$(_suff_get lookback_days_default "$f")"
  CHANGE_BUDGET="$(_suff_get change_budget "$f")"
  : "${MIN_CONVERSIONS:=0}" "${MIN_SPEND_USD:=0}" "${MIN_IMPRESSIONS:=0}"
  : "${MIN_AUDIENCE_SIZE:=0}" "${LOOKBACK_DAYS_DEFAULT:=30}" "${CHANGE_BUDGET:=3}"
}

# sufficient '<entity-json>' -> "pass" | "fail — insufficient data — keep collecting (...)"
sufficient() {
  local json="$1" conv spend impr verdict
  suff_load_thresholds || return 2
  conv="$(printf '%s' "$json" | jq -r '(.conversions // 0) | tonumber? // 0' 2>/dev/null || echo 0)"
  spend="$(printf '%s' "$json" | jq -r '(.spend_usd // 0) | tonumber? // 0' 2>/dev/null || echo 0)"
  impr="$(printf '%s' "$json" | jq -r '(.impressions // 0) | tonumber? // 0' 2>/dev/null || echo 0)"
  verdict="$(awk -v c="$conv" -v s="$spend" -v i="$impr" \
    -v mc="$MIN_CONVERSIONS" -v ms="$MIN_SPEND_USD" -v mi="$MIN_IMPRESSIONS" \
    'BEGIN { if (c+0 >= mc+0 && s+0 >= ms+0 && i+0 >= mi+0) print "pass"; else print "fail" }')"
  if [ "$verdict" = "pass" ]; then
    echo "pass"
  else
    printf 'fail — insufficient data — keep collecting (%s of %s conversions over %sd)\n' \
      "$conv" "$MIN_CONVERSIONS" "$LOOKBACK_DAYS_DEFAULT"
  fi
}

# sufficient_cs <conversions> <spend_usd> -> "pass" | "fail — ...". The
# conversions+spend-only gate the Tier-3 reviews use: budget-rebalance and the
# strategic review judge account/campaign totals that carry conversions and spend
# but not impressions, so forcing them through sufficient() (which also floors on
# impressions) would always fail. Gates against MIN_CONVERSIONS + MIN_SPEND_USD.
sufficient_cs() {
  local conv="$1" spend="$2" verdict
  suff_load_thresholds || return 2
  verdict="$(awk -v c="$conv" -v s="$spend" -v mc="$MIN_CONVERSIONS" -v ms="$MIN_SPEND_USD" \
    'BEGIN { print (c+0 >= mc+0 && s+0 >= ms+0) ? "pass" : "fail" }')"
  if [ "$verdict" = "pass" ]; then
    echo "pass"
  else
    printf 'fail — insufficient data — keep collecting (%s of %s conversions, $%s of $%s spend over %sd)\n' \
      "$conv" "$MIN_CONVERSIONS" "$spend" "$MIN_SPEND_USD" "$LOOKBACK_DAYS_DEFAULT"
  fi
}

# sufficient_audience_size <size> -> "pass" | "fail — insufficient data — keep
# collecting (...)". Separate from sufficient() because audience-focused scans
# (user-list volumes, PMAX signal coverage) judge signal volume, not ad
# performance — forcing them through the conversions/spend/impressions gate
# above would always fail (audiences carry no conversions). Gates against
# MIN_AUDIENCE_SIZE.
sufficient_audience_size() {
  local size="$1" verdict
  suff_load_thresholds || return 2
  verdict="$(awk -v s="$size" -v m="$MIN_AUDIENCE_SIZE" 'BEGIN { print (s+0 >= m+0) ? "pass" : "fail" }')"
  if [ "$verdict" = "pass" ]; then
    echo "pass"
  else
    printf 'fail — insufficient data — keep collecting (audience size %s below floor %s)\n' \
      "$size" "$MIN_AUDIENCE_SIZE"
  fi
}
