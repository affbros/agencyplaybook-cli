---
name: agencyplaybook-cli-google
description: |
  AgencyPlaybook Google Ads CLI (`apb-gads`) — operator-grade command-line automation for Google Ads + Performance Max: read/report on accounts; run 68 diagnostic playbooks (account-health, waste-audit, campaign-bid-strategy-audit, pmax-audit, rsa-quality-audit, learning/scaling/turnaround audits); plan growth-first changes and execute them through a dry-run-first three-gate safety model; build greenfield Search & PMAX campaigns end-to-end (research → structure → RSA → validate → launch); manage keywords, negatives, bidding strategies, conversion actions, audiences, assets, and extensions via 124 gated mutations; run raw GAQL; schedule read-only audits. Covers all 307 commands across 30 groups against Google Ads API v25.

  USE WHEN the user mentions Google Ads, "apb-gads", "gads", "google ads cli", "agencyplaybook google", "apb google", PMAX / Performance Max, RSA / responsive search ads, smart bidding, tCPA / tROAS / target CPA / target ROAS, learning phase, search themes, brand exclusions, negative keywords, keyword planning, conversion value rules, bid adjustments / bid modifiers, account health, waste audit, scaling ad spend, campaign launch, ad-strength / ad rotation, quality score, impression share, dayparting, geo/device performance, GAQL, or wants ANY Google Ads account read, audit, plan, report, or change — even if they don't name the CLI. NOT for Meta/Facebook/Instagram ads (use the agencyplaybook-cli skill) or generic SEO.
---

# Modern Google Ads Operator (`apb-gads`)

Drive the `apb-gads` CLI — a safe, triple-gated Rust Google Ads operator tool — with the
judgment layer it doesn't ship with: which lever for which situation, in what order, framed
for growth, and never at the cost of a converged Smart-Bidding campaign.

**Division of labor.** The CLI owns the mechanics: **307 commands across 30 groups** —
124 gated mutations, 68 diagnostic playbooks, 24 reports, MCC-wide portfolio roll-ups — every
write dry-run by default behind three independent gates, every response JSON. This skill owns
the *operating model*. Never reimplement what the CLI does; orchestrate it, and read the
references below for depth.

> Surface (verify with `apb-gads --help` / `apb-gads playbook list`): 30 groups · 307 leaf
> commands · 123 `mutate` subcommands · 68 playbooks (6 sections) · 24 reports · Google Ads
> **API v25**. The runtime is the source of truth — when a doc and the binary disagree, the binary wins.

## Routing — open the right reference for the task

Load `references/` files **as needed** (progressive disclosure — don't read them all up front):

| The user wants… | Read |
|---|---|
| Exact flags/params for a command ("what does `mutate campaign-budget-update` take?") | `references/commands/<group>.md` (one page per group — `mutate`, `playbook`, `report`, `plan`, `campaign`, …) |
| Switch which account commands target (agency multi-account: "use account X", "set/show current account") | `references/commands/account.md` (`account use`/`current`/`clear`/`list` — persists a current MCC child to `~/.apb-gads/state.json`; precedence `--customer` > persisted > config default) |
| To pick a playbook by symptom ("why won't this exit learning?", "find waste") | `references/playbook-catalog.md` (68 playbooks by section) |
| Do a whole recurring job end-to-end ("clean up my search terms", "what's wasting spend and what should I promote?") | `references/commands/recipe.md` — `recipe list` / `recipe describe <name>` / `recipe search-terms`; the SOP paragraph is § *Recipes* below |
| **Build** a new campaign from a brief ("set up a search campaign for X", "build me a keyword list with ads and negatives", "launch a new campaign") | `references/commands/recipe.md` — `recipe build`; the SOP is § *Build a whole campaign from a brief* below |
| Turn a diagnosis into ONE decisive verb per campaign ("which should I scale / cap?") — SCALE / TIGHTEN / OPTIMIZE / CAP (/ HOLD / CUT) | `references/verdict-framework.md` |
| Choose the campaign TYPE for a goal ("Search, PMax, or Demand Gen?") | `references/campaign-type-selection.md` |
| The doctrine behind a recommendation (modifier×strategy, RSA stats, PMAX facts) | `references/doctrine.md` |
| Concrete command sequences for a goal (diagnose → plan → execute, launch, PMAX pass) | `references/workflows.md`, then `examples.md` |
| To run or reason about a mutation safely | `references/safety-model.md` (the three gates + sandbox + tiers) |
| Operate safely across MULTIPLE client accounts ("set guardrails per client", "run changes across all accounts safely", "did I edit the wrong customer?") | `references/agency-guardrails.md` (two-dial model, per-write right-customer/domain/brand/budget checks, batch review-the-exceptions, override/boundary rules) |
| Tier/scope/entitlement questions ("why 403?", "what does Agency unlock?") | `references/scopes.md` |
| Field-level limits (RSA char counts, PMAX assets, bid-modifier ranges) | `references/policy-limits.md` |
| "Will this write actually stick? is this field mutable in v25?" | `references/capability-matrix.md` |
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

`campaign-bid-strategy-audit` reads the **authoritative** v25 `bidding_strategy_system_status`
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
**`CampaignLaunchSpec` v2 (0.1.21+)** carries the whole build — extra RSAs, geo extras, ad
schedules, device modifiers, audiences, shared sets, sitelinks/callouts, tracking, network
settings, conversion goals, portfolio bidding — applied by eight sequential tail stages, so a
launch leaves no hand-run checklist. A partial failure stops the tail, leaves the campaign PAUSED
and **still exits 0** — read `.status`, then undo with `orchestrate rollback --from-receipt`.
Blocks, formats, the pre-flight refusals and the ≤0.1.20 silent-drop trap:
`references/workflows.md` § W6b.

## Recipes — one verb for a whole job

A **playbook finds**; a **recipe decides and packages**. When the user asks for an OUTCOME rather
than a diagnosis — "clean up my search terms", "what am I wasting money on and what should I add
as keywords?" — reach for a recipe first: it reads the account's own targets and standing rules,
classifies every row, and hands back a plan you can show them.

**The SOP is three steps: run the recipe, read the summary, explain the review bucket.**

```bash
$B --customer <CID> recipe list                       # what exists
$B --customer <CID> recipe describe search-terms      # the decision rules, verbatim from the code
$B --customer <CID> recipe search-terms --lookback-days 30 \
     --out build/search-terms --format all --plan build/search-terms/plan.html
```

1. **Run it.** Dry-run by default; it writes `review.json` (+ CSVs with `--format all`) and, with
   `--plan`, the envelope / review page / document.
2. **Read the summary.** It is on **stderr** and in the JSON's `summary[]`. The header prints the
   DERIVED thresholds and the formula behind them ("waste ≥ USD 20.00 & 0 conv · promote ≥ 3 conv
   at ≤ USD 10.00 (2.00 × target CPA 10.00)"). Quote those numbers to the user — they are the
   argument for every row that follows. Money is always in the account's currency.
3. **Explain the review bucket.** `review` is where the recipe deliberately did NOT act: brand
   terms (never negated or auto-promoted), terms served from 2+ ad groups (ambiguous attribution),
   PMAX search-term insight rows (category-level — informational only), and anything inside the
   review band. Walk the user through `review.json`'s reasons and ask for a decision; do not
   quietly promote the band.

**Prerequisites and refusals.** A recipe stops loudly with `context_missing: brand.terms` rather
than guessing a brand from campaign names. Set it up once:

```bash
$B --customer <CID> context init --mode target_cpa --target-cpa 15 \
     --brand-term "<brand>" --brand-competitor "<competitor>" \
     --canonical-negative-set <sharedSetId>
```

**Applying.** `--execute` hands the recipe's envelope to `mutate apply-plan` — the same three
gates, no new write path — and a plan above 200 actions also needs `--confirm`. Tune, don't
override: `--threshold-override waste_multiplier=3.0` (also `promote_min_conversions`,
`review_band_pct`, `spend_floor`), or persist per-customer values in
`context.recipes.search_terms`. Full doctrine: `references/commands/recipe.md`.

## Build a whole campaign from a brief — `recipe build`

When the user wants something **built** rather than diagnosed — "set up a search campaign for X",
"build me a keyword list with ads and negatives", "launch a new campaign" — the verb is
`recipe build`. It runs the whole expert pipeline (research → structure → copy → targeting →
assets → bidding → validate → plan) from ONE input, the **brief**, and launches nothing unless
asked. Full doctrine: `references/commands/recipe.md`; operator doc `docs/recipes-build.md`.

**The SOP is four steps: write the brief, dry-run it, review the plan, then ask before launching.**

```bash
# 1. dry-run the whole build (nothing reaches the account)
$B --customer <CID> recipe build --brief briefs/<slug>.yaml --out build/

# 2. inspect a single stage while iterating
$B --customer <CID> recipe build --brief briefs/<slug>.yaml --out build/ --stage research

# 3. re-run a hand-edited spec (same spec_hash, same plan digest)
$B --customer <CID> recipe build --spec build/spec.v2.json --out build/v2

# 4. server-validate the whole launch body — still creates nothing
$B --customer <CID> recipe build --brief briefs/<slug>.yaml --validate-only

# 5. ONLY after an explicit human YES: launch it, born PAUSED
$B --customer <CID> recipe build --brief briefs/<slug>.yaml --out build/ --execute
$B --customer <CID> orchestrate rollback --from-receipt build/launch.json     # the undo
```

1. **Write the brief.** Minimum: `customer_id`, `business.landing_page`, `goals.mode` +
   its target, `goals.daily_budget`, `research.seed_keywords` (or `seed_url`), and
   `targeting.geo.include`. Curation lives in `structure.max_ad_groups`,
   `research.exclude_intents` and `research.match_type_policy` — set them; the defaults do not
   curate.
2. **Read the summary.** On **stderr** and in the JSON's `summary[]`: research counts, ad groups,
   keyword match-type mix, copy source, targeting, negatives, assets, goals, the validation
   verdict, and what was written.
3. **Review the plan, not the spec.** `build/plan.md` (or `plan.html`, which you can send to a
   client) renders the same plan-envelope-v2 document `plan.json` carries. `research/keywords.json`
   answers "why isn't <keyword> in here?" — every candidate has a decision and a reason.
4. **Ad copy is the user's call.** `--provider heuristic` (the default) produces **starter copy**
   and the tool flags it `starter_copy: true`. Say so out loud, and offer the expert path: write
   the copy into the brief under `copy.headlines` / `copy.descriptions` with
   `copy.provider: agent` (the `agencyplaybook-planner` skill exists for exactly this). Never
   describe heuristic copy as written-for-them.

**Refusals are information, not obstacles.** `brief_invalid: <field>` names the field to fix. A geo
/ shared set / conversion action / audience name that matches zero or many rows fails with the
candidates listed — show the user the candidates and ask which they meant; never pick for them. A
`--type pmax` build refuses by name any brief block PMAX has no equivalent for. A failing
validation exits **3** and emits no plan.

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

### `--plan` (plan-first) — hand the user a readable plan

The global `--plan <path>` flag means **"plan it, don't do it."** On any mutating command,
orchestrator, or playbook it runs the full dry-run pipeline and writes a **plan-envelope-v2**
document — with **zero** API mutation. Use it to give the user (or their client) something to
approve before anything is applied.

- **The extension picks the artifact:**
  - `<path>.json` → the machine envelope alone (`schema_version: 2`, re-playable via
    `mutate apply-plan`);
  - `<path>.html` → the **review page** — a self-contained, print-ready page a client can read;
  - `<path>.md` → the human plan document plus its `<path>.md.json` envelope twin;
  - any other path → `<path>.md` + `<path>.json` (the original pair).
- `--plan` **cannot** be combined with `--execute` (hard error naming both flags).
- `orchestrate campaign-launch --plan build.json` yields the **whole build** as create ops (budget →
  campaign → ad groups → ads → keywords, then every v2 tail stage), each action carrying its stage,
  its dependencies, and the exact Google operation in `preview`. `plan from-audit --plan` carries the
  ActionPlan's priority / impact / growth / confidence / risk / effort into each action's `score`.
- A playbook with no actionable operations writes an explicit *empty-plan* doc (not an error); a
  pure read warns "nothing to plan" and runs normally.
- `mutate apply-plan` **dry-runs every action** in a v2 plan. It refuses `--execute` on a BUILD plan
  (one whose actions target temp references): those only resolve inside the atomic mutate
  `orchestrate campaign-launch --execute` assembles — the plan is that launch's reviewable preview.
- The plan file is **input, not consent** — applying it re-runs every gate, and is itself validated
  as untrusted input: unknown `schema_version` is rejected, a hand-edited file fails the `plan_hash`
  check, and recorded prior values are re-read to detect drift. A hash mismatch needs
  `--allow-edited-plan`; detected drift needs `--allow-stale-plan` (both explicit, audited). Prefer
  re-running `--plan` to refresh a stale plan over overriding.

```sh
# 1. Plan (writes waste.md + waste.md.json, touches nothing):
apb-gads --customer 1234567890 playbook waste-audit --plan waste.md
# 1b. …or hand them a review page instead:
apb-gads --customer 1234567890 playbook waste-audit --plan waste.html
# 2. Show the user waste.md (or waste.html), get explicit approval, then apply:
apb-gads mutate apply-plan --from-file waste.md.json --execute
#    (refuses if the file was edited after step 1, or if the account drifted since;
#     override with --allow-edited-plan / --allow-stale-plan only with the user's OK.)
```

`--save-plan` is the **deprecated** predecessor (JSON only, no document) — prefer `--plan`.

### Handing a plan to AgencyPlaybook, and picking one back up

**CLI → SaaS.** A `<path>.json` plan-envelope-v2 document (`recipe build`, `mutate apply-plan
--plan`, `orchestrate campaign-launch --plan`, `plan merge`) imports via `POST
/api/v1/gads/plans/import` and lands on the tenant's Plans page at **`/plans/<id>`** (same route
as Meta — there is no separate `/gads/plans/<id>` page). Approve there, or drive it through the
MCP: `gads_export_plan` mints the token + imports it, then `gads_execute_plan` approves + executes
+ polls to a terminal state.

**SaaS → CLI.** There is no `plan get` on this binary — pull a stored Google plan down via the MCP
(`agency_export_plan { channel:"google", plan_id }` → write `envelope` to `plan.json`) or a direct
`GET /api/v1/gads/plans/:id` (Bearer `APB_API_KEY`), then dry-run before applying for real:

```sh
# after writing plan.json (from agency_export_plan or a GET /gads/plans/:id):
apb-gads mutate apply-plan --from-file plan.json --validate-only     # dry run
apb-gads mutate apply-plan --from-file plan.json --execute           # the three-gate safety model
apb-gads plan export --from-file plan.json --format editor-csv --out build/   # or --format html
```

`plan_hash` is re-verified on apply — a hand-edited file needs `--allow-edited-plan`; say so
explicitly rather than adding it silently. If the envelope still carries `{{ref:aN}}` /
`{{account}}` placeholders, never substitute them by hand — the SaaS job runner and this binary
both bind them at run time from one ref map per run.

**CLI-only planning verbs** (no MCP tool beyond the three read-class producers
`agency_build_plan`/`agency_merge_plans`/`agency_forecast_plan`): `plan merge --from a.json --from
b.json --mode growth|efficiency --horizon <days>` (N envelopes → one ranked, wave-sequenced
envelope — never strip the `wait-for-status` pseudo-actions between waves; `conflicts[]` needs a
human to settle), `plan forecast --spec build/spec.v2.json` / `--campaign-id <id>
--budget-scenarios 50,75,100` (delivery estimates, read-only), `portfolio plan` (cross-account),
`experiment results --experiment-id <id>` / `experiment promote --id <id>` (A/B verdict and
graduation).

## Reading results & capability reasoning

- **JSON is the contract.** Read specific keys with `jq` rather than dumping whole playbook
  envelopes (they carry large raw GAQL arrays). The high-value keys per command are in
  `references/workflows.md`.
- **Never claim a write persisted from a `200`/exit-0 alone.** Some v25 fields are accepted but
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
- **Retail readiness (Shopping/PMAX with `--merchant-id`):** run `playbook feed-health-audit`
  **before and after** `plan campaign pmax --merchant-id` — before, to confirm the feed has
  serving inventory (a disapproved-heavy feed wastes the new campaign's budget from day one);
  after, to confirm status didn't regress once traffic starts. It's Path A only (the Ads API
  `shopping_product` resource, existing `adwords` scope — no Merchant Center API), so it reports
  the real `ELIGIBLE`/`ELIGIBLE_LIMITED`/`NOT_ELIGIBLE` status set, not Merchant-Center-native
  PENDING/EXPIRING granularity. Pair it with `playbook shopping-feed-segmentation-audit` for
  listing-group filter coverage.
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
- **v25 is pinned** (bumped from v24 on 2026-09-08; v24 stays served by Google until May 2027). Don't assume v26+ fields exist; the CLI rejects out-of-range inputs pre-API. 🔴 The v25 bump is **BREAKING** for customer-acquisition goals — see `references/capability-matrix.md` § Goal migration.

## Batch scripts (the watchful eye)

A downloadable library of thin bash wrappers around `apb-gads` encodes how a disciplined operator runs a Google Ads account: **watch constantly, change rarely, no decision without sufficient data.** They are samples users run with their own credentials — the intelligence stays in the binary; each script is auditable in 60 seconds.

Three cadence tiers plus a shared library:

- **Tier 1 — Watchdogs** (daily, strictly read-only): `watch-account-pulse.sh`, `watch-budget-pacing.sh`, `watch-policy-flags.sh`, `watch-tracking-health.sh`, `watch-learning-phase.sh`, `watch-fatigue.sh`, `watch-anomalies.sh`. They observe and alert (exit 10 = attention items) and never propose a change — a daily finding is flagged for the weekly review. Because they are read-only by construction, they register cleanly with the native scheduler.
- **Tier 2 — Opportunity scans** (weekly, read-only analysis): `scan-scaling-readiness.sh`, `scan-waste.sh`, `scan-audience-health.sh`, `scan-creative-refresh.sh`, `scan-structure-hygiene.sh`, `scan-query-mining.sh`, `scan-search-terms.sh`, plus `check-sufficiency.sh`. Anything actionable renders as a plan document, gated by the data-sufficiency floor, a cooldown check, and learning-phase protection (entities still learning are watch-only).
- **Tier 3 — Reviews** (weekly/monthly, the only tier that proposes): `weekly-review.sh`, `monthly-strategic-review.sh`, `budget-rebalance.sh`, and `plan-then-apply.sh`.
- **Audit bundles** (`audit-full.sh` + sectioned `audit-*.sh` such as `audit-pmax.sh`, `audit-keywords.sh`, `audit-audience.sh`) run every read-only diagnostic playbook into a timestamped results dir.
- **Shared library** (`lib/common.sh`, `lib/sufficiency.sh`, `lib/cooldown.sh`) and the tunable `thresholds.conf` — defaults mirror the binary's own metric-policy constants so scripts and playbooks agree on what "enough data" means.

**Safety posture:** shipped scripts **never** write. The single sanctioned write path is `plan-then-apply.sh`, which is interactive — it opens a plan document and makes you type the apply command's confirmation yourself. Every proposed change is a plan document you (or a client) read and approve before anything touches the account.

**Where to get them:** the in-app **Scripts** page (`/scripts`), or the public repo under `scripts/gads/` (<https://github.com/affbros/agencyplaybook-cli/tree/main/scripts/gads>). The `/scripts` page reads a live catalogue, so each card's description, cadence, and safety badge come straight from the script's own manifest header.

## Reference index

| File | What it covers |
|---|---|
| `references/commands/<group>.md` | Per-group command + flag reference (generated from the binary — accurate) |
| `references/playbook-catalog.md` | All 68 playbooks by section, with purpose + default window |
| `references/verdict-framework.md` | Gate-based decision verdicts — one verb per campaign (SCALE/TIGHTEN/OPTIMIZE/CAP/HOLD/CUT) |
| `references/campaign-type-selection.md` | Search vs PMax vs Demand Gen — when to use what (2026) |
| `references/doctrine.md` | Modern Google Ads doctrine cheat-sheet (Smart Bidding, learning, RSA, PMAX) |
| `references/workflows.md` | Concrete command sequences (W1-W7) + the output keys to read |
| `references/safety-model.md` | Three-gate write model, sandbox/profile policy, capability tiers |
| `references/scopes.md` | The 7 Google add-on scopes × tier matrix |
| `references/policy-limits.md` | Field-level limits (RSA / PMAX / extensions / URLs / bid modifiers) |
| `references/capability-matrix.md` | What v25 supports / what's been verified per mutation surface |
| `references/automation.md` | Exit codes, `--validate-only`, JSON contract, CI/agent patterns, self-hosting |
| `commands.md` | The 27-group command index |
| `examples.md` | Numbered canonical workflows (copy-paste, dry-run-first) |
