# `apb plan` — Command Reference

16 commands. Auto-generated from the apb binary on 2026-09-11.

### `apb plan apply`

Apply a plan-first envelope from a file (from `--plan` or `plan export`). Imports + validates + previews by default (zero mutation); pass --execute (+ write gates) to apply. The file is untrusted input: its integrity hash and any recorded prior values are re-checked, and delete-class actions need --confirm-destructive

**Scope:** `write:campaigns` · **Min tier:** professional · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--from-file` | `<FROM_FILE>` | Path to the plan JSON file (the `<path>.json` twin, not the `.md` doc) |
| `--allow-edited-plan` |  | Apply even if the file's contents no longer match its recorded hash (hand-edited plan). Explicit + audited |
| `--allow-stale-plan` |  | Apply even if a recorded prior value has drifted from the live value since the plan was emitted. Explicit + audited |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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
apb plan apply --execute --from-file <FROM_FILE> --plan <PATH>
```

### `apb plan approve-batch`

Approve a batch of plans

**Scope:** `write:campaigns` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--ids` | `<IDS>` |  |
| `--approve-plan-id` | `<APPROVE_PLAN_ID>` |  |
| `--account` | `<ACCOUNT>` |  |
| `--all` |  |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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

**Scope:** `write:campaigns` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--plan-id` | `<PLAN_ID>` |  |
| `--pct` | `<PCT>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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

**Scope:** `write:campaigns` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--campaign` | `<CAMPAIGN>` | Campaign name, @alias, or id to cap |
| `--until` | `<UNTIL>` | Release condition: `<metric><op><value>`, e.g. "roas>=3.0" (metric ∈ roas\|cpa\|conv\|spend) |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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

**Scope:** `write:campaigns` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--days` | `<DAYS>` | Lookback window for the current-metric re-check (default 30) |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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
apb plan check-caps --days <DAYS> --plan <PATH>
```

### `apb plan create`

Create a new execution plan

**Scope:** `write:campaigns` · **Min tier:** professional · **Write op** (requires `--execute`)

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
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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
apb plan doctor --plan-id <PLAN_ID> --plan <PATH>
```

### `apb plan execute`

Execute a plan

**Scope:** `write:campaigns` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--plan-id` | `<PLAN_ID>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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
apb plan execute --plan-id <PLAN_ID> --plan <PATH>
```

### `apb plan execute-safe`

Execute a plan with safety checks

**Scope:** `write:campaigns` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--plan-id` | `<PLAN_ID>` |  |
| `--allow-preflight-inconclusive` |  |  |
| `--require-dry-run-pass` |  |  |
| `--allow-no-preflight` |  |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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
apb plan execute-safe --plan-id <PLAN_ID> --plan <PATH>
```

### `apb plan export`

Export a plan to a portable plan-first envelope file (`--id`, a stored plan), or re-render an envelope file you already have (`--from-file`) as the markdown review document or the self-contained HTML review page. Re-appliable via `plan apply --from-file`

**Scope:** `read:campaigns` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` | The plan id to export (see `plan list`). Mutually exclusive with `--from-file` |
| `--from-file` | `<FROM_FILE>` | An existing plan-envelope JSON file to re-render (from `--plan`, `recipe build`, or a previous `plan export`). Mutually exclusive with `--id` |
| `--format` | `<FORMAT>` | Output shape: `json` (the envelope, default), `md` (the review document) or `html` (the self-contained review page). Pair `html` with the global `--fonts web` for online viewing |
| `--out` | `<OUT>` | Output file path |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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
apb plan export --id <ID> --from-file <FROM_FILE>
```

### `apb plan forecast`

What-if delivery-estimate scenarios for an ad set (planning-001 S2). Calls Meta `delivery_estimate` once per budget scenario on the v26-safe field set (`estimate_mau_lower_bound/_upper_bound`, `estimate_ready`, `bid_estimate`) — never the v26-removed `daily_outcomes_curve` / `budget_guardrail` / `estimate_dau`. Prints a table on stderr, JSON on stdout, always. Read-only — never mutates the account

**Scope:** `read:campaigns` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--adset-spec` | `<ADSET_SPEC>` | A `CampaignComposeSpec` (v1 or v2) file path, optionally with an `#ad_sets[N]` fragment to pick one ad set out of several (default: `ad_sets[0]`). Mutually exclusive with `--adset-id` |
| `--adset-id` | `<ADSET_ID>` | An existing ad set id — its live targeting/optimization_goal/budget are read and forecast. Mutually exclusive with `--adset-spec` |
| `--budget-scenarios` | `<BUDGET_SCENARIOS>` | Comma-separated daily budgets in account currency, e.g. `50,75,100`. Default: the ad set's own daily budget × {0.5, 1, 1.5} |
| `--period` | `<PERIOD>` | Informational lookback/forecast window (Meta's delivery_estimate has no period param; echoed into the output for parity with the Google twin). Default `30d` |
| `--out` | `<OUT>` | Write the forecast JSON to this file (in addition to stdout) |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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
apb plan forecast --adset-spec <ADSET_SPEC> --adset-id <ADSET_ID>
```

### `apb plan get`

Print a stored plan (by id) — the record plus its plan-envelope-v2 rendering. `--format v2` prints the envelope alone, which is exactly what `GET /api/v1/plans/:id` returns under `data.envelope`

**Scope:** `write:campaigns` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` | The plan id to read (see `plan list`) |
| `--format` | `<FORMAT>` | `record` (default — the stored row plus `envelope`) or `v2` (the envelope alone) |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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
apb plan get --id <ID> --format <FORMAT>
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
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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

### `apb plan merge`

Merge N Meta plan-envelope-v2 files (from separate `--plan`/`recipe build`/playbook runs) into ONE reviewable envelope: dedupe byte-identical actions, isolate contradictory bidding/target/budget changes as unresolved conflicts, rank the survivors (growth/ efficiency), and sequence them behind the learning-window guard — inserting `wait-for-status` pseudo-actions where needed. `plan apply --from-file --execute` and `plan validate --from-file` both honour those waits (planning-001 sprint-m03)

**Scope:** `read:campaigns` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--from` | `<FILE>` | Path to an input plan file (v1 or v2 envelope). Repeatable — give at least one |
| `--mode` | `<MODE>` | Ranking mode: growth (default — growth score desc, then impact/ confidence/effort) \| efficiency (impact score first) [default: growth] |
| `--horizon` | `<HORIZON>` | Sequencing horizon fallback used when no learning window is known, e.g. "14d" [default: 14d] |
| `--learning-window-days` | `<LEARNING_WINDOW_DAYS>` | Override the Meta learning-window default (7 days) used to evaluate `wait-for-status` sequencing |
| `--offline` |  | Skip every live ad-set learning-status read: every gated target resolves Unknown status (never assumed cleared) |
| `--out` | `<FILE>` | Path to write the merged plan-envelope-v2 JSON |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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
apb plan merge --from <FILE> --mode <MODE>
```

### `apb plan review-batch`

Review a batch of plans

**Scope:** `write:campaigns` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--ids` | `<IDS>` |  |
| `--account` | `<ACCOUNT>` |  |
| `--all` |  |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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
apb plan review-batch --ids <IDS> --plan <PATH>
```

### `apb plan validate`

Validate a plan without executing. `--plan-id` validates a stored plan (existing behavior); `--from-file` validates a plan-envelope-v2 file on disk without importing it into the state store — the read-only twin of `plan apply --from-file` (no `--execute` needed), and reports `wait-for-status` verdicts the same way (planning-001 sprint-m03)

**Scope:** `write:campaigns` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--plan-id` | `<PLAN_ID>` |  |
| `--spec-file` | `<SPEC_FILE>` |  |
| `--from-file` | `<FROM_FILE>` | Path to a plan-envelope-v2 JSON file (from `--plan`, `recipe build`, or `plan merge`). Mutually exclusive with `--plan-id` |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
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
