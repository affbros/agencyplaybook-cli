# CLI handoff — exact sequences, artifact paths, deploy paths

Two eras. **Today** = what the shipped binaries accept (verified 2026-09-08 against `apb-gads 0.1.20`).
**After campaign-build-001** = `recipe build` + `CampaignBuildSpec v2` + Plan envelope (spec:
`ai/specs/campaign-build-001/product-spec.md`). Don't use "after" commands until the CHANGELOG says
they shipped.

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

## Today — Meta (`apb`)

`apb campaign compose-from-spec --spec-file spec.json` (campaign → adsets → creatives → ads; presets
via `campaign preset`); `--plan out.md` for plan-first; `apb plan export --id <plan>` → envelope →
`POST /api/v1/plans/import` → `/validate` → `/execute` in AgencyPlaybook. Example spec:
`rust/docs/examples/compose-spec.json`. The Meta **sandbox cannot create creatives** — validate
creative structure only; the write chain there stops at campaign + ad set.

## After campaign-build-001 (do not use until shipped)

```bash
$G recipe build --brief briefs/<slug>.yaml --out build/            # research → spec.v2.json → plan.json + plan.md + editor/ + research/
$G recipe build --spec build/spec.v2.json                          # re-run a hand-edited spec
$G recipe build --brief … --execute                                 # after YES; born PAUSED
```
Then `plan.json` (Plan envelope v2) imports via `POST /api/v1/gads/plans/import` (S3) and shows in
the web app's Plans page (S4). The brief's `targeting` / `negatives` / `assets` / `settings` blocks are
carried natively — `post-launch.md` disappears.

## MCP sequence (agent-driven, either era)

`gads_resolve_customer` → `gads_build_campaign_spec` (emits the spec; after S5 accepts the brief) →
`gads_validate_spec` → `gads_preview_change` → **human YES + approval token** → `gads_apply_change`
→ `gads_verify_execution`. Meta: `meta_build_campaign_spec` → `meta_create_plan` →
`meta_validate_plan` → YES → `meta_execute_plan`.

## Artifact layout

```
briefs/<slug>.yaml            research/keywords.json        build/structure.json   build/rsa.json
build/goals.json              build/spec.json (v1) | spec.v2.json                 build/plan.md
build/copy-sources.md         build/post-launch.md (today only)                    build/validate.json
build/plan.json (after S2)    build/editor/*.csv (after S2)                        launch.json (after --execute)
```
