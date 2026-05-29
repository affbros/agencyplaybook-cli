# AgencyPlaybook CLI Automation Guide

`apb` is the AgencyPlaybook command-line tool — an operator-grade command layer for agencies that need safe execution, reporting, diagnostics, playbooks, and controlled campaign operations against the Meta Marketing API.

This guide covers **unattended execution**: CI/CD pipelines, cron jobs, AI-agent workflows (Claude Code, Codex, etc.), and shell scripts. For interactive use, run `apb --help` and explore subcommands directly.

> **Tenant disable propagation:** When an admin disables a tenant via `/admin/tenants`, the CLI begins returning `403 tenant_inactive` within **30 seconds** (the local `~/.apb/tenant_context.json` cache TTL).
>
> **Account selection (CI/agents):** in unattended runs, set the target account explicitly — `--account act_…` per command, or `META_AD_ACCOUNT_ID` in the job's environment/`.env`. As of **v0.2.1**, `META_AD_ACCOUNT_ID` **takes precedence over** any persisted `~/.apb/config.json` `default_account` left on the runner, so a stale global default can't silently redirect a job to the wrong account. `apb` echoes `[apb] account: … (source: …)` to stderr for the audit trail.

---

## Machine-Safe Execution

Three flags govern every unattended invocation. Combine them as needed.

| Flag | Effect |
|---|---|
| `--no-input` | Promise that the CLI will never prompt. Any future prompt callsite returns a `safety_gate_blocked` error instead of reading stdin. |
| `--json` | Output structured JSON instead of human-readable tables. Errors emit a structured envelope (see below). |
| `--execute` | Apply changes. Required for all mutations. Without it, the CLI runs in dry-run mode and emits a `would_create` / `would_update` envelope. |
| `--confirm-destructive` | Required in addition to `--execute` for `DELETE`, `ARCHIVE`, $0 budget, and >200% budget changes. |

Read-only commands need none of these (other than optional `--json`):

```bash
apb account list --json
apb report insights --account act_123 --days 30 --json
apb playbook fatigue-index --account act_123 --json
```

Mutations always require `--execute` (without it the CLI dry-runs and exits 0); destructive ones additionally require `--confirm-destructive` (omitting it is a validation error, exit 2):

```bash
apb campaign update-status --id @spring-sale --status PAUSED --execute --json
apb campaign delete --id @old-test --execute --confirm-destructive --json
```

**`--no-input` does not bypass any safety gate.** If a write needs `--execute`, `--no-input` does not supply it; the command simply **dry-runs and exits 0** (it does not mutate). The flag's only job is to forbid stdin reads — see *Safety Model* below.

---

## Exit Codes

Every failure maps to a documented exit code. Scripts and CI runners can branch on these without parsing stderr:

| Code | Meaning | Examples |
|---:|---|---|
| `0` | Success | command completed; dry-run rendered |
| `1` | General / unmapped | I/O error, config parse failure, fall-through |
| `2` | Validation / invalid input | clap parse error, missing required flag, malformed JSON, invalid `--url` |
| `3` | Auth / permission | invalid `APB_API_KEY`, expired token, unauthorized account, missing scope, tier upgrade required |
| `4` | Safety gate blocked | `--execute` provided on a mutation but env-gates (`READ_ONLY` / `ALLOW_WRITES` / `APB_ALLOW_MUTATIONS`) blocked the write (`write_blocked`); or `--no-input` blocked a would-prompt path (`safety_gate_blocked`). **Without `--execute` the CLI dry-runs and exits 0; a missing `--confirm-destructive` is exit 2 (validation), not 4.** |
| `5` | Network / rate-limit / 5xx | Meta API timeout, 429 throttle, 5xx response, connection refused |
| `6` | Partial success | reserved for future batch operations |

When `--json` is set on a failing command, stdout emits a structured envelope. Stderr is empty.

```json
{
  "ok": false,
  "error": {
    "code": "write_blocked",
    "message": "Write blocked: READ_ONLY != false",
    "exit_code": 4,
    "details": {
      "reasons": ["READ_ONLY != false", "ALLOW_WRITES != true"]
    }
  }
}
```

Per-class `error.details` payloads:

| Variant | `error.code` | `details` |
|---|---|---|
| Write blocked | `write_blocked` | `reasons: [string]` — env-var and flag gate failures |
| Safety gate blocked | `safety_gate_blocked` | `gate: string`, `required_flags: [string]` |
| Insufficient scope | `insufficient_scope` | `required_scope`, `current_tier`, `minimum_tier` |
| Account not authorized | `account_not_authorized` | `account_id` |
| Rate limited | `rate_limited` | `retry_after_ms` |

