# `apb leadgen` — Command Reference

6 commands. Auto-generated from the apb binary on 2026-06-05.

### `apb leadgen ad-create`

End-to-end lead-form ad creation (v0.2.0). Validates the campaign objective is `OUTCOME_LEADS`, validates the form belongs to the page, creates a lead-form creative referencing `lead_gen_form_id`, then creates the ad attaching the creative to the ad set. Reverse-pauses on partial failure

**Scope:** `write:leadgen` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--name` | `<NAME>` |  |
| `--campaign` | `<CAMPAIGN>` |  |
| `--adset` | `<ADSET>` |  |
| `--form-id` | `<FORM_ID>` |  |
| `--page-id` | `<PAGE_ID>` | Override Page auto-discovery. Required when the user has multiple Pages |
| `--image` | `<IMAGE>` | Hero image hash or local file path |
| `--headline` | `<HEADLINE>` |  |
| `--body` | `<BODY>` |  |
| `--cta` | `<CTA>` | [default: SIGN_UP] |
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
apb leadgen ad-create --execute --name <NAME> --campaign <CAMPAIGN>
```

### `apb leadgen create`

Create a new leadgen form. Requires `--spec-file` containing the full form payload (questions, privacy_policy_url, etc.). See `docs/examples/leadgen-form-spec.json`

**Scope:** `write:leadgen` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--page-id` | `<PAGE_ID>` |  |
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

```bash
apb leadgen create --execute --page-id <PAGE_ID> --spec-file <SPEC_FILE>
```

### `apb leadgen get`

Get a single leadgen form's details

**Scope:** `read:leadgen` · **Min tier:** professional

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
apb leadgen get --id <ID>
```

### `apb leadgen leads`

List leads for a form (PII — requires `read:leadgen:export` scope). Includes `field_data` with submitter responses

**Scope:** `read:leadgen:export` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--form-id` | `<FORM_ID>` |  |
| `--since` | `<SINCE>` | Filter to leads created on/after this date (YYYY-MM-DD) |
| `--until` | `<UNTIL>` | Filter to leads created before this date (YYYY-MM-DD) |
| `--limit` | `<LIMIT>` |  |
| `--after` | `<AFTER>` |  |
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
apb leadgen leads --form-id <FORM_ID> --since <SINCE>
```

### `apb leadgen leads-export`

Bulk-export leads to CSV (default) or JSON, with optional pagination follow-loop. PII — requires `read:leadgen:export` scope

**Scope:** `read:leadgen:export` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--form-id` | `<FORM_ID>` |  |
| `--since` | `<SINCE>` |  |
| `--until` | `<UNTIL>` |  |
| `--output` | `<OUTPUT>` | Output file path. Defaults to stdout |
| `--format` | `<FORMAT>` | Output format: `csv` (default — CRM-friendly) or `json` [default: csv] |
| `--all` |  | Follow pagination cursors to fetch all pages |
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
apb leadgen leads-export --form-id <FORM_ID> --since <SINCE>
```

### `apb leadgen list`

List leadgen forms attached to a Page (auto-discovered if --page-id omitted)

**Scope:** `read:leadgen` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--page-id` | `<PAGE_ID>` |  |
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
apb leadgen list --page-id <PAGE_ID> --limit <LIMIT>
```
