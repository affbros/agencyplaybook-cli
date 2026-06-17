# `apb value-rule` — Command Reference

4 commands. Auto-generated from the apb binary on 2026-06-17.

### `apb value-rule create`

Create a value rule set. Build a single rule from flags (`--adjust`/`--adjust-value`/`--criteria-type`/`--values`) OR pass a full rules array via `--spec-file` for multi-rule / multi-criteria sets

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--name` | `<NAME>` | Rule set name |
| `--spec-file` | `<SPEC_FILE>` | Full `rules` JSON array (inline or path) — for complex sets. Mutually exclusive with the single-rule flags |
| `--adjust` | `<ADJUST>` | Single-rule: bid direction — `INCREASE` or `DECREASE` |
| `--adjust-value` | `<ADJUST_VALUE>` | Single-rule: magnitude as a percent (e.g. `20` = ±20%; Meta caps +1000% / -90%) |
| `--criteria-type` | `<CRITERIA_TYPE>` | Single-rule: criteria type — `OS_TYPE`, `LOCATION`, `AGE`, `GENDER`, `PLACEMENT`, `DEVICE_PLATFORM`, `CONVERSION_LOCATION`, `OMNI_CHANNEL`, `URL`, `AUDIENCE_LABEL` |
| `--operator` | `<OPERATOR>` | Single-rule: `CONTAINS` (default) or `DOES_NOT_CONTAIN` [default: CONTAINS] |
| `--values` | `<VALUES>` | Single-rule: comma-separated values (e.g. `IOS` for OS_TYPE — UPPERCASE; `US` for LOCATION). Required with the single-rule flags |
| `--value-types` | `<VALUE_TYPES>` | Single-rule: parallel value types per value — `LOCATION_COUNTRY`/`_REGION`/ `_CITY`/`_DMA`/`_COMSCORE_MARKET` or `NONE`. Defaults to `NONE` for each |
| `--rule-name` | `<RULE_NAME>` | Single-rule: optional rule name |
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
apb value-rule create --execute --name <NAME> --spec-file <SPEC_FILE>
```

### `apb value-rule delete`

Delete a value rule set (destructive — requires `--confirm-destructive`)

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`) · **Destructive** (requires `--confirm-destructive`)

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
apb value-rule delete --execute --confirm-destructive --id <ID>
```

### `apb value-rule list`

List value rule sets on the connected ad account

**Scope:** `read:campaigns` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--limit` | `<LIMIT>` |  |
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
apb value-rule list --limit <LIMIT>
```

### `apb value-rule show`

Show one value rule set and its rules

**Scope:** `read:campaigns` · **Min tier:** starter

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
apb value-rule show --id <ID>
```
