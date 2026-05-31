# `apb audience` — Command Reference

8 commands. Auto-generated from the apb binary on 2026-05-31.

### `apb audience create`

Create a custom audience

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--name` | `<NAME>` |  |
| `--subtype` | `<SUBTYPE>` |  |
| `--description` | `<DESCRIPTION>` |  |
| `--customer-file-source` | `<CUSTOMER_FILE_SOURCE>` |  |
| `--rule` | `<RULE>` | Raw Meta rule JSON. Mutual-exclusive with --engagement-source flags. Use this path for advanced filters like `video_view_percent >= 50` |
| `--retention-days` | `<RETENTION_DAYS>` |  |
| `--engagement-source` | `<ENGAGEMENT_SOURCE>` | Sprint 007: first-class engagement-audience builder. Valid: `page`, `video`, `post`, `event`, `lead_form`, `instagram_profile`. Pairs with --source-id; service builds the Meta rule JSON |
| `--source-id` | `<SOURCE_ID>` | ID of the engagement source (page_id, video_id, post_id, event_id, leadgen_form_id, or ig_business_id depending on --engagement-source) |
| `--value-based` |  | Value-based audience: sets `is_value_based=true`. Upload a value column (LTV/VALUE schema code) via `audience users-add` so Meta can build a value-based lookalike |
| `--prefill` |  | `prefill` — backfill a WEBSITE/pixel audience from existing pixel data |
| `--opt-out-link` | `<OPT_OUT_LINK>` | `opt_out_link` — privacy opt-out URL surfaced to users |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb audience create --execute --name <NAME> --subtype <SUBTYPE>
```

### `apb audience create-lookalike`

Create a lookalike audience

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--source` | `<SOURCE>` |  |
| `--country` | `<COUNTRY>` |  |
| `--ratio` | `<RATIO>` |  |
| `--name` | `<NAME>` |  |
| `--account` | `<ACCOUNT>` |  |
| `--starting-ratio` | `<STARTING_RATIO>` | Lower bound of a lookalike *range* (e.g. `0.01`); paired with --ratio as the upper bound |
| `--lookalike-type` | `<LOOKALIKE_TYPE>` | `similarity` (default) or `reach` |
| `--is-financial-service` |  | Mark the lookalike as a financial-services audience (regulated verticals) |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb audience create-lookalike --execute --source <SOURCE> --country <COUNTRY>
```

### `apb audience get`

Get a single custom audience

**Scope:** `read:audiences` · **Min tier:** professional

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
apb audience get --id <ID>
```

### `apb audience list`

List custom audiences

**Scope:** `read:audiences` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--limit` | `<LIMIT>` |  |
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
apb audience list --limit <LIMIT> --after <AFTER>
```

### `apb audience overlap`

Estimate audience overlap between custom audiences

**Scope:** `read:audiences` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--audience-ids` | `<AUDIENCE_IDS>` | Comma-separated audience IDs |
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
apb audience overlap --audience-ids <AUDIENCE_IDS>
```

### `apb audience share`

Share a custom audience with another ad account (same Business Manager). `POST /{audience_id}/adaccounts`. Requires `write:audience-data`

**Scope:** `write:audience-data` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--account` | `<ACCOUNT>` | Target ad account (`act_…` or numeric) to share the audience with |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb audience share --id <ID>
```

### `apb audience users-add`

Upload hashed PII to a customer-list audience. Plaintext rows from `--data-file` are normalized + SHA-256 hashed locally before transmit. Requires `write:audience-data` (Agency+)

**Scope:** `write:audience-data` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--schema` | `<SCHEMA>` | Comma-separated Meta schema field codes: EMAIL, PHONE, FN, LN, DOBY, DOBM, DOBD, GEN, CT, ST, ZIP, COUNTRY, MADID, EXTERN_ID, plus LTV / VALUE (value-based audiences — numeric, sent unhashed) |
| `--data-file` | `<DATA_FILE>` | Path to data file (CSV or JSON). One row per user; column count must match schema length |
| `--format` | `<FORMAT>` | `csv` (default — RFC 4180) or `json` (array of arrays) [default: csv] |
| `--skip-header` |  | Skip the first row of CSV (treat as header). Auto-detected when the first row matches the schema field codes |
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
apb audience users-add --execute --id <ID> --schema <SCHEMA>
```

### `apb audience users-remove`

Remove hashed PII from a customer-list audience. Same data-file shape as users-add. Requires `write:audience-data` (Agency+)

**Scope:** `write:audience-data` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--schema` | `<SCHEMA>` |  |
| `--data-file` | `<DATA_FILE>` |  |
| `--format` | `<FORMAT>` | [default: csv] |
| `--skip-header` |  |  |
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
apb audience users-remove --execute --id <ID> --schema <SCHEMA>
```
