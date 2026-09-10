# `apb-gads recipe`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Recipes — one verb, one job. A recipe reads the account's own context (targets, brand rules, canonical negative list), derives its thresholds from them, classifies every row into negate / promote / review / skip with a reason, and emits a plan-envelope-v2 document plus a currency-denominated summary. DRY-RUN BY DEFAULT: `--execute` applies the plan through `mutate apply-plan`'s three gates, and a plan above the confirm threshold (200 actions) also needs `--confirm`. See docs/recipes.md

**Surface:** ✍️ **Write-capable** · **4 command(s)** · [← back to index](README.md)

> ⚠️ Commands here can write to a Google Ads account. Every write is **dry-run by default** and must clear the three independent gates (`--execute` + config + env) plus a per-customer profile or the test sandbox policy. See [`../mutations.md`](../mutations.md).

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`list`](#apb-gads-recipe-list) | List every registered recipe: name, channel, what it composes, status |
| [`describe`](#apb-gads-recipe-describe) | Print a recipe's decision rules, threshold formulas and exports. |
| [`build`](#apb-gads-recipe-build) | Build a whole campaign from a brief: research → structure → copy → targeting → assets → bidding → validate → plan. |
| [`search-terms`](#apb-gads-recipe-search-terms) | Classify every served search term into negate / promote / review / skip against the account's targets, brand rules and EXISTING negatives (read, never assumed), and package the act buckets as a plan envelope. |

---

<a id="apb-gads-recipe-list"></a>
### `apb-gads recipe list`

List every registered recipe: name, channel, what it composes, status

**Usage**

```
Usage: apb-gads recipe list [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-recipe-describe"></a>
### `apb-gads recipe describe`

Print a recipe's decision rules, threshold formulas and exports. This text IS the recipe's SOP — it is generated from the same code that decides, so the documentation cannot drift from the behaviour

**Usage**

```
Usage: apb-gads recipe describe [OPTIONS] <NAME>
```

**Arguments**

| Argument | Description |
|---|---|
| `<NAME>` | Recipe name, e.g. `search-terms` |

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-recipe-build"></a>
### `apb-gads recipe build`

Build a whole campaign from a brief: research → structure → copy → targeting → assets → bidding → validate → plan. Writes a build directory (spec.v2.json, plan.json, plan.md, plan.html, research/, validate.json) and prints the summary. DRY-RUN BY DEFAULT — `--execute` launches it born PAUSED through `orchestrate campaign-launch`'s existing gates and writes launch.json (roll back with `orchestrate rollback --from-receipt`).

Copy: `--provider heuristic` (default) generates STARTER copy and flags it as such; `--provider agent` means the copy arrives in the brief. For expert copy + brief: install the agencyplaybook-planner skill — https://agencyplaybook.io/downloads

**Usage**

```
Usage: apb-gads recipe build [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--brief <FILE>` | The brief (YAML or JSON). Mutually exclusive with --spec |
| `--spec <FILE>` | A hand-edited spec.v2.json — skips research and re-enters the pipeline at the validate stage. Mutually exclusive with --brief |
| `--out <DIR>` | Build directory. Default: ./build-<YYYYmmdd-HHMM>/ |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--stage <STAGE>` | Stop after this stage: research \| structure \| copy \| targeting \| assets \| bidding \| validate \| plan. Default: plan (the whole build) |
| `--type <TYPE>` | search \| pmax \| demand-gen. Overrides the brief's `type:`; a disagreement fails loud rather than picking |
| `--format <FORMAT>` | spec \| plan \| review \| html \| editor-csv \| all. `all` writes the whole build directory (spec.v2.json, plan.json, plan.md, plan.html, research/, editor/*.csv); `editor-csv` writes ONLY the Google Ads Editor CSV bundle |
| `--provider <PROVIDER>` | heuristic \| agent. Overrides the brief's `copy.provider`. `agent` means the copy arrives in the brief — the binary writes none of it |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — `plan.html`'s font source. `web` adds a Google Fonts `<link>`; `system` stays fully offline-safe |

<a id="apb-gads-recipe-search-terms"></a>
### `apb-gads recipe search-terms`

Classify every served search term into negate / promote / review / skip against the account's targets, brand rules and EXISTING negatives (read, never assumed), and package the act buckets as a plan envelope. Requires `context.brand.terms` — it will not guess a brand from campaign names

**Usage**

```
Usage: apb-gads recipe search-terms [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--out <OUT>` | Directory for review.json (and the CSVs with --format all). Default: build/search-terms |
| `--format <FORMAT>` | summary \| json \| all \| editor-csv. `all` additionally writes negatives.csv + keywords.csv (legacy shape); `editor-csv` writes the same two tables in the Google Ads Editor import layout under `editor/` [default: summary] |
| `--threshold-override <KEY=VALUE>` | Override a derived threshold input: waste_multiplier, promote_min_conversions, review_band_pct, spend_floor. Repeatable |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--review-file <REVIEW_FILE>` | Write the review bucket somewhere other than <out>/review.json |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |
