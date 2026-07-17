# common.sh — shared runtime for the apb-gads (Google Ads) Tier-1 watchdogs.
#
# Sourced, never executed. Provides: arg parsing, binary discovery, the apb-gads
# invocation wrapper (apb-gads is JSON-always — no --json needed — so the wrapper
# only injects --customer and any GADS_EXTRA_ARGS, and fails loud on a non-zero
# binary exit), dated status-file I/O under ./gads-watch/<customer>/<date>/, a
# yesterday-diff helper, and the 0 (quiet) / 10 (attention) / 1 (tool error)
# exit-code convention.
#
# writes: never — every apb-gads call this file makes is a read; it never passes
# the write/execute rail (apb-gads mutations are dry-run without it; none is used).
#
# Portability: bash 4+, jq, and the apb-gads binary on PATH (or APB_GADS_BIN).
#
# GADS_EXTRA_ARGS: extra global args prepended to every invocation (word-split),
# e.g. GADS_EXTRA_ARGS="--config /path/to/google-ads.yaml" for BYO credentials.

# The sourcing watchdog owns `set -euo pipefail`.

APB_GADS_BIN="${APB_GADS_BIN:-apb-gads}"

: "${CUSTOMER:=${GADS_WATCH_CUSTOMER:-}}"
: "${LOOKBACK:=30}"
: "${OUT_DIR:=}"
: "${QUIET:=0}"
: "${GADS_EXTRA_ARGS:=}"
: "${WATCH_NAME:=watchdog}"
_ATTN_COUNT=0

common_usage() {
  cat >&2 <<EOF
${WATCH_NAME} — read-only Google Ads (apb-gads) watchdog. Flags findings "for
weekly review"; it never proposes or applies a change.

Usage: ${WATCH_NAME}.sh --customer <id> [--lookback <days>] [--out-dir <dir>] [--quiet]

  --customer  Google Ads customer id, no dashes. Defaults to \$GADS_WATCH_CUSTOMER.
  --lookback  Lookback window in days (script default ${LOOKBACK}); maps to --lookback-days.
  --out-dir   Status-file directory (default ./gads-watch/<customer>/<YYYY-MM-DD>/).
  --quiet     Suppress progress on stderr.

Env: APB_GADS_BIN=/path/to/apb-gads overrides binary discovery.
     GADS_EXTRA_ARGS="--config /path/to/google-ads.yaml" for BYO credentials.
Exit: 0 quiet · 10 attention items found · 1 tool/auth error.
EOF
}

parse_common_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --customer) CUSTOMER="${2:?--customer needs a value}"; shift 2 ;;
      --customer=*) CUSTOMER="${1#*=}"; shift ;;
      --lookback) LOOKBACK="${2:?--lookback needs a value}"; shift 2 ;;
      --lookback=*) LOOKBACK="${1#*=}"; shift ;;
      --out-dir) OUT_DIR="${2:?--out-dir needs a value}"; shift 2 ;;
      --out-dir=*) OUT_DIR="${1#*=}"; shift ;;
      --quiet) QUIET=1; shift ;;
      -h|--help) common_usage; exit 0 ;;
      *) echo "ERROR: unknown argument: $1" >&2; common_usage; exit 1 ;;
    esac
  done

  command -v jq >/dev/null 2>&1 || { echo "ERROR: jq not found on PATH" >&2; exit 1; }
  command -v "$APB_GADS_BIN" >/dev/null 2>&1 || { echo "ERROR: apb-gads binary not found ($APB_GADS_BIN); set APB_GADS_BIN=/path/to/apb-gads" >&2; exit 1; }
  [ -n "$CUSTOMER" ] || { echo "ERROR: --customer <id> required (or env GADS_WATCH_CUSTOMER)" >&2; exit 1; }

  [ -n "$OUT_DIR" ] || OUT_DIR="./gads-watch/${CUSTOMER}/$(date +%F)"
  mkdir -p "$OUT_DIR"
  _log "watchdog=${WATCH_NAME} customer=${CUSTOMER} lookback=${LOOKBACK}d out=${OUT_DIR}"
}

_log() { [ "$QUIET" = "1" ] || echo "$*" >&2; }

# run_gads <apb-gads args...> — prepends GADS_EXTRA_ARGS + --customer, echoes
# progress to stderr, returns stdout (JSON), exits 1 (tool error) on non-zero.
run_gads() {
  _log "  -> apb-gads $*"
  local out rc
  set +e
  # shellcheck disable=SC2086  # GADS_EXTRA_ARGS is intentionally word-split.
  out="$("$APB_GADS_BIN" ${GADS_EXTRA_ARGS} --customer "$CUSTOMER" "$@" 2>/dev/null)"
  rc=$?
  set -e
  if [ "$rc" -ne 0 ]; then
    echo "ERROR: apb-gads $* exited ${rc} — tool/auth error" >&2
    exit 1
  fi
  printf '%s' "$out"
}

status_write() {
  local name="$1" json="$2"
  mkdir -p "$OUT_DIR"
  printf '%s' "$json" >"${OUT_DIR}/${name}.json"
  _log "  wrote ${OUT_DIR}/${name}.json"
}

status_yesterday() {
  local name="$1" yday f
  yday="$(date -d 'yesterday' +%F 2>/dev/null || date -v-1d +%F 2>/dev/null || true)"
  [ -n "$yday" ] || return 0
  f="./gads-watch/${CUSTOMER}/${yday}/${name}.json"
  [ -f "$f" ] && cat "$f" || return 0
}

attn() {
  printf '[ATTN] %s\n' "$*"
  _ATTN_COUNT=$((_ATTN_COUNT + 1))
}

finish() {
  if [ "$_ATTN_COUNT" -gt 0 ]; then
    _log "-> ${_ATTN_COUNT} item(s) flagged for weekly review."
    exit 10
  fi
  _log "-> quiet: nothing to flag."
  exit 0
}

# --- Tier-2 opportunity-scan extensions (S5b) --------------------------------
# plans_dir — ensure/return the dated out-dir's plans/ subdirectory, where
# Track-A plan docs rendered via the binary's own --plan land.
plans_dir() {
  mkdir -p "${OUT_DIR}/plans"
  printf '%s' "${OUT_DIR}/plans"
}

# scan_write_report <scan-name> <opportunities-json-array> <insufficient-json-array> \
#                    <deferred-cooldown-json-array> <deferred-next-review-json-array>
# Writes <OUT_DIR>/<scan-name>.json (full structured report) and a short
# human <scan-name>.md summary. Every array element is expected to carry at
# least {entity_type, entity_id, entity_name, metric_summary, impact_hint};
# opportunities additionally carry {sufficiency, cooldown} and either
# {plan_doc} or {suggested_command}.
scan_write_report() {
  local name="$1" opp="$2" insuff="$3" cool="$4" defer="$5"
  mkdir -p "$OUT_DIR"
  jq -n --argjson opportunities "$opp" --argjson insufficient_data "$insuff" \
        --argjson deferred_cooldown "$cool" --argjson deferred_next_review "$defer" \
        '{opportunities: $opportunities, insufficient_data: $insufficient_data,
          deferred_cooldown: $deferred_cooldown, deferred_next_review: $deferred_next_review}' \
    >"${OUT_DIR}/${name}.json"
  {
    printf '# %s — %s\n\n' "$name" "$(date +%F)"
    printf '## Opportunities (%s)\n\n' "$(printf '%s' "$opp" | jq 'length')"
    printf '%s' "$opp" | jq -r '.[] |
      "- **\(.entity_type)** \(.entity_name // .entity_id) — \(.metric_summary) — \(.impact_hint)\n" +
      "  sufficiency: \(.sufficiency) · cooldown: \(.cooldown)" +
      (if .plan_doc then "\n  plan: \(.plan_doc)"
       elif .suggested_command then "\n  suggested: `\(.suggested_command)`"
       else "" end)'
    printf '\n## Insufficient data (%s)\n\n' "$(printf '%s' "$insuff" | jq 'length')"
    printf '%s' "$insuff" | jq -r '.[] | "- \(.entity_type) \(.entity_name // .entity_id): \(.sufficiency)"'
    printf '\n## Deferred — cooldown (%s)\n\n' "$(printf '%s' "$cool" | jq 'length')"
    printf '%s' "$cool" | jq -r '.[] | "- \(.entity_type) \(.entity_name // .entity_id) — cooling, skipped this run"'
    printf '\n## Deferred — next review, over change budget (%s)\n\n' "$(printf '%s' "$defer" | jq 'length')"
    printf '%s' "$defer" | jq -r '.[] | "- \(.entity_type) \(.entity_name // .entity_id) — \(.impact_hint)"'
  } >"${OUT_DIR}/${name}.md"
  _log "  wrote ${OUT_DIR}/${name}.json + ${name}.md"
}

# scan_gate_rank_cap <candidates-json-array>
# Runs every candidate ({entity_type, entity_id, entity_name, metric_summary,
# impact_hint, conversions, spend_usd, impressions, impact?}) through
# sufficient() (lib/sufficiency.sh) + cooldown_check() (lib/cooldown.sh), ranks
# survivors by their numeric `impact` field (falls back to spend_usd; largest
# first), caps at $CHANGE_BUDGET (loaded via suff_load_thresholds — call that
# before this), and emits one JSON object on stdout:
#   {opportunities, insufficient_data, deferred_cooldown, deferred_next_review}
# Callers must have already sourced lib/sufficiency.sh + lib/cooldown.sh.
scan_gate_rank_cap() {
  local candidates="$1" n i c eid suf cdv
  local opportunities="[]" insufficient="[]" cooling="[]"
  n="$(printf '%s' "$candidates" | jq 'length' 2>/dev/null || echo 0)"
  if [ "${n:-0}" -gt 0 ]; then
    for i in $(seq 0 $((n - 1))); do
      c="$(printf '%s' "$candidates" | jq -c ".[$i]")"
      eid="$(printf '%s' "$c" | jq -r '.entity_id // "unknown"')"
      suf="$(sufficient "$c")"
      if [ "$suf" != "pass" ]; then
        insufficient="$(jq -cn --argjson arr "$insufficient" --argjson c "$c" --arg s "$suf" \
          '$arr + [$c + {sufficiency: $s}]')"
        continue
      fi
      cdv="$(cooldown_check "$eid")"
      if [ "$cdv" = "cooling" ]; then
        cooling="$(jq -cn --argjson arr "$cooling" --argjson c "$c" \
          '$arr + [$c + {sufficiency: "pass", cooldown: "cooling"}]')"
        continue
      fi
      opportunities="$(jq -cn --argjson arr "$opportunities" --argjson c "$c" --arg cd "$cdv" \
        '$arr + [$c + {sufficiency: "pass", cooldown: $cd}]')"
    done
  fi
  local ranked capped deferred budget
  budget="${CHANGE_BUDGET:-3}"
  ranked="$(printf '%s' "$opportunities" | jq -c 'sort_by(-(.impact // .spend_usd // 0))')"
  capped="$(printf '%s' "$ranked" | jq -c --argjson k "$budget" '.[0:$k]')"
  deferred="$(printf '%s' "$ranked" | jq -c --argjson k "$budget" '.[$k:]')"
  jq -n --argjson opportunities "$capped" --argjson insufficient_data "$insufficient" \
        --argjson deferred_cooldown "$cooling" --argjson deferred_next_review "$deferred" \
        '{opportunities: $opportunities, insufficient_data: $insufficient_data,
          deferred_cooldown: $deferred_cooldown, deferred_next_review: $deferred_next_review}'
}

# scan_finish <opportunities-json-array> — exit 10 if any opportunity
# survived sufficiency+cooldown+change-budget gating, else 0.
scan_finish() {
  local n
  n="$(printf '%s' "$1" | jq 'length' 2>/dev/null || echo 0)"
  if [ "${n:-0}" -gt 0 ] 2>/dev/null; then
    _log "-> ${n} opportunity(ies) surfaced this run."
    exit 10
  fi
  _log "-> quiet: no opportunities surfaced."
  exit 0
}

# --- Tier-3 review + Family-4 audit-bundle extensions (S5c) -------------------
# subject / watch-root helpers — the ONE per-binary difference the review/audit
# helpers below build on. gads keys everything off --customer; the apb common.sh
# defines the same two functions off the ad account.
review_subject() { printf '%s' "$CUSTOMER"; }
watch_root()     { printf './gads-watch/%s' "$CUSTOMER"; }

# --- Family 4: generated audit-* bundles -------------------------------------
# The audit-*.sh scripts (generated by gen_scripts.py) are thin: a manifest, a
# --only pre-parse, parse_common_args, audit_begin, one literal per-playbook line
# per slug (so check_scripts_parity.py validates every command+flag), and
# audit_index. All the plumbing lives here so the generated files stay minimal.

# audit_selected <slug> — with $AUDIT_ONLY (comma list from --only) set, true only
# for a listed slug; empty ONLY selects everything. Used both in the generated
# per-slug `&&` guard and inside audit_record so a filtered-out slug never counts.
audit_selected() {
  local slug="$1"
  [ -n "${AUDIT_ONLY:-}" ] || return 0
  case ",${AUDIT_ONLY}," in *",${slug},"*) return 0 ;; *) return 1 ;; esac
}

# audit_begin <bundle> — declare the result trackers (global, so the generated
# per-slug lines can append) and retarget OUT_DIR at a timestamped results dir.
audit_begin() {
  local bundle="$1"
  AUDIT_OK=(); AUDIT_FAIL=()
  OUT_DIR="${OUT_DIR}/${bundle}-$(date +%Y%m%dT%H%M%S)"
  mkdir -p "$OUT_DIR"
  _log "audit bundle=${bundle} subject=$(review_subject) -> ${OUT_DIR}"
}

# audit_record <slug> <json> — persist one playbook's captured JSON (apb-gads is
# JSON-always, so the generated line captures stdout and hands it here) and tally
# ok/fail. Re-checks selection so an unselected slug is a silent skip.
audit_record() {
  local slug="$1" json="${2:-}"
  audit_selected "$slug" || return 0
  if [ -n "$json" ] && printf '%s' "$json" | jq -e . >/dev/null 2>&1; then
    printf '%s' "$json" >"${OUT_DIR}/${slug}.json"
    AUDIT_OK+=("$slug"); _log "  [ok]   ${slug}"
  else
    AUDIT_FAIL+=("$slug"); _log "  [fail] ${slug}"
  fi
}

# audit_index <bundle> — assemble index.md and exit (0 normally; 1 only if every
# selected playbook failed, i.e. a tool/auth problem, not a thin account).
audit_index() {
  local bundle="$1" out="${OUT_DIR}/index.md" s
  {
    printf '# %s — %s — %s\n\n' "$bundle" "$(review_subject)" "$(date +%F)"
    printf 'Read-only playbook audit bundle (zero API mutations). Each row links '
    printf 'the per-playbook JSON written alongside this index.\n\n'
    printf '## Ran (%s)\n\n' "${#AUDIT_OK[@]}"
    for s in "${AUDIT_OK[@]:-}"; do [ -n "$s" ] && printf -- '- [%s](./%s.json)\n' "$s" "$s"; done
    printf '\n## No data / failed (%s)\n\n' "${#AUDIT_FAIL[@]}"
    for s in "${AUDIT_FAIL[@]:-}"; do [ -n "$s" ] && printf -- '- %s\n' "$s"; done
  } >"$out"
  _log "-> wrote ${out} (${#AUDIT_OK[@]} ok, ${#AUDIT_FAIL[@]} failed)"
  if [ "${#AUDIT_OK[@]}" -eq 0 ] && [ "${#AUDIT_FAIL[@]}" -gt 0 ]; then exit 1; fi
  exit 0
}

# audit_usage <bundle> — shared --help text for the generated bundles.
audit_usage() {
  cat >&2 <<EOF
$1 — read-only playbook audit bundle (generated). Runs each diagnostic playbook
and writes its JSON + an index.md into a timestamped results dir. Never mutates.

Usage: $1.sh --customer <id> [--lookback <days>] [--only <slug,slug>] [--out-dir <dir>] [--quiet]

  --only   Comma-separated slug subset (default: every playbook in the bundle).
  Other flags match the rest of the library (see the watchdogs' --help).
EOF
}

# --- Tier 3: weekly review consolidation -------------------------------------
# review_recent_reports <glob> — echo (newline-separated) matching status files
# found under watch_root()'s dated dirs for the last 7 days (today back).
review_recent_reports() {
  local pat="$1" root d day f i
  root="$(watch_root)"
  [ -d "$root" ] || return 0
  for i in 0 1 2 3 4 5 6; do
    day="$(date -d "-${i} days" +%F 2>/dev/null || date -v-"${i}"d +%F 2>/dev/null || true)"
    [ -n "$day" ] || continue
    d="${root}/${day}"
    [ -d "$d" ] || continue
    for f in "$d/"$pat; do [ -f "$f" ] && printf '%s\n' "$f"; done
  done
}

# review_merge_field <field> <file...> — concat the named top-level array field
# across every report file into one JSON array on stdout (empty if no files).
review_merge_field() {
  local field="$1"; shift
  [ "$#" -gt 0 ] || { echo '[]'; return 0; }
  jq -s --arg f "$field" '[ .[] | (.[$f]? // []) ] | add // []' "$@"
}

# review_write_weekly <survivors> <deferred> <insufficient> <cooling> <sources>
# Renders the ONE consolidated weekly-review.md + .json. Survivors that carry a
# plan_doc link the per-action dry-run plan the scans already rendered; the
# buckets explain why the rest were held. Writes both files; echoes the .md path.
review_write_weekly() {
  local survivors="$1" deferred="$2" insuff="$3" cooling="$4" sources="$5"
  local out="${OUT_DIR}/weekly-review.md" ns nd ni nc
  ns="$(jq 'length' <<<"$survivors")"; nd="$(jq 'length' <<<"$deferred")"
  ni="$(jq 'length' <<<"$insuff")";    nc="$(jq 'length' <<<"$cooling")"
  jq -n --argjson s "$survivors" --argjson d "$deferred" \
        --argjson i "$insuff" --argjson c "$cooling" --arg src "$sources" \
    '{proposed: $s, deferred_next_review: $d, insufficient_data: $i,
      deferred_cooldown: $c, sources: $src}' >"${OUT_DIR}/weekly-review.json"
  {
    printf '# Weekly review — %s — %s\n\n' "$(review_subject)" "$(date +%F)"
    printf '_Sources: %s_\n\n' "$sources"
    if [ "$ns" -gt 0 ]; then
      printf '## Proposed changes this week (%s, capped at change_budget=%s)\n\n' "$ns" "${CHANGE_BUDGET:-3}"
      printf 'Largest-impact-first, after one global change budget across every scan. '
      printf 'Each links the per-action dry-run plan doc the opportunity scan already '
      printf 'rendered (zero API mutation). Apply one with `plan-then-apply.sh <plan.md>`.\n\n'
      jq -r '.[] | "- **\(.entity_type)** \(.entity_name // .entity_id) — \(.metric_summary // "")\n"
        + "  impact \(.impact // .spend_usd // 0) · "
        + (if .plan_doc then "plan: \(.plan_doc)" else "suggested: `\(.suggested_command // "manual review")`" end)' <<<"$survivors"
    else
      printf '## No changes this week\n\n'
      printf 'An explicitly good outcome. The disciplined default is to change nothing '
      printf 'unless the data compels it — and nothing cleared all three gates '
      printf '(sufficiency · cooldown · change budget) this week.\n\n'
    fi
    printf '\n## Why — the buckets\n\n'
    printf -- '- Deferred to next review (over change budget): %s\n' "$nd"
    printf -- '- Insufficient data (keep collecting): %s\n' "$ni"
    printf -- '- Deferred — cooling (recently changed): %s\n\n' "$nc"
    if [ "$nd" -gt 0 ]; then printf '### Deferred — next review\n\n'
      jq -r '.[] | "- \(.entity_type) \(.entity_name // .entity_id) — impact \(.impact // .spend_usd // 0)"' <<<"$deferred"; printf '\n'; fi
    if [ "$ni" -gt 0 ]; then printf '### Insufficient data\n\n'
      jq -r '.[] | "- \(.entity_type) \(.entity_name // .entity_id): \(.sufficiency // "keep collecting")"' <<<"$insuff"; printf '\n'; fi
    if [ "$nc" -gt 0 ]; then printf '### Cooling\n\n'
      jq -r '.[] | "- \(.entity_type) \(.entity_name // .entity_id) — recently changed, held"' <<<"$cooling"; printf '\n'; fi
  } >"$out"
  _log "  wrote ${out} + weekly-review.json"
  printf '%s' "$out"
}
