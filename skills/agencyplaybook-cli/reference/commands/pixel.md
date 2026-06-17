# `apb pixel` — Command Reference

19 commands. Auto-generated from the apb binary on 2026-06-17.

### `apb pixel audience-create`

Create website custom audience from pixel rules

**Scope:** `read:pixels` · **Min tier:** professional · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--pixel-id` | `<PIXEL_ID>` |  |
| `--name` | `<NAME>` |  |
| `--rule` | `<RULE>` | JSON rule for audience (inclusion/exclusion rules) |
| `--retention-days` | `<RETENTION_DAYS>` |  |
| `--prefill` | `<PREFILL>` | [possible values: true, false] |
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
apb pixel audience-create --execute --pixel-id <PIXEL_ID> --name <NAME>
```

### `apb pixel create`

Create a new pixel

**Scope:** `read:pixels` · **Min tier:** professional · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--name` | `<NAME>` |  |
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
apb pixel create --execute --name <NAME>
```

### `apb pixel diagnostics`

Diagnostics (da_checks)

**Scope:** `read:pixels` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--checks` | `<CHECKS>` | Checks to run: pixel_missing_param_in_events, pixel_decline |
| `--connection-method` | `<CONNECTION_METHOD>` | Connection method: ALL, APP, BROWSER, SERVER |
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
apb pixel diagnostics --id <ID> --checks <CHECKS>
```

### `apb pixel events`

Event breakdown

**Scope:** `read:pixels` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--pixel-id` | `<PIXEL_ID>` |  |
| `--days` | `<DAYS>` |  |
| `--aggregation` | `<AGGREGATION>` | Aggregation type (default: event) |
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
apb pixel events --pixel-id <PIXEL_ID> --days <DAYS>
```

### `apb pixel get`

Get pixel details

**Scope:** `read:pixels` · **Min tier:** professional

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
apb pixel get --id <ID>
```

### `apb pixel health`

Health assessment for all pixels

**Scope:** `read:pixels` · **Min tier:** professional

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
apb pixel health
```

### `apb pixel list`

List pixels for the ad account

**Scope:** `read:pixels` · **Min tier:** professional

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
apb pixel list
```

### `apb pixel quality`

Quality score (6-check assessment)

**Scope:** `read:pixels` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--pixel-id` | `<PIXEL_ID>` |  |
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
apb pixel quality --pixel-id <PIXEL_ID>
```

### `apb pixel send-batch`

Send batch events from a JSON file (CAPI)

**Scope:** `read:pixels` · **Min tier:** professional · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--pixel-id` | `<PIXEL_ID>` |  |
| `--file` | `<FILE>` |  |
| `--test-event-code` | `<TEST_EVENT_CODE>` |  |
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
apb pixel send-batch --execute --pixel-id <PIXEL_ID> --file <FILE>
```

### `apb pixel send-event`

Send a single server-side event (CAPI)

**Scope:** `read:pixels` · **Min tier:** professional · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--pixel-id` | `<PIXEL_ID>` |  |
| `--event-name` | `<EVENT_NAME>` |  |
| `--action-source` | `<ACTION_SOURCE>` | [default: website] |
| `--email` | `<EMAIL>` |  |
| `--phone` | `<PHONE>` |  |
| `--event-id` | `<EVENT_ID>` |  |
| `--event-source-url` | `<EVENT_SOURCE_URL>` |  |
| `--event-time` | `<EVENT_TIME>` |  |
| `--test-event-code` | `<TEST_EVENT_CODE>` |  |
| `--value` | `<VALUE>` | Purchase value |
| `--currency` | `<CURRENCY>` | Currency code (e.g. USD) |
| `--contents` | `<CONTENTS>` | `custom_data.contents[]` as a JSON array, e.g. `[{"id":"SKU1","quantity":2,"item_price":9.99}]`. Drives value/ROAS optimization |
| `--content-category` | `<CONTENT_CATEGORY>` | `custom_data.content_category` |
| `--predicted-ltv` | `<PREDICTED_LTV>` | `custom_data.predicted_ltv` — predicted lifetime value for value-based optimization |
| `--lead-id` | `<LEAD_ID>` | `user_data.lead_id` — closes the leadgen → offline-conversion loop |
| `--subscription-id` | `<SUBSCRIPTION_ID>` | `user_data.subscription_id` |
| `--fb-login-id` | `<FB_LOGIN_ID>` | `user_data.fb_login_id` |
| `--external-id` | `<EXTERNAL_ID>` | `user_data.external_id` — your own user/customer ID (sent as provided; Meta accepts it hashed or plain — pre-hash it yourself if desired) |
| `--client-ip` | `<CLIENT_IP>` | `user_data.client_ip_address` (unhashed) |
| `--client-user-agent` | `<CLIENT_USER_AGENT>` | `user_data.client_user_agent` (unhashed) |
| `--fbc` | `<FBC>` | `user_data.fbc` click ID (unhashed) |
| `--fbp` | `<FBP>` | `user_data.fbp` browser ID (unhashed) |
| `--first-name` | `<FIRST_NAME>` | `user_data.fn` first name (hashed) |
| `--last-name` | `<LAST_NAME>` | `user_data.ln` last name (hashed) |
| `--ldu` |  | Limited Data Use (CCPA): sets `data_processing_options=["LDU"]` |
| `--dpo-country` | `<DPO_COUNTRY>` | LDU country (`0` = auto-geolocate). Implies --ldu |
| `--dpo-state` | `<DPO_STATE>` | LDU state (`0` = auto; `1000` = California). Implies --ldu |
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
apb pixel send-event --execute --pixel-id <PIXEL_ID> --event-name <EVENT_NAME>
```

### `apb pixel share`

Share pixel with another ad account

**Scope:** `read:pixels` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--account-id` | `<ACCOUNT_ID>` |  |
| `--business-id` | `<BUSINESS_ID>` |  |
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
apb pixel share --id <ID> --account-id <ACCOUNT_ID>
```

### `apb pixel shared-accounts`

List ad accounts a pixel is shared with

**Scope:** `read:pixels` · **Min tier:** professional

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
apb pixel shared-accounts --id <ID>
```

### `apb pixel shared-agencies`

List agencies a pixel is shared with

**Scope:** `read:pixels` · **Min tier:** professional

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
apb pixel shared-agencies --id <ID>
```

### `apb pixel signal`

Signal strength analysis

**Scope:** `read:pixels` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--pixel-id` | `<PIXEL_ID>` |  |
| `--days` | `<DAYS>` | [default: 30] |
| `--event` | `<EVENT>` | Filter by event name (e.g. Purchase) |
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
apb pixel signal --pixel-id <PIXEL_ID> --days <DAYS>
```

### `apb pixel stats`

Pixel stats with aggregation type

**Scope:** `read:pixels` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--aggregation` | `<AGGREGATION>` | Aggregation type: event, pixel_fire, event_total_counts, host, url, browser_type, device_os, device_type, custom_data_field [default: event] |
| `--days` | `<DAYS>` |  |
| `--event-source` | `<EVENT_SOURCE>` | Filter by event source: WEB_ONLY or SERVER_ONLY |
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
apb pixel stats --id <ID> --aggregation <AGGREGATION>
```

### `apb pixel unshare`

Unshare pixel from an ad account

**Scope:** `read:pixels` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--account-id` | `<ACCOUNT_ID>` |  |
| `--business-id` | `<BUSINESS_ID>` |  |
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
apb pixel unshare --id <ID> --account-id <ACCOUNT_ID>
```

### `apb pixel update`

Update pixel settings

**Scope:** `read:pixels` · **Min tier:** professional · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--name` | `<NAME>` |  |
| `--enable-auto-matching` | `<ENABLE_AUTO_MATCHING>` | [possible values: true, false] |
| `--matching-fields` | `<MATCHING_FIELDS>` | Comma-separated matching fields: em,ph,fn,ln,ge,zp,ct,st,country,db,external_id |
| `--data-use-setting` | `<DATA_USE_SETTING>` | Data use setting: EMPTY, ADVERTISING_AND_ANALYTICS, ANALYTICS_ONLY |
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
apb pixel update --execute --id <ID> --name <NAME>
```

### `apb pixel users`

Assigned users for a pixel

**Scope:** `read:pixels` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--business-id` | `<BUSINESS_ID>` |  |
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
apb pixel users --id <ID> --business-id <BUSINESS_ID>
```

### `apb pixel validate-events`

Validate events locally (no API call)

**Scope:** `read:pixels` · **Min tier:** professional

| Flag | Value | Description |
|---|---|---|
| `--file` | `<FILE>` |  |
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
apb pixel validate-events --file <FILE>
```
