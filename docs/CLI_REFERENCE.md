# CLI Reference

Command reference for `apb` (Rust). **30 command domains, 226 leaf commands** (verified 2026-04-27 via `tasks/ci/api-parity/baseline.json`).

> **Doc currency**: Headline counts match the parity baseline. The per-command sections below were last fully audited prior to campaign-management-completion (S001–S008, 2026-04-25 → 2026-04-26), which added ~40 leaves across `catalog`, `product-set`, `custom-conversion`, `leadgen`, `audience users-add/users-remove`, `account instagram-accounts/instagram-media`, `creative create-collection`, plus generic `adset update` and the `--special-ad-categories` / `--objective` enum flags on campaign create. **Those new commands are NOT yet documented here** — see the workstream summary at `../ai/evals/campaign-management-completion/workstream-summary.md` for the full list. Run `apb --help` and `apb <domain> --help` for current authoritative usage.

---

## Global Flags

These flags are available on every command. For unattended / CI / AI-agent usage, see [`docs/CLI_AUTOMATION.md`](../../docs/CLI_AUTOMATION.md).

| Flag | Type | Description |
|------|------|-------------|
| `--json` | bool | Output as machine-readable JSON (default: human-readable table) |
| `--execute` | bool | Apply changes to the Meta API (required for all writes) |
| `--dry-run` | bool | Preview only, never mutate (informational — writes are dry-run by default) |
| `--confirm-destructive` | bool | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | string | Target a specific ad account (overrides default). Format: `act_XXXXXXXXX` |
| `--no-input` | bool | Promise that the CLI will never prompt. Required for CI/cron/agent execution. Does **not** imply approval — mutations still need `--execute`. |
| `--debug` | bool | Enable debug-level tracing to stderr. Honors `RUST_LOG` if already set. Token / OAuth secrets are sanitized before logging. |
| `--no-color` | bool | Disable ANSI color in output. Also honors `NO_COLOR=1` and `CLICOLOR=0` env vars. |

### Exit Codes

Every failure maps to a documented exit code. See [`docs/CLI_AUTOMATION.md`](../../docs/CLI_AUTOMATION.md) for the full table and CI examples.

| Code | Meaning |
|---:|---|
| 0 | Success |
| 1 | General / unmapped |
| 2 | Validation / invalid input |
| 3 | Auth / permission |
| 4 | Safety gate blocked (missing `--execute`, `--confirm-destructive`, or `--no-input` blocking a prompt) |
| 5 | Network / rate-limit / 5xx |
| 6 | Reserved (partial success) |

### Name-Based ID Resolution

All `--id`, `--campaign`, and `--adset` parameters accept names in addition to numeric IDs:

| Input Format | Resolution | Example |
|-------------|------------|---------|
| Numeric ID | Used directly (no API call) | `--id 120239538597430265` |
| `@alias` | Looked up from `~/.apb/config.json` aliases | `--id @retarget` |
| `"auto"` | Auto-discovers singleton (page_id, pixel_id only) | `--page-id auto` |
| Name string | Searched via Meta API — requires exactly 1 match | `--id "Retargeting – Visitors 180d"` |

If a name matches multiple entities, a disambiguation list is shown with IDs and names.

---

## 1. auth

Authentication helpers — token validation, SaaS login, API key management, and ad account binding.

### `auth test`

Test the access token, list scopes, user identity, and linked ad accounts.

```
apb auth test [--json]
```

**API calls:** `GET /debug_token`, `GET /me`, `GET /me/adaccounts`

**Output fields:**
- `token_present`, `is_valid`, `app_id`, `expires_at`
- `scopes[]` — granted permission scopes
- `user` — `{id, name, email}`
- `ad_accounts[]` — `{id, name, status}`

### `auth login`

Log in with a SaaS API key. Stores credentials locally for subsequent commands.

```
apb auth login --api-key <apb_live_...|apb_test_...> [--api-url <url>] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--api-key` | string | required | API key (`apb_live_...` or `apb_test_...`) |
| `--api-url` | string | `https://api.agencyplaybook.io` (release builds) or `http://localhost:3750` (local `cargo build`) | API server URL. Overridable via `APB_API_URL` env var. |

### `auth status`

Show current plan, tier, scopes, and usage for the logged-in SaaS key. Composites data from two API endpoints (`GET /api/v1/auth/plan` + `GET /api/v1/auth/usage`) into a single view.

```
apb auth status [--json]
```

> **Auth requirement:** this command hits the SaaS auth endpoints (port 3750), not the Meta Graph API. With an `apb_live_*` API key it returns `401 Invalid API key` — pass a session token via `APB_SESSION_TOKEN`, or use `apb auth test` for an API-key-mode liveness probe instead.

### `auth connect-meta`

Connect a Meta account via the OAuth device flow. Opens a browser for consent, then polls the SaaS callback until the user finishes.

```
apb auth connect-meta [--long-lived-user] [--timeout <sec>] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--long-lived-user` | bool | false | Use the 60-day long-lived-user token flow instead of the system-user default. Pairs with the `refresh-meta-tokens` cron on the SaaS side. |
| `--timeout` | u32 | `300` | Maximum seconds to wait for the browser flow to complete |

The CLI mints state via `POST /api/v1/saas/auth/meta/device-init` and polls `GET /api/v1/saas/auth/meta/device-status?device_code=…` until the callback completes. Default mode (`system_user`) uses the Facebook Login for Business `META_LOGIN_CONFIG_ID`. See `ai/specs/oauth/` for the broader OAuth runtime.

### `auth keys list`

List all API keys (masked) for the current tenant.

```
apb auth keys list [--json]
```

### `auth keys create`

Create a new API key.

```
apb auth keys create [--label <label>] [--json]
```

### `auth keys rotate`

Rotate an API key (24-hour grace period for the old key).

```
apb auth keys rotate --id <key_id> [--json]
```

### `auth keys revoke`

Revoke an API key immediately.

```
apb auth keys revoke --id <key_id> [--json]
```

### `auth accounts list`

List ad accounts bound to your API key.

```
apb auth accounts list [--json]
```

### `auth accounts add`

Bind an ad account to your API key.

```
apb auth accounts add --account <act_123456> [--json]
```

### `auth accounts remove`

Unbind an ad account from your API key.

```
apb auth accounts remove --account <act_123456> [--json]
```

---

## 2. doctor

Environment and API diagnostics.

### `doctor check`

Run all diagnostic checks: token validity, required scopes, ad account discovery, write gate state.

```
apb doctor check [--json]
```

**Checks performed:**
1. `token_present` — META_ACCESS_TOKEN is set
2. `token_valid` — Token passes `debug_token` validation
3. `scope_ads_read` — `ads_read` scope granted
4. `scope_ads_management` — `ads_management` scope granted
5. `ad_account` — At least one ad account discoverable
6. `write_gates` — READ_ONLY, ALLOW_WRITES, APB_ALLOW_MUTATIONS state

### `doctor api-compat`

Canary checks for API endpoint and field compatibility.

```
apb doctor api-compat [--json]
```

**Probes (8):**
- `insights_endpoint` — Standard fields return data
- `attribution_windows` — `action_attribution_windows` parameter accepted
- `async_insights` — POST insights creates async report
- `delivery_estimate` — Reach estimation endpoint reachable
- `campaigns_fields` — Campaign list returns `id,name,status,objective`
- `adsets_fields` — Adset list returns expected fields
- `breakdowns_param` — `age,gender` breakdown accepted
- `graph_api_version` — Current version is reachable

### `doctor quota`

API usage pressure report from rate-limit headers.

```
apb doctor quota [--json]
```

**Output:**
- `pressure_score` — 0-100 peak across `x-app-usage`, `x-page-usage`, `x-ad-account-usage`
- `status` — `low` (<25), `moderate` (25-49), `high` (50-79), `critical` (80+)
- `recommended_min_delay_ms` — Suggested delay between heavy requests
- `recommended_batch_size` — Suggested concurrent request limit

### `doctor validate-only-matrix`

Probe which write actions support `execution_options: ['validate_only']`.

```
apb doctor validate-only-matrix [--json]
```

**Probes (6):**
- `campaign.update-status`, `ad.update-status`, `adset.update-budget`
- `adset.update-advantage`, `creative.create-image`, `ad.create`

**Result classifications:** `SUPPORTED`, `NOT_SUPPORTED`, `LIKELY_SUPPORTED`, `INCONCLUSIVE`, `INCONCLUSIVE_RATE_LIMIT`, `INCONCLUSIVE_AUTH`

---

## 3. account

Ad account information and local-config helpers.

### `account list`

List all accessible ad accounts with names. Useful right after `auth connect-meta` to see what the connected user can administer.

```
apb account list [--json]
```

Returns `{id, name, account_status, currency, timezone_name}` per account. Source: `GET /me/adaccounts` filtered to accounts the connected user owns or has agency access to.

### `account set-default`

Set the default ad account for subsequent CLI commands. Writes to `~/.apb/config.json::default_account`. Subsequent commands without `--account` use this value before falling back to env-var or auto-discovery.

```
apb account set-default --account <act_xxxxx> [--json]
```

| Flag | Type | Description |
|------|------|-------------|
| `--account` | string | Account ID (must include the `act_` prefix) |

This is a local-only operation — no API call. Pair with `apb account list` to discover the right ID.

### `account overview`

Account metadata with campaign status counts.

```
apb account overview [--account act_xxx] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--account` | string | auto-discovered | Ad account ID |

**API call:** `GET /{account}` + `GET /{account}/campaigns`

**Fields returned:** id, name, status, currency, timezone, business_name, amount_spent, balance, campaign_count, campaign_statuses

### `account pages`

List pages the user or business manages.

```
apb account pages [--account act_xxx|me] [--json]
```

**API call:** `GET /me/accounts` or `GET /{account}/promote_pages`

### `account info-detailed`

Extended account info: funding, TOS, caps, business address.

```
apb account info-detailed [--account act_xxx] [--json]
```

**Account status codes:** 1=ACTIVE, 2=DISABLED, 3=UNSETTLED, 7=PENDING_RISK_REVIEW, 8=PENDING_SETTLEMENT, 9=IN_GRACE_PERIOD, 100=PENDING_CLOSURE, 101=CLOSED

### `account instagram-accounts` (Sprint 007)

List Instagram accounts visible to a connected Facebook Page. Useful for resolving `instagram_actor_id` when building IG-specific creatives, or for finding the IG account ID to use as an engagement-audience source.

```
apb account instagram-accounts [--page-id <id>] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--page-id` | string | auto | Auto-discovered via `discover_page_id()` if omitted; errors if 0 or >1 pages |

Returns `{id, username, name, profile_pic, followers_count}` per IG account. Empty array is a valid response (Page has no linked IG accounts).

**Required scope**: `read:coverage` (Starter+). Every tier should be able to discover their own IG account linkages.

### `account instagram-media` (Sprint 007)

List media (posts, reels, stories) on an Instagram account. Useful for finding `media_id` to use as a `--source-id` value when building post-engagement or video-engagement audiences via `apb audience create --engagement-source video`.

```
apb account instagram-media --ig-id <ig_account_id> [--limit <n>] [--json]
```

Returns `{id, caption, media_type, media_url, permalink, timestamp}` per media item. `--limit` defaults to 25.

---

## 4. campaign

Campaign CRUD and helpers.

### `campaign list`

```
apb campaign list [--account act_xxx] [--limit N] [--status STATUS] [--since DATE] [--until DATE] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--limit` | u32 | 25 | Max campaigns to return |
| `--account` | string | auto | Ad account override |
| `--status` | string | — | Filter by effective status (e.g. `ACTIVE`, `PAUSED`) |
| `--since` | string | — | Show campaigns created or modified on/after this date (`YYYY-MM-DD` or relative e.g. `30d`) |
| `--until` | string | — | Show campaigns created or modified on/before this date (`YYYY-MM-DD` or relative e.g. `7d`) |

**API fields:** id, name, status, objective, daily_budget, created_time, updated_time

**Examples:**
```bash
apb campaign list --since 30d --json          # Last 30 days
apb campaign list --since 2026-03-01 --until 2026-03-31  # March 2026
apb campaign list --since 7d --status ACTIVE   # Active in last week
```

### `campaign get`

```
apb campaign get --id <campaign_id> [--json]
```

**API fields:** id, name, status, effective_status, objective, daily_budget, lifetime_budget, budget_remaining, bid_strategy, buying_type, special_ad_categories, start_time, stop_time, created_time, updated_time

### `campaign create` (WRITE)

```
apb campaign create --name <name> --objective <ODAX_ENUM> [--status PAUSED] [--daily-budget <usd>] [--lifetime-budget <usd>] [--bid-strategy <strategy>] [--buying-type <type>] [--special-ad-categories <CSV>] [--spec-file <campaign.json>] [--execute] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--name` | string | required | Campaign name |
| `--objective` | enum | required | One of: `OUTCOME_AWARENESS`, `OUTCOME_TRAFFIC`, `OUTCOME_ENGAGEMENT`, `OUTCOME_LEADS`, `OUTCOME_APP_PROMOTION`, `OUTCOME_SALES`. Validated by clap; typos fail at the CLI before any HTTP call. |
| `--status` | string | `PAUSED` | Initial status |
| `--daily-budget` | f64 | — | Daily budget in USD (mutually exclusive with `--lifetime-budget`) |
| `--lifetime-budget` | f64 | — | Lifetime budget in USD |
| `--bid-strategy` | string | — | Bid strategy (`LOWEST_COST_WITHOUT_CAP`, `COST_CAP`, `BID_CAP`) |
| `--buying-type` | string | — | Buying type (`AUCTION` or `RESERVED`) |
| `--special-ad-categories` | CSV | — | Required by Meta for housing/credit/employment/social-issue verticals. Comma-separated, e.g. `--special-ad-categories HOUSING,CREDIT`. Serialized as a JSON array to Meta. |
| `--spec-file` | string | — | JSON spec file (CLI flags override spec values). `special_ad_categories` in the spec accepts both array and CSV-string form. |

DRY-RUN by default. Requires all 4 write gates open.

### `campaign update-status` (WRITE)

```
apb campaign update-status --id <id> --status <PAUSED|ACTIVE|DELETED|ARCHIVED> [--execute] [--confirm-destructive] [--json]
```

**Valid statuses:** `PAUSED`, `ACTIVE`, `DELETED`, `ARCHIVED`. `DELETED` and `ARCHIVED` transitions require `--confirm-destructive`.

### `campaign delete` (WRITE, IRREVERSIBLE)

```
apb campaign delete --id <id> --execute --confirm-destructive [--json]
```

Hard-deletes the campaign via the Graph API `DELETE /{id}` verb. Terminal state (`status=DELETED`) — cannot be reactivated. Cascades to all child ad sets and ads. Requires both `--execute` and `--confirm-destructive`. Use `update-status --status ARCHIVED` if you want a reversible cleanup instead.

**Example:**
```bash
apb campaign delete --id 120241514062480265 --execute --confirm-destructive --json
# {
#   "campaign_id": "120241514062480265",
#   "deleted": true,
#   "result": { "success": true }
# }
```

### `campaign update` (WRITE)

```
apb campaign update --id <id> [--name <name>] [--daily-budget <usd>] [--lifetime-budget <usd>] [--bid-strategy <strategy>] [--status <status>] [--special-ad-categories <CSV>] [--spend-cap <usd>] [--issues-info <JSON>] [--execute] [--confirm-destructive] [--json]
```

Update campaign settings (name, budgets, bid strategy, status). Budget changes exceeding 200% and destructive status changes require `--confirm-destructive`.

| Flag | Type | Description |
|------|------|-------------|
| `--special-ad-categories` | CSV | Comma-separated list. **Note**: Meta rejects empty arrays on update (clearing requires recreate); pass nothing to leave unchanged. |
| `--spend-cap` | f64 | Spend cap in dollars; converted to cents server-side. |
| `--issues-info` | JSON | Raw JSON object passed through to Meta's `issues_info` field; ties to special_ad_categories compliance. |

### `campaign compose` (WRITE)

```
apb campaign compose --name <name> [--source-campaigns <ids>] [--source-adsets <ids>] [--source-ads <ids>] [--objective <obj>] [--execute] [--json]
```

Compose a new campaign by cherry-picking elements from existing campaigns, ad sets, and ads.

### `campaign duplicate` (WRITE)

```
apb campaign duplicate --id <id> [--name "..."] [--execute] [--json]
```

Clones the full tree: campaign -> adsets -> ads. All new entities start as PAUSED. Targeting specs are sanitized (removes `age_range`, ensures `targeting_automation.advantage_audience`).

### `campaign pacing`

```
apb campaign pacing --id <campaign_id> [--json]
```

Check intraday spend pacing vs daily budget. Shows current spend, daily budget, projected end-of-day spend, and pacing status (on_track, underspending, overspending).

### `campaign budget-schedule create` (WRITE)

```
apb campaign budget-schedule create --campaign <id> --time-start <ts> --time-end <ts> --daily-budget <n> [--execute] [--json]
```

### `campaign compose-from-spec` (WRITE)

Create a full campaign stack (campaign + ad sets + creatives + ads) from a single JSON spec file or saved preset.

```
apb campaign compose-from-spec --spec-file <spec.json> [--execute] [--no-rollback] [--with-estimates] [--json]
apb campaign compose-from-spec --preset <name> [--execute] [--no-rollback] [--with-estimates] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--spec-file` | string | — | Path to compose spec JSON (required unless `--preset` is used) |
| `--preset` | string | — | Load a saved preset by name (alternative to `--spec-file`) |
| `--no-rollback` | bool | false | On failure, keep partially created entities instead of pausing them |
| `--with-estimates` | bool | false | Include Meta delivery cost estimates per ad set in dry-run preview |

DRY-RUN by default. Shows preview tree with campaign, ad sets, and creative types. On execution failure, automatically pauses all created entities (rollback) unless `--no-rollback` is specified.

See `docs/examples/compose-spec.json` for the full spec format.

### `campaign preset save`

Save a compose spec file as a named preset for reuse.

```
apb campaign preset save --name <preset_name> --spec-file <spec.json> [--json]
```

### `campaign preset list`

List all saved compose presets.

```
apb campaign preset list [--json]
```

### `campaign preset show`

Display a preset's full spec.

```
apb campaign preset show --name <preset_name> [--json]
```

### `campaign preset delete`

Delete a saved preset.

```
apb campaign preset delete --name <preset_name> [--json]
```

---

## 5. adset

Ad set operations.

### `adset list`

```
apb adset list [--campaign <id>] [--limit N] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--campaign` | string | — | Scope to a campaign |
| `--limit` | u32 | 25 | Max results |

**API fields:** id, name, status, effective_status, campaign_id, daily_budget, lifetime_budget, optimization_goal, bid_strategy

### `adset get`

```
apb adset get --id <adset_id> [--json]
```

**Additional fields:** targeting, start_time, end_time, created_time, updated_time, budget_remaining, billing_event

### `adset update-budget` (WRITE)

```
apb adset update-budget --id <id> --daily-budget <usd> [--execute] [--json]
```

| Flag | Type | Required | Description |
|------|------|----------|-------------|
| `--id` | string | yes | Adset ID |
| `--daily-budget` | f64 | yes | New daily budget in USD (converted to cents for API) |

**Safety cap:** Maximum $10,000/day.

### `adset update-status` (WRITE)

```
apb adset update-status --id <id> --status <PAUSED|ACTIVE|DELETED|ARCHIVED> [--execute] [--confirm-destructive] [--json]
```

### `adset delete` (WRITE, IRREVERSIBLE)

```
apb adset delete --id <id> --execute --confirm-destructive [--json]
```

Hard-deletes the ad set via the Graph API `DELETE /{id}` verb. Terminal; use `update-status --status ARCHIVED` for reversible cleanup. Requires both `--execute` and `--confirm-destructive`.

### `adset update-targeting` (WRITE)

```
apb adset update-targeting --id <id> --spec-file <targeting.json> [--execute] [--json]
```

Accepts `{"targeting": {...}}` or a direct targeting spec object.

### `adset update` (WRITE)

Generic ad-set update — change any subset of mutable fields in one call. Use the targeted shortcuts (`update-budget`, `update-targeting`, `update-status`) when only one field changes.

```
apb adset update --id <id> [--name <name>] [--optimization-goal <goal>] [--billing-event <event>] [--bid-strategy <strategy>] [--bid-amount <usd>] [--pacing-type <type>] [--start-time <iso8601>] [--end-time <iso8601>] [--promoted-object <JSON>] [--status <status>] [--execute] [--confirm-destructive] [--json]
```

| Flag | Type | Description |
|------|------|-------------|
| `--name` | string | Ad set name |
| `--optimization-goal` | string | e.g. `OFFSITE_CONVERSIONS`, `LINK_CLICKS`, `IMPRESSIONS`, `REACH`, `VALUE`, `LANDING_PAGE_VIEWS`, `CONVERSATIONS`, `LEAD_GENERATION` |
| `--billing-event` | string | `IMPRESSIONS` or `LINK_CLICKS` |
| `--bid-strategy` | string | `LOWEST_COST_WITHOUT_CAP`, `LOWEST_COST_WITH_BID_CAP`, `COST_CAP`, `LOWEST_COST_WITH_MIN_ROAS` |
| `--bid-amount` | f64 | Bid amount in USD; converted to cents |
| `--pacing-type` | string | `standard`, `no_pacing`, `accelerated` |
| `--start-time` / `--end-time` | ISO 8601 | e.g. `2026-05-01T00:00:00-0700` |
| `--promoted-object` | JSON | Raw JSON, e.g. `{"pixel_id":"123","custom_event_type":"PURCHASE"}` |
| `--status` | string | `ACTIVE`/`PAUSED`/`DELETED`/`ARCHIVED`. Destructive transitions require `--confirm-destructive`. |

DRY-RUN by default. Returns a `dry_run` envelope with the proposed `changes` map when write gates are closed.

**Example dry-run:**

```bash
apb adset update --id 120239538597430265 --optimization-goal OFFSITE_CONVERSIONS --bid-amount 5.50 --json
# {
#   "dry_run": true,
#   "adset_id": "120239538597430265",
#   "changes": { "optimization_goal": "OFFSITE_CONVERSIONS", "bid_amount": "550" },
#   "blocked_reasons": [...]
# }
```

### `adset create` (WRITE)

```
apb adset create --campaign <id> --name <name> --optimization-goal <goal> [--billing-event IMPRESSIONS] [--daily-budget <usd>] [--lifetime-budget <usd>] [--bid-amount <usd>] [--bid-strategy <strategy>] [--pacing-type <type>] --targeting <json> [--start-time <ts>] [--end-time <ts>] [--promoted-object <json>] [--status PAUSED] [--execute] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--campaign` | string | required | Parent campaign ID |
| `--name` | string | required | Ad set name |
| `--optimization-goal` | string | required | e.g. `OFFSITE_CONVERSIONS`, `LINK_CLICKS`, `REACH` |
| `--billing-event` | string | `IMPRESSIONS` | Billing event type |
| `--daily-budget` | f64 | — | Daily budget in USD (mutually exclusive with `--lifetime-budget`) |
| `--lifetime-budget` | f64 | — | Lifetime budget in USD |
| `--bid-amount` | f64 | — | Bid amount in USD |
| `--bid-strategy` | string | — | `LOWEST_COST_WITHOUT_CAP`, `COST_CAP`, `BID_CAP` |
| `--pacing-type` | string | — | Comma-separated pacing types (e.g. `standard`) |
| `--targeting` | string | required | Targeting spec as inline JSON or path to file |
| `--promoted-object` | string | — | Promoted object JSON (e.g. pixel_id + event) |

---

## 6. ad

Ad-level operations.

### `ad list`

```
apb ad list [--adset <id>] [--limit N] [--json]
```

**API fields:** id, name, status, effective_status, adset_id, campaign_id, creative.id

### `ad get`

```
apb ad get --id <ad_id> [--json]
```

### `ad update-status` (WRITE)

```
apb ad update-status --id <id> --status <PAUSED|ACTIVE|DELETED|ARCHIVED> [--execute] [--confirm-destructive] [--json]
```

### `ad delete` (WRITE, IRREVERSIBLE)

```
apb ad delete --id <id> --execute --confirm-destructive [--json]
```

Hard-deletes the ad via the Graph API `DELETE /{id}` verb. Terminal; use `update-status --status ARCHIVED` for reversible cleanup.

### `ad update` (WRITE)

```
apb ad update --id <id> [--creative-id <id>] [--name <name>] [--status <status>] [--tracking-specs <JSON>] [--display-sequence <n>] [--execute] [--confirm-destructive] [--json]
```

Update ad settings including creative, name, status, tracking specs, and display sequence.

| Flag | Type | Description |
|------|------|-------------|
| `--tracking-specs` | JSON | Raw JSON array of tracking spec objects, e.g. `[{"action.type":["offsite_conversion"],"fb_pixel":["123"]}]`. Used to route conversion attribution through specific pixels or custom conversions. |
| `--display-sequence` | u32 | Display order within an ad set; lower values fire first. |

### `ad create` (WRITE)

```
apb ad create --name <name> --adset <id> --creative-id <id> [--execute] [--json]
```

New ads always start as `PAUSED`.

### `ad create-multi` (WRITE)

Create multiple ads in one ad set, one per creative.

```
apb ad create-multi --adset <id> --name <base_name> --creative-ids <id1,id2,id3> [--status PAUSED] [--execute] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--adset` | string | required | Target ad set ID |
| `--name` | string | required | Base name (ads named `{name} - V1`, `{name} - V2`, etc.) |
| `--creative-ids` | string | required | Comma-separated creative IDs |
| `--status` | string | `PAUSED` | Initial status for all ads |

### `ad preview`

```
apb ad preview --id <ad_id> [--format DESKTOP_FEED_STANDARD|MOBILE_FEED_STANDARD|RIGHT_COLUMN_STANDARD|INSTAGRAM_STANDARD|INSTAGRAM_STORY] [--json]
```

Generate an ad preview URL for the specified format. Returns a preview iframe URL from Meta's ad previews API.

**API:** `GET /{ad_id}/previews`

---

## 7. creative

Creative management.

### `creative list`

```
apb creative list [--account act_xxx] [--limit N] [--json]
```

### `creative get`

```
apb creative get --id <creative_id> [--json]
```

**Fields:** id, name, status, title, body, call_to_action_type, image_url, image_hash, thumbnail_url, object_type, object_story_spec, asset_feed_spec, url_tags

### `creative asset-audit`

Audit creative health: orphans, stale, missing assets.

```
apb creative asset-audit [--account act_xxx] [--json]
```

**Health classifications:** `good`, `warning` (missing image/body/CTA), `stale` (no active ads), `orphan` (no linked ads)

### `creative upload-image` (WRITE)

```
apb creative upload-image --path <file> [--json]
```

Returns `image_hash` and `image_url`. Timeout: 120s.

### `creative upload-video` (WRITE)

```
apb creative upload-video --path <file> [--json]
```

Returns `video_id`. Timeout: 300s.

### `creative upload-video-status`

```
apb creative upload-video-status --id <video_id> [--json]
```

### `creative update` (WRITE)

```
apb creative update --id <id> --spec-file <spec.json> [--execute] [--json]
```

Allowed fields: name, title, body, object_story_spec, asset_feed_spec, url_tags, call_to_action_type

### `creative create-image` (WRITE)

```
apb creative create-image --spec-file <spec.json> [--execute] [--json]
```

Spec must contain: `name`, `object_story_spec.page_id`, `object_story_spec.link_data.image_hash`

### `creative create-video` (WRITE)

```
apb creative create-video --spec-file <spec.json> [--execute] [--json]
```

Requires a pre-uploaded `video_id` in the spec. Partially supported.

### `creative create-carousel` (WRITE)

```
apb creative create-carousel --name "Carousel A" --spec-file <spec.json> [--execute] [--json]
```

Supports Meta `object_story_spec.link_data.child_attachments` payloads.

Validation:
- `object_story_spec.page_id` is required
- `object_story_spec.link_data` is required
- `child_attachments` must contain **2-10** cards

Creates via `POST /{act}/adcreatives` and honors normal write gates + dry-run output.

### `creative create-dynamic` (WRITE)

Create a dynamic creative with `asset_feed_spec` for Meta's Dynamic Creative Optimization (DCO). Meta automatically tests combinations of the provided images, videos, titles, and bodies.

Two input modes — pick one:

**Spec-file mode** (production-grade — recommended for canonical specs):

```
apb creative create-dynamic --name <name> --page-id <page_id> --spec-file <asset_feed.json> [--execute] [--json]
```

**Inline mode** (quick experiments — added in cli-ergonomics-001 sprint 002):

```
apb creative create-dynamic \
  --name "DCO Test" --page-id <page_id> \
  --image <hash-or-path> --image <hash-or-path> \
  --title "Headline A" --title "Headline B" \
  --body  "Body A"      --body  "Body B" \
  --cta LEARN_MORE \
  --url https://example.com \
  --dry-run --json
```

| Flag | Type | Required | Mode | Description |
|------|------|----------|------|-------------|
| `--name` | string | yes | both | Creative name |
| `--page-id` | string | yes | both | Facebook Page ID for the creative |
| `--spec` | string | — | spec-file | Inline `asset_feed_spec` JSON string |
| `--spec-file` | string | — | spec-file | Path to `asset_feed_spec` JSON file |
| `--image` | string | ≥1 | inline | Repeatable. Accepts a Meta image hash OR a local file path (starts with `./`, `/`, `~/`, or ends in `.jpg/.jpeg/.png/.gif/.webp`). Paths upload via `creative.upload_image` under `--execute`; under dry-run a `<dry_run_placeholder:...>` is stamped. |
| `--title` | string | ≥1 | inline | Repeatable. Title text. |
| `--body` | string | ≥1 | inline | Repeatable. Body text. |
| `--cta` | string | yes | inline | Call-to-action enum (e.g. `LEARN_MORE`, `SHOP_NOW`). |
| `--url` | string | yes | inline | Click-through URL. Validated by `url::Url::parse` before any network call. |

**Conflict rule:** Combining `--spec-file` (or `--spec`) with **any** inline DCO flag exits with code 2 and the error: `Cannot use --spec-file together with inline DCO flags. Use one input mode.`

**Validators (inline mode):** ≥1 image, ≥1 title, ≥1 body, present `--cta`, parseable `--url`. Each violation produces an exit-2 `Validation error` naming the missing field.

**Important:** The ad set using this creative must have `is_dynamic_creative: true`.

For agent / CI usage patterns including hash vs path resolution semantics, see [`docs/CLI_AUTOMATION.md`](../../docs/CLI_AUTOMATION.md#dynamic-creative-quick-experiments).

### `creative create-collection` (WRITE — Sprint 003)

Create a **collection ad** creative — Meta's catalog-driven mobile shopping format. The creative pairs a hero image/video with a `template_data.product_set_id` reference; Meta auto-fills the product card grid from the catalog at delivery time.

```
apb creative create-collection --name <name> --spec-file <spec.json> [--execute] [--json]
```

The full spec is too deeply nested for flag-by-flag construction; pass via `--spec-file` only. Working example at `docs/examples/creative-collection-spec.json`. The spec must include:
- `object_story_spec.page_id` and (optionally) `object_story_spec.instagram_actor_id`
- `object_story_spec.template_data.product_set_id` — the product set to render
- `object_story_spec.template_data.video_id` OR `image_hash` — the hero asset
- `object_story_spec.template_data.call_to_action`

Sprint 003 adds the corresponding scope `write:campaigns` (already required for any creative write) and pairs cleanly with `apb catalog product-set-create` to produce the referenced product set.

---

## 8. audience

Custom audience management.

### `audience list`

```
apb audience list [--account act_xxx] [--limit N] [--json]
```

Lists custom audiences.

### `audience get`

```
apb audience get --id <audience_id> [--json]
```

Get details for a single custom audience.

### `audience create` (WRITE)

```
apb audience create --name <name> --subtype <CUSTOM|WEBSITE|ENGAGEMENT|LOOKALIKE> [--description <desc>] [--customer-file-source <source>] [--rule <json>] [--retention-days <days>] [--engagement-source <type> --source-id <id>] [--execute] [--json]
```

Create a custom audience. Subtype determines the audience source.

**Sprint 007 — Engagement-audience first-class flags**: when `--subtype ENGAGEMENT`, you can either:
- **Pass `--rule <JSON>`** with the full Meta rule shape — for advanced filters like `video_view_percent >= 50`. Power-user path.
- **Pass `--engagement-source <type> --source-id <id> [--retention-days <n>]`** — service builds the rule JSON for the common cases.

The two paths are mutually exclusive; specifying both errors out.

| `--engagement-source` | What it captures | `--source-id` is |
|-----------------------|------------------|------------------|
| `page` | People who engaged with the Facebook Page | Page ID |
| `video` | People who watched the video (any %) | Video ID |
| `post` | People who engaged with a specific post | Post ID |
| `event` | People who RSVP'd to a Facebook event | Event ID |
| `lead_form` | People who submitted a lead-gen form | Leadgen Form ID (pairs with S005) |
| `instagram_profile` | People who engaged with the IG business profile | IG account ID (use `apb account instagram-accounts` to find) |

`--retention-days` defaults to 180 days (Meta's default for engagement audiences). Max is 365.

**Examples:**
```bash
# Page engagers in last 90 days
apb audience create --name "Page Engagers 90d" --subtype ENGAGEMENT \
    --engagement-source page --source-id 190237667516138 --retention-days 90 --execute

# People who watched a specific video
apb audience create --name "Video Viewers" --subtype ENGAGEMENT \
    --engagement-source video --source-id 444555666 --execute

# Advanced: people who watched ≥50% of the video (use --rule directly)
apb audience create --name "Engaged Viewers" --subtype ENGAGEMENT --rule '{
  "inclusions": {
    "operator": "or",
    "rules": [{
      "event_sources": [{"id": "444555666", "type": "video"}],
      "retention_seconds": 5184000,
      "filter": {
        "operator": "and",
        "filters": [
          {"field": "event", "operator": "eq", "value": "video_view"},
          {"field": "video_view_percent", "operator": "gte", "value": 50}
        ]
      }
    }]
  }
}' --execute
```

**Closed-loop with leadgen** (S005 → S007): use a leadgen form ID as the engagement source to retarget people who submitted that form.

```bash
apb audience create --name "Lead Form Submitters" --subtype ENGAGEMENT \
    --engagement-source lead_form --source-id 12345678 --retention-days 365 --execute
```

### `audience overlap`

```
apb audience overlap --audience-ids 123,456 [--json]
```

Estimate overlap between two or more custom audiences. Requires at least 2 audience IDs (comma-separated).

**API:** `GET /{account}/delivery_estimate` (with audience overlap parameters)

### `audience create-lookalike` (WRITE)

```
apb audience create-lookalike --source <audience_id> --country <CC> --ratio <0.01-0.20> [--name <name>] [--execute] [--json]
```

Create a lookalike audience from a source custom audience. Ratio controls similarity (lower = more similar, smaller audience).

### `audience users-add` (WRITE PII — Sprint 006)

Upload hashed PII to a customer-list audience. Plaintext rows from `--data-file` are normalized + SHA-256 hashed locally **before transmit** — Meta never receives plaintext.

```
apb audience users-add --id <audience_id> --schema <CSV> --data-file <path> [--format csv|json] [--skip-header] [--execute] [--json]
```

**Required scope**: `write:audience-data` (Agency tier and higher). Distinct from `write:campaigns` because PII upload is gated more carefully than the audience shell creation.

| Flag | Type | Description |
|------|------|-------------|
| `--id` | string | Target audience ID (must be a customer-file-source audience created via `apb audience create --customer-file-source`) |
| `--schema` | CSV | Meta field codes — one per data column. Valid: `EMAIL`, `PHONE`, `FN`, `LN`, `DOBY`, `DOBM`, `DOBD`, `GEN`, `CT`, `ST`, `ZIP`, `COUNTRY`, `MADID`, `EXTERN_ID` |
| `--data-file` | path | CSV (default — RFC 4180) or JSON (array of arrays) |
| `--format` | string | `csv` (default) or `json` |
| `--skip-header` | bool | Skip the first row of CSV. Auto-detected when first row matches schema codes |

**Hashing rules** (per Meta's docs, applied locally before SHA-256):
- `EMAIL`, `FN`, `LN`, `CT`, `ST`, `COUNTRY`, `ZIP`, `MADID`, `EXTERN_ID`: lowercase + trim
- `PHONE`: digits only (strip `+`, `-`, `(`, `)`, spaces)
- `DOBY`: 4-digit year, zero-padded
- `DOBM`, `DOBD`: 2-digit month/day, zero-padded
- `GEN`: first lowercase character (`m` or `f`)

**Batching**: files >10,000 rows split into multiple POSTs (Meta's documented batch limit).

**PII discipline**: the audit log records only `{audience_id, schema, row_count, batch_count}` — never the plaintext or hashed values. Documented in `services/audience.rs::users_mutate`.

**Closed-loop workflow with leadgen** (S005 + S006):
```bash
# Capture leads from a Meta lead-gen form
apb leadgen leads-export --form-id 12345 --output leads.csv --all

# Push them into a Custom Audience for retargeting
apb audience users-add --id <audience_id> --schema EMAIL,PHONE --data-file leads.csv --execute
```

Working data file example at `docs/examples/audience-users-spec.csv`.

### `audience users-remove` (WRITE PII — Sprint 006)

Remove hashed PII from a customer-list audience. Same data-file shape as `users-add`; uses Meta's `DELETE /{audience_id}/users?payload=<json>` path.

```
apb audience users-remove --id <audience_id> --schema <CSV> --data-file <path> [--format csv|json] [--skip-header] [--execute] [--json]
```

Same scope and hashing rules as `users-add`. Useful for honoring opt-out / unsubscribe requests at scale.

---

## 9. targeting

Targeting research commands. All are read-only.

### `targeting interest-search`

```
apb targeting interest-search --query "fitness" [--limit N] [--json]
```

**API:** `GET /search?type=adinterest&q=...`

**Fields:** id, name, audience_size_lower_bound, audience_size_upper_bound, topic, path

### `targeting interest-suggest`

```
apb targeting interest-suggest --query "6003139266461,6003277229371" [--limit N] [--json]
```

Suggest related interests from seed IDs. Gracefully degrades if the API shape is strict.

### `targeting interest-validate`

```
apb targeting interest-validate --ids "6003139266461,6003277229371" [--json]
```

Check whether interest IDs still exist. Falls back to per-ID lookup if batch endpoint fails.

### `targeting behavior-search`

```
apb targeting behavior-search [--limit N] [--json]
```

**API:** `GET /search?type=adTargetingCategory&class=behaviors`

### `targeting demographic-search`

```
apb targeting demographic-search [--demographic-type education|work|life_events|industry|income|home|family_status] [--limit N] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--demographic-type` | string | — | Demographic class (alias: `--type`) |

### `targeting geo-search`

```
apb targeting geo-search --query "New York" [--location-types country,region,city,zip] [--limit N] [--json]
```

### `targeting estimate`

```
apb targeting estimate --spec-file <targeting.json> [--json]
```

Read-only delivery estimate. Returns `estimate_dau`, `estimate_mau`, `daily_outcomes_curve`.

### `targeting delivery-estimate`

```
apb targeting delivery-estimate [--spec <json_string>] [--spec-file <targeting.json>] [--optimization-goal <goal>] [--account act_xxx] [--json]
```

Estimate delivery for a targeting spec with an explicit optimization goal. Accepts targeting either inline via `--spec` or from a file via `--spec-file`.

---

## 10. report

Reporting and insights.

### `report insights`

```
apb report insights [--days N] [--level campaign|account] [--attribution 1d_click,7d_click,...] [--action-report-time impression|conversion|mixed] [--use-account-attribution true|false] [--time-increment 1|7|monthly] [--format table|csv] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--days` | u32 | 30 | Lookback window |
| `--level` | string | campaign | Aggregation level |
| `--attribution` | string | — | Comma-separated attribution windows |
| `--action-report-time` | string | — | `impression`, `conversion`, or `mixed` |
| `--use-account-attribution` | string | — | `true` or `false` |
| `--time-increment` | string | — | `1` (daily), `7` (weekly), or `monthly` granularity |
| `--format` | string | table | `table` (default) or `csv` (CLI only, writes CSV to stdout) |

**Valid attribution windows (Meta-supported common set):** `1d_click`, `7d_click`, `28d_click`, `1d_view`, `7d_view`, `28d_view`, `1d_ev`, `dda`, `default`, `7d_view_first_conversion`, `28d_view_first_conversion`, `7d_view_all_conversions`, `28d_view_all_conversions`, `skan_view`, `skan_click`, `skan_click_second_postback`, `skan_view_second_postback`, `skan_click_third_postback`, `skan_view_third_postback`.

`--attribution` accepts CSV and is sent as an attribution-window array to Meta.

**API fields:** campaign_name, impressions, clicks, spend, cpc, cpm, ctr, actions

### `report compare`

```
apb report compare [--days N] [--compare-days N] [--level campaign|adset|ad] [--limit N] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--days` | u32 | 7 | Current period lookback |
| `--compare-days` | u32 | 7 | Comparison period lookback (immediately prior) |
| `--level` | string | campaign | Aggregation level |
| `--limit` | u32 | 25 | Max rows |

Period-over-period comparison. Returns each metric for both periods plus `delta` (absolute change) and `pct_change` (percentage change). Useful for week-over-week or month-over-month trend analysis.

### `report metrics`

```
apb report metrics --metrics <csv> [--level campaign|adset|ad] [--days N] [--breakdowns csv] [--limit N] [--attribution csv] [--action-report-time impression|conversion|mixed] [--use-account-attribution true|false] [--time-start YYYY-MM-DD --time-end YYYY-MM-DD] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--metrics` | csv | required | Arbitrary insights fields to request |
| `--level` | string | campaign | Aggregation level |
| `--days` | u32 | 30 | Lookback window (ignored when `--time-start/--time-end` are set) |
| `--breakdowns` | csv | — | Optional Meta breakdowns |
| `--limit` | u32 | 100 | Row limit |
| `--attribution` | csv | — | Attribution windows |
| `--action-report-time` | string | — | `impression`, `conversion`, or `mixed` |
| `--use-account-attribution` | string | — | `true` or `false` |
| `--time-start` / `--time-end` | date | — | Explicit date range (must be provided together) |

Returns `{ meta, rows }`, including selected metrics and query metadata.

> Note: some Meta breakdown combinations are invalid when action arrays are requested (for example `actions` + `age,gender,device_platform`). If this happens, remove action-array fields or simplify breakdowns.

### `report presets list`

```
apb report presets list [--json]
```

Lists built-in presets:
- `core-performance`
- `ecom-funnel`
- `creative-video`
- `creative-image-carousel`

### `report presets run`

```
apb report presets run --name <core-performance|ecom-funnel|creative-video|creative-image-carousel> [--level campaign|adset|ad] [--days N] [--limit N] [--json]
```

Runs a preset metric pack and returns `{ meta, rows }` with preset details and recommended breakdowns.

### `report profile save`

```
apb report profile save --name <profile_name> --level <campaign|adset|ad> --metrics <csv> [--breakdowns csv] [--attribution csv] [--action-report-time impression|conversion|mixed] [--use-account-attribution true|false] [--json]
```

Persists a reusable profile at `state/report-profiles/<name>.json`.

### `report profile list`

```
apb report profile list [--json]
```

Lists saved report profiles.

### `report profile run`

```
apb report profile run --name <profile_name> [--days N] [--limit N] [--json]
```

Runs a saved profile through `report metrics` semantics.

### `report breakdown`

```
apb report breakdown --type <age_gender|device_platform|hourly> [--days N] [--json]
```

**Breakdown mapping:**
- `age_gender` → `age,gender`
- `device_platform` → `device_platform`
- `hourly` → `hourly_stats_aggregated_by_advertiser_time_zone`

### `report insights-async start`

```
apb report insights-async start [--days N] [--level ...] [--attribution ...] [--json]
```

Starts an async report job. Returns `job_id`.

### `report insights-async status`

```
apb report insights-async status --job-id <id> [--json]
```

Returns `async_status`, `async_percent_completion`.

### `report insights-async fetch`

```
apb report insights-async fetch --job-id <id> [--limit N] [--json]
```

---

## 11. coverage

### `coverage audit`

```
apb coverage audit [--json]
```

Field coverage matrix across campaigns, adsets, ads, creatives, insights, and targeting. Shows which required API fields are present and populated.

---

## 12. metrics

Derived metric computation.

### `metrics compute`

```
apb metrics compute [--days N] [--level account|campaign|adset|ad] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--days` | u32 | 30 | Lookback window |
| `--level` | string | account | Aggregation level |

**Derived metrics (15+):**
- `hook_rate` — video 3s views / impressions
- `thumb_stop_rate` — video plays / impressions
- `hold_rate` — video thruplays / impressions
- `outbound_ctr` — outbound clicks / impressions
- `link_ctr` — link clicks / impressions
- `cpo_click` — spend / outbound clicks
- `cpa` — spend / purchases
- `roas` — purchase value / spend

### `metrics funnel`

```
apb metrics funnel [--days N] [--json]
```

**Funnel stages:** Impressions -> Clicks -> Landing Page Views -> Add to Cart -> Initiate Checkout -> Purchase

**Output:**
- `dropoff` — per-stage dropoff rates
- `conversion_rates` — click_to_landing_page, landing_page_to_atc, atc_to_checkout, checkout_to_purchase, overall_click_to_purchase

### `metrics objective-pack`

```
apb metrics objective-pack --objective <sales|leadgen|engagement|awareness> [--days N] [--level ...] [--json]
```

Returns objective-specific metrics:
- **sales** — purchases, purchase_value, cpa, roas, add_to_cart, initiate_checkout, avg_watch_time_proxy
- **leadgen** — leads, cpl, lead_cvr, landing_page_views, frequency, reach
- **engagement** — post_engagement, reactions, comments, shares, video_views, engagement_rate, cost_per_engagement
- **awareness** — reach, frequency, cpm, ctr, cost_per_1k_reach

### `metrics creative-quality`

```
apb metrics creative-quality [--account act_xxx] [--campaign <id>] [--days N] [--json]
```

Returns: thumb_stop_ratio, hook_rate, hold_rate, avg_watch_time_proxy, ctr, cpc, frequency

**Note:** `avg_watch_time_proxy` assumes 15-second video duration (actual duration unavailable from insights API).

---

## 13. learning

Learning-phase analysis.

### `learning diagnose`

```
apb learning diagnose [--days N] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--days` | u32 | 14 | Lookback window |

Per-adset diagnostics with stability risk scoring.

**Risk levels:** `high`, `medium`, `low`

**Reason codes:** `LOW_EVENT_DENSITY`, `HIGH_FREQUENCY`, `LOW_CTR`, `HIGH_CPC`, `LOW_SPEND_SIGNAL`

**Recommendations:** `consolidate_candidates`, `creative_refresh_candidates`, `scale_candidates`

### `learning prescribe`

```
apb learning prescribe [--account act_xxx] [--campaign <id>] [--adset <id>] [--days N] [--json]
```

Budget prescription for learning phase exit. Calculates minimum daily budgets to reach weekly thresholds for each optimization event.

**Weekly thresholds:** purchase=50, add_to_cart=150, landing_page_view=1000

### `learning scorecard`

```
apb learning scorecard [--days N] [--json]
```

Weighted 3-component scoring per adset:
- **signal_density** (40%) — conversion volume + spend sufficiency
- **efficiency** (35%) — CTR + CPC benchmarks
- **stability** (25%) — frequency + reach

**Grades:** A (80-100), B (60-79), C (40-59), D (0-39)

### `learning volume`

```
apb learning volume [--account act_xxx] [--campaign <id>] [--adset <id>] [--event <event_type>] [--json]
```

Weekly event volume vs learning-phase exit thresholds. Recommends which optimization event to use.

---

## 14. playbook

Agency-grade diagnostics with impact forecasting. Each playbook returns a 0-100 score, letter grade, findings, and recommendations with projected impact.

### `playbook evaluate`

```
apb playbook evaluate [--days N] [--campaign <id>] [--scope account|campaign] [--json]
```

Evaluates 9 playbook triggers:

1. **creative_fatigue** — frequency > 2.5 or high-frequency adsets exist
2. **mid_funnel_optimization** — ATC dropoff > 85% or checkout dropoff > 75%
3. **audience_expansion** — frequency > 2.0 with good CVR and ROAS
4. **offer_testing** — low purchase CVR with high traffic and intent
5. **landing_page_optimization** — LP-to-ATC rate < 5% with 200+ LPVs
6. **cost_control** — high CPA adsets or ROAS < 1.0
7. **budget_scaling** — high ROAS adsets with ROAS > 1.5
8. **hook_testing** — hook rate < 25% with 10K+ impressions
9. **scaling_headroom** — low frequency + ROAS > 2.0 + 30+ purchases/week

### `playbook health-score`

```
apb playbook health-score [--days N] [--json]
```

Account health score (0-100) across 6 dimensions: spend efficiency, creative health, audience saturation, conversion volume, learning phase stability, and pixel/CAPI signal strength.

### `playbook waste-audit`

```
apb playbook waste-audit [--days N] [--json]
```

Find and quantify wasted ad spend. Identifies zero-conversion adsets, high-CPA outliers, frequency-saturated audiences, and budget allocated to underperformers. Returns total waste estimate and recovery recommendations.

### `playbook fatigue-index`

```
apb playbook fatigue-index [--days N] [--json]
```

Per-ad creative fatigue scoring. Measures frequency trend, CTR decay, CPA inflation, and engagement dropoff to classify each creative as fresh, aging, fatigued, or exhausted.

### `playbook rebalance`

```
apb playbook rebalance [--days N] [--metric cpa|roas] [--json]
```

Budget reallocation recommendations. Analyzes per-adset efficiency and suggests shifts from underperformers to top performers. Returns before/after projections.

### `playbook weekly-digest`

```
apb playbook weekly-digest [--json]
```

Week-over-week comparison with monthly projections. Summarises spend, conversions, CPA, ROAS deltas and projects month-end totals at current run rate.

### `playbook saturation`

```
apb playbook saturation [--days N] [--json]
```

Audience exhaustion detection. Measures frequency trends, reach plateau, and diminishing returns per adset to flag audiences approaching saturation.

### `playbook launch-check`

```
apb playbook launch-check [--json]
```

New account readiness checklist. Validates pixel installation, conversion events, payment method, audience setup, creative assets, and campaign structure before first launch.

### `playbook learning-accelerator`

```
apb playbook learning-accelerator [--days N] [--json]
```

Calculate the budget required to exit learning phase for each adset. Uses historical conversion rates and Meta's 50-event-per-week threshold to recommend minimum daily budgets.

### `playbook creative-mix`

```
apb playbook creative-mix [--json]
```

Creative format diversity audit. Analyses the distribution of image, video, carousel, and collection formats across active ads. Flags over-reliance on a single format and recommends diversification.

### `playbook placement-audit`

```
apb playbook placement-audit [--days N] [--json]
```

Performance by placement (Feed, Stories, Reels, Right Column, Audience Network, etc.) with cost and conversion breakdowns. Recommends placement exclusions for underperformers.

### `playbook daypart`

```
apb playbook daypart [--days N] [--json]
```

Hourly performance heatmap. Identifies peak and off-peak hours for spend efficiency, enabling ad scheduling optimisation.

### `playbook scale-roadmap`

```
apb playbook scale-roadmap [--days N] [--json]
```

Scaling projections at 1.2x, 1.5x, 2x, and 3x current spend. Models expected CPA inflation, conversion volume, and ROAS decay at each tier with risk assessment.

### `playbook roas-recovery`

```
apb playbook roas-recovery [--days N] [--target-roas N] [--json]
```

ROAS decline diagnosis and recovery plan. Identifies the top contributors to ROAS erosion (audience fatigue, creative decay, bid inflation) and prescribes corrective actions with projected recovery timeline.

### `playbook anomaly-detect`

```
apb playbook anomaly-detect [--days N] [--baseline-days N] [--json]
```

Cost anomaly detection vs baseline period. Flags statistically significant deviations in CPA, CPM, CTR, and spend at the campaign and adset level. Uses z-score thresholds to classify anomalies as minor, moderate, or severe.

### `playbook duplicate-detect`

```
apb playbook duplicate-detect [--days N] [--json]
```

Targeting overlap detection across ad sets in different campaigns. Compares targeting specs (age, gender, geo, interests, custom audiences) using weighted Jaccard similarity. Flags pairs with >70% overlap and identifies the weaker performer by CPA. Calculates overlap spend — the budget wasted on self-competing auctions. Returns actionable recommendations to consolidate or pause overlapping ad sets.

**Options:**
- `--days N` — Lookback window for spend/performance data (default: 14)

---

### `playbook catalog`

```
apb playbook catalog [--json]
```

Returns the full playbook directory with slug, display name, pillar, description, and default `--days` value for each of the 24 playbooks. Drives UI filter chips and grouped listings.

**Output:** `{ version, total: 24, pillars: [learning, signal, scaling, turnaround], playbooks: [...] }`

### `playbook event-downgrade-ladder` *(new — Learning pillar)*

```
apb playbook event-downgrade-ladder [--days N] [--json]
```

Walks the Meta event ladder (Purchase → InitiateCheckout → AddToCart → ViewContent) and recommends downgrading the optimization event for adsets running below the 50/week learning threshold. Higher-volume events give Meta's algorithm more signal to optimize against, accelerating learning exit.

**Sample output (Scandalous Coffee, 90d):**
```
TOF Reverse Psych Ad Set [TOF Reverse Psych]
  current_goal: OFFSITE_CONVERSIONS
  weekly volume:  Purchase=0.7  IC=1.6  ATC=3.5  VC=66.1
  recommended:    CONTENT_VIEW
```

### `playbook cbo-vs-abo-audit` *(new — Scaling pillar)*

```
apb playbook cbo-vs-abo-audit [--days N] [--json]
```

Identifies ABO (Ad Set Budget Optimization) campaigns with ≥2 adsets where CPA dispersion (stddev / mean) exceeds 30%, and recommends CBO migration. CBO lets Meta auto-allocate budget toward winners; high-dispersion ABO campaigns are starving the strong adset while a laggard burns spend.

### `playbook no-touch-compliance` *(new — Learning pillar)*

```
apb playbook no-touch-compliance [--days N] [--json]
```

Flags learning-phase adsets edited within the last 7 days. Each edit during LEARNING or LEARNING_LIMITED state restarts Meta's 50-event learning counter. Recommendation: freeze edits for the 7-day stabilization window.

### `playbook broad-targeting-audit` *(new — Signal pillar)*

```
apb playbook broad-targeting-audit [--json]
```

Inspects each active adset's targeting spec and computes a 0-5 narrow_score. Flags ad sets with restrictive age bounds, deep interest stacking (≥3 layered AND groups), pure custom-audience targeting, or Advantage+ audience expansion disabled. Verdict: BROAD / NARROW / OVER_NARROW.

### `playbook consolidation-advisor` *(new — Learning pillar)*

```
apb playbook consolidation-advisor [--days N] [--json]
```

Detects ad-set fragmentation: multi-adset campaigns where the average per-adset conversion volume is below the learning threshold and at least one adset is dragging the campaign. Recommends merging the small adsets into the strongest survivor so the combined budget can clear the 50/week threshold. Distinct from `duplicate-detect` (which targets overlap detection).

### `playbook retargeting-compression` *(new — Scaling pillar)*

```
apb playbook retargeting-compression [--json]
```

Audits custom audiences referenced by active retargeting ad sets. Flags any audience with `retention_days > 30` (e.g., 90d/180d Website Views) and recommends compression to 7-14 days. Long retention windows pollute retargeting pools with stale users past intent.

### `playbook event-hierarchy-audit` *(new — Signal pillar)*

```
apb playbook event-hierarchy-audit [--json]
```

Detects funnel-stage misalignment: campaigns named with TOF/MOF/BOF markers should optimize for events appropriate to that funnel stage (TOF → ViewContent/LandingPageView, MOF → AddToCart/InitiateCheckout, BOF → Purchase). When naming says one stage but `optimization_goal` says another, the algorithm is being told to chase the wrong target.

**Severity scale:**
- HIGH: TOF chasing PURCHASE OR BOF chasing LANDING_PAGE_VIEWS
- MEDIUM: TOF chasing INITIATE_CHECKOUT/ADD_TO_CART
- LOW: minor mismatch

### `playbook capi-dual-signal` *(new — Signal pillar)*

```
apb playbook capi-dual-signal [--json]
```

Audits pixels for Conversions API (CAPI) coverage. Pixel-only tracking loses 20-40% of conversion signal to iOS/ATT and ad-blockers. Pairs pixel events vs server events from `pixel/stats?aggregation=event_source` and computes a signal-stack completeness score (0-100). Flags pixels needing CAPI activation.

### `playbook reset-rebuild-advisor` *(new composite — Turnaround pillar)*

```
apb playbook reset-rebuild-advisor [--days N] [--json]
```

Composite turnaround playbook. Activates only when `health_score < 60` AND ≥2 other red flags (waste >20%, fatigue ≥2, learning failures). Internally calls `health_score`, `waste_audit`, `fatigue_index`, and `learning_accelerator` in parallel via `tokio::join!`, then synthesizes a 4-phase rebuild plan:

1. **Phase 1: Stop the bleeding** — pause flagged waste entities
2. **Phase 2: Restructure** — consolidate to 1-3 CBO campaigns, broad targeting, Conversions objective
3. **Phase 3: Refresh creative supply** — refresh fatigued ads, build creative volume, enable DCO
4. **Phase 4: Verify recovery** — 7-day no-touch window, re-run health-score at day 14

When NOT triggered, returns a clean "no rebuild needed" verdict with the underlying signal counts.

---

### Enhanced playbooks (additive changes)

**`playbook scale-roadmap`** now emits two additional incremental scaling tiers (`+20%`, `+30%`) with `path: "incremental"`, plus a `path` field on every existing tier (`incremental` for ≤1.2x, `duplication` for 1.5x+). Campaigns with any LEARNING_LIMITED adset auto-force ALL their tiers to `path: incremental` to avoid resetting Meta's learning timer.

**`playbook creative-mix`** now emits volume-per-adset and DCO detection signals: `adsets_with_too_few_creatives` (count of ad sets with <3 active creatives), `dco_enabled_count`, `adsets_eligible_for_dco` (≥4 creatives but DCO disabled), plus example lists for each.

---

### Pillar field on every playbook

Every playbook response now carries a `pillar` field: `"learning" | "signal" | "scaling" | "turnaround"`. The 24 playbooks distribute as:

- **Learning (5):** launch-check, learning-accelerator, event-downgrade-ladder, no-touch-compliance, consolidation-advisor
- **Signal (8):** fatigue-index, saturation, creative-mix, placement-audit, duplicate-detect, broad-targeting-audit, event-hierarchy-audit, capi-dual-signal
- **Scaling (7):** waste-audit, rebalance, weekly-digest, daypart, scale-roadmap, cbo-vs-abo-audit, retargeting-compression
- **Turnaround (4):** health-score, roas-recovery, anomaly-detect, reset-rebuild-advisor

---

> **Note:** The CLI binary is now `apb` (not `apb`) following the AgencyPlaybook.io rebrand. Older sections of this reference still use `apb` as the legacy alias — they remain functional via shell symlink but the canonical binary name is `apb`. Run `apb --help` to see the full command tree.

---

## 15. growth

### `growth score`

```
apb growth score [--days N] [--json]
```

0-5 growth score with tier classification.

**Criteria (1 point each):**
- hook_rate > 35%
- link_ctr > 2%
- purchase_cvr > 3%
- frequency < 2.5
- purchases_per_week > 50

**Tiers:** `weak` (0-2), `scalable` (3-4), `strong_scaling_candidate` (5)

---

## 16. action

Action planning and application.

### `action plan`

```
apb action plan [--account <act>] [--campaign <id>] [--days N] [--scope full] [--json]
```

Generate actionable plan seeds from adset performance diagnostics. Analyzes spend, CTR, and conversions to recommend budget increases for strong performers and pauses for underperformers.

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--days` | u32 | 14 | Lookback period |
| `--scope` | string | — | Use `full` for expanded analysis (50 seeds vs 25) |

### `action apply`

```
apb action apply --plan-id <id> [--execute] [--confirm-destructive] [--json]
apb action apply --adset <id> --strategy <relaunch|pause-campaign> [--json]
```

Apply an action plan by plan ID, or generate a strategy bridge plan seed for a specific adset. When using `--plan-id`, applies all steps in the plan with write gate enforcement.

### `action autoplan`

```
apb action autoplan [--account <act>] [--days N] [--limit N] [--json]
```

Generate safe plan seeds from recommendation diagnostics (read-only, no execution). Similar to `action plan` but with explicit limit control.

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--days` | u32 | 14 | Lookback period |
| `--limit` | usize | 10 | Max plan seeds to generate |

---

## 17. budget

### `budget simulate`

```
apb budget simulate --shift-from <adset_id> --shift-to <adset_id> --pct <1-100> [--days N] [--json]
```

Proportional spend simulation. Projects clicks and conversions at shifted budget allocation using historical rates.

**Output:** before/after comparison table with total spend (unchanged), projected clicks, projected conversions.

---

## 18. ask

### `ask`

```
apb ask --question "how are my campaigns performing?" [--days N] [--json]
```

Intent classification + multi-handler orchestration. Routes questions about performance, learning, duplication to the appropriate analysis commands.

---

## 19. search

### `search`

```
apb search --query "brand" [--scope all|campaign,adset,ad,creative,page] [--limit N] [--json]
```

Cross-entity convenience search. Case-insensitive substring match on entity name or ID.

---

## 20. pixel

### `pixel` — Pixel Management, Stats, CAPI & Health

28th command domain. First-class pixel management with Conversions API (CAPI) support.

#### Read Operations

```
pixel list
```
List all pixels for the ad account.
**API:** `GET /{account}/adspixels`

```
pixel get --id <pixel_id>
```
Get detailed pixel information.
**API:** `GET /{pixel_id}`

```
pixel stats --id <pixel_id> [--aggregation event] [--days 7] [--event-source WEB_ONLY|SERVER_ONLY]
```
Pixel statistics with 9 aggregation types: event, pixel_fire, event_total_counts, host, url, browser_type, device_os, device_type, custom_data_field.
**API:** `GET /{pixel_id}/stats`

```
pixel health
```
Health assessment for all account pixels. Checks is_unavailable, last_fired_time.
**API:** `GET /{account}/adspixels`

```
pixel events [--pixel-id <id>] [--days 7] [--aggregation event]
```
Event breakdown with time range filtering. Auto-discovers pixel if --pixel-id not provided.
**API:** `GET /{pixel_id}/stats`

```
pixel signal [--pixel-id <id>] [--days 30] [--event Purchase]
```
Signal strength analysis (strong/moderate/weak/none). Optionally filter by event name.
**API:** `GET /{pixel_id}/stats`

```
pixel quality [--pixel-id <id>]
```
6-check quality assessment: pixel_active, has_events, has_purchase, event_diversity, automatic_matching, match_rate_above_50.
**API:** `GET /{pixel_id}` + `GET /{pixel_id}/stats`

```
pixel diagnostics --id <pixel_id> [--checks pixel_decline,pixel_missing_param_in_events] [--connection-method ALL|BROWSER|SERVER]
```
Run Meta diagnostic checks on a pixel.
**API:** `GET /{pixel_id}/da_checks`

```
pixel users --id <pixel_id> --business-id <business_id>
```
List users assigned to a pixel.
**API:** `GET /{pixel_id}/assigned_users`

#### Write Operations (require --execute)

```
pixel create --name "My Pixel" --execute
```
Create a new pixel (one per ad account).
**API:** `POST /{account}/adspixels`

```
pixel update --id <pixel_id> [--name "New Name"] [--enable-auto-matching true] [--matching-fields em,ph,fn,ln] [--data-use-setting ADVERTISING_AND_ANALYTICS] --execute
```
Update pixel settings.
**API:** `POST /{pixel_id}`

```
pixel share --id <pixel_id> --account-id <ad_account_id> --business-id <business_id> --execute
```
Share pixel with another ad account.
**API:** `POST /{pixel_id}/shared_accounts`

```
pixel unshare --id <pixel_id> --account-id <ad_account_id> --business-id <business_id> --execute
```
Unshare pixel from an ad account.
**API:** `DELETE /{pixel_id}/shared_accounts`

#### Conversions API (CAPI) Operations (require --execute)

```
pixel send-event --pixel-id <id> --event-name Purchase [--action-source website] [--email user@example.com] [--phone 1234567890] [--event-id evt_123] [--event-source-url https://...] [--value 99.99] [--currency USD] [--test-event-code TEST123] --execute
```
Send a single server-side event. PII fields (email, phone) are automatically SHA-256 hashed before sending.
**API:** `POST /{pixel_id}/events`

```
pixel send-batch --pixel-id <id> --file events.json [--test-event-code TEST123] --execute
```
Send batch events from a JSON file (up to 1000 per batch, auto-chunked).
**API:** `POST /{pixel_id}/events`

```
pixel validate-events --file events.json
```
Validate events locally without making any API call. Checks required fields and provides warnings.

#### Audience Operations (require --execute)

```
pixel audience-create --pixel-id <id> --name "All Visitors 30d" --rule '{"inclusions":...}' [--retention-days 30] [--prefill true] --execute
```
Create a website custom audience from pixel event rules.
**API:** `POST /{account}/customaudiences`

---

## 21. plan

Full plan lifecycle management. Plans are JSON files in `state/plans/`.

### `plan create`

```
apb plan create [--account act_xxx] [--campaign <id>] [--name "..."] [--spec-file <payload.json>] [--mode <mode>] [--strategy <strategy>] [--json]
```

Creates a new execution plan from a campaign context and optional spec file.

### `plan validate`

```
apb plan validate --plan-id <id> [--json]
```

Validates plan payload, runs `validate_only` preflight if supported, computes blast radius, generates rollback blueprint.

**Blast radius scores:** 1=MINIMAL, 2=LOW, 3=MODERATE, 4=HIGH, 5=CRITICAL

**Supported plan actions:**

| Action | Blast | Risk | Notes |
|---|---|---|---|
| `campaign.update-status` | 3 | MODERATE | PATCH campaign status |
| `campaign.duplicate` | 4 | HIGH | Creates new campaign + adsets + ads |
| `campaign.delete` | 5 | CRITICAL | `DELETE /{id}` — irreversible, cascades |
| `adset.update-budget` | 2 | LOW | PATCH daily_budget |
| `adset.update-targeting` | 3 | MODERATE | PATCH targeting spec |
| `adset.update-advantage` | 2 | LOW | PATCH targeting_automation flags |
| `adset.delete` | 5 | CRITICAL | `DELETE /{id}` — irreversible |
| `ad.update-status` | 2 | LOW | PATCH ad status |
| `ad.create` | 2 | LOW | Creates paused ad |
| `ad.delete` | 5 | CRITICAL | `DELETE /{id}` — irreversible |
| `creative.create-image` | 1 | MINIMAL | No spend impact |
| `creative.create-video` | 1 | MINIMAL | No spend impact |

`*.delete` actions dispatch through `graph_delete` (HTTP DELETE); all others use `graph_post` (which Meta overloads for create + PATCH).

### `plan execute` (WRITE)

```
apb plan execute --plan-id <id> --execute [--json]
```

Requires:
- Plan status = `VALIDATED`
- All 4 write gates open
- Quota pressure below critical

Produces: pre/post snapshots, API result, execution artifact in `state/executions/`.

### `plan execute-safe` (WRITE)

```
apb plan execute-safe --plan-id <id> [--dry-run] [--allow-preflight-inconclusive] [--allow-no-preflight] [--require-dry-run-pass] [--json]
```

Runs `plan doctor` checks, then executes only if all checks pass.

### `plan doctor`

```
apb plan doctor --plan-id <id> [--json]
```

Preflight check: plan status, write gates, quota pressure, exact next step.

### `plan review-batch`

```
apb plan review-batch [--status VALIDATED] [--limit N] [--json]
```

### `plan approve-batch`

```
apb plan approve-batch [--status VALIDATED] [--limit N] [--json]
```

### `plan canary` (WRITE)

```
apb plan canary [--status VALIDATED] [--dry-run] [--json]
```

Execute-safe the first matching plan as a canary deployment.

### `plan list`

```
apb plan list [--status <filter>] [--json]
```

---

## 22. policy

### `policy profile set`

```
apb policy profile set --profile <dev|staging|prod> [--json]
```

**Profiles:**
- `dev` — strict_mode=false, allow_risk_overrides=true
- `staging` — strict_mode=true, allow_risk_overrides=true
- `prod` — strict_mode=true, allow_risk_overrides=false

### `policy profile show`

```
apb policy profile show [--json]
```

---

## 23. dataset

Advanced analytics with contract envelope schemas. All commands are read-only.

### `dataset readiness`

```
apb dataset readiness [--days N] [--json]
```

Health summary with bottlenecks and thresholds.

### `dataset learning-velocity`

```
apb dataset learning-velocity --campaign <id> [--adset <id>] [--days N] [--json]
```

Weekly velocity vs learning-phase thresholds.

### `dataset learning-state`

```
apb dataset learning-state [--days N] [--json]
```

Explicit adset-level learning-state classifier with threshold gaps.

### `dataset clone-plan`

```
apb dataset clone-plan --source <campaign_id> [--name ...] [--json]
```

Read-only clone payload map (no writes).

### `dataset bundle`

```
apb dataset bundle --campaign <id> --days N [--path <dir>] [--json]
```

Bundled readiness + velocity + clone-plan output.

### `dataset scale-forecast`

```
apb dataset scale-forecast [--account act_xxx] [--campaign <id>] [--budget <usd>] [--days N] [--json]
```

Predict conversions/revenue for budget scaling.

### `dataset execution-plan`

```
apb dataset execution-plan --days N [--campaign <id>] [--json]
```

Prioritised execution steps from diagnostics.

### `dataset targeting-pack`

```
apb dataset targeting-pack --query "..." [--limit N] [--json]
```

Normalised targeting research pack.

### `dataset creative-pipeline`

```
apb dataset creative-pipeline --days N [--limit N] [--json]
```

Creative lifecycle analysis: keep, refresh, or retire.

### `dataset report-contract-v2`

```
apb dataset report-contract-v2 [--days N] [--level campaign|adset|ad] [--attribution ...] [--action-report-time ...] [--use-account-attribution ...] [--json]
```

Enhanced report with attribution metadata and provenance envelope.

### `dataset schema-validate`

```
apb dataset schema-validate --all [--json]
```

Validate contract envelopes for all dataset commands.

### `dataset scenario`

```
apb dataset scenario --campaign <id> --budget <usd> --event <evt> --creative-velocity <n_per_week> --days N [--json]
```

Projected outcomes with risk flags and preconditions.

### `dataset action-queue`

```
apb dataset action-queue [--status pending|validated|executed|failed] [--json]
```

List action plans by status.

### `dataset pixel-health`

```
apb dataset pixel-health [--pixel-id <id>] [--json]
```

### `dataset pixel-events`

```
apb dataset pixel-events [--pixel-id <id>] [--days N] [--json]
```

### `dataset pixel-signal`

```
apb dataset pixel-signal [--days N] [--json]
```

Pixel event continuity and drop-off alerts.

### `dataset pixel-quality`

```
apb dataset pixel-quality [--days N] [--json]
```

Pixel/CAPI quality heuristics and recommendations.

### `dataset agency-ops`

```
apb dataset agency-ops [--days N] [--json]
```

Unified operations cockpit: learning state summary, pixel signal summary, plan queue summary, priority actions.

---

## 24. library

Ads Library search for competitor research. Requires separate Meta Ad Library API approval.

### `library search`

```
apb library search [--terms "search query"] [--countries US,GB,...] [--ad-type political_and_issue_ads|all] [--limit N] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--terms` | string | — | Search terms |
| `--countries` | string | — | Comma-separated country codes |
| `--ad-type` | string | — | Ad type filter (alias: `--type`) |
| `--limit` | u32 | — | Max results |

**API:** `GET /ads_archive`

---

## 25. sync

Local state synchronization.

### `sync pull`

```
apb sync pull [--account act_xxx] [--json]
```

Snapshot campaigns, adsets, and ads to local state. Keeps last 20 snapshots.

### `sync diff`

```
apb sync diff [--json]
```

Compare latest vs previous snapshot. Shows added, removed, and status-changed entities.

---

## 26. split-test

Purpose-built A/B workflow orchestration.

### `split-test create` (WRITE)

```bash
apb split-test create \
  --name "Spring Offer Split" \
  --variant-a-adset 120200001 --variant-a-ad 120300001 \
  --variant-b-adset 120200002 --variant-b-ad 120300002 \
  --daily-budget 20 \
  --objective OUTCOME_SALES \
  --hypothesis "Variant B CTA will improve purchases" \
  --duration-days 7 \
  [--launch-now] [--execute] [--json]
```

Creates:
- 1 new campaign (`PAUSED` unless `--launch-now`)
- 2 cloned adsets (A/B) with half-budget each (min 100 cents)
- 2 ads in the new adsets using source creative IDs
- Manifest at `state/split-tests/<test_id>.json`

### `split-test status`

```bash
apb split-test status --id st_xxxxxxxx [--json]
```

Reads manifest and fetches campaign/adset/ad current statuses.

### `split-test evaluate`

```bash
apb split-test evaluate --id st_xxxxxxxx [--days 7] [--kpi purchase|roas|cpa|ctr] [--json]
```

Computes per-variant metrics:
- spend, clicks, ctr
- purchases, purchase_value
- roas, cpa

Returns winner plus confidence note.

### `split-test promote` (WRITE)

```bash
apb split-test promote --id st_xxxxxxxx --winner A|B [--scale 1.5] [--execute] [--json]
```

Pauses loser adset, activates/scales winner adset, and appends decision log in manifest.

---

## 27. andromeda

Practical volume planning + launch scaffolding.

### `andromeda plan`

```bash
apb andromeda plan \
  --campaign 120000000000001 \
  --adset 120000000000101 \
  --volume 24 \
  --angles "Problem/Solution,UGC Proof,Offer Stack" \
  --formats image,video \
  --days 14 \
  --json
```

Outputs and persists:
- `recommended_volume` (clamped 10..50)
- `angle_matrix[]`
- `variant_blueprints[]` (name, angle, format, hook template, cta template)
- `suggested_next_commands[]`
- Manifest at `state/andromeda/<plan_id>.json`

### `andromeda launch` (WRITE scaffold)

```bash
apb andromeda launch \
  --plan-id andromeda_xxx \
  --adset 120000000000101 \
  --creative-ids 123,456,789 \
  --status PAUSED \
  [--execute] [--json]
```

Behavior:
- Creates ads into target adset using provided creative IDs (via ad create flow)
- If `--creative-ids` is omitted, returns actionable preview/instructions
- Persists launch decisions/events into the plan manifest

---

## 28. duplicate

### `duplicate`

Top-level alias for `campaign duplicate`. Identical flags and behaviour — exists for convenience because campaign duplication is a frequent, standalone operation.

```
apb duplicate --id <campaign_id> [--name "..."] [--execute] [--json]
```

| Flag | Type | Description |
|------|------|-------------|
| `--id` | string | Source campaign ID |
| `--campaign` | string | Alternative to `--id` (alias) |
| `--name` | string | Optional name for the duplicate; defaults to `<source name> (copy)` |

See `### \`campaign duplicate\`` for the full behaviour notes (cascading adset/ad copies, status mapping, blast radius).

---

## 29. rules

Automated rules management — create, list, enable/disable, and apply pre-built agency templates for Meta's `adrules_library` API.

### `rules list`

```
apb rules list [--json]
```

List all automated rules for the ad account.

**API:** `GET /{account}/adrules_library`

### `rules get`

```
apb rules get --id <rule_id> [--json]
```

Get rule details including schedule, evaluation spec, and execution spec.

**API:** `GET /{rule_id}`

### `rules create` (WRITE)

```
apb rules create --name "Rule Name" --spec-file <rule.json> [--execute] [--json]
```

Create a rule from a JSON spec file. The spec must contain `evaluation_spec` and `execution_spec` per Meta's adrules API format.

**API:** `POST /{account}/adrules_library`

### `rules update` (WRITE)

```
apb rules update --id <rule_id> [--spec-file <rule.json>] [--name "New Name"] [--execute] [--json]
```

Update an existing rule. Accepts a partial spec file and/or a new name.

**API:** `POST /{rule_id}`

### `rules delete` (WRITE, DESTRUCTIVE)

```
apb rules delete --id <rule_id> --confirm-destructive [--execute] [--json]
```

Delete a rule. Requires `--confirm-destructive` flag.

**API:** `DELETE /{rule_id}`

### `rules enable` (WRITE)

```
apb rules enable --id <rule_id> [--execute] [--json]
```

Enable a disabled rule.

**API:** `POST /{rule_id}` (sets `status: ENABLED`)

### `rules disable` (WRITE)

```
apb rules disable --id <rule_id> [--execute] [--json]
```

Disable an active rule without deleting it.

**API:** `POST /{rule_id}` (sets `status: DISABLED`)

### `rules preview`

```
apb rules preview --id <rule_id> [--json]
```

Preview which entities (campaigns, adsets, ads) would be affected by the rule's current evaluation spec. Read-only dry run.

**API:** `POST /{rule_id}/preview`

### `rules execute` (WRITE)

```
apb rules execute --id <rule_id> --execute [--json]
```

Manually trigger a scheduled rule immediately. Requires `--execute` flag.

**API:** `POST /{rule_id}/execute`

### `rules templates list`

```
apb rules templates list [--json]
```

List all 8 pre-built agency rule templates.

### `rules templates apply` (WRITE)

```
apb rules templates apply --name <template_name> [--threshold N] [--spend-threshold N] [--days N] [--execute] [--json]
```

Create a rule from a pre-built template with optional parameter overrides.

**Pre-built templates:**

| Template | Description |
|----------|-------------|
| `kill-high-cpa` | Pause adsets where CPA exceeds threshold |
| `kill-zero-results` | Pause adsets with spend but 0 conversions |
| `scale-winner` | +20% budget on low-CPA high-volume adsets |
| `pause-high-frequency` | Pause adsets with frequency > threshold |
| `low-ctr-alert` | Notify when CTR drops below threshold |
| `budget-cap-guard` | Alert when daily spend exceeds cap |
| `reactivate-improved` | Unpause adsets improved to target CPA |
| `scale-roas` | +15% budget on campaigns with ROAS above target |

---

## 30. alias

Manage ID aliases — save frequently-used IDs as `@shortname` for use in any command.

Aliases are stored locally at `~/.apb/config.json`. No scope/tier required.

### `alias set`

Save an alias.

```
apb alias set <name> <id>
```

| Argument | Type | Description |
|----------|------|-------------|
| `name` | string | Alias name (used as `@name` in commands) |
| `id` | string | Target Meta API ID |

**Example:**
```bash
apb alias set retarget 120239538597430265
apb campaign get --id @retarget   # resolves to 120239538597430265
```

### `alias remove`

Remove an alias.

```
apb alias remove <name>
```

### `alias list`

List all saved aliases.

```
apb alias list [--json]
```

---

## 31. catalog

Product catalogs and product sets — the foundation for **DPA** (Dynamic Product Ads) and **Advantage+ Shopping** campaigns. Catalogs are *business-level* resources, not ad-account-scoped — `apb catalog list` enumerates catalogs across every business the connected user can administer (via `/me/businesses` → `/{business_id}/owned_product_catalogs`).

**Required scope**: `read:catalogs` (Professional tier and higher). Sprint 002 ships read-only; write operations (`catalog create`, `product-set create`/`update`/`delete`, `creative create-collection`) land in Sprint 003.

### `catalog list`

List product catalogs owned by businesses the connected user can administer.

```
apb catalog list [--limit <n>] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--limit` | u32 | 25 | Max results across all businesses (aggregated) |

**Example:**
```bash
apb catalog list --json
# [
#   {
#     "id": "1234567890",
#     "name": "Coffee Beans Catalog",
#     "vertical": "commerce",
#     "product_count": 42,
#     "owner_business_id": "1589175082138188"
#   }
# ]
```

Returns `[]` if the connected user owns no catalogs (or has no business affiliations). This is a valid empty state — many tenants connect Meta but don't run DPA.

### `catalog get`

Get full detail for a single catalog by ID.

```
apb catalog get --id <catalog_id> [--json]
```

Returns: `id`, `name`, `vertical`, `store`, `owner_business`, `product_count`, `default_image_url`.

### `catalog products`

List products in a catalog. Paginated — pass the prior response's `paging.cursors.after` value via `--after` to fetch the next page.

```
apb catalog products --id <catalog_id> [--limit <n>] [--after <cursor>] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--id` | string | required | Catalog ID |
| `--limit` | u32 | 25 | Page size |
| `--after` | string | — | Pagination cursor from prior response |

Fields returned per product: `id`, `name`, `description`, `image_url`, `price`, `availability`, `brand`, `retailer_id`.

### `catalog product-sets`

List product sets within a catalog. Product sets are filtered subsets of products — used to scope DPA / Advantage+ Shopping ad sets.

```
apb catalog product-sets --id <catalog_id> [--limit <n>] [--json]
```

Fields: `id`, `name`, `product_count`, `filter` (the product-set rule expression).

### `catalog product-feeds`

List product feeds for a catalog — useful for monitoring stale or failed feed uploads. `latest_upload` includes timestamps + error counts when ingestion fails.

```
apb catalog product-feeds --id <catalog_id> [--json]
```

Fields: `id`, `name`, `latest_upload`, `schedule`, `product_count`.

### `catalog create` (WRITE — Sprint 003)

Create a new product catalog. **Required scope**: `write:catalogs` (Agency tier and higher).

```
apb catalog create --name <name> [--vertical <v>] [--business-id <id>] [--execute] [--json]
```

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--name` | string | required | Catalog name |
| `--vertical` | string | — | One of `commerce`, `vehicles`, `hotels`, `flights`, `destinations`, `home_listings`, `media_title`, `offline_commerce`, etc. Pass-through to Meta. |
| `--business-id` | string | auto-discover | Override auto-discovery; required when the user has 0 or >1 businesses |

Auto-discovery hits `/me/businesses?limit=2` and errors if 0 or >1 businesses come back, prompting the user to pass `--business-id` explicitly.

### `catalog update` (WRITE)

Update catalog fields. Currently only `--name` is mutable post-create — Meta freezes `vertical` and other catalog properties at create time.

```
apb catalog update --id <catalog_id> [--name <new_name>] [--execute] [--json]
```

Passing only `--id` is a no-op (returns dry-run with empty `changes`).

### `catalog product-set-create` (WRITE)

Create a product set — a filtered subset of products used to scope DPA / Advantage+ Shopping ad sets.

```
apb catalog product-set-create --catalog-id <id> --name <name> --filter <JSON> [--execute] [--json]
```

| Flag | Type | Description |
|------|------|-------------|
| `--catalog-id` | string | Parent catalog ID |
| `--name` | string | Product set name |
| `--filter` | JSON | Meta-typed filter expression (pass-through) |

**Filter examples:**
```bash
# Products with "premium" in their type
--filter '{"product_type":{"i_contains":"premium"}}'

# Only in-stock items
--filter '{"availability":{"eq":"in stock"}}'

# Combined: in-stock AND brand starts with "Acme"
--filter '{"and":[{"availability":{"eq":"in stock"}},{"brand":{"i_starts_with":"Acme"}}]}'
```

Meta returns clear error messages for invalid filter shapes; we don't validate client-side.

### `catalog product-set-update` (WRITE)

Update an existing product set. Both `--name` and `--filter` are optional; passing neither is a no-op.

```
apb catalog product-set-update --id <product_set_id> [--name <name>] [--filter <JSON>] [--execute] [--json]
```

### `catalog product-set-delete` (WRITE, IRREVERSIBLE)

Hard-delete a product set via the Graph API `DELETE /{product_set_id}` verb.

```
apb catalog product-set-delete --id <product_set_id> --execute --confirm-destructive [--json]
```

Requires both `--execute` and `--confirm-destructive`. Terminal — there is no archive/unarchive equivalent for product sets; deletion is permanent.

---

## 32. custom-conversion

URL-rule conversion event primitive — Meta's mechanism for defining custom optimization targets on top of pixel/CAPI events. A custom conversion lets you say "a purchase, but only on /checkout/complete" or "a lead, but only when the URL contains /enterprise/" without modifying the pixel code on your site. Once defined, the conversion ID is referenced as `--promoted-object` on adsets to drive conversion-optimized delivery.

**Required scope**: `read:custom-conversions` (Professional+) for read; `write:custom-conversions` (Agency+) for create/update/delete.

Custom conversions are **account-scoped** — `apb custom-conversion list` returns conversions for the connected ad account. Each conversion references one pixel as its `event_source_id` (auto-discovered, override with `--event-source-id` for multi-pixel accounts).

### `custom-conversion list`

```
apb custom-conversion list [--limit <n>] [--json]
```

Returns array of `{id, name, custom_event_type, event_source_id, creation_time}`. Empty array is a valid response for accounts with no custom conversions configured.

### `custom-conversion get`

```
apb custom-conversion get --id <conversion_id> [--json]
```

Full detail: `id`, `name`, `description`, `custom_event_type`, `event_source_id`, `event_source_type`, `rule`, `default_conversion_value`, `creation_time`, `last_fired_time`, `is_archived`, `is_unavailable`.

### `custom-conversion create` (WRITE)

```
apb custom-conversion create --name <name> --custom-event-type <TYPE> --rule <JSON> [--event-source-id <pixel_id>] [--event-source-type pixel] [--description <text>] [--default-conversion-value <usd>] [--execute] [--json]
```

| Flag | Type | Description |
|------|------|-------------|
| `--name` | string | Required. Display name for the conversion. |
| `--custom-event-type` | string | Required. One of Meta's standard event types: `PURCHASE`, `LEAD`, `COMPLETE_REGISTRATION`, `ADD_TO_CART`, `INITIATE_CHECKOUT`, `VIEW_CONTENT`, `SEARCH`, `SUBSCRIBE`, `START_TRIAL`, `CONTACT`, `SCHEDULE`, `SUBMIT_APPLICATION`, `OTHER`, etc. Pass-through string. |
| `--rule` | JSON | Required. URL-match expression (see examples). |
| `--event-source-id` | string | Pixel ID. Auto-discovered if omitted; required when the user has 0 or >1 pixels. |
| `--event-source-type` | string | Defaults to `pixel`. Pass-through. |
| `--description` | string | Free-form description. |
| `--default-conversion-value` | f64 | Default conversion value in USD (used by Meta for VALUE optimization). |

**Rule examples:**

```bash
# Match any URL containing "checkout/complete"
--rule '{"and":[{"_url":{"i_contains":"checkout/complete"}}]}'

# Match thank-you pages but exclude refund pages
--rule '{"and":[{"_url":{"i_contains":"thank-you"}},{"_url":{"not_contains":"refund"}}]}'

# Match domain-specific URL patterns
--rule '{"and":[{"_domain":{"i_contains":"shop.example.com"}},{"_url":{"i_contains":"order/"}}]}'
```

Meta returns clear errors for invalid rule shapes; we don't validate client-side.

### `custom-conversion update` (WRITE)

```
apb custom-conversion update --id <conversion_id> [--name <name>] [--description <text>] [--default-conversion-value <usd>] [--execute] [--json]
```

**Important**: Meta freezes `rule`, `custom_event_type`, and `event_source_id` at creation time — only `--name`, `--description`, and `--default-conversion-value` are mutable post-create. To change the rule expression, delete and recreate.

Empty body (no flags) → dry-run with `changes: {}` (no-op).

### `custom-conversion delete` (WRITE, IRREVERSIBLE)

```
apb custom-conversion delete --id <conversion_id> --execute --confirm-destructive [--json]
```

Hard-deletes via `DELETE /{custom_conversion_id}`. Terminal — there is no archive equivalent. **Cannot delete a conversion currently set as `--promoted-object` on any active adset** — Meta will return error code 100 `in use`. Detach the conversion from all adsets first (via `apb adset update --id <X> --promoted-object '{}'` or by changing the optimization target) before deleting.

---

## 33. leadgen

Lead-generation forms — Meta's inline form system attached to Lead-objective ad campaigns. Users fill out the form without leaving Facebook/Instagram; their responses become "leads" containing PII (name, email, phone, custom-question responses).

**Required scopes** (three-way split):
- **`read:leadgen`** (Professional+) — read form metadata: list, get
- **`write:leadgen`** (Agency+) — create forms
- **`read:leadgen:export`** (Agency+) — read lead PII: leads, leads-export

The PII split is intentional. A Professional-tier customer can audit which forms exist and what questions they ask, but cannot pull submission data — that requires Agency or higher. **Lead `field_data` is never written to the JSONL audit log**; the service-layer logging discipline records only `{form_id, since, until, lead_count}`.

**Meta-side caveat**: lead retrieval requires the `leads_retrieval` Meta OAuth permission AND a Page Access Token (vs the user/system-user token on the connected Meta OAuth). Tokens connected via the standard `connect-meta` flow may need to be re-authorized to grant Page Access. If you see `(#190) This method must be called with a Page Access Token`, the form list/leads paths are blocked until re-auth. Form metadata reads still work.

### `leadgen list`

```
apb leadgen list [--page-id <id>] [--limit <n>] [--json]
```

`--page-id` auto-discovers via `discover_page_id()` if omitted; errors if the user has 0 or >1 Pages.

### `leadgen get`

```
apb leadgen get --id <form_id> [--json]
```

Full form detail: questions array, privacy_policy_url, legal_content, follow_up_action_url, context_card, tracking_parameters, locale.

### `leadgen create` (WRITE — requires `write:leadgen`)

```
apb leadgen create --page-id <id> --spec-file <spec.json> [--execute] [--json]
```

The full spec includes `name`, `questions[]`, `privacy_policy_url`, `legal_content`, `follow_up_action_url`, `tracking_parameters`. See `docs/examples/leadgen-form-spec.json` for a working example. Meta freezes most form fields post-create.

### `leadgen leads` (READ PII — requires `read:leadgen:export`)

```
apb leadgen leads --form-id <id> [--since YYYY-MM-DD] [--until YYYY-MM-DD] [--limit <n>] [--after <cursor>] [--json]
```

Returns lead records including `field_data` (the submitter's responses). Paginated via `--after` cursor from `paging.cursors.after` in the prior response.

### `leadgen leads-export` (READ PII — requires `read:leadgen:export`)

```
apb leadgen leads-export --form-id <id> [--since YYYY-MM-DD] [--until YYYY-MM-DD] [--output <path>] [--format csv|json] [--all]
```

Bulk-export leads. Defaults to **CSV** (CRM-friendly). `--format json` returns a JSON array.

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--form-id` | string | required | Form to export |
| `--since` / `--until` | YYYY-MM-DD | — | Date filter on `time_created` |
| `--output` | string | stdout | Output file path |
| `--format` | string | `csv` | `csv` or `json` |
| `--all` | bool | false | Follow pagination cursors (use for forms with thousands of leads) |

**CSV format**: header row is `id,created_time,ad_id,adset_id,campaign_id,form_id,is_organic,platform,<question_shortname1>,<question_shortname2>,...` with question columns derived from the form's question definitions. Field values are CSV-escaped (commas, quotes, newlines wrapped in quotes per RFC 4180).

**Example**:
```bash
# Export last week's leads as CSV to a file
apb leadgen leads-export --form-id 12345 \
    --since 2026-04-19 --until 2026-04-26 \
    --output /tmp/leads.csv --all

# Same window as JSON to stdout
apb leadgen leads-export --form-id 12345 \
    --since 2026-04-19 --format json | jq '.[].field_data'
```
