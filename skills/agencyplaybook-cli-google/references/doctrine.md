# Modern Google Ads doctrine cheat-sheet (2025-26)

Confidence tags: **[G]** = official Google docs · **[E]** = expert/practitioner
consensus (PPC Mastery, Optmyzr/Vallaeys, ZATO, SavvyRevenue) · **[LV]** =
live-verified against the v24 API by this project.

## 1. Smart Bidding: "bid adjustments are dead"

The five Smart Bidding strategies (Target IS, Max Conversions, Max Conv Value,
tCPA, tROAS) **ignore** manual bid adjustments — Google already prices device,
demographics, audience, time per-auction. [E, PPC Mastery TPE #145]

**Modifier × strategy matrix** [G, corroborated answer/2732132 + answer/6268632]:

| Modifier ↓ / Strategy → | Manual CPC / Max Clicks | Max Conversions | Target CPA | Max Conv Value / tROAS |
|---|---|---|---|---|
| Device | Honored | −100% only | **Modifies the CPA target** (+40% mobile → target ×1.4); −100% excludes | −100% only |
| Location / Ad-schedule / Demographic | Honored | Ignored* | Ignored* | Ignored* |
| Audience | Honored | Attribution priority only, not bid | same | same |

\* The ad schedule itself (eligibility hours) is always respected — only the
schedule **bid %** is ignored. The CLI warns about no-op modifiers at the point of
action (`campaign-device-modifier-set` advisory). [LV]

**Replacement levers** [G unless noted]:
- **Conversion value rules** (`mutate conversion-value-rule-create` — geo/device/
  audience → value multiplier; Max Conv Value/tROAS only). Base rules on something
  you *haven't* told Google; don't mirror old modifiers [E]. They inflate reported
  conversion value — note it when reading results [E].
- **Seasonality adjustments** — forward-looking, 1-7 day spikes only (degraded
  >14d); skip if expected CVR change <30%; be conservative (30-50%). CLI warns
  outside these bounds [LV].
- **Data exclusions** — backward-looking, for tracking outages; re-tune targets after.
- **Target tuning is the steering wheel**: raise tCPA / lower tROAS to scale, in
  ≤10-15% steps, once or twice a month, never combined with a budget change.
- **Experiments** (`mutate experiment-create`) for strategy-type changes.

**Strategy selection ladder** [E, Optmyzr/Store Growers]: new/low-data → Max
Conversions (no target) → steady CAC & ≥~30 conv/30d → tCPA → revenue + accurate
values & ≥~50 conv/mo → Max Conv Value → tROAS.

## 2. Learning phase

- Search: ~50 conversions / 3 conversion cycles to converge [G answer/13020501];
  PMAX ~4-6 weeks [E].
- Authoritative status: `campaign.bidding_strategy_system_status` [G, **selectable
  in v24 — LV**]. Values: `ENABLED` (converged), `LEARNING_NEW`,
  `LEARNING_SETTING_CHANGE`, `LEARNING_BUDGET_CHANGE`, `LEARNING_COMPOSITION_CHANGE`,
  `LEARNING_CONVERSION_*_CHANGE`, `LIMITED_BY_BUDGET`, `LIMITED_BY_DATA`,
  `MISCONFIGURED_*`. PMAX campaigns expose a real status too (not UNAVAILABLE) [LV].
- **Full-reset triggers** [E thresholds, Google publishes none — defaults are
  conservative + tunable via `metric_policy`]: strategy-type change; conversion
  action/setting change; pause→enable; target Δ>15%; budget Δ>20%; PMAX asset-group
  edit. "Likely": target Δ10-15%, budget Δ15-20%. Budget+target in one batch =
  always full reset → split them.
- The CLI's F1 advisory (`learning_advisory` on `campaign-update-bidding-strategy` /
  `campaign-budget-update` dry-run envelopes) reads pre-change state and predicts
  the reset; it informs, never blocks [LV].

## 3. RSA quality (Optmyzr ~20k-account studies, Apr-2026 + Oct-2024)

All [E, high confidence — large-N, replicated]:
- **Ad Strength does not correlate with performance** ("Average" beat "Excellent"
  on CPA $12.43 vs $28.68). It measures structural completeness, not performance,
  and is not an Ad Rank factor. Use as a build checklist, never a KPI. **Only POOR
  triggers a refresh recommendation.** Never rewrite a converting ad to chase
  Excellent.
- **Sentence case beats Title Case** — Title Case was 3.7× worse CPA ($27.47 vs
  $7.46); the single largest formatting effect.
- **Short headlines win**: <20 chars $9.35 vs $18.27 CPA. Descriptions sweet spot
  61-70 chars. Maxing out all 15/4 slots with filler shows no improvement —
  8-10 unique headlines + 2-3 descriptions is the target.
- **Partial pinning beats both extremes** ($13.68 vs $32.57 no-pin / $61.11
  full-pin). Pin only brand/legal/offer, 2-3 unique variants per pinned position;
  accept the resulting "Average" strength.
- **1 strong RSA per ad group** is the foundation (1→2 = +6.6%, 2→3 = +3.7% —
  diminishing); add a second only as a deliberate test.
- Refresh = swap 2-3 assets on cadence using the asset report (Low/Good/Best);
  a true relaunch = create a NEW ad (heavy in-place edits reset learning).
- CLI: `playbook rsa-quality-audit` implements all of this (sentence-case detection,
  <20ch hint, pinning analysis incl. descriptions, ad-strength reframe, DKI lint) [LV].

## 4. PMAX facts

- **Structure**: one theme per asset group; 3-7 groups segmented by margin/
  objective/product — not by audience signal alone (the #1 structural mistake) [E].
- **Signals are hints, not targeting** — Customer Match > remarketing > in-market >
  custom; refresh Customer Match monthly [E]. AUDIENCE signals attach via
  `asset_group_signal` with an `AudienceInfo` message [LV].
- **Search themes: cap 25 per asset group** [G — some vendors wrongly say 50;
  the CLI rejects a 26th pre-API] [LV].
- **Brand exclusions on non-brand PMAX in ~99% of cases** (PMAX over-credits brand)
  [E, PPC Mastery]. Cover Search/Shopping inventory only. CLI:
  `customer suggest-brands` → BRANDS shared set → `campaign-brand-list-exclude`.
- **Negative keywords**: campaign-level up to 10,000 (Mar-2025), account-level
  1,000. They block Search & Shopping only — Display/YouTube junk needs placement +
  topic exclusions [G]. Webpage exclusions route through `campaign_criterion`
  type=WEBPAGE (v24 has no customer-level webpage path) [LV].
- **Final URL expansion is ON by default** — turn off for lead-gen/LP control via
  `mutate campaign-update-url-expansion-opt-out` (v24: `asset_automation_settings`,
  the old boolean is gone) [LV].
- **Visibility limits** [LV]: `performance_max_placement_view` = impressions only
  (brand-safety surface); per-channel spend split + brand-traffic share are NOT in
  the v24 API (script-only territory) — `report pmax-placements` is honest about
  this and lists mitigation writes.
- **Cannibalization**: 91% of accounts show Search↔PMAX overlap; on overlapping
  exact terms Search converts ~3× better (CVR 18.91% vs 6.17%) [E, Optmyzr 503
  accounts]. Mitigate: brand exclusions + dedicated brand Search + negatives +
  keep Search eligible.
- **Hard v24 build facts** [LV]: PMAX needs a non-shared budget (shared AND
  portfolio strategies rejected); bidding at create = MAXIMIZE_CONVERSIONS
  (+optional tCPA) or MAXIMIZE_CONVERSION_VALUE (+optional tROAS) only; per asset
  group ≥3 HEADLINE, ≥1 LONG_HEADLINE, ≥2 DESCRIPTION (one <60 chars), BUSINESS_NAME,
  ≥1 MARKETING_IMAGE, ≥1 SQUARE_MARKETING_IMAGE, ≥1 LOGO; assets must exist before
  the asset group references them (the CLI's atomic builders handle ordering);
  ad-schedule criteria carry NO bid_modifier on PMAX.

## 5. Account structure doctrine

Consolidate; broad match + Smart Bidding to *reach* conversion volume; reject
SKAGs [E, PPC Mastery TPE #126]. `growth consolidation` composes the CLI's
structure audits into this readout; `playbook learning-stuck` recommendations are
growth-framed (consolidate to reach threshold, fix tracking — not "go manual") [LV].
