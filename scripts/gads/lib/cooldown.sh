# cooldown.sh — recent-change lookup for the apb-gads (Google Ads) batch scripts.
#
# `cooldown_check <entity-id>` answers "was this entity changed inside the last
# COOLDOWN_DAYS (default 7)?" so Tier 2/3 change scripts can honour the
# methodical-change discipline (don't touch something that was just touched).
#
# Google Ads exposes change history via the `change_event` resource. apb-gads's
# `changes` command group is the ActionPlan->Changeset apply pipeline (not a
# history read), so this library queries `change_event` through `gaql query`
# instead. It is deliberately BEST-EFFORT: change_event is finicky (30-day cap,
# resource filters, mandatory LIMIT) and per-account access varies, so any failure
# or empty result yields "unknown", and callers treat "unknown"/"active" alike as
# safe-to-watch. Tier 1 is watch-only regardless.
#
# writes: never. The only CLI call is a read-only `gaql query`.

: "${COOLDOWN_DAYS:=7}"

# cooldown_check <entity-id> -> "cooling" | "active" | "unknown"
cooldown_check() {
  local entity_id="${1:-}" days="${COOLDOWN_DAYS:-7}" start q out hit
  [ -n "$entity_id" ] || { echo "unknown"; return 0; }

  start="$(date -d "-${days} days" '+%Y-%m-%d %H:%M:%S' 2>/dev/null \
        || date -v-"${days}"d '+%Y-%m-%d %H:%M:%S' 2>/dev/null || true)"
  [ -n "$start" ] || { echo "unknown"; return 0; }

  q="SELECT change_event.change_date_time, change_event.change_resource_name FROM change_event WHERE change_event.change_date_time >= '${start}' ORDER BY change_event.change_date_time DESC LIMIT 500"

  # Best-effort: never abort the caller. Direct (non-loud) call; failure -> unknown.
  # shellcheck disable=SC2086
  out="$("${APB_GADS_BIN:-apb-gads}" ${GADS_EXTRA_ARGS:-} --customer "${CUSTOMER:-}" gaql query --query "$q" 2>/dev/null || true)"
  [ -n "$out" ] || { echo "unknown"; return 0; }

  hit="$(printf '%s' "$out" | jq -r --arg e "$entity_id" \
    '[.. | strings | select(test($e))] | length' 2>/dev/null || echo 0)"
  if [ "${hit:-0}" -gt 0 ] 2>/dev/null; then
    echo "cooling"
  else
    echo "active"
  fi
}
