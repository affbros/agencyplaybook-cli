# `apb-gads audit`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Sprint D — audit log inspection + replay

**Surface:** 👁️ Read-only · **3 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`list`](#apb-gads-audit-list) | List audit log entries (JSONL at ~/.apb-gads/audit.jsonl by default) |
| [`get`](#apb-gads-audit-get) | Get a single audit entry in full by its index (0-based line number) |
| [`replay`](#apb-gads-audit-replay) | Replay a captured audit entry's operations. |

---

<a id="apb-gads-audit-list"></a>
### `apb-gads audit list`

List audit log entries (JSONL at ~/.apb-gads/audit.jsonl by default)

**Usage**

```
Usage: apb-gads audit list [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--since <SINCE>` | Filter entries on or after this unix timestamp |
| `--limit <LIMIT>` | Max entries to return |

<a id="apb-gads-audit-get"></a>
### `apb-gads audit get`

Get a single audit entry in full by its index (0-based line number)

**Usage**

```
Usage: apb-gads audit get [OPTIONS] --id <ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--id <ID>` | — |

<a id="apb-gads-audit-replay"></a>
### `apb-gads audit replay`

Replay a captured audit entry's operations. Dry-run by default; --execute required to submit. Entries must be schema v2+

**Usage**

```
Usage: apb-gads audit replay [OPTIONS] --id <ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--id <ID>` | — |