Errors **not** in this table (e.g. `validation_error`, `auth_error`) emit a flat envelope — `code` + `message` + `exit_code`, with no `details` object.

---

## Ergonomic creative builders + leadgen ad-create (v0.2.0)

Sprint 3 of agency-gaps-v2 added 7 new `apb` commands paired with 7 API endpoints — operator-friendly builders that generate v25 `AdCreative` JSON internally. CI patterns:

- `apb creative create-image-simple` / `create-video-simple` — single-asset creatives. Image/video flags accept local paths (auto-upload under `--execute`) or Meta hashes/IDs.
- `apb creative create-lead-form-ad` — injects `lead_gen_form_id` into `link_data.call_to_action.value`. Validates form exists pre-write.
- `apb creative create-catalog-creative --format <single|carousel|collection|automatic>` — auto-wires the matching Sprint-1 `--allow-*` flag from the `--format` intent. Operators don't need to manually pass `--allow-collection` for a `--format collection` creative.
- `apb creative create-story-template` / `create-reels-video-template` — emit `story_advisories` / `reels_advisories` arrays (9:16 reminder, safe-zone, video length limits).
- `apb leadgen ad-create` — end-to-end orchestrator. Validates campaign objective is `OUTCOME_LEADS` + form belongs to page BEFORE any write. Reverse-pauses the creative if ad-create fails.

API parity: every CLI command has a paired `POST /api/v1/creatives/...` (or `/api/v1/leadgen/ad-create`) endpoint accepting the same fields as a typed JSON body. See `rust/docs/API_REFERENCE.md` § v0.2.0 Ergonomic Builders.

## Creative format auditor (v0.2.0, exit 2)

Every creative `create-*` subcommand and `apb creative update` runs a pure-function auditor on the spec before any write. Detects 11 unintended Meta v25 format-expansion variants (CAROUSEL / COLLECTION / FORMAT_AUTOMATION / `product_set_id` / `template_url` / `{{product.*}}` / etc. — the Scandalous Coffee class).

For CI / unattended pipelines:
- `--strict-format` upgrades dry-run findings to exit 2 (fail loud on any finding). Use this in pre-merge checks.
- `--audit-only` runs the auditor and exits 0 without writing, regardless of `--execute`. Use for spec-review jobs that want to read the `format_audit.findings` array via `--json`.
- When `--execute` is set and the audit detects unwhitelisted findings, the binary exits 2 BEFORE the write gate's exit 4 — so CI scripts that branch on exit code see the actionable auditor message, not the env complaint.
- Whitelist matching findings explicitly with `--allow-carousel`, `--allow-collection`, `--allow-automatic-format`, `--allow-format-automation`, `--allow-catalog-template`.

Full risk taxonomy + flag-by-flag reference at [`../rust/docs/CREATIVE_AUDITOR.md`](../rust/docs/CREATIVE_AUDITOR.md).

```yaml
# Example: GitHub Actions step that audits every committed creative spec.
- name: Audit creative specs
  run: |
    for spec in specs/creative/*.json; do
      apb creative create-image --name "ci-$(basename $spec .json)" --spec-file "$spec" --strict-format --json
    done
```

---

## Pre-flight Guards (`validation_error`, exit 2, during `--dry-run`)

A growing set of Meta-side rejections are now caught **before any network call** — so they fail fast on `--dry-run`, not after `--execute`. All return exit `2` with `error.code = "validation_error"`. Agents can either branch on the exit code (already covered) or pattern-match the message excerpt.

| Guard | Trigger | Message excerpt | Since |
|---|---|---|---|
| **Objective must be ODAX** | `campaign create` / `campaign compose-from-spec` with a non-`OUTCOME_*` objective (legacy `CONVERSIONS`, `LINK_CLICKS`, `POST_ENGAGEMENT`, …) | `objective 'CONVERSIONS' is not a valid Meta v25 objective … (CONVERSIONS → OUTCOME_SALES)` | v0.1.19 |
| **Conversion goal needs `promoted_object`** | `adset create` / compose with `--optimization-goal OFFSITE_CONVERSIONS` or `VALUE` and no `--promoted-object` | `optimization-goal OFFSITE_CONVERSIONS … requires a promoted_object — pass --promoted-object '{"pixel_id":"<id>","custom_event_type":"PURCHASE"}'` | v0.1.19 |
| **Dayparting needs a lifetime budget** | `--daypart-hours` / `--adset-schedule` + `--daily-budget` on create; or `adset update --adset-schedule` against a daily-budget ad set (or its CBO parent campaign — the CLI fetches both) | `adset_schedule (dayparting) requires a lifetime budget; daily-budget ad sets can't use fixed daypart scheduling` | v0.1.15 (create) / v0.1.17 (update + CBO parent) |
| **Dayparting windows must fit the flight** | Any `timezone_type=ADVERTISER` window's recurring slot never intersects `start_time → end_time` (e.g. lifetime $350 with windows past `--end-time …T10:00`). Skipped for flights ≥ 7 days. | `N daypart window(s) fall entirely outside the flight (… .. …) and will never deliver: HH:MM-HH:MM, …` | v0.1.20 |
| **Placement preset conflict** | `--placements <preset>` on `adset create` / `adset update-targeting` when the operator's `--targeting` JSON already contains `publisher_platforms` / `facebook_positions` / `instagram_positions` | `--placements reels conflicts with --targeting.publisher_platforms (operator set X, preset wants Y). Remove one of them.` | v0.2.0 |

All guards are deterministic and best-effort: `USER`-timezone windows, parse failures on times, and lookup failures (e.g. parent campaign GET errors) **pass through** rather than block — Meta stays the final authority. No false positives by design.

### Soft `advisories[]` (non-blocking, v0.1.20)

The `adset create` / `adset update` result includes an `advisories[]` string array (top-level, alongside `id` or inside the dry-run envelope) for Meta-accepted setups that usually under-deliver:

| Trigger | Sample message |
|---|---|
| Lifetime budget, flight < 24h | `Flight is only Xh — a lifetime budget paces poorly over <1 day; use a daily budget or a longer flight.` |
| Lifetime budget, flight < 6 days | `Flight is ~Xd — Meta typically needs ≥6 days to exit the learning phase; short flights can under-deliver.` |
| Lifetime / dayparted ad set with no `end_time` | `Lifetime budget / dayparting requires --end-time …` |

Agents should surface advisories to the operator but **not** treat them as failures. The exit code stays `0` (dry-run) or `0` (execute success); `advisories` is omitted when empty.

### Full-body dry-run preview (v0.1.20)

`adset create --dry-run` returns a `would_create` object that contains the **complete** request body Meta would receive: `campaign_id`, `name`, `optimization_goal`, `billing_event`, `targeting` (with `targeting_automation.advantage_audience` injected), `daily_budget` / `lifetime_budget`, `bid_strategy`, `bid_amount`, `pacing_type`, `promoted_object`, `start_time`, `end_time`, `adset_schedule`, `status`. (`adset update` previews the full `changes` map.) Agents can verify budget/conversion/schedule wiring without `--execute`.

```json
{
  "ok": true,
  "dry_run": true,
  "would_create": {
    "campaign_id": "120…",
    "name": "Evening Sales",
    "optimization_goal": "OFFSITE_CONVERSIONS",
    "billing_event": "IMPRESSIONS",
    "lifetime_budget": "35000",
    "pacing_type": ["day_parting"],
    "promoted_object": {"pixel_id": "…", "custom_event_type": "ADD_TO_CART"},
    "adset_schedule": [/* 6 windows */],
    "start_time": "2026-06-01T00:00:00-0700",
    "end_time": "2026-06-08T23:59:00-0700",
    "status": "PAUSED",
    "targeting": {/* … */}
  },
  "advisories": [],
  "blocked_reasons": ["--execute flag not provided", "READ_ONLY != false", …]
}
```

---

## CI/CD Examples

### Read-only health check (GitHub Actions, GitLab, etc.)

```bash
apb doctor check --no-input --json
# exit 0 = healthy; non-zero = config drift or expired credentials
```

### Daily insights pull

```bash
apb report insights \
  --account act_123 \
  --days 7 \
  --no-input --json \
  > reports/$(date -I).json
```

### Dry-run a campaign change before merging

```bash
apb campaign update \
  --id @spring-sale \
  --account act_123 \
  --daily-budget 5000 \
  --no-input --json
# Without --execute the CLI prints a dry-run envelope ({"dry_run": true,
# "changes": {...}, "blocked_reasons": [...]}) and exits 0.
# Use this in PR previews so reviewers can see the projected change.
```

### Gated mutation in a deployment job

```bash
set -e
apb campaign update-status \
  --id @spring-sale \
  --status PAUSED \
  --account act_123 \
  --no-input --json --execute
case $? in
  0) echo "paused" ;;
  4) echo "FAILED: missing safety flag — should not happen with --execute"; exit 1 ;;
  5) echo "TRANSIENT: network/5xx — retry with backoff"; exit 75 ;;
  *) echo "FATAL: $?"; exit 1 ;;
esac
```

### Destructive op with explicit confirmation

```bash
apb campaign delete \
  --id @old-test \
  --account act_123 \
  --no-input --json --execute --confirm-destructive
```

---

## AI Agent / Claude Usage

Recommended invocation pattern for an agent (Claude Code, Codex, etc.) running `apb` programmatically:

1. **Always pass `--no-input --json`.** Promise no prompts; consume structured JSON.
2. **Never pass `--execute` without explicit user authorization for that specific command.** A user saying "yes proceed" once is not blanket authorization for future invocations — re-confirm per command.
3. **Branch on `error.exit_code`, not `error.message`** — messages are localized and may evolve; codes are stable contract.
4. **For destructive operations**, surface the dry-run output to the user before the `--execute --confirm-destructive` invocation. Never auto-confirm.

Minimal Claude-style invocation:

```bash
apb playbook fatigue-index \
  --account act_123 \
  --no-input --json
```

Decision tree on the result:
- `exit 0` → parse `data` and act on findings
- `exit 4` → safety gate blocked; report `error.details.required_flags` to user, do not proceed
- `exit 3` → auth issue; ask user to refresh credentials
- `exit 5` → transient; back off and retry up to N times
- `exit 2` → user-input bug; surface `error.message` to user, do not retry

---

## Debugging

`--debug` installs `tracing_subscriber` with **stderr** output and sets `RUST_LOG=apb_cli=debug,apb_core=debug,apb_api=debug` if the env var is unset. JSON output on stdout is unaffected.

The CLI emits debug events from three targets out of the box:

| Target | Where | Sample fields |
|---|---|---|
| `apb_cli::dispatch` | top of every command dispatch | `execute`, `dry_run`, `confirm_destructive`, `json_output`, `no_input`, `tenant_authenticated` |
| `apb_core::http` | every Meta Graph API call (request entry, success, error) | `method`, `endpoint`, `status`, `latency_ms`, `attempt`, `retryable`, `param_keys` |
| `apb_core::gate` | every write-gate evaluation, both dry-run and exit-4 paths | `execute_attempted`, `allowed`, `reasons` |

Sample `--debug` stderr from a list call:

```text
DEBUG apb_cli::dispatch: dispatch start execute=false dry_run=false json_output=true no_input=true tenant_authenticated=true
DEBUG apb_core::http:    graph request method="GET" endpoint=act_X/campaigns param_keys=["fields", "limit"]
DEBUG apb_core::http:    graph response ok endpoint=act_X/campaigns status=200 latency_ms=750 attempt=0
```

**Explicit `RUST_LOG` always wins** over the `--debug` default — narrow or widen the filter as needed:

```bash
# Narrow to one target
RUST_LOG=apb_core::http=debug apb --debug campaign list

# Widen to include third-party HTTP plumbing (reqwest, hyper)
RUST_LOG=apb_cli=debug,apb_core=debug,reqwest=debug,hyper_util::client=info apb --debug campaign list

# Maximum verbosity (TLS handshakes, pool checkouts, etc.)
RUST_LOG=trace apb --debug campaign list
```

For per-command structured audit events (always on, independent of `--debug`), tail the JSONL file:

```bash
tail -f logs/apb.jsonl                  # all events
jq 'select(.event=="campaign.update")' < logs/apb.jsonl
```

### Sanitization

`apb_core::log_sanitize::redact()` runs on events flowing through the apb logger and tracing layer. **Third-party events surfaced via a widened `RUST_LOG` (reqwest, hyper) bypass the apb sanitizer** — choose your filter accordingly when piping to a log aggregator. Patterns the sanitizer covers:

- `Authorization: Bearer <token>` → `Bearer [REDACTED]`
- `?access_token=<value>` and `?refresh_token=<value>` → `<param>=[REDACTED]`
- `apb_live_<tier>_<32+ hex>` and `apb_test_<tier>_<32+ hex>` → `apb_<env>_[REDACTED]`
- `EAA<long base64-ish>` (Meta system-user / page tokens) → `EAA[REDACTED]`

The CLI writes structured JSONL events to `logs/apb.jsonl` regardless of `--debug` — that is the canonical apb event stream today.

---

## Plain Output / Log Aggregation

ANSI escape sequences interfere with log aggregators (CloudWatch, Datadog, Loki, Splunk). The CLI honors three opt-out signals:

| Signal | Source |
|---|---|
| `--no-color` | CLI flag (highest priority) |
| `NO_COLOR=1` | environment variable (de-facto standard) |
| `CLICOLOR=0` | environment variable (BSD ls convention) |

Any of the three forces clap's color choice to `Never`. JSON output is ANSI-free regardless.

```bash
NO_COLOR=1 apb campaign list --account act_123 | tee /var/log/apb.log
```

---

## Dynamic Creative Quick Experiments

For production DCO use, author an `asset_feed_spec` JSON file and pass it via `--spec-file`. For quick experiments and ad-hoc testing, the CLI accepts inline flags:

```bash
apb creative create-dynamic \
  --name "DCO Test - May" \
  --image abc123def456 \
  --image fedcba654321 \
  --title "Lower Your Monthly Payment" \
  --title "Compare Loan Options Fast" \
  --body "Check your options without hurting your credit." \
  --body "See personalized offers in minutes." \
  --cta LEARN_MORE \
  --url https://example.com \
  --account act_123 \
  --page-id 1234567890 \
  --dry-run --json
```

### Image input modes

`--image` accepts either a Meta image hash or a local file path:

- **Hash** (e.g. `abc123def456`): used directly. No upload happens.
- **Path** (starts with `./`, `/`, `~/`, `..`, or ends with `.jpg|.jpeg|.png|.gif|.webp`): the CLI calls `apb_core::services::creative::upload_image()` to mint a hash, then assembles the spec.
  - Under `--execute`, this is a real upload.
  - Under `--dry-run`, no upload happens; the spec is stamped with `<dry_run_placeholder:./img.jpg>` so you can inspect the planned shape. To verify the upload itself before a dry-run, use `apb creative upload-image --path ./img.jpg --execute` first to mint the hash, then pass the hash inline.

To disambiguate an image hash that happens to look like a filename, prefix with `./` to force path mode.

### Conflict rule

`--spec-file` (or `--spec`) and inline DCO flags are **mutually exclusive**:

```bash
apb creative create-dynamic --spec-file dco.json --image abc123 \
  # → exits 2 with: Cannot use --spec-file together with inline DCO flags. Use one input mode.
```

### Inline-mode validators

The CLI rejects inline invocations missing any of:

- ≥1 `--image` (hash or path)
- ≥1 `--title`
- ≥1 `--body`
- `--cta`
- `--url` (parsed as a URL)

Each violation produces an exit-2 `Validation error` naming the missing field.

---

## Safety Model for Unattended Execution

The CLI's safety contract is layered. Each layer must explicitly permit before a mutation runs.

1. **`--no-input`** promises *no prompts*. It does **not** imply approval. Mutations still need `--execute`. This separation is deliberate: an agent or cron job committing to non-interactive execution must still prove it's authorized to write.
2. **Env-var gates** (`READ_ONLY=false`, `ALLOW_WRITES=true`, `APB_ALLOW_MUTATIONS=true`) — three independent operator-controlled toggles.
3. **`--execute`** — explicit per-invocation flag.
4. **`--confirm-destructive`** — required for DELETE / ARCHIVE / $0 budget / >200% budget moves.

Env-gate and `--no-input`-prompt failures abort with **exit 4** — `write_blocked` (`error.details.reasons`) or `safety_gate_blocked` (`error.details.required_flags`). Note the other two layers differ: a missing `--execute` **dry-runs and exits 0** (no abort), and a missing `--confirm-destructive` is a **validation error (exit 2)**.

**`--no-input` never implies approval.** It is a contract between the operator and the CLI that stdin will not be read; nothing more. If you pipe `apb` into a script, you must still satisfy every gate the operation requires. The CLI will refuse rather than guess.

---

## See also

- `reference/exit-codes.md` — canonical exit-code table + agent decision tree (in this skill bundle)
- `reference/scopes.md` — per-scope command list and tier requirements (in this skill bundle)
- Full CLI reference & downloads: <https://agencyplaybook.io> (Developer → CLI Reference) and <https://github.com/affbros/agencyplaybook-cli>
