# `apb-gads customer`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Customer (account) reads: list accessible accounts and walk the MCC hierarchy.

**Surface:** 👁️ Read-only · **2 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`list`](#apb-gads-customer-list) |  |
| [`suggest-brands`](#apb-gads-customer-suggest-brands) | Suggest verified brands for a name prefix (BrandSuggestionService). |

---

<a id="apb-gads-customer-list"></a>
### `apb-gads customer list`

**Usage**

```
Usage: apb-gads customer list [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-customer-suggest-brands"></a>
### `apb-gads customer suggest-brands`

Suggest verified brands for a name prefix (BrandSuggestionService). Returns each brand's Commercial-KG id (MID) for `shared-criterion-add --type BRAND --brand-id <id>`

**Usage**

```
Usage: apb-gads customer suggest-brands [OPTIONS] --prefix <PREFIX>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--prefix <PREFIX>` | Brand-name prefix to search (e.g. "Starbucks") |
| `--selected-brand-id <SELECTED_BRAND_ID>` | Already-selected brand id to exclude from results (repeatable) |
