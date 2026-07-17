#!/usr/bin/env bash
# name: check-sufficiency
# binary: apb
# tier: 2
# cadence: on-demand
# description: Standalone user-facing gate — "does this entity have enough data to judge?" Wraps lib/sufficiency.sh's sufficient() so an operator (or a script) can ask the same question the Tier-2 opportunity scans ask internally, without running a full scan. Takes a JSON blob describing the entity's conversions/spend/impressions over the lookback and prints the pass/fail verdict verbatim, including the "keep collecting (X of Y conversions over Zd)" wording used everywhere else in this library.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"
# shellcheck source=lib/sufficiency.sh
source "${HERE}/lib/sufficiency.sh"

WATCH_NAME="check-sufficiency"
ENTITY_JSON=""

check_sufficiency_usage() {
  cat >&2 <<EOF
check-sufficiency — "does this entity have enough data to judge?" Standalone,
read-only. Prints the sufficient() verdict from lib/sufficiency.sh verbatim.

Usage: check-sufficiency.sh --account <act_id> --entity-json '<json>'

  --account      Ad account (act_XXXX). Defaults to \$APB_WATCH_ACCOUNT. Echoed
                 back for context only — this script makes no apb calls.
  --entity-json  Required. JSON object carrying at least {conversions,
                 spend_usd, impressions} for the entity being judged.
  --out-dir      Unused (accepted for flag-compatibility with the other
                 scripts' common.sh parser).
  --quiet        Suppress progress on stderr.

Exit: 0 sufficient (pass) · 10 insufficient (fail) · 1 tool/arg error.
EOF
}

# --entity-json isn't known to lib/common.sh's parse_common_args — pull it out
# of "$@" first, then hand the rest to the shared parser so --account/--out-dir/
# --quiet keep working exactly like every other script in this library.
_args=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --entity-json) ENTITY_JSON="${2:?--entity-json needs a value}"; shift 2 ;;
    --entity-json=*) ENTITY_JSON="${1#*=}"; shift ;;
    -h|--help) check_sufficiency_usage; exit 0 ;;
    *) _args+=("$1"); shift ;;
  esac
done

parse_common_args "${_args[@]}"

[ -n "$ENTITY_JSON" ] || { echo "ERROR: --entity-json '<json>' required" >&2; check_sufficiency_usage; exit 1; }
printf '%s' "$ENTITY_JSON" | jq -e . >/dev/null 2>&1 || { echo "ERROR: --entity-json is not valid JSON" >&2; exit 1; }

verdict="$(sufficient "$ENTITY_JSON")" || { echo "ERROR: sufficiency check failed (see above)" >&2; exit 1; }
printf '%s\n' "$verdict"

if [ "$verdict" = "pass" ]; then
  exit 0
else
  exit 10
fi
