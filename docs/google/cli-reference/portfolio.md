# `apb-gads portfolio`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Portfolio reporting — MCC-wide, per-currency roll-ups across every reportable child account (analytics-upgrade-001 S007). READ-ONLY; no three-gate safety applied. Fan-out is sequential per account (Google one-ops/day quota); money is never summed across currencies. Window size is the global `--lookback-days` (default 30). With `--customer`, scopes to that single account; without it, every non-manager child of the configured MCC (`login_customer_id`)

**Surface:** 👁️ Read-only · **4 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`summary`](#apb-gads-portfolio-summary) | MCC-wide account summary: per reportable child-account totals (cost, conversions, value, clicks, impressions, ctr, cpa, roas) plus a per-currency roll-up (never FX-blended). |
| [`breakdown`](#apb-gads-portfolio-breakdown) | MCC-wide metric breakdown segmented by a single dimension, grouped per currency. |
| [`trend`](#apb-gads-portfolio-trend) | MCC-wide daily trend: per-currency cost / conversions / conversions_value time-series across reportable children. |
| [`plan`](#apb-gads-portfolio-plan) | Marginal-return budget allocator (planning-001 sprint-g10): per campaign, estimate marginal return from 30d/60d conversions-vs-cost slopes plus `impression-share-loss` headroom, move budget from below-median to above-median marginal return in steps ≤ `--max-step-pct`, never onto a LEARNING campaign, never across currencies, never onto a campaign that can't spend more (lost-IS-to-budget ≈ 0). |

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
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

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
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-portfolio-trend"></a>
### `apb-gads portfolio trend`

MCC-wide daily trend: per-currency cost / conversions / conversions_value time-series across reportable children. Mirrors the portfolio `/gads/reports/trend`. READ-ONLY

**Usage**

```
Usage: apb-gads portfolio trend [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-portfolio-plan"></a>
### `apb-gads portfolio plan`

Marginal-return budget allocator (planning-001 sprint-g10): per campaign, estimate marginal return from 30d/60d conversions-vs-cost slopes plus `impression-share-loss` headroom, move budget from below-median to above-median marginal return in steps ≤ `--max-step-pct`, never onto a LEARNING campaign, never across currencies, never onto a campaign that can't spend more (lost-IS-to-budget ≈ 0). READ-ONLY: writes an envelope of `campaign-budget-update-bulk` actions to `--out` — this command never executes anything itself

**Usage**

```
Usage: apb-gads portfolio plan [OPTIONS] --out <FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--manager <MANAGER>` | The MCC customer id to fan out over (every reportable non-manager child). Mutually exclusive with the global `--customer`, which scopes to exactly one account instead (used by the sandbox smoke test) |
| `--objective <OBJECTIVE>` | conversions (default) \| value — which per-dollar metric ranks campaigns [default: conversions] |
| `--budget-total <BUDGET_TOTAL>` | Cap (currency units) on the sum of new budgets within `--currency`'s group. Requires `--currency` |
| `--currency <CURRENCY>` | Restrict allocation to one currency's campaigns. Omit to allocate within every currency present, independently |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--horizon <HORIZON>` | Recent-window length, e.g. "30d". The trailing window is the same length immediately before it (60 days total read for the default) [default: 30d] |
| `--max-step-pct <MAX_STEP_PCT>` | Largest single move, as a percentage of either side's current budget [default: 10] |
| `--out <FILE>` | Path to write the plan-envelope-v2 JSON |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--with-meta <FILE>` | Merge a `meta-portfolio.json` file (from `apb agency portfolio plan --meta-portfolio-out`) per currency, for REPORTING only — Meta actions are listed in the result, never added to this envelope |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |
