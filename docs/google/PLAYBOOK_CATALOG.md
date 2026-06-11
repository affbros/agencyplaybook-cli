# apb-gads Playbook Catalog

The canonical registry of every playbook this CLI ships with. Modeled after AgencyPlaybook's typed catalog (24 entries for Meta), adapted for Google Ads + PMAX.

The runtime version of this catalog is `crates/ads-core/src/playbooks.rs::PLAYBOOK_CATALOG` and is queryable via:

```bash
apb-gads --pretty playbook list
```

## Status snapshot

- **Implemented:** 63
- **Planned:** 0
- **Total cataloged:** 63

All 63 cataloged playbooks are Implemented and live-verified against a real Google Ads test account. Most recent additions: Agency Playbooks v2 Phase 3 — `placement-leakage-audit` (mutation-ready for display placements) and `pmax-url-exclusion-audit` (mutation-ready WEBPAGE negative spec for PMAX/DISPLAY waste URL coverage). The full v2 series (11 playbooks across 3 phases) shipped in May-16; see `docs/agency-playbooks-v2.md` for the design and `docs/playbooks.md` for the operator-oriented per-playbook detail.

## Sections

Each playbook belongs to one section. Sections mirror AgencyPlaybook's pattern (Core Diagnostics / Growth & Scale / Data Quality & Hygiene / Structural) plus two Google-Ads-native sections (Creative, Performance Max).

---

## Core Diagnostics

Fast health checks that should run weekly or on-demand to surface acute issues.

| Slug | Status | Lookback | Purpose |
|---|---|---|---|
| `weekly-audit` | IMPLEMENTED | 365d | Account spend snapshot + top campaigns + top search terms + PMAX presence in one bundle. Trailing 365-day window by default (the name is a cadence, not the window); override with `--lookback-days`. |
| `account-health` | IMPLEMENTED | 365d | Structured scorecard with status counts, trailing-365-day spend signals, recommended next actions. Override with `--lookback-days`. |
| `launch-check` | IMPLEMENTED | 7d | Verify presence of campaigns, ad groups, ads, keywords, and PMAX entities pre-launch. |
| `waste-audit` | IMPLEMENTED | 365d | Identify expensive search terms with poor or zero conversions; surface obvious leaks. Trailing 365-day window by default; override with `--lookback-days`. |
| `budget-pacing` | IMPLEMENTED | this-month | Compare daily-budget × days-elapsed against actual cost; flag over/under-pacing. |
| `impression-share-loss` | IMPLEMENTED | 30d | Per-campaign IS lost to budget vs lost to rank; flag campaigns >10% budget-lost or >20% rank-lost. |
| `anomaly-detection` | IMPLEMENTED | 14d | Week-over-week spend / clicks / conversion change alerts; flags newly-active and newly-dark campaigns. |

## Growth & Scale

Surface opportunities to spend more on what's working and to expand winning patterns.

| Slug | Status | Lookback | Purpose |
|---|---|---|---|
| `budget-rebalance` | IMPLEMENTED | 30d | Rank campaigns by ROAS; recommend shifting budget from low-ROAS to high-ROAS. |
| `broad-match-conversion-rate` | IMPLEMENTED | 90d | Identify broad-match keywords with significant spend and < 0.5% conversion rate. |
| `dayparting-analysis` | IMPLEMENTED | 90d | Performance by day-of-week × hour-of-day for ad-scheduling adjustments. |
| `geo-performance` | IMPLEMENTED | 90d | Cost / conversions by geographic location for geo-targeting changes. |
| `device-performance` | IMPLEMENTED | 90d | Desktop vs mobile vs tablet performance comparison. |
| `seasonality-overview` | IMPLEMENTED | 365d | Month-over-month spend / conversion / CPA trend with MoM percent deltas. |
| `cross-network-performance` | IMPLEMENTED | 90d | Split metrics by Search vs Display vs YouTube vs Partner Search with per-network ROAS. |
| `audience-performance` | IMPLEMENTED | 90d | Per-audience-type aggregation across in-market, remarketing, demographics; surfaces CPA per type. |
| `expansion-readiness` | IMPLEMENTED | 30d | Flag campaigns with sustained budget pressure (lost-IS > 10%) AND ROAS ≥ `--min-roas` as candidates for budget lift. |
| `search-term-promotion` | IMPLEMENTED | 90d | Promote high-value search terms to keywords, filtered by metric thresholds (impressions/clicks/cost/conversions/conv-value/ROAS/CPA/top-N); enriched with intent-based match type, historical-CPC suggested bid, cluster label. Emits `keyword_promotion_candidates` → KeywordAddBulk (also `keyword-add-bulk --from-file`). |
| `competitor-pressure` | IMPLEMENTED | 30d | Flag campaigns where search_rank_lost_impression_share rose ≥ 5pp (current 30d vs prior 30d). Proxy signal only — true domain-level auction insights require Standard API access. |
| `audience-burnout-detection` | IMPLEMENTED | 30d | Detect audience targets where engagement is decaying (CTR/CVR drop, CPA rise) current vs prior 30d on `ad_group_audience_view`. Tiered HIGH/MEDIUM by per-metric threshold crossings. Knobs: `--burnout-ctr-drop-pp-high` (0.5), `--burnout-cvr-drop-pp-high` (0.3), `--burnout-cpa-rise-pct-high` (25.0), `--burnout-min-clicks` (50). |
| `roas-nudge-recommendation` | IMPLEMENTED | 14d | Per-campaign tROAS / tCPA micro-adjustment recommendations bounded by ±`--max-nudge-pct` (default 10%) based on 14d actual-vs-target performance. Skips below `--min-conversions-for-nudge` (15) or within `--target-roas-tolerance-pct` (5%). Tier is always MEDIUM (informational — operator must vet). |

## Data Quality & Hygiene

Maintenance work — cleanup, audit, and consistency checks.

