# `apb-gads account`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Pick a persistent "current" operating account (an MCC child) so subsequent commands target it without repeating `--customer`. The selection persists at `~/.apb-gads/state.json` (separate from `google-ads.yaml`). The MCC (`login_customer_id`) is never changed — only the operating customer. `use`, `current`, and `clear` are local state ops (no Google API call); `list` reads the MCC hierarchy. Resolution precedence: `--customer` > persisted > config default

**Surface:** 👁️ Read-only · **4 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`list`](#apb-gads-account-list) | List the MCC's child accounts (same source as `customer list`) and echo the resolved current operating account so you can see which one commands target |
| [`use`](#apb-gads-account-use) | Persist <customer_id> as the current operating account (writes ~/.apb-gads/state.json with perms 0600). |
| [`current`](#apb-gads-account-current) | Print the resolved current operating account and its source (flag / persisted / config-default) |
| [`clear`](#apb-gads-account-clear) | Remove the persisted current selection; resolution falls back to the SaaS/config default account |

---

<a id="apb-gads-account-list"></a>
### `apb-gads account list`

List the MCC's child accounts (same source as `customer list`) and echo the resolved current operating account so you can see which one commands target

**Usage**

```
Usage: apb-gads account list [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-account-use"></a>
### `apb-gads account use`

Persist <customer_id> as the current operating account (writes ~/.apb-gads/state.json with perms 0600). It outranks the SaaS/config default but never a per-command `--customer` flag. In SaaS mode the id must be one of your accessible accounts

**Usage**

```
Usage: apb-gads account use [OPTIONS] <CUSTOMER_ID>
```

**Arguments**

| Argument | Description |
|---|---|
| `<CUSTOMER_ID>` | Numeric Google Ads customer id, no dashes (e.g. 1234567890) |

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-account-current"></a>
### `apb-gads account current`

Print the resolved current operating account and its source (flag / persisted / config-default)

**Usage**

```
Usage: apb-gads account current [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-account-clear"></a>
### `apb-gads account clear`

Remove the persisted current selection; resolution falls back to the SaaS/config default account

**Usage**

```
Usage: apb-gads account clear [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._
