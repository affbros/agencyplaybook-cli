# `apb-gads campaign-type-advisor`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Campaign-type advisor (Search vs PMax vs Demand Gen) — prescriptive: given a goal, demand state, conversion-signal strength, and daily budget, recommend the primary engine + the maturity-ordered sequence (Search captures demand · PMax scales it · Demand Gen creates it). Pure; pass `--customer` to ground the signal in the account's trailing-30d conversions. See campaign-type-selection doctrine

**Surface:** 👁️ Read-only · **1 command(s)** · [← back to index](README.md)

---

<a id="apb-gads-campaign-type-advisor"></a>
## `apb-gads campaign-type-advisor`

Campaign-type advisor (Search vs PMax vs Demand Gen) — prescriptive: given a goal, demand state, conversion-signal strength, and daily budget, recommend the primary engine + the maturity-ordered sequence (Search captures demand · PMax scales it · Demand Gen creates it). Pure; pass `--customer` to ground the signal in the account's trailing-30d conversions. See campaign-type-selection doctrine

**Usage**

```
Usage: apb-gads campaign-type-advisor [OPTIONS] --goal <GOAL>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--goal <GOAL>` | Primary goal: sales \| leads \| awareness |
| `--demand <DEMAND>` | Existing search demand for the product/service: existing \| none (default existing) |
| `--signal-strength <SIGNAL_STRENGTH>` | Conversion-signal strength (PMax-readiness proxy): high \| medium \| low. Ignored when --customer is set (derived from trailing-30d conversions) |
| `--budget-daily <BUDGET_DAILY>` | Daily budget in account currency (broad-reach feasibility check) |
