# apb-gads Usage Guide

Task-oriented, end-to-end guide for managing Google Ads + Performance Max with the `apb-gads`
CLI. It assumes you've already installed the binary and connected Google Ads — if not, start at
[`GETTING_STARTED.md`](GETTING_STARTED.md).

`apb-gads` is built around three habits, and every workflow below leans on them:

- **Growth-first.** The diagnostics lead with where you have efficient headroom to *grow* — budget-limited winners, expansion-ready campaigns, search terms to promote — ranked by upside, never by cuts. A waste audit exists to *redeploy* spend, not to shrink the account.
- **Learning-phase-aware.** Google's Smart Bidding has a learning phase, and careless edits reset it. The CLI reads the authoritative `bidding_strategy_system_status` and attaches a `learning_advisory` to every bid/budget dry-run so you can see the reset cost before you pay it.
- **Dry-run-first.** Every `mutate` / `orchestrate` / `changes apply` write is dry-run by default. You read the planned request body (and its advisories), show the user, get approval, and only then re-run with `--execute`. There is no bypass.

Conventions used throughout:

- **Output is always JSON.** `--pretty` only toggles indentation — pipe to `jq` for extraction.
- **`<CID>`** is the operating Google Ads customer id: a 10-digit number, **plain numeric, no dashes** (`1234567890`, not `123-456-7890`). Set it with the global `--customer <CID>` flag.
- Placeholders you'll substitute: `<CID>`, `<CAMPAIGN_ID>`, `<AD_GROUP_ID>`, `<BUDGET_ID>`, `<ASSET_GROUP_ID>`, `/tmp/spec.json`, `https://www.yourbrand.com`.
- For brevity many blocks set `B="apb-gads --pretty --customer <CID>"` and then run `$B <command>`.

---

## Quick Start

### Prerequisites

- The `apb-gads` binary on your `PATH` (`apb-gads --version`).
- An AgencyPlaybook API key (`apb_live_<tier>_<32hex>` from the dashboard `/api-keys` page).
- The Google Ads **add-on** enabled on your tenant and a Google account connected in the web dashboard (one-time consent + account picker). The CLI authenticates with your API key — it never holds Google credentials of its own.

### Setup

```bash
# Store your key where the CLI reads it from any directory.
mkdir -p ~/.apb
echo 'APB_API_KEY=apb_live_<tier>_<32hex>' > ~/.apb/.env
```

Credentials resolve **shell env → project-local `.env` → `~/.apb/.env`** (first match wins). The
downloaded binary already targets `https://api.agencyplaybook.io`; only set `APB_API_URL` for
self-hosting / local dev. Full setup detail (install, dashboard connect, account picker) is in
[`GETTING_STARTED.md`](GETTING_STARTED.md).

### Verify

```bash
apb-gads --pretty auth test       # the APB_API_KEY → /auth/resolve chain works + a Google token came back
apb-gads --pretty doctor check    # environment + config sanity (creds, write-gate posture)
apb-gads --pretty customer list   # the Google Ads accounts your connection can reach
```

`auth test` exit 0 means you're connected. A `403` on `customer list` means the Google Ads add-on
isn't enabled on the tenant. `customer list` is also how you discover the `<CID>` values — if your
connection reaches exactly one account it auto-selects.

### Select the account

Pass the operating account on every command with the global `--customer <CID>` flag:

```bash
apb-gads --pretty --customer <CID> playbook account-health
```

---

## The operating loop

Real account work follows a **DIAGNOSE → PLAN → CHANGE → LAUNCH** loop. *Diagnose* read-only
playbooks to find both growth headroom and waste; *plan* by turning an audit into a scored, ranked
artifact (or assembling a greenfield launch spec); *change* live entities through the dry-run →
review → `--execute` protocol under the three gates; *launch* greenfield campaigns from a validated
spec. The diagnosis spine you run first, always, on any account:

```bash
B="apb-gads --pretty --customer <CID>"
$B playbook account-health                  # health scorecard + recommended next actions
$B playbook campaign-bid-strategy-audit     # AUTHORITATIVE bidding_strategy_system_status buckets
$B playbook anomaly-detection               # week-over-week spend/clicks/conv change alerts
$B growth scale-up                          # efficient headroom to GROW, ranked by upside
```

