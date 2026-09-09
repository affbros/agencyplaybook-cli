# `apb-gads report`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Named, pre-built read reports (search terms, performance, PMAX, etc.).

**Surface:** 👁️ Read-only · **24 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`account-summary-365d`](#apb-gads-report-account-summary-365d) |  |
| [`campaign-performance-365d`](#apb-gads-report-campaign-performance-365d) |  |
| [`monthly-breakdown-365d`](#apb-gads-report-monthly-breakdown-365d) |  |
| [`search-terms-365d`](#apb-gads-report-search-terms-365d) |  |
| [`pmax-summary`](#apb-gads-report-pmax-summary) |  |
| [`asset-usage`](#apb-gads-report-asset-usage) |  |
| [`pmax-asset-groups`](#apb-gads-report-pmax-asset-groups) |  |
| [`pmax-asset-group-assets`](#apb-gads-report-pmax-asset-group-assets) |  |
| [`pmax-asset-group-performance`](#apb-gads-report-pmax-asset-group-performance) |  |
| [`pmax-placements`](#apb-gads-report-pmax-placements) | PMAX placement + channel-proxy visibility (the black box): where ads ran (performance_max_placement_view, impressions-only — for brand-safety exclusions) aggregated by placement_type, plus PMAX campaign metrics. |
| [`pmax-network-placements`](#apb-gads-report-pmax-network-placements) | v24.2: performance_max_placement_view segmented by segments.ad_network_type (Search/Display/partner networks) — channel-MIX proxy, sibling of `pmax-placements` (which aggregates the same view by placement_type instead) |
| [`campaign-settings`](#apb-gads-report-campaign-settings) |  |
| [`campaign-criteria`](#apb-gads-report-campaign-criteria) |  |
| [`shared-sets`](#apb-gads-report-shared-sets) |  |
| [`shared-criteria`](#apb-gads-report-shared-criteria) |  |
| [`campaign-shared-sets`](#apb-gads-report-campaign-shared-sets) |  |
| [`pmax-audience-signals`](#apb-gads-report-pmax-audience-signals) |  |
| [`experiments`](#apb-gads-report-experiments) |  |
| [`ad-approval-status`](#apb-gads-report-ad-approval-status) |  |
| [`impression-share-detail`](#apb-gads-report-impression-share-detail) |  |
| [`shopping-products`](#apb-gads-report-shopping-products) | v24 shopping: list products from the account's linked Merchant Center feed. |
| [`shopping-performance`](#apb-gads-report-shopping-performance) | v24 shopping: per-product performance over the resolved lookback window (default 30d; override via --lookback-days). |
| [`cart-data-sales`](#apb-gads-report-cart-data-sales) | v24 CartDataSalesView — segments by product SOLD (not clicked). |
| [`customer-settings`](#apb-gads-report-customer-settings) | Customer-level settings (v24). |

---

<a id="apb-gads-report-account-summary-365d"></a>
### `apb-gads report account-summary-365d`

**Usage**

```
Usage: apb-gads report account-summary-365d [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--include-non-biddable` | Include v24 non-biddable metrics (all_conversions family, COGS, gross profit, revenue micros). See docs/v24-non-biddable-metrics.md for the compatibility matrix |

<a id="apb-gads-report-campaign-performance-365d"></a>
### `apb-gads report campaign-performance-365d`

**Usage**

```
Usage: apb-gads report campaign-performance-365d [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 10] |
| `--include-non-biddable` | Include v24 non-biddable metrics alongside biddable metrics |

<a id="apb-gads-report-monthly-breakdown-365d"></a>
### `apb-gads report monthly-breakdown-365d`

**Usage**

```
Usage: apb-gads report monthly-breakdown-365d [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-report-search-terms-365d"></a>
### `apb-gads report search-terms-365d`

**Usage**

```
Usage: apb-gads report search-terms-365d [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 20] |

<a id="apb-gads-report-pmax-summary"></a>
### `apb-gads report pmax-summary`

**Usage**

```
Usage: apb-gads report pmax-summary [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-report-asset-usage"></a>
### `apb-gads report asset-usage`

**Usage**

```
Usage: apb-gads report asset-usage [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 20] |

<a id="apb-gads-report-pmax-asset-groups"></a>
### `apb-gads report pmax-asset-groups`

**Usage**

```
Usage: apb-gads report pmax-asset-groups [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 20] |

<a id="apb-gads-report-pmax-asset-group-assets"></a>
### `apb-gads report pmax-asset-group-assets`

**Usage**

```
Usage: apb-gads report pmax-asset-group-assets [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 20] |

<a id="apb-gads-report-pmax-asset-group-performance"></a>
### `apb-gads report pmax-asset-group-performance`

**Usage**

```
Usage: apb-gads report pmax-asset-group-performance [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 20] |

<a id="apb-gads-report-pmax-placements"></a>
### `apb-gads report pmax-placements`

PMAX placement + channel-proxy visibility (the black box): where ads ran (performance_max_placement_view, impressions-only — for brand-safety exclusions) aggregated by placement_type, plus PMAX campaign metrics. Honest about API limits (per-channel spend split is script-only) + mitigation writes

**Usage**

```
Usage: apb-gads report pmax-placements [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 50] |

<a id="apb-gads-report-pmax-network-placements"></a>
### `apb-gads report pmax-network-placements`

v24.2: performance_max_placement_view segmented by segments.ad_network_type (Search/Display/partner networks) — channel-MIX proxy, sibling of `pmax-placements` (which aggregates the same view by placement_type instead)

**Usage**

```
Usage: apb-gads report pmax-network-placements [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 50] |

<a id="apb-gads-report-campaign-settings"></a>
### `apb-gads report campaign-settings`

**Usage**

```
Usage: apb-gads report campaign-settings [OPTIONS] --campaign-id <CAMPAIGN_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |

<a id="apb-gads-report-campaign-criteria"></a>
### `apb-gads report campaign-criteria`

**Usage**

```
Usage: apb-gads report campaign-criteria [OPTIONS] --campaign-id <CAMPAIGN_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-id <CAMPAIGN_ID>` | — |

<a id="apb-gads-report-shared-sets"></a>
### `apb-gads report shared-sets`

**Usage**

```
Usage: apb-gads report shared-sets [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 50] |

<a id="apb-gads-report-shared-criteria"></a>
### `apb-gads report shared-criteria`

**Usage**

```
Usage: apb-gads report shared-criteria [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 200] |

<a id="apb-gads-report-campaign-shared-sets"></a>
### `apb-gads report campaign-shared-sets`

**Usage**

```
Usage: apb-gads report campaign-shared-sets [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 100] |

<a id="apb-gads-report-pmax-audience-signals"></a>
### `apb-gads report pmax-audience-signals`

**Usage**

```
Usage: apb-gads report pmax-audience-signals [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 50] |

<a id="apb-gads-report-experiments"></a>
### `apb-gads report experiments`

**Usage**

```
Usage: apb-gads report experiments [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 50] |

<a id="apb-gads-report-ad-approval-status"></a>
### `apb-gads report ad-approval-status`

**Usage**

```
Usage: apb-gads report ad-approval-status [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 200] |

<a id="apb-gads-report-impression-share-detail"></a>
### `apb-gads report impression-share-detail`

**Usage**

```
Usage: apb-gads report impression-share-detail [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-report-shopping-products"></a>
### `apb-gads report shopping-products`

v24 shopping: list products from the account's linked Merchant Center feed. Returns title, brand, price, availability, status, channel

**Usage**

```
Usage: apb-gads report shopping-products [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 100] |

<a id="apb-gads-report-shopping-performance"></a>
### `apb-gads report shopping-performance`

v24 shopping: per-product performance over the resolved lookback window (default 30d; override via --lookback-days). Ordered by cost

**Usage**

```
Usage: apb-gads report shopping-performance [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 100] |

<a id="apb-gads-report-cart-data-sales"></a>
### `apb-gads report cart-data-sales`

v24 CartDataSalesView — segments by product SOLD (not clicked). Surfaces cross-sell vs lead revenue split + units sold. Uses the resolved lookback window (default 30d)

**Usage**

```
Usage: apb-gads report cart-data-sales [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 100] |

<a id="apb-gads-report-customer-settings"></a>
### `apb-gads report customer-settings`

Customer-level settings (v24). Surfaces customer.video_brand_safety_suitability — the v24 replacement for the removed campaign.video_brand_safety_suitability — plus tracking, auto-tagging, timezone, status

**Usage**

```
Usage: apb-gads report customer-settings [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._
