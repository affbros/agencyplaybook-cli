# `apb-gads plan`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Phase B1 (v24) — keyword planning surface (reads only). Wraps KeywordPlanIdeaService / KeywordPlanService. Does not write; no three-gate safety applied. Expert copy + brief: install the agencyplaybook-planner skill (see /downloads)

**Surface:** 👁️ Read-only · **15 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`keyword-ideas`](#apb-gads-plan-keyword-ideas) | Generate keyword ideas from seeds (keywords, URL, or site). |
| [`keyword-historical-metrics`](#apb-gads-plan-keyword-historical-metrics) | Historical metrics for a fixed keyword list. |
| [`from-audit`](#apb-gads-plan-from-audit) | Convert an audit/playbook spec envelope (written by `playbook ... |
| [`goals`](#apb-gads-plan-goals) | Emit goal configuration, recommended bid strategy, and budget feasibility heuristics for a given campaign mode. |
| [`keywords`](#apb-gads-plan-keywords) | Fetch keyword ideas then run the full generation pipeline: cluster → intent classify → match-type recommend → seed negatives. |
| [`structure`](#apb-gads-plan-structure) | Build a campaign skeleton from a keywords-plan JSON file. |
| [`rsa`](#apb-gads-plan-rsa) | Generate RSA headline/description candidates per ad group from a campaign-structure JSON file |
| [`tracking`](#apb-gads-plan-tracking) | Emit a static conversion-tracking setup template for the given mode. |
| [`campaign`](#apb-gads-plan-campaign) | Greenfield campaign planning: assemble a launchable CampaignLaunchSpec from planning artifacts (`search`). |
| [`export`](#apb-gads-plan-export) | Render a plan envelope file (v1 lifted or native v2) into an artifact, read-only — no gates, no network. |
| [`merge`](#apb-gads-plan-merge) | Merge N Google plan-envelope-v2 files (from separate `--plan`/`recipe build`/`recipe search-terms` runs) into ONE reviewable envelope: dedupe byte-identical actions, isolate contradictory bidding/target/ budget changes as unresolved conflicts, rank the survivors (growth/efficiency), and sequence them behind the learning-window guard — inserting `wait-for-status` pseudo-actions where needed. |
| [`forecast`](#apb-gads-plan-forecast) | Forecast a campaign build via `GenerateKeywordForecastMetrics` (planning-001 sprint-g08). |

---

<a id="apb-gads-plan-keyword-ideas"></a>
### `apb-gads plan keyword-ideas`

Generate keyword ideas from seeds (keywords, URL, or site). Wraps KeywordPlanIdeaService.GenerateKeywordIdeas. Returns avg monthly searches, competition level/index, and top-of-page bid ranges

**Usage**

```
Usage: apb-gads plan keyword-ideas [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--seed-keyword <SEED_KEYWORD>` | Seed keyword. Repeatable. At least one of --seed-keyword, --seed-url, --seed-site, or --seed-keyword-file is required |
| `--seed-url <SEED_URL>` | URL seed. Combine with --seed-keyword for keywordAndUrlSeed; alone, uses urlSeed (exact URL only — for site-wide use --seed-site) |
| `--seed-site <SEED_SITE>` | Site seed. Site-wide crawl. Mutually exclusive with --seed-keyword and --seed-url |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--seed-keyword-file <SEED_KEYWORD_FILE>` | Path to newline-separated keyword file; each line is appended to --seed-keyword |
| `--geo-target-id <GEO_TARGET_ID>` | Geo target constant ID (numeric). Default: 2840 (United States). Repeatable [default: 2840] |
| `--language-id <LANGUAGE_ID>` | Language constant ID (numeric). Default: 1000 (English) [default: 1000] |
| `--network <NETWORK>` | Network: GOOGLE_SEARCH or GOOGLE_SEARCH_AND_PARTNERS [default: GOOGLE_SEARCH] |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--limit <LIMIT>` | Page size (1..=10000) [default: 100] |
| `--include-adult` | Include adult keywords in results |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-plan-keyword-historical-metrics"></a>
### `apb-gads plan keyword-historical-metrics`

Historical metrics for a fixed keyword list. Wraps KeywordPlanIdeaService.GenerateKeywordHistoricalMetrics. Returns backward-looking search volume + competition + bid metrics, and optional per-month search volume series

**Usage**

```
Usage: apb-gads plan keyword-historical-metrics [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--keyword <KEYWORD>` | Keyword. Repeatable. At least one of --keyword or --keyword-file is required |
| `--keyword-file <KEYWORD_FILE>` | Path to newline-separated keyword file; each line is appended to --keyword |
| `--geo-target-id <GEO_TARGET_ID>` | [default: 2840] |
| `--language-id <LANGUAGE_ID>` | [default: 1000] |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--network <NETWORK>` | [default: GOOGLE_SEARCH] |
| `--include-adult` | — |
| `--include-average-cpc` | Request the averageCpcMicros field in the response (adds historicalMetricsOptions.includeAverageCpc to the request) |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-plan-from-audit"></a>
### `apb-gads plan from-audit`

Convert an audit/playbook spec envelope (written by `playbook ... --output-spec`) into a normalized, scored ActionPlan artifact (priority/impact/confidence/risk/effort + can_auto_apply). Read/transform only — no write

**Usage**

```
Usage: apb-gads plan from-audit [OPTIONS] --spec-file <SPEC_FILE> --playbook <PLAYBOOK>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--spec-file <SPEC_FILE>` | Path to the spec envelope JSON (the `--output-spec` output) |
| `--playbook <PLAYBOOK>` | Source playbook slug, recorded in the artifact for traceability (e.g. `waste-cluster-audit`) |
| `--rank-by <RANK_BY>` | Action ranking: `growth-first` (default — lead with the biggest scaling upside, never bury a scale-up under a cut) or `efficiency-first` (the legacy savings-weighted priority order) [default: growth-first] |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-plan-goals"></a>
### `apb-gads plan goals`

Emit goal configuration, recommended bid strategy, and budget feasibility heuristics for a given campaign mode. No API call

**Usage**

```
Usage: apb-gads plan goals [OPTIONS] --mode <MODE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--mode <MODE>` | Campaign mode: lead-gen \| ecommerce \| brand \| app |
| `--target-cpa <TARGET_CPA>` | Target CPA in USD (e.g. 25.0). Omit to use MAXIMIZE_CONVERSIONS |
| `--target-roas <TARGET_ROAS>` | Target ROAS as a multiplier (e.g. 4.0 = 400%). Omit unless ROAS-focused |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-plan-keywords"></a>
### `apb-gads plan keywords`

Fetch keyword ideas then run the full generation pipeline: cluster → intent classify → match-type recommend → seed negatives. Requires --customer. Emits keywords-plan JSON

**Usage**

```
Usage: apb-gads plan keywords [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--seed-keyword <SEED_KEYWORD>` | Seed keyword. Repeatable |
| `--geo-target-id <GEO_TARGET_ID>` | Geo target constant ID (numeric). Default: 2840 (United States) [default: 2840] |
| `--language-id <LANGUAGE_ID>` | Language constant ID (numeric). Default: 1000 (English) [default: 1000] |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--provider <PROVIDER>` | Generation provider: heuristic (default) \| disabled [default: heuristic] |
| `--position-target <POSITION_TARGET>` | Where to aim each keyword's suggested bid within its top-of-page range: first-page (low) \| top-of-page (midpoint, default) \| first-position (high) [default: top-of-page] |
| `--intent-file <INTENT_FILE>` | Path to an intent-keywords YAML file. Each present category (commercial, coupon, free, jobs, support, branded, competitors) REPLACES the built-in defaults — edit the lists to add/remove terms. See docs/planning.md |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-plan-structure"></a>
### `apb-gads plan structure`

Build a campaign skeleton from a keywords-plan JSON file. Pure transform — no API, no generation

**Usage**

```
Usage: apb-gads plan structure [OPTIONS] --from <FROM>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from <FROM>` | Path to the keywords-plan JSON produced by `plan keywords` |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-plan-rsa"></a>
### `apb-gads plan rsa`

Generate RSA headline/description candidates per ad group from a campaign-structure JSON file

**Usage**

```
Usage: apb-gads plan rsa [OPTIONS] --from <FROM>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from <FROM>` | Path to the campaign-structure JSON produced by `plan structure` |
| `--provider <PROVIDER>` | Generation provider: heuristic (default) \| disabled [default: heuristic] |
| `--brand <BRAND>` | Brand name to inject into templates (e.g. "Scandalous Coffee") [default: ""] |
| `--final-url <FINAL_URL>` | Base final URL for the ads (e.g. "https://www.scandalouscoffee.com") [default: ""] |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-plan-tracking"></a>
### `apb-gads plan tracking`

Emit a static conversion-tracking setup template for the given mode. No API call

**Usage**

```
Usage: apb-gads plan tracking [OPTIONS] --mode <MODE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--mode <MODE>` | Campaign mode: lead-gen \| ecommerce \| brand \| app |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-plan-campaign"></a>
### `apb-gads plan campaign`

Greenfield campaign planning: assemble a launchable CampaignLaunchSpec from planning artifacts (`search`). Produces reviewable artifacts only — never launches (use `validate campaign-spec` then `orchestrate campaign-launch`)

**Usage**

```
Usage: apb-gads plan campaign [OPTIONS] <COMMAND>
```

**Subcommands**

| Subcommand | Summary |
|---|---|
| [`search`](#apb-gads-plan-campaign-search) | Assemble a launchable multi-ad-group CampaignLaunchSpec (bare JSON) from `plan structure` + `plan rsa` (+ optional goals/keywords). |
| [`full`](#apb-gads-plan-campaign-full) | Run the whole greenfield pipeline (keyword research → structure → rsa → goals → tracking → one launch spec per campaign + summary.md) into --export-dir. |
| [`pmax`](#apb-gads-plan-campaign-pmax) | Assemble a launchable PmaxLaunchPlanSpec (bare JSON) for a single-asset-group Performance Max campaign (phase 1). |
| [`demand-gen`](#apb-gads-plan-campaign-demand-gen) | Assemble a launchable DemandGenLaunchSpec (bare JSON) for a single-ad-group Demand Gen campaign (decision-verdict-001 S004) — the third pillar alongside `search` / `pmax`. |

<a id="apb-gads-plan-campaign-search"></a>
#### `apb-gads plan campaign search`

Assemble a launchable multi-ad-group CampaignLaunchSpec (bare JSON) from `plan structure` + `plan rsa` (+ optional goals/keywords). Pure transform, no API. Pipe into `validate campaign-spec` then `orchestrate campaign-launch`

**Usage**

```
Usage: apb-gads plan campaign search [OPTIONS] --structure <STRUCTURE> --rsa <RSA> --daily-budget <DAILY_BUDGET>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--structure <STRUCTURE>` | Path to the campaign-structure JSON (`plan structure` output). Required |
| `--rsa <RSA>` | Path to the rsa JSON (`plan rsa` output). Required — supplies ad copy |
| `--goals <GOALS>` | Path to the goals JSON (`plan goals` output). Optional — sets bidding |
| `--keywords-plan <KEYWORDS_PLAN>` | Path to the keywords-plan JSON (`plan keywords` output). Optional — supplies seeded negative keywords |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--negatives-file <NEGATIVES_FILE>` | Path to a campaign-negatives JSON list — `[{"text": "...", "match_type": "BROAD\|PHRASE\|EXACT"}]`. Merged into the exported spec's `campaign_negative_keywords` (deduped against the keywords-plan seeds), so global exclusions no longer have to be hand-injected |
| `--intent <INTENT>` | Which intent-campaign to emit (e.g. commercial). Omit to use the single campaign, or the highest-volume one for a multi-campaign structure |
| `--campaign-name <CAMPAIGN_NAME>` | Override the campaign name (defaults to the structure's campaign name) |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--landing-page <LANDING_PAGE>` | Landing page URL — overrides the RSA artifact's final_urls for every ad group |
| `--daily-budget <DAILY_BUDGET>` | Daily budget in USD (e.g. 500). Required; converted to micros |
| `--geo-target-id <GEO_TARGET_ID>` | Positive geo-target-constant ID (numeric). Repeatable. Default 2840 (US) |
| `--location <LOCATION>` | Geo-target NAME (e.g. "United States"). Repeatable; resolved to an ID |
| `--language-id <LANGUAGE_ID>` | Language-constant ID (numeric). Repeatable. Default 1000 (English) |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |
| `--language <LANGUAGE>` | Language NAME (e.g. "English"). Repeatable; resolved to an ID |
| `--target-cpa <TARGET_CPA>` | Target CPA in USD — sets/overrides TARGET_CPA bidding |
| `--bid-aggressiveness <BID_AGGRESSIVENESS>` | Per-keyword CPC aggressiveness: conservative (0.75x) \| balanced (1.0x) \| aggressive (1.25x), or a raw multiplier like 0.85. Each keyword's bid = its suggested top-of-page bid × this. Requires --keywords-plan |
| `--export <EXPORT>` | Write the bare spec JSON to this path (in addition to stdout) |

<a id="apb-gads-plan-campaign-full"></a>
#### `apb-gads plan campaign full`

Run the whole greenfield pipeline (keyword research → structure → rsa → goals → tracking → one launch spec per campaign + summary.md) into --export-dir. Requires --customer (live keyword-ideas). Read-only — produces artifacts, launches nothing

**Usage**

```
Usage: apb-gads plan campaign full [OPTIONS] --landing-page <LANDING_PAGE> --daily-budget <DAILY_BUDGET> --export-dir <EXPORT_DIR>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--type <CAMPAIGN_TYPE>` | Campaign type. Only `search` is supported today (pmax is a later phase) [default: search] |
| `--seed-keywords <SEED_KEYWORDS>` | Seed keywords. Repeatable, and each value may be comma-separated. Required |
| `--landing-page <LANDING_PAGE>` | Landing page URL for the ads. Required |
| `--campaign-name <CAMPAIGN_NAME>` | Campaign name for the primary (highest-volume) campaign. Optional |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--mode <MODE>` | Goal mode: lead-gen \| ecommerce \| brand \| app [default: lead-gen] |
| `--geo-target-id <GEO_TARGET_ID>` | Geo-target-constant ID (numeric). Repeatable. Default 2840 (US) |
| `--location <LOCATION>` | Geo-target NAME (e.g. "United States"). Repeatable; resolved to an ID |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--language-id <LANGUAGE_ID>` | Language-constant ID (numeric). Repeatable. Default 1000 (English) |
| `--language <LANGUAGE>` | Language NAME (e.g. "English"). Repeatable; resolved to an ID |
| `--network <NETWORK>` | Network: GOOGLE_SEARCH or GOOGLE_SEARCH_AND_PARTNERS [default: GOOGLE_SEARCH] |
| `--daily-budget <DAILY_BUDGET>` | Total daily budget in USD (split across campaigns by volume share) |
| `--target-cpa <TARGET_CPA>` | Target CPA in USD (sets TARGET_CPA bidding) |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |
| `--target-roas <TARGET_ROAS>` | Target ROAS multiplier (e.g. 4.0) |
| `--brand <BRAND>` | Brand name injected into RSA templates [default: ""] |
| `--provider <PROVIDER>` | Generation provider: heuristic (default) \| disabled [default: heuristic] |
| `--intent-file <INTENT_FILE>` | Path to an intent-keywords YAML file (see `plan keywords --intent-file`) |
| `--bid-aggressiveness <BID_AGGRESSIVENESS>` | Per-keyword CPC aggressiveness: conservative \| balanced \| aggressive, or a raw multiplier like 0.85 (bid = suggested top-of-page bid × this) |
| `--export-dir <EXPORT_DIR>` | Directory to write all artifacts + summary.md into. Required |

<a id="apb-gads-plan-campaign-pmax"></a>
#### `apb-gads plan campaign pmax`

Assemble a launchable PmaxLaunchPlanSpec (bare JSON) for a single-asset-group Performance Max campaign (phase 1). Pure transform, no API. Pipe into `validate pmax-spec` then `orchestrate pmax-build`. Image assets must already exist (pass their resource names); use `mutate asset-create-image` to upload

**Usage**

```
Usage: apb-gads plan campaign pmax [OPTIONS] --campaign-name <CAMPAIGN_NAME> --budget-micros <BUDGET_MICROS> --final-url <FINAL_URL> --business-name <BUSINESS_NAME>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-name <CAMPAIGN_NAME>` | Campaign name (must contain `Test-ok-to-delete` for sandbox launches) |
| `--budget-micros <BUDGET_MICROS>` | Daily budget in micros (e.g. 50000000 = $50.00) |
| `--final-url <FINAL_URL>` | Final URL for the asset group |
| `--geo-target-id <GEO_TARGET_ID>` | Geo-target-constant ID (numeric). Repeatable. Default 2840 (US) |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--location <LOCATION>` | Geo-target NAME (e.g. "United States"). Repeatable; resolved to an ID |
| `--language-id <LANGUAGE_ID>` | Language-constant ID (numeric). Repeatable. Default 1000 (English) |
| `--language <LANGUAGE>` | Language NAME (e.g. "English"). Repeatable; resolved to an ID |
| `--bidding-strategy <BIDDING_STRATEGY>` | Bidding: MAXIMIZE_CONVERSIONS \| MAXIMIZE_CONVERSION_VALUE (PMAX-only) [default: MAXIMIZE_CONVERSIONS] |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--target-cpa-micros <TARGET_CPA_MICROS>` | Target CPA micros (MAXIMIZE_CONVERSIONS only) |
| `--target-roas <TARGET_ROAS>` | Target ROAS (MAXIMIZE_CONVERSION_VALUE only, e.g. 3.5) |
| `--negative-keyword <NEGATIVE_KEYWORD>` | Campaign negative keyword as `text:match_type` (PHRASE\|EXACT). Repeatable |
| `--brand-guidelines` | Enable PMAX brand guidelines (campaign-level brand assets). Needs a logo |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |
| `--headline <HEADLINE>` | Headline (3–15 required). Repeatable |
| `--long-headline <LONG_HEADLINE>` | Long headline (0–5). Repeatable |
| `--description <DESCRIPTION>` | Description (2–5 required; at least one < 60 chars). Repeatable |
| `--business-name <BUSINESS_NAME>` | Business name (REQUIRED — v24 needs a BUSINESS_NAME asset) |
| `--logo-asset <LOGO_ASSET>` | Existing LOGO asset resource (customers/<id>/assets/<id>). Repeatable |
| `--landscape-logo-asset <LANDSCAPE_LOGO_ASSET>` | Existing LANDSCAPE_LOGO asset resource. Repeatable |
| `--marketing-image-asset <MARKETING_IMAGE_ASSET>` | Existing MARKETING_IMAGE asset resource (1.91:1, ≥1 required). Repeatable |
| `--square-marketing-image-asset <SQUARE_MARKETING_IMAGE_ASSET>` | Existing SQUARE_MARKETING_IMAGE asset resource (1:1, ≥1 required). Repeatable |
| `--path1 <PATH1>` | Optional display path 1 (≤15 chars) |
| `--path2 <PATH2>` | Optional display path 2 (≤15 chars; requires path1) |
| `--search-theme <SEARCH_THEME>` | SEARCH_THEME signal text (≤80 chars) on the asset group. Repeatable |
| `--audience-id <AUDIENCE_ID>` | Existing AUDIENCE id (numeric) to add as an asset-group signal. Repeatable |
| `--brand-exclusion-mid <BRAND_EXCLUSION_MID>` | Brand MID (e.g. /g/11trq85f_6 from `customer suggest-brands`) to build a BRANDS exclusion set from + exclude. Repeatable |
| `--brand-exclusion-set-id <BRAND_EXCLUSION_SET_ID>` | Existing BRANDS shared set id (numeric) to exclude from the campaign |
| `--ad-schedule <AD_SCHEDULE>` | Ad schedule (dayparting) as DAY:start_hour:end_hour (e.g. MONDAY:9:17). NO bid modifier (PMAX rejects per-schedule modifiers). Repeatable |
| `--customer-acquisition-mode <CUSTOMER_ACQUISITION_MODE>` | New-customer-acquisition optimization mode: TARGET_ALL_EQUALLY \| BID_HIGHER_FOR_NEW_CUSTOMER \| TARGET_NEW_CUSTOMER (singular). The new-customer modes need an account-level existing-customer definition |
| `--merchant-id <MERCHANT_ID>` | Merchant Center account ID (numeric) — makes this a RETAIL (Shopping) PMax that serves product ads from the linked feed. Pair with a fully-partitioned listing group (`mutate pmax-listing-group-filter-*`) |
| `--feed-label <FEED_LABEL>` | Merchant Center feed label (e.g. "US") restricting which products serve. Only meaningful with --merchant-id |

<a id="apb-gads-plan-campaign-demand-gen"></a>
#### `apb-gads plan campaign demand-gen`

Assemble a launchable DemandGenLaunchSpec (bare JSON) for a single-ad-group Demand Gen campaign (decision-verdict-001 S004) — the third pillar alongside `search` / `pmax`. Pre-create video + logo assets (`mutate asset-*`) and pass their resource names. Emits `{ command, spec, validation }`; pipe `.spec` to `orchestrate demand-gen-build --from-file`

**Usage**

```
Usage: apb-gads plan campaign demand-gen [OPTIONS] --campaign-name <CAMPAIGN_NAME> --budget-micros <BUDGET_MICROS> --final-url <FINAL_URL> --ad-group-name <AD_GROUP_NAME>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--campaign-name <CAMPAIGN_NAME>` | — |
| `--budget-micros <BUDGET_MICROS>` | — |
| `--final-url <FINAL_URL>` | — |
| `--geo-target-id <GEO_TARGET_ID>` | Positive geo-target-constant id (numeric, e.g. 2840 = USA). Repeatable |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--language-id <LANGUAGE_ID>` | Language-constant id (numeric, e.g. 1000 = English). Repeatable |
| `--bidding-strategy <BIDDING_STRATEGY>` | Bidding: MAXIMIZE_CLICKS \| MAXIMIZE_CONVERSIONS \| MAXIMIZE_CONVERSION_VALUE [default: MAXIMIZE_CONVERSIONS] |
| `--target-cpa-micros <TARGET_CPA_MICROS>` | Target CPA micros (MAXIMIZE_CONVERSIONS) |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--target-roas <TARGET_ROAS>` | Target ROAS (MAXIMIZE_CONVERSION_VALUE, e.g. 3.5) |
| `--ad-group-name <AD_GROUP_NAME>` | — |
| `--audience-id <AUDIENCE_ID>` | Existing AUDIENCE id (numeric). Repeatable |
| `--video-asset <VIDEO_ASSET>` | Video asset resource name (≥1 required). Repeatable |
| `--logo-asset <LOGO_ASSET>` | Logo image asset resource name (≥1 required). Repeatable |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |
| `--headline-asset <HEADLINE_ASSET>` | — |
| `--long-headline-asset <LONG_HEADLINE_ASSET>` | — |
| `--description-asset <DESCRIPTION_ASSET>` | — |
| `--cta-asset <CTA_ASSET>` | — |
| `--business-name-asset <BUSINESS_NAME_ASSET>` | — |

<a id="apb-gads-plan-export"></a>
### `apb-gads plan export`

Render a plan envelope file (v1 lifted or native v2) into an artifact, read-only — no gates, no network. What the SaaS `editor.zip` route shells to for `--format editor-csv` (sprint-g05)

**Usage**

```
Usage: apb-gads plan export [OPTIONS] --from-file <FILE> --format <FORMAT> --out <PATH>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FILE>` | Path to the plan JSON (v1 or v2 envelope) |
| `--format <FORMAT>` | editor-csv \| html \| md. `editor-csv` writes `<out>/editor/*.csv`; `html`/`md` write a single file at `--out` |
| `--out <PATH>` | Output path: a directory for `editor-csv`, a file for `html`/`md` |
| `--fonts <FONTS>` | system (default) \| web — only meaningful with `--format html` [default: system] |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--allow-edited-plan` | Proceed even if the envelope's recomputed hash no longer matches its stored value (same override `apply-plan` uses) |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |

<a id="apb-gads-plan-merge"></a>
### `apb-gads plan merge`

Merge N Google plan-envelope-v2 files (from separate `--plan`/`recipe build`/`recipe search-terms` runs) into ONE reviewable envelope: dedupe byte-identical actions, isolate contradictory bidding/target/ budget changes as unresolved conflicts, rank the survivors (growth/efficiency), and sequence them behind the learning-window guard — inserting `wait-for-status` pseudo-actions where needed. `mutate apply-plan` honours those waits (planning-001 sprint-g07)

**Usage**

```
Usage: apb-gads plan merge [OPTIONS] --out <FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from <FILE>` | Path to an input plan file (v1 or v2 envelope). Repeatable — give at least one |
| `--mode <MODE>` | Ranking mode: growth (default — growth score desc, then impact/ confidence/effort) \| efficiency (impact score first) [default: growth] |
| `--horizon <HORIZON>` | Sequencing horizon fallback when no live/per-target window is known, e.g. "14d". Google campaigns use the live channel-type default (Search 14 / PMAX 28) instead when `--customer` is given and `--offline` is not set [default: 14d] |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--offline` | Skip every live learning-window/status read even if `--customer` is set: every gated target falls back to the channel default window and an Unknown status (never assumed cleared) |
| `--out <FILE>` | Path to write the merged plan-envelope-v2 JSON |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-plan-forecast"></a>
### `apb-gads plan forecast`

Forecast a campaign build via `GenerateKeywordForecastMetrics` (planning-001 sprint-g08). Reads a CampaignLaunchSpec (`--spec`, the shape `recipe build`/`plan campaign search` emit) or a live campaign (`--campaign-id`), fans out one forecast call per budget/target scenario (paced ~1 QPS/CID), and prints a scenario table. With `--plan`, stamps `score.growth_micros` / `preview.forecast` onto the emitted envelope's build/budget actions. PMAX/Demand Gen campaigns (via `--campaign-id`) have no forecast API and return `{"forecast": null}` with exit 0

**Usage**

```
Usage: apb-gads plan forecast [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--spec <SPEC>` | Path to a CampaignLaunchSpec JSON. Mutually exclusive with `--campaign-id` |
| `--campaign-id <CAMPAIGN_ID>` | A live campaign id to forecast instead of a spec file. Reads keywords/geo/language/bidding via GAQL. Mutually exclusive with `--spec` |
| `--budget-scenarios <BUDGET_SCENARIOS>` | Comma-separated daily budget scenarios in USD, e.g. "50,100,150". Each becomes `manualCpcBiddingStrategy.dailyBudgetMicros` — a real Google-enforced daily budget cap. Mutually exclusive with --target-scenarios (different bidding strategies) |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--target-scenarios <TARGET_SCENARIOS>` | Comma-separated daily target-spend scenarios in USD, e.g. "25,50,75", forecast under `maximizeConversionsBiddingStrategy` (what Google forecasts if Smart Bidding maximizes conversions within that daily spend). Mutually exclusive with --budget-scenarios |
| `--period <PERIOD>` | Forecast window: "<n>d" (e.g. 30d) or "YYYY-MM-DD..YYYY-MM-DD" [default: 30d] |
| `--out <OUT>` | Write the raw scenario JSON to this path in addition to stdout |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |
