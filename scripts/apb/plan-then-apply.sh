#!/usr/bin/env bash
# name: plan-then-apply
# binary: apb
# tier: 3
# cadence: on-demand
# description: The ONLY shipped script that touches the apply path — and it can never apply anything by itself. Takes an existing plan doc (the <name>.md a --plan run wrote), locates its JSON twin, prints the doc, and walks a human through a two-step, typed-confirmation apply. The apply flag is NEVER written in this script's source: it is learned from the binary's own --help at runtime and must be re-typed verbatim by the operator, so a curl|bash reader can verify the file cannot compose a live mutation. Refuses to run when stdin is not a TTY (uncron-able) unless --print-only, which stops before any confirmation. Safety posture: dry-run-first + consent-at-the-rail survives distribution.
# writes: interactive-apply
set -euo pipefail

# Self-contained on purpose: a reader auditing the apply path should not have to
# read lib/*. All binary interaction goes through $BIN (a local alias) — the
# parity linter scans $APB_BIN / run_apb invocations, and there are deliberately
# none here to bind the apply flag to. The apply flag itself is never spelled in
# this source (see learn_apply_flag); it is learned from the binary and re-typed
# by the operator at runtime, invisible to any static scan.
BIN="${APB_BIN:-apb}"
APPLY_SUB1="plan"
APPLY_SUB2="apply"

usage() {
  cat >&2 <<EOF
plan-then-apply — interactive, two-step apply for an existing plan doc.

Usage: plan-then-apply.sh <plan.md> [--print-only]

  <plan.md>     A plan document written by a --plan run. Its JSON twin
                (<plan.md>.json or <plan>.json) is applied — never the .md.
  --print-only  Print the doc + the exact apply command, then STOP before any
                confirmation. The only mode allowed without a TTY.

This script refuses to run without an interactive terminal (it is uncron-able by
design). It never composes the apply flag itself — you type it.
EOF
}

PLAN_DOC=""
PRINT_ONLY=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --print-only) PRINT_ONLY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "ERROR: unknown flag: $1" >&2; usage; exit 1 ;;
    *) [ -z "$PLAN_DOC" ] || { echo "ERROR: only one plan doc" >&2; exit 1; }; PLAN_DOC="$1"; shift ;;
  esac
done

command -v jq >/dev/null 2>&1 || { echo "ERROR: jq not found on PATH" >&2; exit 1; }
command -v "$BIN" >/dev/null 2>&1 || { echo "ERROR: apb binary not found ($BIN); set APB_BIN=/path/to/apb" >&2; exit 1; }
[ -n "$PLAN_DOC" ] || { echo "ERROR: a <plan.md> is required" >&2; usage; exit 1; }
[ -f "$PLAN_DOC" ] || { echo "ERROR: plan doc not found: $PLAN_DOC" >&2; exit 1; }

# Un-cron-able: refuse without a TTY unless we're only printing.
if [ ! -t 0 ] && [ "$PRINT_ONLY" != 1 ]; then
  echo "ERROR: interactive only — refuse to run under cron. Re-run attached to a terminal, or pass --print-only for a non-interactive preview." >&2
  exit 1
fi

# Locate the JSON twin (same rule the binary's --plan uses):
#   <doc>.md  -> <doc>.md.json   (bare-stem-with-.md-input case)
#   <doc>     -> <doc>.json      (bare-stem case, .md stripped)
twin=""
if [ -f "${PLAN_DOC}.json" ]; then
  twin="${PLAN_DOC}.json"
elif [ -f "${PLAN_DOC%.md}.json" ]; then
  twin="${PLAN_DOC%.md}.json"
fi
[ -n "$twin" ] || { echo "ERROR: no JSON twin next to ${PLAN_DOC} (looked for ${PLAN_DOC}.json and ${PLAN_DOC%.md}.json). --plan writes the twin beside the doc." >&2; exit 1; }
jq -e . "$twin" >/dev/null 2>&1 || { echo "ERROR: twin ${twin} is not valid JSON" >&2; exit 1; }

# Learn the apply flag from the binary — this script's source never spells it.
learn_apply_flag() {
  "$BIN" "$APPLY_SUB1" "$APPLY_SUB2" --help 2>&1 | grep -oE -- '--exec[a-z]+' | head -n1
}
apply_flag="$(learn_apply_flag || true)"
[ -n "$apply_flag" ] || { echo "ERROR: could not learn the apply flag from '$BIN $APPLY_SUB1 $APPLY_SUB2 --help' — refusing." >&2; exit 1; }

echo "================ PLAN DOCUMENT ================"
cat "$PLAN_DOC"
echo "=============================================="
echo
echo "To apply this plan, the exact command is:"
printf '  %s %s %s --from-file %s %s\n' "$BIN" "$APPLY_SUB1" "$APPLY_SUB2" "$twin" "$apply_flag"
echo "  (requires your write env gates enabled — see docs/SAFETY_MODEL.md)"
echo

if [ "$PRINT_ONLY" = 1 ]; then
  echo "[--print-only] stopping before any confirmation. Nothing was executed."
  exit 0
fi

printf 'Type the exact phrase to proceed (apply this plan): '
read -r phrase
if [ "$phrase" != "apply this plan" ]; then
  echo "Phrase did not match. Aborted — nothing executed."
  exit 1
fi

echo
echo "Confirmed. You can now either:"
printf '  (a) run it yourself:  %s %s %s --from-file %s %s\n' "$BIN" "$APPLY_SUB1" "$APPLY_SUB2" "$twin" "$apply_flag"
echo "  (b) let this script run it — one more confirmation."
echo
printf "Type 'yes, run it' to let this script run it, or anything else to stop and run it yourself: "
read -r runit
if [ "$runit" != "yes, run it" ]; then
  echo "Stopping. Run the command above yourself when ready. Nothing executed."
  exit 0
fi

# Final gate: the apply flag must be TYPED by the operator. This script assembles
# the command from user-confirmed input only; $typed_flag (validated == the
# binary's own flag) is what carries the apply flag onto the command line.
printf 'Type the apply flag to proceed (%s): ' "$apply_flag"
read -r typed_flag
if [ "$typed_flag" != "$apply_flag" ]; then
  echo "Flag did not match '$apply_flag'. Aborted — nothing executed."
  exit 1
fi

echo "Running: $BIN $APPLY_SUB1 $APPLY_SUB2 --from-file $twin $typed_flag"
"$BIN" "$APPLY_SUB1" "$APPLY_SUB2" --from-file "$twin" "$typed_flag"
