# `apb-gads sandbox`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Test-sandbox write flows: end-to-end helper(s) that exercise the $1 sandbox policy (create → verify → clean up) on a disposable entity.

**Surface:** ✍️ **Write-capable** · **1 command(s)** · [← back to index](README.md)

> ⚠️ Commands here can write to a Google Ads account. Every write is **dry-run by default** and must clear the three independent gates (`--execute` + config + env) plus a per-customer profile or the test sandbox policy. See [`../mutations.md`](../mutations.md).

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`helper`](#apb-gads-sandbox-helper) |  |

---

<a id="apb-gads-sandbox-helper"></a>
### `apb-gads sandbox helper`

**Usage**

```
Usage: apb-gads sandbox helper [OPTIONS] <COMMAND>
```

**Subcommands**

| Subcommand | Summary |
|---|---|
| [`full-flow`](#apb-gads-sandbox-helper-full-flow) |  |

<a id="apb-gads-sandbox-helper-full-flow"></a>
#### `apb-gads sandbox helper full-flow`

**Usage**

```
Usage: apb-gads sandbox helper full-flow [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |
