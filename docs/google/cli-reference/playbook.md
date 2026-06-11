# `apb-gads playbook`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Agency-style read playbooks: audits, scorecards, and hygiene readouts.

**Surface:** 👁️ Read-only · **64 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`list`](#apb-gads-playbook-list) |  |
| [`weekly-audit`](#apb-gads-playbook-weekly-audit) | Account spend snapshot, top campaigns, search terms, and PMAX presence in one bundle. |
| [`waste-audit`](#apb-gads-playbook-waste-audit) | Identify expensive search terms with poor or zero conversions plus other obvious spend leaks. |
| [`pmax-audit`](#apb-gads-playbook-pmax-audit) | PMAX summary, asset groups, asset-group assets, asset-group performance, plus diagnostics flags (waste, dormant, missing required assets). |
| [`launch-check`](#apb-gads-playbook-launch-check) | Verify presence of campaigns, ad groups, ads, keywords, and PMAX entities before going live. |
| [`creative-refresh`](#apb-gads-playbook-creative-refresh) | Ad inventory + asset usage + top search-term inputs for the next creative iteration. |
| [`account-health`](#apb-gads-playbook-account-health) | Structured health scorecard with status counts, trailing-365-day spend signals, and recommended next actions. |
| [`search-term-cleanup`](#apb-gads-playbook-search-term-cleanup) | Surface negative-keyword candidates from search terms with ad-group context for bulk apply. |
| [`account-structure-audit`](#apb-gads-playbook-account-structure-audit) | Density mapping: ads per ad group, keywords per ad group, ad groups per campaign. |
| [`conversion-tracking-check`](#apb-gads-playbook-conversion-tracking-check) | List configured conversion actions and flag REMOVED, HIDDEN, or unverified ones. |
| [`conversion-tracking-audit`](#apb-gads-playbook-conversion-tracking-audit) | Comprehensive v24 audit: tag health, full conversion-action settings (attribution, value, lookbacks, origin-specific), customer + per-campaign goal mapping, custom variables, value-rule sets, account links, plus actionable findings (severity-coded). |
| [`geo-performance`](#apb-gads-playbook-geo-performance) | Cost and conversions broken out by geographic location to inform geo-targeting changes. |
| [`device-performance`](#apb-gads-playbook-device-performance) | Desktop vs mobile vs tablet performance comparison. |
| [`dayparting-analysis`](#apb-gads-playbook-dayparting-analysis) | Performance by day-of-week and hour-of-day to inform ad scheduling adjustments. |
| [`ad-extension-coverage`](#apb-gads-playbook-ad-extension-coverage) | Per-campaign sitelink, callout, and structured snippet coverage; flag thin extensions. |
| [`budget-pacing`](#apb-gads-playbook-budget-pacing) | Compare daily-budget * days-elapsed against actual cost for the current month per campaign. |
| [`impression-share-loss`](#apb-gads-playbook-impression-share-loss) | Surface impression share lost to budget and lost to rank per campaign. |
| [`quality-score-audit`](#apb-gads-playbook-quality-score-audit) | Distribution of keyword quality scores; flag low-QS keywords with significant spend. |
| [`naming-convention-audit`](#apb-gads-playbook-naming-convention-audit) | Flag campaigns and ad groups whose names don't match common operator patterns. |
| [`campaign-bid-strategy-audit`](#apb-gads-playbook-campaign-bid-strategy-audit) | Mix of bidding strategies in use across campaigns with status and channel context. |
| [`seasonality-overview`](#apb-gads-playbook-seasonality-overview) | 365-day month-over-month spend, conversion, and CPA trend to spot seasonal patterns. |
| [`keyword-match-type-mix`](#apb-gads-playbook-keyword-match-type-mix) | Distribution of BROAD/PHRASE/EXACT keywords; flag campaigns with imbalanced mix. |
| [`duplicate-keywords`](#apb-gads-playbook-duplicate-keywords) | Find keywords with the same text + match-type appearing across multiple ad groups. |
| [`broad-match-conversion-rate`](#apb-gads-playbook-broad-match-conversion-rate) | Identify broad-match keywords with poor conversion rates that should be paused or refined. |
| [`negative-keyword-coverage`](#apb-gads-playbook-negative-keyword-coverage) | Per-ad-group negative-keyword counts; flag groups with zero or very few negatives. |
| [`competitor-keyword-bleed`](#apb-gads-playbook-competitor-keyword-bleed) | Search terms hitting known competitor brand patterns; group by brand for triage. |
| [`ad-rotation-audit`](#apb-gads-playbook-ad-rotation-audit) | Ads per ad group; flag ad groups with fewer than 3 active ads (Google's minimum). |
| [`landing-page-audit`](#apb-gads-playbook-landing-page-audit) | Group ads by final URL; flag URLs with very low traffic or used by only one ad. |
| [`budget-rebalance`](#apb-gads-playbook-budget-rebalance) | Rank campaigns by ROAS and recommend shifting budget from low-ROAS to high-ROAS campaigns. |
| [`anomaly-detection`](#apb-gads-playbook-anomaly-detection) | Week-over-week spend / clicks / conversion change alerts; flags newly-active and newly-dark campaigns. |
| [`cross-network-performance`](#apb-gads-playbook-cross-network-performance) | Split metrics by Search vs Display vs YouTube vs Partner Search networks with per-network ROAS. |
| [`audience-performance`](#apb-gads-playbook-audience-performance) | Per-audience-type aggregation across in-market, remarketing, demographics; surfaces CPA per type. |
| [`pmax-asset-coverage`](#apb-gads-playbook-pmax-asset-coverage) | Per-asset-group field-type completeness scoring with policy-configurable minimums + advisories: missing YOUTUBE_VIDEO (Important), portrait-image recommendation, and audience-signal presence (Important). |
| [`pmax-maturity-gate`](#apb-gads-playbook-pmax-maturity-gate) | Per-PMAX-campaign readiness verdict: maturity (age≥30d OR ≥50 conv), CPA-vs-target performance tier (star/performer/underperformer/problem/starved), learning-band approximation, and PMax-vs-Search ROAS ratio → ready_to_scale / optimize / collect_data / pause_candidate with named blockers. |
| [`pmax-scaling-plan`](#apb-gads-playbook-pmax-scaling-plan) | Per-PMAX-campaign Go/No-Go budget-scaling decision (maturity + profitability vs target + no halt band + no bid+budget stacking checked vs audit.jsonl); on Go recommends a single-step budget increase capped at 50% and emits a budget_update_candidates spec → CampaignBudgetUpdateBulk (review-gated). |
| [`shopping-feed-segmentation-audit`](#apb-gads-playbook-shopping-feed-segmentation-audit) | Shopping feed + PMAX listing-group-filter coverage audit. |
| [`targeting-coverage`](#apb-gads-playbook-targeting-coverage) | Per-campaign targeting-dimension scorecard (geo/language/device/schedule/audience/demographic/placement/topic/brand/content_label) with missing-targeting flags for ENABLED campaigns. |
| [`rsa-asset-performance`](#apb-gads-playbook-rsa-asset-performance) | Per-ad headline/description performance labels (LOW/GOOD/BEST/PENDING) surfacing swap candidates. |
| [`rsa-quality-audit`](#apb-gads-playbook-rsa-quality-audit) | 7-point copy-quality review of every live RSA (8-angle diversity, near-duplicates, keyword coverage, CTA/trust, DKI linter, policy-content) scored alongside ad_strength + approval_status; emits informational rsa_refresh_candidates for orchestrate ad-refresh. |
| [`experiment-readiness`](#apb-gads-playbook-experiment-readiness) | Flag ENABLED campaigns with sufficient baseline (30d conversions + clicks) that aren't already in a Google Ads Experiment. |
| [`policy-compliance`](#apb-gads-playbook-policy-compliance) | Bucket ads by approval_status (DISAPPROVED, APPROVED_LIMITED, etc.) and surface policy_topic_entries for triage. |
| [`smart-bidding-readiness`](#apb-gads-playbook-smart-bidding-readiness) | Per-campaign 0-90 readiness score for moving from manual CPC to tCPA / tROAS / MAXIMIZE_CONVERSIONS. |
| [`match-type-sculpting`](#apb-gads-playbook-match-type-sculpting) | Recommend match-type upgrades (PHRASE→EXACT) or downgrades (BROAD→PHRASE) per keyword based on 90d conv-rate. |
| [`expansion-readiness`](#apb-gads-playbook-expansion-readiness) | Flag campaigns with sustained budget pressure (lost-IS > 10%) AND high ROAS as candidates for budget lift. |
| [`quality-score-root-cause`](#apb-gads-playbook-quality-score-root-cause) | Break low-QS keywords down by which component (expected CTR, ad relevance, landing-page experience) is BELOW_AVERAGE. |
| [`search-term-promotion`](#apb-gads-playbook-search-term-promotion) | Promote high-value search terms to keywords, filtered by metric thresholds (impressions/clicks/cost/conversions/conv-value/ROAS/CPA/top-N), enriched with intent-based match type, historical-CPC suggested bid, and a cluster label. |
| [`competitor-pressure`](#apb-gads-playbook-competitor-pressure) | Flag campaigns where search_rank_lost_impression_share rose ≥ 5pp in current vs prior 30d — proxy for rising auction pressure (domain-level auction insights require Standard API access). |
| [`waste-cluster-audit`](#apb-gads-playbook-waste-cluster-audit) | Token-stem clusters of zero-conversion search queries with combined spend ≥ $200 in the lookback window; emits a mutation-ready negative-keyword spec. |
| [`keyword-prune-audit`](#apb-gads-playbook-keyword-prune-audit) | Rank ENABLED keywords by metrics and flag prune candidates by $ (zero-conversion spend / absolute CPA ceiling), % (CPA/ROAS vs context target), and # (no-traffic click/impression floors); emits a mutation-ready keyword-remove spec. |
| [`conversion-value-gap`](#apb-gads-playbook-conversion-value-gap) | Flag conversion actions marked primary_for_goal in lead/form-fill categories that have no default_value or always_use_default_value=false (breaks Smart Bidding value math). |
| [`campaign-cannibalization`](#apb-gads-playbook-campaign-cannibalization) | Detect normalized queries served by ≥ 2 of our own active campaigns with material spend each, tiered LOW/MEDIUM/HIGH/CRITICAL by CPA gap and bid-strategy divergence. |
| [`qs-cpc-tax`](#apb-gads-playbook-qs-cpc-tax) | Quantify the CPC inflation paid for QS<5 keywords via counterfactual to a high-QS peer cohort (ad-group/match/network → campaign/match → account → heuristic fallback) with confidence labels. |
| [`bid-strategy-mismatch`](#apb-gads-playbook-bid-strategy-mismatch) | Detect campaigns whose current bid strategy is throttling scale (manual_cpc_with_strong_conversions, tcpa_budget_throttled, troas_without_value_tracking, etc.) with per-rule evidence blocks. |
| [`audience-burnout-detection`](#apb-gads-playbook-audience-burnout-detection) | Detect audience targets where engagement is decaying current-vs-prior 30d (CTR/CVR drop, CPA rise) across ad_group_audience_view. |
| [`geo-bid-drift-audit`](#apb-gads-playbook-geo-bid-drift-audit) | Detect geos (ZIP / state / DMA) where CPA has drifted materially current-vs-prior 30d on geographic_view; surfaces hidden spend pockets weighted by cost share. |
| [`landing-page-intent-drift-audit`](#apb-gads-playbook-landing-page-intent-drift-audit) | Surface landing pages where Google's landing_page_view quality signals degraded — mobile-friendliness, post_click_quality_score — and pair with the keywords pointing at them. |
| [`pmax-segmentation-audit`](#apb-gads-playbook-pmax-segmentation-audit) | Per-PMAX-campaign should-split / too-many-asset-groups recommendations based on spend, conversion volume, and asset-group count. |
| [`brand-exclusion-audit`](#apb-gads-playbook-brand-exclusion-audit) | Audit account-wide customer_negative_criterion coverage against competitor-brand patterns from `competitor-keyword-bleed`. |
| [`campaign-consolidation-audit`](#apb-gads-playbook-campaign-consolidation-audit) | Inverse of pmax-segmentation-audit: flag micro-campaigns (low spend, low conversion volume) sharing channel + bid-strategy that should be merged. |
| [`sandbox-campaign-audit`](#apb-gads-playbook-sandbox-campaign-audit) | Enforce small-bets hygiene: sandbox / experiment campaigns must not share budgets, must not use portfolio bidding, and must stay below the operator-set account-spend share. |
| [`roas-nudge-recommendation`](#apb-gads-playbook-roas-nudge-recommendation) | Per-campaign tROAS / tCPA micro-adjustment recommendations bounded by ±max_nudge_pct (default 10%) based on 14d actual-vs-target performance. |
| [`conversion-value-tier-audit`](#apb-gads-playbook-conversion-value-tier-audit) | Extends conversion-value-gap with value-quality scoring: placeholder-pattern, single-value-pattern, high-variance-pattern across conversion-action categories. |
| [`placement-leakage-audit`](#apb-gads-playbook-placement-leakage-audit) | Surface display + video placements (detail_placement_view) that consumed PMAX/DISPLAY/VIDEO budget with zero conversions. |
| [`pmax-url-exclusion-audit`](#apb-gads-playbook-pmax-url-exclusion-audit) | Substitute for v24-removed url_expansion_opt_out: per (PMAX/DISPLAY campaign, common-waste pattern) coverage check against campaign_criterion WEBPAGE negatives (/blog, /careers, /privacy, etc.). |

---

<a id="apb-gads-playbook-list"></a>
### `apb-gads playbook list`

**Usage**

```
Usage: apb-gads playbook list [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-weekly-audit"></a>
### `apb-gads playbook weekly-audit`

Account spend snapshot, top campaigns, search terms, and PMAX presence in one bundle. Trailing 365-day window by default (the name is a cadence, not the window); override with --lookback-days.

*Section `core_diagnostics` · default lookback 365d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook weekly-audit [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-waste-audit"></a>
### `apb-gads playbook waste-audit`

Identify expensive search terms with poor or zero conversions plus other obvious spend leaks. Trailing 365-day window by default; override with --lookback-days.

*Section `core_diagnostics` · default lookback 365d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook waste-audit [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-pmax-audit"></a>
### `apb-gads playbook pmax-audit`

PMAX summary, asset groups, asset-group assets, asset-group performance, plus diagnostics flags (waste, dormant, missing required assets).

*Section `performance_max` · default lookback 365d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook pmax-audit [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-launch-check"></a>
### `apb-gads playbook launch-check`

Verify presence of campaigns, ad groups, ads, keywords, and PMAX entities before going live.

*Section `core_diagnostics` · default lookback 7d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook launch-check [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-creative-refresh"></a>
### `apb-gads playbook creative-refresh`

Ad inventory + asset usage + top search-term inputs for the next creative iteration.

*Section `creative` · default lookback 365d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook creative-refresh [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-account-health"></a>
### `apb-gads playbook account-health`

Structured health scorecard with status counts, trailing-365-day spend signals, and recommended next actions. Override the window with --lookback-days.

*Section `core_diagnostics` · default lookback 365d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook account-health [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-search-term-cleanup"></a>
### `apb-gads playbook search-term-cleanup`

Surface negative-keyword candidates from search terms with ad-group context for bulk apply.

*Section `data_quality_hygiene` · default lookback 365d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook search-term-cleanup [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 25] |

<a id="apb-gads-playbook-account-structure-audit"></a>
### `apb-gads playbook account-structure-audit`

Density mapping: ads per ad group, keywords per ad group, ad groups per campaign.

*Section `structural` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook account-structure-audit [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-conversion-tracking-check"></a>
### `apb-gads playbook conversion-tracking-check`

List configured conversion actions and flag REMOVED, HIDDEN, or unverified ones.

*Section `data_quality_hygiene` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook conversion-tracking-check [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-conversion-tracking-audit"></a>
### `apb-gads playbook conversion-tracking-audit`

Comprehensive v24 audit: tag health, full conversion-action settings (attribution, value, lookbacks, origin-specific), customer + per-campaign goal mapping, custom variables, value-rule sets, account links, plus actionable findings (severity-coded).

*Section `data_quality_hygiene` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook conversion-tracking-audit [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-geo-performance"></a>
### `apb-gads playbook geo-performance`

Cost and conversions broken out by geographic location to inform geo-targeting changes.

*Section `growth_and_scale` · default lookback 90d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook geo-performance [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 25] |

<a id="apb-gads-playbook-device-performance"></a>
### `apb-gads playbook device-performance`

Desktop vs mobile vs tablet performance comparison.

*Section `growth_and_scale` · default lookback 90d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook device-performance [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-dayparting-analysis"></a>
### `apb-gads playbook dayparting-analysis`

Performance by day-of-week and hour-of-day to inform ad scheduling adjustments.

*Section `growth_and_scale` · default lookback 90d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook dayparting-analysis [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-ad-extension-coverage"></a>
### `apb-gads playbook ad-extension-coverage`

Per-campaign sitelink, callout, and structured snippet coverage; flag thin extensions.

*Section `structural` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook ad-extension-coverage [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-budget-pacing"></a>
### `apb-gads playbook budget-pacing`

Compare daily-budget * days-elapsed against actual cost for the current month per campaign.

*Section `core_diagnostics` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook budget-pacing [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-impression-share-loss"></a>
### `apb-gads playbook impression-share-loss`

Surface impression share lost to budget and lost to rank per campaign.

*Section `core_diagnostics` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook impression-share-loss [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-quality-score-audit"></a>
### `apb-gads playbook quality-score-audit`

Distribution of keyword quality scores; flag low-QS keywords with significant spend.

*Section `data_quality_hygiene` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook quality-score-audit [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-naming-convention-audit"></a>
### `apb-gads playbook naming-convention-audit`

Flag campaigns and ad groups whose names don't match common operator patterns.

*Section `data_quality_hygiene` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook naming-convention-audit [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-campaign-bid-strategy-audit"></a>
### `apb-gads playbook campaign-bid-strategy-audit`

Mix of bidding strategies in use across campaigns with status and channel context.

*Section `structural` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook campaign-bid-strategy-audit [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-seasonality-overview"></a>
### `apb-gads playbook seasonality-overview`

365-day month-over-month spend, conversion, and CPA trend to spot seasonal patterns.

*Section `growth_and_scale` · default lookback 365d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook seasonality-overview [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-keyword-match-type-mix"></a>
### `apb-gads playbook keyword-match-type-mix`

Distribution of BROAD/PHRASE/EXACT keywords; flag campaigns with imbalanced mix.

*Section `structural` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook keyword-match-type-mix [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-duplicate-keywords"></a>
### `apb-gads playbook duplicate-keywords`

Find keywords with the same text + match-type appearing across multiple ad groups.

*Section `data_quality_hygiene` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook duplicate-keywords [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-broad-match-conversion-rate"></a>
### `apb-gads playbook broad-match-conversion-rate`

Identify broad-match keywords with poor conversion rates that should be paused or refined.

*Section `growth_and_scale` · default lookback 90d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook broad-match-conversion-rate [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-negative-keyword-coverage"></a>
### `apb-gads playbook negative-keyword-coverage`

Per-ad-group negative-keyword counts; flag groups with zero or very few negatives.

*Section `data_quality_hygiene` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook negative-keyword-coverage [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-competitor-keyword-bleed"></a>
### `apb-gads playbook competitor-keyword-bleed`

Search terms hitting known competitor brand patterns; group by brand for triage.

*Section `data_quality_hygiene` · default lookback 365d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook competitor-keyword-bleed [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 25] |

<a id="apb-gads-playbook-ad-rotation-audit"></a>
### `apb-gads playbook ad-rotation-audit`

Ads per ad group; flag ad groups with fewer than 3 active ads (Google's minimum).

*Section `structural` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook ad-rotation-audit [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-landing-page-audit"></a>
### `apb-gads playbook landing-page-audit`

Group ads by final URL; flag URLs with very low traffic or used by only one ad.

*Section `data_quality_hygiene` · default lookback 90d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook landing-page-audit [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-budget-rebalance"></a>
### `apb-gads playbook budget-rebalance`

Rank campaigns by ROAS and recommend shifting budget from low-ROAS to high-ROAS campaigns.

*Section `growth_and_scale` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook budget-rebalance [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-anomaly-detection"></a>
### `apb-gads playbook anomaly-detection`

Week-over-week spend / clicks / conversion change alerts; flags newly-active and newly-dark campaigns.

*Section `core_diagnostics` · default lookback 14d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook anomaly-detection [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-cross-network-performance"></a>
### `apb-gads playbook cross-network-performance`

Split metrics by Search vs Display vs YouTube vs Partner Search networks with per-network ROAS.

*Section `growth_and_scale` · default lookback 90d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook cross-network-performance [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-audience-performance"></a>
### `apb-gads playbook audience-performance`

Per-audience-type aggregation across in-market, remarketing, demographics; surfaces CPA per type.

*Section `growth_and_scale` · default lookback 90d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook audience-performance [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-pmax-asset-coverage"></a>
### `apb-gads playbook pmax-asset-coverage`

Per-asset-group field-type completeness scoring with policy-configurable minimums + advisories: missing YOUTUBE_VIDEO (Important), portrait-image recommendation, and audience-signal presence (Important). underbuilt/severe_underbuilt flags.

*Section `performance_max` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook pmax-asset-coverage [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-pmax-maturity-gate"></a>
### `apb-gads playbook pmax-maturity-gate`

Per-PMAX-campaign readiness verdict: maturity (age≥30d OR ≥50 conv), CPA-vs-target performance tier (star/performer/underperformer/problem/starved), learning-band approximation, and PMax-vs-Search ROAS ratio → ready_to_scale / optimize / collect_data / pause_candidate with named blockers. Read-only; targets resolve context-first.

*Section `performance_max` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook pmax-maturity-gate [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--target-cpa-micros <TARGET_CPA_MICROS>` | Override the context/account target CPA (micros) for the performance tier. |
| `--target-roas <TARGET_ROAS>` | Override the context/account target ROAS (ratio, e.g. 3.0). |
| `--aov-micros <AOV_MICROS>` | Average order value (micros) for the pause exception. Default: computed from account conv-value/conversions. |

<a id="apb-gads-playbook-pmax-scaling-plan"></a>
### `apb-gads playbook pmax-scaling-plan`

Per-PMAX-campaign Go/No-Go budget-scaling decision (maturity + profitability vs target + no halt band + no bid+budget stacking checked vs audit.jsonl); on Go recommends a single-step budget increase capped at 50% and emits a budget_update_candidates spec → CampaignBudgetUpdateBulk (review-gated). Targets context-first.

*Section `performance_max` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook pmax-scaling-plan [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--target-cpa-micros <TARGET_CPA_MICROS>` | Override the context/account target CPA (micros). |
| `--target-roas <TARGET_ROAS>` | Override the context/account target ROAS (ratio, e.g. 4.0). |
| `--increment-pct <INCREMENT_PCT>` | Single-step budget increase percent for Go campaigns. Default 20; capped at 50. |
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write a budget_update_candidates spec (→ CampaignBudgetUpdateBulk, review-gated). |

<a id="apb-gads-playbook-shopping-feed-segmentation-audit"></a>
### `apb-gads playbook shopping-feed-segmentation-audit`

Shopping feed + PMAX listing-group-filter coverage audit. Enumerates the Merchant Center feed by brand/availability/status, counts filter coverage per asset group, and flags anti-patterns (only-root filter, NOT_ELIGIBLE inventory, brand diversity without filter coverage)

*Section `performance_max` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook shopping-feed-segmentation-audit [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-targeting-coverage"></a>
### `apb-gads playbook targeting-coverage`

Per-campaign targeting-dimension scorecard (geo/language/device/schedule/audience/demographic/placement/topic/brand/content_label) with missing-targeting flags for ENABLED campaigns.

*Section `structural` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook targeting-coverage [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-rsa-asset-performance"></a>
### `apb-gads playbook rsa-asset-performance`

Per-ad headline/description performance labels (LOW/GOOD/BEST/PENDING) surfacing swap candidates. Drives RSA iteration and message testing.

*Section `creative` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook rsa-asset-performance [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write an informational swap-candidate list |

<a id="apb-gads-playbook-rsa-quality-audit"></a>
### `apb-gads playbook rsa-quality-audit`

7-point copy-quality review of every live RSA (8-angle diversity, near-duplicates, keyword coverage, CTA/trust, DKI linter, policy-content) scored alongside ad_strength + approval_status; emits informational rsa_refresh_candidates for orchestrate ad-refresh.

*Section `creative` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook rsa-quality-audit [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write an informational rsa_refresh_candidates spec (for orchestrate ad-refresh) |

<a id="apb-gads-playbook-experiment-readiness"></a>
### `apb-gads playbook experiment-readiness`

Flag ENABLED campaigns with sufficient baseline (30d conversions + clicks) that aren't already in a Google Ads Experiment.

*Section `structural` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook experiment-readiness [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-playbook-policy-compliance"></a>
### `apb-gads playbook policy-compliance`

Bucket ads by approval_status (DISAPPROVED, APPROVED_LIMITED, etc.) and surface policy_topic_entries for triage.

*Section `data_quality_hygiene` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook policy-compliance [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write an informational ad-fix list |

<a id="apb-gads-playbook-smart-bidding-readiness"></a>
### `apb-gads playbook smart-bidding-readiness`

Per-campaign 0-90 readiness score for moving from manual CPC to tCPA / tROAS / MAXIMIZE_CONVERSIONS.

*Section `structural` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook smart-bidding-readiness [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write a campaign-update-bidding-strategy-bulk-compatible spec |

<a id="apb-gads-playbook-match-type-sculpting"></a>
### `apb-gads playbook match-type-sculpting`

Recommend match-type upgrades (PHRASE→EXACT) or downgrades (BROAD→PHRASE) per keyword based on 90d conv-rate.

*Section `structural` · default lookback 90d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook match-type-sculpting [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write a keyword-update-match-type-bulk-compatible spec |

<a id="apb-gads-playbook-expansion-readiness"></a>
### `apb-gads playbook expansion-readiness`

Flag campaigns with sustained budget pressure (lost-IS > 10%) AND high ROAS as candidates for budget lift.

*Section `growth_and_scale` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook expansion-readiness [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--min-roas <MIN_ROAS>` | [default: 3] |
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write a campaign-budget-update-bulk-compatible spec |

<a id="apb-gads-playbook-quality-score-root-cause"></a>
### `apb-gads playbook quality-score-root-cause`

Break low-QS keywords down by which component (expected CTR, ad relevance, landing-page experience) is BELOW_AVERAGE.

*Section `data_quality_hygiene` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook quality-score-root-cause [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write an informational remediation list |

<a id="apb-gads-playbook-search-term-promotion"></a>
### `apb-gads playbook search-term-promotion`

Promote high-value search terms to keywords, filtered by metric thresholds (impressions/clicks/cost/conversions/conv-value/ROAS/CPA/top-N), enriched with intent-based match type, historical-CPC suggested bid, and a cluster label. Emits a keyword_promotion_candidates spec → KeywordAddBulk (also consumable by keyword-add-bulk --from-file).

*Section `growth_and_scale` · default lookback 90d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook search-term-promotion [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--min-impressions <MIN_IMPRESSIONS>` | Only promote terms with ≥ this many impressions. Disabled when unset. |
| `--min-clicks <MIN_CLICKS>` | Only promote terms with ≥ this many clicks. Disabled when unset. |
| `--min-cost-micros <MIN_COST_MICROS>` | Only promote terms with ≥ this spend (micros). Disabled when unset. |
| `--min-conversions <MIN_CONVERSIONS>` | Only promote terms with ≥ this many conversions. Default 1. Overrides customer policy. |
| `--min-conv-value-micros <MIN_CONV_VALUE_MICROS>` | Only promote terms with ≥ this conversion value (micros). Disabled when unset. |
| `--min-roas <MIN_ROAS>` | Only promote terms with ROAS ≥ this (conv_value / cost). Disabled when unset. |
| `--max-cpa-micros <MAX_CPA_MICROS>` | Only promote terms with CPA ≤ this (micros). Disabled when unset. |
| `--top-n <TOP_N>` | Cap the number of promoted candidates (highest-converting first). Disabled when unset. |
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write a keyword-add-bulk-compatible spec (spec_type keyword_promotion_candidates) |

<a id="apb-gads-playbook-competitor-pressure"></a>
### `apb-gads playbook competitor-pressure`

Flag campaigns where search_rank_lost_impression_share rose ≥ 5pp in current vs prior 30d — proxy for rising auction pressure (domain-level auction insights require Standard API access).

*Section `growth_and_scale` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook competitor-pressure [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write an informational bid-response list |

<a id="apb-gads-playbook-waste-cluster-audit"></a>
### `apb-gads playbook waste-cluster-audit`

Token-stem clusters of zero-conversion search queries with combined spend ≥ $200 in the lookback window; emits a mutation-ready negative-keyword spec.

*Section `data_quality_hygiene` · default lookback 90d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook waste-cluster-audit [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--min-cluster-cost-micros <MIN_CLUSTER_COST_MICROS>` | Minimum combined cluster cost (micros) to qualify as wasted spend. Default 200000000 ($200). Overrides customer policy. |
| `--match-type-token-cutoff <MATCH_TYPE_TOKEN_CUTOFF>` | Suggested negatives with ≤ this many tokens become EXACT, otherwise PHRASE. Default 2. Overrides customer policy. |
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write a mutation-ready negative-keyword spec |

<a id="apb-gads-playbook-keyword-prune-audit"></a>
### `apb-gads playbook keyword-prune-audit`

Rank ENABLED keywords by metrics and flag prune candidates by $ (zero-conversion spend / absolute CPA ceiling), % (CPA/ROAS vs context target), and # (no-traffic click/impression floors); emits a mutation-ready keyword-remove spec.

*Section `data_quality_hygiene` · default lookback 90d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook keyword-prune-audit [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--min-cost-micros <MIN_COST_MICROS>` | $ mode: spend floor (micros) for a keyword to qualify as wasted spend. Default 50000000 ($50). Overrides customer policy. |
| `--max-conversions <MAX_CONVERSIONS>` | $ mode: flag a spender with conversions ≤ this. Default 0 (zero-conversion). Overrides customer policy. |
| `--max-cpa-micros <MAX_CPA_MICROS>` | $ mode: absolute CPA ceiling (micros) — conv>0 AND CPA > this → prune. Disabled when unset. |
| `--max-cpa-pct <MAX_CPA_PCT>` | % mode: flag a spender whose CPA exceeds this percent of target CPA (e.g. 130). Needs a target. Disabled when unset. |
| `--max-roas-pct <MAX_ROAS_PCT>` | % mode: flag a spender whose ROAS is below this percent of target ROAS (e.g. 70). Needs a target. Disabled when unset. |
| `--min-clicks <MIN_CLICKS>` | # mode: flag a zero-conversion keyword with clicks below this floor. Disabled when unset. |
| `--min-impressions <MIN_IMPRESSIONS>` | # mode: flag a zero-conversion keyword with impressions below this floor. Disabled when unset. |
| `--bottom-n <BOTTOM_N>` | # mode: also flag the worst N spenders by CPA (conv>0). Disabled when unset. |
| `--target-cpa-micros <TARGET_CPA_MICROS>` | Override the context target CPA (micros) used by % mode. |
| `--target-roas <TARGET_ROAS>` | Override the context target ROAS (ratio, e.g. 3.0) used by % mode. |
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write a mutation-ready keyword-remove spec (spec_type keyword_prune_candidates) |

<a id="apb-gads-playbook-conversion-value-gap"></a>
### `apb-gads playbook conversion-value-gap`

Flag conversion actions marked primary_for_goal in lead/form-fill categories that have no default_value or always_use_default_value=false (breaks Smart Bidding value math).

*Section `data_quality_hygiene` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook conversion-value-gap [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write an informational conversion-tracking-gap review list |

<a id="apb-gads-playbook-campaign-cannibalization"></a>
### `apb-gads playbook campaign-cannibalization`

Detect normalized queries served by ≥ 2 of our own active campaigns with material spend each, tiered LOW/MEDIUM/HIGH/CRITICAL by CPA gap and bid-strategy divergence.

*Section `structural` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook campaign-cannibalization [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--min-clicks-per-campaign <MIN_CLICKS_PER_CAMPAIGN>` | MEDIUM tier: minimum clicks per campaign. Default 10. Overrides customer policy. |
| `--min-spend-per-campaign <MIN_SPEND_PER_CAMPAIGN>` | MEDIUM tier: minimum spend per campaign (micros). Default 10000000 ($10). Overrides customer policy. |
| `--min-combined-spend <MIN_COMBINED_SPEND>` | MEDIUM tier: minimum combined spend (micros). Default 50000000 ($50). Overrides customer policy. |
| `--cpa-ratio-critical <CPA_RATIO_CRITICAL>` | CRITICAL tier: worst/best CPA ratio threshold. Default 1.5. Overrides customer policy. |
| `--critical-combined-spend <CRITICAL_COMBINED_SPEND>` | CRITICAL tier: minimum combined spend (micros). Default 100000000 ($100). Overrides customer policy. |
| `--high-each-clicks-min <HIGH_EACH_CLICKS_MIN>` | HIGH tier: minimum clicks per campaign. Default 10. Overrides customer policy. |
| `--high-each-spend <HIGH_EACH_SPEND>` | HIGH tier: minimum spend per campaign (micros). Default 25000000 ($25). Overrides customer policy. |
| `--high-combined-spend <HIGH_COMBINED_SPEND>` | HIGH tier: minimum combined spend (micros). Default 100000000 ($100). Overrides customer policy. |
| `--low-combined-spend <LOW_COMBINED_SPEND>` | LOW tier: minimum combined spend (micros). Default 25000000 ($25). Overrides customer policy. |
| `--severity-mode <SEVERITY_MODE>` | Severity gate: standard \| strict \| diagnostic [default: standard] |
| `--include-brand` | Include brand-token queries in the analysis |
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write an informational query-cannibalization review list |

<a id="apb-gads-playbook-qs-cpc-tax"></a>
### `apb-gads playbook qs-cpc-tax`

Quantify the CPC inflation paid for QS<5 keywords via counterfactual to a high-QS peer cohort (ad-group/match/network → campaign/match → account → heuristic fallback) with confidence labels.

*Section `data_quality_hygiene` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook qs-cpc-tax [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--low-qs-min <LOW_QS_MIN>` | Low-QS range inclusive lower bound. Default 1. Overrides customer policy. |
| `--low-qs-max <LOW_QS_MAX>` | Low-QS range inclusive upper bound (keywords ≤ this value treated as low-QS). Default 4. Overrides customer policy. |
| `--high-qs-min <HIGH_QS_MIN>` | High-QS cohort threshold (keywords ≥ this value form the peer cohort). Default 7. Overrides customer policy. |
| `--cohort-min-size <COHORT_MIN_SIZE>` | Minimum cohort size (keywords with non-zero clicks) at each hierarchical level. Default 3. Overrides customer policy. |
| `--heuristic-multiplier <HEURISTIC_MULTIPLIER>` | L4 fallback heuristic multiplier in (target_qs − qs) × multiplier × cost. Default 0.167. Overrides customer policy. |
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write an informational low-QS keyword review list |

<a id="apb-gads-playbook-bid-strategy-mismatch"></a>
### `apb-gads playbook bid-strategy-mismatch`

Detect campaigns whose current bid strategy is throttling scale (manual_cpc_with_strong_conversions, tcpa_budget_throttled, troas_without_value_tracking, etc.) with per-rule evidence blocks.

*Section `structural` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook bid-strategy-mismatch [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--manual-cpc-conv-threshold <MANUAL_CPC_CONV_THRESHOLD>` | manual_cpc_with_strong_conversions rule: conv threshold. Default 30. Overrides customer policy. |
| `--max-clicks-conv-threshold <MAX_CLICKS_CONV_THRESHOLD>` | max_clicks_with_strong_conversions rule: conv threshold. Default 20. Overrides customer policy. |
| `--tcpa-budget-lost-is-threshold <TCPA_BUDGET_LOST_IS_THRESHOLD>` | tcpa_budget_throttled rule: search_budget_lost_impression_share floor. Default 0.20. Overrides customer policy. |
| `--tcpa-budget-conv-threshold <TCPA_BUDGET_CONV_THRESHOLD>` | tcpa_budget_throttled rule: conv floor. Default 10. Overrides customer policy. |
| `--tcpa-target-too-low-median-multiplier <TCPA_TARGET_TOO_LOW_MEDIAN_MULTIPLIER>` | tcpa_target_too_low rule: target_cpa < median(actual_cpa) × this. Default 0.6. Overrides customer policy. |
| `--tcpa-rank-lost-is-threshold <TCPA_RANK_LOST_IS_THRESHOLD>` | tcpa_target_too_low rule: search_rank_lost_impression_share floor. Default 0.30. Overrides customer policy. |
| `--maximize-conversions-conv-threshold <MAXIMIZE_CONVERSIONS_CONV_THRESHOLD>` | maximize_conversions_without_target_cpa rule: conv threshold. Default 100. Overrides customer policy. |
| `--learning-stuck-days <LEARNING_STUCK_DAYS>` | learning_stuck rule: campaign-age cutoff in days. Default 14. Overrides customer policy. |
| `--learning-stuck-conv-max <LEARNING_STUCK_CONV_MAX>` | learning_stuck rule: conv-count ceiling. Default 5. Overrides customer policy. |
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write an informational bid-strategy-mismatch review list |

<a id="apb-gads-playbook-audience-burnout-detection"></a>
### `apb-gads playbook audience-burnout-detection`

Detect audience targets where engagement is decaying current-vs-prior 30d (CTR/CVR drop, CPA rise) across ad_group_audience_view. Tiered HIGH/MEDIUM by per-metric threshold crossings.

*Section `growth_and_scale` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook audience-burnout-detection [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--burnout-ctr-drop-pp-high <BURNOUT_CTR_DROP_PP_HIGH>` | HIGH tier: CTR percentage-point drop threshold (current vs prior period). Default 0.5. Overrides customer policy. |
| `--burnout-cvr-drop-pp-high <BURNOUT_CVR_DROP_PP_HIGH>` | HIGH tier: CVR percentage-point drop threshold. Default 0.3. Overrides customer policy. |
| `--burnout-cpa-rise-pct-high <BURNOUT_CPA_RISE_PCT_HIGH>` | HIGH tier: CPA percent-rise threshold. Default 25.0. Overrides customer policy. |
| `--burnout-min-clicks <BURNOUT_MIN_CLICKS>` | Skip audiences with fewer clicks than this in either period. Default 50. Overrides customer policy. |

<a id="apb-gads-playbook-geo-bid-drift-audit"></a>
### `apb-gads playbook geo-bid-drift-audit`

Detect geos (ZIP / state / DMA) where CPA has drifted materially current-vs-prior 30d on geographic_view; surfaces hidden spend pockets weighted by cost share.

*Section `data_quality_hygiene` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook geo-bid-drift-audit [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--geo-cpa-drift-pct-high <GEO_CPA_DRIFT_PCT_HIGH>` | HIGH tier: CPA percent-drift threshold. Default 50.0. Overrides customer policy. |
| `--geo-cpa-drift-pct-medium <GEO_CPA_DRIFT_PCT_MEDIUM>` | MEDIUM tier: CPA percent-drift threshold. Default 25.0. Overrides customer policy. |
| `--geo-min-cost-share-pct <GEO_MIN_COST_SHARE_PCT>` | HIGH tier: geo's share of campaign spend threshold. Default 2.0. Overrides customer policy. |
| `--geo-min-clicks <GEO_MIN_CLICKS>` | Skip geos with fewer clicks than this in either period. Default 30. Overrides customer policy. |

<a id="apb-gads-playbook-landing-page-intent-drift-audit"></a>
### `apb-gads playbook landing-page-intent-drift-audit`

Surface landing pages where Google's landing_page_view quality signals degraded — mobile-friendliness, post_click_quality_score — and pair with the keywords pointing at them.

*Section `data_quality_hygiene` · default lookback 90d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook landing-page-intent-drift-audit [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--lp-below-avg-keyword-share-pct <LP_BELOW_AVG_KEYWORD_SHARE_PCT>` | Flag URL when this share or more of its keywords show post_click_quality_score=BELOW_AVERAGE. Default 50.0. Overrides customer policy. |
| `--lp-min-mobile-friendly-pct <LP_MIN_MOBILE_FRIENDLY_PCT>` | Flag URL when mobile_friendly_clicks_percentage drops below this. Default 80.0. Overrides customer policy. |
| `--lp-min-clicks <LP_MIN_CLICKS>` | Skip URLs with fewer total clicks than this in the lookback. Default 100. Overrides customer policy. |

<a id="apb-gads-playbook-pmax-segmentation-audit"></a>
### `apb-gads playbook pmax-segmentation-audit`

Per-PMAX-campaign should-split / too-many-asset-groups recommendations based on spend, conversion volume, and asset-group count.

*Section `performance_max` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook pmax-segmentation-audit [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--split-min-spend-micros <SPLIT_MIN_SPEND_MICROS>` | SHOULD_SPLIT (HIGH): minimum 30d spend (micros). Default 5_000_000_000 ($5k). Overrides customer policy. |
| `--split-min-conversions <SPLIT_MIN_CONVERSIONS>` | SHOULD_SPLIT (HIGH): minimum 30d conversions. Default 50. Overrides customer policy. |
| `--asset-groups-per-campaign-max <ASSET_GROUPS_PER_CAMPAIGN_MAX>` | TOO_MANY_GROUPS (MEDIUM): asset-group count ceiling. Default 7. Overrides customer policy. |
| `--asset-groups-per-campaign-min <ASSET_GROUPS_PER_CAMPAIGN_MIN>` | Floor for asset-group counts (drives segmentation suggestions). Default 3. Overrides customer policy. |

<a id="apb-gads-playbook-brand-exclusion-audit"></a>
### `apb-gads playbook brand-exclusion-audit`

Audit account-wide customer_negative_criterion coverage against competitor-brand patterns from `competitor-keyword-bleed`. Emits a mutation-ready customer-negative-criterion-add spec for missing exclusions.

*Section `structural` · default lookback 90d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook brand-exclusion-audit [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--bleed-min-cost-micros <BLEED_MIN_COST_MICROS>` | Only emit negatives for competitor-bleed terms above this cost (micros). Default 10_000_000 ($10). Overrides customer policy. |
| `--brand-token-list <BRAND_TOKEN_LIST>` | Optional path to a one-token-per-line brand list (overrides the hardcoded competitor list). Overrides customer policy. |
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write a mutation-ready customer_negative_criterion_candidates spec (consumer mutation `customer-negative-criterion-add-bulk` ships separately). |

<a id="apb-gads-playbook-campaign-consolidation-audit"></a>
### `apb-gads playbook campaign-consolidation-audit`

Inverse of pmax-segmentation-audit: flag micro-campaigns (low spend, low conversion volume) sharing channel + bid-strategy that should be merged.

*Section `structural` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook campaign-consolidation-audit [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--micro-max-spend-micros <MICRO_MAX_SPEND_MICROS>` | Micro-campaign cost ceiling (micros). Default 500_000_000 ($500). Overrides customer policy. |
| `--micro-max-conversions <MICRO_MAX_CONVERSIONS>` | Micro-campaign conversion ceiling. Default 5. Overrides customer policy. |
| `--min-micros-in-cluster <MIN_MICROS_IN_CLUSTER>` | Minimum micro-campaigns to form a consolidation candidate. Default 2. Overrides customer policy. |

<a id="apb-gads-playbook-sandbox-campaign-audit"></a>
### `apb-gads playbook sandbox-campaign-audit`

Enforce small-bets hygiene: sandbox / experiment campaigns must not share budgets, must not use portfolio bidding, and must stay below the operator-set account-spend share.

*Section `structural` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook sandbox-campaign-audit [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--sandbox-tag-list <SANDBOX_TAG_LIST>` | Comma-separated case-insensitive substrings flagging sandbox candidates. Default 'sandbox,test,experiment,pilot'. Overrides customer policy. |
| `--sandbox-budget-share-pct-max <SANDBOX_BUDGET_SHARE_PCT_MAX>` | Maximum permitted sandbox-spend share of account spend (percent). Default 10.0. Overrides customer policy. |

<a id="apb-gads-playbook-roas-nudge-recommendation"></a>
### `apb-gads playbook roas-nudge-recommendation`

Per-campaign tROAS / tCPA micro-adjustment recommendations bounded by ±max_nudge_pct (default 10%) based on 14d actual-vs-target performance. Big changes reset learning; small nudges don't.

*Section `growth_and_scale` · default lookback 14d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook roas-nudge-recommendation [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--max-nudge-pct <MAX_NUDGE_PCT>` | Maximum per-recommendation target adjustment in percent (clamped ±). Default 10.0. Overrides customer policy. |
| `--min-conversions-for-nudge <MIN_CONVERSIONS_FOR_NUDGE>` | Skip campaigns with fewer 14d conversions than this (too noisy). Default 15. Overrides customer policy. |
| `--target-roas-tolerance-pct <TARGET_ROAS_TOLERANCE_PCT>` | Don't nudge if actual within ±this percent of current target. Default 5.0. Overrides customer policy. |

<a id="apb-gads-playbook-conversion-value-tier-audit"></a>
### `apb-gads playbook conversion-value-tier-audit`

Extends conversion-value-gap with value-quality scoring: placeholder-pattern, single-value-pattern, high-variance-pattern across conversion-action categories.

*Section `data_quality_hygiene` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook conversion-value-tier-audit [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--tier-placeholder-count <TIER_PLACEHOLDER_COUNT>` | Placeholder-pattern threshold: this many actions sharing a placeholder default_value flag the category. Default 2. Overrides customer policy. |
| `--tier-high-variance-ratio <TIER_HIGH_VARIANCE_RATIO>` | High-variance threshold: max/min ratio of default_value within a category. Default 100.0. Overrides customer policy. |
| `--tier-placeholder-values <TIER_PLACEHOLDER_VALUES>` | Comma-separated f64 values treated as obvious placeholders. Default '0.0,1.0'. Overrides customer policy. |

<a id="apb-gads-playbook-placement-leakage-audit"></a>
### `apb-gads playbook placement-leakage-audit`

Surface display + video placements (detail_placement_view) that consumed PMAX/DISPLAY/VIDEO budget with zero conversions. Mutation-ready for display exclusions; YouTube placements informational only (Google auto-targeting re-adds excluded channels).

*Section `performance_max` · default lookback 30d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook placement-leakage-audit [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--leakage-min-cost-micros <LEAKAGE_MIN_COST_MICROS>` | Flag placements with at least this cost and zero conversions. Default 25_000_000 ($25). Overrides customer policy. |
| `--leakage-include-channels <LEAKAGE_INCLUDE_CHANNELS>` | Comma-separated channel allowlist. Default 'PERFORMANCE_MAX,DISPLAY,VIDEO'. Overrides customer policy. |
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write a mutation-ready placement_exclusion_candidates spec (display-side placements only; YouTube excluded per Google's auto-targeting behavior). |

<a id="apb-gads-playbook-pmax-url-exclusion-audit"></a>
### `apb-gads playbook pmax-url-exclusion-audit`

Substitute for v24-removed url_expansion_opt_out: per (PMAX/DISPLAY campaign, common-waste pattern) coverage check against campaign_criterion WEBPAGE negatives (/blog, /careers, /privacy, etc.). Mutation-ready spec.

*Section `structural` · default lookback 90d · status `implemented`*

**Usage**

```
Usage: apb-gads playbook pmax-url-exclusion-audit [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--waste-url-patterns <WASTE_URL_PATTERNS>` | Comma-separated URL path prefixes treated as common-waste patterns. Default '/blog,/careers,/privacy,/terms,/about,/affiliate,/coupon,/jobs,/legal'. Overrides customer policy. |
| `--include-display-channels <INCLUDE_DISPLAY_CHANNELS>` | Also audit DISPLAY campaigns alongside PERFORMANCE_MAX. Default true. [possible values: true, false] |
| `--output-spec <OUTPUT_SPEC>` | Optional: path to write a mutation-ready campaign_negative_webpage_candidates spec — apply with `mutate campaign-negative-webpage-add-bulk --from-file <path>`. |
