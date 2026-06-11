# `apb-gads` — Complete CLI Reference

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

This is the **exhaustive, runtime-derived** reference for every command, subcommand, and parameter the `apb-gads` binary exposes. It is generated directly from `apb-gads --help`, so it is authoritative and cannot drift from the binary as long as the generator is re-run on each CLI change.

For narrative, examples, and *how to think about* the CLI, see [`../commands.md`](../commands.md) (day-to-day reference), [`../playbooks.md`](../playbooks.md), and [`../mutations.md`](../mutations.md) (the safety model). This directory is the flat, complete enumeration those docs defer to.

**At a glance:** 24 command groups · 271 total commands/subcommands · API version `v24`.

## Global options

These are defined on the top-level parser and accepted by (almost) every command. Per-command pages list only *command-specific* parameters and assume these are available.

| Option | Description |
|---|---|
| `--config <CONFIG>` | [default: google-ads.yaml] |
| `--customer <CUSTOMER>` | — |
| `--pretty` | Pretty-print JSON |
| `--execute` | Allow a mutating command to proceed past dry-run planning |
| `--validate-only` | When combined with --execute, sets validateOnly=true on every googleAds:mutate call. Google validates schema + policy + auth server-side and returns empty results; no entities created or updated. Used by scripts/qa_test_account.sh Tier 3 SERVER_VALIDATED sweep. |
| `--confirm` | Confirm operations whose amount_micros exceeds a safety profile's require_confirmation_above_micros threshold |
| `--lookback-days <LOOKBACK_DAYS>` | Override the per-playbook default lookback window (in days) for any read that uses a date range |
| `--output <OUTPUT>` | Write JSON output to this file path instead of stdout |
| `--save-plan <SAVE_PLAN>` | After a dry-run mutation, write a normalized plan JSON to this path (re-playable via `mutate apply-plan`) |
| `-h, --help` | Print help |
| `-V, --version` | Print version |

## Safety model (writes)

Every `mutate` subcommand — and the write paths inside `orchestrate`, `changes`, `verify`, and `sandbox` — is **dry-run by default**. A write only goes out when three independent gates all pass *and* a per-customer profile or the sandbox policy authorizes the specific operation:

1. **CLI gate** — `--execute` on the command line.
2. **Config gate** — `safety.allow_writes: true` + `safety.read_only: false` in `google-ads.yaml`.
3. **Env gate** — `APB_GADS_ALLOW_MUTATIONS=true` (when `safety.require_mutation_env: true`).

There is no bypass flag. The global `--validate-only` flag turns any `mutate` into a server-side schema/policy check (`validateOnly=true`) that creates nothing. Full details: [`../mutations.md`](../mutations.md) and [`../configuration.md`](../configuration.md).

## Command groups

| Group | Surface | Commands | Description |
|---|---|---|---|
| [`auth`](auth.md) | 👁️ read | 6 | Authentication checks against the configured OAuth credentials. |
| [`doctor`](doctor.md) | 👁️ read | 1 | Environment / configuration diagnostics — verify the CLI is wired up correctly. |
| [`customer`](customer.md) | 👁️ read | 2 | Customer (account) reads: list accessible accounts and walk the MCC hierarchy. |
| [`campaign`](campaign.md) | 👁️ read | 2 | Campaign reads: list and inspect campaigns on the operating account. |
| [`ad-group`](ad-group.md) | 👁️ read | 1 | Ad-group reads: list ad groups under a campaign. |
| [`ad`](ad.md) | 👁️ read | 1 | Ad reads: list ads under an ad group. |
| [`keyword`](keyword.md) | 👁️ read | 1 | Keyword reads: list ad-group keyword criteria. |
| [`negative-keyword`](negative-keyword.md) | 👁️ read | 1 | Negative-keyword reads. |
| [`asset`](asset.md) | 👁️ read | 1 | Asset reads: list account assets (images, text, video, etc.). |
| [`mutate`](mutate.md) | ✍️ write | 116 | Every write surface. Dry-run by default; gated behind the three-gate safety model. |
| [`gaql`](gaql.md) | 👁️ read | 1 | Run ad-hoc Google Ads Query Language (GAQL) against the searchStream endpoint. |
| [`report`](report.md) | 👁️ read | 23 | Named, pre-built read reports (search terms, performance, PMAX, etc.). |
| [`playbook`](playbook.md) | 👁️ read | 64 | Agency-style read playbooks: audits, scorecards, and hygiene readouts. |
| [`plan`](plan.md) | 👁️ read | 11 | Phase B1 (v24) — keyword planning surface (reads only). |
| [`sandbox`](sandbox.md) | ✍️ write | 1 | Test-sandbox write flows: end-to-end helper(s) that exercise the $1 sandbox policy (create → verify → clean up) on a disposable entity. |
| [`orchestrate`](orchestrate.md) | ✍️ write | 7 | Phase 3 composite workflows — orchestrators that compose primitives into end-to-end operator flows (ad-rotate, campaign-launch, etc.) |
| [`audit`](audit.md) | 👁️ read | 3 | Sprint D — audit log inspection + replay |
| [`schedule`](schedule.md) | 👁️ read | 7 | Sprint G — schedule read-only playbooks / orchestrators via the system crontab. |
| [`verify`](verify.md) | ✍️ write | 9 | Sprint W — live-execute verification. |
| [`changes`](changes.md) | ✍️ write | 3 | Artifact pipeline — turn a scored ActionPlan (from `plan from-audit`) into a reviewable Changeset and apply it through the guarded plan path. |
| [`growth`](growth.md) | 👁️ read | 5 | Growth analysis — dual-window weekly/monthly performance reviews and guardrail-based monitoring. |
| [`export`](export.md) | 👁️ read | 1 | Render an artifact JSON into CSV, JSON, or Markdown. |
| [`context`](context.md) | 👁️ read | 2 | Per-customer goal/strategy context state. |
| [`validate`](validate.md) | 👁️ read | 2 | Inspect planning artifacts for launch-readiness. |

## Full command index

Every leaf command, grouped. Click through to the parameter-level page.

### `auth`

- [`apb-gads auth test`](auth.md#apb-gads-auth-test)
- [`apb-gads auth accessible-customers`](auth.md#apb-gads-auth-accessible-customers)
- [`apb-gads auth refresh-token-help`](auth.md#apb-gads-auth-refresh-token-help)
- [`apb-gads auth login`](auth.md#apb-gads-auth-login) — Validate an AgencyPlaybook API key and save it to the shared `~/.apb/.env` (one login serves both `apb` and `apb-gads`)
- [`apb-gads auth status`](auth.md#apb-gads-auth-status) — Show the Google Ads connection status for the current API key
- [`apb-gads auth connect-google`](auth.md#apb-gads-auth-connect-google) — Connect Google Ads via the OAuth device flow (opens your browser, then polls)

### `doctor`

- [`apb-gads doctor check`](doctor.md#apb-gads-doctor-check)

### `customer`

- [`apb-gads customer list`](customer.md#apb-gads-customer-list)
- [`apb-gads customer suggest-brands`](customer.md#apb-gads-customer-suggest-brands) — Suggest verified brands for a name prefix (BrandSuggestionService).

### `campaign`

- [`apb-gads campaign list`](campaign.md#apb-gads-campaign-list)
- [`apb-gads campaign get`](campaign.md#apb-gads-campaign-get)

### `ad-group`

- [`apb-gads ad-group list`](ad-group.md#apb-gads-ad-group-list)

### `ad`

- [`apb-gads ad list`](ad.md#apb-gads-ad-list)

### `keyword`

- [`apb-gads keyword list`](keyword.md#apb-gads-keyword-list)

### `negative-keyword`

- [`apb-gads negative-keyword list`](negative-keyword.md#apb-gads-negative-keyword-list)

### `asset`

- [`apb-gads asset list`](asset.md#apb-gads-asset-list)

### `mutate`

- [`apb-gads mutate apply-plan`](mutate.md#apb-gads-mutate-apply-plan) — Sprint D — re-apply a plan JSON (from --save-plan) to the API.
- [`apb-gads mutate inverse-plan`](mutate.md#apb-gads-mutate-inverse-plan) — Sprint D — generate a compensating (inverse) plan from an audit log entry.
- [`apb-gads mutate campaign-budget-create`](mutate.md#apb-gads-mutate-campaign-budget-create)
- [`apb-gads mutate negative-keyword-add`](mutate.md#apb-gads-mutate-negative-keyword-add)
- [`apb-gads mutate negative-keyword-add-bulk`](mutate.md#apb-gads-mutate-negative-keyword-add-bulk)
- [`apb-gads mutate campaign-negative-keyword-add`](mutate.md#apb-gads-mutate-campaign-negative-keyword-add)
- [`apb-gads mutate campaign-negative-keyword-add-bulk`](mutate.md#apb-gads-mutate-campaign-negative-keyword-add-bulk)
- [`apb-gads mutate campaign-negative-webpage-add-bulk`](mutate.md#apb-gads-mutate-campaign-negative-webpage-add-bulk) — Sprint B.3: bulk WEBPAGE negative criterion adds on N campaigns (consumer for `pmax-url-exclusion-audit`).
- [`apb-gads mutate keyword-add-bulk`](mutate.md#apb-gads-mutate-keyword-add-bulk)
- [`apb-gads mutate criterion-remove-bulk`](mutate.md#apb-gads-mutate-criterion-remove-bulk)
- [`apb-gads mutate campaign-update-status-bulk`](mutate.md#apb-gads-mutate-campaign-update-status-bulk)
- [`apb-gads mutate ad-create-bulk`](mutate.md#apb-gads-mutate-ad-create-bulk)
- [`apb-gads mutate campaign-budget-update-bulk`](mutate.md#apb-gads-mutate-campaign-budget-update-bulk)
- [`apb-gads mutate campaign-update-bidding-strategy-bulk`](mutate.md#apb-gads-mutate-campaign-update-bidding-strategy-bulk)
- [`apb-gads mutate ad-update-status-bulk`](mutate.md#apb-gads-mutate-ad-update-status-bulk)
- [`apb-gads mutate keyword-update-match-type-bulk`](mutate.md#apb-gads-mutate-keyword-update-match-type-bulk)
- [`apb-gads mutate keyword-bid-set-bulk`](mutate.md#apb-gads-mutate-keyword-bid-set-bulk)
- [`apb-gads mutate keyword-update-match-type`](mutate.md#apb-gads-mutate-keyword-update-match-type)
- [`apb-gads mutate ad-update-status`](mutate.md#apb-gads-mutate-ad-update-status)
- [`apb-gads mutate ad-group-criterion-update`](mutate.md#apb-gads-mutate-ad-group-criterion-update)
- [`apb-gads mutate budget-transfer`](mutate.md#apb-gads-mutate-budget-transfer)
- [`apb-gads mutate conversion-action-update`](mutate.md#apb-gads-mutate-conversion-action-update)
- [`apb-gads mutate conversion-action-update-value`](mutate.md#apb-gads-mutate-conversion-action-update-value) — Update `value_settings.default_value` (and optionally `value_settings.always_use_default_value`) on an existing conversion action.
- [`apb-gads mutate customer-negative-criterion-add`](mutate.md#apb-gads-mutate-customer-negative-criterion-add)
- [`apb-gads mutate customer-negative-criterion-remove`](mutate.md#apb-gads-mutate-customer-negative-criterion-remove)
- [`apb-gads mutate customer-negative-criterion-add-bulk`](mutate.md#apb-gads-mutate-customer-negative-criterion-add-bulk) — Sprint B.2: bulk variant of `customer-negative-criterion-add` for the KEYWORD path.
- [`apb-gads mutate user-list-create`](mutate.md#apb-gads-mutate-user-list-create)
- [`apb-gads mutate audience-create`](mutate.md#apb-gads-mutate-audience-create) — Create an Audience resource (in-market/affinity/user-list/custom + demographics).
- [`apb-gads mutate pmax-listing-group-filter-create`](mutate.md#apb-gads-mutate-pmax-listing-group-filter-create)
- [`apb-gads mutate pmax-listing-group-filter-remove`](mutate.md#apb-gads-mutate-pmax-listing-group-filter-remove)
- [`apb-gads mutate asset-create-youtube-video`](mutate.md#apb-gads-mutate-asset-create-youtube-video)
- [`apb-gads mutate asset-create-image`](mutate.md#apb-gads-mutate-asset-create-image)
- [`apb-gads mutate campaign-update-status`](mutate.md#apb-gads-mutate-campaign-update-status)
- [`apb-gads mutate ad-create`](mutate.md#apb-gads-mutate-ad-create)
- [`apb-gads mutate campaign-create`](mutate.md#apb-gads-mutate-campaign-create)
- [`apb-gads mutate ad-group-create`](mutate.md#apb-gads-mutate-ad-group-create)
- [`apb-gads mutate keyword-add`](mutate.md#apb-gads-mutate-keyword-add)
- [`apb-gads mutate keyword-bid-set`](mutate.md#apb-gads-mutate-keyword-bid-set)
- [`apb-gads mutate campaign-budget-update`](mutate.md#apb-gads-mutate-campaign-budget-update)
- [`apb-gads mutate criterion-remove`](mutate.md#apb-gads-mutate-criterion-remove)
- [`apb-gads mutate ad-remove`](mutate.md#apb-gads-mutate-ad-remove)
- [`apb-gads mutate ad-group-remove`](mutate.md#apb-gads-mutate-ad-group-remove)
- [`apb-gads mutate campaign-remove`](mutate.md#apb-gads-mutate-campaign-remove)
- [`apb-gads mutate campaign-budget-remove`](mutate.md#apb-gads-mutate-campaign-budget-remove)
- [`apb-gads mutate pmax-campaign-create`](mutate.md#apb-gads-mutate-pmax-campaign-create)
- [`apb-gads mutate pmax-asset-group-create`](mutate.md#apb-gads-mutate-pmax-asset-group-create)
- [`apb-gads mutate pmax-asset-group-remove`](mutate.md#apb-gads-mutate-pmax-asset-group-remove)
- [`apb-gads mutate pmax-asset-attach`](mutate.md#apb-gads-mutate-pmax-asset-attach)
- [`apb-gads mutate pmax-asset-detach`](mutate.md#apb-gads-mutate-pmax-asset-detach)
- [`apb-gads mutate pmax-launch`](mutate.md#apb-gads-mutate-pmax-launch)
- [`apb-gads mutate ad-validate`](mutate.md#apb-gads-mutate-ad-validate)
- [`apb-gads mutate campaign-geo-add`](mutate.md#apb-gads-mutate-campaign-geo-add)
- [`apb-gads mutate campaign-language-add`](mutate.md#apb-gads-mutate-campaign-language-add)
- [`apb-gads mutate campaign-device-modifier-set`](mutate.md#apb-gads-mutate-campaign-device-modifier-set)
- [`apb-gads mutate campaign-ad-schedule-add`](mutate.md#apb-gads-mutate-campaign-ad-schedule-add)
- [`apb-gads mutate campaign-audience-add`](mutate.md#apb-gads-mutate-campaign-audience-add)
- [`apb-gads mutate campaign-demographic-exclude`](mutate.md#apb-gads-mutate-campaign-demographic-exclude)
- [`apb-gads mutate campaign-ipblock-add`](mutate.md#apb-gads-mutate-campaign-ipblock-add)
- [`apb-gads mutate campaign-demographic-add`](mutate.md#apb-gads-mutate-campaign-demographic-add)
- [`apb-gads mutate campaign-proximity-add`](mutate.md#apb-gads-mutate-campaign-proximity-add)
- [`apb-gads mutate campaign-content-label-exclude`](mutate.md#apb-gads-mutate-campaign-content-label-exclude)
- [`apb-gads mutate campaign-placement-exclude`](mutate.md#apb-gads-mutate-campaign-placement-exclude)
- [`apb-gads mutate campaign-topic-exclude`](mutate.md#apb-gads-mutate-campaign-topic-exclude)
- [`apb-gads mutate campaign-youtube-video-exclude`](mutate.md#apb-gads-mutate-campaign-youtube-video-exclude)
- [`apb-gads mutate campaign-youtube-channel-exclude`](mutate.md#apb-gads-mutate-campaign-youtube-channel-exclude)
- [`apb-gads mutate campaign-mobile-app-exclude`](mutate.md#apb-gads-mutate-campaign-mobile-app-exclude)
- [`apb-gads mutate campaign-criterion-remove`](mutate.md#apb-gads-mutate-campaign-criterion-remove)
- [`apb-gads mutate campaign-update-bidding-strategy`](mutate.md#apb-gads-mutate-campaign-update-bidding-strategy)
- [`apb-gads mutate campaign-update-dates`](mutate.md#apb-gads-mutate-campaign-update-dates)
- [`apb-gads mutate campaign-update-network-settings`](mutate.md#apb-gads-mutate-campaign-update-network-settings)
- [`apb-gads mutate campaign-update-frequency-cap`](mutate.md#apb-gads-mutate-campaign-update-frequency-cap)
- [`apb-gads mutate pmax-audience-signal-attach`](mutate.md#apb-gads-mutate-pmax-audience-signal-attach)
- [`apb-gads mutate pmax-audience-signal-detach`](mutate.md#apb-gads-mutate-pmax-audience-signal-detach)
- [`apb-gads mutate shared-set-create`](mutate.md#apb-gads-mutate-shared-set-create)
- [`apb-gads mutate shared-criterion-add`](mutate.md#apb-gads-mutate-shared-criterion-add)
- [`apb-gads mutate campaign-shared-set-attach`](mutate.md#apb-gads-mutate-campaign-shared-set-attach)
- [`apb-gads mutate campaign-brand-list-exclude`](mutate.md#apb-gads-mutate-campaign-brand-list-exclude) — Exclude a BRANDS shared set (brand list) from a campaign as a NEGATIVE brand-list criterion — competitor-brand exclusion (PMAX & gated channels allow brand lists only negatively).
- [`apb-gads mutate conversion-action-create`](mutate.md#apb-gads-mutate-conversion-action-create)
- [`apb-gads mutate shared-criterion-remove`](mutate.md#apb-gads-mutate-shared-criterion-remove)
- [`apb-gads mutate campaign-shared-set-detach`](mutate.md#apb-gads-mutate-campaign-shared-set-detach)
- [`apb-gads mutate shared-set-remove`](mutate.md#apb-gads-mutate-shared-set-remove)
- [`apb-gads mutate campaign-update-tracking-url`](mutate.md#apb-gads-mutate-campaign-update-tracking-url)
- [`apb-gads mutate ad-create-video-responsive`](mutate.md#apb-gads-mutate-ad-create-video-responsive) — Create a VideoResponsiveAd (v24).
- [`apb-gads mutate ad-update-video-responsive`](mutate.md#apb-gads-mutate-ad-update-video-responsive) — Partial update of a VideoResponsiveAd (v24 made VideoResponsiveAdInfo mutable).
- [`apb-gads mutate ad-create-demandgen-video-responsive`](mutate.md#apb-gads-mutate-ad-create-demandgen-video-responsive) — Create a DemandGenVideoResponsiveAd (v24).
- [`apb-gads mutate customer-update-video-brand-safety`](mutate.md#apb-gads-mutate-customer-update-video-brand-safety) — Set customer-level video brand safety (v24).
- [`apb-gads mutate campaign-update-vtc-optimization`](mutate.md#apb-gads-mutate-campaign-update-vtc-optimization) — Toggle view-through conversion optimization on a campaign.
- [`apb-gads mutate campaign-update-target-impression-share`](mutate.md#apb-gads-mutate-campaign-update-target-impression-share)
- [`apb-gads mutate campaign-update-customer-acquisition`](mutate.md#apb-gads-mutate-campaign-update-customer-acquisition)
- [`apb-gads mutate campaign-update-geo-target-type`](mutate.md#apb-gads-mutate-campaign-update-geo-target-type)
- [`apb-gads mutate campaign-update-ad-rotation`](mutate.md#apb-gads-mutate-campaign-update-ad-rotation)
- [`apb-gads mutate campaign-update-url-expansion-opt-out`](mutate.md#apb-gads-mutate-campaign-update-url-expansion-opt-out) — Opt a campaign out of (or back into) final-URL-expansion text-asset automation — the v24 lever (campaign.asset_automation_settings, FINAL_URL_EXPANSION_TEXT_ASSET_AUTOMATION) that replaced the removed `url_expansion_opt_out` boolean.
- [`apb-gads mutate bidding-strategy-create`](mutate.md#apb-gads-mutate-bidding-strategy-create)
- [`apb-gads mutate bidding-strategy-remove`](mutate.md#apb-gads-mutate-bidding-strategy-remove) — Remove a portfolio (shared) bidding strategy.
- [`apb-gads mutate campaign-attach-portfolio-bidding`](mutate.md#apb-gads-mutate-campaign-attach-portfolio-bidding)
- [`apb-gads mutate bidding-seasonality-adjustment-create`](mutate.md#apb-gads-mutate-bidding-seasonality-adjustment-create)
- [`apb-gads mutate bidding-data-exclusion-create`](mutate.md#apb-gads-mutate-bidding-data-exclusion-create)
- [`apb-gads mutate conversion-value-rule-create`](mutate.md#apb-gads-mutate-conversion-value-rule-create) — Create a conversion value rule (account-level): adjust the conversion VALUE Smart Bidding optimizes toward, by geo/device/audience — the modern replacement for geo/device/audience bid adjustments under value-based bidding (Max Conv Value / Target ROAS).
- [`apb-gads mutate campaign-conversion-goal-set`](mutate.md#apb-gads-mutate-campaign-conversion-goal-set)
- [`apb-gads mutate ad-group-audience-add`](mutate.md#apb-gads-mutate-ad-group-audience-add)
- [`apb-gads mutate ad-group-demographic-add`](mutate.md#apb-gads-mutate-ad-group-demographic-add)
- [`apb-gads mutate ad-group-placement-add`](mutate.md#apb-gads-mutate-ad-group-placement-add)
- [`apb-gads mutate asset-create-sitelink`](mutate.md#apb-gads-mutate-asset-create-sitelink)
- [`apb-gads mutate asset-create-callout`](mutate.md#apb-gads-mutate-asset-create-callout)
- [`apb-gads mutate asset-create-structured-snippet`](mutate.md#apb-gads-mutate-asset-create-structured-snippet)
- [`apb-gads mutate asset-create-promotion`](mutate.md#apb-gads-mutate-asset-create-promotion)
- [`apb-gads mutate asset-create-call`](mutate.md#apb-gads-mutate-asset-create-call)
- [`apb-gads mutate asset-create-price`](mutate.md#apb-gads-mutate-asset-create-price)
- [`apb-gads mutate campaign-asset-attach`](mutate.md#apb-gads-mutate-campaign-asset-attach)
- [`apb-gads mutate campaign-asset-detach`](mutate.md#apb-gads-mutate-campaign-asset-detach)
- [`apb-gads mutate ad-group-asset-attach`](mutate.md#apb-gads-mutate-ad-group-asset-attach)
- [`apb-gads mutate ad-group-asset-detach`](mutate.md#apb-gads-mutate-ad-group-asset-detach)
- [`apb-gads mutate customer-asset-attach`](mutate.md#apb-gads-mutate-customer-asset-attach)
- [`apb-gads mutate customer-asset-detach`](mutate.md#apb-gads-mutate-customer-asset-detach)
- [`apb-gads mutate experiment-create`](mutate.md#apb-gads-mutate-experiment-create)
- [`apb-gads mutate experiment-end`](mutate.md#apb-gads-mutate-experiment-end)

### `gaql`

- [`apb-gads gaql query`](gaql.md#apb-gads-gaql-query)

### `report`

- [`apb-gads report account-summary-365d`](report.md#apb-gads-report-account-summary-365d)
- [`apb-gads report campaign-performance-365d`](report.md#apb-gads-report-campaign-performance-365d)
- [`apb-gads report monthly-breakdown-365d`](report.md#apb-gads-report-monthly-breakdown-365d)
- [`apb-gads report search-terms-365d`](report.md#apb-gads-report-search-terms-365d)
- [`apb-gads report pmax-summary`](report.md#apb-gads-report-pmax-summary)
- [`apb-gads report asset-usage`](report.md#apb-gads-report-asset-usage)
- [`apb-gads report pmax-asset-groups`](report.md#apb-gads-report-pmax-asset-groups)
- [`apb-gads report pmax-asset-group-assets`](report.md#apb-gads-report-pmax-asset-group-assets)
- [`apb-gads report pmax-asset-group-performance`](report.md#apb-gads-report-pmax-asset-group-performance)
- [`apb-gads report pmax-placements`](report.md#apb-gads-report-pmax-placements) — PMAX placement + channel-proxy visibility (the black box): where ads ran (performance_max_placement_view, impressions-only — for brand-safety exclusions) aggregated by placement_type, plus PMAX campaign metrics.
- [`apb-gads report campaign-settings`](report.md#apb-gads-report-campaign-settings)
- [`apb-gads report campaign-criteria`](report.md#apb-gads-report-campaign-criteria)
- [`apb-gads report shared-sets`](report.md#apb-gads-report-shared-sets)
- [`apb-gads report shared-criteria`](report.md#apb-gads-report-shared-criteria)
- [`apb-gads report campaign-shared-sets`](report.md#apb-gads-report-campaign-shared-sets)
- [`apb-gads report pmax-audience-signals`](report.md#apb-gads-report-pmax-audience-signals)
- [`apb-gads report experiments`](report.md#apb-gads-report-experiments)
- [`apb-gads report ad-approval-status`](report.md#apb-gads-report-ad-approval-status)
- [`apb-gads report impression-share-detail`](report.md#apb-gads-report-impression-share-detail)
- [`apb-gads report shopping-products`](report.md#apb-gads-report-shopping-products) — v24 shopping: list products from the account's linked Merchant Center feed.
- [`apb-gads report shopping-performance`](report.md#apb-gads-report-shopping-performance) — v24 shopping: per-product performance over the resolved lookback window (default 30d; override via --lookback-days).
- [`apb-gads report cart-data-sales`](report.md#apb-gads-report-cart-data-sales) — v24 CartDataSalesView — segments by product SOLD (not clicked).
- [`apb-gads report customer-settings`](report.md#apb-gads-report-customer-settings) — Customer-level settings (v24).

### `playbook`

- [`apb-gads playbook list`](playbook.md#apb-gads-playbook-list)
- [`apb-gads playbook weekly-audit`](playbook.md#apb-gads-playbook-weekly-audit) — Account spend snapshot, top campaigns, search terms, and PMAX presence in one bundle.
- [`apb-gads playbook waste-audit`](playbook.md#apb-gads-playbook-waste-audit) — Identify expensive search terms with poor or zero conversions plus other obvious spend leaks.
- [`apb-gads playbook pmax-audit`](playbook.md#apb-gads-playbook-pmax-audit) — PMAX summary, asset groups, asset-group assets, asset-group performance, plus diagnostics flags (waste, dormant, missing required assets).
- [`apb-gads playbook launch-check`](playbook.md#apb-gads-playbook-launch-check) — Verify presence of campaigns, ad groups, ads, keywords, and PMAX entities before going live.
- [`apb-gads playbook creative-refresh`](playbook.md#apb-gads-playbook-creative-refresh) — Ad inventory + asset usage + top search-term inputs for the next creative iteration.
- [`apb-gads playbook account-health`](playbook.md#apb-gads-playbook-account-health) — Structured health scorecard with status counts, trailing-365-day spend signals, and recommended next actions.
- [`apb-gads playbook search-term-cleanup`](playbook.md#apb-gads-playbook-search-term-cleanup) — Surface negative-keyword candidates from search terms with ad-group context for bulk apply.
- [`apb-gads playbook account-structure-audit`](playbook.md#apb-gads-playbook-account-structure-audit) — Density mapping: ads per ad group, keywords per ad group, ad groups per campaign.
- [`apb-gads playbook conversion-tracking-check`](playbook.md#apb-gads-playbook-conversion-tracking-check) — List configured conversion actions and flag REMOVED, HIDDEN, or unverified ones.
- [`apb-gads playbook conversion-tracking-audit`](playbook.md#apb-gads-playbook-conversion-tracking-audit) — Comprehensive v24 audit: tag health, full conversion-action settings (attribution, value, lookbacks, origin-specific), customer + per-campaign goal mapping, custom variables, value-rule sets, account links, plus actionable findings (severity-coded).
- [`apb-gads playbook geo-performance`](playbook.md#apb-gads-playbook-geo-performance) — Cost and conversions broken out by geographic location to inform geo-targeting changes.
- [`apb-gads playbook device-performance`](playbook.md#apb-gads-playbook-device-performance) — Desktop vs mobile vs tablet performance comparison.
- [`apb-gads playbook dayparting-analysis`](playbook.md#apb-gads-playbook-dayparting-analysis) — Performance by day-of-week and hour-of-day to inform ad scheduling adjustments.
- [`apb-gads playbook ad-extension-coverage`](playbook.md#apb-gads-playbook-ad-extension-coverage) — Per-campaign sitelink, callout, and structured snippet coverage; flag thin extensions.
- [`apb-gads playbook budget-pacing`](playbook.md#apb-gads-playbook-budget-pacing) — Compare daily-budget * days-elapsed against actual cost for the current month per campaign.
- [`apb-gads playbook impression-share-loss`](playbook.md#apb-gads-playbook-impression-share-loss) — Surface impression share lost to budget and lost to rank per campaign.
- [`apb-gads playbook quality-score-audit`](playbook.md#apb-gads-playbook-quality-score-audit) — Distribution of keyword quality scores; flag low-QS keywords with significant spend.
- [`apb-gads playbook naming-convention-audit`](playbook.md#apb-gads-playbook-naming-convention-audit) — Flag campaigns and ad groups whose names don't match common operator patterns.
- [`apb-gads playbook campaign-bid-strategy-audit`](playbook.md#apb-gads-playbook-campaign-bid-strategy-audit) — Mix of bidding strategies in use across campaigns with status and channel context.
- [`apb-gads playbook seasonality-overview`](playbook.md#apb-gads-playbook-seasonality-overview) — 365-day month-over-month spend, conversion, and CPA trend to spot seasonal patterns.
- [`apb-gads playbook keyword-match-type-mix`](playbook.md#apb-gads-playbook-keyword-match-type-mix) — Distribution of BROAD/PHRASE/EXACT keywords; flag campaigns with imbalanced mix.
- [`apb-gads playbook duplicate-keywords`](playbook.md#apb-gads-playbook-duplicate-keywords) — Find keywords with the same text + match-type appearing across multiple ad groups.
- [`apb-gads playbook broad-match-conversion-rate`](playbook.md#apb-gads-playbook-broad-match-conversion-rate) — Identify broad-match keywords with poor conversion rates that should be paused or refined.
- [`apb-gads playbook negative-keyword-coverage`](playbook.md#apb-gads-playbook-negative-keyword-coverage) — Per-ad-group negative-keyword counts; flag groups with zero or very few negatives.
- [`apb-gads playbook competitor-keyword-bleed`](playbook.md#apb-gads-playbook-competitor-keyword-bleed) — Search terms hitting known competitor brand patterns; group by brand for triage.
- [`apb-gads playbook ad-rotation-audit`](playbook.md#apb-gads-playbook-ad-rotation-audit) — Ads per ad group; flag ad groups with fewer than 3 active ads (Google's minimum).
- [`apb-gads playbook landing-page-audit`](playbook.md#apb-gads-playbook-landing-page-audit) — Group ads by final URL; flag URLs with very low traffic or used by only one ad.
- [`apb-gads playbook budget-rebalance`](playbook.md#apb-gads-playbook-budget-rebalance) — Rank campaigns by ROAS and recommend shifting budget from low-ROAS to high-ROAS campaigns.
- [`apb-gads playbook anomaly-detection`](playbook.md#apb-gads-playbook-anomaly-detection) — Week-over-week spend / clicks / conversion change alerts; flags newly-active and newly-dark campaigns.
- [`apb-gads playbook cross-network-performance`](playbook.md#apb-gads-playbook-cross-network-performance) — Split metrics by Search vs Display vs YouTube vs Partner Search networks with per-network ROAS.
- [`apb-gads playbook audience-performance`](playbook.md#apb-gads-playbook-audience-performance) — Per-audience-type aggregation across in-market, remarketing, demographics; surfaces CPA per type.
- [`apb-gads playbook pmax-asset-coverage`](playbook.md#apb-gads-playbook-pmax-asset-coverage) — Per-asset-group field-type completeness scoring with policy-configurable minimums + advisories: missing YOUTUBE_VIDEO (Important), portrait-image recommendation, and audience-signal presence (Important).
- [`apb-gads playbook pmax-maturity-gate`](playbook.md#apb-gads-playbook-pmax-maturity-gate) — Per-PMAX-campaign readiness verdict: maturity (age≥30d OR ≥50 conv), CPA-vs-target performance tier (star/performer/underperformer/problem/starved), learning-band approximation, and PMax-vs-Search ROAS ratio → ready_to_scale / optimize / collect_data / pause_candidate with named blockers.
- [`apb-gads playbook pmax-scaling-plan`](playbook.md#apb-gads-playbook-pmax-scaling-plan) — Per-PMAX-campaign Go/No-Go budget-scaling decision (maturity + profitability vs target + no halt band + no bid+budget stacking checked vs audit.jsonl); on Go recommends a single-step budget increase capped at 50% and emits a budget_update_candidates spec → CampaignBudgetUpdateBulk (review-gated).
- [`apb-gads playbook shopping-feed-segmentation-audit`](playbook.md#apb-gads-playbook-shopping-feed-segmentation-audit) — Shopping feed + PMAX listing-group-filter coverage audit.
- [`apb-gads playbook targeting-coverage`](playbook.md#apb-gads-playbook-targeting-coverage) — Per-campaign targeting-dimension scorecard (geo/language/device/schedule/audience/demographic/placement/topic/brand/content_label) with missing-targeting flags for ENABLED campaigns.
- [`apb-gads playbook rsa-asset-performance`](playbook.md#apb-gads-playbook-rsa-asset-performance) — Per-ad headline/description performance labels (LOW/GOOD/BEST/PENDING) surfacing swap candidates.
- [`apb-gads playbook rsa-quality-audit`](playbook.md#apb-gads-playbook-rsa-quality-audit) — 7-point copy-quality review of every live RSA (8-angle diversity, near-duplicates, keyword coverage, CTA/trust, DKI linter, policy-content) scored alongside ad_strength + approval_status; emits informational rsa_refresh_candidates for orchestrate ad-refresh.
- [`apb-gads playbook experiment-readiness`](playbook.md#apb-gads-playbook-experiment-readiness) — Flag ENABLED campaigns with sufficient baseline (30d conversions + clicks) that aren't already in a Google Ads Experiment.
- [`apb-gads playbook policy-compliance`](playbook.md#apb-gads-playbook-policy-compliance) — Bucket ads by approval_status (DISAPPROVED, APPROVED_LIMITED, etc.) and surface policy_topic_entries for triage.
- [`apb-gads playbook smart-bidding-readiness`](playbook.md#apb-gads-playbook-smart-bidding-readiness) — Per-campaign 0-90 readiness score for moving from manual CPC to tCPA / tROAS / MAXIMIZE_CONVERSIONS.
- [`apb-gads playbook match-type-sculpting`](playbook.md#apb-gads-playbook-match-type-sculpting) — Recommend match-type upgrades (PHRASE→EXACT) or downgrades (BROAD→PHRASE) per keyword based on 90d conv-rate.
- [`apb-gads playbook expansion-readiness`](playbook.md#apb-gads-playbook-expansion-readiness) — Flag campaigns with sustained budget pressure (lost-IS > 10%) AND high ROAS as candidates for budget lift.
- [`apb-gads playbook quality-score-root-cause`](playbook.md#apb-gads-playbook-quality-score-root-cause) — Break low-QS keywords down by which component (expected CTR, ad relevance, landing-page experience) is BELOW_AVERAGE.
- [`apb-gads playbook search-term-promotion`](playbook.md#apb-gads-playbook-search-term-promotion) — Promote high-value search terms to keywords, filtered by metric thresholds (impressions/clicks/cost/conversions/conv-value/ROAS/CPA/top-N), enriched with intent-based match type, historical-CPC suggested bid, and a cluster label.
- [`apb-gads playbook competitor-pressure`](playbook.md#apb-gads-playbook-competitor-pressure) — Flag campaigns where search_rank_lost_impression_share rose ≥ 5pp in current vs prior 30d — proxy for rising auction pressure (domain-level auction insights require Standard API access).
- [`apb-gads playbook waste-cluster-audit`](playbook.md#apb-gads-playbook-waste-cluster-audit) — Token-stem clusters of zero-conversion search queries with combined spend ≥ $200 in the lookback window; emits a mutation-ready negative-keyword spec.
- [`apb-gads playbook keyword-prune-audit`](playbook.md#apb-gads-playbook-keyword-prune-audit) — Rank ENABLED keywords by metrics and flag prune candidates by $ (zero-conversion spend / absolute CPA ceiling), % (CPA/ROAS vs context target), and # (no-traffic click/impression floors); emits a mutation-ready keyword-remove spec.
- [`apb-gads playbook conversion-value-gap`](playbook.md#apb-gads-playbook-conversion-value-gap) — Flag conversion actions marked primary_for_goal in lead/form-fill categories that have no default_value or always_use_default_value=false (breaks Smart Bidding value math).
- [`apb-gads playbook campaign-cannibalization`](playbook.md#apb-gads-playbook-campaign-cannibalization) — Detect normalized queries served by ≥ 2 of our own active campaigns with material spend each, tiered LOW/MEDIUM/HIGH/CRITICAL by CPA gap and bid-strategy divergence.
- [`apb-gads playbook qs-cpc-tax`](playbook.md#apb-gads-playbook-qs-cpc-tax) — Quantify the CPC inflation paid for QS<5 keywords via counterfactual to a high-QS peer cohort (ad-group/match/network → campaign/match → account → heuristic fallback) with confidence labels.
- [`apb-gads playbook bid-strategy-mismatch`](playbook.md#apb-gads-playbook-bid-strategy-mismatch) — Detect campaigns whose current bid strategy is throttling scale (manual_cpc_with_strong_conversions, tcpa_budget_throttled, troas_without_value_tracking, etc.) with per-rule evidence blocks.
- [`apb-gads playbook audience-burnout-detection`](playbook.md#apb-gads-playbook-audience-burnout-detection) — Detect audience targets where engagement is decaying current-vs-prior 30d (CTR/CVR drop, CPA rise) across ad_group_audience_view.
- [`apb-gads playbook geo-bid-drift-audit`](playbook.md#apb-gads-playbook-geo-bid-drift-audit) — Detect geos (ZIP / state / DMA) where CPA has drifted materially current-vs-prior 30d on geographic_view; surfaces hidden spend pockets weighted by cost share.
- [`apb-gads playbook landing-page-intent-drift-audit`](playbook.md#apb-gads-playbook-landing-page-intent-drift-audit) — Surface landing pages where Google's landing_page_view quality signals degraded — mobile-friendliness, post_click_quality_score — and pair with the keywords pointing at them.
- [`apb-gads playbook pmax-segmentation-audit`](playbook.md#apb-gads-playbook-pmax-segmentation-audit) — Per-PMAX-campaign should-split / too-many-asset-groups recommendations based on spend, conversion volume, and asset-group count.
- [`apb-gads playbook brand-exclusion-audit`](playbook.md#apb-gads-playbook-brand-exclusion-audit) — Audit account-wide customer_negative_criterion coverage against competitor-brand patterns from `competitor-keyword-bleed`.
- [`apb-gads playbook campaign-consolidation-audit`](playbook.md#apb-gads-playbook-campaign-consolidation-audit) — Inverse of pmax-segmentation-audit: flag micro-campaigns (low spend, low conversion volume) sharing channel + bid-strategy that should be merged.
- [`apb-gads playbook sandbox-campaign-audit`](playbook.md#apb-gads-playbook-sandbox-campaign-audit) — Enforce small-bets hygiene: sandbox / experiment campaigns must not share budgets, must not use portfolio bidding, and must stay below the operator-set account-spend share.
- [`apb-gads playbook roas-nudge-recommendation`](playbook.md#apb-gads-playbook-roas-nudge-recommendation) — Per-campaign tROAS / tCPA micro-adjustment recommendations bounded by ±max_nudge_pct (default 10%) based on 14d actual-vs-target performance.
- [`apb-gads playbook conversion-value-tier-audit`](playbook.md#apb-gads-playbook-conversion-value-tier-audit) — Extends conversion-value-gap with value-quality scoring: placeholder-pattern, single-value-pattern, high-variance-pattern across conversion-action categories.
- [`apb-gads playbook placement-leakage-audit`](playbook.md#apb-gads-playbook-placement-leakage-audit) — Surface display + video placements (detail_placement_view) that consumed PMAX/DISPLAY/VIDEO budget with zero conversions.
- [`apb-gads playbook pmax-url-exclusion-audit`](playbook.md#apb-gads-playbook-pmax-url-exclusion-audit) — Substitute for v24-removed url_expansion_opt_out: per (PMAX/DISPLAY campaign, common-waste pattern) coverage check against campaign_criterion WEBPAGE negatives (/blog, /careers, /privacy, etc.).

### `plan`

- [`apb-gads plan keyword-ideas`](plan.md#apb-gads-plan-keyword-ideas) — Generate keyword ideas from seeds (keywords, URL, or site).
- [`apb-gads plan keyword-historical-metrics`](plan.md#apb-gads-plan-keyword-historical-metrics) — Historical metrics for a fixed keyword list.
- [`apb-gads plan from-audit`](plan.md#apb-gads-plan-from-audit) — Convert an audit/playbook spec envelope (written by `playbook ...
- [`apb-gads plan goals`](plan.md#apb-gads-plan-goals) — Emit goal configuration, recommended bid strategy, and budget feasibility heuristics for a given campaign mode.
- [`apb-gads plan keywords`](plan.md#apb-gads-plan-keywords) — Fetch keyword ideas then run the full generation pipeline: cluster → intent classify → match-type recommend → seed negatives.
- [`apb-gads plan structure`](plan.md#apb-gads-plan-structure) — Build a campaign skeleton from a keywords-plan JSON file.
- [`apb-gads plan rsa`](plan.md#apb-gads-plan-rsa) — Generate RSA headline/description candidates per ad group from a campaign-structure JSON file
- [`apb-gads plan tracking`](plan.md#apb-gads-plan-tracking) — Emit a static conversion-tracking setup template for the given mode.
- [`apb-gads plan campaign search`](plan.md#apb-gads-plan-campaign-search) — Assemble a launchable multi-ad-group CampaignLaunchSpec (bare JSON) from `plan structure` + `plan rsa` (+ optional goals/keywords).
- [`apb-gads plan campaign full`](plan.md#apb-gads-plan-campaign-full) — Run the whole greenfield pipeline (keyword research → structure → rsa → goals → tracking → one launch spec per campaign + summary.md) into --export-dir.
- [`apb-gads plan campaign pmax`](plan.md#apb-gads-plan-campaign-pmax) — Assemble a launchable PmaxLaunchPlanSpec (bare JSON) for a single-asset-group Performance Max campaign (phase 1).

### `sandbox`

- [`apb-gads sandbox helper full-flow`](sandbox.md#apb-gads-sandbox-helper-full-flow)

### `orchestrate`

- [`apb-gads orchestrate ad-rotate`](orchestrate.md#apb-gads-orchestrate-ad-rotate) — Rotate ads within an ad group: pause a list of ads and/or enable a list of ads in a single atomic mutate batch
- [`apb-gads orchestrate ad-refresh`](orchestrate.md#apb-gads-orchestrate-ad-refresh) — Refresh a fatigued RSA: create a NEW responsive search ad in the ad group and optionally pause an old one (create-new + pause-old — editing in place resets policy review and breaks history).
- [`apb-gads orchestrate campaign-launch`](orchestrate.md#apb-gads-orchestrate-campaign-launch) — End-to-end campaign launch from a JSON spec file: budget → campaign → ad group → RSA → keywords.
- [`apb-gads orchestrate pmax-build`](orchestrate.md#apb-gads-orchestrate-pmax-build) — Atomic Performance Max build (phase 1): a single-asset-group PMAX campaign created in ONE googleAds:mutate — budget → campaign (bidding at create) → geo/language/campaign-negatives → assets → asset group → links.
- [`apb-gads orchestrate weekly-optimization`](orchestrate.md#apb-gads-orchestrate-weekly-optimization) — Weekly-optimization readout: composes search-term-cleanup + expansion-readiness + impression-share-loss into a single advisory document.
- [`apb-gads orchestrate monthly-review`](orchestrate.md#apb-gads-orchestrate-monthly-review) — Monthly-review readout: composes account-health + waste-audit + creative-refresh + budget-pacing + quality-score-audit into a bundled 30-day view.
- [`apb-gads orchestrate rollback`](orchestrate.md#apb-gads-orchestrate-rollback) — Rollback: accept a list of resource names and submit a single atomic remove batch.

### `audit`

- [`apb-gads audit list`](audit.md#apb-gads-audit-list) — List audit log entries (JSONL at ~/.apb-gads/audit.jsonl by default)
- [`apb-gads audit get`](audit.md#apb-gads-audit-get) — Get a single audit entry in full by its index (0-based line number)
- [`apb-gads audit replay`](audit.md#apb-gads-audit-replay) — Replay a captured audit entry's operations.

### `schedule`

- [`apb-gads schedule list`](schedule.md#apb-gads-schedule-list) — List all registered jobs
- [`apb-gads schedule add`](schedule.md#apb-gads-schedule-add) — Register a new job.
- [`apb-gads schedule remove`](schedule.md#apb-gads-schedule-remove) — Remove a job from the store
- [`apb-gads schedule show`](schedule.md#apb-gads-schedule-show) — Show one job in full
- [`apb-gads schedule install`](schedule.md#apb-gads-schedule-install) — Render the managed crontab section.
- [`apb-gads schedule uninstall`](schedule.md#apb-gads-schedule-uninstall) — Remove the managed section from the user's crontab
- [`apb-gads schedule run`](schedule.md#apb-gads-schedule-run) — Run a job now (shells out to the same apb-gads binary with the stored args).

### `verify`

- [`apb-gads verify preflight`](verify.md#apb-gads-verify-preflight) — Report the live-verify policy shape for the target customer.
- [`apb-gads verify noop`](verify.md#apb-gads-verify-noop) — W2 scaffold probe: exercises the verification state machine end-to-end (lock → manifest → stages → ledger) without touching the Google Ads API.
- [`apb-gads verify smoke`](verify.md#apb-gads-verify-smoke) — W2 server-side gate: submit a synthetic Example-shaped campaign-budget create payload to Google with `validateOnly=true`.
- [`apb-gads verify search-lifecycle`](verify.md#apb-gads-verify-search-lifecycle) — W3 Chain 1: full search-campaign lifecycle.
- [`apb-gads verify pmax-launch`](verify.md#apb-gads-verify-pmax-launch) — W4 Chain 2: full PMAX launch (Path 3 — production-asset reuse).
- [`apb-gads verify rsa-lifecycle`](verify.md#apb-gads-verify-rsa-lifecycle) — P5 Chain 3: full RSA create + refresh lifecycle.
- [`apb-gads verify bootstrap-pmax-assets`](verify.md#apb-gads-verify-bootstrap-pmax-assets) — Sprint W5 Phase 5/6: bootstrap standalone PMAX assets on a non-Example account so its LiveVerifyPolicy.pmax_asset_config can be populated and `verify pmax-launch` can run end-to-end.
- [`apb-gads verify list`](verify.md#apb-gads-verify-list) — List recent verification runs from the append-only ledger
- [`apb-gads verify cleanup`](verify.md#apb-gads-verify-cleanup) — List pending cleanup entries from prior crashed or partial runs.

### `changes`

- [`apb-gads changes from-plan`](changes.md#apb-gads-changes-from-plan) — Convert a scored ActionPlan JSON into a Changeset of raw v24 mutate ops.
- [`apb-gads changes apply`](changes.md#apb-gads-changes-apply) — Apply a Changeset.
- [`apb-gads changes rollback`](changes.md#apb-gads-changes-rollback) — Generate + apply the inverse of a previously-applied changeset, looked up by audit-log id (reuses `mutate inverse-plan`).

### `growth`

- [`apb-gads growth weekly-review`](growth.md#apb-gads-growth-weekly-review) — Dual-window weekly performance review (current N days vs prior N days).
- [`apb-gads growth monthly-review`](growth.md#apb-gads-growth-monthly-review) — Dual-window monthly performance review (current N days vs prior N days) with budget reallocation and next-month roadmap.
- [`apb-gads growth monitor`](growth.md#apb-gads-growth-monitor) — Evaluate guardrail rules from a YAML rules file against live account data.
- [`apb-gads growth scale-up`](growth.md#apb-gads-growth-scale-up) — Growth-first scale-up readout: where you have efficient headroom to GROW — budget-limited winners, rank-limited campaigns, expansion-ready, search terms to promote, and ROAS headroom — ranked by upside, never by cuts.
- [`apb-gads growth consolidation`](growth.md#apb-gads-growth-consolidation) — Consolidation/structure readout aligned to the "consolidate + broad match + Smart Bidding" doctrine: where over-fragmentation starves Smart Bidding of signal, and how consolidating unlocks scale.

### `export`

- [`apb-gads export render`](export.md#apb-gads-export-render) — Render an artifact JSON file to CSV, JSON, or Markdown

### `context`

- [`apb-gads context init`](context.md#apb-gads-context-init) — Initialize or overwrite the per-customer context file
- [`apb-gads context show`](context.md#apb-gads-context-show) — Show the current context for a customer.

### `validate`

- [`apb-gads validate campaign-spec`](validate.md#apb-gads-validate-campaign-spec) — Validate a CampaignLaunchSpec (from `plan campaign search`) for launch readiness: budget/geo/language/bidding present, every ad group has keywords + a valid RSA (counts, char limits, dupes), match types valid, negatives recommended.
- [`apb-gads validate pmax-spec`](validate.md#apb-gads-validate-pmax-spec) — Validate a PmaxLaunchPlanSpec (from `plan campaign pmax`) for launch readiness: budget/final_url/geo/language present, PMAX-valid bidding, asset-group content (headline/description counts + lengths, required BUSINESS_NAME + marketing/square images), brand-guidelines + path rules, negatives recommended.
