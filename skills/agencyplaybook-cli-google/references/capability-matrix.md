# Capability matrix — what's proven, and how to trust a write

A `200` / exit-0 from a mutation is **not** proof the change persisted. Some Google Ads v25 fields
are accepted but silently not applied, write-only, or frozen at create. **Never claim a write
landed from the response alone — confirm by readback.** This reference tells you how strongly each
surface has been proven and how to verify the rest yourself.

## Execution tiers (strongest proof a surface has earned)

| Tier | What it means |
|---|---|
| **READ** | Reads/reports — always live, no gates. |
| **DRY_RUN** | Local validators run, no API call. The default for every `mutate`. |
| **SERVER_VALIDATED** | Google validated the full request body (`validateOnly=true`) — schema + policy + auth — and created nothing. Invoke with `--execute --validate-only`. |
| **EXECUTE_SANDBOX** | A real write, but confined to the `$1` `Test-ok-to-delete` sandbox (or a per-customer profile). |
| **LIVE_VERIFIED** | Real entities created via a `verify` chain, **read back to confirm**, then atomically cleaned up and ledger-recorded. |

## What's verified at the top tier

- **LIVE_VERIFIED** (full create → readback → cleanup proven): SEARCH campaign create + targeting
  (`verify search-lifecycle`), RSA create + refresh (`verify rsa-lifecycle` → covers
  `ad-create` + `ad-update-status`), and atomic PMAX launch (`verify pmax-launch`).
  As of **0.1.21** the search-lifecycle chain is a **spec-v2 chain**: alongside the v1
  budget/campaign/geo/ad-group/RSA/keywords it creates a sitelink + callout asset and their
  campaign links, an ad schedule, a device bid modifier, a shared-set attach, a
  `final_url_suffix` and explicit network settings, then reads **all 24 assertions** back by
  resource name before atomically removing them. So the `assets` / `targeting` /
  `negatives-extra` / `tracking` / `settings` tail ops of `orchestrate campaign-launch` are
  LIVE_VERIFIED, not merely server-validated.
- **SERVER_VALIDATED**: the large majority of the 123 `mutate` surfaces have been proven against
  Google's validator via `--validate-only` — schema + policy correct, no state change. This is the
  fastest way to prove *your* payload before writing.
- **EXECUTE_SANDBOX**: every other execute-mode write lands in the `$1` `Test-ok-to-delete`
  sandbox unless a per-customer profile authorizes the specific op (see `safety-model.md`).

## Google Ads API v25 (pinned 2026-09-08) — what changed for writes

🔴 **BREAKING — customer-acquisition goals.** v25 removed `CustomerLifecycleGoal` /
`CampaignLifecycleGoal` and their services. `mutate campaign-update-customer-acquisition` now runs a
**two-step** flow against two dedicated (non-unified-mutate) services whose REST collections are
**Capitalized**, unlike every other Google Ads collection: `POST …/Goals:mutate` then
`POST …/CampaignGoalConfigs:mutate` (lowercase `goals:mutate` 404s). The CLI keeps the v24
`--optimization-mode` vocabulary and maps it: `TARGET_ALL_EQUALLY` / `BID_HIGHER_FOR_NEW_CUSTOMER`
→ `TARGET_ALL`, `TARGET_NEW_CUSTOMER` → `TARGET_SPECIFIC`. **`GoalService` has no `remove`** — an
account-level Goal provisioned this way is permanent on that account (the campaign *link* is
reversible). On an account with no existing-customer definition, `TARGET_ALL` is rejected with an
unmapped `requestError: UNKNOWN` / "The error code is not in this version".

New in v25, and verified:

| Surface | Tier | Notes |
|---|---|---|
| `mutate campaign-update-ai-max --enable {true\|false}` | SERVER_VALIDATED | `campaign.ai_max_setting.enable_ai_max` (v25.1). Master switch — sub-settings do nothing while it is off. |
| `mutate ad-group-update-ai-max-search-term-matching --disable {true\|false}` | SERVER_VALIDATED | The only writable field on `AiMaxAdGroupSetting`; effective only while AI Max is on the parent campaign. |
| `mutate asset-update-synthetic-content --ai-generated {true\|false}` | SERVER_VALIDATED | EU AI Act attestation. Eligible: IMAGE / MEDIA_BUNDLE / YOUTUBE_VIDEO. |
| `mutate ad-update-synthetic-content --ai-generated {true\|false}` | DRY_RUN | Eligible: HTML5_UPLOAD_AD / DYNAMIC_HTML5_AD / IMAGE_AD; anything else → `fieldError: VALUE_MUST_BE_UNSET`. |
| `mutate experiment-create --type <ExperimentType>` | SERVER_VALIDATED (`SEARCH_CUSTOM`, `SEARCH_AUTOMATED_BIDDING_STRATEGY`, `HOTEL_CUSTOM`, `PMAX_REPLACEMENT_SHOPPING`) | Every v25 enum member accepted; default `SEARCH_CUSTOM`. |
| `experiment results --experiment-id` | READ | Control vs treatment + point estimate / margin of error / p-value. |
| `mutate apply-plan` on a **plan-envelope v2** file | SERVER_VALIDATED + EXECUTE_SANDBOX | `schema_version: 2` accepted alongside v1 and legacy plans; `integrity.hash` gated, `--allow-edited-plan` overrides. |

Two write rules that are live-proven and **documented nowhere by Google**:

1. **Synthetic-content mask must name both leaves** —
   `synthetic_content_info.advertiser_attestation.status,…advertiser_attestation.source`. A
   parent-message mask is `FIELD_HAS_SUBFIELDS`; `status` alone is `INVALID_VALUE` at `…source`.
2. **`experiment-create`'s status depends on the type** — `SETUP` for the classic types, `ENABLED`
   for `ADOPT_AI_MAX` / `ADOPT_BROAD_MATCH_KEYWORDS` / `OPTIMIZE_ASSETS` / `SMART_MATCHING` /
   `COMPARE_CAMPAIGNS` / `PMAX_TEXT_CUSTOMIZATION_FINAL_URL_EXPANSION` / `DISPLAY_AND_VIDEO_360`.
   The wrong one is `experimentError: INVALID_STATUS`. The CLI picks it and reports `create_status`.
   `Experiment.suffix` is `IMMUTABLE_FIELD` on the two PMAX types and is not sent for them
   (`suffix_sent: false`).

Honest caveats to carry into recommendations: **full PMAX lifecycle management** (image/video
upload, every listing-group shape) is partial, and **broad live write surface beyond the
sandbox/profile envelope is intentionally gated**. When you're unsure a surface is hardened, say so
and prove it with `--validate-only` rather than asserting it works.

## How to verify a specific field changed

1. **Before writing** — `--execute --validate-only` to prove the wire shape (SERVER_VALIDATED).
2. **After writing** — read it back and compare to the intended value:
   - `apb-gads --customer <CID> campaign get --campaign-id <ID>` / the matching `report …`
   - or a targeted `apb-gads --customer <CID> gaql query --query "SELECT … WHERE …"`
3. **Report honestly**: "verified by readback" vs "accepted (200) but not confirmable" vs
   "rejected." For multi-entity changes, a `verify` chain does the readback for you and records the
   result in the ledger (`verify list`).

> The runtime is the source of truth for what exists and what's hardened. `apb-gads playbook list`,
> `apb-gads <group> --help`, and `references/commands/<group>.md` are authoritative; this matrix is
> a reasoning aid, not a guarantee.
