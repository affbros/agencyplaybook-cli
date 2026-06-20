# apb-gads Playbook Catalog (66)

Every diagnostic playbook the CLI ships, grouped by section. All are **read-only** and return JSON.

```bash
apb-gads --pretty --customer <CID> playbook <slug>     # run one
apb-gads --pretty --customer <CID> playbook <slug> --lookback-days 90   # override the window
apb-gads --pretty playbook list                        # the live registry (source of truth)
```

- **Window**: the default lookback in days. The name is a *cadence*, not the window — `weekly-audit` defaults to 365d. Structural playbooks ignore `--lookback-days`.
- Playbooks that emit an actionable spec accept `--output-spec <file>` to feed `plan from-audit` → `changes apply` (see `workflows.md` § W2). A few accept threshold flags — see `references/commands/playbook.md` for exact params.

## Core Diagnostics (7)

| Slug | Window | What it surfaces |
|---|---|---|
| `weekly-audit` | 365d | Account spend snapshot, top campaigns, search terms, and PMAX presence in one bundle. Trailing 365-day window by default (the name is a cadence, not the window); override with --lookback-days. |
| `account-health` | 365d | Structured health scorecard with status counts, trailing-365-day spend signals, and recommended next actions. Override the window with --lookback-days. |
| `launch-check` | 7d | Verify presence of campaigns, ad groups, ads, keywords, and PMAX entities before going live. |
| `waste-audit` | 365d | Identify expensive search terms with poor or zero conversions plus other obvious spend leaks. Trailing 365-day window by default; override with --lookback-days. |
| `budget-pacing` | 30d | Compare daily-budget * days-elapsed against actual cost for the current month per campaign. |
| `impression-share-loss` | 30d | Surface impression share lost to budget and lost to rank per campaign. |
| `anomaly-detection` | 14d | Week-over-week spend / clicks / conversion change alerts; flags newly-active and newly-dark campaigns. |

## Growth & Scale (13)

| Slug | Window | What it surfaces |
|---|---|---|
| `budget-rebalance` | 30d | Rank campaigns by ROAS and recommend shifting budget from low-ROAS to high-ROAS campaigns. |
| `broad-match-conversion-rate` | 90d | Identify broad-match keywords with poor conversion rates that should be paused or refined. |
| `dayparting-analysis` | 90d | Performance by day-of-week and hour-of-day to inform ad scheduling adjustments. |
| `geo-performance` | 90d | Cost and conversions broken out by geographic location to inform geo-targeting changes. |
| `device-performance` | 90d | Desktop vs mobile vs tablet performance comparison. |
| `seasonality-overview` | 365d | 365-day month-over-month spend, conversion, and CPA trend to spot seasonal patterns. |
| `cross-network-performance` | 90d | Split metrics by Search vs Display vs YouTube vs Partner Search networks with per-network ROAS. |
| `audience-performance` | 90d | Per-audience-type aggregation across in-market, remarketing, demographics; surfaces CPA per type. |
| `expansion-readiness` | 30d | Flag campaigns with sustained budget pressure (lost-IS > 10%) AND high ROAS as candidates for budget lift. |
| `search-term-promotion` | 90d | Promote high-value search terms to keywords, filtered by metric thresholds (impressions/clicks/cost/conversions/conv-value/ROAS/CPA/top-N), enriched with intent-based match type, historical-CPC suggested bid, and a cluster label. Emits a keyword_promotion_candidates spec → KeywordAddBulk (also consumable by keyword-add-bulk --from-file). |
| `competitor-pressure` | 30d | Trend rank-lost + top + absolute-top impression share over N windows (`--windows`, default 2; `--level campaign\|ad_group\|keyword`) and decompose loss into rank-lost (→ raise bid / improve QS / tighten match) vs budget-lost (→ raise budget), with a `under_pressure`/`relief`/`steady` verdict. IS clamping (`<10%`/`>90%`) handled — never read as literals. **Named-competitor / overlap / outranking data is NOT available via the Google Ads API at any access tier; this is the impression-share proxy — use the Google Ads UI Auction Insights report for competitor domains.** |
| `audience-burnout-detection` | 30d | Detect audience targets where engagement is decaying current-vs-prior 30d (CTR/CVR drop, CPA rise) across ad_group_audience_view. Tiered HIGH/MEDIUM by per-metric threshold crossings. |
| `roas-nudge-recommendation` | 14d | Per-campaign tROAS / tCPA micro-adjustment recommendations bounded by ±max_nudge_pct (default 10%) based on 14d actual-vs-target performance. Big changes reset learning; small nudges don't. |

## Data Quality & Hygiene (20)

| Slug | Window | What it surfaces |
|---|---|---|
| `search-term-cleanup` | 365d | Surface negative-keyword candidates from search terms with ad-group context for bulk apply. |
| `negative-keyword-coverage` | 30d | Per-ad-group negative-keyword counts; flag groups with zero or very few negatives. |
| `duplicate-keywords` | 30d | Find keywords with the same text + match-type appearing across multiple ad groups. |
| `competitor-keyword-bleed` | 365d | Search terms hitting known competitor brand patterns; group by brand for triage. |
| `naming-convention-audit` | 30d | Flag campaigns and ad groups whose names don't match common operator patterns. |
| `conversion-tracking-check` | 30d | List configured conversion actions and flag REMOVED, HIDDEN, or unverified ones. |
| `conversion-tracking-audit` | 30d | Comprehensive v24 audit: tag health, full conversion-action settings (attribution, value, lookbacks, origin-specific), customer + per-campaign goal mapping, custom variables, value-rule sets, account links, plus actionable findings (severity-coded). |
| `landing-page-audit` | 90d | Group ads by final URL; flag URLs with very low traffic or used by only one ad. |
| `quality-score-audit` | 30d | Distribution of keyword quality scores; flag low-QS keywords with significant spend. |
| `keyword-prune-audit` | 90d | Rank ENABLED keywords by metrics and flag prune candidates by $ (zero-conversion spend / absolute CPA ceiling), % (CPA/ROAS vs context target), and # (no-traffic click/impression floors); emits a mutation-ready keyword-remove spec. |
| `policy-compliance` | 30d | Bucket ads by approval_status (DISAPPROVED, APPROVED_LIMITED, etc.) and surface policy_topic_entries for triage. |
| `quality-score-root-cause` | 30d | Break low-QS keywords down by which component (expected CTR, ad relevance, landing-page experience) is BELOW_AVERAGE. |
| `waste-cluster-audit` | 90d | Token-stem clusters of zero-conversion search queries with combined spend ≥ $200 in the lookback window; emits a mutation-ready negative-keyword spec. |
| `search-term-analysis` | 90d | Consolidated search-term analysis: ties each search term to its triggering keyword (text + match type), computes per-term CPA/ROAS, and emits BOTH promote candidates (high-ROI search terms not yet keywords → keyword adds) and negate candidates (high-cost/zero-conversion terms → negatives) in one combined `--output-spec` envelope for the dry-run-first apply pipeline (`plan from-audit` → `changes from-plan` → `changes apply`). |
| `search-term-ngram-audit` | 90d | Decomposes search terms into 1/2/3-grams, aggregates spend/clicks/conversions per n-gram, and flags wasteful patterns (high spend, ~0 conversions) + the most efficient ones. Emits the wasteful **multi-word** n-grams as `shared_negative_candidates` to a shared negative list via the actionable pipeline (`--shared-set` required); 1-grams are surfaced but only emitted as negatives with `--include-unigram-negatives`. |
| `conversion-value-gap` | 30d | Flag conversion actions marked primary_for_goal in lead/form-fill categories that have no default_value or always_use_default_value=false (breaks Smart Bidding value math). |
| `qs-cpc-tax` | 30d | Quantify the CPC inflation paid for QS<5 keywords via counterfactual to a high-QS peer cohort (ad-group/match/network → campaign/match → account → heuristic fallback) with confidence labels. |
| `geo-bid-drift-audit` | 30d | Detect geos (ZIP / state / DMA) where CPA has drifted materially current-vs-prior 30d on geographic_view; surfaces hidden spend pockets weighted by cost share. |
| `landing-page-intent-drift-audit` | 90d | Surface landing pages where Google's landing_page_view quality signals degraded — mobile-friendliness, post_click_quality_score — and pair with the keywords pointing at them. |
| `conversion-value-tier-audit` | 30d | Extends conversion-value-gap with value-quality scoring: placeholder-pattern, single-value-pattern, high-variance-pattern across conversion-action categories. |

## Structural (16)

| Slug | Window | What it surfaces |
|---|---|---|
| `account-structure-audit` | 30d | Density mapping: ads per ad group, keywords per ad group, ad groups per campaign. |
| `ad-rotation-audit` | 30d | Ads per ad group; flag ad groups with fewer than 3 active ads (Google's minimum). |
| `campaign-bid-strategy-audit` | 30d | Mix of bidding strategies in use across campaigns with status and channel context. |
| `campaign-type-fit` | 30d | Per-ENABLED-campaign channel-type fit vs conversion signal: flags Demand Gen optimizing for conversions with no signal (→ Search) and PMax launched onto thin signal (→ Search-first). The type-level companion to the verdict; aligns with verdict G3. Read-only. |
| `keyword-match-type-mix` | 30d | Distribution of BROAD/PHRASE/EXACT keywords; flag campaigns with imbalanced mix. |
| `ad-extension-coverage` | 30d | Per-campaign sitelink, callout, and structured snippet coverage; flag thin extensions. |
| `targeting-coverage` | 30d | Per-campaign targeting-dimension scorecard (geo/language/device/schedule/audience/demographic/placement/topic/brand/content_label) with missing-targeting flags for ENABLED campaigns. |
| `experiment-readiness` | 30d | Flag ENABLED campaigns with sufficient baseline (30d conversions + clicks) that aren't already in a Google Ads Experiment. |
| `smart-bidding-readiness` | 30d | Per-campaign 0-90 readiness score for moving from manual CPC to tCPA / tROAS / MAXIMIZE_CONVERSIONS. |
| `match-type-sculpting` | 90d | Recommend match-type upgrades (PHRASE→EXACT) or downgrades (BROAD→PHRASE) per keyword based on 90d conv-rate. |
| `campaign-cannibalization` | 30d | Detect normalized queries served by ≥ 2 of our own active campaigns with material spend each, tiered LOW/MEDIUM/HIGH/CRITICAL by CPA gap and bid-strategy divergence. |
| `bid-strategy-mismatch` | 30d | Detect campaigns whose current bid strategy is throttling scale — 10 named rules with per-rule evidence blocks (manual_cpc_with_strong_conversions, tcpa_budget_throttled, troas_without_value_tracking, learning_stuck, etc.). Includes the smart-bidding-misapplication trio: tcpa_insufficient_conversions (TARGET_CPA below `--tcpa-min-conversions`, default 30 → Maximize Conversions), troas_insufficient_conversions (TARGET_ROAS below `--troas-min-conversions`, default 15 → Maximize Conversion Value, or Maximize Conversions if value tracking is unhealthy), max_conv_value_insufficient_conversions (MAXIMIZE_CONVERSION_VALUE below `--max-conv-value-min-conversions`, default 15 → keep uncapped). Each frames the fallback as the correct entry strategy for the volume tier (best-practice guidance, not an API gate), cites the lookback window, and points at `mutate campaign-update-bidding-strategy` — advisory only, no auto-apply. |
| `brand-exclusion-audit` | 90d | Audit account-wide customer_negative_criterion coverage against competitor-brand patterns from `competitor-keyword-bleed`. Emits a mutation-ready customer-negative-criterion-add spec for missing exclusions. |
| `campaign-consolidation-audit` | 30d | Inverse of pmax-segmentation-audit: flag micro-campaigns (low spend, low conversion volume) sharing channel + bid-strategy that should be merged. |
| `sandbox-campaign-audit` | 30d | Enforce small-bets hygiene: sandbox / experiment campaigns must not share budgets, must not use portfolio bidding, and must stay below the operator-set account-spend share. |
| `pmax-url-exclusion-audit` | 90d | Substitute for v24-removed url_expansion_opt_out: per (PMAX/DISPLAY campaign, common-waste pattern) coverage check against campaign_criterion WEBPAGE negatives (/blog, /careers, /privacy, etc.). Mutation-ready spec. |

## Creative (3)

| Slug | Window | What it surfaces |
|---|---|---|
| `creative-refresh` | 365d | Ad inventory + asset usage + top search-term inputs for the next creative iteration. |
| `rsa-asset-performance` | 30d | Per-ad headline/description performance labels (LOW/GOOD/BEST/PENDING) surfacing swap candidates. Drives RSA iteration and message testing. |
| `rsa-quality-audit` | 30d | 7-point copy-quality review of every live RSA (8-angle diversity, near-duplicates, keyword coverage, CTA/trust, DKI linter, policy-content) scored alongside ad_strength + approval_status; emits informational rsa_refresh_candidates for orchestrate ad-refresh. |

## Performance Max (7)

| Slug | Window | What it surfaces |
|---|---|---|
| `pmax-audit` | 365d | PMAX summary, asset groups, asset-group assets, asset-group performance, plus diagnostics flags (waste, dormant, missing required assets). |
| `pmax-asset-coverage` | 30d | Per-asset-group field-type completeness scoring with policy-configurable minimums + advisories: missing YOUTUBE_VIDEO (Important), portrait-image recommendation, and audience-signal presence (Important). underbuilt/severe_underbuilt flags. |
| `pmax-maturity-gate` | 30d | Per-PMAX-campaign readiness verdict: maturity (age≥30d OR ≥50 conv), CPA-vs-target performance tier (star/performer/underperformer/problem/starved), learning-band approximation, and PMax-vs-Search ROAS ratio → ready_to_scale / optimize / collect_data / pause_candidate with named blockers. Read-only; targets resolve context-first. |
| `pmax-scaling-plan` | 30d | Per-PMAX-campaign Go/No-Go budget-scaling decision (maturity + profitability vs target + no halt band + no bid+budget stacking checked vs audit.jsonl); on Go recommends a single-step budget increase capped at 50% and emits a budget_update_candidates spec → CampaignBudgetUpdateBulk (review-gated). Targets context-first. |
| `shopping-feed-segmentation-audit` | 30d | For retail PMAX: enumerates the Merchant Center feed (products by brand, availability, status) and the current listing-group filter coverage per asset group; flags asset groups with only a root UNIT_INCLUDED (whole-feed targeting) and NOT_ELIGIBLE products that need feed remediation. |
| `pmax-segmentation-audit` | 30d | Per-PMAX-campaign should-split / too-many-asset-groups recommendations based on spend, conversion volume, and asset-group count. |
| `placement-leakage-audit` | 30d | Surface display + video placements (detail_placement_view) that consumed PMAX/DISPLAY/VIDEO budget with zero conversions. Mutation-ready for display exclusions; YouTube placements informational only (Google auto-targeting re-adds excluded channels). |

