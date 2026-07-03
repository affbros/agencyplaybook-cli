# Changelog — apb-gads (Google Ads CLI)

All notable changes to the `apb-gads` CLI binary distribution.

Format inspired by [Keep a Changelog](https://keepachangelog.com/). This file is mirrored to the public repo `affbros/agencyplaybook-cli` (as `CHANGELOG-gads.md`, beside `apb`'s `CHANGELOG.md`) on every `gads-v*` release tag. apb-gads has its own version line (`0.1.x`) and tags (`gads-vX.Y.Z`), independent of `apb`.

## [Unreleased]

## [0.1.13] — 2026-07-02 (correctness & gate-consistency patch)

No command/flag surface change — still **286 commands / 27 groups / 66 playbooks**.

### Fixed
- **HTTP client now has connect + request timeouts.** The Google Ads API client previously had no timeout at all, so a stalled endpoint could hang the CLI indefinitely (the worst-case CI failure mode). Added a bounded connect-timeout and request-timeout.
- **`validate demand-gen-spec` now exits 3 when the spec fails validation**, matching its own `--help` contract and its sibling validators (it previously always exited 0).
- **`doctor check` no longer discards offline portability diagnostics on an auth failure.** Portability is computed first; an auth error is captured as `auth_ok: false` + `auth_error` instead of aborting the whole command — exactly when a misconfigured first run needs those diagnostics.
- **`auth test` now returns a structured result** (`{valid, customer_count, resourceNames}`) instead of a raw passthrough of Google's `resourceNames`.
- **Clearer first-run errors.** A missing credentials file now names `google-ads.example.yaml` and `apb-gads auth login` instead of a raw "failed to read config".
- **`doctor check` now reports `binary_version`** (a top support-diagnostic field).

### Changed
- **Uniform write-gate output.** All three write gates now emit the same `advisories` key and a `decision` field (previously the key drifted between `local_gate_advisories`/`advisories`, and the sandbox gate omitted `decision`). The asset-path safety gate now follows the same advisory-by-default posture as the campaign gates instead of hard-failing — consistent with the gw1 model.
- Updated the CLI `about` string (dropped a stale "read-only … MVP" description; the 116 gated mutations shipped many versions ago).

### Security / CI
- Added a **public-repo mirror leak guard** (`check_public_mirror_leaks.py`), enforced in CI: only the curated public docs + skill directories are mirror-eligible, and the check fails if a live account identifier appears in any mirror-eligible path.
- The gads `cargo fmt --check` step is now a hard CI gate (previously advisory).

## [0.1.12] — 2026-07-02 (write-gate portability + PMAX pre-flight validators + audience/demographic fixes)

Ships the full `gads-write-gate-portability-001` workstream (Tier 1 + Tier 2 + follow-up fixes). No command/flag surface change — still **286 commands / 27 groups / 66 playbooks**. Safety-model behavior changed (see below).

### Changed — the binary no longer polices itself (Tier 1)
- **Local write/read gates are advisory by default.** The binary's own `permitted_operations` allowlist, `read_only`/`allow_writes`/`require_mutation_env` flags, budget caps, and sandbox rules no longer *block* an operation — they surface as advisories in the JSON output. The dry-run→live `--execute` toggle and the `audit.jsonl` write are unchanged. Authority/consent lives at the server/proxy (tier · scope · `write_policy`) and the MCP handshake + Skill — not baked into the tool. Opt back into strict local enforcement with `safety.enforce_local_gates: true`.
- **The server write-policy floor is enforced where it's actually enforceable.** In managed mode the SaaS `write_policy` (e.g. Starter = read-only) is re-checked server-side by the apb-api Google proxy, so the binary treats its local copy as advisory when the request is proven proxy-routed. BYO mode (no proxy in its path) keeps the local floor as its only backstop.

### Changed — managed-mode portability (Tier 1)
- **Stable `~/.apb-gads` state home.** With only `.env`/`APB_API_KEY` and no `google-ads.yaml`, `audit` logging, `context`, and `schedule` now work (they previously silently broke) — state resolves under `~/.apb-gads/` instead of erroring.
- **`verify pmax-launch` is portable.** PMAX bootstrap asset IDs come from the tenant's server profile; the hardcoded Scandalous-Coffee fallback is scoped to that one customer only — every other account gets a clear "bootstrap assets first" error instead of a cross-account `RESOURCE_NOT_FOUND`.
- **`doctor check` gained a `portability` block** — reports the config source (managed/byo/legacy), whether a local `google-ads.yaml` is loaded, and warns if one is silently shadowing managed mode.

### Added — PMAX pre-flight validators (Tier 2)
- **YouTube-only video attach** — `pmax-asset-attach --field-type YOUTUBE_VIDEO --asset-id <id>` best-effort-confirms the asset is actually a YouTube video before submitting; a confirmed mismatch points at `asset-create-youtube-video` (no MP4 upload path exists).
- **New-customer acquisition precondition** — `campaign-update-customer-acquisition --optimization-mode {TARGET_NEW_CUSTOMER|BID_HIGHER_FOR_NEW_CUSTOMER}` surfaces a `precondition_advisory` (needs an account-level existing-customer definition, else Google rejects the goal).
- **Demographic-signal-type guidance** — a demographic-looking `pmax-audience-signal-attach --signal-type` (e.g. `AGE_RANGE_35_44`) points at the real `audience-create` → `--signal-type AUDIENCE` workflow instead of a generic error.
- **Portrait aspect ratio** — an undersized `asset-create-image --field-type PORTRAIT_MARKETING_IMAGE` names the expected 4:5 ratio alongside the pixel minimums.
- **`INCOME_RANGE` on PMAX** — a household-income exclusion on a confirmed PERFORMANCE_MAX campaign is blocked pre-API (income isn't a PMAX control — only an Audience signal). `campaign-device-modifier-set --bid-modifier` help now documents `0.0` = exclude/opt-out.

### Fixed
- **Age-segmented audiences now work.** `audience-create --age-range AGE_RANGE_*` previously always failed against Google — the age dimension was serialized as bare enum strings, but the v24 `AgeDimension.age_ranges` is a repeated `AgeSegment` message of numeric bounds. Each `--age-range` now maps to its `{minAge, maxAge}` bucket (`AGE_RANGE_65_UP` → min-only; `AGE_RANGE_UNDETERMINED` → `includeUndetermined`). Gender/parental-status were already correct.
- **Positive campaign-level demographic targeting is blocked with clear guidance.** `campaign-demographic-add` without `--negative` (any demo type, any channel) previously produced a confusing raw Google `FIELD_INCOMPATIBLE_WITH_NEGATIVE_TARGETING` reject — campaign demographic criteria are exclusion-only. It now fails pre-API pointing at `campaign-demographic-exclude` (to exclude) or `ad-group-demographic-add` (for positive ad-group-level demographic bid adjustments).

## [0.1.11] — 2026-06-20 (competitive IS + smart-bidding misapplication — analysis-expansion S4–S5)

### Added
- **Competitive impression-share intelligence** — `playbook competitor-pressure` enhanced into an N-window impression-share competitive proxy: trends top-of-page erosion (`search_top_impression_share` + `search_absolute_top_impression_share`) alongside rank-lost IS over `--windows N`, decomposes "losing ground" into **rank-lost** (raise bid / improve Quality Score / tighten match) vs **budget-lost** (raise budget), and localizes with `--level campaign|ad_group|keyword`. Handles Google's IS clamping sentinels (`<10%` / `>90%`). **Honest about the API limit:** named-competitor / overlap / outranking data is NOT available via the Google Ads API — the playbook output and docs say so and point to the manual Google Ads UI Auction Insights report.
- **Smart-bidding misapplication diagnostic** — `playbook bid-strategy-mismatch` gains 3 conversion-volume rules: Target CPA under 30 conv → Maximize Conversions; Target ROAS under 15 conv (the documented Search/Shopping floor, **not** 50) → Maximize Conversion Value (or Maximize Conversions if value tracking is unhealthy); plus the symmetric Maximize-Conversion-Value case. Framed as the correct **entry** strategy for the volume tier (not a retreat); the manual switch is `mutate campaign-update-bidding-strategy`. New `--tcpa-min-conversions` / `--troas-min-conversions` / `--max-conv-value-min-conversions` flags.

No safety-model change; surface unchanged at **286 commands / 27 groups / 66 playbooks** (both sprints add flags/rules to existing playbooks).

## [0.1.10] — 2026-06-19 (search-term analysis suite — analysis-expansion S1–S3)

### Added
- **`playbook search-term-analysis`** — consolidated search-term analysis: ties each search term to its triggering keyword (text + match type), computes per-term CPA/ROAS, and emits BOTH promote candidates (high-ROI terms not yet keywords → keyword adds) and negate candidates (high-cost / zero-conversion → negatives) in **one combined `--output-spec`** for the dry-run-first apply pipeline (`plan from-audit` → `changes from-plan` → `changes apply`).
- **`playbook search-term-ngram-audit`** — decomposes search terms into 1/2/3-grams, aggregates spend/clicks/conversions per n-gram, and flags the most wasteful + most efficient patterns. Emits the wasteful **multi-word** n-grams as shared-negative candidates (`--shared-set <resource|id>`); 1-grams are surfaced but only emitted as negatives with `--include-unigram-negatives`.
- **Shared-negative-list action routing** — the actionable pipeline can now write **shared** negative-keyword lists (previously ad-group / campaign only). New `--negatives-to ad-group|campaign|shared` (default `ad-group`, behavior unchanged) + `--shared-set` on `waste-cluster-audit` and `search-term-analysis`; bad-term candidates route to a shared negative list via the existing guarded `apply_plan`.

### Changed
- Surface grows to **286 commands across 27 groups · 66 diagnostic playbooks**.

No safety-model change — every new write rides the existing three-gate + `apply_plan` guard. The shared-criterion *add* is auto-apply-eligible; shared-set *create* + campaign *attach* stay review-gated.

## [0.1.9] — 2026-06-18 (server-delivered guardrail profiles)

### Added
- **Server-delivered guardrail profiles** (agency-guardrails-001 Sprint 005). An agency authors a managed customer's guardrail once in the web app (**Agency → Guardrails**, `channel=google`: allowed domains + a daily-budget cap), and every `apb-gads` host that resolves the tenant's `APB_API_KEY` **applies it automatically** — no `google-ads.yaml` edit per customer.
  - The profiles ride along in the existing `/auth/resolve?provider=google_ads` response (no new round-trip) and are overlaid onto the customer's `SafetyProfile` + `LiveVerifyPolicy`: the central allowed-domains + daily-budget cap become the write authorization, with new ads forced **PAUSED**.
  - A local `google-ads.yaml` profile, where present, **always wins** (more-specific) — the central profile only fills the gap. Only `enforcement: block` profiles with a non-empty domain allowlist are applied; `warn`/`off` are advisory for now (gads' preflight is hard-fail).
- No new command or flag — this reuses gads' existing three-gate + `LiveVerifyPolicy` enforcement.

## [0.1.8] — 2026-06-18 (retail/Shopping PMax — `plan campaign pmax --merchant-id`)

### Added
- **`plan campaign pmax --merchant-id <N> [--feed-label <label>]`** — first-class retail (Shopping) Performance Max: the planner now emits a `shopping_setting` (Merchant Center account + optional feed label) in the launch spec, so `mutate pmax-launch` creates a PMax campaign that serves product ads from the linked feed. Previously the only way to set it was hand-editing the spec JSON. Pair with a fully-partitioned listing group (`mutate pmax-listing-group-filter-*`, with an "Other" node) so every product is covered.

No mutation-surface change — `pmax_mutations` already honored `shopping_setting`; this exposes it on the `plan campaign pmax` builder.

### Added
- **`verdict --include-paused`** — reactivation / post-mortem lens. By default `verdict` judges only ENABLED campaigns; with this flag PAUSED campaigns are judged too (their G1 Efficiency + G3 Quality history is still informative), each tagged with a per-entry `status`. Paused campaigns carry delivery **"n/a"** (no current pacing) so **SCALE can never fire** for a paused campaign; the output adds `mode: "reactivation"` and a `reactivation_note` reinterpreting the verbs — OPTIMIZE = was efficient, relaunch as-is · TIGHTEN = fix before relaunch · CAP/CUT = correctly killed, leave off · HOLD = ran too briefly to judge. The pure decision engine is unchanged; default (no-flag) output is byte-identical. Mirrors `apb verdict --include-paused` (apb `v0.5.16`). Part of decision-verdict-001.

### Fixed
- **Latent integer overflow in the `verdict` decision engine** — the zero-conversion quality check computed `cost_micros >= 3 * aov_micros.unwrap_or(i64::MAX)`, which overflowed (`i64::MAX * 3`) for **any** mature campaign with zero conversions (panic in debug, silent wrap in release). It was never hit before because earlier live checks ran against accounts whose active campaigns had conversions; an all-paused / zero-conversion account surfaced it. Fixed to treat an unknown AOV as "threshold unreachable" (no false CUT), matching the floating-point side's `f64::INFINITY` semantics.

## [0.1.6] — 2026-06-17

### Added
- **Conditional campaign caps** — `mutate campaign-cap --customer <CID> --campaign <ID> --until "<metric><op><value>"` freezes a campaign (pauses it via the guarded `campaign-update-status` path) and records a release condition (`metric` ∈ `roas|cpa|conv|spend`); `--until` is **required and validated up front** so nothing is frozen without a way out. `campaign-check-caps` re-fetches current metrics and un-pauses the campaigns whose condition has cleared; `campaign-list-caps` shows open caps. Caps persist to `~/.apb-gads/caps.json` (`0700`/`0600`). The condition grammar is byte-aligned with apb's `plan cap --until` (apb `v0.5.14`); gads has no plan framework, so the freeze is a direct guarded mutation rather than a `CAPPED` plan. Part of decision-verdict-001 S005.

## [0.1.5] — 2026-06-17

### Added
- **`campaign-type-advisor`** — prescriptive Search vs Performance Max vs Demand Gen recommendation: given a goal, demand state, conversion-signal strength, and daily budget it returns the primary engine plus the maturity-ordered sequence (Search captures existing demand · PMax scales it · Demand Gen creates new demand). Pure; pass `--customer` to ground the signal in the account's trailing-30-day conversions.
- **`playbook campaign-type-fit`** — scores an account's existing campaigns as `good_fit` / `misaligned` / `premature` against the advisor's doctrine and the verdict G3 maturity gate.
- **Demand Gen greenfield builder** — `plan campaign demand-gen` → `validate demand-gen-spec` → `orchestrate demand-gen-build`: an atomic, born-PAUSED Demand Gen campaign build with dry-run + `--validate-only` (SERVER_VALIDATED) support, reusing the existing responsive-video ad spec and gated campaign-create path. Part of decision-verdict-001 S004.

## [0.1.4] — 2026-06-16

### Added
- **`verdict --queue`** — ranks the per-campaign verdicts into a decision queue by **$ impact/day**, each with a next-action command (SCALE → `growth scale-up` / `playbook pmax-scaling-plan`; TIGHTEN → `playbook waste-cluster-audit` → negatives; CAP/CUT → `mutate campaign-update-status`) and a reallocation line (freed CAP'd budget → top SCALE candidate). Read-only — gads has no plan framework, so there is no conditional `plan cap` here (that's apb's `v0.5.14`); the freeze is a manual `mutate`. Part of the cross-CLI decision-verdict framework (decision-verdict-001 S003).

## [0.1.3] — 2026-06-16

### Added
- **`verdict` command** (`apb-gads verdict --customer <CID>`) — a per-campaign decision engine that emits one decisive verb (**SCALE / OPTIMIZE / TIGHTEN / CAP / HOLD / CUT**) for every ENABLED campaign across all channel types, from three platform-native gates: **Efficiency** (CPA/ROAS vs target, tiered), **Delivery+headroom** (budget-capped while efficient = the SCALE signal), and **Quality/signal** (maturity + conversion floor). Generalizes the `pmax-maturity-gate` readiness rollup to the whole account. Read-only; returns a queue ranked by spend with per-gate states, blockers, and a `next` action. `--target-roas`/`--target-cpa` set the efficiency target; `--min-age-days`/`--min-conversions` tune the maturity floor; `--lookback-days` the window. Part of the cross-CLI decision-verdict framework (see the `verdict-framework.md` skill reference).

## [0.1.2] — 2026-06-16

### Added
- **`account` command group** (`list` / `use` / `current` / `clear`) — persistent operating-account selection for agencies managing many accounts under one manager (MCC). Pick a current child account once (`apb-gads account use <customer_id>`, persisted to `~/.apb-gads/state.json` with `0600` perms) and every later command targets it **without repeating `--customer`**. Resolution precedence: `--customer` flag > persisted selection > config/SaaS default. The manager account (`login_customer_id`) is never switched — only the operating account. `account use` validates the id against your accessible accounts in SaaS mode, and `account current` reports the resolved account and where it came from.

### Changed
- Internal hardening: the gads crates now build clean under `cargo clippy -- -D warnings` and `rustfmt --check`, both CI hard-gated.

## [0.1.1] — 2026-06-12

### Added
- **Proxy auth mode (S008b)** — when the tenant is in proxy mode, `apb-gads` calls the AgencyPlaybook API edge authenticated with its `APB_API_KEY`; the real Google access/developer tokens are injected server-side and never disclosed to the binary.
- **Docs + Claude skill at `apb` parity** — full `apb-gads` command/flag reference, the `agencyplaybook-cli-google` Claude skill, and an in-app `/cli-reference/google` page. CI hard-gates skill / catalogue / generated-doc drift against the binary.

## [0.1.0] — 2026-06-11 (first public release)

The first published `apb-gads` binary — operator-grade Google Ads account management (reads, reports, agency "playbooks", and safe gated mutations), authenticated with your existing AgencyPlaybook API key.

### Added
- **3-platform binaries** published to `affbros/agencyplaybook-cli` (`bin/{linux-x86_64,macos,windows-x86_64}/apb-gads[.exe]`), beside `apb`. Downloaded binaries default to `https://api.agencyplaybook.io`.
- **SaaS authentication** — set one `APB_API_KEY` and `apb-gads` resolves Google Ads credentials from the AgencyPlaybook API (`/auth/resolve?provider=google_ads`); the Google refresh token never leaves the server. `apb-gads auth login` writes the shared `~/.apb/.env` (one login serves both `apb` and `apb-gads`); `auth status` and `auth connect-google` (OAuth device flow) round out the flow.
- **Two credential modes** — managed OAuth (server-held refresh token) or BYO local `google-ads.yaml` (`GOOGLE_ADS_OAUTH=DISABLED`); both require `APB_API_KEY` so tier/scope/entitlement are enforced.
- **Entitlement-aware** — the Google Ads add-on (Professional+) gates access; reads need Professional+, writes need Agency+. A read-only plan can't execute writes regardless of local config (the write-policy floor).
- **Safety preserved** — the contract-tested 3-gate write model (dry-run default; `--execute` + config + env gates; per-customer profiles / sandbox) is intact. Mutations are dry-run unless explicitly gated.
- `apb-gads --version`; `--pretty` JSON output; provider-namespaced credential cache (`~/.apb/tenant_context.google_ads.json`).

### Notes
- The **public binary refuses to run without `APB_API_KEY`** — Google Ads access is a paid add-on on the AgencyPlaybook platform.
- Surface: 28 command groups (`customer`, `campaign`, `report`, `playbook`, `mutate`, `plan`, `verify`, `auth`, …). See the bundled docs / `apb-gads --help`.
