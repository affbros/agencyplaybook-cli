# Changelog

All notable changes to the `apb` CLI binary distribution.

Format inspired by [Keep a Changelog](https://keepachangelog.com/). This file is mirrored to the public repo `affbros/agencyplaybook-cli` on every release tag.

## [Unreleased]

## [0.5.12] — 2026-06-10 (CLI hardening: credential-file permissions + Retry-After-aware cooldown)

No new commands (still **254 leaves / 248 endpoints**). Security + reliability patch. No breaking changes.

### Security
- **Credential files under `~/.apb` are now created with restrictive permissions** (`0700` directory, `0600` files) on Unix. Previously `~/.apb/credentials.json` (your SaaS API key), `~/.apb/tenant_context.json` (the resolved Meta access token), `~/.apb/config.json`, and the `.env` written by `apb auth login` inherited the process umask (typically world/group-readable `0644`), so any other local user on a shared or CI host could read your live API key and Meta OAuth token. New files are created `0600` from the start (no world-readable window) and a pre-existing loose file is re-tightened on the next write. No-op on non-Unix (Windows ACLs unaffected). CWE-732.

### Changed
- **Post-429 rate-limit cooldown now honors Meta's `Retry-After`.** When Meta returns a `Retry-After` on a 429, the cross-invocation filesystem cooldown uses that window (already capped at `META_BACKPRESSURE_MAX_RETRY_AFTER_SECS`, default 60s) instead of always applying the fixed 600s default. A transient 429 with a short `Retry-After` no longer hard-blocks the account for 10 minutes across every subsequent `apb` invocation; the 600s default still applies when Meta sends no `Retry-After`.

## [0.5.11] — 2026-06-08 (CLI polish: cleaner `auth test` output)

No new commands (still **254 leaves / 248 endpoints**). Follow-up to v0.5.10 that makes the `auth test` output less confusing. Patch bump — no breaking changes.

### Changed
- **`apb auth test` now omits `app_id` and `scopes` entirely when they can't be introspected** (no `META_APP_ID`/`META_APP_SECRET` configured, or a token Meta won't let self-introspect) — instead of showing `app_id: -` / `scopes: []` alongside a verbose `introspection_note`. The note (which also leaked an internal "Config error:" label) is removed. Connection status is carried clearly by `is_valid: true` + `user` + `ad_accounts`; `app_id`/`scopes` appear only when introspection actually succeeds (app creds set). Skill + CLI-reference docs updated to match.

## [0.5.10] — 2026-06-08 (CLI fix: `auth test` no longer reports a false `is_valid: false`)

No new commands (still **254 leaves / 248 endpoints**). Fixes a confusing false-negative in `apb auth test`. Patch bump — no breaking changes.

### Fixed
- **`apb auth test` no longer reports `is_valid: false` (and `app_id: -`, `scopes: []`) for a working token.** Those three fields came solely from Meta's `/debug_token`, which Meta authorizes **only with an app access token** — a user or system-user token can't introspect itself (`(#100) You must provide an app access token, or a user access token that is an owner or developer of the app`), and the rejection was silently swallowed. Now:
  - `is_valid` reflects reality — it's `true` whenever `/me` resolves the token (the same call that populates `user` and `ad_accounts`). A genuinely bad token still errors out the command.
  - `app_id`/`scopes` are introspected with the **app access token** (`META_APP_ID`|`META_APP_SECRET`) when configured, so they now populate correctly (e.g. a connected OAuth token reports its real `ads_management`/`ads_read`/… scopes instead of an empty list).
  - When introspection isn't available (no app creds configured, or a token Meta won't let self-introspect), a new **`introspection_note`** field explains why `app_id`/`scopes` are empty — instead of empty values that read as "no permissions / unknown app". (System-user tokens legitimately have no classic OAuth scopes; they use Business-asset permissions.)

New `MetaClient::introspect_token()` performs the app-token-authorized introspection (uncached; the app secret is never logged). The legacy duplicate `commands/auth.rs::test` now delegates to the single diagnostics implementation. (`apb doctor check` was unaffected — it validates the token via connectivity, not `/debug_token`.)

## [0.5.9] — 2026-06-08 (CLI fixes: A-tail mechanical scoping flags)

No new commands (still **254 leaves / 248 endpoints**); continues the flag-wiring backlog (`docs/tasks/2026-06-08-cli-conformance-findings.md`). Seven more parsed-but-dropped flags now reach the request. Patch bump — no breaking changes.

### Fixed
- **`dataset pixel-events --days <N>`** and **`dataset pixel-signal --event <name>`** now reach the pixel service (the `PixelService` methods already supported these; the dataset-alias dispatch arms were passing `None`). Windowed event stats / single-event signal filtering now work from the `dataset` alias, matching the `pixel` domain commands.
- **`dataset pixel-quality --days <N>`** now windows the pixel stats it scores (`start_time`/`end_time`) instead of always scoring all-time data.
- **`dataset pixel-health --pixel-id <id>`** now narrows the account-wide health sweep to a single pixel instead of being ignored.
- **`dataset creative-pipeline --campaign <id>`** and **`dataset targeting-pack --campaign <id>`** now scope to that campaign's insights/adsets edge (via `DatasetService::scope_node()`) instead of reporting account-wide.
- **`action plan --campaign <id>`** now scopes the autoplan insights sweep to one campaign instead of always scanning the whole account.

Names/`@alias` resolve via `resolve_campaign_id`. The flag-wiring lint baseline shrank 35 → **31** grandfathered arms. CLI-side wiring (the matching API endpoints pass `None`/default for now — API-side scoping remains a tracked follow-up). Several flags bundled into the same arms remain **deliberately deferred** as unbuilt features or state-model risks (`creative_velocity`, `spec_file`, `sync --campaign/--path`, `creative asset-audit --campaign`, `action apply --action`, `dataset agency-ops --scope`, `action plan --plan-only`) — see the findings report §6b.

## [0.5.8] — 2026-06-08 (CLI fixes: dataset + playbook scoping flags)

No new commands (still **254 leaves / 248 endpoints**); continues the flag-wiring backlog (`docs/tasks/2026-06-08-cli-conformance-findings.md`). More parsed-but-dropped scoping flags now reach the request. Patch bump — no breaking changes.

### Fixed
- **`dataset readiness` / `learning-state` / `learning-velocity` / `report-contract-v2` `--campaign`** (and `--adset` where applicable) now scope to that entity's insights edge instead of being ignored and reporting account-wide. `dataset bundle` also scopes its readiness section to the bundle's campaign.
- **`dataset execution-plan --campaign`** now scopes (its `--mode`/`--strategy` remain unimplemented and are tracked separately).
- **`playbook evaluate --campaign`** now scopes the evaluation to one campaign (its `--scope` flag remains a tracked follow-up).

Shared `DatasetService::scope_node()` helper, mirroring `AnalyticsService`. Flag-wiring baseline shrank 39 → **35** grandfathered arms. CLI-side wiring (the matching API endpoints pass `None` for now — API-side scoping is a tracked follow-up).

## [0.5.7] — 2026-06-08 (CLI fixes: more silently-dropped analytics scoping flags)

No new commands (still **254 leaves / 248 endpoints**); continues the flag-wiring backlog from v0.5.6 (`docs/tasks/2026-06-08-cli-conformance-findings.md`). Six more arms where clap parsed a flag that `dispatch()` swallowed now actually scope the request. Patch bump — no breaking changes.

### Fixed
- **`metrics compute --campaign` and `metrics creative-quality --campaign`** now scope the metrics to that campaign's insights edge instead of being ignored and computing account-wide.
- **`learning diagnose` / `learning prescribe --campaign`/`--adset`** and **`learning scorecard --campaign`** now scope to that entity (precedence: ad set > campaign > account), matching how `learning volume` already behaved.
- **`account overview --days <N>`** now adds a windowed spend/delivery summary (`spend,impressions,clicks,reach` over the last N days) instead of dropping the flag.

The flag-wiring lint baseline shrank from 45 → **39** grandfathered arms. (CLI-side wiring; the matching API endpoints still query account-wide — API-side scoping for these is a tracked follow-up.)

## [0.5.6] — 2026-06-08 (CLI fixes: analytics scoping flags that were silently dropped)

No new commands (still **254 leaves / 248 endpoints**); three flags that clap parsed but `dispatch()` silently swallowed now actually reach the request. Surfaced by a full-surface CLI conformance + flag-wiring audit (`docs/tasks/2026-06-08-cli-conformance-findings.md`). Patch bump — no breaking changes. (More dropped-flag fixes are tracked in that report as a follow-up.)

### Fixed
- **`report insights --campaign <id>` / `--adset <id>` now scope the report** to that entity instead of being ignored and returning account-wide data. The flags existed but were dropped before the service ran; insights now query the `<campaign|adset>/insights` edge (ad set wins over campaign). The same `--campaign` scoping was wired into `report breakdown`. Mirrored on the HTTP API (`GET /api/v1/reports/{insights,breakdown}` accept `campaign`/`adset`).
- **`metrics funnel --event <action_type>` now scopes the conversion tally** to a single action type (e.g. `--event purchase`) instead of being ignored and always counting all conversions. Mirrored on `GET /api/v1/analytics/funnel` (`event` query param).
- **`creative update --name <name>` now applies the rename.** It was parsed but dropped; you previously had to use `--spec '{"name":"…"}'`. `--name` is now merged into the update payload (and is sufficient on its own).

## [0.5.5] — 2026-06-07 (CLI fixes: ad-account id normalization, CBO bid default, plan-create spec)

No new commands (still **254 leaves / 248 endpoints**); three CLI correctness fixes surfaced by an aggressive write-path test against a Meta Ads sandbox. Patch bump — no breaking changes.

### Fixed
- **Bare numeric ad-account IDs are normalized to `act_<id>`.** Setting `META_AD_ACCOUNT_ID=1476…` (the form Ads Manager shows) or passing `--account 1476…` previously sent every account-scoped call to `/1476…` instead of `/act_1476…`, failing with a cryptic `(#100) Tried accessing nonexisting field`. The `--account` flag, the env var, the `~/.apb/config.json` default, and the SaaS tenant default are all canonicalized now, and `apb account current` no longer falsely reports `reachable_by_token: false` for a bare-id active account.
- **`campaign create` no longer leaves CBO campaigns on a bid-cap strategy that breaks child ad sets.** When a campaign-level budget is set without an explicit `--bid-strategy`, Meta defaulted to `LOWEST_COST_WITH_BID_CAP` (which requires a bid cap), so the next `adset create` failed with "Invalid parameter: Bid …". `apb` now defaults the no-cap strategy (`LOWEST_COST_WITHOUT_CAP`) for budgeted campaigns. ABO campaigns (no campaign budget) are unchanged — bid strategy stays at the ad set.
- **`plan create --spec-file` now reads a file (or inline JSON) and honors the spec.** It previously treated the argument as an opaque payload string, hardcoded `action=custom`/`target=plan`, and ignored `--campaign`/`--strategy`/`--mode`/`--name`, so the resulting plan could never validate against a real target. It now accepts a file path **or** inline JSON of the form `{"action":"<domain.verb>","target_id":"<id>" (or "target_ids":[…]),"payload":{…}}`, validates the action against the known plan-action set, and falls back to `--campaign` for the target.

## [0.5.4] — 2026-06-03 (security: hardening tail)

No new commands (still **254 leaves / 248 endpoints**); **CLI behavior unchanged**. Server-side hardening compiled into `apb-core`, so the CLI binary is re-released for parity. Patch bump.

### Security
- **Binding an ad account now verifies it's reachable by the connection's Meta token** (`me/adaccounts`) before it's stored — fail-closed (SEC-M4). Previously the per-key account allowlist could name accounts the token couldn't actually use.
- **The unauthenticated OAuth device-status endpoint no longer echoes raw Meta error text** to the caller (status-only), and its 500 path is scrubbed (SEC-L4).
- Cosmetic: `docs/template.env` Stripe placeholder no longer looks like a real `pk_live_` key (SEC-L7).

## [0.5.3] — 2026-06-03 (security: per-tenant API state isolation)

No new commands (still **254 leaves / 248 endpoints**); **CLI behavior unchanged**. Server-side security hardening compiled into `apb-core`, so the CLI binary is re-released for parity. Patch bump.

### Security
- **Per-tenant isolation of file-backed state on the multi-tenant API server.** Plans, sync snapshots, and policy profiles are namespaced per tenant (`state/tenants/<id>/`) with `Plan` ownership stamping — closing a cross-tenant disclosure + approval-tampering gap on `/plans`, `/sync`, and `/policy` (SEC-C2 / SEC-H1). The CLI keeps its single-user flat layout, so local plans/policy are unaffected.
- **Internal 500 responses no longer echo raw database error text** to API clients (SEC-M2).
- **The API server refuses to start without `DATABASE_URL`** unless `APB_ALLOW_DEV_AUTH=true`, preventing an accidental full-access dev-auth fallback in production (SEC-L6).

## [0.5.2] — 2026-06-01 (CLI account resolution: SaaS re-rank + cache de-poisoning)

No new commands (still **254 leaves / 248 endpoints**). Fixes a stale machine-global `default_account` mis-targeting a SaaS key, and de-poisons account discovery. Patch bump — behavior fix + one new flag, no breaking changes.

### Fixed
- **A stale global `default_account` no longer mis-targets a SaaS key.** In SaaS mode (`APB_API_KEY` set), account resolution now follows `--account` → `META_AD_ACCOUNT_ID` → tenant default → token auto-discovery; the machine-global `~/.apb/config.json` `default_account` is consulted **only in legacy/BYO mode**. Previously a default set under one key outranked another key's identity and pointed it at an account it couldn't read — surfacing as a confusing Meta permission error on `apb campaign list`. Legacy/BYO precedence (`--account` → `.env` → global) is unchanged.
- **Account discovery is no longer cross-token-poisoned.** `me/adaccounts` (and other account-less endpoints) are namespaced in the response cache by a per-token fingerprint instead of a shared `__default__`, so switching API keys can't serve a stale account-discovery result.

### Changed
- **`apb` auto-uses your ad account only when there's exactly one.** When no account is specified and the token can reach a single account, it's used automatically; when it can reach several, `apb` lists them and asks you to choose (`--account` or set a default) instead of silently using the first.

### Added
- **`apb account set-default --clear`** removes the persisted global default (`--account` is now optional — required only when setting).
- **`apb meta cache --clear`** now also clears the cached tenant context (`~/.apb/tenant_context.json`), forcing a clean token + account re-resolve.
- On an account-access error for an *implicitly*-resolved account, `apb` prints a stderr hint naming where the account came from and how to override it.

## [0.5.1] — 2026-06-01 (CBO / campaign-budget awareness for delivery-pacing + bid-strategy)

No new commands (still **254 leaves / 248 endpoints**). Makes the two scaling playbooks useful on **CBO** accounts (budget set at the campaign level — the common agency setup), closing the v0.5.0 follow-up. Patch bump — behavior-only enrichment, no surface or breaking changes.

### Changed
- **`apb playbook delivery-pacing` now assesses CBO campaigns at the campaign level.** It previously read ad-set-level budgets only, so on CBO accounts (budget on the campaign, not the ad set) it returned `insufficient_data`. It now rolls each CBO campaign's ad-set spend up to the campaign budget and scores an "assessable unit" = an adset-budgeted (ABO) ad set **or** a campaign-budgeted (CBO) campaign. Findings gain a `campaigns[]` array (per-CBO-campaign pace + cause) alongside the existing `adsets[]`; `LEARNING_LIMITED` is rolled up from child ad sets into the campaign verdict. ABO accounts are unaffected.
- **`apb playbook bid-strategy` is now CBO-aware.** The "uncapped on a scaled budget" check uses the parent **campaign** budget as the basis when the ad set has none (CBO), and the effective bid strategy falls back to the campaign's when the ad set inherits it — so CBO ad sets report their real strategy + budget basis instead of `UNSET`/$0. The `COST_CAP` / `MIN_ROAS` per-ad-set verdicts are unchanged.

### Notes
- Supersedes the v0.5.0 note that `delivery-pacing` returns `insufficient_data` on CBO — it now produces a real campaign-level score. `insufficient_data` remains only when there is genuinely no adset-level or campaign-level budget on the active ad sets.
- Read-only; no writes. The bid-strategy "uncapped on a scaled budget" flag fires at a ≥ $100 budget basis (now reachable on CBO).

## [0.5.0] — 2026-06-01 (playbook intelligence expansion: +8 diagnostic playbooks, 24→32)

Eight new **read-only** diagnostic playbooks across the signal and scaling pillars, taking the catalog from **24 → 32**. All require `read:playbooks:full` (Agency+); the core (Professional) set is unchanged at 5. CLI grows **246 → 254 leaves**; the HTTP API grows **240 → 248 endpoints** and `POST /api/v1/playbooks/batch` now covers all 32. Minor version bump — meaningful additive feature batch, no breaking changes.

### Added
- **`apb playbook creative-velocity`** (signal, 30d) — fresh-creative cadence: net-new ads/week, % spend on creative <30d old, single-creative dependency, creative win-rate vs account-median CPA, and refresh-runway weeks. Flags accounts "starving for fresh creative."
- **`apb playbook video-engagement`** (signal, 14d) — per-video hook-vs-payoff diagnosis: hook rate (plays÷impressions), hold rate (thruplay÷plays), the p25→p100 retention curve, and which third of the video leaks.
- **`apb playbook funnel-leak`** (signal, 14d) — locates the leakiest conversion-funnel stage (CTR → LPV → ATC → IC → Purchase) and attributes it (creative / landing page / offer / checkout).
- **`apb playbook signal-quality`** (signal, structural) — measurement-quality sibling of `capi-dual-signal`: standard-event coverage, CAPI server/web split, advanced-matching breadth, and `match_rate_approx` when Meta returns it (graceful proxy when gated).
- **`apb playbook delivery-pacing`** (scaling, 7d) — per-ad-set under-delivery cause classification: budget-capped vs learning-limited vs bid/audience-constrained.
- **`apb playbook bid-strategy`** (scaling, 30d) — bid strategy vs realized CPA/ROAS: COST_CAP throttling, uncapped scaled spend, MIN_ROAS floor misses.
- **`apb playbook segment-performance`** (signal, 30d) — per-segment (device / placement / age / gender) waste audit with ready-to-attach `value_rule` bid-down specs; honors the iOS conversion-breakdown limit (age/gender = delivery-efficiency only).
- **`apb playbook advantage-adoption`** (scaling, 30d) — advisory audit of Advantage+ structure adoption (`smart_promotion_type` + Advantage+ Audience) with manual-sales migration candidates. Never writes (ASC creation was removed in Marketing API v25).

All eight return the standard `{ grade, score, summary, findings, recommendations }` envelope (or `insufficient_data` when there's nothing to analyze) and are read-only.

### Notes
- `delivery-pacing` / `bid-strategy` assess **ad-set-level** budgets; on CBO (campaign-budget) accounts `delivery-pacing` returns `insufficient_data` rather than a misleading score — campaign-level pacing is a planned follow-up.
- `signal-quality` uses an advanced-matching-breadth + coverage + CAPI proxy when Meta gates `match_rate_approx` (EMQ), and surfaces the real value automatically when a token has Dataset Quality access.

## [0.4.6] — 2026-05-31 (playbook metadata correction: all 24 valid & consistent)

No new commands (still 246 leaves). Corrects playbook metadata drift across the catalog, CLI, API, and frontend, and makes `/playbooks/batch` cover all 24. Most changes are metadata/docs with **zero behavior change**; the batch + scope items are API-side (additive, fail-closed).

### Fixed
- **`apb playbook catalog` default windows now match what actually runs.** The catalog advertised longer default lookbacks (e.g. fatigue-index 30d) than the CLI/API/UI actually use (28d). Lowered the catalog's `default_days` for 9 playbooks to the real runtime defaults — the displayed window now equals the executed window. (The CLI/API/UI defaults were already correct; only the catalog metadata was stale.)
- **`creative-mix` / `launch-check` no longer accept a `--days`/`--since` flag the engine silently ignored.** Both are structural audits (they inspect current creative/setup config, not a time window), so the no-op flags were removed and the phantom `default_days` dropped from the catalog for all 6 structural playbooks (also broad-targeting-audit, event-hierarchy-audit, capi-dual-signal, retargeting-compression).
- **Rate-limit cooldown test** updated to the v0.4.5 `MetaError::RateLimit` contract (a masked break — the cooldown short-circuit now returns the first-class variant; the test still asserted the old `Api{RateLimit}` shape and was skipped by the `--lib` test gate).

### Changed (API — server rebuild, no client impact)
- **`POST /api/v1/playbooks/batch` now runs all 24 playbooks** (was 10). Added the 14 missing dispatch arms + per-slug scope mappings (5 core / 19 agency, fail-closed on unknown slugs) and raised the per-request cap to 24.
- **`GET /api/v1/playbooks/catalog` is no longer agency-gated.** The static directory is now readable by any authenticated tenant (drives the upgrade/upsell UI); `summary` stays at the lowest playbook tier. Previously both fell through to the agency-only `read:playbooks:full` scope (a Professional-tier 403).

### Docs / internal
- `playbook evaluate` reference rewritten to the real 5-play model (SCALE / FATIGUE_RESET / CREATIVE_REFRESH / WAIT_FOR_SIGNAL / MAINTAIN) — the previous "9 triggers" never existed in code.
- Removed dead `apb-cli` `commands/playbook.rs::evaluate()` orphan; fixed the stale "Learning pillar (4)→(5)" comment and "15 playbooks" doc counts.
- New `check_playbook_parity.py` CI guard + committed `playbook-catalog.fixture.json` + strengthened frontend test — assert pillar / default_days / scope parity across catalog ↔ API ↔ frontend so this drift can't silently recur.

No command-surface change (still 246 leaves). Error-shape fix only; exit codes and HTTP statuses are unchanged.

### Fixed
- **Terminal Meta rate-limit errors now serialize as `code: "rate_limited"` (was `"api_error"`) in `--json`**, with the wait window surfaced as `error.details.retry_after_ms`. Previously the retry loops and backpressure-cooldown short-circuits in the Meta client returned a generic `Api{error_class: RateLimit}` error, so `--json` consumers saw `"api_error"` with no retry window — indistinguishable from an ordinary API failure. They now return the first-class `RateLimit` variant, so agents/CI scripts can branch on `rate_limited` and read `retry_after_ms` directly. As a side effect, the human-mode error gains the **"Wait ~Ns, then retry."** bullet (driven by the same `retry_after_ms`). Exit code stays `5` (network class) and the HTTP API stays `429` — only the JSON `code` token and `details` changed.

## [0.4.4] — 2026-05-31 (rate-limit UX: visible backoff + opt-in throttle)

No command-surface change (still 246 leaves). Behavioral/UX only, with safe defaults — behavior is unchanged unless `APB_THROTTLE` is set or a 429/5xx is hit in human mode.

### Added
- **Live backoff feedback.** On a Meta 429/5xx the CLI now prints a one-line stderr notice before each retry — e.g. `⚠️  Meta rate limit — retrying in 8s (retry 1/3)` — instead of pausing silently. Suppressed under `--json` / `--no-input` so captured output stays clean.
- **Actionable rate-limit error.** When retries are exhausted, the human-mode error appends guidance: how long to wait, that Meta's limit is an **ad-account-level rolling usage score (not a daily quota)**, `apb doctor quota` to check headroom, burst-reduction tips, the `APB_THROTTLE` opt-in, and the Ads-API-access-tier caveat. (`--json` already carried `retry_after_ms` in `error.details`.)
- **Opt-in preemptive throttle (`APB_THROTTLE=1`).** Off by default. When enabled, the CLI persists per-account peak Meta usage to `~/.apb/throttle/<acct>.usage.json` (120s TTL) and pre-sleeps before requests once pressure crosses the soft/hard thresholds (`META_BACKPRESSURE_SOFT/HARD_PCT`, default 60/80 → 250/2000ms). Works **within a run** (in-memory reading) and **across rapid back-to-back invocations** (persisted snapshot) — bringing the SaaS server's 60/80 backpressure model to the CLI for high-fanout agent loops.

### Notes
- Complements the existing reactive protections (Retry-After-aware exponential backoff + the 10-minute cross-invocation cooldown after a 429). The API server path is untouched — notices are CLI-human-mode only.

## [0.4.3] — 2026-05-30 (advantage-plus placements include Threads)

### Fixed
- **`--placements advantage-plus`** now includes **Threads** — `publisher_platforms` is `facebook, instagram, audience_network, messenger, threads` (was 4 platforms, silently excluding Threads — narrower than Meta's true automatic/Advantage+ default). Live-verified Meta accepts + persists it. No command-surface change (246 leaves).

## [0.4.2] — 2026-05-30 (Value Rules + targeting/upload fixes)

`cli_leaf_count` 242 → 246 (new `value-rule` domain). No new scopes (value rules use `read:campaigns` / `write:campaigns`).

### Added
- **Value Rules (bid multipliers)** — new `value-rule create | list | show | delete` domain. A `value_rule_set` raises/lowers the bid for users matching criteria (e.g. bid +20% for iOS users). Build a single rule from flags (`--adjust`/`--adjust-value`/`--criteria-type`/`--values`) or pass a full multi-rule array via `--spec-file`. Criteria types: `GENDER`/`AGE`/`OS_TYPE`/`LOCATION`/`PLACEMENT`/`DEVICE_PLATFORM`/`CONVERSION_LOCATION`/`OMNI_CHANNEL`/`URL`/`AUDIENCE_LABEL`. Schema reverse-engineered + live-verified against Meta v25 (`POST /act_<id>/value_rule_set`). HTTP equivalent at `/api/v1/value-rules`.
- **`adset create --value-rule-set-ids`** — attach value rule sets to an ad set (Meta's write-only `value_rule_set_ids` param; not read back via `adset get`).
- **Docs:** documented that the v25 ad set has **no separate "attribution model" field** — `attribution_spec` (windows) is the only lever, "Standard" = the default. Traffic performance goals (`--optimization-goal LANDING_PAGE_VIEWS` / `LINK_CLICKS`) and the cost-per-result goal (`--bid-strategy COST_CAP --bid-amount`) were already supported.

### Fixed
- **`targeting interest-validate --ids`** validated by interest *name* (Meta's `interest_list` param) instead of by ID, so it reported every interest invalid. Now uses `interest_fbid_list` — returns real validity + names and flags deprecated interests.
- **`creative upload-video` named every asset "Default"** — title/name were set in the resumable upload's `start` phase (which Meta ignores); moved to the `finish` phase. Now the asset name = `--name`, else the file basename.

### Known limitation
- Meta does not support deleting a `value_rule_set` through this API path on all accounts/tokens (returns "Unsupported delete request"); `value-rule delete` surfaces that error — delete in Ads Manager if rejected.

## [0.4.1] — 2026-05-29 (EngineSEO live-test fixes)

Fixes surfaced by an end-to-end live validation of the v0.4.0 write surface against a real Meta ad account (image + video DCO campaigns, paused). No new commands or scopes (`cli_leaf_count` stays 242).

### Fixed
- **Targeting builder `--interests` / `--exclude-interests` never resolved a NAME** — `resolve_interest_ids` indexed a `{"data":[…]}` envelope, but `interest_search` returns a bare array, so every interest name failed with "no interest found matching …" (only numeric IDs worked). Now indexes the array directly.
- **`creative upload-image` rejected an extensionless `--name`** — the asset name was used as the multipart filename with a hardcoded `application/octet-stream` MIME, so Meta returned `(#100) The type of file is not supported` for e.g. `--name "my-logo"`. Now sniffs the image magic bytes to set an accurate content-type and guarantees the multipart filename carries the right extension (png/jpg/gif/webp/bmp).
- **`adset get` couldn't read back several v0.4.0 write fields** — added `is_dynamic_creative`, `dsa_beneficiary`, `dsa_payor`, and `bid_constraints` to the requested field set so a created ad set's DCO/DSA/min-ROAS settings actually appear on read-back.
- **`--enhancements standard` broke creative-create** — Meta removed the umbrella `standard_enhancements` opt-in (now rejected with "… has been deprecated. Please choose to set individual features instead."). `standard` is now a no-op (with a deprecation note); CSV feature keys are upper-cased to match Meta's `creative_features_spec` enum (e.g. `IMAGE_ANIMATION`, `TEXT_OVERLAY_TRANSLATION`).
- **Inline DCO (`creative create-dynamic`) with `--video` failed** — the inline `asset_feed_spec` never set `ad_formats` and always emitted a separate `images` array, so combining `--image` + `--video` hit Meta "an asset feed can have exactly one ad format". Now derives exactly one format: a video feed is `SINGLE_VIDEO` (image hashes become per-video `thumbnail_hash`), an image-only feed is `SINGLE_IMAGE`.

### Internal
- Made `cli_resolver_cache_test` deterministic — its four tests mutate the process-global `HOME`, so they now serialize on an in-test async lock instead of relying on `--test-threads=1` (which `cargo test --workspace` doesn't pass), keeping the binding test gate green under default threading.

## [0.4.0] — 2026-05-29 (meta-v25-field-coverage)

Single batched release of the 3-tier Meta Marketing API v25 write-field-coverage workstream (correctness → capability → ergonomics). `cli_leaf_count` 241 → 242 (new `audience share`). No new scopes.

### Added — Meta v25 field coverage, Tier 1 (correctness) — `meta-v25-field-coverage`
- **Ad set:** `--dynamic-creative` (enables DCO — the CLI previously hardcoded it off), `--destination-type` (WhatsApp/Messenger/app/on-platform objectives), `--attribution-spec` (+ rejects v25-invalid 7d/28d view-through windows, removed 2026-01-12), `--dsa-beneficiary`/`--dsa-payor` (EU DSA; advisory when targeting EU countries without them).
- **Campaign:** `--special-ad-category-country` (Meta requires it when a special ad category is set — now fails loud locally instead of a Meta 400).
- **Creative:** `--instagram-user-id` (top-level v25 field) on the image/video simple builders; `--instagram-actor-id` kept as a deprecated alias (Meta deprecated it 2025-09-09).
- **CAPI:** per-field PII normalization in `hash_pii_fields` (phone→digits, US-5 zip, YYYYMMDD dob, city/state letters-only, gender f/m, ISO-2 country) — fixes silent match-rate (EMQ) loss from the prior generic lowercase.
- **Audience:** `customer_file_source` defaults to `USER_PROVIDED_ONLY` for `CUSTOM` audiences (was a hard `(#100)` failure when omitted).

### Added — Meta v25 field coverage, Tier 2 (capability) — `meta-v25-field-coverage`
- **Ad set Advantage+ relaxation:** `--advantage-detailed-targeting` (sets `targeting_automation.advantage_audience=1`), `--advantage-lookalike` / `--advantage-custom-audience` (build `targeting.targeting_relaxation`).
- **Ad set min-ROAS / bid caps:** `--bid-constraints` (raw JSON, e.g. `{"roas_average_floor":12000}`) with validation — `LOWEST_COST_WITH_MIN_ROAS` requires a positive floor; `COST_CAP`/`LOWEST_COST_WITH_BID_CAP` require `--bid-amount`.
- **Creative enhancements (Advantage+):** `--enhancements standard|none|<csv>` on the image/video simple builders → per-feature `degrees_of_freedom_spec.creative_features_spec.*.enroll_status` (the dead `enable_standard_enhancements` bundle is never emitted). A deliberate opt-in is whitelisted in the creative auditor; the carousel/collection/FORMAT_AUTOMATION ("Scandalous") trap still blocks.
- **Inline DCO completeness:** `creative create-dynamic` gains `--description`, `--video` (pre-uploaded IDs), and `--optimization-type` on the inline `asset_feed_spec` path.
- **CAPI value optimization:** `pixel send-event` gains `--contents` (`custom_data.contents[]`), `--content-category`, `--predicted-ltv`, plus `--lead-id` / `--subscription-id` / `--fb-login-id` on `user_data` (unhashed IDs — closes the leadgen → offline-conversion loop).
- **Value-based audiences:** `audience create --value-based` (sets `is_value_based=true`) + `LTV` / `VALUE` schema codes for `audience users-add` (numeric, sent unhashed) — value-based audiences are now buildable end-to-end.
- **Leadgen quality:** `leadgen create` now pre-flights for a privacy policy (`privacy_policy{url,link_text}` or legacy `privacy_policy_url`) and fails loud without one. The example spec (`docs/examples/leadgen-form-spec.json`) gains `is_optimized_for_quality`, `context_card`, a qualifier question, structured `privacy_policy`, and `thank_you_page`.

### Added — Meta v25 field coverage, Tier 3 (ergonomics) — `meta-v25-field-coverage`
- **`--extra-fields` escape hatch** on `campaign create` + `adset create` — a raw JSON object shallow-merged into the request body for any Meta field apb doesn't expose as a flag. Bypasses validation (advisory) and **fails loud on a key collision** with an apb-managed field. Kills the "no full-body passthrough" gap class.
- **Targeting builder** on `adset create` — build the `targeting` spec from flags instead of hand-authored JSON: `--countries`/`--regions`/`--cities`/`--exclude-countries`, `--age-min`/`--age-max`/`--genders`, `--interests` (name→ID via search) / `--behaviors`, `--exclude-interests`, `--custom-audiences`/`--exclude-custom-audiences`, `--locales`/`--device-platforms`/`--user-os`. Mutually exclusive with `--targeting`/`--spec-file` (fails loud).
- **Campaign create/update parity:** `campaign create` gains `--spend-cap`, `--start-time`, `--stop-time`, `--promoted-object`; `--bid-strategy` is validated against the v25 enum on both campaign + ad set.
- **CAPI breadth + LDU:** `pixel send-event` gains `--first-name`/`--last-name`/`--external-id` (hashed), `--client-ip`/`--client-user-agent`/`--fbc`/`--fbp` (unhashed match signals), and Limited Data Use `--ldu`/`--dpo-country`/`--dpo-state` (CCPA `data_processing_options`).
- **Audience completeness:** `audience create` gains `--prefill`/`--opt-out-link`; `audience create-lookalike` gains `--starting-ratio` (range), `--lookalike-type`, `--is-financial-service`; new **`audience share`** subcommand shares a custom audience with another ad account (`POST /{id}/adaccounts`). One new CLI leaf (241 → **242**).

### Fixed
- **Compose** posted `special_ad_categories` as the literal string `"[]"` instead of a JSON array — migrated `ComposeSpecCampaign.special_ad_categories` to `Vec<String>`.
- **`apb-api` had not compiled on `main` since v0.3.0** — the v0.3.0 `objective_pack`/`volume`/`scenario` signature changes were never propagated to the HTTP routes (CI built `apb-cli` + ran parity scripts but never compiled `apb-api`). Routes fixed, and **`cargo build -p apb-api` added to `cli-parity.yml`** so it can't recur.

## [0.3.0] — 2026-05-29 (cli-account-switching + cli-flag-wiring)

### Added — ergonomic account switching (cli-account-switching)
Switch the active ad account by **name**, and — with a profile — switch its Meta token at the same time, so the "token can't reach this account" `(#200)` mismatch can't recur.
- **`apb account use <profile|name|act_…|123456>`** — set the active account by profile name, account-name substring, `act_` id, or numeric id; a bare name is matched against the accounts the current token can reach; prints the resolved account + a reachability hint.
- **`apb account profile add|list|remove`** — named profiles binding an account to its token. The token is referenced by the **name of an env var** (`--token-env SCANDALOUS_TOKEN`), never stored in plaintext. In `META_OAUTH=DISABLED` mode the active profile's `token_env` supplies the BYO Meta token (an explicit `META_ACCESS_TOKEN` still wins).
- **`apb account current`** — shows the active account, its profile, and which accounts the token actually reaches — flagging a token/account mismatch before a command 403s.
- Net **+5 CLI leaves (236 → 241)**; CLI-local (no new API endpoints). `~/.apb/config.json` gains `account_profiles` + `active_profile`, both back-compatible with older binaries.

### Fixed — silently-dropped CLI flags (cli-flag-wiring)
Three documented flags were parsed by clap and then absorbed by a `{ .. }` rest-pattern in dispatch before reaching the service — the same bug class as the v0.2.2 `--name` fix. Found by a static drift audit (`docs/tasks/cli-audit.md`). Metric math is covered by new `apb-core` unit tests; **live behavioral validation against a real ad account is deferred to the operator** (the audit ran read-only, no Meta calls).
- **`metrics objective-pack --objective`** now returns the documented per-objective metric pack (sales / leadgen / engagement / awareness) instead of ignoring the flag; `--days` is honored (was hardcoded 30). With no `--objective`, the prior by-objective overview is preserved.
- **`learning volume`** now scopes by `--campaign` / `--adset` and filters by `--event`, reporting weekly optimization-event volume vs learning-phase exit thresholds (was account-wide entity *counts*, ignoring every flag).
- **`dataset scenario --budget`** now derives the projection multiplier from the target budget vs current daily spend (was a fixed 1.0/1.5/2.0× sweep that ignored `--budget`); adds the documented `--event` / `--creative-velocity` flags and emits risk flags + preconditions.

### Added
- **Flag-wiring CI lint** (`rust/scripts/check_flag_wiring.py`, wired into `cli-parity.yml`) fails CI on any *new* clap flag swallowed by a `{ .. }` dispatch pattern. Current known drops are grandfathered in `rust/tasks/ci/api-parity/flag-wiring-baseline.json` (51 arms) so the gate prevents regressions while the backlog is worked down.

## [0.2.2] — Unreleased (cli-asset-naming Sprint 1)

**Added — name uploaded assets.** Every image/video upload path now accepts an explicit asset name; when omitted it defaults to the file's basename (filename + extension), which was already the de-facto default.

### Added
- **Builders:** per-asset `--image-name` / `--video-name` / `--thumbnail-name` / `--hero-image-name` on `creative create-image-simple`, `create-video-simple`, `create-lead-form-ad`, `create-catalog-creative`, `create-story-template`, `create-reels-video-template` (distinct from the builders' `--name`, which is the *creative* name).
- **`creative upload-video --title`** — display title, separate from the asset `--name`; defaults to the asset name.
- **API:** `POST /api/v1/creatives/upload-image` and `/upload-video` accept an optional `name` multipart field (defaults to the uploaded filename).
- Videos now set Meta's advideos `name` field (was only `title`).

### Fixed
- **`creative upload-image --name` was silently ignored** (the dispatch dropped it; images were always named by basename). It now sets the asset name.
- **Robust image-upload hash extraction:** `resolve_image_input` now reads `result.hash`, else the `images.<name>.hash` envelope, else a single entry, and surfaces Meta's error message instead of a generic "no hash" — addressing the `upload_image returned no hash for <file>` failures on otherwise-valid images.

### Changed
- **`creative upload-video --name` now sets the asset name** (Meta advideos `name`) rather than the display title. Use `--title` for the display title. Behavior change.

No new commands/endpoints/scopes (flags only; stays 236/236).

Deferred (follow-up): explicit naming on raw `creative create-image`(DCO multi-image)/`create-video --thumbnail` and the single-image quick-create path — these keep the basename default for now (DCO needs a parallel name-list design).

## [0.2.1] — Unreleased (cli-account-precedence Sprint 1)

**Fixed — ad-account resolution precedence.** `META_AD_ACCOUNT_ID` (from the shell env or the `.env` the binary ran from) now **takes precedence over** the persisted global `~/.apb/config.json` `default_account`. Previously the hidden global file silently outranked the documented `.env`, so swapping the account in `.env` had no effect and commands kept targeting a stale default — often surfacing as a confusing `(#200) Ad account owner has NOT granted ads_management` when the token had no rights on the silently-chosen account.

### Changed
- **Account precedence is now:** `--account` flag → `META_AD_ACCOUNT_ID` (.env / env) → `~/.apb/config.json` `default_account` → SaaS tenant default → auto-discovery. (Was: flag → `~/.apb/config.json` → env.)
- The env-derived account also passes the SaaS `can_access_account` gate — if a tenant isn't authorized for the `.env` account, the command returns `account_not_authorized` (surfacing intent) instead of silently substituting the global default.

### Added
- **Transparent account reporting:** each run prints `[apb] account: <act_id> (source: --account flag | env META_AD_ACCOUNT_ID | ~/.apb/config.json default)` to stderr (suppressed under `--json`).
- **Override warning:** when `META_AD_ACCOUNT_ID` overrides a *differing* `~/.apb/config.json` default, `apb` prints a loud `note:` naming both accounts so the override is never silent.

No new commands, endpoints, or scopes (stays 236/236). Pure CLI resolution change; `apb-api` unaffected.

## [0.2.0] — 2026-05-27

**Agency-gaps-v2 workstream.** Four phases of the gap analysis at `docs/tasks/agency-gaps-may-26-v2.md` shipped together: creative format auditor, placement presets, ergonomic builders + leadgen ad-create, built-in compose presets. Net surface: **+7 CLI leaves, +7 API endpoints (229 → 236), zero new tier scopes, zero migrations.** 86 new unit tests pass.

### Added — Creative format auditor (Phase 1, Sprint 1)

- **`apb creative create-*` / `update` now audit specs for unintended Meta v25 format-expansion fields.** Detects 11 risks (CAROUSEL, COLLECTION, AUTOMATIC_FORMAT, CAROUSEL_IMAGE, CAROUSEL_VIDEO, FORMAT_AUTOMATION, degrees_of_freedom_spec, contextual_multi_ads, product_set_id, template_url, `{{product.*}}` syntax). When `--execute` is set with unwhitelisted findings, exits **2** with an actionable error naming each detected risk and the `--allow-*` flag that whitelists it. Fires BEFORE the env-var write gate so the spec-fix message surfaces first. CI use: `--strict-format` upgrades dry-run findings to errors. Spec-review: `--audit-only` runs the auditor and exits 0 without writing. The Scandalous Coffee fix: a single-image creative whose `asset_feed_spec` carried `CAROUSEL/COLLECTION/FORMAT_AUTOMATION` is now blocked at dry-run. See `rust/docs/CREATIVE_AUDITOR.md`.
- 8 new flags on each affected creative command: `--allow-carousel`, `--allow-collection`, `--allow-automatic-format`, `--allow-format-automation`, `--allow-catalog-template`, `--strict-format`, `--audit-only`, `--creative-format <kind>`.
- API parity: matching `allow_*` / `strict_format` / `audit_only` JSON body fields on `POST /api/v1/creatives` + `/dynamic` + `/collection` + `PATCH /api/v1/creatives/{id}`.

### Added — Placement presets (Phase 2, Sprint 2)

- **`apb adset create` + `adset update-targeting` now accept `--placements <preset>`** — expands one of 6 curated shapes into v25 `publisher_platforms` / `facebook_positions` / `instagram_positions`. Presets: `feed`, `stories`, `reels`, `stories-reels`, `feed-stories-reels`, `advantage-plus`. Merges cleanly with operator `--targeting` JSON; **fails loud on conflict** (exit 2, message names both sides). IG's feed equivalent is named `stream` in v25 — the preset handles that.
- API parity: `placements` field on `CreateAdsetBody` + `UpdateTargetingBody` accepts the same kebab-case names via `PlacementPreset::parse_kebab`.

### Added — Ergonomic creative builders + leadgen ad-create (Phase 3, Sprint 3)

- **6 new `creative create-*-simple` / `*-template` builders.** Take operator-friendly flags (`--page-id --image --headline --body --url --cta` etc.) and build the v25 `AdCreative` spec internally — no JSON authoring. All `--image` / `--video` / `--thumbnail` / `--hero-image` flags accept Meta hashes/IDs or local file paths (auto-uploaded under `--execute`).
  - `creative create-image-simple`
  - `creative create-video-simple`
  - `creative create-lead-form-ad` — **first `lead_gen_form_id` injection in the codebase**
  - `creative create-catalog-creative --format <single|carousel|collection|automatic>` — auto-wires the matching auditor `--allow-*` flag so explicit format intent doesn't trip the auditor
  - `creative create-story-template` — emits `story_advisories` (9:16 reminder, safe-zone, ≤15s video)
  - `creative create-reels-video-template` — emits `reels_advisories` (9:16, ≤90s)
- **`apb leadgen ad-create` end-to-end orchestrator.** One command: validates campaign objective is `OUTCOME_LEADS`, verifies the form belongs to the page (Page-token check fires FIRST so token failures surface before any write), creates lead-form creative referencing `lead_gen_form_id` in `link_data.call_to_action.value`, creates the ad. **Reverse-pause rollback** if ad-create fails after creative succeeded.
- API parity: 7 paired endpoints — `POST /api/v1/creatives/{image-simple,video-simple,lead-form-ad,catalog,story-template,reels-video-template}` + `POST /api/v1/leadgen/ad-create`.
- Baseline `endpoint_count` + `cli_leaf_count` bumped **229 → 236** in lockstep with the +7 code change.

### Added — Built-in compose presets (Phase 4, Sprint 4)

- **`apb campaign compose-from-spec --preset <name>` now accepts 6 built-in preset names** — produces full campaign + adset + creative + ad stacks from operator-friendly args (`--campaign-name --page-id --daily-budget` + per-preset extras like `--form-id`, `--catalog-id`, `--product-set-id`, `--pixel-id`).
  - `sales-video`, `sales-carousel`, `lead-form`, `catalog-sales`, `reels-video`, `stories-video`
  - `catalog-sales` auto-switches optimization goal to `OFFSITE_CONVERSIONS` when `--pixel-id` is given, else falls back to `LINK_CLICKS`
  - `reels-video` / `stories-video` reuse Sprint 2's placement shapes
- **Built-in preset names take precedence over user-saved presets.** Shadow collision (user-saved preset with a built-in name) exits 2 with a clear shadowing message — NEITHER preset is silently used.
- API parity: `ComposeFromSpecBody` extended with `preset_name` + 7 preset arg fields. `spec` made optional. Same shadow-collision logic server-side.

### Changed

- Parity baseline counts: `endpoint_count` 229 → 236, `cli_leaf_count` 229 → 236, `route_module_count` unchanged at 25.
- `CLAUDE.md` + `rust/CLAUDE.md` surface-size references updated.
- API HTTP mapping in `rust/docs/API_REFERENCE.md` extended with the 7 new endpoint rows + a "v0.2.0 Ergonomic Builders" section.

### Pattern reference

All v0.2.0 pre-flight checks follow the v0.1.20 `validate_*()` / `*_advisories()` split established in `services/adset.rs:72,109,194` for the pacing/dayparting work. Pure functions, no I/O, run before any gate check, surface findings in dry-run preview AND in the actionable error on `--execute`.

## [0.1.20] — 2026-05-25

Pacing & scheduling alignment — close the gaps found in the 2026-05-25 live dayparting validation. Headline: catch the "$350 lifetime over a 10-hour flight" class of mistake before the API call.

### Added
- **Dayparting-windows-vs-flight guard.** `adset create`/`update` now reject (exit 2, during dry-run) a daypart `adset_schedule` whose window(s) fall entirely outside the flight (`start_time`→`end_time`) and could never deliver — the error names the dead windows. Enforced only for `timezone_type=ADVERTISER` windows (exact account-tz comparison); `USER`-tz windows are per-viewer-local and skipped (no false positives). Best-effort: absent/unparseable times, or a flight ≥ 7 days, pass through.
- **Pacing advisories (non-blocking).** Lifetime-budget setups Meta accepts but that under-deliver now surface an `advisories` array in the create/update result (visible in the dry-run preview): flight < 24h, flight < 6 days (learning phase), or a lifetime/dayparted ad set with no `--end-time`.
- **`pacing_type` in `adset list`.** List rows now show the raw pacing mode (`standard`/`day_parting`) alongside the existing `dayparting` flag.

### Changed
- **`adset create` dry-run preview now echoes the full request body.** `would_create` previously showed only a curated subset (name/campaign/optimization_goal/billing_event/status/schedule); it now includes `lifetime_budget`, `targeting`, `promoted_object`, `pacing_type`, `bid_strategy`, and the flight — so the budget/conversion wiring can be verified before `--execute`. (Targeting + promoted_object JSON are now also validated during dry-run.)

## [0.1.19] — 2026-05-25

Pre-flight create guards — catch two common Meta v25 rejections before the API call (during dry-run), with actionable messages, instead of learning the rule from a post-hoc Meta error.

### Added
- **Campaign objective must be ODAX.** `campaign create` (and `compose-from-spec`) now reject a non-v25 objective up front with a legacy→ODAX hint (e.g. `CONVERSIONS → OUTCOME_SALES`, `LINK_CLICKS → OUTCOME_TRAFFIC`). Valid: `OUTCOME_AWARENESS, OUTCOME_TRAFFIC, OUTCOME_ENGAGEMENT, OUTCOME_LEADS, OUTCOME_SALES, OUTCOME_APP_PROMOTION`.
- **Conversion ad set requires `promoted_object`.** `adset create` (and `compose-from-spec`) with `--optimization-goal OFFSITE_CONVERSIONS` (or `VALUE`) and no `--promoted-object` now fails fast (exit 2) telling you to pass a pixel + event (`{"pixel_id":"…","custom_event_type":"PURCHASE"}`), instead of Meta rejecting the create later.

Both guards are deterministic (no false positives on valid setups) and fire during dry-run. The `optimization_goal × billing_event` compatibility matrix is intentionally **not** hard-blocked (too broad to encode safely) — deferred to a future soft advisory.

## [0.1.18] — 2026-05-25

Dayparting **readback** fix — `adset get` couldn't see a schedule Meta had actually persisted.

### Fixed
- **`adset get` now returns the full ad-set state, including `pacing_type` and `adset_schedule`.** The field list previously omitted `pacing_type, adset_schedule, effective_status, updated_time` (plus `configured_status, budget_remaining, destination_type, attribution_spec`), so after a successful dayparting update `adset get` showed no schedule even though Meta had persisted it (a direct Graph fetch confirmed it was there). This was a **readback gap, not a persistence bug** — creation/update were working. Both the CLI and the HTTP API GET use the corrected field list.

### Added
- **Persisted-state verification on `adset update`.** After an executed update that sets a schedule, the response now carries a `verification` block read back fresh from Graph — `{verified, pacing_type, adset_schedule}` — so you get *confirmed persisted*, not optimistic success.
- **`adset list` now surfaces `lifetime_budget` and a `dayparting` flag.** Dayparted ad sets run on a lifetime budget, so the old summary (daily-budget only) rendered `-` and hid them.

## [0.1.17] — 2026-05-25

Day-parting safety: catch the daily-budget rejection during dry-run instead of on `--execute`.

### Fixed
- **`adset update` now pre-flights the budget type before adding a schedule.** Adding day parting (`--daypart-hours` / `--adset-schedule`) to a **live** ad set that's on a **daily budget** — or whose **CBO campaign** is on a daily budget — used to pass the dry-run and then be rejected by Meta (`Campaigns with day parting enabled do not support daily budgets`). The CLI now looks up the existing budget type and fails fast (exit 2) with an actionable message: create a **new** ad set/campaign with a **lifetime budget**, since Meta freezes budget *type* at create (`Changing from lifetime to daily budget or vice versa is not allowed`). The check is best-effort — a failed lookup never blocks the update; only a clearly daily-budget entity errors. (The create-time guard for `--daypart-hours` + `--daily-budget` was already present since 0.1.15; this extends it to the update path the dry-run couldn't see.)

## [0.1.16] — 2026-05-24

Workflow ergonomics found while building the dayparted campaign — three quality-of-life additions for the duplicate-and-optimize loop.

### Added
- **`targeting geo-resolve --regions "Connecticut,Indiana,Washington" [--cities …]`** — batch-resolves region/city **names → Meta keys** (wrapping `geo-search`, preferring an exact US match) and emits a ready-to-paste `geo_locations` fragment plus `resolved`/`unresolved` lists. No more one search per state.
- **`created_time` / `updated_time` in `ad list`** — so "the recent video/ad from the last 7-14 days" can be picked reliably. (Meta's ad *creative* object doesn't expose `created_time`; use `ad list` recency, since ads reference their creative.)

### Changed
- **Richer `campaign compose-from-spec` dry-run preview.** `would_create` now shows, per ad set: `status`, `daily/lifetime_budget`, `billing_event`, `promoted_object`, a `targeting_summary` (countries + region/city counts + age), and `adset_schedule`; per ad: `name`, `status`, and a creative brief (type + id/name); plus campaign `status`/budget and a PAUSED/ACTIVE note.

## [0.1.15] — 2026-05-24

Ad-set **dayparting / ad scheduling** support — the one Meta deployment surface APB couldn't reach. Validated end-to-end on a live account (lifetime-budget ad set + 4-window schedule accepted by Meta).

### Added
- **`adset_schedule` (dayparting) on `adset create`, `adset update`, and `campaign compose-from-spec`** (and the HTTP API `POST/PATCH /api/v1/adsets`). Pass an explicit Meta-format array via **`--adset-schedule`** (inline JSON or file), or build one from hours with **`--daypart-hours "9,12,16,19,21"`** (`--daypart-days 0-6`, `--daypart-timezone USER|ADVERTISER`). Consecutive hours merge into windows.
- The CLI **auto-sets `pacing_type=["day_parting"]`** when a schedule is present (Meta rejects a schedule otherwise), unless you pass an explicit `--pacing-type`.

### Fixed / Validation
- **Dayparting requires a lifetime budget.** A schedule combined with `--daily-budget` now fails fast: *"adset_schedule (dayparting) requires a lifetime budget; daily-budget ad sets can't use fixed daypart scheduling…"* — instead of an opaque Meta 400. Lifetime ad-set budgets pass; campaign-CBO (no ad-set budget) passes through for Meta to validate.
- Dry-run preview for `adset create` now includes the resolved `adset_schedule`.

## [0.1.14] — 2026-05-24

Targeting helper fixes found while building a duplicate-and-optimize workflow (top-15 states, dayparting, ADD_TO_CART) for a live account. The dry-run mutation path was fine; the targeting *lookup/estimate* helpers were broken.

### Fixed
- **`targeting geo-search --geo-type region` (and `city`, `geo_market`, …) no longer 400s.** The CLI was sending the location-type value straight through as Meta's `type=` param (`type=region`), which Meta rejects with "Unsupported get request". Location-type values now correctly run against `type=adgeolocation` with a `location_types` filter; only real Meta search types (`adgeolocation`, `adcountry`, `adzipcode`, …) are sent as `type=`. (apb-core → CLI + HTTP API.)
- **`targeting estimate --spec-file` / `delivery-estimate --spec-file` now read the file.** They were forwarding the literal *path* as the targeting spec, so Meta replied "Targeting spec must be an associative array". The file is now read to its contents (inline `--spec` unchanged). Same latent bug fixed in `adset create --spec-file`.

### Added
- **Pre-flight targeting validation.** A targeting spec whose `geo_locations.regions`/`cities` entries carry a name but no Meta `key` now fails fast with an actionable message (pointing to `geo-search --location-types`), instead of Meta's opaque "type integer is expected but a type NULL was received". Applied to `targeting estimate`, `delivery-estimate`, and `adset create`.

## [0.1.13] — 2026-05-24

Ad-set creation fix found while validating the operator BYO ad-creation flow against a live account — the third Meta-required-field gap in this series (after `is_adset_budget_sharing_enabled` in v0.1.10).

### Fixed
- **`adset create` and `campaign compose-from-spec` now send `targeting_automation.advantage_audience`.** Meta rejects an ad-set create unless this flag is explicitly `0` or `1` ("you need to enable or disable the Advantage audience feature"). The CLI never set it, so any ad-set/compose create with a minimal targeting spec failed mid-funnel. The service now **defaults it to `0` (off)** when absent — honoring whatever targeting you specified — and respects an explicit value already present in the targeting spec. (Shared apb-core fix → also applies to the HTTP API `POST /api/v1/adsets`.)

### Added
- **`adset create --advantage-audience <0|1>`** — opt into Advantage audience (`1`) or force it off (`0`). Overrides any value in `--targeting`. Spec/`targeting_automation` passthrough still works for `compose-from-spec`. Exposed on the HTTP API `POST /api/v1/adsets` body as `advantage_audience`.

## [0.1.12] — 2026-05-24

Access-control hardening for operator BYO mode (follow-up to `meta-static-token-001` / `admin-disable-enforcement-001`). Closes a path where an admin-disabled user/key could keep using the CLI.

### Changed
- **`META_OAUTH=DISABLED` now requires a valid `APB_API_KEY`.** Previously, setting `META_OAUTH=DISABLED` with a local `META_ACCESS_TOKEN` but **no** `APB_API_KEY` silently dropped the CLI into ungated legacy mode — it never contacted AgencyPlaybook, so disabling the user/key in the admin panel had no effect. BYO mode now fails fast with a clear error unless the platform key is present and resolves (login + tier/scope still enforced every run). Pure legacy mode (no `META_OAUTH`, no key — the standalone Meta tool) is unaffected.

### Fixed
- **BYO resolution no longer requires a platform Meta token.** A tenant that never connected Meta (the norm under operator-token mode) now resolves cleanly in BYO mode instead of failing with "Failed to parse TenantContext" — the local token is used, the platform key is still validated for access control.
- **(apb-api / `pg-store` only) Unbound user keys are rejected.** The resolver now refuses a `key_type='user'` API key whose `user_id` is NULL (a legacy key that escapes user-disable revocation); internal/tenant-scoped keys are unaffected. Companion server-side migration backfills and deactivates such keys.

## [0.1.11] — 2026-05-23

Operator bring-your-own Meta token mode (workstream `meta-static-token-001`) — a hidden escape hatch from the per-tenant OAuth broker for self-hosted / single-operator setups, validated end-to-end against a real account.

### Added
- **`META_OAUTH=DISABLED` + `META_ACCESS_TOKEN` (CLI):** when both are set, `apb` still validates your `APB_API_KEY` against the platform (login + tier/scope enforcement unchanged) but uses your **local** `META_ACCESS_TOKEN` for all Meta calls instead of the platform-resolved OAuth token. Lets an operator drive their own (or a client's) Meta account without completing the OAuth / app-review flow. Default-off — unset `META_OAUTH` for normal per-tenant OAuth behavior.

### Fixed
- **Null `meta_token` no longer breaks tenant resolution.** `PgTenantResolver` now decodes the legacy `meta_token` column as nullable, so a tenant that never connected Meta (the norm under operator-token mode) resolves cleanly instead of throwing a decode error. (apb-api / `pg-store` only.)

## [0.1.10] — 2026-05-22

Campaign-creation fixes found while building a live campaign + video ad against a real account (workstream `campaign-creation-fixes-001`). Two CLI gaps that each produced a Meta 400 mid-funnel.

### Fixed
- **`campaign create` now sends `is_adset_budget_sharing_enabled` for ABO campaigns.** Meta rejects a campaign with no campaign-level budget (the ad-set-budget model) unless this field is set explicitly (error subcode 4834011 — "You must specify True or False in the field is_adset_budget_sharing_enabled if you are not using campaign budget"). The CLI never sent it. It now defaults the field to `false` whenever no `--daily-budget`/`--lifetime-budget` is given; when a campaign budget *is* set the field is omitted. Locked in with a `resolve_budget_sharing` truth-table unit test. (Also exposed on the HTTP API `POST /api/v1/campaigns` body as `budget_sharing`.)

### Added
- **`campaign create --budget-sharing <bool>`** — opt into letting ad sets share 20% of their budget (`is_adset_budget_sharing_enabled: true`), or force `false`. Spec files may carry `is_adset_budget_sharing_enabled` / `budget_sharing`.
- **`creative create-video --thumbnail <path-or-hash>`** — video creatives require a thumbnail (`video_data.image_hash`), else Meta returns subcode 1443226 ("Your ad needs a video thumbnail"). The flag accepts a local image path (uploaded for you via `creative upload-image`) or an existing Meta image hash, and injects it as `object_story_spec.video_data.image_hash`. If no thumbnail is supplied (flag or in-spec `image_hash`/`image_url`), the CLI now fails fast with a clear validation error (exit 2) instead of letting the request 400 at Meta.

## [0.1.9] — 2026-05-21

Follow-up to the v0.1.8 review: two fixes that didn't fully take in 0.1.8, re-found on the shipped binary.

### Fixed
- **`playbook capi-dual-signal` now reports real server/browser event volume** (RT-3, take 2). The v0.1.8 rewrite correctly queried `SERVER_ONLY`/`WEB_ONLY` but summed `count` at the wrong level: Meta's `/stats?aggregation=event` returns **time buckets** (`{start_time, end_time, data:[{value,count}]}`), so the per-event counts are nested one level below `data`. Summing the outer rows always yielded `0`, so CAPI-active accounts still saw `server_events_7d:0` / `capi_active:false` / grade `F`. Now walks the nested `{value,count}` items (handling `count` as int or string). Locked in with a unit test (`sum_stats_event_counts`).
- **`playbook learning-accelerator` returns the insufficient-data state when ad sets have no conversions** (RT-5, completion). It still graded `F`/`0` when ad sets were running but recorded zero conversions in the window — there is no learning-phase trajectory to grade without conversions. Now returns `grade:"N/A"`, `score:null`, `insufficient_data:true` (matching `scale-roadmap` and the other diagnostics). The `total_adsets == 0` case was already handled; this adds the `total_conversions == 0` case.

## [0.1.8] — 2026-05-21

Behavioral/bugfix release from a live-account review (findings RT-1…RT-10). No command surface change.

### Security
- **Meta access tokens are now redacted from CLI stdout.** Meta Graph responses embed `access_token=EAA…` inside `paging.next`/`paging.previous` URLs; commands that print raw responses (e.g. `pixel stats`, `pixel events`, `catalog products`, and the CAPI `pixel send-event`/`send-batch` success output) leaked that token to terminal scrollback, CI logs, and piped captures. Tokens are now stripped from paging URLs at the source (so the HTTP API is covered too) and the CLI output formatter redacts any residual token. Opaque `paging.cursors` are preserved, so `--after` pagination is unaffected (RT-2).

### Fixed
- **`playbook capi-dual-signal` no longer reports a false "CAPI off / grade F"** on accounts where the Conversions API is actively firing. It sent the pixel `/stats` window as Unix epoch seconds (Meta expects `YYYY-MM-DD`) and read event counts from the wrong field, so it always saw zero server events. It now queries `SERVER_ONLY`/`WEB_ONLY` over a correct date range (RT-3).
- **Diagnostic playbooks now return a distinct "insufficient data" state** (`grade: "N/A"`, `score: null`, `insufficient_data: true`) when there is nothing to analyze, instead of disagreeing — some previously returned grade A/100 ("nothing flagged") and others grade F/0 ("zero average") for the same empty account (RT-1, RT-5).
- **`report insights --days` rejects `0` and negative values** with a clean "value must be ≥ 1" message instead of returning an ambiguous single-day window (`--days 0`) or a confusing `unexpected argument '-5'` (RT-8, RT-9).
- **`waste-audit` no longer prints `Best CPA adset:  at $0.00`** when no ad set had a conversion — it now says `N/A (no conversions in window)` (RT-10a).
- **`leadgen list` / `leadgen leads` give an actionable hint** when Meta returns `(#190) … Page Access Token` instead of surfacing the raw Graph error (RT-10c).

### Changed
- **Pixel-domain flags accept both `--id` and `--pixel-id` everywhere.** Previously `pixel get`/`stats`/`diagnostics` used `--id` while `pixel signal`/`quality`/`events` and `dataset pixel-*` used `--pixel-id`; both spellings now work across the whole pixel domain via aliases (RT-7).
- **Playbook ad-set counts now name their basis** so they reconcile across playbooks: "delivering in window" (health-score) vs "status-ACTIVE" (creative-mix/broad-targeting/event-hierarchy) vs "total" (duplicate-detect) (RT-6).
- **`apb campaign get --help`** now documents that `--id` accepts a numeric ID, an `@alias`, or an exact campaign name (auto-resolved) (NEW-2).

### Notes
- RT-4 (insights cache "ignores date range") was investigated and is **not a bug**: the response cache key already includes the full query (time range, level, increment). A regression test was added to lock this in. The reported identical spend across `--days 1/7/30` matched an account whose entire spend history fell within the shortest window.

## [0.1.7] — 2026-05-21

### Fixed
- **`apb plan` mutating commands now require the `write:campaigns` scope** (Agency tier+), matching the HTTP API. The CLI previously mapped every `plan` subcommand to `read:campaigns`, so a read-only–tier key could create/validate/execute/canary/approve plans from the CLI even though the API correctly rejected the same operations (`POST /plans/*` is gated `write:campaigns`). `plan list` and `plan doctor` remain `read:campaigns`. No change for Agency+ tiers.

## [0.1.6] — 2026-05-21

### Fixed
- **`apb auth login` now uses the baked production API URL.** It (and the stored-credential `base_url()` default) hardcoded `http://localhost:3000` and ignored the compile-time `APB_DEFAULT_API_URL`, so downloaded binaries failed `auth login` with "Failed to connect to SaaS API at http://localhost:3000" unless `--api-url` was passed. Both now fall back to `cli_resolver::DEFAULT_API_URL` (baked `https://api.agencyplaybook.io` in release builds; localhost only for local dev). Other commands were unaffected — they already resolved through that default.

## [0.1.5] — 2026-05-20

### Changed
- **macOS binary is now Developer ID-signed and notarized.** The `build-macos` CI job codesigns the universal binary (hardened runtime + secure timestamp) and submits it to Apple's notary service before publishing, so macOS no longer shows "Apple could not verify 'apb' is free of malware." A bare Mach-O can't be stapled, so Gatekeeper verifies the notarization ticket online by code hash.

## [0.1.4] — 2026-05-19

### Fixed
- **Linux binary glibc compatibility.** v0.1.3 built on `ubuntu-latest` (now Ubuntu 24.04, glibc 2.39), which made the Linux binary fail to run on Debian 12, Ubuntu 22.04 LTS, RHEL 9, and any older distro. Pinned `build-linux` and `publish` jobs to `ubuntu-22.04` (glibc 2.35) for broader compatibility. Same fix applied to the README's platform compatibility note.

## [0.1.3] — 2026-05-19

Adds a global config file so the downloaded binary works from any directory.

### Added
- `~/.apb/.env` global credentials file. The CLI loads it on every invocation after the project-local `.env`, so users with the downloaded binary set `APB_API_KEY` and `APB_API_URL` once and the CLI works from any cwd.
- Precedence order is now: shell env → CWD `.env` → `~/.apb/.env` → compile-time defaults. CWD wins on conflicts (per-project override pattern).
- Public README rewritten with platform-specific setup blocks (Linux/macOS bash + Windows PowerShell).

### Changed
- `rust/crates/apb-cli/src/main.rs` extended with `dotenvy::from_path(home/.apb/.env)` after the existing `dotenvy::dotenv()` call. Uses the existing `dirs` dep — no new deps added.

## [0.1.2] — 2026-05-19

Restores the Windows binary that was erroneously dropped in v0.1.1.

### Added
- `build-windows` job back in the release matrix (`windows-latest`, target `x86_64-pc-windows-msvc`). Produces `apb.exe` with `APB_DEFAULT_API_URL=https://api.agencyplaybook.io` baked in. RUSTFLAGS path-remap covers `C:\Users\runneradmin\.cargo`. Tee-to-file verification pattern matches Linux + macOS jobs.
- Publish job extended to handle 3 artifacts: writes to `bin/linux-x86_64/`, `bin/macos/`, `bin/windows-x86_64/`.

### Why
v0.1.1 dropped Windows after I misinterpreted "macOS/Linux version — which is what Claude Code does" as a directive to remove Windows entirely. It wasn't — the user was specifying the macOS distribution model (one universal binary instead of separate Intel/aarch64), not eliminating Windows. Windows was the one platform that built cleanly across every prior CI attempt; removing it solved no problem.

## [0.1.1] — 2026-05-19

First end-to-end CI release. Build matrix simplified to 2 jobs (Linux + macOS universal) following Claude Code's distribution model. Windows support deferred to WSL2 (run the Linux binary inside Ubuntu — no functionality loss).

### Changed
- Build matrix: 4 jobs → 2 jobs. `macos-x86_64` (Intel Mac runner, indefinitely queued due to GitHub macOS minutes quota) and `windows-x86_64` (deferred) both removed. macOS replaced with a single universal binary built on `macos-14` via `lipo -create` merging both arch slices.
- Public-repo layout: `bin/macos-x86_64/` and `bin/macos-aarch64/` collapsed into `bin/macos/`. `bin/windows-x86_64/` removed.

### Added
- macOS universal binary (Intel + Apple Silicon) shipped natively — runs on both architectures without Rosetta.
- Refreshed Linux x86_64 binary built by CI.

### Notes
- Binaries built with `APB_DEFAULT_API_URL=https://api.agencyplaybook.io` baked in.
- macOS verification step uses tee-to-file pattern (avoids `strings|grep -q` SIGPIPE under macOS toolchain).
- Windows users: see `docs/INSTALL.md` (or the public README) for WSL2 setup.

## [0.1.0] — 2026-05-19

Initial public release.

### Added
- Pre-built `apb` binary for Linux x86_64 (glibc 2.31+). macOS Intel, macOS Apple Silicon, and Windows x86_64 binaries arrive on the first CI tag build (`release.yml` workflow).
- Full CLI surface: 226 commands across 30 domains.
- Public docs: CLI reference, usage guide, safety model, API reference, automation patterns, campaign-composer guide, Meta API field reference.
- Example JSON specs: compose, carousel, lead-gen form, creative collection.
- MIT license on the public-binary repo.

### Notes
- Binary defaults `APB_API_URL` to `https://api.agencyplaybook.io` (the production API endpoint — currently in private beta). Override via the `APB_API_URL` env var for self-hosted endpoints or local development.
- All mutating commands require `--execute` (dry-run is default). Destructive ops additionally require `--confirm-destructive`. See `docs/SAFETY_MODEL.md`.