| Slug | Status | Lookback | Purpose |
|---|---|---|---|
| `search-term-cleanup` | IMPLEMENTED | 365d | Negative-keyword candidates from search terms with ad-group context for bulk apply. |
| `negative-keyword-coverage` | IMPLEMENTED | 30d | Per-ad-group negative-keyword counts; flag groups with zero or thin (< 5) coverage. |
| `duplicate-keywords` | IMPLEMENTED | 30d | Same keyword + match-type appearing across multiple ad groups (internal competition). |
| `competitor-keyword-bleed` | IMPLEMENTED | 365d | Search terms hitting known competitor brand patterns; group by brand for triage. |
| `naming-convention-audit` | IMPLEMENTED | n/a | Flag campaigns / ad groups whose names lack separators, are very short, or duplicate. |
| `conversion-tracking-check` | IMPLEMENTED | n/a | List configured conversion actions; flag REMOVED, HIDDEN, or unverified ones. |
| `conversion-tracking-audit` | IMPLEMENTED | 30d | Comprehensive v24 audit: tag health, full conversion-action settings (attribution, value, lookbacks, origin-specific), customer + per-campaign goal mapping with UI-style buckets (Sales/Leads/Awareness/Other), per-campaign goal config (CUSTOMER vs CUSTOM), custom goals, custom variables, value-rule sets, account links, plus severity-coded findings (10 rules). |
| `landing-page-audit` | IMPLEMENTED | n/a | Group ads by final URL; flag ads with no URL, singleton URLs, surface top URLs. |
| `quality-score-audit` | IMPLEMENTED | n/a | Distribution of keyword quality scores; surface low-QS (1-4) keywords. |
| `keyword-prune-audit` | IMPLEMENTED | 90d | Rank ENABLED keywords by metrics; flag prune candidates by **$** (zero-conv spend / absolute CPA ceiling), **%** (CPA/ROAS vs context target), **#** (no-traffic floors / worst-N by CPA). Emits a mutation-ready `keyword_prune_candidates` spec → KeywordRemoveBulk (review-gated). |
| `policy-compliance` | IMPLEMENTED | n/a | Bucket ads by approval_status (DISAPPROVED, APPROVED_LIMITED, etc.); surface `policy_topic_entries` per flagged ad. |
| `quality-score-root-cause` | IMPLEMENTED | n/a | Low-QS keywords broken down by bottleneck component (expected CTR vs ad relevance vs landing-page experience) with per-bottleneck remediation. |
| `waste-cluster-audit` | IMPLEMENTED | 90d | Token-stem clusters of zero-conversion search queries with combined spend ≥ `--min-cluster-cost-micros` (default $200) in the lookback; emits a mutation-ready `negative_keyword_candidates` spec consumable by `mutate negative-keyword-add-bulk --from-file`. |
| `conversion-value-gap` | IMPLEMENTED | 30d | Flag ENABLED `primary_for_goal` conversion actions in lead-like categories (LEAD/SUBMIT_LEAD_FORM/SIGNUP/CONTACT/etc.) with missing or improperly-configured value settings (HIGH severity), and revenue-implied categories (PURCHASE/ADD_TO_CART/etc.) with no `default_value` set (MEDIUM severity). Surfaces `value_status` enum: configured / missing / zero_default / default_set_but_not_always_used. |
| `qs-cpc-tax` | IMPLEMENTED | 30d | Quantify CPC inflation from QS 1–4 keywords via hierarchical high-QS-cohort counterfactual (ad-group/match/network → campaign/match → account → heuristic fallback). Reports `measured_tax_micros`, `measured_tax_percent`, `low_qs_cost_share_percent`, `baseline_source_distribution`. Heuristic `estimated_tax_micros` emitted only when no peer cohort exists (confidence=low). |
| `geo-bid-drift-audit` | IMPLEMENTED | 30d | Detect geos where CPA has drifted materially current vs prior 30d on `geographic_view`. HIGH requires both CPA drift ≥ `--geo-cpa-drift-pct-high` (default 50%) AND current cost share ≥ `--geo-min-cost-share-pct` (default 2.0%); MEDIUM on CPA drift alone ≥ `--geo-cpa-drift-pct-medium` (default 25%). Skips geos with < `--geo-min-clicks` (default 30) in either period. |
| `landing-page-intent-drift-audit` | IMPLEMENTED | 90d | Cross-references `landing_page_view` + `ad_group_ad.final_urls` + `keyword_view.post_click_quality_score`. Flags URL when ≥ `--lp-below-avg-keyword-share-pct` (default 50%) of its keywords show post-click QS BELOW_AVERAGE, OR mobile-friendly-clicks-pct < `--lp-min-mobile-friendly-pct` (default 80%). HIGH when both fire. |
| `conversion-value-tier-audit` | IMPLEMENTED | 30d | Extends `conversion-value-gap` with value-quality scoring: placeholder_pattern (MEDIUM), single_value_pattern (LOW), high_variance_pattern (HIGH) across conversion-action categories. Knobs: `--tier-placeholder-count` (2), `--tier-high-variance-ratio` (100.0), `--tier-placeholder-values` (csv "0.0,1.0"). |

## Structural

Account-shape and structure checks.

| Slug | Status | Lookback | Purpose |
|---|---|---|---|
| `account-structure-audit` | IMPLEMENTED | n/a | Density mapping: ads per ad group, keywords per ad group, ad groups per campaign. Flags thin ad groups. |
| `ad-rotation-audit` | IMPLEMENTED | n/a | Active ads per ad group; flag groups with 0, 1, or 2 ads (Google recommends ≥ 3). |
| `campaign-bid-strategy-audit` | IMPLEMENTED | n/a | Mix of bidding strategies in use across campaigns with status and channel context. |
| `keyword-match-type-mix` | IMPLEMENTED | n/a | Per-campaign BROAD/PHRASE/EXACT distribution; flag imbalanced (>80% one type). |
| `ad-extension-coverage` | IMPLEMENTED | n/a | Per-campaign sitelink/callout/structured-snippet presence; flag missing recommended types. |
| `targeting-coverage` | IMPLEMENTED | n/a | Per-campaign 10-dimension targeting scorecard (geo/lang/device/schedule/audience/demographic/placement/topic/brand/content_label) with missing-targeting flags for ENABLED campaigns. |
| `experiment-readiness` | IMPLEMENTED | 30d | Flag ENABLED campaigns with sufficient 30d baseline (conversions + clicks) that aren't already bound to a Google Ads Experiment arm. |
| `smart-bidding-readiness` | IMPLEMENTED | 30d | Per-campaign 0-90 readiness score for moving from manual CPC to tCPA / tROAS / MAXIMIZE_CONVERSIONS with recommended next strategy. |
| `match-type-sculpting` | IMPLEMENTED | 90d | Recommend match-type upgrades (PHRASE→EXACT) or downgrades (BROAD→PHRASE) per keyword based on 90d conv-rate and cost. |
| `campaign-cannibalization` | IMPLEMENTED | 30d | Detect normalized queries served by ≥ 2 of our own active ENABLED campaigns with material spend each; tiered LOW/MEDIUM/HIGH/CRITICAL by CPA gap and bid-strategy divergence. `--severity-mode standard\|strict\|diagnostic`; emits informational `query_cannibalization_review` spec. |
| `bid-strategy-mismatch` | IMPLEMENTED | 30d | Detect campaigns whose *current* bid strategy is throttling scale. Fires 7 named rules with per-rule severity + evidence block: `manual_cpc_with_strong_conversions`, `max_clicks_with_strong_conversions`, `tcpa_budget_throttled`, `tcpa_target_too_low`, `troas_without_value_tracking` (CRITICAL when value tracking unhealthy), `maximize_conversions_without_target_cpa`, `learning_stuck`. Two GAQL probes (campaign metrics + conversion-action value-health). |
| `brand-exclusion-audit` | IMPLEMENTED | 90d | Diff competitor-bleed search terms against existing `customer_negative_criterion` (KEYWORD type). Uncovered terms become mutation-ready spec items (`customer_negative_criterion_candidates`, default EXACT match type). Knobs: `--bleed-min-cost-micros` ($10), `--brand-token-list` (file path). |
| `campaign-consolidation-audit` | IMPLEMENTED | 30d | Cluster ENABLED micro-campaigns (cost < `--micro-max-spend-micros` AND conv < `--micro-max-conversions`) by `(channel_type, bidding_strategy_type)`. Clusters with `--min-micros-in-cluster` (2) or more emit a consolidation candidate with the highest-cost member as proposed merge target. Tier is always MEDIUM. |
| `sandbox-campaign-audit` | IMPLEMENTED | 30d | Sandbox candidates = name matches `--sandbox-tag-list` (default "sandbox,test,experiment,pilot") OR `campaign.experiment_type` is non-BASE. Violations: `shared_budget` (HIGH), `portfolio_bidding` (MEDIUM), `spend_share_violation` (account-wide, >`--sandbox-budget-share-pct-max` default 10%). |
| `pmax-url-exclusion-audit` | IMPLEMENTED | 90d | Substitute for v24-removed `url_expansion_opt_out`: per (PMAX/DISPLAY campaign × common-waste URL pattern) coverage check against `campaign_criterion` WEBPAGE negatives (v24-correct — `customer_negative_criterion.webpage.*` doesn't exist). Patterns `/blog,/careers,/privacy,/terms,/about,/affiliate,/coupon,/jobs,/legal` by default. Mutation-ready `customer_negative_criterion_webpage_candidates` spec via `--output-spec`. |

## Creative

Creative-rotation and asset-iteration helpers.

| Slug | Status | Lookback | Purpose |
|---|---|---|---|
| `creative-refresh` | IMPLEMENTED | 365d | Ad inventory + asset usage + top search-term inputs for next creative iteration. |
| `rsa-asset-performance` | IMPLEMENTED | 30d | Per-ad RSA headline/description performance labels (LOW/GOOD/BEST/PENDING) with swap candidates; subsumes the message-testing capability. |
| `rsa-quality-audit` | IMPLEMENTED | 30d | 7-point copy-quality review of every live RSA (8-angle diversity, near-duplicates, keyword coverage, CTA/trust, DKI linter, policy-content) scored with `ad_strength` + `approval_status`; emits informational `rsa_refresh_candidates` for `orchestrate ad-refresh`. Honest limit: no per-asset spend claim (Google exposes `performance_label` only). |

## Performance Max

PMAX-specific inspection and diagnostics.

| Slug | Status | Lookback | Purpose |
|---|---|---|---|
| `pmax-audit` | IMPLEMENTED | 365d | PMAX summary + asset groups + asset-group assets + asset-group performance + diagnostics flags (waste / dormant / missing required field types). |
| `pmax-asset-coverage` | IMPLEMENTED | 30d | Per-asset-group field-type completeness scoring with **policy-configurable minimums** (`PmaxAssetCoveragePolicy`) + advisories: **missing-video** (Important), **portrait-image** recommendation, **audience-signal presence** (Important); `underbuilt` / `severe_underbuilt` flags. Honest limit: signal-strength ranking + brand-cannibalization are follow-ups (presence only). |
| `pmax-maturity-gate` | IMPLEMENTED | 30d | Per-PMAX-campaign readiness verdict: maturity (age≥30d OR ≥50 conv), CPA-vs-target tier (star/performer/underperformer/problem/starved), learning-band approximation, PMax-vs-Search ROAS ratio → `ready_to_scale` / `optimize` / `collect_data` / `pause_candidate` + named blockers. Targets context-first. Honest limit: no API learning-status field; band is an age/volume approximation. |
| `pmax-scaling-plan` | IMPLEMENTED | 30d | Per-PMAX-campaign Go/No-Go budget scaling (maturity + profitability vs target + no halt band CPA>1.2×/ROAS<0.8× + no bid+budget stacking, checked vs `audit.jsonl`); on Go recommends a single-step budget increase capped at 50% → emits `budget_update_candidates` spec → CampaignBudgetUpdateBulk (review-gated). Targets context-first. |
| `shopping-feed-segmentation-audit` | IMPLEMENTED | 30d | Enumerates Merchant Center feed (by brand / availability / status) + PMAX listing-group-filter coverage per asset group; flags only-root-filter asset groups, NOT_ELIGIBLE inventory, and brand diversity without filter coverage. Does NOT recommend RETAIL_FILTER (v24 allowlist-only, §B2.1 gated). |
| `pmax-segmentation-audit` | IMPLEMENTED | 30d | Per-PMAX-campaign rules: SHOULD_SPLIT (HIGH) when spend >= `--split-min-spend-micros` ($5k) + conv >= `--split-min-conversions` (50) + asset_group_count <= 1; TOO_MANY_GROUPS (MEDIUM) when count > `--asset-groups-per-campaign-max` (7). Emits a fixed `suggested_segments` menu (Brand Defense / High Intent / Prospecting / etc.). |
| `placement-leakage-audit` | IMPLEMENTED | 30d | Surface display + video placements (`detail_placement_view`) that consumed PMAX/DISPLAY/VIDEO budget with zero conversions over the lookback. Severity HIGH at >= 4× the `--leakage-min-cost-micros` floor (default $25), MEDIUM otherwise. `mutation_eligible` flag set for WEBSITE / MOBILE_APP / GOOGLE_PRODUCTS placement types; YouTube placements informational only (auto-targeting re-adds excluded channels). Mutation-ready `placement_exclusion_candidates` spec via `--output-spec`. |

---

## How to add a new playbook

1. Add a new entry to `PLAYBOOK_CATALOG` in `crates/ads-core/src/playbooks.rs` with `status: PlaybookStatus::Planned`.
2. Implement the method on `AdsClient` in `crates/ads-core/src/client.rs`. Follow the established shape:
   ```rust
   pub async fn my_playbook(&self, customer_id: &str) -> Result<Value> {
       // 1. fetch data via existing client methods or new gaql_query calls
       // 2. compute findings / scoring
       // 3. return json!({ "playbook": "my-playbook", "customer_id": ..., ..., "recommendations": [...] })
   }
   ```
3. Add a clap variant in `crates/ads-cli/src/main.rs::PlaybookCommands` and a matching dispatch arm.
4. Append a `run_case` line to `scripts/qa_smoke.sh` exercising the live API.
5. Flip the catalog entry's `status` to `PlaybookStatus::Implemented`.
6. Run `scripts/qa_smoke.sh` — confirm exit 0 and PASS count incremented.

Future structural improvement: extract playbooks from `client.rs` into a `playbooks` submodule once the file exceeds ~3,000 lines or the methods are clearly tested as a unit.
