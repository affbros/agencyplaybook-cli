# `apb ad` — Command Reference

8 commands. Auto-generated from the apb binary on 2026-06-01.

### `apb ad create`

Create a new ad

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--adset` | `<ADSET>` |  |
| `--name` | `<NAME>` |  |
| `--creative-id` | `<CREATIVE_ID>` |  |
| `--status` | `<STATUS>` |  |
| `--spec` | `<SPEC>` |  |
| `--spec-file` | `<SPEC_FILE>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb ad create --execute --adset <ADSET> --name <NAME>
```

### `apb ad create-multi`

Create multiple ads in one ad set (one per creative)

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--adset` | `<ADSET>` |  |
| `--name` | `<NAME>` |  |
| `--creative-ids` | `<CREATIVE_IDS>` | Comma-separated creative IDs |
| `--status` | `<STATUS>` |  |
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
apb ad create-multi --execute --adset <ADSET> --name <NAME>
```

### `apb ad delete`

Hard-delete an ad via the Graph API `DELETE` verb (irreversible). Requires `--confirm-destructive`

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
apb ad delete --execute --confirm-destructive --id <ID>
```

### `apb ad get`

Get a single ad

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
apb ad get --id <ID>
```

### `apb ad list`

List ads

**Scope:** `read:campaigns` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--campaign` | `<CAMPAIGN>` |  |
| `--adset` | `<ADSET>` |  |
| `--limit` | `<LIMIT>` |  |
| `--status` | `<STATUS>` |  |
| `--after` | `<AFTER>` |  |
| `--all` |  |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb ad list --campaign <CAMPAIGN> --adset <ADSET>
```

### `apb ad preview`

Generate ad preview URL

**Scope:** `read:campaigns` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--format` | `<FORMAT>` | Preview format: DESKTOP_FEED_STANDARD, MOBILE_FEED_STANDARD, INSTAGRAM_STANDARD, RIGHT_COLUMN_STANDARD [default: DESKTOP_FEED_STANDARD] |
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
apb ad preview --id <ID> --format <FORMAT>
```

### `apb ad update`

Update ad settings

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--creative-id` | `<CREATIVE_ID>` |  |
| `--name` | `<NAME>` |  |
| `--status` | `<STATUS>` |  |
| `--tracking-specs` | `<TRACKING_SPECS>` | Raw JSON array of tracking spec objects, e.g. `[{"action.type":["offsite_conversion"],"fb_pixel":["123"]}]` |
| `--display-sequence` | `<DISPLAY_SEQUENCE>` | Display order within an ad set; lower fires first |
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
apb ad update --execute --id <ID> --creative-id <CREATIVE_ID>
```

### `apb ad update-status`

Update ad status

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--status` | `<STATUS>` |  |
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
apb ad update-status --execute --id <ID> --status <STATUS>
```
