# `apb report` — Command Reference

12 commands. Auto-generated from the apb binary on 2026-05-26.

### `apb report breakdown`

Pull insights with breakdowns

**Scope:** `read:reports` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--campaign` | `<CAMPAIGN>` |  |
| `--level` | `<LEVEL>` |  |
| `--days` | `<DAYS>` |  |
| `--limit` | `<LIMIT>` |  |
| `--breakdown-type` | `<BREAKDOWN_TYPE>` |  |
| `--time-increment` | `<TIME_INCREMENT>` | Granularity: 1 (daily), 7 (weekly), monthly, all_days |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb report breakdown --campaign <CAMPAIGN> --level <LEVEL>
```

### `apb report compare`

Compare metrics between two time periods

**Scope:** `read:reports:advanced` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--level` | `<LEVEL>` |  |
| `--days` | `<DAYS>` |  |
| `--compare-days` | `<COMPARE_DAYS>` | Days for comparison period (defaults to same as --days) |
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
apb report compare --level <LEVEL> --days <DAYS>
```

### `apb report insights`

Pull insights synchronously

**Scope:** `read:reports` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--campaign` | `<CAMPAIGN>` |  |
| `--adset` | `<ADSET>` |  |
| `--level` | `<LEVEL>` |  |
| `--days` | `<DAYS>` | Lookback window in days (default 30, min 1). Ignored when --since/--until are provided |
| `--limit` | `<LIMIT>` |  |
| `--time-start` | `<TIME_START>` | Explicit start date (YYYY-MM-DD or relative e.g. 30d). Use with --time-end / --until |
| `--time-end` | `<TIME_END>` | Explicit end date (YYYY-MM-DD or relative e.g. 0d for today) |
| `--attribution` | `<ATTRIBUTION>` |  |
| `--action-report-time` | `<ACTION_REPORT_TIME>` |  |
| `--use-account-attribution` | `<USE_ACCOUNT_ATTRIBUTION>` |  |
| `--compact` |  |  |
| `--time-increment` | `<TIME_INCREMENT>` | Granularity: 1 (daily), 7 (weekly), monthly, all_days |
| `--format` | `<FORMAT>` | Output format: json (default) or csv [default: json] |
| `--accounts` | `<ACCOUNTS>` | Run across multiple ad accounts (comma-separated or "all") |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb report insights --campaign <CAMPAIGN> --adset <ADSET>
```

### `apb report insights-async fetch`

Fetch completed async insights

**Scope:** `read:reports` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--job-id` | `<JOB_ID>` |  |
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
apb report insights-async fetch --job-id <JOB_ID> --limit <LIMIT>
```

### `apb report insights-async start`

Start an async insights job

**Scope:** `read:reports` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--campaign` | `<CAMPAIGN>` |  |
| `--level` | `<LEVEL>` |  |
| `--days` | `<DAYS>` |  |
| `--time-start` | `<TIME_START>` |  |
| `--time-end` | `<TIME_END>` |  |
| `--attribution` | `<ATTRIBUTION>` |  |
| `--time-increment` | `<TIME_INCREMENT>` | Granularity: 1 (daily), 7 (weekly), monthly, all_days |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb report insights-async start --campaign <CAMPAIGN> --level <LEVEL>
```

### `apb report insights-async status`

Check async insights job status

**Scope:** `read:reports` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--job-id` | `<JOB_ID>` |  |
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
apb report insights-async status --job-id <JOB_ID>
```

### `apb report metrics`

Pull insights with arbitrary metric fields

**Scope:** `read:reports` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--level` | `<LEVEL>` |  |
| `--days` | `<DAYS>` | Lookback window in days (default 30). Ignored when --since/--until are provided |
| `--metrics` | `<METRICS>` |  |
| `--breakdowns` | `<BREAKDOWNS>` |  |
| `--limit` | `<LIMIT>` |  |
| `--attribution` | `<ATTRIBUTION>` |  |
| `--action-report-time` | `<ACTION_REPORT_TIME>` |  |
| `--use-account-attribution` | `<USE_ACCOUNT_ATTRIBUTION>` |  |
| `--time-start` | `<TIME_START>` | Explicit start date (YYYY-MM-DD or relative e.g. 30d). Use with --time-end / --until |
| `--time-end` | `<TIME_END>` | Explicit end date (YYYY-MM-DD or relative e.g. 0d for today) |
| `--time-increment` | `<TIME_INCREMENT>` | Granularity: 1 (daily), 7 (weekly), monthly, all_days |
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
apb report metrics --level <LEVEL> --days <DAYS>
```

### `apb report presets list`

List available report presets

**Scope:** `read:reports` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
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
apb report presets list
```

### `apb report presets run`

Run a preset by name

**Scope:** `read:reports` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--name` | `<NAME>` |  |
| `--level` | `<LEVEL>` |  |
| `--days` | `<DAYS>` |  |
| `--limit` | `<LIMIT>` |  |
| `--time-increment` | `<TIME_INCREMENT>` | Granularity: 1 (daily), 7 (weekly), monthly, all_days |
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
apb report presets run --name <NAME> --level <LEVEL>
```

### `apb report profile list`

List saved report profiles

**Scope:** `read:reports` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
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
apb report profile list
```

### `apb report profile run`

Run a saved profile

**Scope:** `read:reports` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--name` | `<NAME>` |  |
| `--days` | `<DAYS>` |  |
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
apb report profile run --name <NAME> --days <DAYS>
```

### `apb report profile save`

Save a report profile

**Scope:** `read:reports` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--name` | `<NAME>` |  |
| `--level` | `<LEVEL>` |  |
| `--metrics` | `<METRICS>` |  |
| `--breakdowns` | `<BREAKDOWNS>` |  |
| `--attribution` | `<ATTRIBUTION>` |  |
| `--action-report-time` | `<ACTION_REPORT_TIME>` |  |
| `--use-account-attribution` | `<USE_ACCOUNT_ATTRIBUTION>` |  |
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
apb report profile save --name <NAME> --level <LEVEL>
```