A zero-spend or brand-new account legitimately returns empty findings — read that as "no demand
signal yet," not a forced to-do list.

---

## Workflows

### 1. Daily / weekly health check

```bash
B="apb-gads --pretty --customer <CID>"

$B playbook account-health | jq '{score: .score, counts: .summary.campaign_counts, actions: .recommendations}'
$B playbook campaign-bid-strategy-audit | jq '{learning_now, growth_blockers, misconfigured, by_channel}'
$B playbook anomaly-detection --lookback-days 14
```

Read the **bid-strategy audit first** — it reads the authoritative v24
`bidding_strategy_system_status`, and its buckets dictate what you may touch this session:
`learning_now[]` campaigns are **off-limits** (let them converge), `growth_blockers[]`
(`LIMITED_BY_BUDGET` / `LIMITED_BY_DATA`) are where the growth plan starts, and `misconfigured[]`
must be fixed before any optimization. Trust these buckets over any heuristic. The `account-health`
`.score` is a 0-100 heuristic — don't over-read it; `anomaly-detection` flags newly-active and
newly-dark campaigns so a paused winner or a runaway spender surfaces fast.

> **Trap:** `bidding_strategy_system_status` is independent of `campaign.status` — a PAUSED campaign
> usually still reports `ENABLED` here, and at zero spend "converged" is vacuous. Always read it
> next to campaign status and actual spend.

### 2. Find and redeploy waste

```bash
B="apb-gads --pretty --customer <CID>"

# Spend leaks framed as redeployment opportunities, not cuts.
$B playbook waste-audit --lookback-days 90 | jq '.findings'

# Token-stem clusters of zero-conversion queries (≥ $200 combined) → mutation-ready negative spec.
$B playbook waste-cluster-audit --output-spec /tmp/spec.json | jq '.clusters'

# DRY-RUN the bulk negative-keyword add (no --execute → nothing is submitted).
$B mutate negative-keyword-add-bulk --from-file /tmp/spec.json

# Approve, then re-run with both write gates.
APB_GADS_ALLOW_MUTATIONS=true $B mutate negative-keyword-add-bulk --from-file /tmp/spec.json --execute
```

`waste-cluster-audit` writes a spec that `mutate negative-keyword-add-bulk --from-file` consumes
natively — no reshaping. The **point is redeployment**: every dollar a negative keyword frees should
fund a `growth scale-up` opportunity, not just lower the bill. Bulk mutations pre-validate every
item and reject the whole batch on any failure, so one malformed row can't half-apply.

### 3. Scale decision (the learning-phase guardrails)

```bash
B="apb-gads --pretty --customer <CID>"

# Where you have efficient headroom to grow, ranked by upside.
$B growth scale-up --min-roas 3.0 | jq '.'

# Campaigns under sustained budget pressure (lost-IS > 10%) AND high ROAS = lift candidates.
$B playbook expansion-readiness | jq '.candidates'
```

A `growth scale-up` opportunity in the `LIMITED_BY_BUDGET` bucket is the cleanest scale signal there
is. Stay inside the guardrails when you actually raise budgets or move targets:

- **Budget moves ≤ 15-20%**, **target moves ≤ 10-15%**, once or twice a month.
- **NEVER change budget and target in the same change** — Google treats that as a guaranteed full learning reset. Split them across sessions.
- A campaign in `learning_now[]` is off-limits — wait for `ENABLED` or route a strategy-type change through an experiment (`mutate experiment-create`).

Anything bigger than the guardrails should go through an experiment, not a live mutation. See
Workflow 4 for the actual bid/budget change under the advisory.

### 4. Bid-strategy review (modern levers)

```bash
B="apb-gads --pretty --customer <CID>"

# 1. State of play — which campaigns are mid-learning, which are ready to move.
$B playbook campaign-bid-strategy-audit | jq '.learning_now'

# 2. Per-campaign 0-90 readiness for moving from manual CPC to tCPA / tROAS.
$B playbook smart-bidding-readiness | jq '.campaigns'

# 3. DRY-RUN a tROAS nudge and READ will_reset_learning before approving.
$B mutate campaign-update-bidding-strategy --campaign-id <CAMPAIGN_ID> \
  --strategy-type TARGET_ROAS --target-roas 3.5 | jq '.learning_advisory'

# 4. Approved + inside the guardrail → execute.
APB_GADS_ALLOW_MUTATIONS=true $B mutate campaign-update-bidding-strategy --campaign-id <CAMPAIGN_ID> \
  --strategy-type TARGET_ROAS --target-roas 3.5 --execute
```

The single most important field on any bid/budget dry-run is
`learning_advisory.will_reset_learning` (`no` → proceed after approval; `likely` → take the smaller
step it suggests; `yes` → use an experiment instead). Under Smart Bidding, **manual bid adjustments
are dead** — geo/device/audience/schedule modifiers are ignored by the value/conversion strategies.
The modern replacement for value-based bidding is the **conversion value rule**: adjust the
conversion *value* Smart Bidding optimizes toward, by geo/device/audience (Max Conv Value / tROAS
only):

```bash
# DRY-RUN: multiply conversion value by 1.2x for US traffic (replaces an old +20% geo bid mod).
$B mutate conversion-value-rule-create --dimension geo --geo-target-id 2840 --value 1.2

APB_GADS_ALLOW_MUTATIONS=true $B mutate conversion-value-rule-create --dimension geo --geo-target-id 2840 --value 1.2 --execute
```

Note: value rules **inflate reported conversion value** — call that out when you read the results.

### 5. Negative-keyword hygiene

```bash
B="apb-gads --pretty --customer <CID>"

# Surface negative-keyword candidates from search terms (with ad-group context).
$B playbook search-term-cleanup --limit 50 --output /tmp/spec.json

# DRY-RUN the bulk add — this command reads search-term-cleanup's {candidate_actions:[...]} directly.
$B mutate negative-keyword-add-bulk --from-file /tmp/spec.json

# Approve → apply.
APB_GADS_ALLOW_MUTATIONS=true $B mutate negative-keyword-add-bulk --from-file /tmp/spec.json --execute

# For campaign-level negatives instead, hand-author an items file:
#   {"items":[{"campaign_id":"<CAMPAIGN_ID>","text":"free","match_type":"PHRASE"}, ...]}
APB_GADS_ALLOW_MUTATIONS=true $B mutate campaign-negative-keyword-add-bulk --from-file /tmp/items.json --execute
```

`search-term-cleanup` writes a `candidate_actions[]` spec that the ad-group-level bulk add consumes
with no reshaping. Campaign-level negatives go up to **10,000 per campaign** and block Search +
Shopping only — Display/YouTube junk needs placement/topic exclusions.

### 6. RSA quality + refresh (POOR-only)

```bash
B="apb-gads --pretty --customer <CID>"

# 1. Find ads that actually need a refresh — only POOR ad strength qualifies.
$B playbook rsa-quality-audit --output-spec /tmp/spec.json | jq '.rsa_refresh_candidates'

# 2. Validate the proposed copy locally (no API) — exit 3 on a fail verdict.
$B mutate ad-validate --from-file /tmp/spec.json

# 3. DRY-RUN the refresh: creates a NEW RSA (born PAUSED), recommends a pause target.
$B orchestrate ad-refresh --ad-group-id <AD_GROUP_ID> \
  --headline "Fast same-day delivery" --headline "Order before 3pm" --headline "Free returns" \
  --description "Shipped from our local warehouse for next-day arrival." \
  --description "30-day no-questions returns on every order." \
  --final-url https://www.yourbrand.com

# 4. Approve → create the new ad and pause the fatigued one (destructive → global --confirm).
APB_GADS_ALLOW_MUTATIONS=true $B orchestrate ad-refresh --ad-group-id <AD_GROUP_ID> \
  --headline "Fast same-day delivery" --headline "Order before 3pm" --headline "Free returns" \
  --description "Shipped from our local warehouse for next-day arrival." \
  --description "30-day no-questions returns on every order." \
  --final-url https://www.yourbrand.com \
  --pause-ad-id <OLD_AD_ID> --execute --confirm
```

