# Building Campaigns with apb-gads

`apb-gads` builds **greenfield** campaigns — a brand-new Search or Performance Max
campaign from nothing — through a research → structure → spec → **validate** →
launch pipeline. Every stage emits JSON, every spec is checked by a pure-local
validator before a single byte goes to Google, and every entity is born `PAUSED`.

This guide covers the two launch pipelines and the exact command sequence for
each. The runtime is always the source of truth — when this doc and the binary
disagree, the binary wins (`apb-gads validate --help`,
`apb-gads orchestrate --help`).

> **Working examples ship alongside this doc** — both are minimal-but-complete
> and **validate clean** (exit 0):
> [`examples/campaign-launch-spec.json`](examples/campaign-launch-spec.json) (Search) and
> [`examples/pmax-launch-spec.json`](examples/pmax-launch-spec.json) (PMAX).

## The pipeline

The flow is the same shape for both campaign types: **research → structure →
RSA/assets → spec file → validate → dry-run → execute**. The first three stages
can be done by hand or generated for you by `plan campaign …`; the back half is
identical either way.

### Search

```bash
# 1-3. RESEARCH + STRUCTURE + RSA — generate a launch-ready spec from a brief.
#       (Pure planning: keyword ideas, ad-group structure, RSA drafts. No writes.)
apb-gads --customer <CID> plan campaign full \
  --business "<one-line business description>" \
  --url https://www.yourbrand.com \
  --export-dir /tmp/build

# 4-5. SPEC + VALIDATE — structural launch-readiness check. Exit 3 on a fail.
apb-gads validate campaign-spec --from-file /tmp/build/campaign-launch-spec.json

# 6. LAUNCH (dry-run) — preview every op; nothing is created.
apb-gads --customer <CID> orchestrate campaign-launch \
  --from-file /tmp/build/campaign-launch-spec.json

# 7. LAUNCH (execute) — only after review; see "Execute safely" below.
```

You can also hand-author the spec file directly (copy
[`examples/campaign-launch-spec.json`](examples/campaign-launch-spec.json) and
edit it) and skip straight to step 4.

### Performance Max

PMAX is identical except its asset groups reference **image assets that must
already exist** in the account. Upload them first (`asset create-image`, or
`verify bootstrap-pmax-assets` for a fresh account), capture the returned
`customers/<id>/assets/<id>` resource names, and drop them into the spec.

```bash
# 0. ASSETS FIRST — PMAX asset groups link existing image assets by resource name.
apb-gads --customer <CID> asset create-image --execute ...   # → note the asset resource names

# 1-3. RESEARCH + STRUCTURE — emit a PMAX plan spec from a brief.
apb-gads --customer <CID> plan campaign pmax \
  --business "<one-line business description>" \
  --final-url https://www.yourbrand.com \
  --output /tmp/pmax.json

# 4-5. SPEC + VALIDATE.
apb-gads validate pmax-spec --from-file /tmp/pmax.json

# 6. LAUNCH (dry-run).
apb-gads --customer <CID> orchestrate pmax-build --from-file /tmp/pmax.json

# 7. LAUNCH (execute) — only after review.
```

## The Search launch spec

`orchestrate campaign-launch --from-file` (and `validate campaign-spec`) consume
a **`CampaignLaunchSpec`**. Annotated reference — see the full working file at
[`examples/campaign-launch-spec.json`](examples/campaign-launch-spec.json):

| Field | Required | Notes |
|---|---|---|
| `campaign_name` | ✅ | Non-empty. The launched campaign's name. |
| `budget_micros` | ✅ | Daily budget in micros (`50000000` = $50.00). Must be `> 0`. |
| `geo_target_ids` | ✅ | Numeric geo-target-constant IDs, e.g. `["2840"]` = USA. **At least one** — every campaign must carry positive geo. |
| `language_ids` | ✅ | Numeric language-constant IDs, e.g. `["1000"]` = English. At least one. |
| `bidding_strategy` | optional | `{strategy_type, target_cpa_micros?, target_roas?, enhanced_cpc?}`. Omit → launches `MANUAL_CPC` (validator emits a `bidding_unset` warning, still passes). |
| `campaign_negative_keywords` | optional | Global exclusions `[{text, match_type}]`; `match_type` is `PHRASE` or `EXACT`. The right home for jobs/free/competitor terms. |
| `ad_groups[]` | ✅* | Multi-ad-group form: each `{name, cpc_bid_micros?, rsa, keywords[], negative_keywords?}`. |

**Either** `ad_groups[]` **or** the legacy single-ad-group fields
(`ad_group_name` + `rsa` + `keywords`) — **not both** (the validator rejects an
ambiguous spec). Prefer `ad_groups[]`; the examples use it.

Per ad group:

- **`keywords[]`** — at least one. Each `{text, match_type, cpc_bid_micros?}`;
  `match_type` is `BROAD` / `PHRASE` / `EXACT`. Optional per-keyword
  `cpc_bid_micros` must be a positive multiple of `10000` ($0.01 billable unit).
- **`negative_keywords[]`** — optional, `PHRASE`/`EXACT` only.
- **`cpc_bid_micros`** — optional ad-group default bid; positive multiple of `10000`.
- **`rsa`** — one Responsive Search Ad: `{headlines[], descriptions[], final_urls[]}`.
  - **3–15 headlines**, each **≤ 30 chars**, all **unique** (case-insensitive).
  - **2–4 descriptions**, each **≤ 90 chars**.
  - **≥ 1 `final_urls`**, each `http`/`https`. Use your real landing page.

### Spec v2 — the whole build in one file (0.1.21+)

Everything above is **v1**, and it still works exactly as written. From **0.1.21** the
spec accepts an additional set of **optional** blocks, applied by eight sequential
**tail stages** that run after the campaign exists — so one `orchestrate campaign-launch`
leaves no hand-run checklist behind:

| Tail stage | Blocks it applies |
|---|---|
| `ads` | `ad_groups[].rsas[]` — additional RSAs for the same ad group (max **3 per ad group**). The primary `rsa` also accepts `pins`, `path1`, `path2`. |
| `targeting` | `geo_exclude_ids`, `geo_target_type` (`PRESENCE` / `PRESENCE_OR_INTEREST`), `location_modifiers`, `proximity`, `ad_schedules`, `device_modifiers`, `audiences.observation`, `demographics.exclude` |
| `negatives-extra` | `shared_sets.create[]` / `shared_sets.attach[]`, `brand_exclusion` |
| `assets` | `assets.sitelinks[]`, `.callouts[]`, `.snippets[]`, `.call`, `.price`, `.promotion`, `.image_resources[]` |
| `tracking` | `tracking.url_template`, `tracking.final_url_suffix` |
| `settings` | `settings.search_partners`, `.display_expansion`, `.ad_rotation`, `.url_expansion_opt_out`, `.frequency_cap` |
| `goals` | `conversion_goals.actions[]`, `conversion_goals.customer_acquisition` |
| `portfolio-bidding` | `bidding_strategy.portfolio_resource` |

Formats worth knowing before you write the file:

- `rsa.pins` — `{"HEADLINE_1": ["exact headline text"], …}`. A pin must reference copy that
  is present in the same RSA; otherwise `validate campaign-spec` exits 3 (Google would
  create the ad **without** the asset).
- `demographics.exclude[]` — `"TYPE:VALUE"` strings, e.g. `"AGE_RANGE:AGE_RANGE_18_24"`.
  Campaign-level demographics are **exclusion-only**.
- `conversion_goals.actions[]` — either `"<CATEGORY>:<ORIGIN>"` (e.g. `"PURCHASE:WEBSITE"`)
  or a conversion-action resource name / id.
- `ad_schedules[]` — `{day, start_hour, end_hour, bid_modifier?}`. On Search a
  `bid_modifier` is allowed (unlike PMAX).

**Four v2 fields are refused before any write**, with a message naming the field and the
workaround, rather than being silently dropped: `tracking.custom_params`,
`audiences.targeting`, `demographics.include`, and
`conversion_goals.customer_acquisition.value_bid_micros`.

> ⚠️ **Check your binary version before using a v2 spec.** `CampaignLaunchSpec` does not
> reject unknown fields and carries no schema version, so **0.1.20 or older parses a v2
> spec happily and silently ignores every v2 block** — you get the v1 skeleton with no
> error. Run `apb-gads --version` (need ≥ 0.1.21) and check the launch output carries
> `spec_summary.v2_blocks`.

### If a tail stage fails

The head (budget + campaign) is atomic; the tails are sequential by necessity. If a tail
stage fails, the launch **stops there**, the campaign stays `PAUSED` (it is born paused and
never enabled, so it cannot spend), and the output is a receipt with
`"status": "partial-failure"`, `failed_stage`, `tail_completed_through` and
`tail_resources[]`.

> ⚠️ **A partial failure still exits 0.** The outcome is in `.status`, not the exit code —
> a `set -e` script must read it.

Save the receipt and undo the whole launch with one atomic batch:

```bash
apb-gads --customer <CID> orchestrate campaign-launch \
  --from-file spec.json --execute > receipt.json

# if .status is "partial-failure":
apb-gads --customer <CID> orchestrate rollback --from-receipt receipt.json          # dry-run
APB_GADS_ALLOW_MUTATIONS=true apb-gads --customer <CID> \
  orchestrate rollback --from-receipt receipt.json --execute
```

Rollback removes children before parents and detaches shared sets before removing them.
Two things it deliberately leaves behind and reports rather than dropping: a **device
campaign criterion** (Google refuses to remove one individually — it goes away with the
campaign) and any **created assets** (the v24 API has no asset-remove operation; delete
them in the Google Ads UI).

### Pre-flight the whole build without creating anything

```bash
APB_GADS_ALLOW_MUTATIONS=true apb-gads --customer <CID> orchestrate campaign-launch \
  --from-file spec.json --validate-only --execute
```

Google validates the head **and** every tail op server-side; nothing is created. Three op
classes cannot be validated before the campaign exists — the customer-acquisition goal (a
separate API service), the conversion-goal set (its resource name is a composite key), and
the brand-list exclusion (eligibility is evaluated against a real campaign). They are listed
under `sequential_tail_steps[].skipped`, and the top-level verdict is then
**`validated-partial`** rather than `validated`. All three are validated at execute time.

## The PMAX launch spec

`orchestrate pmax-build --from-file` (and `validate pmax-spec`) consume a
**`PmaxLaunchPlanSpec`** — note this is the *plan/orchestrate* spec (it carries
bidding + geo/language + campaign negatives), distinct from the bare
`mutate pmax-launch` contract. Annotated reference — full working file at
[`examples/pmax-launch-spec.json`](examples/pmax-launch-spec.json):

| Field | Required | Notes |
|---|---|---|
| `campaign_name` | ✅ | Non-empty. |
| `budget_micros` | ✅ | Daily budget micros, `> 0`. PMAX uses a **non-shared** budget (built for you). |
| `final_url` | ✅ | Campaign landing page (`https://www.yourbrand.com`). Asset groups inherit it unless they set their own. |
| `geo_target_ids` | ✅ | Numeric, ≥ 1 (e.g. `["2840"]`). |
| `language_ids` | ✅ | Numeric, ≥ 1 (e.g. `["1000"]`). |
| `bidding` | ✅ | **Required.** `{strategy_type, target_cpa_micros?, target_roas?}`. PMAX accepts **only** `MAXIMIZE_CONVERSIONS` or `MAXIMIZE_CONVERSION_VALUE` — standalone `TARGET_CPA`/`TARGET_ROAS` are rejected. `target_roas` pairs with the VALUE strategy; `target_cpa_micros` with CONVERSIONS. |
| `campaign_negative_keywords` | optional | `[{text, match_type}]`, `PHRASE`/`EXACT`. Recommended (warns if absent). |

Single-asset-group fields (the legacy form the examples use; **or** provide an
`asset_groups[]` array, not both):

- **`headlines[]`** — **3–15**, each ≤ 30 chars.
- **`long_headlines[]`** — **≥ 1**, each ≤ 90 chars (v24 `NOT_ENOUGH_LONG_HEADLINE_ASSET` otherwise).
- **`descriptions[]`** — **2–5**, each ≤ 90 chars, **and at least one must be < 60 chars** (Google's PMAX short-slot rule).
- **`business_name`** — **required**, ≤ 25 chars (v24 rejects an asset group with no `BUSINESS_NAME` asset).

Required-asset facts (all are existing-asset resource names shaped
`customers/<id>/assets/<id>` — upload before launch):

- **`logo_asset_resources`** — **≥ 1** (1:1 LOGO; v24 `NOT_ENOUGH_LOGO_ASSET` otherwise).
- **`marketing_image_asset_resources`** — **≥ 1** (1.91:1 MARKETING_IMAGE).
- **`square_marketing_image_asset_resources`** — **≥ 1** (1:1 SQUARE_MARKETING_IMAGE).
- `landscape_logo_asset_resources` — optional.

Optional: `path1`/`path2` (display-URL paths, ≤ 15 chars, path2 requires path1),
`signals[]` (per-asset-group `SEARCH_THEME`/`AUDIENCE`), `brand_exclusions`,
`ad_schedules[]`, `customer_acquisition`.

## Validate before you launch

Both validators are **pure-local** — no API, no auth, no writes. They check spec
**structure** against Google's field limits, so you can run them anywhere
(including CI) the moment you've authored a file:

```bash
apb-gads validate campaign-spec --from-file campaign-launch-spec.json
apb-gads validate pmax-spec     --from-file pmax-launch-spec.json
```

A passing spec prints `"overall":"pass"` and **exits 0**. A failing spec prints
a JSON report listing every blocking `error` (with `field` + `rule`) and
**exits 3** — distinct from clap usage errors (2) and runtime errors (1), so a
script can tell "the spec is invalid" apart from "the tool broke". Warnings are
advisory and do **not** change the exit code.

Because a fail exits non-zero, chain validate before launch so bad input stops
the line:

```bash
apb-gads validate campaign-spec --from-file spec.json \
  && apb-gads --customer <CID> orchestrate campaign-launch --from-file spec.json
```

## Execute safely

`orchestrate campaign-launch` / `orchestrate pmax-build` are **dry-run by
default** — without `--execute` they preview the full operation batch (`steps[]`
/ the atomic op list) and create nothing. Review that preview, then execute.

A live write must clear **all three independent gates** (there is no bypass
flag), plus an operation-level authorization (per-customer profile or the
test-sandbox policy). See [`SAFETY_MODEL.md`](SAFETY_MODEL.md) for the full
model:

1. **CLI gate** — `--execute` on the command line.
2. **Config gate** — `safety.allow_writes: true` and `safety.read_only: false` in `google-ads.yaml`.
3. **Env gate** — `APB_GADS_ALLOW_MUTATIONS=true` (when `safety.require_mutation_env: true`).

```bash
# Dry-run (default) — preview, no writes:
apb-gads --customer <CID> orchestrate campaign-launch --from-file spec.json

# Execute — all gates lit:
APB_GADS_ALLOW_MUTATIONS=true \
  apb-gads --customer <CID> --execute orchestrate campaign-launch --from-file spec.json
```

**Everything is born `PAUSED`.** A launched campaign, its ad groups, and its
ads/asset groups are all created in `PAUSED` status — nothing spends until you
review the live entities and explicitly enable them. To prove the request shape
server-side **without** creating anything, add `--validate-only`
(`SERVER_VALIDATED`: Google validates schema + policy + auth, creates nothing).

## See also

- [`GETTING_STARTED.md`](GETTING_STARTED.md) — the on-ramp: auth, first reads, and the command-group map.
- [`SAFETY_MODEL.md`](SAFETY_MODEL.md) — the three-gate write model, sandbox/profile authorization, and the dry-run → execute split in full.
- [`POLICY_LIMITS.md`](POLICY_LIMITS.md) — the field-level limits (RSA/PMAX char counts, asset minimums, URL caps) the validators enforce.
- [`CLI_AUTOMATION.md`](CLI_AUTOMATION.md) — exit codes, JSON output contract, and AI-agent / CI invocation patterns.
- [`cli-reference/plan.md`](cli-reference/plan.md) — `plan campaign search` / `plan campaign full` / `plan campaign pmax` flag reference.
- [`cli-reference/orchestrate.md`](cli-reference/orchestrate.md) — `orchestrate campaign-launch` / `orchestrate pmax-build` flag reference.
