# `apb plan` — Command Reference

11 commands. Auto-generated from the apb binary on 2026-06-18.

### `apb plan approve-batch`

Approve a batch of plans

**Scope:** `write:campaigns` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--ids` | `<IDS>` |  |
| `--approve-plan-id` | `<APPROVE_PLAN_ID>` |  |
| `--account` | `<ACCOUNT>` |  |
| `--all` |  |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb plan approve-batch --ids <IDS> --approve-plan-id <APPROVE_PLAN_ID>
```

### `apb plan canary`

Run canary (partial) execution

**Scope:** `write:campaigns` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--plan-id` | `<PLAN_ID>` |  |
| `--pct` | `<PCT>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb plan canary --plan-id <PLAN_ID> --pct <PCT>
```

### `apb plan cap`

Conditional cap — freeze a campaign (pause) and hold until a release condition clears. Dry-run by default; pass --execute to pause. `--until` is required (fail-fast if invalid)

**Scope:** `write:campaigns` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--campaign` | `<CAMPAIGN>` | Campaign name, @alias, or id to cap |
| `--until` | `<UNTIL>` | Release condition: `<metric><op><value>`, e.g. "roas>=3.0" (metric ∈ roas\|cpa\|conv\|spend) |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb plan cap --campaign <CAMPAIGN> --until <UNTIL>
```

### `apb plan check-caps`

Re-evaluate every open cap against current metrics; promote (un-pause) the ones whose condition has cleared. Dry-run by default; pass --execute to promote

**Scope:** `write:campaigns` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--days` | `<DAYS>` | Lookback window for the current-metric re-check (default 30) |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb plan check-caps --days <DAYS> --allow-domain <HOST>
```

### `apb plan create`

Create a new execution plan

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--campaign` | `<CAMPAIGN>` |  |
| `--name` | `<NAME>` |  |
| `--spec-file` | `<SPEC_FILE>` | Plan spec — file path OR inline JSON: {"action":"<domain.verb>","target_id":"<id>" (or "target_ids":[...]),"payload":{...}} |
| `--mode` | `<MODE>` |  |
| `--strategy` | `<STRATEGY>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb plan create --execute --campaign <CAMPAIGN> --name <NAME>
```

### `apb plan doctor`

Run plan diagnostics

**Scope:** `read:campaigns` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--plan-id` | `<PLAN_ID>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb plan doctor --plan-id <PLAN_ID> --allow-domain <HOST>
```

### `apb plan execute`

Execute a plan

**Scope:** `write:campaigns` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--plan-id` | `<PLAN_ID>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb plan execute --plan-id <PLAN_ID> --allow-domain <HOST>
```

### `apb plan execute-safe`

Execute a plan with safety checks

**Scope:** `write:campaigns` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--plan-id` | `<PLAN_ID>` |  |
| `--allow-preflight-inconclusive` |  |  |
| `--require-dry-run-pass` |  |  |
| `--allow-no-preflight` |  |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb plan execute-safe --plan-id <PLAN_ID> --allow-domain <HOST>
```

### `apb plan list`

List existing plans

**Scope:** `read:campaigns` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--limit` | `<LIMIT>` |  |
| `--status` | `<STATUS>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb plan list --limit <LIMIT> --status <STATUS>
```

### `apb plan review-batch`

Review a batch of plans

**Scope:** `write:campaigns` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--ids` | `<IDS>` |  |
| `--account` | `<ACCOUNT>` |  |
| `--all` |  |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb plan review-batch --ids <IDS> --allow-domain <HOST>
```

### `apb plan validate`

Validate a plan without executing

**Scope:** `write:campaigns` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--plan-id` | `<PLAN_ID>` |  |
| `--spec-file` | `<SPEC_FILE>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb plan validate --plan-id <PLAN_ID> --spec-file <SPEC_FILE>
```