**Refresh only on POOR strength.** Ad Strength measures structural *completeness*, not performance —
"Average" with a good CPA is healthy, so never rewrite a converting ad to chase "Excellent."
`ad-refresh` creates a **new** ad rather than editing in place, because heavy in-place edits reset
policy review and break history. Copy rules baked into validation: sentence case (Title Case is
~3.7× worse CPA), 8-10 unique headlines with several < 20 chars, descriptions 61-70 chars, partial
pinning only. Pausing the old ad is destructive, so it needs the global `--confirm` on top of the
gates.

### 7. PMAX guardrails

```bash
B="apb-gads --pretty --customer <CID>"

# Where PMAX ran (impressions-only) + the channel proxy + an honest list of v24 visibility limits.
$B playbook pmax-audit | jq '.diagnostics.findings[].flags'
$B report pmax-placements --limit 50

# Junk-placement webpage exclusions (the substitute for v24-removed url_expansion controls).
$B playbook pmax-url-exclusion-audit --output-spec /tmp/spec.json
$B mutate campaign-negative-webpage-add-bulk --from-file /tmp/spec.json                       # dry-run
APB_GADS_ALLOW_MUTATIONS=true $B mutate campaign-negative-webpage-add-bulk --from-file /tmp/spec.json --execute

# Brand exclusions on non-brand PMAX (~99% of cases — PMAX over-credits brand).
$B customer suggest-brands --prefix "<COMPETITOR>"                                            # get the brand MID
$B mutate shared-set-create --name "Brand exclusions" --type BRANDS                            # dry-run
APB_GADS_ALLOW_MUTATIONS=true $B mutate shared-set-create --name "Brand exclusions" --type BRANDS --execute
APB_GADS_ALLOW_MUTATIONS=true $B mutate shared-criterion-add --shared-set-id <BRANDS_SET_ID> --criterion-type BRAND --brand-id <MID> --execute
APB_GADS_ALLOW_MUTATIONS=true $B mutate campaign-brand-list-exclude --campaign-id <CAMPAIGN_ID> --shared-set-id <BRANDS_SET_ID> --execute

# Turn off Final URL expansion for lead-gen / landing-page control.
APB_GADS_ALLOW_MUTATIONS=true $B mutate campaign-update-url-expansion-opt-out --campaign-id <CAMPAIGN_ID> --execute

# Seed a search-theme signal — the CLI rejects a 26th (cap is 25 per asset group).
APB_GADS_ALLOW_MUTATIONS=true $B mutate pmax-audience-signal-attach \
  --asset-group-id <ASSET_GROUP_ID> --signal-type SEARCH_THEME --text "same day delivery" --execute
```

`report pmax-placements` is honest about v24's black box — it shows impressions only; per-channel
spend split is script-only territory — then names the mitigation writes above. Doctrine: one theme
per asset group (segment by margin/objective, **not by audience signal**); search themes cap at **25
per asset group** and the CLI fails pre-API on a 26th; final URL expansion is ON by default — opt
out for lead-gen control.

### 8. Greenfield Search launch

```bash
B="apb-gads --pretty --customer <CID>"

# 1. Assemble launch-ready CampaignLaunchSpecs from research → structure → RSA (read-only, launches nothing).
$B plan campaign full --seed-keywords "running shoes,trail runners" \
  --landing-page https://www.yourbrand.com --daily-budget 100 --mode ecommerce \
  --brand "YourBrand" --export-dir /tmp/launch

# 2. Validate the spec — a fail verdict prints its report and exits 3, halting any chained launch.
$B validate campaign-spec --from-file /tmp/launch/<campaign>.json

# 3. DRY-RUN the launch (budget → campaign → ad group → RSA → keywords; entities born PAUSED).
$B orchestrate campaign-launch --from-file /tmp/launch/<campaign>.json

# 4. Approve → execute.
APB_GADS_ALLOW_MUTATIONS=true $B orchestrate campaign-launch --from-file /tmp/launch/<campaign>.json --execute
```

`plan campaign full` runs the whole pipeline (keyword research → structure → rsa → goals →
tracking) and writes one launch spec per intent campaign plus a `summary.md` into `--export-dir` —
it produces artifacts and launches nothing. `validate campaign-spec` is the gate: it checks
budget/geo/bidding presence, RSA counts + char limits, and keywords per ad group, exiting 3 on any
blocking error so `validate … && orchestrate …` stops on bad input. Everything is born **PAUSED** —
review in the UI before enabling. For the deeper build reference (per-stage control, `plan
keywords → structure → rsa → goals`, intent files) see the planning workflows in Workflow 10 plus
[`cli-reference/plan.md`](cli-reference/plan.md) (the campaign-build deep dive).

