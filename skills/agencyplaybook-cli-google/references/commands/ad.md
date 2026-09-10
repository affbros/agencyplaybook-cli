# `apb-gads ad`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Ad reads: list ads under an ad group.

**Surface:** 👁️ Read-only · **1 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`list`](#apb-gads-ad-list) |  |

---

<a id="apb-gads-ad-list"></a>
### `apb-gads ad list`

**Usage**

```
Usage: apb-gads ad list [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 20] |
| `--with-attestation` | v24.2: attempt Ad.synthetic_content_info (advertiser + system AI-content attestations, EU AI Act 2026-08-02). Not yet queryable on live v24.2 (PROHIBITED_FIELD_IN_SELECT_CLAUSE) — falls back to the base list plus an `attestation_unavailable` note |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |
