# `apb-gads verify`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Sprint W — live-execute verification. Opt-in chains that write to a real Google Ads account under the LiveVerifyPolicy envelope ($5/day, "test" in name, USA-only geo, explicit customer + domain allowlist), then read back, cleanup, and emit a manifest. Distinct from the $1 sandbox — see docs/tasks/write-plan-apr24.md

**Surface:** ✍️ **Write-capable** · **9 command(s)** · [← back to index](README.md)

> ⚠️ Commands here can write to a Google Ads account. Every write is **dry-run by default** and must clear the three independent gates (`--execute` + config + env) plus a per-customer profile or the test sandbox policy. See [`../mutations.md`](../mutations.md).

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`preflight`](#apb-gads-verify-preflight) | Report the live-verify policy shape for the target customer. |
| [`noop`](#apb-gads-verify-noop) | W2 scaffold probe: exercises the verification state machine end-to-end (lock → manifest → stages → ledger) without touching the Google Ads API. |
| [`smoke`](#apb-gads-verify-smoke) | W2 server-side gate: submit a synthetic Scandalous-shaped campaign-budget create payload to Google with `validateOnly=true`. |
| [`search-lifecycle`](#apb-gads-verify-search-lifecycle) | W3 Chain 1: full search-campaign lifecycle. |
| [`pmax-launch`](#apb-gads-verify-pmax-launch) | W4 Chain 2: full PMAX launch (Path 3 — production-asset reuse). |
| [`rsa-lifecycle`](#apb-gads-verify-rsa-lifecycle) | P5 Chain 3: full RSA create + refresh lifecycle. |
| [`bootstrap-pmax-assets`](#apb-gads-verify-bootstrap-pmax-assets) | Sprint W5 Phase 5/6: bootstrap standalone PMAX assets on a non-Scandalous account so its LiveVerifyPolicy.pmax_asset_config can be populated and `verify pmax-launch` can run end-to-end. |
| [`list`](#apb-gads-verify-list) | List recent verification runs from the append-only ledger |
| [`cleanup`](#apb-gads-verify-cleanup) | List pending cleanup entries from prior crashed or partial runs. |

---

<a id="apb-gads-verify-preflight"></a>
### `apb-gads verify preflight`

Report the live-verify policy shape for the target customer. Pure config check — does not hit the Google Ads API in W2 (W3+ extends this to also probe for stale TEST entities)

**Usage**

```
Usage: apb-gads verify preflight [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-verify-noop"></a>
### `apb-gads verify noop`

W2 scaffold probe: exercises the verification state machine end-to-end (lock → manifest → stages → ledger) without touching the Google Ads API. Useful as a plumbing regression test

**Usage**

```
Usage: apb-gads verify noop [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-verify-smoke"></a>
### `apb-gads verify smoke`

W2 server-side gate: submit a synthetic Scandalous-shaped campaign-budget create payload to Google with `validateOnly=true`. Exercises auth + wire schema + LiveVerifyPolicy permission + Google's server-side validation pipeline. Creates nothing

**Usage**

```
Usage: apb-gads verify smoke [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-verify-search-lifecycle"></a>
### `apb-gads verify search-lifecycle`

W3 Chain 1: full search-campaign lifecycle. PREFLIGHT → VALIDATE → CREATE (9-op atomic) → VERIFY (17 GAQL assertions) → CLEANUP (9-op atomic remove) → POSTCHECK. Creates a real PAUSED $5/day USA-only SEARCH campaign with one ad group, RSA, 2 keywords, 2 negatives; reads back; atomically removes everything; confirms 0 residual. Total ~8 seconds. Worst-case exposure: $0 (PAUSED)

**Usage**

```
Usage: apb-gads verify search-lifecycle [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-verify-pmax-launch"></a>
### `apb-gads verify pmax-launch`

W4 Chain 2: full PMAX launch (Path 3 — production-asset reuse). Atomic create of campaign-budget + PMAX campaign + USA geo + asset group + 8 asset-group-asset links to EXISTING production assets (1 LOGO + 1 BUSINESS_NAME + 3 HEADLINE + 1 LONG_HEADLINE + 2 DESCRIPTION). VERIFY via 4 GAQL read-backs. CLEANUP atomically removes asset group (cascades AGA links) + geo + campaign + budget. Production assets untouched. Worst-case exposure: $0 (PAUSED + no conversion goals)

**Usage**

```
Usage: apb-gads verify pmax-launch [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-verify-rsa-lifecycle"></a>
### `apb-gads verify rsa-lifecycle`

P5 Chain 3: full RSA create + refresh lifecycle. PREFLIGHT → VALIDATE → CREATE (4-op atomic: budget + PAUSED SEARCH campaign + ad group + RSA) → VERIFY (reads back the ad's ad_strength + policy approval/review status — the signals Chain 1 omits) → REFRESH (create-new RSA + pause-old, the `orchestrate ad-refresh` contract) → CLEANUP (atomic remove) → POSTCHECK. Earns LIVE_VERIFIED for ad-create-rsa and ad-update-status. Worst-case exposure: $0 (PAUSED throughout)

**Usage**

```
Usage: apb-gads verify rsa-lifecycle [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-verify-bootstrap-pmax-assets"></a>
### `apb-gads verify bootstrap-pmax-assets`

Sprint W5 Phase 5/6: bootstrap standalone PMAX assets on a non-Scandalous account so its LiveVerifyPolicy.pmax_asset_config can be populated and `verify pmax-launch` can run end-to-end. Uploads 3 images (logo / marketing / square-marketing) and creates 7 text assets (1 BUSINESS_NAME + 3 HEADLINE + 1 LONG_HEADLINE + 2 DESCRIPTION). Standalone assets persist (v24 AssetService has no remove); Google de-dups by content (re-run safe — same IDs returned). Emits a `yaml_paste_block` ready for `safety.profiles.<id>.live_verify_policy:`

**Usage**

```
Usage: apb-gads verify bootstrap-pmax-assets [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--fixtures <FIXTURES>` | Directory containing the 3 image fixtures (logo.png, marketing_image.png, square_marketing_image.png). Defaults to the repo's committed fixtures [default: scripts/fixtures/test-pmax-assets] |

<a id="apb-gads-verify-list"></a>
### `apb-gads verify list`

List recent verification runs from the append-only ledger

**Usage**

```
Usage: apb-gads verify list [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--limit <LIMIT>` | [default: 20] |

<a id="apb-gads-verify-cleanup"></a>
### `apb-gads verify cleanup`

List pending cleanup entries from prior crashed or partial runs. W3+ extends this to replay each one

**Usage**

```
Usage: apb-gads verify cleanup [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._
