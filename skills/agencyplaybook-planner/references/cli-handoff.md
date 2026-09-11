# CLI handoff — exact sequences, artifact paths, deploy paths

**Today** = what the shipped binaries accept (verified 2026-09-09 against `apb-gads 0.2.0`, dep-phase2
sprint-g05). `recipe build` (`CampaignBuildSpec v2` + Plan envelope v2, spec:
`ai/specs/campaign-build-001/product-spec.md`) shipped in sprint-g04; the Editor CSV bundle
(`recipe build --format editor-csv|all`, `plan export --format editor-csv`) shipped in sprint-g05 —
both eras below are current, use whichever fits the brief. The v1 `plan campaign search` →
`orchestrate campaign-launch` sequence still works unchanged and is the right choice for a spec you
want to hand-edit stage by stage; `recipe build` is the right choice for a whole-campaign brief in
one shot.

Conventions used below: `$G` = `apb-gads --config <yaml> --customer <id>` (in-repo runs need a leading
`APB_API_KEY=` or SaaS-resolve hijacks `--config`); `$B` = the brief; artifacts under `build/`.

## Today — Google Search

```bash
mkdir -p research build
# 0 context (targets come from here)
$G context show || $G context init --mode target_cpa --target-cpa 18.00 --primary-kpi conversions

# 1 research (real Google-wide data; works on the sandbox)
$G plan keywords --seed-keyword "whole bean coffee" --seed-keyword "fresh roasted coffee beans" \
   --geo-target-id 2840 --language-id 1000 --output research/keywords.json
#   planner: drop clusters matching brief.research.exclude_intents; record counts

# 2 structure
$G plan structure --from research/keywords.json --output build/structure.json
#   planner: enforce structure.max_ad_groups; merge thin clusters (consolidation doctrine)

# 3 copy — pick ONE
$G plan rsa --from build/structure.json --brand "Example Roasters" \
   --final-url https://www.example.com/whole-bean --output build/rsa.json        # provider=heuristic
#   or provider=agent: YOU write build/rsa.json (rsa-artifact-shape.md) after scraping the landing page

# 4 goals (from context, not memory)
$G plan goals --mode lead-gen --target-cpa 18.00 --output build/goals.json      # mode: lead-gen|ecommerce|brand|app

# 5 assemble → CampaignLaunchSpec (v1)
$G plan campaign search --structure build/structure.json --rsa build/rsa.json --goals build/goals.json \
   --keywords-plan research/keywords.json --campaign-name "Test-ok-to-delete Example Roasters — Whole Bean — US" \
   --landing-page https://www.example.com/whole-bean --daily-budget 75 \
   --geo-target-id 2840 --language-id 1000 --target-cpa 18.00 --export build/spec.json

# 6 validate (exit 3 = fail — fix the spec, never override)
$G validate campaign-spec --from-file build/spec.json
$G playbook launch-check ; $G playbook smart-bidding-readiness

# 7 plan (dry-run + review doc). Add --validate-only for Google's SERVER_VALIDATED round-trip.
$G orchestrate campaign-launch --from-file build/spec.json --plan build/plan.md
$G orchestrate campaign-launch --from-file build/spec.json --validate-only --execute   # needs APB_GADS_ALLOW_MUTATIONS=true

# 8 launch — ONLY after a human YES in this conversation (entities born PAUSED)
APB_GADS_ALLOW_MUTATIONS=true $G orchestrate campaign-launch --from-file build/spec.json --execute
$G verify list ; $G changes recent
```

### v1 spec ceiling → `build/post-launch.md`

`CampaignLaunchSpec` carries: campaign · budget · ad groups (1 RSA + keywords + negatives) · campaign
negatives · geo ids · language ids · bidding. Everything else the brief asks for, emit as post-launch
commands (each dry-run first, `--execute` only after YES), using `<campaign_id>` from the launch receipt:

| Brief block | Post-launch command |
|---|---|
| `targeting.schedule` | `$G mutate campaign-ad-schedule-add --campaign-id <id> --day MONDAY --start 06:00 --end 22:00 …` |
| `targeting.devices` | `$G mutate campaign-device-modifier-set --campaign-id <id> --device MOBILE --modifier 1.10` (CLI warns it's a no-op under Smart Bidding except −100%) |
| `targeting.geo.exclude` / `type` | `$G mutate campaign-geo-add … --negative`, `$G mutate campaign-update-geo-target-type --campaign-id <id> --positive PRESENCE` |
| `targeting.audiences` / `demographics` | `$G mutate campaign-audience-add …`, `campaign-demographic-exclude …` |
| `negatives.shared_sets` | `$G mutate campaign-shared-set-attach --campaign-id <id> --shared-set <resource>` (resolve by exact name first; ambiguity → stop) |
| `negatives.brand_exclusion` | `$G mutate campaign-brand-list-exclude …` |
| `assets.*` | `$G mutate asset-create-sitelink …` → `campaign-asset-attach …` (same for callout / structured-snippet / call / price) |
| `business.final_url_suffix` | `$G mutate campaign-update-tracking-url --campaign-id <id> --final-url-suffix …` |
| `settings.networks` / `ad_rotation` / `url_expansion` | `campaign-update-network-settings`, `-ad-rotation`, `-url-expansion-opt-out` |
| `goals.conversion_actions` / `customer_acquisition` | `campaign-conversion-goal-set`, `campaign-update-customer-acquisition` |

Run `$G mutate <cmd> --help` for exact flags — don't guess them.

## Today — Google PMAX / Demand Gen

`plan campaign pmax` → `validate pmax-spec` → `orchestrate pmax-build` (atomic single mutate, born
PAUSED). `PmaxLaunchPlanSpec` already carries asset groups, signals, ad schedules, brand exclusions,
customer acquisition. Assets (logos/images/videos) must pre-exist — `verify bootstrap-pmax-assets`
on the sandbox. Demand Gen: `plan campaign demand-gen` → `validate demand-gen-spec` →
`orchestrate demand-gen-build`.

## Today — Meta, whole-campaign brief (`apb recipe build`)

`recipe build` shipped on the Meta lane in sprint-m02 (`apb 0.5.28`) — the Meta twin of the Google
sequence above, same brief shape with `channel: meta`:

```bash
apb context show || apb context init --mode target_cpa --target-cpa 18.00 --brand-term "<brand>"
apb recipe describe build                                  # the decision rules — quote, don't paraphrase
apb recipe build --brief briefs/<slug>.yaml --out build/   # spec.v2.json + plan.json + plan.md + plan.html + preview.html + summary.json
apb plan export --from-file build/plan.json --format html --fonts web --out review.html
# launch (born PAUSED, four gates) …
READ_ONLY=false ALLOW_WRITES=true APB_ALLOW_MUTATIONS=true apb recipe build --brief briefs/<slug>.yaml --out build/ --execute
# … or hand build/plan.json to AgencyPlaybook: POST /api/v1/plans/import → /validate → /execute
```

Rollback: `build/launch.json.rollback_envelope` → `apb plan apply --from-file rollback.json --execute
--confirm-destructive`. **No Editor CSV on Meta** — there is no Ads-Editor import format, and
`summary.json` says so rather than faking one.

Annotated reference brief: `rust/tests/fixtures/brief-sandbox-meta.yaml`. Guide: `rust/docs/recipes.md`.

## Today — Meta, stage-by-stage (`compose-from-spec`)

`apb campaign compose-from-spec --spec-file spec.json` (campaign → adsets → creatives → ads; presets
via `campaign preset`); `--plan out.md` (or `out.html`) for plan-first; `apb plan export --id <plan>` →
envelope → `POST /api/v1/plans/import` → `/validate` → `/execute` in AgencyPlaybook. Example spec:
`rust/docs/examples/compose-spec.json`. The Meta **sandbox cannot create creatives** — validate
creative structure only; the write chain there stops at campaign + ad set (a sandbox `--execute`
ends `PARTIAL`, which is the expected outcome).

## Today — Google Search, whole-campaign brief (`recipe build`)

```bash
$G recipe build --brief briefs/<slug>.yaml --out build/             # research → spec.v2.json → plan.json + plan.md + plan.html + editor/*.csv + research/
$G recipe build --spec build/spec.v2.json                           # re-run a hand-edited spec
$G recipe build --brief briefs/<slug>.yaml --format editor-csv --out build/   # ONLY the Editor CSV bundle
$G plan export --from-file build/plan.json --format editor-csv --out build/  # re-export from an existing plan.json, read-only
$G recipe build --brief … --execute                                  # after YES; born PAUSED
```
`plan.json` (Plan envelope v2) imports via `POST /api/v1/gads/plans/import` (S3) and shows in the web
app's Plans page (S4). The brief's `targeting` / `negatives` / `assets` / `settings` blocks are carried
natively — `post-launch.md` disappears. `build/editor/*.csv` (sprint-g05) is the same plan rendered in
Google Ads Editor's own import column layout — hand it to a client who wants to review or hand-tune
in Editor before launch; it is a READ artifact only, `--execute` never touches it.

## MCP sequence (agent-driven, either era)

Single bounded change (one campaign/ad-set/keyword op, not a whole build): Google
`gads_preview_change` (mints a token) → **human YES + approval token** → `gads_apply_change` →
`gads_verify_execution`. Meta: `meta_preview_change` → YES → `meta_apply_change` →
`meta_verify_execution`.

```json
{"tool": "gads_preview_change", "arguments": {"customer_id": "1234567890", "change_set": {"op": "campaign-update-status", "entity_id": "18765432109", "params": {"status": "PAUSED"}}}}
```

Spec/build → plan → execute (either channel): `gads_resolve_customer` → `gads_build_campaign_spec`
(emits the spec; after S5 accepts the brief) → `gads_validate_spec` / `gads_export_plan` (produces
the envelope, imports it, mints the token) → YES → `gads_execute_plan` (approve + execute + poll).
Meta: `meta_build_campaign_spec` → `meta_create_plan` → `meta_validate_plan` (mints the token) →
YES → `meta_execute_plan` (imports + approves + executes + polls). Both channels share the same
plan states: `pending → approved → executing → executed | failed`.

```json
{"tool": "gads_export_plan", "arguments": {"customer_id": "1234567890", "change_set": {"op": "campaign-update-status", "entity_id": "18765432109", "params": {"status": "PAUSED"}}}}
{"tool": "gads_execute_plan", "arguments": {"plan_id": "pln_g_9a3f", "approval_token": "apt_...", "operator_confirmation": true}}

{"tool": "meta_create_plan", "arguments": {"action": "campaign.update-status", "target_id": "120212345678901", "payload": {"status": "PAUSED"}}}
{"tool": "meta_validate_plan", "arguments": {"plan_id": "pln_abc123"}}
{"tool": "meta_execute_plan", "arguments": {"plan_id": "pln_abc123", "approval_token": "apt_...", "operator_confirmation": true}}
```

Whole-brief build (`recipe build`, either channel): `agency_build_plan` (spec + plan envelope +
verdict, imported to the Plans page on a SaaS session, born PAUSED) → human reviews the artifact
(review URL / `review.html`) → YES → `gads_execute_plan` / `meta_execute_plan` (approve + execute
+ poll) → `meta_verify_execution` / `gads_verify_execution`. If it needs undoing:
`agency_rollback_plan` (channel-aware; also rollback-eligible for a `failed` plan whose receipt
created at least one resource — read `completed_through` first, don't just build a fresh plan on
top of live orphans).

```json
{"tool": "agency_build_plan", "arguments": {"channel": "google", "customer_id": "1234567890", "brief": {"objective": "leads", "final_url": "https://example.com", "daily_budget_micros": 20000000}}}
{"tool": "agency_rollback_plan", "arguments": {"channel": "google", "plan_id": "pln_g_9a3f", "operator_confirmation": true, "confirm_destructive": true}}
```

### Handing a plan to AgencyPlaybook, and picking one back up (both directions)

**SaaS → CLI** (you built/approved a plan in the MCP or on the Plans page and want to run or
re-inspect it from a terminal): `agency_export_plan` returns the envelope, its `plan_hash`, and
the exact apply command for the row's channel — `apb plan apply --from-file plan.json --execute`
(Meta) or `apb-gads mutate apply-plan --from-file plan.json --execute` (Google). Dry-run first
with `apb plan validate --from-file` / `--validate-only`. Equivalent CLI-only form: `apb plan get
--id <id> --format v2 > plan.json`. `plan_hash` is re-verified on apply — a hand-edited file needs
`--allow-edited-plan`; say so explicitly rather than adding it silently. `apb plan export
--from-file plan.json --format html|editor-csv` renders the same envelope for human review or
Google Ads Editor.

**CLI → SaaS** (you built a plan on the CLI — `recipe build`, `plan merge`, `orchestrate …
--plan`, `apb plan export` — and want it on the Plans page for approval): the resulting
`plan.json` imports via the existing import path — `meta_execute_plan` (Meta) or
`gads_export_plan` (Google) picks up an on-disk envelope and imports it, or `POST
/api/v1/plans/import` / `/api/v1/gads/plans/import` directly — after which it appears on
`/plans/<id>` for a human approve, same as anything built through the MCP. `{{ref:aN}}` /
`{{account}}` temp references in a create-class envelope are bound by the EXECUTOR at run time
(SaaS job runner and both CLIs share one ref map per run) — never hand-edit them.

### CLI-only planning verbs

The MCP wraps `agency_build_plan` / `agency_merge_plans` / `agency_forecast_plan` over the three
most common of these — the rest stay terminal-only.

`plan merge --from a.json --from b.json --mode … --horizon …` (N envelopes → one ranked,
wave-sequenced envelope; MCP twin: `agency_merge_plans`), `plan forecast --adset-spec … /
--campaign-id …` (MCP twin: `agency_forecast_plan`), `apb-gads recipe build` / `apb recipe build`
(MCP twin: `agency_build_plan`), `plan validate --from-file`, `plan doctor --from-file` (structural
lint before validate), `plan get --id <id> --format v2`, `plan export --from-file … --format
html|editor-csv`, `plan review-batch` / `plan approve-batch` (batch human review), `plan canary`
(staged rollout), `portfolio plan` (cross-account), `experiment --treatment-plan <envelope>` (A/B
test a plan against a live baseline). None of these have a direct MCP tool beyond the three named
above — run them in a terminal, then hand the result back through the CLI → SaaS import path.

## Artifact layout

```
briefs/<slug>.yaml            research/keywords.json        build/structure.json   build/rsa.json
build/goals.json              build/spec.json (v1) | spec.v2.json                 build/plan.md
build/copy-sources.md         build/post-launch.md (today only)                    build/validate.json
build/plan.json                build/editor/*.csv (sprint-g05)                     launch.json (after --execute)
```
