# `apb adset` — Command Reference

8 commands. Auto-generated from the apb binary on 2026-06-05.

### `apb adset create`

Create a new ad set

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--campaign` | `<CAMPAIGN>` |  |
| `--name` | `<NAME>` |  |
| `--optimization-goal` | `<OPTIMIZATION_GOAL>` |  |
| `--billing-event` | `<BILLING_EVENT>` |  |
| `--daily-budget` | `<DAILY_BUDGET>` |  |
| `--lifetime-budget` | `<LIFETIME_BUDGET>` |  |
| `--bid-amount` | `<BID_AMOUNT>` |  |
| `--bid-strategy` | `<BID_STRATEGY>` |  |
| `--pacing-type` | `<PACING_TYPE>` |  |
| `--targeting` | `<TARGETING>` |  |
| `--spec-file` | `<SPEC_FILE>` |  |
| `--advantage-audience` | `<ADVANTAGE_AUDIENCE>` | Advantage audience (0 = off, 1 = on). Meta requires this on ad-set create; defaults to 0 when omitted. Overrides any value in the targeting spec |
| `--start-time` | `<START_TIME>` |  |
| `--end-time` | `<END_TIME>` |  |
| `--promoted-object` | `<PROMOTED_OBJECT>` |  |
| `--adset-schedule` | `<ADSET_SCHEDULE>` | Dayparting: explicit Meta `adset_schedule` as inline JSON or a file path |
| `--daypart-hours` | `<DAYPART_HOURS>` | Dayparting builder: comma-separated hours 0-23 (e.g. "9,12,16,19,21"). Consecutive hours merge into windows; built into `adset_schedule` (requires a lifetime budget). Overridden by --adset-schedule |
| `--daypart-days` | `<DAYPART_DAYS>` | Days for --daypart-hours: comma-separated 0-6 (0=Sunday). Default all 7 |
| `--daypart-timezone` | `<DAYPART_TIMEZONE>` | Timezone for --daypart-hours: USER (viewer) or ADVERTISER. Default USER |
| `--destination-type` | `<DESTINATION_TYPE>` | Conversion/traffic destination: WEBSITE, APP, MESSENGER, INSTAGRAM_DIRECT, WHATSAPP, ON_AD, ON_POST. Required for click-to-message / app objectives |
| `--dynamic-creative` |  | Enable Dynamic Creative (DCO) — required for asset_feed_spec creatives |
| `--attribution-spec` | `<ATTRIBUTION_SPEC>` | Per-ad-set attribution windows as inline JSON, e.g. `[{"event_type":"CLICK_THROUGH","window_days":7},{"event_type":"VIEW_THROUGH","window_days":1}]` |
| `--dsa-beneficiary` | `<DSA_BENEFICIARY>` | EU DSA: beneficiary of the ads (required for EU-targeted delivery) |
| `--dsa-payor` | `<DSA_PAYOR>` | EU DSA: payor for the ads (required for EU-targeted delivery) |
| `--advantage-detailed-targeting` |  | Advantage+ detailed-targeting expansion (lets Meta expand beyond your detailed-targeting selections). Sets targeting_automation.advantage_audience=1 |
| `--advantage-lookalike` |  | Advantage+ lookalike expansion → targeting.targeting_relaxation.lookalike=1 |
| `--advantage-custom-audience` |  | Advantage+ custom-audience expansion → targeting.targeting_relaxation.custom_audience=1 |
| `--bid-constraints` | `<BID_CONSTRAINTS>` | Bid/ROAS constraints JSON, e.g. `{"roas_average_floor":12000}`. Required when --bid-strategy is LOWEST_COST_WITH_MIN_ROAS |
| `--countries` | `<COUNTRIES>` | Country codes (ISO-2), comma-separated, e.g. `US,CA` |
| `--regions` | `<REGIONS>` | Region keys (from `apb targeting geo-search`), comma-separated |
| `--cities` | `<CITIES>` | City keys (from `apb targeting geo-search`), comma-separated |
| `--exclude-countries` | `<EXCLUDE_COUNTRIES>` | Excluded country codes, comma-separated |
| `--age-min` | `<AGE_MIN>` |  |
| `--age-max` | `<AGE_MAX>` |  |
| `--genders` | `<GENDERS>` | Genders: comma-separated `1` (male) / `2` (female). Omit for all |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--interests` | `<INTERESTS>` | Interest IDs or names (names resolved via interest search), comma-separated |
| `--behaviors` | `<BEHAVIORS>` | Behavior IDs, comma-separated |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--exclude-interests` | `<EXCLUDE_INTERESTS>` | Excluded interest IDs, comma-separated |
| `--custom-audiences` | `<CUSTOM_AUDIENCES>` | Custom-audience IDs to include, comma-separated |
| `--exclude-custom-audiences` | `<EXCLUDE_CUSTOM_AUDIENCES>` | Custom-audience IDs to exclude, comma-separated |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--locales` | `<LOCALES>` | Locale IDs, comma-separated |
| `--device-platforms` | `<DEVICE_PLATFORMS>` | Device platforms: `mobile`,`desktop` |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--user-os` | `<USER_OS>` | User OS: `iOS`,`Android` |
| `--extra-fields` | `<EXTRA_FIELDS>` | Escape hatch: raw JSON object merged into the create body for Meta fields apb doesn't expose. Bypasses validation; fails loud on collision |
| `--value-rule-set-ids` | `<VALUE_RULE_SET_IDS>` | Attach Value Rule sets (bid multipliers) — comma-separated value_rule_set IDs from `apb value-rule create`. Meta write-only param (not read back) |
| `--status` | `<STATUS>` |  |
| `--placements` | `<PLACEMENTS>` | Placement preset (v0.2.0). Expands into v25 publisher_platforms / facebook_positions / instagram_positions, merged into --targeting / --spec-file. Fails loud (exit 2) when the targeting JSON already sets any of those three keys. See `rust/docs/USAGE_GUIDE.md` § "Reels/Stories placement preset" [possible values: feed, stories, reels, stories-reels, feed-stories-reels, advantage-plus] |

```bash
apb adset create --execute --campaign <CAMPAIGN> --name <NAME>
```

### `apb adset delete`

Hard-delete an ad set via the Graph API `DELETE` verb (irreversible). Requires `--confirm-destructive`

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`) · **Destructive** (requires `--confirm-destructive`)

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--adset` | `<ADSET>` |  |
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
apb adset delete --execute --confirm-destructive --id <ID> --adset <ADSET>
```

### `apb adset get`

Get a single ad set

**Scope:** `read:campaigns` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--adset` | `<ADSET>` |  |
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
apb adset get --id <ID> --adset <ADSET>
```

### `apb adset list`

List ad sets

**Scope:** `read:campaigns` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--campaign` | `<CAMPAIGN>` |  |
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
apb adset list --campaign <CAMPAIGN> --limit <LIMIT>
```

### `apb adset update`

Generic ad-set update — change any subset of mutable fields in one call. Use the targeted shortcuts (`update-budget`, `update-targeting`, `update-status`) when only one field changes

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--adset` | `<ADSET>` |  |
| `--name` | `<NAME>` |  |
| `--optimization-goal` | `<OPTIMIZATION_GOAL>` |  |
| `--billing-event` | `<BILLING_EVENT>` |  |
| `--bid-strategy` | `<BID_STRATEGY>` |  |
| `--bid-amount` | `<BID_AMOUNT>` | In dollars (converted to cents) |
| `--pacing-type` | `<PACING_TYPE>` |  |
| `--start-time` | `<START_TIME>` | ISO 8601, e.g. `2026-05-01T00:00:00-0700` |
| `--end-time` | `<END_TIME>` |  |
| `--promoted-object` | `<PROMOTED_OBJECT>` | Raw JSON for `promoted_object`, e.g. `{"pixel_id":"123","custom_event_type":"PURCHASE"}` |
| `--adset-schedule` | `<ADSET_SCHEDULE>` | Dayparting: explicit Meta `adset_schedule` as inline JSON or a file path |
| `--daypart-hours` | `<DAYPART_HOURS>` | Dayparting builder: comma-separated hours 0-23 (e.g. "9,12,16,19,21"). Consecutive hours merge into windows; built into `adset_schedule` (requires a lifetime budget). Overridden by --adset-schedule |
| `--daypart-days` | `<DAYPART_DAYS>` | Days for --daypart-hours: comma-separated 0-6 (0=Sunday). Default all 7 |
| `--daypart-timezone` | `<DAYPART_TIMEZONE>` | Timezone for --daypart-hours: USER (viewer) or ADVERTISER. Default USER |
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
apb adset update --execute --id <ID> --adset <ADSET>
```

### `apb adset update-budget`

Update ad-set budget

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--adset` | `<ADSET>` |  |
| `--daily-budget` | `<DAILY_BUDGET>` |  |
| `--budget` | `<BUDGET>` |  |
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
apb adset update-budget --execute --id <ID> --adset <ADSET>
```

### `apb adset update-status`

Update ad-set status

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--adset` | `<ADSET>` |  |
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
apb adset update-status --execute --id <ID> --adset <ADSET>
```

### `apb adset update-targeting`

Update ad-set targeting

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--adset` | `<ADSET>` |  |
| `--spec` | `<SPEC>` |  |
| `--spec-file` | `<SPEC_FILE>` |  |
| `--placements` | `<PLACEMENTS>` | Placement preset (v0.2.0). Expands into v25 publisher_platforms / facebook_positions / instagram_positions, merged into the targeting JSON provided via --spec/--spec-file. Fails loud (exit 2) when the targeting JSON already sets any of those three keys [possible values: feed, stories, reels, stories-reels, feed-stories-reels, advantage-plus] |
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
apb adset update-targeting --execute --id <ID> --adset <ADSET>
```