### 9. Greenfield PMAX launch

```bash
B="apb-gads --pretty --customer <CID>"

# Image assets must already exist — upload first and capture the resource names from each result.
APB_GADS_ALLOW_MUTATIONS=true $B mutate asset-create-image --file ./marketing.png --field-type MARKETING_IMAGE --execute
APB_GADS_ALLOW_MUTATIONS=true $B mutate asset-create-image --file ./square.png --field-type SQUARE_MARKETING_IMAGE --execute
APB_GADS_ALLOW_MUTATIONS=true $B mutate asset-create-image --file ./logo.png --field-type LOGO --execute

# 1. Assemble a single-asset-group PmaxLaunchPlanSpec (pure transform, no API).
$B plan campaign pmax --campaign-name "PMAX Prospecting" --budget-micros 50000000 \
  --final-url https://www.yourbrand.com --business-name "YourBrand" \
  --headline "Same-day delivery" --headline "Free returns" --headline "Shop the sale" \
  --description "Local warehouse means next-day arrival on every order." \
  --description "30-day returns, no questions asked." \
  --marketing-image-asset customers/<CID>/assets/<MKT_ID> \
  --square-marketing-image-asset customers/<CID>/assets/<SQ_ID> \
  --logo-asset customers/<CID>/assets/<LOGO_ID> \
  --search-theme "same day delivery" --export /tmp/pmax.json

# 2. Validate launch-readiness (exit 3 on fail).
$B validate pmax-spec --from-file /tmp/pmax.json

# 3. DRY-RUN the atomic build (budget → campaign → geo/lang/negatives → assets → asset group → links).
$B orchestrate pmax-build --from-file /tmp/pmax.json

# 4. Approve → execute (all-or-nothing; entities born PAUSED).
APB_GADS_ALLOW_MUTATIONS=true $B orchestrate pmax-build --from-file /tmp/pmax.json --execute
```

PMAX has hard v24 build requirements that `validate pmax-spec` checks before you launch: a
**non-shared** budget, MAXIMIZE_CONVERSIONS or MAXIMIZE_CONVERSION_VALUE bidding, and per asset
group ≥ 3 HEADLINE / ≥ 2 DESCRIPTION (one < 60 chars) / BUSINESS_NAME / ≥ 1 MARKETING_IMAGE / ≥ 1
SQUARE_MARKETING_IMAGE / ≥ 1 LOGO. Assets must exist **before** the asset group references them, so
upload images first and pass their resource names. `orchestrate pmax-build` submits the whole thing
in one atomic `googleAds:mutate`, so a failure rolls back rather than leaving partial state.

### 10. Keyword planning

```bash
B="apb-gads --pretty --customer <CID>"

# Forward-looking idea generation from seeds (keywords, a URL, or a whole site).
$B plan keyword-ideas --seed-keyword "running shoes" --seed-keyword "trail runners" \
  --geo-target-id 2840 --language-id 1000 --limit 100 \
  | jq '.[] | {text, avg_monthly_searches, competition}'

# Site-wide crawl seed instead of explicit keywords.
$B plan keyword-ideas --seed-site https://www.yourbrand.com --limit 200

# Backward-looking historical metrics for a fixed list (add --include-average-cpc for CPC).
$B plan keyword-historical-metrics --keyword "running shoes" --keyword "marathon trainers" --include-average-cpc
```

`plan keyword-ideas` wraps v24 `GenerateKeywordIdeas` (avg monthly searches, competition,
top-of-page bid ranges) and is read-only — no three-gate safety applies. Default geo is `2840`
(United States) and default language is `1000` (English); both are repeatable. Use
`keyword-historical-metrics` when you already have the exact keyword list and want backward-looking
volume + competition. For the full greenfield search pipeline broken into inspectable stages —
`plan keywords → plan structure → plan rsa → plan goals → plan campaign search` — see
[`cli-reference/plan.md`](cli-reference/plan.md); each stage is a pure transform so you can
hand-edit the intermediate JSON between steps.

### 11. The artifact pipeline (audit → plan → changeset → apply)

```bash
B="apb-gads --pretty --customer <CID>"

# a. Run an audit that emits a mutation-ready spec.
$B playbook waste-cluster-audit --output-spec /tmp/spec.json

# b. Score + rank it into an ActionPlan (growth-first ranking is the default).
$B plan from-audit --spec-file /tmp/spec.json --playbook waste-cluster-audit --rank-by growth-first --output /tmp/plan.json

# c. Stage auto-applicable actions into a reviewable Changeset.
$B changes from-plan --from-file /tmp/plan.json --output /tmp/changeset.json

# d. DRY-RUN the changeset (no --execute) — read exactly what it would submit.
$B changes apply --from-file /tmp/changeset.json

# e. Approve → apply through the guarded plan path (the single write).
APB_GADS_ALLOW_MUTATIONS=true $B changes apply --from-file /tmp/changeset.json --execute
```

This is the auditable way to turn a diagnosis into changes. `plan from-audit` defaults to
`growth-first` ranking so a scale-up never gets buried under a cut (pass `--rank-by
efficiency-first` for the legacy savings-weighted order). `changes from-plan` only stages actions
flagged auto-applicable (add `--include-review` to also stage human-review ones), and the single
write in step (e) reuses `mutate apply-plan`'s gates. Render any artifact for a human with
`apb-gads export render --from /tmp/plan.json --format markdown`.

### 12. Raw GAQL for the long tail

```bash
apb-gads --pretty --customer <CID> gaql query --query \
  "SELECT campaign.name, metrics.cost_micros, metrics.conversions
   FROM campaign
   WHERE segments.date BETWEEN '2026-05-01' AND '2026-05-31'
   ORDER BY metrics.cost_micros DESC"
```

Reach for `gaql query` only for questions a named `report` / `playbook` doesn't cover. Two gotchas
the CLI can't paper over: **date literals must be quoted strings** inside `BETWEEN` (`'2026-05-01'`,
not bare), and **you cannot `SELECT` segments without a metric** (Google rejects `SELECT
segments.date FROM campaign` with no metric column). `DURING LAST_30_DAYS` also isn't accepted by
every resource view, so an explicit quoted `BETWEEN` window is the safe form.

### 13. Reporting + jq extraction + `--output`

```bash
B="apb-gads --customer <CID>"

# Write raw JSON straight to a file with the global --output flag.
$B report campaign-performance-365d --limit 25 --output /tmp/perf.json

# Or pipe --pretty output through jq for extraction.
$B --pretty report search-terms-365d --limit 50 | jq '.[] | select(.conversions == 0 and .cost_micros > 50000000)'

# Render any artifact JSON to CSV / Markdown for a human (pure-local, no API).
$B export render --from /tmp/perf.json --format csv --out-dir /tmp/perf-csv
```

`--output <path>` is a **global** flag that redirects JSON to a file instead of stdout — handy for
piping a report into the next command or archiving it. For extraction, pipe `--pretty` to `jq` and
read specific keys rather than dumping whole envelopes (playbooks carry large raw GAQL arrays).
`export render` turns any artifact into CSV / JSON / Markdown locally — no Google Ads API call, no
safety gates.

### 14. Scheduling read-only audits

```bash
# Register a monthly account-health run. Everything after `--` is the read-only invocation.
apb-gads schedule add --id monthly-health --cron "0 9 1 * *" --job-customer <CID> \
  -- playbook account-health

# Smoke-test it now, then render + install the managed crontab section.
apb-gads schedule run --id monthly-health
apb-gads schedule install            # dry-run: prints the crontab section + the ready-to-pipe command
apb-gads schedule install --apply    # merge it into your user crontab
```

`schedule` accepts **read-only** invocations only — it rejects anything containing `--execute`,
`mutate`, `sandbox`, write-capable `orchestrate`, or `audit replay` at registration time, so
**mutations cannot be scheduled, by construction**. The model is emit-cron-lines: the CLI manages a
JSON state file and renders a managed crontab section that the OS fires; there's no long-lived
daemon. Per-run output lands in `{config_dir}/schedule-runs/<id>.jsonl`.

