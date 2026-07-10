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
