# API Reference

Internal API documentation for the `apb` Rust codebase. Covers all public types, functions, and module interfaces.

---

## Module Layout

```
src/
├── main.rs              Entry point
├── cli.rs               CLI type definitions (clap derive)
├── config.rs            Configuration and write gates
├── error.rs             Error types and classification
├── logger.rs            JSONL structured logging
├── api/
│   ├── mod.rs           Re-exports
│   ├── client.rs        MetaClient — HTTP client with retry
│   └── usage.rs         UsageHeaders — rate-limit header parsing
├── output/
│   ├── mod.rs           Re-exports
│   └── printer.rs       Output formatting (JSON / table)
├── state/
│   ├── mod.rs           Re-exports
│   ├── snapshot.rs      Snapshot persistence and diffing
│   ├── plans.rs         Plan CRUD, actions, blast radius
│   ├── executions.rs    Execution artifact storage
│   └── policy.rs        Policy profile management
└── commands/
    ├── mod.rs           CommandContext + dispatch()
    ├── common.rs        Shared helpers and constants
    └── *.rs             One file per domain (30 modules, includes split_test.rs)
```

---

## `config::Config`

```rust
pub struct Config {
    pub access_token: String,         // META_ACCESS_TOKEN (required)
    pub graph_version: String,        // META_GRAPH_VERSION (default: "v25.0")
    pub graph_base: String,           // META_GRAPH_BASE (default: "https://graph.facebook.com")
    pub ad_account_id: Option<String>,// META_AD_ACCOUNT_ID (auto-discovered if absent)

    pub read_only: bool,              // READ_ONLY != "false" → true (default: true)
    pub allow_writes: bool,           // ALLOW_WRITES == "true" → true (default: false)
    pub strict_mode: bool,            // META_CTL_STRICT_MODE != "false" → true
    pub allow_risk_overrides: bool,   // META_CTL_ALLOW_RISK_OVERRIDES == "true"
    pub operator_override: bool,      // META_CTL_ALLOW_MUTATIONS == "true"

    pub max_retries: u32,             // META_MAX_RETRIES (default: 3)
    pub retry_base_ms: u64,           // Base retry delay (default: 1000)

    pub log_dir: String,              // "logs"
    pub state_dir: String,            // "state"
    pub plans_dir: String,            // "state/plans"
    pub executions_dir: String,       // "state/executions"
}
```

### Methods

```rust
/// Load from environment. Fails immediately if META_ACCESS_TOKEN is missing.
Config::from_env() -> Result<Arc<Config>, MetaError>

/// Returns true only when !read_only && allow_writes.
config.can_write() -> bool

/// Check all 4 write gates. Returns (allowed: bool, reasons: Vec<String>).
config.check_write_gates(execute_flag: bool) -> WriteGateResult
```

### WriteGateResult

```rust
pub struct WriteGateResult {
    pub allowed: bool,        // true only when all 4 gates are open
    pub reasons: Vec<String>, // list of blocked reasons (empty when allowed)
}
```

**4 gates (all must pass):**
1. `execute_flag` — `--execute` passed on CLI
2. `!read_only` — `READ_ONLY=false` in env
3. `allow_writes` — `ALLOW_WRITES=true` in env
4. `operator_override` — `META_CTL_ALLOW_MUTATIONS=true` in env

---

## `error::MetaError`

```rust
pub enum MetaError {
    Api { message, status, code, subcode, error_class },
    RateLimit { message, retry_after_ms },
    Auth(String),
    Validation(String),
    Network(String),
    Config(String),
    Io(std::io::Error),
    WriteBlocked { reasons: Vec<String> },
    User(String),
}
```

### ErrorClass

```rust
pub enum ErrorClass {
    Auth,        // HTTP 401/403, code 190/200, "access token"/"oauth"
    Permission,  // "permission", "does not have permission"
    RateLimit,   // HTTP 429, code 4/17/613, subcode 2446079
    Validation,  // HTTP 400, code 100/2
    Api5xx,      // HTTP 500-599
    Network,     // Connection/timeout errors
    Unknown,     // Everything else
}
```

### classify_api_error

```rust
pub fn classify_api_error(
    status: Option<u16>,
    code: Option<i64>,
    subcode: Option<i64>,
    message: &str,
) -> ErrorClass
```

Classifies a Meta Graph API error response into a typed `ErrorClass`.

### MetaApiErrorResponse

```rust
pub struct MetaApiErrorResponse {
    pub error: Option<MetaApiErrorDetail>,
}

pub struct MetaApiErrorDetail {
    pub message: Option<String>,
    pub code: Option<i64>,
    pub error_subcode: Option<i64>,
    pub error_type: Option<String>,
    pub fbtrace_id: Option<String>,
}
```

---

## `api::MetaClient`

HTTP client for the Meta Graph API with retry, backoff, and ad account discovery.

### Construction

```rust
MetaClient::new(config: Arc<Config>) -> Result<MetaClient, MetaError>
```

Creates a `reqwest::Client` with:
- Connect timeout: **10 seconds**
- Response timeout: **45 seconds**

If `config.ad_account_id` is set, it is pre-populated in the `OnceCell`.

### API Methods

```rust
/// GET request with retry/backoff.
async fn graph_get(
    &self,
    endpoint: &str,        // e.g. "me/adaccounts", "{acct}/campaigns"
    params: &[(&str, &str)],
) -> Result<Value, MetaError>

/// POST request with retry/backoff.
async fn graph_post(
    &self,
    endpoint: &str,
    body: &Value,
    params: &[(&str, &str)],
) -> Result<Value, MetaError>

/// Discover first ad account. Thread-safe OnceCell — called at most once.
async fn discover_ad_account(&self) -> Result<String, MetaError>

/// Get last captured usage headers (from most recent API call).
async fn get_last_usage(&self) -> Option<(UsageHeaders, String)>
```

### URL Construction

```
{graph_base}/{graph_version}/{endpoint}?access_token={token}&{params...}
```

Example: `https://graph.facebook.com/v25.0/me/adaccounts?access_token=EAA...&fields=id,name&limit=5`

### Retry/Backoff

All requests use `request_with_retry` internally:

- **Max retries:** `config.max_retries` (default 3)
- **Retryable conditions:** rate limits, HTTP 5xx, connection errors, timeouts
- **Rate limit delay:** `jitter(8000ms * 2^attempt)` — 8s, 16s, 32s
- **Other retry delay:** `jitter(1000ms * 2^attempt)` — 1s, 2s, 4s
- **Jitter:** `+rand(0..400ms)`

### Rate Limit Detection

A response is classified as rate-limited if any of:
- HTTP status 429
- Error code 4 (application request limit)
- Error code 17 (user request limit)
- Error code 613 (API call rate limit)
- Error subcode 2446079
- Message contains "request limit", "rate limit", or "too many calls"

### Logging

Every API call logs (with the token redacted):
- `api_request` — method, endpoint, param keys (never values)
- `api_response` — endpoint, status
- `api_error` — endpoint, status, attempt, retryable, message
- `api_backoff` — endpoint, attempt, delay_ms

---

## `api::UsageHeaders`

```rust
pub struct UsageHeaders {
    pub app: Option<Value>,   // x-app-usage header (parsed JSON)
    pub page: Option<Value>,  // x-page-usage header
    pub ad: Option<Value>,    // x-ad-account-usage header
}
```

### Methods

```rust
UsageHeaders::from_headers(headers: &HeaderMap) -> Self
usage.has_data() -> bool
usage.peak_pressure() -> f64  // 0-100, max across call_count/total_cputime/total_time/acc_id_util_pct
```

---

## `output::printer`

```rust
/// Print data as JSON or human-readable table.
pub fn print_output(data: &Value, json_mode: bool, label: &str)

/// Print error and exit with code 1.
pub fn die(msg: &str) -> !
```

**JSON mode:** Pretty-printed `serde_json::to_string_pretty`.

**Human mode:**
- `Value::Array` of objects → ASCII table with column widths auto-calculated
- `Value::Object` → key-value list
- Other → plain string

---

## `logger`

JSONL structured logging to `logs/apb.jsonl`.

```rust
pub fn info(log_dir: &str, event: &str, data: Value)
pub fn warn(log_dir: &str, event: &str, data: Value)
pub fn error(log_dir: &str, event: &str, data: Value)
pub fn action_log(log_dir: &str, entry: Value)  // → logs/apb-actions.jsonl
```

**Entry format:**
```json
{"ts":"2024-01-15T12:00:00Z","level":"info","event":"api_request","method":"GET","endpoint":"me/adaccounts"}
```

---

## `state::snapshot`

```rust
/// Push a new snapshot. Keeps last 20.
pub fn push_snapshot(
    state_dir: &str,
    campaigns: Vec<Value>,
    adsets: Vec<Value>,
    ads: Vec<Value>,
) -> Snapshot

/// Get latest snapshot or None.
pub fn latest(state_dir: &str) -> Option<Snapshot>

/// Get previous (second-to-last) snapshot or None.
pub fn previous(state_dir: &str) -> Option<Snapshot>

/// Diff two snapshots. Returns {campaigns, adsets, ads} each with
/// {added, removed, status_changed, details}.
pub fn diff_snapshots(older: &Snapshot, newer: &Snapshot) -> Value
```

### Snapshot

```rust
pub struct Snapshot {
    pub ts: String,             // ISO 8601 timestamp
    pub campaigns: Vec<Value>,  // [{id, name, status, ...}]
    pub adsets: Vec<Value>,
    pub ads: Vec<Value>,
}
```

Stored in `state/apb.json` as `{"snapshots": [...]}`.

---

## `state::plans`

### Plan

```rust
pub struct Plan {
    pub plan_id: String,
    pub action: String,
    pub target_id: String,
    pub payload: Value,
    pub status: String,          // CREATED | VALIDATED | EXECUTED | INVALID | FAILED
    pub created_at: String,
    pub updated_at: String,
    pub blast_radius: Option<BlastRadius>,
    pub validation_errors: Vec<String>,
    pub rollback_blueprint: Option<Value>,
    pub dry_run_preview: Option<Value>,
}
```

### PlanAction

Type-safe plan action enum with string conversion.

```rust
pub enum PlanAction {
    CampaignUpdateStatus,   // "campaign.update-status"
    CampaignDuplicate,      // "campaign.duplicate"
    AdsetUpdateBudget,      // "adset.update-budget"
    AdsetUpdateTargeting,   // "adset.update-targeting"
    AdsetUpdateAdvantage,   // "adset.update-advantage"
    AdUpdateStatus,         // "ad.update-status"
    AdCreate,               // "ad.create"
    CreativeCreateImage,    // "creative.create-image"
    CreativeCreateVideo,    // "creative.create-video"
}
```

### PlanStatus

```rust
pub enum PlanStatus { Created, Validated, Executed, Invalid, Failed }
```

### BlastRadius

```rust
pub struct BlastRadius {
    pub score: u8,           // 1-5
    pub max: u8,             // always 5
    pub risk_level: String,  // MINIMAL | LOW | MODERATE | HIGH | CRITICAL
    pub description: String,
}
```

### Functions

```rust
pub fn gen_plan_id() -> String           // "plan_{base36_ts}_{hex8}"
pub fn save_plan(plans_dir, plan)
pub fn load_plan(plans_dir, plan_id) -> Option<Plan>
pub fn list_plans(plans_dir) -> Vec<Plan>
pub fn compute_blast_radius(action: &PlanAction) -> BlastRadius
pub fn ensure_plans_dir(plans_dir)
```

---

## `state::executions`

```rust
/// Save execution artifact to state/executions/{plan_id}_{timestamp}.json.
pub fn save_execution(executions_dir: &str, plan_id: &str, artifact: &Value)
```

---

## `state::policy`

```rust
pub struct PolicyProfile {
    pub profile: String,             // "dev" | "staging" | "prod"
    pub strict_mode: bool,
    pub allow_risk_overrides: bool,
    pub notes: String,
    pub updated_at: Option<String>,
}

pub fn profiles() -> Vec<PolicyProfile>  // dev, staging, prod
pub fn load_policy() -> Option<PolicyProfile>
pub fn save_policy(profile: &PolicyProfile)
```

---

## `commands::CommandContext`

```rust
pub struct CommandContext {
    pub client: MetaClient,
    pub config: Arc<Config>,
    pub json_output: bool,
}
```

Passed to every command handler. Provides the authenticated API client, configuration, and output mode.

---

## `commands::common`

### Constants

```rust
pub const CONVERSION_TYPES: &[&str]     // 8 conversion action types
pub const PURCHASE_TYPES: &[&str]       // 3 purchase action types

pub const LOW_CONVERSION_VOLUME: f64    // 10.0
pub const HIGH_FREQUENCY: f64           // 4.0
pub const LOW_CTR_PCT: f64              // 0.5
pub const HIGH_CPC_USD: f64             // 5.0
pub const LOW_SPEND_SIGNAL_USD: f64     // 10.0
pub const MEANINGFUL_SPEND_USD: f64     // 50.0
pub const SCALE_CTR_PCT: f64            // 1.5
pub const SCALE_CONVERSION_MIN: f64     // 20.0
pub const SCALE_CPC_USD: f64            // 2.0
```

### Functions

```rust
/// Sum conversion values across CONVERSION_TYPES.
pub fn extract_conversions(actions: &Value) -> f64

/// Extract a single action_type value from an actions array.
pub fn extract_action_value(actions: &Value, action_type: &str) -> f64

/// Sum values across multiple action types.
pub fn extract_action_value_multi(actions: &Value, types: &[&str]) -> f64

/// Sum purchase revenue from action_values array.
pub fn extract_purchase_value(action_values: &Value) -> f64

/// Returns (json_param, since_date, until_date) for a lookback window.
pub fn build_time_range(days: u32) -> (String, String, String)

/// Division that returns 0.0 when denominator is 0.
pub fn safe_div(num: f64, den: f64) -> f64

/// Round to 2 decimal places.
pub fn round2(n: f64) -> f64

/// Round to 4 decimal places.
pub fn round4(n: f64) -> f64
```

---

## `commands::dispatch`

```rust
/// Route CLI domain/action to the correct command handler.
pub async fn dispatch(cli: Cli, ctx: CommandContext) -> Result<(), MetaError>
```

Matches on `cli.domain` (24 variants), then on the nested action enum, extracting flags and calling the appropriate `async fn` in each command module.

---

## Command Handler Signatures

Every command handler follows this pattern:

```rust
pub async fn handler_name(ctx: &CommandContext, ...flags) -> Result<(), MetaError>
```

### Read commands

```rust
// 1. Discover ad account
let acct = ctx.client.discover_ad_account().await?;

// 2. Call Graph API
let data = ctx.client.graph_get(&format!("{acct}/campaigns"), &[
    ("fields", "id,name,status"),
    ("limit", &limit.to_string()),
]).await?;

// 3. Format and print
print_output(&json!(rows), ctx.json_output, "Campaigns:");
```

### Write commands

```rust
// 1. Check write gates
let gates = ctx.config.check_write_gates(execute);
if !gates.allowed {
    // Print DRY-RUN result
    return Ok(());
}

// 2. Execute API call
let acct = ctx.client.discover_ad_account().await?;
let result = ctx.client.graph_post(&format!("{acct}/campaigns"), &body, &[]).await?;

// 3. Print result
print_output(&result, ctx.json_output, "Campaign created:");
```

### Reporting API examples

```bash
# Custom metric pull
apb report metrics --level ad --days 7 \
  --metrics impressions,clicks,spend,ctr,cpc --limit 10 --json

# Preset execution
apb report presets run --name core-performance --days 7 --json

# Saved profile lifecycle
apb report profile save --name weekly --level campaign \
  --metrics impressions,clicks,spend,purchase_roas \
  --attribution 7d_click,1d_view --action-report-time conversion --json
apb report profile run --name weekly --days 7 --json
```

---

## Meta Graph API Endpoints Used

| Command | Method | Endpoint | Key Parameters |
|---------|--------|----------|----------------|
| auth test | GET | `debug_token` | input_token |
| auth test | GET | `me` | fields=id,name,email |
| auth test | GET | `me/adaccounts` | fields=id,name,account_status |
| account overview | GET | `{acct}` | fields=id,name,account_status,currency,... |
| account overview | GET | `{acct}/campaigns` | fields=id,status |
| account pages | GET | `me/accounts` or `{acct}/promote_pages` | fields=id,name,category,fan_count |
| campaign list | GET | `{acct}/campaigns` | fields,limit |
| campaign get | GET | `{id}` | fields (15 fields) |
| campaign create | POST | `{acct}/campaigns` | campaign spec body |
| campaign update-status | POST | `{id}` | {status} |
| adset list | GET | `{acct}/adsets` or `{campaign}/adsets` | fields,limit |
| adset update-budget | POST | `{id}` | {daily_budget} (in cents) |
| adset update-targeting | POST | `{id}` | {targeting} |
| ad list | GET | `{acct}/ads` or `{adset}/ads` | fields,limit |
| ad create | POST | `{acct}/ads` | {name,adset_id,status,creative} |
| creative list | GET | `{acct}/adcreatives` | fields,limit |
| creative create-carousel | POST | `{acct}/adcreatives` | {name,object_story_spec.link_data.child_attachments} |
| andromeda launch | POST | `{acct}/ads` | one ad create per creative_id |
| creative upload-image | POST | `{acct}/adimages` | multipart form |
| creative upload-video | POST | `{acct}/advideos` | multipart form |
| audience list | GET | `{acct}/customaudiences` | fields,limit |
| targeting interest-search | GET | `search` | type=adinterest,q=... |
| targeting geo-search | GET | `search` | type=adgeolocation,q=... |
| targeting estimate | GET | `{acct}/delivery_estimate` | targeting_spec |
| report insights | GET | `{acct}/insights` | fields,time_range,level |
| report metrics | GET | `{acct}/insights` | arbitrary fields + optional breakdowns/attribution/report-time/account-attribution |
| report presets run | GET | `{acct}/insights` | preset field packs |
| report profile run | GET | `{acct}/insights` | profile field packs |
| report breakdown | GET | `{acct}/insights` | fields,time_range,breakdowns |
| report insights-async start | POST | `{acct}/insights` | async report params |
| report insights-async status | GET | `{job_id}` | fields |
| report insights-async fetch | GET | `{job_id}/insights` | limit |
| sync pull | GET | `{acct}/campaigns` + `/adsets` + `/ads` | parallel fetch |
| split-test create | GET | `{source_adset}` / `{source_ad}` | fields for cloning + creative lineage |
| split-test create | POST | `{acct}/campaigns` | name, objective, status, special_ad_categories |
| split-test create | POST | `{acct}/adsets` | campaign_id, targeting, optimization_goal, billing_event, promoted_object, bid_strategy, budget |
| split-test create | POST | `{acct}/ads` | name, adset_id, creative.creative_id, status |
| split-test status | GET | `{campaign}` / `{adset}` / `{ad}` | status/effective_status + budget |
| split-test evaluate | GET | `{ad_id}/insights` | time_range, spend/clicks/ctr/actions/action_values |
| split-test promote | POST | `{adset_id}` | status and daily_budget updates |
| budget-schedule create | POST | `{campaign}/budget_schedules` | budget_value,time_start,time_end |

---

## File Outputs

| Path | Format | Description |
|------|--------|-------------|
| `logs/apb.jsonl` | JSONL | Structured event log (all API calls, commands) |
| `logs/apb-actions.jsonl` | JSONL | Action/mutation log |
| `state/apb.json` | JSON | Snapshot database (last 20 snapshots) |
| `state/plans/{plan_id}.json` | JSON | Individual plan files |
| `state/executions/{plan_id}_{ts}.json` | JSON | Execution artifacts |
| `state/split-tests/{test_id}.json` | JSON | Split-test manifest + decision log |
| `state/andromeda/{plan_id}.json` | JSON | Andromeda plan manifest + launch events |
| `state/report-profiles/{name}.json` | JSON | Saved report metric profiles |
| `state/policy-profile.json` | JSON | Active policy profile |
