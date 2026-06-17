---
name: agencyplaybook-cli-google
description: |
  AgencyPlaybook Google Ads CLI (`apb-gads`) — operator-grade command-line automation for Google Ads + Performance Max: read/report on accounts; run 63 diagnostic playbooks (account-health, waste-audit, campaign-bid-strategy-audit, pmax-audit, rsa-quality-audit, learning/scaling/turnaround audits); plan growth-first changes and execute them through a dry-run-first three-gate safety model; build greenfield Search & PMAX campaigns end-to-end (research → structure → RSA → validate → launch); manage keywords, negatives, bidding strategies, conversion actions, audiences, assets, and extensions via 116 gated mutations; run raw GAQL; schedule read-only audits. Covers all 276 commands across 26 groups against Google Ads API v24.

  USE WHEN the user mentions Google Ads, "apb-gads", "gads", "google ads cli", "agencyplaybook google", "apb google", PMAX / Performance Max, RSA / responsive search ads, smart bidding, tCPA / tROAS / target CPA / target ROAS, learning phase, search themes, brand exclusions, negative keywords, keyword planning, conversion value rules, bid adjustments / bid modifiers, account health, waste audit, scaling ad spend, campaign launch, ad-strength / ad rotation, quality score, impression share, dayparting, geo/device performance, GAQL, or wants ANY Google Ads account read, audit, plan, report, or change — even if they don't name the CLI. NOT for Meta/Facebook/Instagram ads (use the agencyplaybook-cli skill) or generic SEO.
---

# Modern Google Ads Operator (`apb-gads`)

Drive the `apb-gads` CLI — a safe, triple-gated Rust Google Ads operator tool — with the
judgment layer it doesn't ship with: which lever for which situation, in what order, framed
for growth, and never at the cost of a converged Smart-Bidding campaign.

**Division of labor.** The CLI owns the mechanics: **276 commands across 26 groups** —
116 gated mutations, 63 diagnostic playbooks, 23 reports — every write dry-run by default
behind three independent gates, every response JSON. This skill owns the *operating model*.
Never reimplement what the CLI does; orchestrate it, and read the references below for depth.

> Surface (verify with `apb-gads --help` / `apb-gads playbook list`): 26 groups · 276 leaf
> commands · 116 `mutate` subcommands · 63 playbooks (6 sections) · 23 reports · Google Ads
> **API v24**. The runtime is the source of truth — when a doc and the binary disagree, the binary wins.

## Routing — open the right reference for the task

Load `references/` files **as needed** (progressive disclosure — don't read them all up front):

| The user wants… | Read |
|---|---|
| Exact flags/params for a command ("what does `mutate campaign-budget-update` take?") | `references/commands/<group>.md` (one page per group — `mutate`, `playbook`, `report`, `plan`, `campaign`, …) |
| Switch which account commands target (agency multi-account: "use account X", "set/show current account") | `references/commands/account.md` (`account use`/`current`/`clear`/`list` — persists a current MCC child to `~/.apb-gads/state.json`; precedence `--customer` > persisted > config default) |
| To pick a playbook by symptom ("why won't this exit learning?", "find waste") | `references/playbook-catalog.md` (63 playbooks by section) |
| Turn a diagnosis into ONE decisive verb per campaign ("which should I scale / cap?") — SCALE / TIGHTEN / OPTIMIZE / CAP (/ HOLD / CUT) | `references/verdict-framework.md` |
| Choose the campaign TYPE for a goal ("Search, PMax, or Demand Gen?") | `references/campaign-type-selection.md` |
| The doctrine behind a recommendation (modifier×strategy, RSA stats, PMAX facts) | `references/doctrine.md` |
| Concrete command sequences for a goal (diagnose → plan → execute, launch, PMAX pass) | `references/workflows.md`, then `examples.md` |
| To run or reason about a mutation safely | `references/safety-model.md` (the three gates + sandbox + tiers) |
| Tier/scope/entitlement questions ("why 403?", "what does Agency unlock?") | `references/scopes.md` |
| Field-level limits (RSA char counts, PMAX assets, bid-modifier ranges) | `references/policy-limits.md` |
| "Will this write actually stick? is this field mutable in v24?" | `references/capability-matrix.md` |
| CI/CD or agent automation (exit codes, `--validate-only`, JSON, `--output`) | `references/automation.md` |
| The full command index | `commands.md` |

## Setup

The downloaded `apb-gads` binary already targets `https://api.agencyplaybook.io`. Connect a
Google Ads account once in the AgencyPlaybook dashboard (**Integrations → Connect Google Ads**;
requires the Google Ads add-on), then point the CLI at your API key:

```bash
mkdir -p ~/.apb
echo 'APB_API_KEY=apb_live_<tier>_<32hex>' > ~/.apb/.env   # key from the dashboard /api-keys page
B="apb-gads --pretty"
$B auth test && $B doctor check     # sanity: auth resolves + environment is healthy
$B customer list                    # the Google accounts your connection can reach
```

- Credentials resolve in order: shell env → project-local `.env` (cwd) → `~/.apb/.env` (global).
  Set `~/.apb/.env` once and the CLI works from any directory. Only set `APB_API_URL` to point
  at a non-default endpoint (self-hosting / local dev).
- **Select the operating account with the global `--customer <CID>` flag** — `<CID>` is a
  10-digit Google Ads customer id, **plain numeric, no dashes** (`1234567890`, not `123-456-7890`).
  If your connection reaches exactly one account it is auto-selected; the dashboard account
  picker sets it otherwise.
- **Output is always JSON.** `--pretty` only toggles indentation; pipe to `jq` for extraction.
  `--output <path>` writes the JSON to a file; `--lookback-days N` overrides any playbook's window.
- **Self-host / BYO** path (developers running their own token via `google-ads.yaml`): see
  `references/automation.md` § Self-hosting. The default public path is the SaaS broker above.

## The two prime directives

These come from the account owner and override generic optimization instinct:

1. **Growth-first. Never tell a scaler to shrink.** A $100/day account aiming at $1,000/day must
   not hear "cut to $20/day to save waste." Rank opportunities by growth headroom, pair every
   "cut X" with "redeploy into Y," and read `LIMITED_BY_BUDGET` as a *growth signal*, not a
   problem. The CLI bakes this in: `plan from-audit` defaults to growth-first ranking and
   `growth scale-up` is the headroom readout.
2. **Protect the learning phase.** The most expensive mistake on a trending Smart-Bidding
   campaign is a well-meaning change that resets learning (~50 conversions / 3 cycles Search;
   ~4-6 weeks PMAX). Before any bid/budget/strategy change, read the `learning_advisory` the CLI
   attaches to the dry-run envelope. Stay inside: target moves ≤10-15%, budget moves ≤15-20%,
   once or twice a month, never budget+target in the same change. Route full-reset moves through
   `mutate experiment-create` instead of mutating live.

## Core operating loop

```
DIAGNOSE → PLAN (growth-first) → CHANGE (dry-run → approve → execute) → LAUNCH (greenfield)
```

**The output of diagnosis is a verdict** — one decisive verb per campaign (**SCALE / TIGHTEN /
OPTIMIZE / CAP**, plus **HOLD / CUT**), derived from explicit pass/fail *gates* rather than a fuzzy
score. When the user asks "which campaigns should I scale / cap this week?", run the gate playbooks
and apply `references/verdict-framework.md`. For *which engine to build* (Search vs PMax vs Demand
Gen), see `references/campaign-type-selection.md`.

**1. Diagnose (always start here).** `references/workflows.md` § W1 has the full sequence; the spine is:

```
playbook account-health → playbook campaign-bid-strategy-audit → growth scale-up
→ (if PMAX present) playbook pmax-audit + report pmax-placements
→ (if Search present) playbook rsa-quality-audit
```

`campaign-bid-strategy-audit` reads the **authoritative** v24 `bidding_strategy_system_status`
enum — trust its `learning_now[]` / `growth_blockers[]` / `misconfigured[]` buckets over any
heuristic. `LEARNING_*` = hands off; `LIMITED_BY_BUDGET`/`LIMITED_BY_DATA` = scale or consolidate;
`MISCONFIGURED_*` = fix configuration first. Two traps: status is **independent of
`campaign.status`** (a PAUSED campaign can report `ENABLED`; at zero spend "converged" is
vacuous); and **zero-data accounts** legitimately return empty findings — read that as "no demand
signal yet," not a forced recommendation list. Pick playbooks by symptom from
`references/playbook-catalog.md`.

**2. Plan growth-first.** Feed an audit's `--output-spec` into the artifact pipeline:
`playbook <audit> --output-spec x.json` → `plan from-audit` (GrowthFirst ranking by default) →
`changes from-plan` → review → `changes apply` (dry-run) → gated `changes apply --execute`.
Present the plan ranked by upside, with each change's learning-phase cost stated.

**3. Change safely.** Every mutation is **dry-run by default**. The protocol is non-negotiable:
**dry-run → read the JSON plan + advisories → show the user → get explicit approval → re-run
with `--execute`** (+ the env gate; + `--confirm` above a profile threshold). See
`references/safety-model.md` for the three gates and the sandbox/profile policy. Never attempt to
bypass or hand-craft around a guard rejection — the rejection is the system working.

**4. Greenfield launch.** Search: `plan campaign full` (research→structure→RSA→spec) →
`validate campaign-spec` (exit 3 on fail — stop) → `orchestrate campaign-launch`. PMAX:
`plan campaign pmax` → `validate pmax-spec` → `orchestrate pmax-build` (atomic
budget→campaign→assets→asset groups→signals, then brand-exclusion + customer-acquisition tail).
Entities are born PAUSED; review before enabling. Full recipes in `examples.md`.

## Safety doctrine (apply to every mutation)

1. **Dry-run first.** Every `mutate`/`orchestrate`/`changes apply` write needs `--execute`.
   Without it the CLI prints the JSON plan it *would* submit and changes nothing.
2. **Three independent gates, no bypass flag.** `--execute` (CLI) **and** `safety.allow_writes:
   true`+`read_only: false` (config) **and**, when required, `APB_GADS_ALLOW_MUTATIONS=true`
   (env). Then a per-customer **profile** *or* the **sandbox** policy must authorize the specific
   op. Details + the SaaS read-only floor: `references/safety-model.md`.
3. **`--validate-only` proves wire shapes without writing.** With `--execute`+env it sets Google's
   `validateOnly=true` — server-side schema/policy/auth check that creates nothing. Use it before
   proposing a new payload shape on a real account (SERVER_VALIDATED tier).
4. **`--confirm` clears a profile's high-spend threshold** (`require_confirmation_above_micros`).
5. **Branch on exit code, not stdout text.** `0` ok · `1` runtime error · `2` usage error ·
   **`3` a `fail` verdict** from `validate campaign-spec` / `validate pmax-spec` / `mutate
   ad-validate`. So `apb-gads validate campaign-spec --from-file s.json && apb-gads orchestrate
   campaign-launch …` halts on a bad spec. See `references/automation.md`.
6. **Every executed write lands in `audit list`;** `mutate inverse-plan` builds the rollback.

## Reading results & capability reasoning

- **JSON is the contract.** Read specific keys with `jq` rather than dumping whole playbook
  envelopes (they carry large raw GAQL arrays). The high-value keys per command are in
  `references/workflows.md`.
- **Never claim a write persisted from a `200`/exit-0 alone.** Some v24 fields are accepted but
  silently not applied, write-only, or frozen at create. Before asserting a field changed, check
  `references/capability-matrix.md` (DRY_RUN / SERVER_VALIDATED / LIVE_VERIFIED per surface) and,
  for anything `accepted_unverified`, run a follow-up read (`<entity> get` / `report …` / `gaql`)
  and compare. Report "verified by readback" vs "accepted but not confirmable."
- **Customer IDs are plain numeric, no dashes.** `login_customer_id` is the MCC; `--customer` /
  `default_customer_id` is the operating account, which must be reachable under that login.

## PMAX guardrails & RSA quality (summary — full doctrine in `references/doctrine.md`)

- **PMAX:** brand-exclude non-brand PMAX (~99% of cases); seed first-party audience signals
  (Customer Match > remarketing > in-market); **≤25 search themes per asset group**; one theme
  per asset group, 3-7 groups by margin/objective (not by audience); watch `report pmax-placements`
  for junk; turn off Final URL expansion for lead-gen
  (`mutate campaign-update-url-expansion-opt-out`).
- **RSA:** 1 strong RSA per ad group; 8-10 sentence-case headlines (several <20 chars);
  descriptions 61-70 chars; **partial pinning only** (2-3 variants per pinned position); refresh
  **only on POOR** ad strength — AVERAGE with good CPA is healthy. Never rewrite a converting ad to
  chase "Excellent" (Ad Strength measures completeness, not performance). Field limits:
  `references/policy-limits.md`.

## Tiers & scopes

Google Ads is a paid **add-on** (`tenants.google_ads_addon=true`) layered on the apb tier. The 7
`*:google:*` scopes gate capability by tier: **reads** (campaigns/reports/playbooks/planning) at
**Professional+**, **writes** (mutations/verify) at **Agency+**, **scheduled automation** at
**Enterprise+**. A `403 insufficient_scope` (exit 3 on the API path) means the tier/add-on doesn't
cover it — see `references/scopes.md` for the full matrix and the upgrade path.

## Hard safety rules (binding)

- **Ask before any `--execute` against a real campaign.** No exceptions.
- **Test writes** go to a real, owned domain (never `example.com`/`test.com` — placeholder
  domains are an account-suspension signal), campaign names must contain `Test-ok-to-delete`, ads
  are born PAUSED, **max 1 test campaign per session** without explicit approval, pre-check for
  residue (`gaql` for non-REMOVED `Test-ok-to-delete*`) before creating, and clean up when done.
- **When a guard blocks a write, report it — never handcraft a workaround.** There is no bypass
  flag by design.
- **v24 is pinned.** Don't assume v25+ fields exist; the CLI rejects out-of-range inputs pre-API.

## Reference index

| File | What it covers |
|---|---|
| `references/commands/<group>.md` | Per-group command + flag reference (generated from the binary — accurate) |
| `references/playbook-catalog.md` | All 63 playbooks by section, with purpose + default window |
| `references/verdict-framework.md` | Gate-based decision verdicts — one verb per campaign (SCALE/TIGHTEN/OPTIMIZE/CAP/HOLD/CUT) |
| `references/campaign-type-selection.md` | Search vs PMax vs Demand Gen — when to use what (2026) |
| `references/doctrine.md` | Modern Google Ads doctrine cheat-sheet (Smart Bidding, learning, RSA, PMAX) |
| `references/workflows.md` | Concrete command sequences (W1-W7) + the output keys to read |
| `references/safety-model.md` | Three-gate write model, sandbox/profile policy, capability tiers |
| `references/scopes.md` | The 7 Google add-on scopes × tier matrix |
| `references/policy-limits.md` | Field-level limits (RSA / PMAX / extensions / URLs / bid modifiers) |
| `references/capability-matrix.md` | What v24 supports / what's been verified per mutation surface |
| `references/automation.md` | Exit codes, `--validate-only`, JSON contract, CI/agent patterns, self-hosting |
| `commands.md` | The 24-group command index |
| `examples.md` | Numbered canonical workflows (copy-paste, dry-run-first) |
