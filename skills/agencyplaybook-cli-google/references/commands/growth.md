# `apb-gads growth`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Growth analysis — dual-window weekly/monthly performance reviews and guardrail-based monitoring. All subcommands are READ-ONLY (no mutations)

**Surface:** 👁️ Read-only · **5 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`weekly-review`](#apb-gads-growth-weekly-review) | Dual-window weekly performance review (current N days vs prior N days). |
| [`monthly-review`](#apb-gads-growth-monthly-review) | Dual-window monthly performance review (current N days vs prior N days) with budget reallocation and next-month roadmap. |
| [`monitor`](#apb-gads-growth-monitor) | Evaluate guardrail rules from a YAML rules file against live account data. |
| [`scale-up`](#apb-gads-growth-scale-up) | Growth-first scale-up readout: where you have efficient headroom to GROW — budget-limited winners, rank-limited campaigns, expansion-ready, search terms to promote, and ROAS headroom — ranked by upside, never by cuts. |
| [`consolidation`](#apb-gads-growth-consolidation) | Consolidation/structure readout aligned to the "consolidate + broad match + Smart Bidding" doctrine: where over-fragmentation starves Smart Bidding of signal, and how consolidating unlocks scale. |

---

<a id="apb-gads-growth-weekly-review"></a>
### `apb-gads growth weekly-review`

Dual-window weekly performance review (current N days vs prior N days). Classifies campaigns as winners/losers, computes account-level delta, and emits recommended actions. READ-ONLY. Window size is the global `--lookback-days` (default 7 if unset)

**Usage**

```
Usage: apb-gads growth weekly-review [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-growth-monthly-review"></a>
### `apb-gads growth monthly-review`

Dual-window monthly performance review (current N days vs prior N days) with budget reallocation and next-month roadmap. READ-ONLY. Window size is the global `--lookback-days` (default 30 if unset)

**Usage**

```
Usage: apb-gads growth monthly-review [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-growth-monitor"></a>
### `apb-gads growth monitor`

Evaluate guardrail rules from a YAML rules file against live account data. Issues at most two GAQL queries; evaluation is in-memory. READ-ONLY

**Usage**

```
Usage: apb-gads growth monitor [OPTIONS] --rules <RULES>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--rules <RULES>` | Path to the guardrails YAML rules file |

<a id="apb-gads-growth-scale-up"></a>
### `apb-gads growth scale-up`

Growth-first scale-up readout: where you have efficient headroom to GROW — budget-limited winners, rank-limited campaigns, expansion-ready, search terms to promote, and ROAS headroom — ranked by upside, never by cuts. READ-ONLY (composes four read playbooks)

**Usage**

```
Usage: apb-gads growth scale-up [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--min-roas <MIN_ROAS>` | Minimum ROAS gate for the expansion-readiness lever (e.g. 3.0) [default: 3] |

<a id="apb-gads-growth-consolidation"></a>
### `apb-gads growth consolidation`

Consolidation/structure readout aligned to the "consolidate + broad match + Smart Bidding" doctrine: where over-fragmentation starves Smart Bidding of signal, and how consolidating unlocks scale. READ-ONLY (composes 3 audits)

**Usage**

```
Usage: apb-gads growth consolidation [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._
