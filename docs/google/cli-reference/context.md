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
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--primary-kpi <PRIMARY_KPI>` | Primary KPI (default: conversions) |
| `--from <FROM>` | Optional path to a `plan goals` artifact JSON whose goals fields override the explicit --mode / --target-cpa / --target-roas flags |
| `--brand-term <TERM>` | Schema v2 — a brand term recipes must never negate or auto-promote. Repeatable. Omitting it leaves any existing terms in place |
| `--brand-domain <DOMAIN>` | Schema v2 — a domain the brand owns. Repeatable; omitting preserves |
| `--brand-competitor <BRAND>` | Schema v2 — a competitor brand. Competitor traffic is account-wide junk, so it seeds the canonical negative list. Repeatable |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--canonical-negative-set <SHARED_SET>` | Schema v2 — the account's canonical NEGATIVE_KEYWORDS shared set (resource name or bare id). Where account-wide negatives go |
| `--protected-shared-set <SHARED_SET>` | Schema v2 — a shared set recipes must not modify. Repeatable |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-context-show"></a>
### `apb-gads context show`

Show the current context for a customer. Errors if not yet initialized

**Usage**

```
Usage: apb-gads context show [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |
