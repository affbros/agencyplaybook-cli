#!/usr/bin/env bash
# name: check-sufficiency
# binary: apb-gads
# tier: 2
# cadence: on-demand
# description: Standalone on-demand check of the shared data-sufficiency gate (lib/sufficiency.sh) for an arbitrary entity, outside the context of a full Tier-2 scan run. Useful for spot-checking "does this one campaign/ad-group/keyword have enough data yet?" without running a whole scan. Takes --customer (for parity with the other scripts' flag surface; not otherwise used — sufficiency is a pure local computation against thresholds.conf, no API call) and a bespoke --entity-json carrying at minimum {conversions, spend_usd, impressions}. Prints the sufficient() verdict verbatim to stdout.
# writes: never
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HERE}/lib/common.sh"
# shellcheck source=lib/sufficiency.sh
source "${HERE}/lib/sufficiency.sh"

WATCH_NAME="check-sufficiency"

check_sufficiency_usage() {
  cat >&2 <<EOF
check-sufficiency — on-demand spot-check of the shared data-sufficiency gate.
Does not run any apb-gads call; pure local computation against thresholds.conf.

Usage: check-sufficiency.sh --customer <id> --entity-json '<json>' [--out-dir <dir>] [--quiet]

  --customer     Google Ads customer id (accepted for flag-surface parity; not
                 otherwise used by this script).
  --entity-json  JSON object carrying at minimum {conversions, spend_usd,
                 impressions}; extra fields are ignored.
  --out-dir      Accepted for parity with parse_common_args; unused (writes: never).
  --quiet        Suppress progress on stderr.

Exit: 0 verdict=pass · 10 verdict=fail (insufficient data) · 1 parse/tool error.
EOF
}

# parse_common_args (lib/common.sh) doesn't know --entity-json, so pull it
# (and its value) out of "$@" first and hand the remainder to the shared
# parser — this is the one flag this script adds on top of the common set.
ENTITY_JSON=""
_rest=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --entity-json) ENTITY_JSON="${2:?--entity-json needs a value}"; shift 2 ;;
    --entity-json=*) ENTITY_JSON="${1#*=}"; shift ;;
    -h|--help) check_sufficiency_usage; exit 0 ;;
    *) _rest+=("$1"); shift ;;
  esac
done

parse_common_args "${_rest[@]}"

if [ -z "$ENTITY_JSON" ]; then
  echo "ERROR: --entity-json '<json>' required" >&2
  check_sufficiency_usage
  exit 1
fi

if ! printf '%s' "$ENTITY_JSON" | jq -e . >/dev/null 2>&1; then
  echo "ERROR: --entity-json is not valid JSON" >&2
  exit 1
fi

set +e
verdict="$(sufficient "$ENTITY_JSON")"
rc=$?
set -e
if [ "$rc" -ne 0 ]; then
  echo "ERROR: sufficiency check failed (thresholds.conf load error)" >&2
  exit 1
fi

printf '%s\n' "$verdict"
if [ "$verdict" = "pass" ]; then
  exit 0
else
  exit 10
fi
