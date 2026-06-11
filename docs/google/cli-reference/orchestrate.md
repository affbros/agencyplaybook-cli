# `apb-gads orchestrate`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Phase 3 composite workflows — orchestrators that compose primitives into end-to-end operator flows (ad-rotate, campaign-launch, etc.)

**Surface:** ✍️ **Write-capable** · **7 command(s)** · [← back to index](README.md)

> ⚠️ Commands here can write to a Google Ads account. Every write is **dry-run by default** and must clear the three independent gates (`--execute` + config + env) plus a per-customer profile or the test sandbox policy. See [`../mutations.md`](../mutations.md).

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`ad-rotate`](#apb-gads-orchestrate-ad-rotate) | Rotate ads within an ad group: pause a list of ads and/or enable a list of ads in a single atomic mutate batch |
| [`ad-refresh`](#apb-gads-orchestrate-ad-refresh) | Refresh a fatigued RSA: create a NEW responsive search ad in the ad group and optionally pause an old one (create-new + pause-old — editing in place resets policy review and breaks history). |
| [`campaign-launch`](#apb-gads-orchestrate-campaign-launch) | End-to-end campaign launch from a JSON spec file: budget → campaign → ad group → RSA → keywords. |
| [`pmax-build`](#apb-gads-orchestrate-pmax-build) | Atomic Performance Max build (phase 1): a single-asset-group PMAX campaign created in ONE googleAds:mutate — budget → campaign (bidding at create) → geo/language/campaign-negatives → assets → asset group → links. |
| [`weekly-optimization`](#apb-gads-orchestrate-weekly-optimization) | Weekly-optimization readout: composes search-term-cleanup + expansion-readiness + impression-share-loss into a single advisory document. |
| [`monthly-review`](#apb-gads-orchestrate-monthly-review) | Monthly-review readout: composes account-health + waste-audit + creative-refresh + budget-pacing + quality-score-audit into a bundled 30-day view. |
| [`rollback`](#apb-gads-orchestrate-rollback) | Rollback: accept a list of resource names and submit a single atomic remove batch. |

---

<a id="apb-gads-orchestrate-ad-rotate"></a>
### `apb-gads orchestrate ad-rotate`

Rotate ads within an ad group: pause a list of ads and/or enable a list of ads in a single atomic mutate batch

**Usage**

```
Usage: apb-gads orchestrate ad-rotate [OPTIONS] --ad-group-id <AD_GROUP_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | Ad group ID. All referenced ads must belong to this ad group |
| `--pause-ad-id <PAUSE_AD_ID>` | Ad ID(s) to set to PAUSED. Repeat the flag for each ID |
| `--enable-ad-id <ENABLE_AD_ID>` | Ad ID(s) to set to ENABLED. Repeat the flag for each ID |

<a id="apb-gads-orchestrate-ad-refresh"></a>
### `apb-gads orchestrate ad-refresh`

Refresh a fatigued RSA: create a NEW responsive search ad in the ad group and optionally pause an old one (create-new + pause-old — editing in place resets policy review and breaks history). The new copy is hard-validated and quality-scored; existing ads are classified by ad_strength to recommend the pause target + intensity. Dry-run by default; pausing the old ad is destructive and needs the global --confirm

**Usage**

```
Usage: apb-gads orchestrate ad-refresh [OPTIONS] --ad-group-id <AD_GROUP_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--ad-group-id <AD_GROUP_ID>` | Target ad group ID (the new RSA is created here) |
| `--headline <HEADLINE>` | New RSA headline. Repeat the flag (3–15 required) |
| `--description <DESCRIPTION>` | New RSA description. Repeat the flag (2–4 required) |
| `--final-url <FINAL_URL>` | Final URL for the new ad. Repeat the flag |
| `--path1 <PATH1>` | Optional display path 1 (≤15 chars) |
| `--path2 <PATH2>` | Optional display path 2 (≤15 chars) |
| `--pause-ad-id <PAUSE_AD_ID>` | Old ad ID to PAUSE (destructive; needs --confirm). Omit to create only and get a recommended pause target |
| `--new-status <NEW_STATUS>` | New ad status: PAUSED (default, safe) or ENABLED [default: PAUSED] |

<a id="apb-gads-orchestrate-campaign-launch"></a>
### `apb-gads orchestrate campaign-launch`

End-to-end campaign launch from a JSON spec file: budget → campaign → ad group → RSA → keywords. Sequential execute path (each step depends on the previous step's returned resource name).

Spec shape: { campaign_name, budget_micros, ad_group_name, ad_group_cpc_bid_micros?, rsa: {headlines[], descriptions[], final_urls[]}, keywords: [{text, match_type}] }

**Usage**

```
Usage: apb-gads orchestrate campaign-launch [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | JSON spec file |

<a id="apb-gads-orchestrate-pmax-build"></a>
### `apb-gads orchestrate pmax-build`

Atomic Performance Max build (phase 1): a single-asset-group PMAX campaign created in ONE googleAds:mutate — budget → campaign (bidding at create) → geo/language/campaign-negatives → assets → asset group → links. Takes a PmaxLaunchPlanSpec (`plan campaign pmax` / `validate pmax-spec`). Dry-run by default; --execute submits (all-or-nothing). Entities are born PAUSED

**Usage**

```
Usage: apb-gads orchestrate pmax-build [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | JSON PmaxLaunchPlanSpec file |

<a id="apb-gads-orchestrate-weekly-optimization"></a>
### `apb-gads orchestrate weekly-optimization`

Weekly-optimization readout: composes search-term-cleanup + expansion-readiness + impression-share-loss into a single advisory document. Read-only — use the per-playbook --output-spec flag to generate bulk-mutation specs

**Usage**

```
Usage: apb-gads orchestrate weekly-optimization [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--search-term-limit <SEARCH_TERM_LIMIT>` | Max search-term candidates to surface [default: 50] |
| `--min-roas-for-expansion <MIN_ROAS_FOR_EXPANSION>` | Minimum ROAS for expansion readiness candidates [default: 2] |

<a id="apb-gads-orchestrate-monthly-review"></a>
### `apb-gads orchestrate monthly-review`

Monthly-review readout: composes account-health + waste-audit + creative-refresh + budget-pacing + quality-score-audit into a bundled 30-day view. Read-only

**Usage**

```
Usage: apb-gads orchestrate monthly-review [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-orchestrate-rollback"></a>
### `apb-gads orchestrate rollback`

Rollback: accept a list of resource names and submit a single atomic remove batch. Supported: campaigns, adGroups, adGroupAds, adGroupCriteria, campaignBudgets. Assets are flagged as unsupported (AssetService has no remove op as of v24 — remove via Google Ads UI)

**Usage**

```
Usage: apb-gads orchestrate rollback [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--resource <RESOURCE>` | Resource name to remove. Repeat for each resource. Example: customers/123/campaigns/456 |
