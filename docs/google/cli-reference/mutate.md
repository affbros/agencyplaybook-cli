# `apb-gads mutate`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Every write surface. Dry-run by default; gated behind the three-gate safety model.

**Surface:** ✍️ **Write-capable** · **116 command(s)** · [← back to index](README.md)

> ⚠️ Commands here can write to a Google Ads account. Every write is **dry-run by default** and must clear the three independent gates (`--execute` + config + env) plus a per-customer profile or the test sandbox policy. See [`../mutations.md`](../mutations.md).

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`apply-plan`](#apb-gads-mutate-apply-plan) | Sprint D — re-apply a plan JSON (from --save-plan) to the API. |
| [`inverse-plan`](#apb-gads-mutate-inverse-plan) | Sprint D — generate a compensating (inverse) plan from an audit log entry. |
| [`campaign-budget-create`](#apb-gads-mutate-campaign-budget-create) |  |
| [`negative-keyword-add`](#apb-gads-mutate-negative-keyword-add) |  |
| [`negative-keyword-add-bulk`](#apb-gads-mutate-negative-keyword-add-bulk) |  |
| [`campaign-negative-keyword-add`](#apb-gads-mutate-campaign-negative-keyword-add) |  |
| [`campaign-negative-keyword-add-bulk`](#apb-gads-mutate-campaign-negative-keyword-add-bulk) |  |
| [`campaign-negative-webpage-add-bulk`](#apb-gads-mutate-campaign-negative-webpage-add-bulk) | Sprint B.3: bulk WEBPAGE negative criterion adds on N campaigns (consumer for `pmax-url-exclusion-audit`). |
| [`keyword-add-bulk`](#apb-gads-mutate-keyword-add-bulk) |  |
| [`criterion-remove-bulk`](#apb-gads-mutate-criterion-remove-bulk) |  |
| [`campaign-update-status-bulk`](#apb-gads-mutate-campaign-update-status-bulk) |  |
| [`ad-create-bulk`](#apb-gads-mutate-ad-create-bulk) |  |
| [`campaign-budget-update-bulk`](#apb-gads-mutate-campaign-budget-update-bulk) |  |
| [`campaign-update-bidding-strategy-bulk`](#apb-gads-mutate-campaign-update-bidding-strategy-bulk) |  |
| [`ad-update-status-bulk`](#apb-gads-mutate-ad-update-status-bulk) |  |
| [`keyword-update-match-type-bulk`](#apb-gads-mutate-keyword-update-match-type-bulk) |  |
| [`keyword-bid-set-bulk`](#apb-gads-mutate-keyword-bid-set-bulk) |  |
| [`keyword-update-match-type`](#apb-gads-mutate-keyword-update-match-type) |  |
| [`ad-update-status`](#apb-gads-mutate-ad-update-status) |  |
| [`ad-group-criterion-update`](#apb-gads-mutate-ad-group-criterion-update) |  |
| [`budget-transfer`](#apb-gads-mutate-budget-transfer) |  |
| [`conversion-action-update`](#apb-gads-mutate-conversion-action-update) |  |
| [`conversion-action-update-value`](#apb-gads-mutate-conversion-action-update-value) | Update `value_settings.default_value` (and optionally `value_settings.always_use_default_value`) on an existing conversion action. |
| [`customer-negative-criterion-add`](#apb-gads-mutate-customer-negative-criterion-add) |  |
| [`customer-negative-criterion-remove`](#apb-gads-mutate-customer-negative-criterion-remove) |  |
| [`customer-negative-criterion-add-bulk`](#apb-gads-mutate-customer-negative-criterion-add-bulk) | Sprint B.2: bulk variant of `customer-negative-criterion-add` for the KEYWORD path. |
| [`user-list-create`](#apb-gads-mutate-user-list-create) |  |
| [`audience-create`](#apb-gads-mutate-audience-create) | Create an Audience resource (in-market/affinity/user-list/custom + demographics). |
| [`pmax-listing-group-filter-create`](#apb-gads-mutate-pmax-listing-group-filter-create) |  |
| [`pmax-listing-group-filter-remove`](#apb-gads-mutate-pmax-listing-group-filter-remove) |  |
| [`asset-create-youtube-video`](#apb-gads-mutate-asset-create-youtube-video) |  |
| [`asset-create-image`](#apb-gads-mutate-asset-create-image) |  |
| [`campaign-update-status`](#apb-gads-mutate-campaign-update-status) |  |
| [`ad-create`](#apb-gads-mutate-ad-create) |  |
| [`campaign-create`](#apb-gads-mutate-campaign-create) |  |
| [`ad-group-create`](#apb-gads-mutate-ad-group-create) |  |
| [`keyword-add`](#apb-gads-mutate-keyword-add) |  |
| [`keyword-bid-set`](#apb-gads-mutate-keyword-bid-set) |  |
| [`campaign-budget-update`](#apb-gads-mutate-campaign-budget-update) |  |
| [`criterion-remove`](#apb-gads-mutate-criterion-remove) |  |
| [`ad-remove`](#apb-gads-mutate-ad-remove) |  |
| [`ad-group-remove`](#apb-gads-mutate-ad-group-remove) |  |
| [`campaign-remove`](#apb-gads-mutate-campaign-remove) |  |
| [`campaign-budget-remove`](#apb-gads-mutate-campaign-budget-remove) |  |
| [`pmax-campaign-create`](#apb-gads-mutate-pmax-campaign-create) |  |
| [`pmax-asset-group-create`](#apb-gads-mutate-pmax-asset-group-create) |  |
| [`pmax-asset-group-remove`](#apb-gads-mutate-pmax-asset-group-remove) |  |
| [`pmax-asset-attach`](#apb-gads-mutate-pmax-asset-attach) |  |
| [`pmax-asset-detach`](#apb-gads-mutate-pmax-asset-detach) |  |
| [`pmax-launch`](#apb-gads-mutate-pmax-launch) |  |
| [`ad-validate`](#apb-gads-mutate-ad-validate) |  |
| [`campaign-geo-add`](#apb-gads-mutate-campaign-geo-add) |  |
| [`campaign-language-add`](#apb-gads-mutate-campaign-language-add) |  |
| [`campaign-device-modifier-set`](#apb-gads-mutate-campaign-device-modifier-set) |  |
| [`campaign-ad-schedule-add`](#apb-gads-mutate-campaign-ad-schedule-add) |  |
| [`campaign-audience-add`](#apb-gads-mutate-campaign-audience-add) |  |
| [`campaign-demographic-exclude`](#apb-gads-mutate-campaign-demographic-exclude) |  |
| [`campaign-ipblock-add`](#apb-gads-mutate-campaign-ipblock-add) |  |
| [`campaign-demographic-add`](#apb-gads-mutate-campaign-demographic-add) |  |
| [`campaign-proximity-add`](#apb-gads-mutate-campaign-proximity-add) |  |
| [`campaign-content-label-exclude`](#apb-gads-mutate-campaign-content-label-exclude) |  |
| [`campaign-placement-exclude`](#apb-gads-mutate-campaign-placement-exclude) |  |
| [`campaign-topic-exclude`](#apb-gads-mutate-campaign-topic-exclude) |  |
| [`campaign-youtube-video-exclude`](#apb-gads-mutate-campaign-youtube-video-exclude) |  |
| [`campaign-youtube-channel-exclude`](#apb-gads-mutate-campaign-youtube-channel-exclude) |  |
| [`campaign-mobile-app-exclude`](#apb-gads-mutate-campaign-mobile-app-exclude) |  |
| [`campaign-criterion-remove`](#apb-gads-mutate-campaign-criterion-remove) |  |
| [`campaign-update-bidding-strategy`](#apb-gads-mutate-campaign-update-bidding-strategy) |  |
| [`campaign-update-dates`](#apb-gads-mutate-campaign-update-dates) |  |
| [`campaign-update-network-settings`](#apb-gads-mutate-campaign-update-network-settings) |  |
| [`campaign-update-frequency-cap`](#apb-gads-mutate-campaign-update-frequency-cap) |  |
| [`pmax-audience-signal-attach`](#apb-gads-mutate-pmax-audience-signal-attach) |  |
| [`pmax-audience-signal-detach`](#apb-gads-mutate-pmax-audience-signal-detach) |  |
| [`shared-set-create`](#apb-gads-mutate-shared-set-create) |  |
| [`shared-criterion-add`](#apb-gads-mutate-shared-criterion-add) |  |
| [`campaign-shared-set-attach`](#apb-gads-mutate-campaign-shared-set-attach) |  |
| [`campaign-brand-list-exclude`](#apb-gads-mutate-campaign-brand-list-exclude) | Exclude a BRANDS shared set (brand list) from a campaign as a NEGATIVE brand-list criterion — competitor-brand exclusion (PMAX & gated channels allow brand lists only negatively). |
| [`conversion-action-create`](#apb-gads-mutate-conversion-action-create) |  |
| [`shared-criterion-remove`](#apb-gads-mutate-shared-criterion-remove) |  |
| [`campaign-shared-set-detach`](#apb-gads-mutate-campaign-shared-set-detach) |  |
| [`shared-set-remove`](#apb-gads-mutate-shared-set-remove) |  |
| [`campaign-update-tracking-url`](#apb-gads-mutate-campaign-update-tracking-url) |  |
| [`ad-create-video-responsive`](#apb-gads-mutate-ad-create-video-responsive) | Create a VideoResponsiveAd (v24). |
| [`ad-update-video-responsive`](#apb-gads-mutate-ad-update-video-responsive) | Partial update of a VideoResponsiveAd (v24 made VideoResponsiveAdInfo mutable). |
| [`ad-create-demandgen-video-responsive`](#apb-gads-mutate-ad-create-demandgen-video-responsive) | Create a DemandGenVideoResponsiveAd (v24). |
| [`customer-update-video-brand-safety`](#apb-gads-mutate-customer-update-video-brand-safety) | Set customer-level video brand safety (v24). |
| [`campaign-update-vtc-optimization`](#apb-gads-mutate-campaign-update-vtc-optimization) | Toggle view-through conversion optimization on a campaign. |
| [`campaign-update-target-impression-share`](#apb-gads-mutate-campaign-update-target-impression-share) |  |
| [`campaign-update-customer-acquisition`](#apb-gads-mutate-campaign-update-customer-acquisition) |  |
| [`campaign-update-geo-target-type`](#apb-gads-mutate-campaign-update-geo-target-type) |  |
| [`campaign-update-ad-rotation`](#apb-gads-mutate-campaign-update-ad-rotation) |  |
| [`campaign-update-url-expansion-opt-out`](#apb-gads-mutate-campaign-update-url-expansion-opt-out) | Opt a campaign out of (or back into) final-URL-expansion text-asset automation — the v24 lever (campaign.asset_automation_settings, FINAL_URL_EXPANSION_TEXT_ASSET_AUTOMATION) that replaced the removed `url_expansion_opt_out` boolean. |
| [`bidding-strategy-create`](#apb-gads-mutate-bidding-strategy-create) |  |
| [`bidding-strategy-remove`](#apb-gads-mutate-bidding-strategy-remove) | Remove a portfolio (shared) bidding strategy. |
| [`campaign-attach-portfolio-bidding`](#apb-gads-mutate-campaign-attach-portfolio-bidding) |  |
| [`bidding-seasonality-adjustment-create`](#apb-gads-mutate-bidding-seasonality-adjustment-create) |  |
| [`bidding-data-exclusion-create`](#apb-gads-mutate-bidding-data-exclusion-create) |  |
| [`conversion-value-rule-create`](#apb-gads-mutate-conversion-value-rule-create) | Create a conversion value rule (account-level): adjust the conversion VALUE Smart Bidding optimizes toward, by geo/device/audience — the modern replacement for geo/device/audience bid adjustments under value-based bidding (Max Conv Value / Target ROAS). |
| [`campaign-conversion-goal-set`](#apb-gads-mutate-campaign-conversion-goal-set) |  |
| [`ad-group-audience-add`](#apb-gads-mutate-ad-group-audience-add) |  |
| [`ad-group-demographic-add`](#apb-gads-mutate-ad-group-demographic-add) |  |
| [`ad-group-placement-add`](#apb-gads-mutate-ad-group-placement-add) |  |
| [`asset-create-sitelink`](#apb-gads-mutate-asset-create-sitelink) |  |
| [`asset-create-callout`](#apb-gads-mutate-asset-create-callout) |  |
| [`asset-create-structured-snippet`](#apb-gads-mutate-asset-create-structured-snippet) |  |
| [`asset-create-promotion`](#apb-gads-mutate-asset-create-promotion) |  |
| [`asset-create-call`](#apb-gads-mutate-asset-create-call) |  |
| [`asset-create-price`](#apb-gads-mutate-asset-create-price) |  |
| [`campaign-asset-attach`](#apb-gads-mutate-campaign-asset-attach) |  |
| [`campaign-asset-detach`](#apb-gads-mutate-campaign-asset-detach) |  |
| [`ad-group-asset-attach`](#apb-gads-mutate-ad-group-asset-attach) |  |
| [`ad-group-asset-detach`](#apb-gads-mutate-ad-group-asset-detach) |  |
| [`customer-asset-attach`](#apb-gads-mutate-customer-asset-attach) |  |
| [`customer-asset-detach`](#apb-gads-mutate-customer-asset-detach) |  |
| [`experiment-create`](#apb-gads-mutate-experiment-create) |  |
| [`experiment-end`](#apb-gads-mutate-experiment-end) |  |

---

<a id="apb-gads-mutate-apply-plan"></a>
### `apb-gads mutate apply-plan`

Sprint D — re-apply a plan JSON (from --save-plan) to the API. Dry-run by default; --execute required to submit

**Usage**

```
Usage: apb-gads mutate apply-plan [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | — |

<a id="apb-gads-mutate-inverse-plan"></a>
### `apb-gads mutate inverse-plan`

Sprint D — generate a compensating (inverse) plan from an audit log entry. Read-only: does not submit. Use --save-plan to write the inverse to disk for review + later apply-plan --execute. Requires audit schema v2 (Sprint D+)

**Usage**

```
Usage: apb-gads mutate inverse-plan [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--audit-id <AUDIT_ID>` | Audit entry index (use `audit list` to find). Mutually exclusive with --from-audit-file |
| `--from-audit-file <FROM_AUDIT_FILE>` | Alternative: read audit entry from a JSON file instead of the configured audit log |

<a id="apb-gads-mutate-campaign-budget-create"></a>
### `apb-gads mutate campaign-budget-create`

**Usage**

```
Usage: apb-gads mutate campaign-budget-create [OPTIONS] --name <NAME> --amount-micros <AMOUNT_MICROS>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--name <NAME>` | — |
| `--amount-micros <AMOUNT_MICROS>` | — |
| `--shared` | Create as an explicitly-shared budget (attachable to multiple campaigns) |

<a id="apb-gads-mutate-negative-keyword-add"></a>
### `apb-gads mutate negative-keyword-add`

**Usage**

```
Usage: apb-gads mutate negative-keyword-add [OPTIONS] --ad-group-id <AD_GROUP_ID> --text <TEXT>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | — |
| `--text <TEXT>` | — |
| `--match-type <MATCH_TYPE>` | [default: EXACT] |

<a id="apb-gads-mutate-negative-keyword-add-bulk"></a>
### `apb-gads mutate negative-keyword-add-bulk`

**Usage**

```
Usage: apb-gads mutate negative-keyword-add-bulk [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to JSON with either {items:[...]} or search-term-cleanup output {candidate_actions:[...]} |

<a id="apb-gads-mutate-campaign-negative-keyword-add"></a>
### `apb-gads mutate campaign-negative-keyword-add`

**Usage**

```
Usage: apb-gads mutate campaign-negative-keyword-add [OPTIONS] --campaign-id <CAMPAIGN_ID> --text <TEXT>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--text <TEXT>` | — |
| `--match-type <MATCH_TYPE>` | [default: EXACT] |

<a id="apb-gads-mutate-campaign-negative-keyword-add-bulk"></a>
### `apb-gads mutate campaign-negative-keyword-add-bulk`

**Usage**

```
Usage: apb-gads mutate campaign-negative-keyword-add-bulk [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to JSON: {items:[{campaign_id, text, match_type}, ...]} |

<a id="apb-gads-mutate-campaign-negative-webpage-add-bulk"></a>
### `apb-gads mutate campaign-negative-webpage-add-bulk`

Sprint B.3: bulk WEBPAGE negative criterion adds on N campaigns (consumer for `pmax-url-exclusion-audit`). v24 routes webpage exclusions through `campaign_criterion` with type=WEBPAGE + negative=true — per-campaign, not customer-wide (the v24 path `customer_negative_criterion.webpage.*` does not exist). JSON shape: {items:[{campaign_id, criterion_name, conditions: [{operand: URL|CATEGORY|PAGE_TITLE|PAGE_CONTENT|CUSTOM_LABEL, operator: EQUALS|CONTAINS, argument: <string>}, ...] }, ...]}. Conditions on the same item AND together

**Usage**

```
Usage: apb-gads mutate campaign-negative-webpage-add-bulk [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to JSON: {items:[{campaign_id, criterion_name, conditions:[{operand, operator, argument}]}, ...]} |

<a id="apb-gads-mutate-keyword-add-bulk"></a>
### `apb-gads mutate keyword-add-bulk`

**Usage**

```
Usage: apb-gads mutate keyword-add-bulk [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to JSON: {items:[{ad_group_id, text, match_type}, ...]} |

<a id="apb-gads-mutate-criterion-remove-bulk"></a>
### `apb-gads mutate criterion-remove-bulk`

**Usage**

```
Usage: apb-gads mutate criterion-remove-bulk [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to JSON: {items:[{ad_group_id, criterion_id}, ...]} |

<a id="apb-gads-mutate-campaign-update-status-bulk"></a>
### `apb-gads mutate campaign-update-status-bulk`

**Usage**

```
Usage: apb-gads mutate campaign-update-status-bulk [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to JSON: {items:[{campaign_id, status}, ...]} |

<a id="apb-gads-mutate-ad-create-bulk"></a>
### `apb-gads mutate ad-create-bulk`

**Usage**

```
Usage: apb-gads mutate ad-create-bulk [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to JSON: {items:[{ad_group_id, headlines:[...], descriptions:[...], final_urls:[...]}, ...]} |

<a id="apb-gads-mutate-campaign-budget-update-bulk"></a>
### `apb-gads mutate campaign-budget-update-bulk`

**Usage**

```
Usage: apb-gads mutate campaign-budget-update-bulk [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to JSON: {items:[{budget_resource_name, amount_micros}, ...]} |

<a id="apb-gads-mutate-campaign-update-bidding-strategy-bulk"></a>
### `apb-gads mutate campaign-update-bidding-strategy-bulk`

**Usage**

```
Usage: apb-gads mutate campaign-update-bidding-strategy-bulk [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to JSON: {items:[{campaign_id, bidding_strategy_type, target_cpa_micros?, target_roas?}, ...]} |

<a id="apb-gads-mutate-ad-update-status-bulk"></a>
### `apb-gads mutate ad-update-status-bulk`

**Usage**

```
Usage: apb-gads mutate ad-update-status-bulk [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to JSON: {items:[{ad_group_id, ad_id, status}, ...]} |

<a id="apb-gads-mutate-keyword-update-match-type-bulk"></a>
### `apb-gads mutate keyword-update-match-type-bulk`

**Usage**

```
Usage: apb-gads mutate keyword-update-match-type-bulk [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to JSON: {items:[{ad_group_id, criterion_id, keyword_text, new_match_type, cpc_bid_micros?}, ...]} |

<a id="apb-gads-mutate-keyword-bid-set-bulk"></a>
### `apb-gads mutate keyword-bid-set-bulk`

**Usage**

```
Usage: apb-gads mutate keyword-bid-set-bulk [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to JSON: {items:[{ad_group_id, criterion_id, cpc_bid_micros}, ...]} |

<a id="apb-gads-mutate-keyword-update-match-type"></a>
### `apb-gads mutate keyword-update-match-type`

**Usage**

```
Usage: apb-gads mutate keyword-update-match-type [OPTIONS] --ad-group-id <AD_GROUP_ID> --criterion-id <CRITERION_ID> --keyword-text <KEYWORD_TEXT> --new-match-type <NEW_MATCH_TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | — |
| `--criterion-id <CRITERION_ID>` | — |
| `--keyword-text <KEYWORD_TEXT>` | — |
| `--new-match-type <NEW_MATCH_TYPE>` | BROAD \| PHRASE \| EXACT |
| `--cpc-bid-micros <CPC_BID_MICROS>` | — |

<a id="apb-gads-mutate-ad-update-status"></a>
### `apb-gads mutate ad-update-status`

**Usage**

```
Usage: apb-gads mutate ad-update-status [OPTIONS] --ad-group-id <AD_GROUP_ID> --ad-id <AD_ID> --status <STATUS>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | — |
| `--ad-id <AD_ID>` | — |
| `--status <STATUS>` | ENABLED \| PAUSED \| REMOVED |

<a id="apb-gads-mutate-ad-group-criterion-update"></a>
### `apb-gads mutate ad-group-criterion-update`

**Usage**

```
Usage: apb-gads mutate ad-group-criterion-update [OPTIONS] --ad-group-id <AD_GROUP_ID> --criterion-id <CRITERION_ID> --status <STATUS>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | — |
| `--criterion-id <CRITERION_ID>` | — |
| `--status <STATUS>` | ENABLED \| PAUSED \| REMOVED |

<a id="apb-gads-mutate-budget-transfer"></a>
### `apb-gads mutate budget-transfer`

**Usage**

```
Usage: apb-gads mutate budget-transfer [OPTIONS] --from-budget-resource-name <FROM_BUDGET_RESOURCE_NAME> --to-budget-resource-name <TO_BUDGET_RESOURCE_NAME> --amount-micros <AMOUNT_MICROS> --from-new-amount-micros <FROM_NEW_AMOUNT_MICROS> --to-new-amount-micros <TO_NEW_AMOUNT_MICROS>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-budget-resource-name <FROM_BUDGET_RESOURCE_NAME>` | — |
| `--to-budget-resource-name <TO_BUDGET_RESOURCE_NAME>` | — |
| `--amount-micros <AMOUNT_MICROS>` | — |
| `--from-new-amount-micros <FROM_NEW_AMOUNT_MICROS>` | Post-transfer amount for the source budget |
| `--to-new-amount-micros <TO_NEW_AMOUNT_MICROS>` | Post-transfer amount for the destination budget |

<a id="apb-gads-mutate-conversion-action-update"></a>
### `apb-gads mutate conversion-action-update`

**Usage**

```
Usage: apb-gads mutate conversion-action-update [OPTIONS] --conversion-action-id <CONVERSION_ACTION_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--conversion-action-id <CONVERSION_ACTION_ID>` | — |
| `--primary-for-goal` | — |

<a id="apb-gads-mutate-conversion-action-update-value"></a>
### `apb-gads mutate conversion-action-update-value`

Update `value_settings.default_value` (and optionally `value_settings.always_use_default_value`) on an existing conversion action. Auto-fix path for the `$0 default value` gateway bug surfaced by `conversion-value-gap` / `conversion-tracking-audit`

**Usage**

```
Usage: apb-gads mutate conversion-action-update-value [OPTIONS] --conversion-action-id <CONVERSION_ACTION_ID> --default-value <DEFAULT_VALUE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--conversion-action-id <CONVERSION_ACTION_ID>` | — |
| `--default-value <DEFAULT_VALUE>` | Non-negative float — the new default conversion value |
| `--always-use-default-value <ALWAYS_USE_DEFAULT_VALUE>` | Optional: when present, updates the `always_use_default_value` flag in the same mutate. Omit to leave the flag unchanged [possible values: true, false] |

<a id="apb-gads-mutate-customer-negative-criterion-add"></a>
### `apb-gads mutate customer-negative-criterion-add`

**Usage**

```
Usage: apb-gads mutate customer-negative-criterion-add [OPTIONS] --criterion-type <CRITERION_TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--criterion-type <CRITERION_TYPE>` | KEYWORD \| PLACEMENT |
| `--text <TEXT>` | — |
| `--match-type <MATCH_TYPE>` | BROAD \| PHRASE \| EXACT (KEYWORD only) |
| `--url <URL>` | — |

<a id="apb-gads-mutate-customer-negative-criterion-remove"></a>
### `apb-gads mutate customer-negative-criterion-remove`

**Usage**

```
Usage: apb-gads mutate customer-negative-criterion-remove [OPTIONS] --criterion-id <CRITERION_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--criterion-id <CRITERION_ID>` | — |

<a id="apb-gads-mutate-customer-negative-criterion-add-bulk"></a>
### `apb-gads mutate customer-negative-criterion-add-bulk`

Sprint B.2: bulk variant of `customer-negative-criterion-add` for the KEYWORD path. Reads `{items:[{text, match_type}, ...]}` from a JSON file. Routes through the v24 shared_set + customer_negative_criterion + N×shared_criterion chain (1-3 mutates depending on state). All N shared_criterion entries succeed or fail atomically in the final call. Consumer for `brand-exclusion-audit`'s mutation-ready output

**Usage**

```
Usage: apb-gads mutate customer-negative-criterion-add-bulk [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to JSON: {items:[{text, match_type}, ...]} |

<a id="apb-gads-mutate-user-list-create"></a>
### `apb-gads mutate user-list-create`

**Usage**

```
Usage: apb-gads mutate user-list-create [OPTIONS] --name <NAME>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--name <NAME>` | — |
| `--description <DESCRIPTION>` | — |
| `--membership-life-span-days <MEMBERSHIP_LIFE_SPAN_DAYS>` | [default: 540] |
| `--rule-url-contains <RULE_URL_CONTAINS>` | URL path fragment for rule-based list membership |

<a id="apb-gads-mutate-audience-create"></a>
### `apb-gads mutate audience-create`

Create an Audience resource (in-market/affinity/user-list/custom + demographics). The id seeds a PMAX AUDIENCE signal via `pmax-audience-signal-attach --signal-type AUDIENCE --audience-id`

**Usage**

```
Usage: apb-gads mutate audience-create [OPTIONS] --name <NAME>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--name <NAME>` | — |
| `--description <DESCRIPTION>` | — |
| `--asset-group-id <ASSET_GROUP_ID>` | If set → ASSET_GROUP scope bound to this group; else CUSTOMER scope (reusable) |
| `--user-interest-id <USER_INTEREST_ID>` | In-market/affinity user_interest category id (repeatable). Find via: gaql user_interest |
| `--user-list-id <USER_LIST_ID>` | user_list id to include as a segment (repeatable) |
| `--custom-audience-id <CUSTOM_AUDIENCE_ID>` | custom_audience id to include as a segment (repeatable) |
| `--age-range <AGE_RANGE>` | AGE_RANGE_18_24 \| _25_34 \| _35_44 \| _45_54 \| _55_64 \| _65_UP \| _UNDETERMINED (repeatable) |
| `--gender <GENDER>` | MALE \| FEMALE \| UNDETERMINED (repeatable) |
| `--parental-status <PARENTAL_STATUS>` | PARENT \| NOT_A_PARENT \| UNDETERMINED (repeatable) |

<a id="apb-gads-mutate-pmax-listing-group-filter-create"></a>
### `apb-gads mutate pmax-listing-group-filter-create`

**Usage**

```
Usage: apb-gads mutate pmax-listing-group-filter-create [OPTIONS] --asset-group-id <ASSET_GROUP_ID> --filter-type <FILTER_TYPE> --dimension-type <DIMENSION_TYPE> --dimension-value <DIMENSION_VALUE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--asset-group-id <ASSET_GROUP_ID>` | — |
| `--filter-type <FILTER_TYPE>` | UNIT_INCLUDED \| UNIT_EXCLUDED \| SUBDIVISION |
| `--dimension-type <DIMENSION_TYPE>` | PRODUCT_BRAND \| PRODUCT_CATEGORY \| PRODUCT_CONDITION \| PRODUCT_CUSTOM_ATTRIBUTE |
| `--dimension-value <DIMENSION_VALUE>` | — |
| `--parent-filter-resource-name <PARENT_FILTER_RESOURCE_NAME>` | — |

<a id="apb-gads-mutate-pmax-listing-group-filter-remove"></a>
### `apb-gads mutate pmax-listing-group-filter-remove`

**Usage**

```
Usage: apb-gads mutate pmax-listing-group-filter-remove [OPTIONS] --asset-group-id <ASSET_GROUP_ID> --filter-id <FILTER_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--asset-group-id <ASSET_GROUP_ID>` | — |
| `--filter-id <FILTER_ID>` | — |

<a id="apb-gads-mutate-asset-create-youtube-video"></a>
### `apb-gads mutate asset-create-youtube-video`

**Usage**

```
Usage: apb-gads mutate asset-create-youtube-video [OPTIONS] --video-id <VIDEO_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--video-id <VIDEO_ID>` | 11-character YouTube video ID |
| `--name <NAME>` | — |

<a id="apb-gads-mutate-asset-create-image"></a>
### `apb-gads mutate asset-create-image`

**Usage**

```
Usage: apb-gads mutate asset-create-image [OPTIONS] --file <FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--file <FILE>` | Path to image file (PNG/JPEG/GIF). Must be ≤ 5,120 KB. |
| `--name <NAME>` | — |
| `--field-type <FIELD_TYPE>` | MARKETING_IMAGE \| SQUARE_MARKETING_IMAGE \| PORTRAIT_MARKETING_IMAGE \| LOGO \| LANDSCAPE_LOGO \| IMAGE (for unscoped create) |

<a id="apb-gads-mutate-campaign-update-status"></a>
### `apb-gads mutate campaign-update-status`

**Usage**

```
Usage: apb-gads mutate campaign-update-status [OPTIONS] --campaign-id <CAMPAIGN_ID> --status <STATUS>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--status <STATUS>` | — |

<a id="apb-gads-mutate-ad-create"></a>
### `apb-gads mutate ad-create`

**Usage**

```
Usage: apb-gads mutate ad-create [OPTIONS] --ad-group-id <AD_GROUP_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | — |
| `--headline <HEADLINES>` | — |
| `--description <DESCRIPTIONS>` | — |
| `--final-url <FINAL_URLS>` | — |

<a id="apb-gads-mutate-campaign-create"></a>
### `apb-gads mutate campaign-create`

**Usage**

```
Usage: apb-gads mutate campaign-create [OPTIONS] --name <NAME> --channel-type <CHANNEL_TYPE> --budget-resource-name <BUDGET_RESOURCE_NAME>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--name <NAME>` | — |
| `--channel-type <CHANNEL_TYPE>` | SEARCH, DISPLAY, or DEMAND_GEN. (VIDEO is not creatable via the API.) |
| `--budget-resource-name <BUDGET_RESOURCE_NAME>` | — |

<a id="apb-gads-mutate-ad-group-create"></a>
### `apb-gads mutate ad-group-create`

**Usage**

```
Usage: apb-gads mutate ad-group-create [OPTIONS] --campaign-id <CAMPAIGN_ID> --name <NAME>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--name <NAME>` | — |
| `--ad-group-type <AD_GROUP_TYPE>` | [default: SEARCH_STANDARD] |
| `--cpc-bid-micros <CPC_BID_MICROS>` | — |

<a id="apb-gads-mutate-keyword-add"></a>
### `apb-gads mutate keyword-add`

**Usage**

```
Usage: apb-gads mutate keyword-add [OPTIONS] --ad-group-id <AD_GROUP_ID> --text <TEXT>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | — |
| `--text <TEXT>` | — |
| `--match-type <MATCH_TYPE>` | [default: BROAD] |

<a id="apb-gads-mutate-keyword-bid-set"></a>
### `apb-gads mutate keyword-bid-set`

**Usage**

```
Usage: apb-gads mutate keyword-bid-set [OPTIONS] --ad-group-id <AD_GROUP_ID> --criterion-id <CRITERION_ID> --cpc-bid-micros <CPC_BID_MICROS>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | — |
| `--criterion-id <CRITERION_ID>` | — |
| `--cpc-bid-micros <CPC_BID_MICROS>` | Keyword-level max CPC in micros ($1.00 = 1000000) |

<a id="apb-gads-mutate-campaign-budget-update"></a>
### `apb-gads mutate campaign-budget-update`

**Usage**

```
Usage: apb-gads mutate campaign-budget-update [OPTIONS] --budget-resource-name <BUDGET_RESOURCE_NAME> --amount-micros <AMOUNT_MICROS>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--budget-resource-name <BUDGET_RESOURCE_NAME>` | — |
| `--amount-micros <AMOUNT_MICROS>` | — |

<a id="apb-gads-mutate-criterion-remove"></a>
### `apb-gads mutate criterion-remove`

**Usage**

```
Usage: apb-gads mutate criterion-remove [OPTIONS] --ad-group-id <AD_GROUP_ID> --criterion-id <CRITERION_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | — |
| `--criterion-id <CRITERION_ID>` | — |

<a id="apb-gads-mutate-ad-remove"></a>
### `apb-gads mutate ad-remove`

**Usage**

```
Usage: apb-gads mutate ad-remove [OPTIONS] --ad-group-id <AD_GROUP_ID> --ad-id <AD_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | — |
| `--ad-id <AD_ID>` | — |

<a id="apb-gads-mutate-ad-group-remove"></a>
### `apb-gads mutate ad-group-remove`

**Usage**

```
Usage: apb-gads mutate ad-group-remove [OPTIONS] --ad-group-id <AD_GROUP_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | — |

<a id="apb-gads-mutate-campaign-remove"></a>
### `apb-gads mutate campaign-remove`

**Usage**

```
Usage: apb-gads mutate campaign-remove [OPTIONS] --campaign-id <CAMPAIGN_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |

<a id="apb-gads-mutate-campaign-budget-remove"></a>
### `apb-gads mutate campaign-budget-remove`

**Usage**

```
Usage: apb-gads mutate campaign-budget-remove [OPTIONS] --budget-resource-name <BUDGET_RESOURCE_NAME>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--budget-resource-name <BUDGET_RESOURCE_NAME>` | — |

<a id="apb-gads-mutate-pmax-campaign-create"></a>
### `apb-gads mutate pmax-campaign-create`

**Usage**

```
Usage: apb-gads mutate pmax-campaign-create [OPTIONS] --name <NAME> --budget-resource-name <BUDGET_RESOURCE_NAME> --final-url <FINAL_URL>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--name <NAME>` | — |
| `--budget-resource-name <BUDGET_RESOURCE_NAME>` | — |
| `--final-url <FINAL_URL>` | — |

<a id="apb-gads-mutate-pmax-asset-group-create"></a>
### `apb-gads mutate pmax-asset-group-create`

**Usage**

```
Usage: apb-gads mutate pmax-asset-group-create [OPTIONS] --campaign-id <CAMPAIGN_ID> --name <NAME> --final-url <FINAL_URL>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--name <NAME>` | — |
| `--final-url <FINAL_URL>` | — |

<a id="apb-gads-mutate-pmax-asset-group-remove"></a>
### `apb-gads mutate pmax-asset-group-remove`

**Usage**

```
Usage: apb-gads mutate pmax-asset-group-remove [OPTIONS] --asset-group-id <ASSET_GROUP_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--asset-group-id <ASSET_GROUP_ID>` | — |

<a id="apb-gads-mutate-pmax-asset-attach"></a>
### `apb-gads mutate pmax-asset-attach`

**Usage**

```
Usage: apb-gads mutate pmax-asset-attach [OPTIONS] --asset-group-id <ASSET_GROUP_ID> --field-type <FIELD_TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--asset-group-id <ASSET_GROUP_ID>` | — |
| `--field-type <FIELD_TYPE>` | With --text: HEADLINE \| LONG_HEADLINE \| DESCRIPTION \| BUSINESS_NAME. With --asset-id, also media: YOUTUBE_VIDEO \| MARKETING_IMAGE \| SQUARE_MARKETING_IMAGE \| LOGO \| LANDSCAPE_LOGO \| PORTRAIT_MARKETING_IMAGE |
| `--text <TEXT>` | Text content for a new TEXT asset (mutually exclusive with --asset-id) |
| `--asset-id <ASSET_ID>` | Existing asset ID to link — text OR media, e.g. a YOUTUBE_VIDEO/image asset (mutually exclusive with --text) |

<a id="apb-gads-mutate-pmax-asset-detach"></a>
### `apb-gads mutate pmax-asset-detach`

**Usage**

```
Usage: apb-gads mutate pmax-asset-detach [OPTIONS] --asset-group-id <ASSET_GROUP_ID> --asset-id <ASSET_ID> --field-type <FIELD_TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--asset-group-id <ASSET_GROUP_ID>` | — |
| `--asset-id <ASSET_ID>` | — |
| `--field-type <FIELD_TYPE>` | — |

<a id="apb-gads-mutate-pmax-launch"></a>
### `apb-gads mutate pmax-launch`

**Usage**

```
Usage: apb-gads mutate pmax-launch [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to JSON: {name, final_url, budget_micros, headlines:[3-15], long_headlines:[0-5], descriptions:[2-5], business_name?, logo_asset_resources:[..], marketing_image_asset_resources:[1+], square_marketing_image_asset_resources:[1+]} (marketing + square images are existing IMAGE asset resources, required for a valid asset group) |
| `--legacy-sequential` | Use the pre-v24 sequential path (one mutate per entity). Default is one atomic mutate using v24 negative-ID temp resources — preferred because failure rolls back the whole batch rather than leaving partial state. Retained for one version to let operators compare outputs; will be removed in a later arc |

<a id="apb-gads-mutate-ad-validate"></a>
### `apb-gads mutate ad-validate`

**Usage**

```
Usage: apb-gads mutate ad-validate [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to JSON: {ad_type: 'rsa'\|'pmax_asset_group', ad: {...spec...}}. Pre-flight validation with no API call. |

<a id="apb-gads-mutate-campaign-geo-add"></a>
### `apb-gads mutate campaign-geo-add`

**Usage**

```
Usage: apb-gads mutate campaign-geo-add [OPTIONS] --campaign-id <CAMPAIGN_ID> --geo-target-id <GEO_TARGET_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--geo-target-id <GEO_TARGET_ID>` | Numeric ID, e.g. 2840 for USA (geoTargetConstants/2840) |
| `--negative` | Treat as a geo exclusion instead of a positive target |
| `--bid-modifier <BID_MODIFIER>` | 0.1-10.0; e.g. 1.2 = +20% |

<a id="apb-gads-mutate-campaign-language-add"></a>
### `apb-gads mutate campaign-language-add`

**Usage**

```
Usage: apb-gads mutate campaign-language-add [OPTIONS] --campaign-id <CAMPAIGN_ID> --language-id <LANGUAGE_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--language-id <LANGUAGE_ID>` | Numeric ID, e.g. 1000 for English (languageConstants/1000) |

<a id="apb-gads-mutate-campaign-device-modifier-set"></a>
### `apb-gads mutate campaign-device-modifier-set`

**Usage**

```
Usage: apb-gads mutate campaign-device-modifier-set [OPTIONS] --campaign-id <CAMPAIGN_ID> --device <DEVICE> --bid-modifier <BID_MODIFIER>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--device <DEVICE>` | DESKTOP \| MOBILE \| TABLET \| CONNECTED_TV \| OTHER |
| `--bid-modifier <BID_MODIFIER>` | 0.1-10.0; e.g. 0.8 = -20% |

<a id="apb-gads-mutate-campaign-ad-schedule-add"></a>
### `apb-gads mutate campaign-ad-schedule-add`

**Usage**

```
Usage: apb-gads mutate campaign-ad-schedule-add [OPTIONS] --campaign-id <CAMPAIGN_ID> --day <DAY> --start-hour <START_HOUR> --end-hour <END_HOUR>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--day <DAY>` | MONDAY \| TUESDAY \| WEDNESDAY \| THURSDAY \| FRIDAY \| SATURDAY \| SUNDAY |
| `--start-hour <START_HOUR>` | 0-23 |
| `--end-hour <END_HOUR>` | 0-23, must be greater than start-hour |
| `--bid-modifier <BID_MODIFIER>` | — |

<a id="apb-gads-mutate-campaign-audience-add"></a>
### `apb-gads mutate campaign-audience-add`

**Usage**

```
Usage: apb-gads mutate campaign-audience-add [OPTIONS] --campaign-id <CAMPAIGN_ID> --audience-type <AUDIENCE_TYPE> --audience-id <AUDIENCE_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--audience-type <AUDIENCE_TYPE>` | USER_LIST \| USER_INTEREST \| CUSTOM_AUDIENCE \| AUDIENCE |
| `--audience-id <AUDIENCE_ID>` | Numeric ID; full resource path is constructed from --customer + type |
| `--negative` | Add as exclusion instead of positive targeting/observation |
| `--bid-modifier <BID_MODIFIER>` | — |

<a id="apb-gads-mutate-campaign-demographic-exclude"></a>
### `apb-gads mutate campaign-demographic-exclude`

**Usage**

```
Usage: apb-gads mutate campaign-demographic-exclude [OPTIONS] --campaign-id <CAMPAIGN_ID> --demo-type <DEMO_TYPE> --demo-value <DEMO_VALUE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--demo-type <DEMO_TYPE>` | AGE_RANGE \| GENDER \| PARENTAL_STATUS \| INCOME_RANGE |
| `--demo-value <DEMO_VALUE>` | Per-type enum: e.g. AGE_RANGE_18_24, FEMALE, PARENT, INCOME_RANGE_0_50 |

<a id="apb-gads-mutate-campaign-ipblock-add"></a>
### `apb-gads mutate campaign-ipblock-add`

**Usage**

```
Usage: apb-gads mutate campaign-ipblock-add [OPTIONS] --campaign-id <CAMPAIGN_ID> --ip-address <IP_ADDRESS>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--ip-address <IP_ADDRESS>` | IPv4/IPv6 address or CIDR range to exclude |

<a id="apb-gads-mutate-campaign-demographic-add"></a>
### `apb-gads mutate campaign-demographic-add`

**Usage**

```
Usage: apb-gads mutate campaign-demographic-add [OPTIONS] --campaign-id <CAMPAIGN_ID> --demo-type <DEMO_TYPE> --demo-value <DEMO_VALUE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--demo-type <DEMO_TYPE>` | AGE_RANGE \| GENDER \| PARENTAL_STATUS \| INCOME_RANGE |
| `--demo-value <DEMO_VALUE>` | Per-type enum: e.g. AGE_RANGE_25_34, FEMALE, INCOME_RANGE_90_UP |
| `--negative` | Exclude instead of target (default is positive targeting) |
| `--bid-modifier <BID_MODIFIER>` | 0.1-10.0; positive criteria only |

<a id="apb-gads-mutate-campaign-proximity-add"></a>
### `apb-gads mutate campaign-proximity-add`

**Usage**

```
Usage: apb-gads mutate campaign-proximity-add [OPTIONS] --campaign-id <CAMPAIGN_ID> --latitude <LATITUDE> --longitude <LONGITUDE> --radius <RADIUS> --radius-units <RADIUS_UNITS>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--latitude <LATITUDE>` | Latitude in decimal degrees, e.g. 47.6062 |
| `--longitude <LONGITUDE>` | Longitude in decimal degrees, e.g. -122.3321 |
| `--radius <RADIUS>` | Radius value (max 500 miles / 800 km) |
| `--radius-units <RADIUS_UNITS>` | KILOMETERS \| MILES |
| `--bid-modifier <BID_MODIFIER>` | 0.1-10.0 |

<a id="apb-gads-mutate-campaign-content-label-exclude"></a>
### `apb-gads mutate campaign-content-label-exclude`

**Usage**

```
Usage: apb-gads mutate campaign-content-label-exclude [OPTIONS] --campaign-id <CAMPAIGN_ID> --label-type <LABEL_TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--label-type <LABEL_TYPE>` | SEXUALLY_SUGGESTIVE\|BELOW_THE_FOLD\|PARKED_DOMAIN\|JUVENILE\|PROFANITY\|TRAGEDY\|VIDEO\|EMBEDDED_VIDEO\|LIVE_STREAMING_VIDEO\|SOCIAL_ISSUES |

<a id="apb-gads-mutate-campaign-placement-exclude"></a>
### `apb-gads mutate campaign-placement-exclude`

**Usage**

```
Usage: apb-gads mutate campaign-placement-exclude [OPTIONS] --campaign-id <CAMPAIGN_ID> --url <URL>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--url <URL>` | Placement URL/app to exclude |

<a id="apb-gads-mutate-campaign-topic-exclude"></a>
### `apb-gads mutate campaign-topic-exclude`

**Usage**

```
Usage: apb-gads mutate campaign-topic-exclude [OPTIONS] --campaign-id <CAMPAIGN_ID> --topic-id <TOPIC_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--topic-id <TOPIC_ID>` | Numeric topic constant ID |

<a id="apb-gads-mutate-campaign-youtube-video-exclude"></a>
### `apb-gads mutate campaign-youtube-video-exclude`

**Usage**

```
Usage: apb-gads mutate campaign-youtube-video-exclude [OPTIONS] --campaign-id <CAMPAIGN_ID> --video-id <VIDEO_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--video-id <VIDEO_ID>` | — |

<a id="apb-gads-mutate-campaign-youtube-channel-exclude"></a>
### `apb-gads mutate campaign-youtube-channel-exclude`

**Usage**

```
Usage: apb-gads mutate campaign-youtube-channel-exclude [OPTIONS] --campaign-id <CAMPAIGN_ID> --channel-id <CHANNEL_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--channel-id <CHANNEL_ID>` | — |

<a id="apb-gads-mutate-campaign-mobile-app-exclude"></a>
### `apb-gads mutate campaign-mobile-app-exclude`

**Usage**

```
Usage: apb-gads mutate campaign-mobile-app-exclude [OPTIONS] --campaign-id <CAMPAIGN_ID> --app-id <APP_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--app-id <APP_ID>` | platform-prefixed app id, e.g. 1-com.example.app (Android) or 2-<id> (iOS) |

<a id="apb-gads-mutate-campaign-criterion-remove"></a>
### `apb-gads mutate campaign-criterion-remove`

**Usage**

```
Usage: apb-gads mutate campaign-criterion-remove [OPTIONS] --campaign-id <CAMPAIGN_ID> --criterion-id <CRITERION_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--criterion-id <CRITERION_ID>` | — |

<a id="apb-gads-mutate-campaign-update-bidding-strategy"></a>
### `apb-gads mutate campaign-update-bidding-strategy`

**Usage**

```
Usage: apb-gads mutate campaign-update-bidding-strategy [OPTIONS] --campaign-id <CAMPAIGN_ID> --strategy-type <STRATEGY_TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--strategy-type <STRATEGY_TYPE>` | MANUAL_CPC \| MAXIMIZE_CONVERSIONS \| MAXIMIZE_CONVERSION_VALUE \| TARGET_CPA \| TARGET_ROAS \| PERCENT_CPC \| MAXIMIZE_CLICKS (=TARGET_SPEND) |
| `--target-cpa-micros <TARGET_CPA_MICROS>` | — |
| `--target-roas <TARGET_ROAS>` | — |
| `--enhanced-cpc <ENHANCED_CPC>` | [possible values: true, false] |
| `--cpc-bid-ceiling-micros <CPC_BID_CEILING_MICROS>` | Required for MAXIMIZE_CLICKS: positive CPC bid ceiling in micros (the v24 update path cannot set a no-ceiling Maximize Clicks) |

<a id="apb-gads-mutate-campaign-update-dates"></a>
### `apb-gads mutate campaign-update-dates`

**Usage**

```
Usage: apb-gads mutate campaign-update-dates [OPTIONS] --campaign-id <CAMPAIGN_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--start-date <START_DATE>` | — |
| `--end-date <END_DATE>` | — |

<a id="apb-gads-mutate-campaign-update-network-settings"></a>
### `apb-gads mutate campaign-update-network-settings`

**Usage**

```
Usage: apb-gads mutate campaign-update-network-settings [OPTIONS] --campaign-id <CAMPAIGN_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--target-google-search <TARGET_GOOGLE_SEARCH>` | [possible values: true, false] |
| `--target-search-network <TARGET_SEARCH_NETWORK>` | [possible values: true, false] |
| `--target-content-network <TARGET_CONTENT_NETWORK>` | [possible values: true, false] |
| `--target-partner-search-network <TARGET_PARTNER_SEARCH_NETWORK>` | [possible values: true, false] |
| `--target-youtube <TARGET_YOUTUBE>` | [possible values: true, false] |
| `--target-google-tv-network <TARGET_GOOGLE_TV_NETWORK>` | [possible values: true, false] |

<a id="apb-gads-mutate-campaign-update-frequency-cap"></a>
### `apb-gads mutate campaign-update-frequency-cap`

**Usage**

```
Usage: apb-gads mutate campaign-update-frequency-cap [OPTIONS] --campaign-id <CAMPAIGN_ID> --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--from-file <FROM_FILE>` | JSON: {frequency_caps: [{key:{level,event_type,time_unit,time_length}, cap}, ...]} |

<a id="apb-gads-mutate-pmax-audience-signal-attach"></a>
### `apb-gads mutate pmax-audience-signal-attach`

**Usage**

```
Usage: apb-gads mutate pmax-audience-signal-attach [OPTIONS] --asset-group-id <ASSET_GROUP_ID> --signal-type <SIGNAL_TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--asset-group-id <ASSET_GROUP_ID>` | — |
| `--signal-type <SIGNAL_TYPE>` | SEARCH_THEME (with --text) or AUDIENCE (with --audience-id) |
| `--text <TEXT>` | Search-theme text (max 80 chars) |
| `--audience-id <AUDIENCE_ID>` | Audience resource ID (must have scope=ASSET_GROUP) |

<a id="apb-gads-mutate-pmax-audience-signal-detach"></a>
### `apb-gads mutate pmax-audience-signal-detach`

**Usage**

```
Usage: apb-gads mutate pmax-audience-signal-detach [OPTIONS] --signal-resource-name <SIGNAL_RESOURCE_NAME>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--signal-resource-name <SIGNAL_RESOURCE_NAME>` | Full resource: customers/X/assetGroupSignals/<id>~<id> |

<a id="apb-gads-mutate-shared-set-create"></a>
### `apb-gads mutate shared-set-create`

**Usage**

```
Usage: apb-gads mutate shared-set-create [OPTIONS] --name <NAME> --type <TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--name <NAME>` | — |
| `--type <TYPE>` | NEGATIVE_KEYWORDS \| NEGATIVE_PLACEMENTS \| ACCOUNT_LEVEL_NEGATIVE_KEYWORDS \| BRANDS |

<a id="apb-gads-mutate-shared-criterion-add"></a>
### `apb-gads mutate shared-criterion-add`

**Usage**

```
Usage: apb-gads mutate shared-criterion-add [OPTIONS] --shared-set-id <SHARED_SET_ID> --criterion-type <CRITERION_TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--shared-set-id <SHARED_SET_ID>` | — |
| `--criterion-type <CRITERION_TYPE>` | KEYWORD (with --text + --match-type), PLACEMENT (with --url), or BRAND (with --brand-id) |
| `--text <TEXT>` | — |
| `--match-type <MATCH_TYPE>` | BROAD \| PHRASE \| EXACT (KEYWORD only) |
| `--url <URL>` | — |
| `--brand-id <BRAND_ID>` | Brand Commercial-KG MID from `customer suggest-brands` (BRAND only) |

<a id="apb-gads-mutate-campaign-shared-set-attach"></a>
### `apb-gads mutate campaign-shared-set-attach`

**Usage**

```
Usage: apb-gads mutate campaign-shared-set-attach [OPTIONS] --campaign-id <CAMPAIGN_ID> --shared-set-id <SHARED_SET_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--shared-set-id <SHARED_SET_ID>` | — |

<a id="apb-gads-mutate-campaign-brand-list-exclude"></a>
### `apb-gads mutate campaign-brand-list-exclude`

Exclude a BRANDS shared set (brand list) from a campaign as a NEGATIVE brand-list criterion — competitor-brand exclusion (PMAX & gated channels allow brand lists only negatively). Build/populate the set first with `shared-set-create --type BRANDS` + `shared-criterion-add --type BRAND`

**Usage**

```
Usage: apb-gads mutate campaign-brand-list-exclude [OPTIONS] --campaign-id <CAMPAIGN_ID> --shared-set-id <SHARED_SET_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--shared-set-id <SHARED_SET_ID>` | A BRANDS-type shared set id |

<a id="apb-gads-mutate-conversion-action-create"></a>
### `apb-gads mutate conversion-action-create`

**Usage**

```
Usage: apb-gads mutate conversion-action-create [OPTIONS] --name <NAME> --category <CATEGORY>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--name <NAME>` | — |
| `--category <CATEGORY>` | DEFAULT \| PURCHASE \| LEAD \| SIGNUP \| PAGE_VIEW \| DOWNLOAD \| ADD_TO_CART \| ... (see ConversionActionCategory) |
| `--default-value <DEFAULT_VALUE>` | Default conversion value (currency-agnostic; account currency applies) |
| `--counting-type <COUNTING_TYPE>` | ONE_PER_CLICK \| MANY_PER_CLICK |
| `--type <ACTION_TYPE>` | WEBPAGE (default) \| GOOGLE_ANALYTICS_4_* \| FIREBASE_ANDROID_* \| FIREBASE_IOS_* |

<a id="apb-gads-mutate-shared-criterion-remove"></a>
### `apb-gads mutate shared-criterion-remove`

**Usage**

```
Usage: apb-gads mutate shared-criterion-remove [OPTIONS] --shared-set-id <SHARED_SET_ID> --criterion-id <CRITERION_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--shared-set-id <SHARED_SET_ID>` | — |
| `--criterion-id <CRITERION_ID>` | — |

<a id="apb-gads-mutate-campaign-shared-set-detach"></a>
### `apb-gads mutate campaign-shared-set-detach`

**Usage**

```
Usage: apb-gads mutate campaign-shared-set-detach [OPTIONS] --campaign-id <CAMPAIGN_ID> --shared-set-id <SHARED_SET_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--shared-set-id <SHARED_SET_ID>` | — |

<a id="apb-gads-mutate-shared-set-remove"></a>
### `apb-gads mutate shared-set-remove`

**Usage**

```
Usage: apb-gads mutate shared-set-remove [OPTIONS] --shared-set-id <SHARED_SET_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--shared-set-id <SHARED_SET_ID>` | — |

<a id="apb-gads-mutate-campaign-update-tracking-url"></a>
### `apb-gads mutate campaign-update-tracking-url`

**Usage**

```
Usage: apb-gads mutate campaign-update-tracking-url [OPTIONS] --campaign-id <CAMPAIGN_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--tracking-url-template <TRACKING_URL_TEMPLATE>` | Empty string clears the template |
| `--final-url-suffix <FINAL_URL_SUFFIX>` | — |

<a id="apb-gads-mutate-ad-create-video-responsive"></a>
### `apb-gads mutate ad-create-video-responsive`

Create a VideoResponsiveAd (v24). Spec is a JSON file — see VideoResponsiveAdSpec. v24 requires videos + logo_images (business_name is NOT required)

**Usage**

```
Usage: apb-gads mutate ad-create-video-responsive [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to VideoResponsiveAdSpec JSON |

<a id="apb-gads-mutate-ad-update-video-responsive"></a>
### `apb-gads mutate ad-update-video-responsive`

Partial update of a VideoResponsiveAd (v24 made VideoResponsiveAdInfo mutable). Each present field in the spec is added to the update mask

**Usage**

```
Usage: apb-gads mutate ad-update-video-responsive [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to VideoResponsiveAdUpdateSpec JSON |

<a id="apb-gads-mutate-ad-create-demandgen-video-responsive"></a>
### `apb-gads mutate ad-create-demandgen-video-responsive`

Create a DemandGenVideoResponsiveAd (v24). Distinct validated surface from ad-create-video-responsive. Same v24 required fields (videos + logo_images); business_name remains operator-opt-in

**Usage**

```
Usage: apb-gads mutate ad-create-demandgen-video-responsive [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to DemandGenVideoResponsiveAdSpec JSON |

<a id="apb-gads-mutate-customer-update-video-brand-safety"></a>
### `apb-gads mutate customer-update-video-brand-safety`

Set customer-level video brand safety (v24). Replaces the removed campaign.video_brand_safety_suitability with the account-wide customer.video_brand_safety_suitability

**Usage**

```
Usage: apb-gads mutate customer-update-video-brand-safety [OPTIONS] --suitability <SUITABILITY>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--suitability <SUITABILITY>` | EXPANDED_INVENTORY \| STANDARD_INVENTORY \| LIMITED_INVENTORY (short aliases EXPANDED / STANDARD / LIMITED also accepted) |

<a id="apb-gads-mutate-campaign-update-vtc-optimization"></a>
### `apb-gads mutate campaign-update-vtc-optimization`

Toggle view-through conversion optimization on a campaign. New in v24. When enabled, Smart Bidding considers view-through conversions alongside click-through for optimization. Pass exactly one of --enable or --disable

**Usage**

```
Usage: apb-gads mutate campaign-update-vtc-optimization [OPTIONS] --campaign-id <CAMPAIGN_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--enable` | Enable VTC optimization |
| `--disable` | Disable VTC optimization |

<a id="apb-gads-mutate-campaign-update-target-impression-share"></a>
### `apb-gads mutate campaign-update-target-impression-share`

**Usage**

```
Usage: apb-gads mutate campaign-update-target-impression-share [OPTIONS] --campaign-id <CAMPAIGN_ID> --location <LOCATION> --location-fraction-micros <LOCATION_FRACTION_MICROS>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--location <LOCATION>` | ANYWHERE_ON_PAGE \| TOP_OF_PAGE \| ABSOLUTE_TOP_OF_PAGE |
| `--location-fraction-micros <LOCATION_FRACTION_MICROS>` | 1..1000000 (e.g. 650000 = 65%) |
| `--cpc-bid-ceiling-micros <CPC_BID_CEILING_MICROS>` | — |

<a id="apb-gads-mutate-campaign-update-customer-acquisition"></a>
### `apb-gads mutate campaign-update-customer-acquisition`

**Usage**

```
Usage: apb-gads mutate campaign-update-customer-acquisition [OPTIONS] --campaign-id <CAMPAIGN_ID> --optimization-mode <OPTIMIZATION_MODE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--optimization-mode <OPTIMIZATION_MODE>` | TARGET_ALL_EQUALLY \| BID_HIGHER_FOR_NEW_CUSTOMER \| TARGET_NEW_CUSTOMER |

<a id="apb-gads-mutate-campaign-update-geo-target-type"></a>
### `apb-gads mutate campaign-update-geo-target-type`

**Usage**

```
Usage: apb-gads mutate campaign-update-geo-target-type [OPTIONS] --campaign-id <CAMPAIGN_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--positive-geo-target-type <POSITIVE_GEO_TARGET_TYPE>` | PRESENCE_OR_INTEREST \| SEARCH_INTEREST \| PRESENCE |
| `--negative-geo-target-type <NEGATIVE_GEO_TARGET_TYPE>` | PRESENCE_OR_INTEREST \| PRESENCE |

<a id="apb-gads-mutate-campaign-update-ad-rotation"></a>
### `apb-gads mutate campaign-update-ad-rotation`

**Usage**

```
Usage: apb-gads mutate campaign-update-ad-rotation [OPTIONS] --campaign-id <CAMPAIGN_ID> --rotation-mode <ROTATION_MODE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--rotation-mode <ROTATION_MODE>` | OPTIMIZE \| ROTATE_INDEFINITELY |

<a id="apb-gads-mutate-campaign-update-url-expansion-opt-out"></a>
### `apb-gads mutate campaign-update-url-expansion-opt-out`

Opt a campaign out of (or back into) final-URL-expansion text-asset automation — the v24 lever (campaign.asset_automation_settings, FINAL_URL_EXPANSION_TEXT_ASSET_AUTOMATION) that replaced the removed `url_expansion_opt_out` boolean. Reads + merges existing settings so other automation types (e.g. TEXT_ASSET_AUTOMATION) are preserved, not reset

**Usage**

```
Usage: apb-gads mutate campaign-update-url-expansion-opt-out [OPTIONS] --campaign-id <CAMPAIGN_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--opt-out` | Opt OUT of final-URL expansion (stop auto-discovered landing pages / auto-generated text assets) |
| `--opt-in` | Opt back IN (revert to Google's default expansion) |

<a id="apb-gads-mutate-bidding-strategy-create"></a>
### `apb-gads mutate bidding-strategy-create`

**Usage**

```
Usage: apb-gads mutate bidding-strategy-create [OPTIONS] --name <NAME> --strategy-type <STRATEGY_TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--name <NAME>` | — |
| `--strategy-type <STRATEGY_TYPE>` | TARGET_CPA \| TARGET_ROAS \| MAXIMIZE_CONVERSIONS \| MAXIMIZE_CONVERSION_VALUE |
| `--target-cpa-micros <TARGET_CPA_MICROS>` | — |
| `--target-roas <TARGET_ROAS>` | — |

<a id="apb-gads-mutate-bidding-strategy-remove"></a>
### `apb-gads mutate bidding-strategy-remove`

Remove a portfolio (shared) bidding strategy. Must have no attached campaigns (detach them first via campaign-update-bidding-strategy or campaign-remove)

**Usage**

```
Usage: apb-gads mutate bidding-strategy-remove [OPTIONS] --bidding-strategy-id <BIDDING_STRATEGY_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--bidding-strategy-id <BIDDING_STRATEGY_ID>` | — |

<a id="apb-gads-mutate-campaign-attach-portfolio-bidding"></a>
### `apb-gads mutate campaign-attach-portfolio-bidding`

**Usage**

```
Usage: apb-gads mutate campaign-attach-portfolio-bidding [OPTIONS] --campaign-id <CAMPAIGN_ID> --bidding-strategy-id <BIDDING_STRATEGY_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--bidding-strategy-id <BIDDING_STRATEGY_ID>` | — |

<a id="apb-gads-mutate-bidding-seasonality-adjustment-create"></a>
### `apb-gads mutate bidding-seasonality-adjustment-create`

**Usage**

```
Usage: apb-gads mutate bidding-seasonality-adjustment-create [OPTIONS] --name <NAME> --start-date <START_DATE> --end-date <END_DATE> --conversion-rate-modifier <CONVERSION_RATE_MODIFIER>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--name <NAME>` | — |
| `--start-date <START_DATE>` | YYYY-MM-DD |
| `--end-date <END_DATE>` | YYYY-MM-DD |
| `--conversion-rate-modifier <CONVERSION_RATE_MODIFIER>` | 0.1-10.0; 1.5 = +50% |

<a id="apb-gads-mutate-bidding-data-exclusion-create"></a>
### `apb-gads mutate bidding-data-exclusion-create`

**Usage**

```
Usage: apb-gads mutate bidding-data-exclusion-create [OPTIONS] --name <NAME> --start-date <START_DATE> --end-date <END_DATE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--name <NAME>` | — |
| `--start-date <START_DATE>` | YYYY-MM-DD |
| `--end-date <END_DATE>` | YYYY-MM-DD |

<a id="apb-gads-mutate-conversion-value-rule-create"></a>
### `apb-gads mutate conversion-value-rule-create`

Create a conversion value rule (account-level): adjust the conversion VALUE Smart Bidding optimizes toward, by geo/device/audience — the modern replacement for geo/device/audience bid adjustments under value-based bidding (Max Conv Value / Target ROAS). WARNING: inflates reported conversion value

**Usage**

```
Usage: apb-gads mutate conversion-value-rule-create [OPTIONS] --dimension <DIMENSION> --value <VALUE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--dimension <DIMENSION>` | geo \| device \| audience |
| `--operation <OPERATION>` | multiply \| add \| set [default: multiply] |
| `--value <VALUE>` | 1.2 = multiply conversion value by 1.2x |
| `--geo-target-id <GEO_TARGET_ID>` | required for --dimension geo (e.g. 2840 = US) |
| `--device <DEVICE>` | required for --dimension device: mobile\|desktop\|tablet |
| `--user-list-id <USER_LIST_ID>` | required for --dimension audience |

<a id="apb-gads-mutate-campaign-conversion-goal-set"></a>
### `apb-gads mutate campaign-conversion-goal-set`

**Usage**

```
Usage: apb-gads mutate campaign-conversion-goal-set [OPTIONS] --campaign-id <CAMPAIGN_ID> --category <CATEGORY> --origin <ORIGIN>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--category <CATEGORY>` | Conversion category, e.g. PURCHASE \| LEAD \| ADD_TO_CART \| BEGIN_CHECKOUT |
| `--origin <ORIGIN>` | Conversion origin, e.g. WEBSITE \| APP \| CALL_FROM_ADS |
| `--biddable` | — |
| `--not-biddable` | — |

<a id="apb-gads-mutate-ad-group-audience-add"></a>
### `apb-gads mutate ad-group-audience-add`

**Usage**

```
Usage: apb-gads mutate ad-group-audience-add [OPTIONS] --ad-group-id <AD_GROUP_ID> --audience-type <AUDIENCE_TYPE> --audience-id <AUDIENCE_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | — |
| `--audience-type <AUDIENCE_TYPE>` | USER_LIST \| USER_INTEREST \| CUSTOM_AUDIENCE \| AUDIENCE |
| `--audience-id <AUDIENCE_ID>` | — |
| `--negative` | Exclude instead of target |
| `--bid-modifier <BID_MODIFIER>` | — |

<a id="apb-gads-mutate-ad-group-demographic-add"></a>
### `apb-gads mutate ad-group-demographic-add`

**Usage**

```
Usage: apb-gads mutate ad-group-demographic-add [OPTIONS] --ad-group-id <AD_GROUP_ID> --demo-type <DEMO_TYPE> --demo-value <DEMO_VALUE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | — |
| `--demo-type <DEMO_TYPE>` | AGE_RANGE \| GENDER \| PARENTAL_STATUS \| INCOME_RANGE |
| `--demo-value <DEMO_VALUE>` | — |
| `--negative` | Exclude instead of target |
| `--bid-modifier <BID_MODIFIER>` | — |

<a id="apb-gads-mutate-ad-group-placement-add"></a>
### `apb-gads mutate ad-group-placement-add`

**Usage**

```
Usage: apb-gads mutate ad-group-placement-add [OPTIONS] --ad-group-id <AD_GROUP_ID> --url <URL>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | — |
| `--url <URL>` | Placement URL |
| `--negative` | Exclude instead of target (managed placement) |

<a id="apb-gads-mutate-asset-create-sitelink"></a>
### `apb-gads mutate asset-create-sitelink`

**Usage**

```
Usage: apb-gads mutate asset-create-sitelink [OPTIONS] --link-text <LINK_TEXT> --final-url <FINAL_URL>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--link-text <LINK_TEXT>` | ≤ 25 chars |
| `--final-url <FINAL_URL>` | — |
| `--description1 <DESCRIPTION1>` | Optional description1 (≤ 35 chars) |
| `--description2 <DESCRIPTION2>` | Optional description2 (≤ 35 chars) |

<a id="apb-gads-mutate-asset-create-callout"></a>
### `apb-gads mutate asset-create-callout`

**Usage**

```
Usage: apb-gads mutate asset-create-callout [OPTIONS] --text <TEXT>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--text <TEXT>` | Callout text (≤ 25 chars) |

<a id="apb-gads-mutate-asset-create-structured-snippet"></a>
### `apb-gads mutate asset-create-structured-snippet`

**Usage**

```
Usage: apb-gads mutate asset-create-structured-snippet [OPTIONS] --header <HEADER>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--header <HEADER>` | Approved header (e.g. Brands, Services, Types, Styles, Amenities, Courses, Destinations, Models, Neighborhoods, Shows, Insurance coverage, Degree programs, Featured hotels, Service catalog) |
| `--value <VALUE>...` | Repeatable: 1-10 values, each ≤ 25 chars |

<a id="apb-gads-mutate-asset-create-promotion"></a>
### `apb-gads mutate asset-create-promotion`

**Usage**

```
Usage: apb-gads mutate asset-create-promotion [OPTIONS] --promotion-target <PROMOTION_TARGET> --final-url <FINAL_URL>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--promotion-target <PROMOTION_TARGET>` | ≤ 20 chars, e.g. 'Holiday Sale' |
| `--percent-off <PERCENT_OFF>` | Mutually exclusive with --money-amount-off-micros; 1-99 |
| `--money-amount-off-micros <MONEY_AMOUNT_OFF_MICROS>` | Absolute discount in micros; requires --money-currency-code |
| `--money-currency-code <MONEY_CURRENCY_CODE>` | 3-letter ISO (e.g. USD); required with --money-amount-off-micros |
| `--promotion-code <PROMOTION_CODE>` | — |
| `--final-url <FINAL_URL>` | — |
| `--start-date <START_DATE>` | YYYY-MM-DD |
| `--end-date <END_DATE>` | YYYY-MM-DD |

<a id="apb-gads-mutate-asset-create-call"></a>
### `apb-gads mutate asset-create-call`

**Usage**

```
Usage: apb-gads mutate asset-create-call [OPTIONS] --country-code <COUNTRY_CODE> --phone-number <PHONE_NUMBER>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--country-code <COUNTRY_CODE>` | 2-letter ISO (e.g. US) |
| `--phone-number <PHONE_NUMBER>` | — |

<a id="apb-gads-mutate-asset-create-price"></a>
### `apb-gads mutate asset-create-price`

**Usage**

```
Usage: apb-gads mutate asset-create-price [OPTIONS] --price-type <PRICE_TYPE> --language-code <LANGUAGE_CODE> --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--price-type <PRICE_TYPE>` | BRANDS \| EVENTS \| LOCATIONS \| NEIGHBORHOODS \| PRODUCT_CATEGORIES \| PRODUCT_TIERS \| SERVICES \| SERVICE_CATEGORIES \| SERVICE_TIERS |
| `--language-code <LANGUAGE_CODE>` | e.g. 'en' |
| `--from-file <FROM_FILE>` | JSON with {items:[{header,description?,price_micros,currency_code,price_unit,final_url}, ...]} — 3-8 items |

<a id="apb-gads-mutate-campaign-asset-attach"></a>
### `apb-gads mutate campaign-asset-attach`

**Usage**

```
Usage: apb-gads mutate campaign-asset-attach [OPTIONS] --campaign-id <CAMPAIGN_ID> --asset-id <ASSET_ID> --field-type <FIELD_TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--asset-id <ASSET_ID>` | — |
| `--field-type <FIELD_TYPE>` | SITELINK \| CALLOUT \| STRUCTURED_SNIPPET \| PROMOTION \| CALL \| PRICE \| ... |

<a id="apb-gads-mutate-campaign-asset-detach"></a>
### `apb-gads mutate campaign-asset-detach`

**Usage**

```
Usage: apb-gads mutate campaign-asset-detach [OPTIONS] --campaign-id <CAMPAIGN_ID> --asset-id <ASSET_ID> --field-type <FIELD_TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |
| `--asset-id <ASSET_ID>` | — |
| `--field-type <FIELD_TYPE>` | — |

<a id="apb-gads-mutate-ad-group-asset-attach"></a>
### `apb-gads mutate ad-group-asset-attach`

**Usage**

```
Usage: apb-gads mutate ad-group-asset-attach [OPTIONS] --ad-group-id <AD_GROUP_ID> --asset-id <ASSET_ID> --field-type <FIELD_TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | — |
| `--asset-id <ASSET_ID>` | — |
| `--field-type <FIELD_TYPE>` | — |

<a id="apb-gads-mutate-ad-group-asset-detach"></a>
### `apb-gads mutate ad-group-asset-detach`

**Usage**

```
Usage: apb-gads mutate ad-group-asset-detach [OPTIONS] --ad-group-id <AD_GROUP_ID> --asset-id <ASSET_ID> --field-type <FIELD_TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | — |
| `--asset-id <ASSET_ID>` | — |
| `--field-type <FIELD_TYPE>` | — |

<a id="apb-gads-mutate-customer-asset-attach"></a>
### `apb-gads mutate customer-asset-attach`

**Usage**

```
Usage: apb-gads mutate customer-asset-attach [OPTIONS] --asset-id <ASSET_ID> --field-type <FIELD_TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--asset-id <ASSET_ID>` | — |
| `--field-type <FIELD_TYPE>` | — |

<a id="apb-gads-mutate-customer-asset-detach"></a>
### `apb-gads mutate customer-asset-detach`

**Usage**

```
Usage: apb-gads mutate customer-asset-detach [OPTIONS] --asset-id <ASSET_ID> --field-type <FIELD_TYPE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--asset-id <ASSET_ID>` | — |
| `--field-type <FIELD_TYPE>` | — |

<a id="apb-gads-mutate-experiment-create"></a>
### `apb-gads mutate experiment-create`

**Usage**

```
Usage: apb-gads mutate experiment-create [OPTIONS] --base-campaign-id <BASE_CAMPAIGN_ID> --name <NAME> --suffix <SUFFIX> --traffic-split <TRAFFIC_SPLIT>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--base-campaign-id <BASE_CAMPAIGN_ID>` | — |
| `--name <NAME>` | Experiment base name (sandbox tag appended automatically) |
| `--suffix <SUFFIX>` | Suffix appended to treatment campaign name (e.g. '-exp') |
| `--traffic-split <TRAFFIC_SPLIT>` | 1-99; percent of traffic routed to the treatment arm |

<a id="apb-gads-mutate-experiment-end"></a>
### `apb-gads mutate experiment-end`

**Usage**

```
Usage: apb-gads mutate experiment-end [OPTIONS] --experiment-id <EXPERIMENT_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--experiment-id <EXPERIMENT_ID>` | — |
