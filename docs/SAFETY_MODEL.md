# Safety Model

`apb` implements a multi-layer safety system to prevent accidental mutations to the Meta Marketing API. This document describes each layer, how they interact, and the verification process.

---

## Design Principle

**Every mutating command is DRY-RUN by default.** A write only executes when the operator has explicitly opened all safety gates. There is no shortcut to bypass this — each gate serves a different role and must be individually enabled.

---

## Layer 1: Write Gates (4 independent gates)

All four gates must be open simultaneously for any API mutation to occur.

### Gate 1: `--execute` flag

The operator must pass `--execute` on the command line. Without it, every write command shows a DRY-RUN preview of what would happen.

```bash
# This NEVER writes — shows preview only
apb campaign update-status --id 123 --status PAUSED

# This CAN write (if other gates are open)
apb campaign update-status --id 123 --status PAUSED --execute
```

### Gate 2: `READ_ONLY` environment variable

Must be set to `false` in `.env` or environment. Defaults to `true` (writes blocked).

```env
READ_ONLY=false
```

### Gate 3: `ALLOW_WRITES` environment variable

Must be set to `true`. Defaults to `false` (writes blocked).

```env
ALLOW_WRITES=true
```

### Gate 4: `META_CTL_ALLOW_MUTATIONS` environment variable

Explicit operator override. Must be set to `true`. Not stored in `.env` by convention — exported in the shell session when mutations are intended.

```bash
export META_CTL_ALLOW_MUTATIONS=true
```

### Gate Truth Table

| --execute | READ_ONLY | ALLOW_WRITES | MUTATIONS | Result |
|-----------|-----------|--------------|-----------|--------|
| false | any | any | any | DRY-RUN |
| true | true | any | any | DRY-RUN |
| true | false | false | any | DRY-RUN |
| true | false | true | false | DRY-RUN |
| true | false | true | true | **EXECUTE** |

Only 1 of 16 combinations allows a write.

### Gate Check Output

When a write is blocked, the output includes the exact reasons:

```json
{
  "mode": "DRY-RUN",
  "would_update": { "campaign_id": "123", "status": "PAUSED" },
  "blocked_by": [
    "--execute flag not provided",
    "READ_ONLY != false",
    "ALLOW_WRITES != true",
    "META_CTL_ALLOW_MUTATIONS != true"
  ]
}
```

---

## Layer 5: Unattended Execution Contract

(Added by `cli-ergonomics-001` workstream, 2026-05-01.)

When `apb` runs in CI/CD, cron, or under an AI agent, three additional surfaces govern safety:

### `--no-input` — never prompt

Promises that the CLI will not read stdin. Today the binary has zero stdin reads, but the flag is wired so any future prompt callsite must consult `apb_core::safety::require_input_allowed(no_input)` and fail-fast with `MetaError::SafetyGateBlocked` rather than block.

**`--no-input` does NOT imply approval.** If a write needs `--execute`, this flag does not supply it. The two are independent: `--no-input` is about prompt behavior, `--execute` is about mutation authorization. Combine them explicitly; the CLI refuses rather than guess.

### Per-class exit codes

`MetaError` variants map to documented exit codes via `apb_core::exit_codes::exit_for_error(&MetaError) -> i32`:

| Code | Meaning | Triggers |
|---:|---|---|
| `0` | Success | command completed; dry-run rendered |
| `1` | General / unmapped | I/O, config parse failure, fall-through |
| `2` | Validation / invalid input | clap parse error, missing required flag, malformed JSON, invalid `--url` |
| `3` | Auth / permission | invalid `APB_API_KEY`, expired token, `AccountNotAuthorized`, `InsufficientScope`, `KeyExpired` |
| `4` | **Safety gate blocked** | `WriteBlocked` (missing `--execute` or env-var gate) **OR** `SafetyGateBlocked` (e.g. `--no-input` blocking a prompt) |
| `5` | Network / rate-limit / 5xx | Meta API timeout, 429 throttle, 5xx, connection refused |
| `6` | Reserved (Partial) | future batch operations |

### Structured JSON envelope

When `--json` is set on a failing command, stdout emits a structured envelope (stderr empty):

```json
{
  "ok": false,
  "error": {
    "code": "write_blocked",
    "message": "Write blocked: [\"--execute flag not provided\"]",
    "exit_code": 4,
    "details": { "reasons": ["--execute flag not provided", "READ_ONLY=true"] }
  }
}
```

Per-variant `details` payloads:

| Variant | `error.code` | `details` |
|---|---|---|
| `WriteBlocked` | `write_blocked` | `reasons: [string]` |
| `SafetyGateBlocked` | `safety_gate_blocked` | `gate: string`, `required_flags: [string]` |
| `InsufficientScope` | `insufficient_scope` | `required_scope`, `current_tier`, `minimum_tier` |
| `AccountNotAuthorized` | `account_not_authorized` | `account_id` |
| `RateLimit` | `rate_limited` | `retry_after_ms` |

The same `SafetyGateBlocked` variant maps to **HTTP 403** with `error.code = "safety_gate_blocked"` in `apb-api`, mirroring the existing `WriteBlocked → 403` mapping.

### Sanitization for `--debug` output

When `--debug` is set, `tracing` writes to stderr. Anything that reaches the subscriber should run through `apb_core::log_sanitize::redact()` first; it masks bearer tokens, `access_token=` / `refresh_token=` query params, `apb_live_*` / `apb_test_*` keys, and Meta `EAA*` system-user tokens.

