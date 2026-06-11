# apb-gads — Canonical Workflows

19 task-oriented workflows for the `apb-gads` Google Ads CLI — the patterns operators actually run, growth-first and learning-phase-aware. Every command, subcommand, and flag below is **real** (verified against the binary), and every mutation is shown **dry-run first**, then the gated `--execute` variant. Set the account once with the global `--customer <CID>` flag (plain 10-digit id, no dashes) and pipe JSON to `jq`.

---

## 1. Setup & sanity

```bash
# One-time: store your AgencyPlaybook key where both binaries read it.
mkdir -p ~/.apb
echo 'APB_API_KEY=apb_live_<tier>_<32hex>' > ~/.apb/.env   # key from the dashboard /api-keys page
B="apb-gads --pretty"

$B auth test                 # auth resolves through the SaaS broker — exit 0 = connected
$B doctor check              # environment health (creds, config, write-gate posture)
$B customer list             # the Google Ads accounts your connection can reach
```

`auth test` proves the `APB_API_KEY` → `/auth/resolve?provider=google_ads` chain works and a Google token came back; `doctor check` confirms config + the read-only floor. `customer list` is how you discover the `<CID>` values for `--customer` — if your connection reaches exactly one account it auto-selects. A `403` here means the Google Ads add-on isn't enabled on the tenant.

## 2. Full read-only diagnosis sequence

```bash
B="apb-gads --pretty --customer <CID>"

$B playbook account-health | jq '{score: .composite_score, actions: .recommended_actions}'
$B playbook campaign-bid-strategy-audit | jq '{learning_now, growth_blockers, misconfigured}'
$B growth scale-up --min-roas 3.0 | jq '.opportunities'
# If PMAX campaigns are present:
$B playbook pmax-audit
$B report pmax-placements --limit 50
# If Search campaigns are present:
$B playbook rsa-quality-audit | jq '.rsa_refresh_candidates'
```

This is the diagnostic spine — always start here before touching anything. `campaign-bid-strategy-audit` reads the **authoritative** v24 `bidding_strategy_system_status`: trust its `learning_now[]` / `growth_blockers[]` / `misconfigured[]` buckets over any heuristic (`LEARNING_*` = hands off, `LIMITED_BY_BUDGET` = scale, `MISCONFIGURED_*` = fix config first). `growth scale-up` ranks opportunities by upside, never by cuts. A zero-spend account legitimately returns empty findings — read that as "no demand signal yet," not a forced to-do list.

## 3. The universal dry-run → review → execute pattern

```bash
# 1. DRY-RUN FIRST — no --execute, so nothing is submitted; the CLI prints the plan it would send.
apb-gads --pretty --customer <CID> mutate campaign-budget-update \
  --budget-resource-name customers/<CID>/campaignBudgets/<BUDGET_ID> \
  --amount-micros 60000000          # $60.00/day

# 2. Read the dry-run JSON: the would-be request body + the learning_advisory.
#    learning_advisory predicts whether this change resets Smart Bidding learning.

# 3. Approve, then re-run with ALL THREE gates: --execute + the env gate (config gate is in google-ads.yaml).
APB_GADS_ALLOW_MUTATIONS=true apb-gads --pretty --customer <CID> mutate campaign-budget-update \
  --budget-resource-name customers/<CID>/campaignBudgets/<BUDGET_ID> \
  --amount-micros 60000000 --execute
```

Every `mutate`/`orchestrate`/`changes apply` write is dry-run by default. The protocol is non-negotiable: **dry-run → read the JSON + advisories → show the user → get approval → re-run with `--execute`**. The `learning_advisory` on the dry-run envelope is the single most important field to read on any bid/budget/strategy change — it tells you the learning-phase cost before you pay it.

## 4. Audit → ranked plan → reviewed changeset → gated apply

```bash
B="apb-gads --pretty --customer <CID>"

# a. Run an audit that emits a mutation-ready spec.
$B playbook waste-cluster-audit --output-spec /tmp/spec.json

# b. Score + rank it into an ActionPlan (growth-first ranking is the default).
$B plan from-audit --spec-file /tmp/spec.json --playbook waste-cluster-audit --rank-by growth-first \
  --output /tmp/plan.json

# c. Stage auto-applicable actions into a reviewable Changeset.
$B changes from-plan --from-file /tmp/plan.json --output /tmp/changeset.json

# d. DRY-RUN the changeset (no --execute) — read what it would submit.
$B changes apply --from-file /tmp/changeset.json

# e. Approve → apply through the guarded plan path.
APB_GADS_ALLOW_MUTATIONS=true $B changes apply --from-file /tmp/changeset.json --execute
```

This is the artifact pipeline — the auditable way to turn a diagnosis into changes. `plan from-audit` defaults to `growth-first` ranking so a scale-up never gets buried under a cut. `changes from-plan` only stages actions flagged auto-applicable (add `--include-review` to also stage human-review ones); the single write in step (e) reuses `mutate apply-plan`'s three gates.

## 5. Safe bid/budget change under the learning-phase protocol

```bash
B="apb-gads --pretty --customer <CID>"

# Check current state first — is the campaign mid-learning?
$B playbook campaign-bid-strategy-audit | jq '.learning_now'

# DRY-RUN a tROAS nudge and READ will_reset_learning before doing anything.
$B mutate campaign-update-bidding-strategy --campaign-id <CAMPAIGN_ID> \
  --strategy-type TARGET_ROAS --target-roas 3.5 | jq '.learning_advisory'

# Approved + inside the guardrail → execute.
APB_GADS_ALLOW_MUTATIONS=true $B mutate campaign-update-bidding-strategy --campaign-id <CAMPAIGN_ID> \
  --strategy-type TARGET_ROAS --target-roas 3.5 --execute
```

Read `learning_advisory.will_reset_learning` on the dry-run envelope before approving. Stay inside the guardrails: **target moves ≤10-15%, budget moves ≤15-20%, once or twice a month, and NEVER budget + target in the same change** (Google treats that as a guaranteed full reset). If the move is bigger than that, route it through an experiment instead of mutating the live campaign.

## 6. `--validate-only` wire-shape proof (creates nothing)

```bash
# --validate-only + --execute + env gate → Google validates schema/policy/auth server-side
# (validateOnly=true) and returns empty results. No entity is created or updated.
APB_GADS_ALLOW_MUTATIONS=true apb-gads --pretty --customer <CID> --validate-only \
  mutate campaign-budget-create --name "Q3 Prospecting" --amount-micros 50000000 --execute
```

Use this to prove a payload shape against a real account before you propose the real write — it reaches Google's servers (SERVER_VALIDATED tier) but mutates nothing. It is the safest possible "will this body be accepted?" check, stronger than a local dry-run because Google itself validates policy and auth. Drop `--validate-only` (keep `--execute` + env) when you actually want to apply it.

## 7. RSA refresh (POOR ad-strength only)

```bash
B="apb-gads --pretty --customer <CID>"

# 1. Find ads that actually need a refresh — only POOR strength qualifies.
$B playbook rsa-quality-audit --output-spec /tmp/spec.json | jq '.rsa_refresh_candidates'

# 2. Validate the new copy locally (no API) — exit 3 on a fail verdict.
$B mutate ad-validate --from-file /tmp/spec.json

# 3. DRY-RUN the refresh: creates a NEW RSA, recommends a pause target (editing in place resets learning).
$B orchestrate ad-refresh --ad-group-id <AD_GROUP_ID> \
  --headline "Fast same-day delivery" --headline "Order before 3pm" --headline "Free returns" \
  --description "Shipped from our local warehouse for next-day arrival." \
  --description "30-day no-questions returns on every order." \
  --final-url https://www.yourbrand.com

# 4. Approve → create the new ad (born PAUSED) and pause the fatigued one (destructive → --confirm).
APB_GADS_ALLOW_MUTATIONS=true $B orchestrate ad-refresh --ad-group-id <AD_GROUP_ID> \
  --headline "Fast same-day delivery" --headline "Order before 3pm" --headline "Free returns" \
  --description "Shipped from our local warehouse for next-day arrival." \
  --description "30-day no-questions returns on every order." \
  --final-url https://www.yourbrand.com \
  --pause-ad-id <OLD_AD_ID> --execute --confirm
```

Refresh **only on POOR** ad strength — AVERAGE with good CPA is healthy, and Ad Strength measures completeness, not performance, so never rewrite a converting ad to chase "Excellent." `ad-refresh` creates a new ad rather than editing in place (heavy in-place edits reset policy review and break history). Pausing the old ad is destructive, so it needs the global `--confirm` on top of the gates.

## 8. PMAX guardrail pass

```bash
B="apb-gads --pretty --customer <CID>"

# Junk-placement webpage exclusions (substitute for the v24-removed url_expansion_opt_out).
$B report pmax-placements --limit 50
$B playbook pmax-url-exclusion-audit --output-spec /tmp/spec.json
$B mutate campaign-negative-webpage-add-bulk --from-file /tmp/spec.json                       # dry-run
APB_GADS_ALLOW_MUTATIONS=true $B mutate campaign-negative-webpage-add-bulk --from-file /tmp/spec.json --execute

# Brand exclusions on non-brand PMAX (~99% of cases — PMAX over-credits brand).
$B customer suggest-brands --prefix "<COMPETITOR>"                                             # get the brand MID
$B playbook brand-exclusion-audit --output-spec /tmp/spec.json
$B mutate campaign-brand-list-exclude --campaign-id <CAMPAIGN_ID> --shared-set-id <BRANDS_SET_ID>   # dry-run
APB_GADS_ALLOW_MUTATIONS=true $B mutate campaign-brand-list-exclude --campaign-id <CAMPAIGN_ID> --shared-set-id <BRANDS_SET_ID> --execute

# Turn off Final URL expansion for lead-gen / landing-page control.
$B mutate campaign-update-url-expansion-opt-out --campaign-id <CAMPAIGN_ID> --opt-out           # dry-run
APB_GADS_ALLOW_MUTATIONS=true $B mutate campaign-update-url-expansion-opt-out --campaign-id <CAMPAIGN_ID> --opt-out --execute

# Seed a search-theme signal — the CLI rejects a 26th (cap is 25 per asset group).
$B mutate pmax-audience-signal-attach --asset-group-id <ASSET_GROUP_ID> --signal-type SEARCH_THEME --text "same day delivery"   # dry-run
APB_GADS_ALLOW_MUTATIONS=true $B mutate pmax-audience-signal-attach --asset-group-id <ASSET_GROUP_ID> --signal-type SEARCH_THEME --text "same day delivery" --execute
```

`report pmax-placements` is honest about v24's visibility limits (impressions only — per-channel spend split is script-only territory), then names the mitigation writes. Build the BRANDS shared set from `customer suggest-brands` output (`mutate shared-set-create --type BRANDS` → `shared-criterion-add --type BRAND --brand-id <MID>`) before attaching it. Search themes cap at **25 per asset group**; the CLI fails pre-API on a 26th.

## 9. Greenfield Search launch

```bash
B="apb-gads --pretty --customer <CID>"

# 1. Assemble a launch-ready CampaignLaunchSpec from research → structure → RSA (read-only, launches nothing).
$B plan campaign full --seed-keywords "running shoes,trail runners" \
  --landing-page https://www.yourbrand.com --daily-budget 100 --mode ecommerce \
  --brand "YourBrand" --export-dir /tmp/launch

# 2. Validate it — a fail verdict prints its report and exits 3, halting any chained launch.
$B validate campaign-spec --from-file /tmp/launch/<campaign>.json

# 3. DRY-RUN the launch (budget → campaign → ad group → RSA → keywords; entities born PAUSED).
$B orchestrate campaign-launch --from-file /tmp/launch/<campaign>.json

# 4. Approve → execute.
APB_GADS_ALLOW_MUTATIONS=true $B orchestrate campaign-launch --from-file /tmp/launch/<campaign>.json --execute
```

`plan campaign full` runs the whole pipeline (keyword research → structure → rsa → goals → tracking) and writes one launch spec per intent campaign plus a `summary.md` into `--export-dir` — it produces artifacts and launches nothing. `validate campaign-spec` is the gate: it checks budget/geo/bidding presence, RSA counts + char limits, keywords per ad group, and exits 3 on any blocking error so `validate … && orchestrate …` stops on bad input. Everything is born PAUSED — review before enabling.

## 10. Greenfield PMAX launch

```bash
B="apb-gads --pretty --customer <CID>"

# Image assets must already exist — upload first and capture the resource names.
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

PMAX has hard v24 build requirements: a non-shared budget, MAXIMIZE_CONVERSIONS or MAXIMIZE_CONVERSION_VALUE bidding, and per asset group ≥3 HEADLINE / ≥2 DESCRIPTION (one <60 chars) / BUSINESS_NAME / ≥1 MARKETING_IMAGE / ≥1 SQUARE_MARKETING_IMAGE / ≥1 LOGO — `validate pmax-spec` checks all of it before you launch. Assets must exist before the asset group references them, so upload images first and pass their resource names. `orchestrate pmax-build` submits the whole thing in one atomic `googleAds:mutate` so a failure rolls back rather than leaving partial state.

## 11. Keyword planning

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

`plan keyword-ideas` wraps v24 `GenerateKeywordIdeas` (avg monthly searches, competition, top-of-page bid ranges) and is reads-only — no three-gate safety applies. Default geo is 2840 (United States) and default language is 1000 (English); both are repeatable. Use `keyword-historical-metrics` when you already have the exact keyword list and want backward-looking volume + competition.

## 12. Negative-keyword hygiene

```bash
B="apb-gads --pretty --customer <CID>"

