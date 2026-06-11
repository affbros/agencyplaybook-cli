# `apb-gads export`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Render an artifact JSON into CSV, JSON, or Markdown. Pure local file operation — no Google Ads API calls, no three-gate safety applied

**Surface:** 👁️ Read-only · **1 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`render`](#apb-gads-export-render) | Render an artifact JSON file to CSV, JSON, or Markdown |

---

<a id="apb-gads-export-render"></a>
### `apb-gads export render`

Render an artifact JSON file to CSV, JSON, or Markdown.

For CSV output, one file is written per table to `--out-dir` (or the current directory). For JSON and Markdown, output goes to stdout (or `--output` if set). Multiple CSV tables (e.g. keywords-plan → keywords.csv + negative-keywords.csv) are each written as a separate file.

**Usage**

```
Usage: apb-gads export render [OPTIONS] --from <FROM>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from <FROM>` | Path to the artifact JSON file |
| `--format <FORMAT>` | Output format: csv, json, or markdown |
| `--out-dir <OUT_DIR>` | For CSV format: directory to write one file per table. Defaults to the current working directory |