For complete agent / CI invocation patterns, see [`docs/CLI_AUTOMATION.md`](../../docs/CLI_AUTOMATION.md).

---

## Layer 2: Plan Lifecycle

For operations that need review before execution, the plan system adds additional safety.

### Plan Flow

```
create → validate → execute
```

1. **create** — Captures the intended action, target, and payload as a JSON plan file
2. **validate** — Runs preflight checks (validate_only API probe, blast radius scoring, rollback blueprint generation)
3. **execute** — Requires explicit approval match + all write gates + quota check

### Plan Execution Gates (3 additional checks)

On top of the 4 write gates, plan execution requires:

5. **Plan status = VALIDATED** — Plan must have passed validation
6. **Approval match** — `--approve-plan-id` must exactly match `--plan-id`
7. **Quota check** — API usage pressure must be below critical threshold

### Blast Radius Scoring

Every plan action is scored 1-5:

| Score | Level | Examples |
|-------|-------|----------|
| 1 | MINIMAL | creative.create-image, creative.create-video |
| 2 | LOW | adset.update-budget, ad.update-status, ad.create |
| 3 | MODERATE | campaign.update-status, adset.update-targeting |
| 4 | HIGH | campaign.duplicate (creates multiple entities) |
| 5 | CRITICAL | (reserved for future destructive operations) |

### Rollback Blueprints

When a plan is validated, a rollback blueprint is generated:

- **Status changes** — Revert to the pre-snapshot status
- **Budget changes** — Revert to the pre-snapshot budget
- **Entity creation** — Delete the created entity
- **DELETED status** — Marked as irreversible

### Plan execute-safe

The safest execution path. Runs `plan doctor` first, then executes only if all checks pass:

```bash
apb plan execute-safe --plan-id plan_abc --json
```

Flags for edge cases:
- `--dry-run` — Run doctor checks only, never execute
- `--allow-preflight-inconclusive` — Continue when validate_only is inconclusive
- `--allow-no-preflight` — Continue when action has no validate_only support
- `--require-dry-run-pass` — Require prior dry-run pass before execution

---

## Layer 3: Execution Artifacts

Every executed plan produces an artifact in `state/executions/`:

```json
{
  "plan_id": "plan_abc123",
  "executed_at": "2024-01-15T12:00:00Z",
  "pre_snapshot": { ... },
  "post_snapshot": { ... },
  "api_result": { ... },
  "quota_at_execution": { ... }
}
```

This provides:
- **Audit trail** — What was changed, when, and what the state was before/after
- **Rollback data** — Pre-snapshot values to revert if needed
- **Quota context** — API pressure at the time of execution

---

## Layer 4: Policy Profiles

Environment-level safety presets:

### dev

```json
{ "strict_mode": false, "allow_risk_overrides": true }
```

Flexible for development. Override flags are allowed.

### staging

```json
{ "strict_mode": true, "allow_risk_overrides": true }
```

Strict by default, but allows explicit override testing.

### prod

```json
{ "strict_mode": true, "allow_risk_overrides": false }
```

Maximum safety. Override flags are disabled by policy.

Set with:

```bash
apb policy profile set --profile prod
```

---

## Safety Checklist for Operators

Before executing any write:

1. Run `apb doctor check --json` — verify token, scopes, account
2. Run `apb doctor quota --json` — verify API pressure is acceptable
3. Use `--json` output and review the DRY-RUN preview
4. For plan-based writes, use the full `create → validate → execute-safe` flow
5. After execution, verify with a read command (e.g., `campaign get --id ...`)

---

## Logging

All operations are logged to `logs/apb.jsonl`:

```jsonl
{"ts":"2024-01-15T12:00:00Z","level":"info","event":"campaign_update_status","id":"123","status":"PAUSED","dry_run":true}
{"ts":"2024-01-15T12:01:00Z","level":"info","event":"campaign_status_updated","id":"123","status":"PAUSED","result":{"success":true}}
```

Mutations are additionally logged to `logs/apb-actions.jsonl` for audit.

The access token is **never** logged — only parameter keys are recorded in API request logs.

### PII handling discipline (Sprints 005, 006)

Two scopes carry PII through service-layer code: `read:leadgen:export` (lead form `field_data` containing submitter responses) and `write:audience-data` (customer-list audience uploads with email/phone/name). The audit log is intentionally ungated — every service writes to it — so PII leakage here would bypass scope gating.

**Discipline** (codified in `services/leadgen.rs::list_leads`/`export_leads` and `services/audience.rs::users_mutate`): log only the *shape* of the operation, never the values:

| Operation | Logged | NEVER logged |
|---|---|---|
| `leadgen.list_leads` | `{form_id, since, until, lead_count}` | `field_data`, lead values, response text |
| `leadgen.export_leads` | `{form_id, since, until, lead_count, follow_pagination}` | Same |
| `audience.users_add` / `users_remove` | `{audience_id, schema, row_count, batch_count}` | Plaintext PII (passed through), hashed values |

Hashing for `audience users-add` happens client-side in the service layer via SHA-256 with Meta's per-field normalization rules (lowercase+trim for email/names, digit-only for phones, zero-pad for DOB) — Meta receives only hashes; the local process retains plaintext only as long as the request is in-flight.

Verification: per Sprint 005 and Sprint 006 evals, strict regex grep audits of `logs/apb.jsonl` for plaintext + hashed PII patterns return zero hits. Page IDs and other public Meta object identifiers are not PII.
