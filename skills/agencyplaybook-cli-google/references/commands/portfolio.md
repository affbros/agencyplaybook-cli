# `apb-gads portfolio`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Portfolio reporting — MCC-wide, per-currency roll-ups across every reportable child account (analytics-upgrade-001 S007). READ-ONLY; no three-gate safety applied. Fan-out is sequential per account (Google one-ops/day quota); money is never summed across currencies. Window size is the global `--lookback-days` (default 30). With `--customer`, scopes to that single account; without it, every non-manager child of the configured MCC (`login_customer_id`)

**Surface:** 👁️ Read-only · **3 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`summary`](#apb-gads-portfolio-summary) | MCC-wide account summary: per reportable child-account totals (cost, conversions, value, clicks, impressions, ctr, cpa, roas) plus a per-currency roll-up (never FX-blended). |
| [`breakdown`](#apb-gads-portfolio-breakdown) | MCC-wide metric breakdown segmented by a single dimension, grouped per currency. |
| [`trend`](#apb-gads-portfolio-trend) | MCC-wide daily trend: per-currency cost / conversions / conversions_value time-series across reportable children. |

---

<a id="apb-gads-portfolio-summary"></a>
### `apb-gads portfolio summary`

MCC-wide account summary: per reportable child-account totals (cost, conversions, value, clicks, impressions, ctr, cpa, roas) plus a per-currency roll-up (never FX-blended). `--compare` adds prior-window deltas per account and a `previous_totals_by_currency` sibling. Mirrors the web UI's `/gads/accounts/summary`. READ-ONLY

**Usage**

```
Usage: apb-gads portfolio summary [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--compare` | Also compute the equal-length prior window and per-account deltas |

<a id="apb-gads-portfolio-breakdown"></a>
### `apb-gads portfolio breakdown`

MCC-wide metric breakdown segmented by a single dimension, grouped per currency. Mirrors `/gads/reports/breakdown`. READ-ONLY

**Usage**

```
Usage: apb-gads portfolio breakdown [OPTIONS] --dimension <DIMENSION>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--dimension <DIMENSION>` | Segment dimension: device \| network \| campaign_type |

<a id="apb-gads-portfolio-trend"></a>
### `apb-gads portfolio trend`

MCC-wide daily trend: per-currency cost / conversions / conversions_value time-series across reportable children. Mirrors the portfolio `/gads/reports/trend`. READ-ONLY

**Usage**

```
Usage: apb-gads portfolio trend [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._