### 15. Multi-account fan-out

```bash
# Loop a read-only audit over every account the connection can reach.
for CID in $(apb-gads customer list | jq -r '.[].customer_id'); do
  echo "=== $CID ==="
  apb-gads --customer "$CID" playbook account-health --output "/tmp/health-$CID.json"
done
```

`--customer` is a global flag, so any command parameterizes cleanly in a shell loop — pull the id
list from `customer list` and iterate. **Keep fan-out loops read-only.** If you need to write across
accounts, run the dry-run → review → execute protocol *per account* rather than blasting `--execute`
in a loop. Each run writes its own `--output` file so you can diff accounts afterward.

---

## Reading results & exit codes

Every command returns a JSON document on stdout; `--pretty` only changes indentation. Branch on the
**exit code, never on stdout text**:

| Code | Meaning | Notes |
|---|---|---|
| `0` | success / a `pass` verdict | normal |
| `1` | runtime / IO / API error | network, auth, a Google API error body |
| `2` | usage error | a bad/missing flag (clap) |
| `3` | a **validation `fail`** verdict | from `validate campaign-spec`, `validate pmax-spec`, or `mutate ad-validate` — the JSON report is still printed |

The `&&` chain is the canonical halt-on-fail pattern — a bad spec exits 3, so the launch after `&&`
never runs:

```bash
apb-gads --customer <CID> validate campaign-spec --from-file /tmp/launch/campaign.json \
  && APB_GADS_ALLOW_MUTATIONS=true apb-gads --customer <CID> \
       orchestrate campaign-launch --from-file /tmp/launch/campaign.json --execute
```

**Never claim a write persisted without reading it back.** A dry-run shows what *would* be sent; a
`--validate-only --execute` run proves Google would *accept* the body but creates nothing; only a
live `--execute` followed by a readback (or a `verify` chain) proves persistence. Which surfaces are
proven at which tier (DRY_RUN / SERVER_VALIDATED / LIVE_VERIFIED) is documented in
[`CAPABILITY.md`](CAPABILITY.md).

---

## Safety in one paragraph

Every `mutate` / write-capable `orchestrate` / `changes apply` command is **dry-run by default** and
needs all three independent gates before a write reaches Google — `--execute` on the command line,
`safety.allow_writes: true` + `safety.read_only: false` in config (or, in SaaS mode, the
`write:google:mutations` add-on scope), and `APB_GADS_ALLOW_MUTATIONS=true` in the environment — plus
a per-customer profile or the deny-by-default sandbox must authorize the specific op. Destructive
ops (pausing/removing) additionally need the global `--confirm`. There is no bypass flag: **a guard
rejection is the system working — report it, never work around it.** To prove a payload shape against
a real account without creating anything, add `--validate-only` to an `--execute` run (Google
validates schema + policy + auth server-side and returns empty results). Full gate model, profiles,
verification chains, and the audit trail: [`SAFETY_MODEL.md`](SAFETY_MODEL.md).

---

## See also

- [`GETTING_STARTED.md`](GETTING_STARTED.md) — install, dashboard connect, API key, account picker.
- [`cli-reference/README.md`](cli-reference/README.md) — exhaustive per-command / per-flag reference (every group).
- [`cli-reference/plan.md`](cli-reference/plan.md) — the greenfield campaign-build pipeline in depth (`plan campaign` / `validate` / `orchestrate`).
- [`SAFETY_MODEL.md`](SAFETY_MODEL.md) — the three-gate write model, sandbox/profile policy, exit codes.
- [`PLAYBOOK_CATALOG.md`](PLAYBOOK_CATALOG.md) — pick a playbook by symptom (all 66, grouped by section).
- [`DOCTRINE.md`](DOCTRINE.md) — modern Google Ads doctrine (Smart Bidding, learning phase, RSA stats, PMAX facts).
- [`CLI_AUTOMATION.md`](CLI_AUTOMATION.md) — CI/CD + AI-agent invocation patterns (JSON contract, exit codes, scheduling).
- [`CAPABILITY.md`](CAPABILITY.md) — which write surfaces are proven at which tier; never claim persistence without readback.