# Surface negative-keyword candidates from search terms (with ad-group context).
$B playbook search-term-cleanup --limit 50 --output /tmp/spec.json

# DRY-RUN the bulk add — this command reads search-term-cleanup's {candidate_actions:[...]} directly.
$B mutate negative-keyword-add-bulk --from-file /tmp/spec.json

# Approve → apply.
APB_GADS_ALLOW_MUTATIONS=true $B mutate negative-keyword-add-bulk --from-file /tmp/spec.json --execute

# For campaign-level negatives instead of ad-group-level, hand-author the items file:
#   {"items":[{"campaign_id":"<CAMPAIGN_ID>","text":"free","match_type":"PHRASE"}, ...]}
APB_GADS_ALLOW_MUTATIONS=true $B mutate campaign-negative-keyword-add-bulk --from-file /tmp/spec.json --execute
```

`search-term-cleanup` writes a `candidate_actions[]` spec that `mutate negative-keyword-add-bulk --from-file` consumes natively — no reshaping needed. Bulk mutations pre-validate every item and reject the whole batch on any failure, so a single malformed row can't half-apply. Campaign-level negatives go up to 10,000 per campaign and block Search + Shopping only (Display/YouTube junk needs placement/topic exclusions).

## 13. Raw GAQL for ad-hoc questions

```bash
# Anything a named report doesn't cover — query the searchStream endpoint directly.
apb-gads --pretty --customer <CID> gaql query --query \
  "SELECT campaign.name, metrics.cost_micros, metrics.conversions
   FROM campaign
   WHERE segments.date BETWEEN '2026-05-01' AND '2026-05-31'
   ORDER BY metrics.cost_micros DESC"
```

Two GAQL gotchas the CLI can't paper over: **date literals must be quoted strings** inside `BETWEEN` (`'2026-05-01'`, not bare), and **you cannot `SELECT` segments without metrics** — Google rejects `SELECT segments.date FROM campaign` with no metric column. `DURING LAST_30_DAYS` also isn't accepted by every resource view, so an explicit quoted `BETWEEN` window is the safe form. Use named `report` / `playbook` commands first; reach for `gaql query` only for the long tail.

## 14. Exit-code branching in bash

```bash
# Spec validators exit 3 on a fail verdict — chain with && to halt before a bad launch.
apb-gads --customer <CID> validate campaign-spec --from-file /tmp/launch/campaign.json \
  && APB_GADS_ALLOW_MUTATIONS=true apb-gads --customer <CID> \
       orchestrate campaign-launch --from-file /tmp/launch/campaign.json --execute

# Or branch explicitly on the exit code (never parse stdout text).
apb-gads --customer <CID> validate pmax-spec --from-file /tmp/pmax.json
case $? in
  0) echo "Spec OK — safe to launch" ;;
  3) echo "Validation FAIL — read the printed report, fix the spec, do not launch" ;;
  2) echo "Usage error — a flag/arg is wrong" ;;
  1) echo "Runtime error — auth/network/API; check the message" ;;
esac
```

Branch on the **exit code, not stdout text**: `0` ok · `1` runtime error · `2` usage error · **`3` a `fail` verdict** from `validate campaign-spec` / `validate pmax-spec` / `mutate ad-validate`. The `&&` form is the canonical halt-on-fail pattern — a bad spec exits 3, so the launch after `&&` never runs. This is what makes the validate→orchestrate sequence safe to put in a script.

## 15. Reporting to a file / piping to jq

```bash
B="apb-gads --customer <CID>"

# Write the raw JSON straight to a file with the global --output flag.
$B report campaign-performance-365d --limit 25 --output /tmp/perf.json

# Or pipe --pretty output through jq for extraction.
$B --pretty report search-terms-365d --limit 50 | jq '.[] | select(.conversions == 0 and .cost_micros > 50000000)'

# Render any artifact JSON to CSV/Markdown for a human (pure-local, no API).
$B export render --from /tmp/perf.json --format csv --out-dir /tmp/perf-csv
```

`--output <path>` is a global flag that redirects the JSON to a file instead of stdout — handy for piping a report into the next command or archiving it. For extraction, pipe `--pretty` output to `jq` and read specific keys rather than dumping whole envelopes (playbooks carry large raw GAQL arrays). `export render` turns any artifact into CSV or Markdown locally — no Google Ads API call, no safety gates.

## 16. Scheduling a recurring read-only audit

```bash
B="apb-gads"

# Register a monthly account-health run. Everything after `--` is the read-only invocation.
$B schedule add --id monthly-health --cron "0 9 1 * *" --job-customer <CID> \
  -- playbook account-health

# Smoke-test it now, then render + install the managed crontab section.
$B schedule run --id monthly-health
$B schedule install            # dry-run: prints the crontab section + the pipe command
$B schedule install --apply    # merge it into your user crontab
```

`schedule` only accepts **read-only** invocations after `--`: `validate_safe_command` rejects anything containing `--execute`, `mutate`, `sandbox`, or write-capable `orchestrate` at registration time — **mutations cannot be scheduled, by construction**. The model is emit-cron-lines: the CLI manages a JSON state file and renders a managed crontab section that the OS fires; there's no long-lived daemon. Per-run output lands in `{config_dir}/schedule-runs/<id>.jsonl`.

## 17. Multi-account fan-out

```bash
# Loop a read-only audit over every account the connection can reach.
for CID in $(apb-gads customer list | jq -r '.[].customer_id'); do
  echo "=== $CID ==="
  apb-gads --customer "$CID" playbook account-health --output "/tmp/health-$CID.json"
done
```

`--customer` is a global flag, so any command parameterizes cleanly in a shell loop — pull the id list from `customer list` and iterate. Keep fan-out loops read-only; if you need to write across accounts, run the dry-run → review → execute protocol per account rather than blasting `--execute` in a loop. Each run writes its own `--output` file so you can diff accounts afterward.

## 18. Rollback / audit trail

```bash
B="apb-gads --pretty --customer <CID>"

# Every executed write lands in the audit log — inspect it.
$B audit list --limit 20
$B audit get --id <AUDIT_INDEX>

# Build the inverse of a prior write (dry-run by default) from its audit-log id.
$B mutate inverse-plan --audit-id <AUDIT_INDEX>
APB_GADS_ALLOW_MUTATIONS=true $B mutate inverse-plan --audit-id <AUDIT_INDEX> --execute

# Or roll back a changeset applied through the artifact pipeline, by audit id.
$B changes rollback --audit-id <AUDIT_INDEX>                                          # dry-run
APB_GADS_ALLOW_MUTATIONS=true $B changes rollback --audit-id <AUDIT_INDEX> --execute
```

Only execute-mode mutations are logged — dry-run and blocked attempts are not, so `audit list` is a clean record of what actually changed. `mutate inverse-plan` reads an audit entry and constructs the reverse operations (still dry-run by default — review before `--execute`). For a quick undo of arbitrary just-created resources, `orchestrate rollback --resource customers/<CID>/campaigns/<ID>` submits an atomic remove batch (note: v24 `AssetService` has no remove — assets are removed in the Google Ads UI).

## 19. Greenfield from explicit planning steps (when you want control)

```bash
B="apb-gads --pretty --customer <CID>"

# Step the search pipeline by hand instead of one-shotting `plan campaign full`.
$B plan keywords --seed-keyword "running shoes" --seed-keyword "trail runners" --output /tmp/kw.json
$B plan structure --from /tmp/kw.json --output /tmp/structure.json
$B plan rsa --from /tmp/structure.json --brand "YourBrand" --final-url https://www.yourbrand.com --output /tmp/rsa.json
$B plan goals --mode ecommerce --target-roas 4.0 --output /tmp/goals.json

# Assemble the launch spec from the pieces, then validate → launch (as in §9).
$B plan campaign search --structure /tmp/structure.json --rsa /tmp/rsa.json --goals /tmp/goals.json \
  --daily-budget 100 --location "United States" --export /tmp/launch.json
$B validate campaign-spec --from-file /tmp/launch.json \
  && APB_GADS_ALLOW_MUTATIONS=true $B orchestrate campaign-launch --from-file /tmp/launch.json --execute
```

`plan campaign full` (§9) is the fast path; this is the same pipeline broken into inspectable stages — useful when you want to hand-edit the keyword clusters, RSA copy, or bidding between steps. Each stage is a pure transform (`plan structure` / `plan rsa` take no API), so you can iterate on the intermediate JSON freely. The terminal `validate campaign-spec && orchestrate campaign-launch` is the same halt-on-fail launch from §14.

---

## Cross-references

- Concrete command sequences (W1–W7) + the output keys to read: `references/workflows.md`
- Pick a playbook by symptom (all 63, by section): `references/playbook-catalog.md`
- The three-gate write model, sandbox/profile policy, capability tiers: `references/safety-model.md`
- Modern Google Ads doctrine (Smart Bidding, learning phase, RSA stats, PMAX facts): `references/doctrine.md`
- The full 24-group command index: `commands.md`
