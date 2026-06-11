# `apb-gads plan`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Phase B1 (v24) — keyword planning surface (reads only). Wraps KeywordPlanIdeaService / KeywordPlanService. Does not write; no three-gate safety applied

**Surface:** 👁️ Read-only · **11 command(s)** · [← back to index](README.md)

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

---

<a id="apb-gads-plan-keyword-ideas"></a>
### `apb-gads plan keyword-ideas`

Generate keyword ideas from seeds (keywords, URL, or site). Wraps v24 KeywordPlanIdeaService.GenerateKeywordIdeas. Returns avg monthly searches, competition level/index, and top-of-page bid ranges

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
| `--seed-keyword-file <SEED_KEYWORD_FILE>` | Path to newline-separated keyword file; each line is appended to --seed-keyword |
| `--geo-target-id <GEO_TARGET_ID>` | Geo target constant ID (numeric). Default: 2840 (United States). Repeatable [default: 2840] |
| `--language-id <LANGUAGE_ID>` | Language constant ID (numeric). Default: 1000 (English) [default: 1000] |
| `--network <NETWORK>` | Network: GOOGLE_SEARCH or GOOGLE_SEARCH_AND_PARTNERS [default: GOOGLE_SEARCH] |
| `--limit <LIMIT>` | Page size (1..=10000) [default: 100] |
| `--include-adult` | Include adult keywords in results |

<a id="apb-gads-plan-keyword-historical-metrics"></a>
### `apb-gads plan keyword-historical-metrics`

Historical metrics for a fixed keyword list. Wraps v24 KeywordPlanIdeaService.GenerateKeywordHistoricalMetrics. Returns backward-looking search volume + competition + bid metrics, and optional per-month search volume series

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
| `--network <NETWORK>` | [default: GOOGLE_SEARCH] |
| `--include-adult` | — |
| `--include-average-cpc` | Request the averageCpcMicros field in the response (adds historicalMetricsOptions.includeAverageCpc to the request) |

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
| `--provider <PROVIDER>` | Generation provider: heuristic (default) \| disabled [default: heuristic] |
| `--position-target <POSITION_TARGET>` | Where to aim each keyword's suggested bid within its top-of-page range: first-page (low) \| top-of-page (midpoint, default) \| first-position (high) [default: top-of-page] |
| `--intent-file <INTENT_FILE>` | Path to an intent-keywords YAML file. Each present category (commercial, coupon, free, jobs, support, branded, competitors) REPLACES the built-in defaults — edit the lists to add/remove terms. See docs/planning.md |

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
| `--brand <BRAND>` | Brand name to inject into templates (e.g. "Example Co") [default: ""] |
| `--final-url <FINAL_URL>` | Base final URL for the ads (e.g. "https://www.yourbrand.com") [default: ""] |

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
| `--intent <INTENT>` | Which intent-campaign to emit (e.g. commercial). Omit to use the single campaign, or the highest-volume one for a multi-campaign structure |
| `--campaign-name <CAMPAIGN_NAME>` | Override the campaign name (defaults to the structure's campaign name) |
| `--landing-page <LANDING_PAGE>` | Landing page URL — overrides the RSA artifact's final_urls for every ad group |
| `--daily-budget <DAILY_BUDGET>` | Daily budget in USD (e.g. 500). Required; converted to micros |
| `--geo-target-id <GEO_TARGET_ID>` | Positive geo-target-constant ID (numeric). Repeatable. Default 2840 (US) |
| `--location <LOCATION>` | Geo-target NAME (e.g. "United States"). Repeatable; resolved to an ID |
| `--language-id <LANGUAGE_ID>` | Language-constant ID (numeric). Repeatable. Default 1000 (English) |
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
| `--mode <MODE>` | Goal mode: lead-gen \| ecommerce \| brand \| app [default: lead-gen] |
| `--geo-target-id <GEO_TARGET_ID>` | Geo-target-constant ID (numeric). Repeatable. Default 2840 (US) |
| `--location <LOCATION>` | Geo-target NAME (e.g. "United States"). Repeatable; resolved to an ID |
| `--language-id <LANGUAGE_ID>` | Language-constant ID (numeric). Repeatable. Default 1000 (English) |
| `--language <LANGUAGE>` | Language NAME (e.g. "English"). Repeatable; resolved to an ID |
| `--network <NETWORK>` | Network: GOOGLE_SEARCH or GOOGLE_SEARCH_AND_PARTNERS [default: GOOGLE_SEARCH] |
| `--daily-budget <DAILY_BUDGET>` | Total daily budget in USD (split across campaigns by volume share) |
| `--target-cpa <TARGET_CPA>` | Target CPA in USD (sets TARGET_CPA bidding) |
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
| `--location <LOCATION>` | Geo-target NAME (e.g. "United States"). Repeatable; resolved to an ID |
| `--language-id <LANGUAGE_ID>` | Language-constant ID (numeric). Repeatable. Default 1000 (English) |
| `--language <LANGUAGE>` | Language NAME (e.g. "English"). Repeatable; resolved to an ID |
| `--bidding-strategy <BIDDING_STRATEGY>` | Bidding: MAXIMIZE_CONVERSIONS \| MAXIMIZE_CONVERSION_VALUE (PMAX-only) [default: MAXIMIZE_CONVERSIONS] |
| `--target-cpa-micros <TARGET_CPA_MICROS>` | Target CPA micros (MAXIMIZE_CONVERSIONS only) |
| `--target-roas <TARGET_ROAS>` | Target ROAS (MAXIMIZE_CONVERSION_VALUE only, e.g. 3.5) |
| `--negative-keyword <NEGATIVE_KEYWORD>` | Campaign negative keyword as `text:match_type` (PHRASE\|EXACT). Repeatable |
| `--brand-guidelines` | Enable PMAX brand guidelines (campaign-level brand assets). Needs a logo |
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
