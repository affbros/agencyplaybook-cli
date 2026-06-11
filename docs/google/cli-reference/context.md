# `apb-gads context`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Per-customer goal/strategy context state. Writes a local JSON file at {config_dir}/context/{customer_id}.json. No Google Ads API calls; entirely outside the three-gate safety model (see docs/context.md)

**Surface:** 👁️ Read-only · **2 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`init`](#apb-gads-context-init) | Initialize or overwrite the per-customer context file |
| [`show`](#apb-gads-context-show) | Show the current context for a customer. |

---

<a id="apb-gads-context-init"></a>
### `apb-gads context init`

Initialize or overwrite the per-customer context file

**Usage**

```
Usage: apb-gads context init [OPTIONS] --mode <MODE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--mode <MODE>` | Goal/bidding mode. E.g. target_cpa, target_roas, maximize_conversions, maximize_conversion_value, manual_cpc |
| `--target-cpa <TARGET_CPA>` | Target CPA in dollars (optional, used with target_cpa mode) |
| `--target-roas <TARGET_ROAS>` | Target ROAS as a multiplier (optional, used with target_roas mode) |
| `--primary-kpi <PRIMARY_KPI>` | Primary KPI (default: conversions) |
| `--from <FROM>` | Optional path to a `plan goals` artifact JSON whose goals fields override the explicit --mode / --target-cpa / --target-roas flags |

<a id="apb-gads-context-show"></a>
### `apb-gads context show`

Show the current context for a customer. Errors if not yet initialized

**Usage**

```
Usage: apb-gads context show [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._
