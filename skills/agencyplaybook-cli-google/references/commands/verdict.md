# `apb-gads verdict`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Per-campaign decision verdict — one verb (SCALE / OPTIMIZE / TIGHTEN / CAP / HOLD / CUT) per ENABLED campaign across ALL channel types, from 3 gates (Efficiency / Delivery+headroom / Quality). Read-only; emits a queue ranked by spend. Targets resolve `--target-*` > context goals. See verdict-framework doctrine

**Surface:** 👁️ Read-only · **1 command(s)** · [← back to index](README.md)

---

<a id="apb-gads-verdict"></a>
## `apb-gads verdict`

Per-campaign decision verdict — one verb (SCALE / OPTIMIZE / TIGHTEN / CAP / HOLD / CUT) per ENABLED campaign across ALL channel types, from 3 gates (Efficiency / Delivery+headroom / Quality). Read-only; emits a queue ranked by spend. Targets resolve `--target-*` > context goals. See verdict-framework doctrine

**Usage**

```
Usage: apb-gads verdict [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--target-roas <TARGET_ROAS>` | Target ROAS for the Efficiency gate (overrides campaign/context target) |
| `--target-cpa <TARGET_CPA>` | Target CPA in account currency for the Efficiency gate (overrides campaign/context) |
| `--min-age-days <MIN_AGE_DAYS>` | Maturity floor — min age in days before a campaign is judged (default 30) |
| `--min-conversions <MIN_CONVERSIONS>` | Maturity floor — min conversions before a campaign is judged (default 50) |
| `--queue` | Rank the verdicts into a decision queue ($ impact/day + next-action + reallocation) |
| `--include-paused` | Also judge PAUSED campaigns (reactivation / post-mortem lens). Paused campaigns carry delivery "n/a" so SCALE can't fire; read OPTIMIZE=relaunch, CUT=correctly killed |
