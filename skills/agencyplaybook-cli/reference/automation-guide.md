# AgencyPlaybook CLI Automation Guide

`apb` is the AgencyPlaybook command-line tool — an operator-grade command layer for agencies that need safe execution, reporting, diagnostics, playbooks, and controlled campaign operations against the Meta Marketing API.

This guide covers **unattended execution**: CI/CD pipelines, cron jobs, AI-agent workflows (Claude Code, Codex, etc.), and shell scripts. For interactive use, run `apb --help` and explore subcommands directly.

> **Tenant disable propagation:** When an admin disables a tenant via `/admin/tenants`, the CLI begins returning `403 tenant_inactive` within **30 seconds** (the local `~/.apb/tenant_context.json` cache TTL).

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
apb report insights --account act_123 --since 30d --json
apb playbook fatigue-index --account act_123 --json
```

Mutations always require `--execute`; destructive ones additionally require `--confirm-destructive`. The CLI fails fast with exit code 4 if you forget either:

```bash
apb campaign update-status --id @spring-sale --status PAUSED --execute --json
apb campaign delete --id @old-test --execute --confirm-destructive --json
```

**`--no-input` does not bypass any safety gate.** If a write needs `--execute`, `--no-input` does not supply it; the command still exits 4. The flag's only job is to forbid stdin reads — see *Safety Model* below.

---

## Exit Codes

Every failure maps to a documented exit code. Scripts and CI runners can branch on these without parsing stderr:

| Code | Meaning | Examples |
|---:|---|---|
| `0` | Success | command completed; dry-run rendered |
| `1` | General / unmapped | I/O error, config parse failure, fall-through |
| `2` | Validation / invalid input | clap parse error, missing required flag, malformed JSON, invalid `--url` |
| `3` | Auth / permission | invalid `APB_API_KEY`, expired token, unauthorized account, missing scope, tier upgrade required |
| `4` | Safety gate blocked | `--execute` provided on a mutation but env-gates (`READ_ONLY` / `ALLOW_WRITES` / `APB_ALLOW_MUTATIONS`) blocked the write; `--confirm-destructive` missing on a destructive op; `--no-input` set on a would-prompt path. **Without `--execute` the CLI dry-runs and exits 0** — see "Dry-run a campaign change" below. |
| `5` | Network / rate-limit / 5xx | Meta API timeout, 429 throttle, 5xx response, connection refused |
| `6` | Partial success | reserved for future batch operations |

When `--json` is set on a failing command, stdout emits a structured envelope. Stderr is empty.

```json
{
  "ok": false,
  "error": {
    "code": "write_blocked",
    "message": "Write blocked: [\"--execute flag not provided\"]",
    "exit_code": 4,
    "details": {
      "reasons": ["--execute flag not provided", "READ_ONLY=true"]
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
  --since 7d \
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

A failure at any layer aborts with exit code 4 and a JSON envelope naming the missing flag in `error.details.required_flags`.

**`--no-input` never implies approval.** It is a contract between the operator and the CLI that stdin will not be read; nothing more. If you pipe `apb` into a script, you must still satisfy every gate the operation requires. The CLI will refuse rather than guess.

---

## See also

- `reference/exit-codes.md` — canonical exit-code table + agent decision tree (in this skill bundle)
- `reference/scopes.md` — per-scope command list and tier requirements (in this skill bundle)
- Full CLI reference & downloads: <https://agencyplaybook.io> (Developer → CLI Reference) and <https://github.com/affbros/agencyplaybook-cli>
