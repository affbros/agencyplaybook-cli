# Changelog

All notable changes to the `apb` CLI binary distribution.

Format inspired by [Keep a Changelog](https://keepachangelog.com/). This file is mirrored to the public repo `affbros/agencyplaybook-cli` on every release tag.

## [Unreleased]

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
