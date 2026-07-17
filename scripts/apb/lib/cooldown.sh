# cooldown.sh — recent-change lookup for the apb (Meta) batch scripts.
#
# `cooldown_check <entity-id>` answers "was this entity changed inside the last
# COOLDOWN_DAYS (default 7)?" so Tier 2/3 change scripts can honour the
# methodical-change discipline (don't touch something that was just touched).
#
# apb NO-DATA FALLBACK: apb exposes no per-entity change-history read as a
# command — `sync` produces point-in-time snapshots, not a change log, and no
# other read returns an edit timeline. So cooldown_check returns "unknown", and
# callers treat "unknown" as "active" (safe: Tier 1 is watch-only regardless, and
# Tier 2/3 fall back to their sufficiency + change-budget gates). If apb ever
# ships a change-history read, swap the body here — the contract stays the same.
#
# writes: never. This library makes no CLI calls today.

: "${COOLDOWN_DAYS:=7}"

# cooldown_check <entity-id> -> "cooling" | "active" | "unknown"
cooldown_check() {
  local entity_id="${1:-}"
  [ -n "$entity_id" ] || { echo "unknown"; return 0; }
  # No change-history surface on apb (see header) -> conservative "unknown".
  echo "unknown"
}
