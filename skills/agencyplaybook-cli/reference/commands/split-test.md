# `apb split-test` — Command Reference

4 commands. Auto-generated from the apb binary on 2026-05-22.

### `apb split-test create`

Create a new A/B split test from source adsets/ads

**Scope:** `admin:split-test` · **Min tier:** enterprise · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--name` | `<NAME>` |  |
| `--variant-a-adset` | `<VARIANT_A_ADSET>` |  |
| `--variant-a-ad` | `<VARIANT_A_AD>` |  |
| `--variant-b-adset` | `<VARIANT_B_ADSET>` |  |
| `--variant-b-ad` | `<VARIANT_B_AD>` |  |
| `--daily-budget` | `<DAILY_BUDGET>` | [default: 5] |
| `--objective` | `<OBJECTIVE>` | [default: OUTCOME_SALES] |
| `--hypothesis` | `<HYPOTHESIS>` |  |
| `--duration-days` | `<DURATION_DAYS>` | [default: 7] |
| `--launch-now` |  |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb split-test create --execute --name <NAME> --variant-a-adset <VARIANT_A_ADSET>
```

### `apb split-test evaluate`

Evaluate split test winner from ad insights

**Scope:** `admin:split-test` · **Min tier:** enterprise

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--days` | `<DAYS>` | [default: 7] |
| `--kpi` | `<KPI>` | [default: purchase] |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb split-test evaluate --id <ID> --days <DAYS>
```

### `apb split-test promote`

Promote winner variant and pause loser

**Scope:** `admin:split-test` · **Min tier:** enterprise · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--winner` | `<WINNER>` |  |
| `--scale` | `<SCALE>` | [default: 1.5] |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb split-test promote --execute --id <ID> --winner <WINNER>
```

### `apb split-test status`

Inspect current status of a split test

**Scope:** `admin:split-test` · **Min tier:** enterprise

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb split-test status --id <ID>
```
