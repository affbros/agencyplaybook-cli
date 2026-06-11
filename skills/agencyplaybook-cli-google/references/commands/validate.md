# `apb-gads validate`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Inspect planning artifacts for launch-readiness. Pure-local validators — no API, no writes. A failing verdict prints its JSON report and exits non-zero (code 3), so `validate … && orchestrate campaign-launch` stops on bad input

**Surface:** 👁️ Read-only · **2 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`campaign-spec`](#apb-gads-validate-campaign-spec) | Validate a CampaignLaunchSpec (from `plan campaign search`) for launch readiness: budget/geo/language/bidding present, every ad group has keywords + a valid RSA (counts, char limits, dupes), match types valid, negatives recommended. |
| [`pmax-spec`](#apb-gads-validate-pmax-spec) | Validate a PmaxLaunchPlanSpec (from `plan campaign pmax`) for launch readiness: budget/final_url/geo/language present, PMAX-valid bidding, asset-group content (headline/description counts + lengths, required BUSINESS_NAME + marketing/square images), brand-guidelines + path rules, negatives recommended. |

---

<a id="apb-gads-validate-campaign-spec"></a>
### `apb-gads validate campaign-spec`

Validate a CampaignLaunchSpec (from `plan campaign search`) for launch readiness: budget/geo/language/bidding present, every ad group has keywords + a valid RSA (counts, char limits, dupes), match types valid, negatives recommended. Errors block (exit 3); warnings are advisory

**Usage**

```
Usage: apb-gads validate campaign-spec [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to the CampaignLaunchSpec JSON (`plan campaign search --export`) |

<a id="apb-gads-validate-pmax-spec"></a>
### `apb-gads validate pmax-spec`

Validate a PmaxLaunchPlanSpec (from `plan campaign pmax`) for launch readiness: budget/final_url/geo/language present, PMAX-valid bidding, asset-group content (headline/description counts + lengths, required BUSINESS_NAME + marketing/square images), brand-guidelines + path rules, negatives recommended. Errors block (exit 3); warnings are advisory

**Usage**

```
Usage: apb-gads validate pmax-spec [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to the PmaxLaunchPlanSpec JSON (`plan campaign pmax`) |
