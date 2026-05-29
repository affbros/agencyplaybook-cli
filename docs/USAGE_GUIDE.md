# Usage Guide

Practical guide for using `apb` (Rust) to manage Meta Marketing API campaigns. Covers setup, common workflows, and real-world examples.

> **Tenant disable propagation:** When an admin disables a tenant via `/admin/tenants`, the CLI begins returning `403 tenant_inactive` within **30 seconds** (the local `~/.apb/tenant_context.json` cache TTL).
>
> **Active ad account:** a command targets `--account` if given, else `META_AD_ACCOUNT_ID` from the `.env`/env where you ran `apb`, else the persisted global default in `~/.apb/config.json` (set via `apb account set-default --account act_…`). **The `.env` value wins over the global default (v0.2.1+)** — if they differ, `apb` prints a loud `note:`. Every run prints `[apb] account: … (source: …)` so the active account is never a mystery. Full precedence: CLI_REFERENCE.md → "Account resolution precedence".
>
> **Switching accounts the easy way (cli-account-switching):** save a profile once — `apb account profile add scandalous --account act_… --token-env SCANDALOUS_TOKEN` — then `apb account use scandalous` flips the account **and** its token together in one command. `apb account current` shows the active account and whether your token can actually reach it (catching a mismatch before it 403s).
>
> **Naming uploaded assets (v0.2.2+):** image/video uploads accept an explicit name — `--name` on `creative upload-image`/`upload-video`, and per-asset `--image-name`/`--video-name`/`--thumbnail-name`/`--hero-image-name` on the `create-*` builders. Omit it and the asset is named by the file's basename. See CLI_REFERENCE.md → "Naming uploaded assets".

---

## Quick Start

### 1. Prerequisites

- Rust 1.75+ (`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`)
- A Meta Marketing API access token with `ads_read` and `ads_management` scopes

### 2. Setup

```bash
cd rust/

# Copy the .env from the parent project (or create one)
cp ../.env .env

# Verify your .env has META_ACCESS_TOKEN set
grep META_ACCESS_TOKEN .env
```

### 3. Build

```bash
cargo build --release
```

The binary is at `target/release/apb`.

### 4. Verify

```bash
# Test authentication
cargo run -p apb-cli -- auth test --json

# Run full diagnostics
cargo run -p apb-cli -- doctor check --json
```

---

## Common Workflows

### Quick DCO Experiments (inline flags)

For ad-hoc creative testing, the inline `--image / --title / --body / --cta / --url` flags compile into the same `asset_feed_spec` shape that `--spec-file` produces. The existing spec-file path is preserved bit-exact for production use.

**Hashes only — pure dry-run, no upload:**

```bash
apb creative create-dynamic \
  --name "DCO Test - May" \
  --page-id 1234567890 \
  --image abc123def456 \
  --image fedcba654321 \
  --title "Lower Your Monthly Payment" \
  --title "Compare Loan Options Fast" \
  --body  "Check your options without hurting your credit." \
  --body  "See personalized offers in minutes." \
  --cta   LEARN_MORE \
  --url   https://example.com \
  --account act_123 --dry-run --json
```

**Mixed paths and hashes:**

```bash
# Path inputs upload via creative.upload_image under --execute.
# Under --dry-run, paths get a <dry_run_placeholder:./img.jpg> stamp so the spec is verifiable end-to-end.
apb creative create-dynamic \
  --name "Mixed" --page-id 1234567890 \
  --image ./fixtures/img1.jpg --image abc123def456 \
  --title T --body B --cta LEARN_MORE --url https://x.com \
  --account act_123 --dry-run --json
```

**Conflict (rejected):**

```bash
apb creative create-dynamic --spec-file dco.json --image abc123 \
  --name X --page-id 1234567890
# → exit 2, stderr: Cannot use --spec-file together with inline DCO flags. Use one input mode.
```

For canonical multi-variant production specs, prefer the `--spec-file` flow with a checked-in `asset_feed_spec.json`.

### Workflow 1: Daily Performance Check

```bash
# Account overview
apb account overview --json

# Last 7 days performance
apb report insights --days 7 --json

# Breakdown by age and gender
apb report breakdown --type age_gender --days 7 --json

# Compute derived metrics (ROAS, CPA, hook rate)
apb metrics compute --days 7 --level campaign --json

# Growth readiness score
apb growth score --days 30 --json
```

### Workflow 2: Learning Phase Analysis

```bash
# Diagnose learning issues per adset
apb learning diagnose --days 14 --json

# Scorecard with grades
apb learning scorecard --days 14 --json

# Weekly volume vs thresholds
apb learning volume --event purchase --json

# Budget prescription for a specific campaign
apb learning prescribe --campaign 120213456789 --days 14 --json
```

### Workflow 3: Scaling Decision

```bash
# Playbook evaluation (9 triggers checked)
apb playbook evaluate --days 30 --json

# Growth score
apb growth score --days 30 --json

# Budget simulation: shift 20% spend from adset A to B
apb budget simulate --shift-from 120200001 --shift-to 120200002 --pct 20 --days 30 --json

# Scale forecast
apb dataset scale-forecast --budget 100 --days 30 --campaign 120213456789 --json
```

### Workflow 4: Targeting Research

```bash
# Search interests
apb targeting interest-search --query "fitness" --limit 20 --json

# Get suggestions from seed interests
apb targeting interest-suggest --query "6003139266461,6003277229371" --json

# Validate interest IDs still exist
apb targeting interest-validate --ids "6003139266461,6003277229371" --json

# Geographic targeting
apb targeting geo-search --query "New York" --json

# Audience size estimate from a targeting spec
apb targeting estimate --spec-file targeting.json --json
```

### Workflow 5: Creative Management

```bash
# List all creatives
apb creative list --limit 50 --json

# Audit creative health (orphans, stale, missing assets)
apb creative asset-audit --json

# Upload an image
apb creative upload-image --path ./ad-image.jpg --json

# Upload a video, then build a video creative WITH a thumbnail.
# --thumbnail accepts a local path (uploaded for you) or an existing image hash.
# Meta requires a thumbnail on every video creative; the CLI injects it as
# object_story_spec.video_data.image_hash and fails fast if none is supplied.
apb creative upload-video --path ./ad.mp4 --name "Spring Promo" --execute --json   # → video_id
apb creative create-video --name "Spring Promo Creative" \
  --spec '{"object_story_spec":{"page_id":"123","video_data":{"video_id":"<VIDEO_ID>","message":"..."}}}' \
  --thumbnail ./thumb.jpg --execute --json

# Check creative quality metrics
apb metrics creative-quality --days 30 --json

# Creative lifecycle pipeline
apb dataset creative-pipeline --days 30 --json
```

### Workflow 5a: Format audit guard (v0.2.0)

Every `creative create-*` and `creative update` runs a format auditor before any write — detects unintended Meta v25 format-expansion fields (CAROUSEL / COLLECTION / FORMAT_AUTOMATION / `product_set_id` / etc.) that can cause Meta to render an ad in a format the operator never intended. This is the Scandalous Coffee fix (incident 2026-05-23). Full taxonomy at [`CREATIVE_AUDITOR.md`](./CREATIVE_AUDITOR.md).

```bash
# Inspect a spec without writing (audit-only)
apb creative create-image --name "review" --spec-file ./ad.json --audit-only --json | jq '.format_audit'

# Trap a creative spec with unintended formats (Scandalous-style trap)
cat >/tmp/trap.json <<JSON
{"object_story_spec":{"page_id":"P","link_data":{"image_hash":"H","link":"https://x"}},
 "asset_feed_spec":{"ad_formats":["CAROUSEL","COLLECTION"],"optimization_type":"FORMAT_AUTOMATION"}}
JSON

# Dry-run surfaces 3 findings (exit 0; advisory)
apb creative create-image --name "test" --spec-file /tmp/trap.json --json

# --execute → blocked with actionable error naming each finding + the flag that whitelists it (exit 2)
apb creative create-image --name "test" --spec-file /tmp/trap.json --execute
# error: Creative format audit failed: CAROUSEL, COLLECTION, FORMAT_AUTOMATION detected …
#        Pass --allow-carousel --allow-collection --allow-format-automation to override.

# Operator confirms intent with the three whitelisting flags
apb creative create-image --name "test" --spec-file /tmp/trap.json --execute \
  --allow-carousel --allow-collection --allow-format-automation

# In CI: upgrade dry-run findings to errors (fail loud on any finding)
apb creative create-image --name "ci" --spec-file ./ad.json --strict-format
```

### Workflow 5b: Reels / Stories placement preset (v0.2.0)

`adset create` and `adset update-targeting` accept `--placements <PRESET>` to expand a curated placement shape into v25 `publisher_platforms` / `facebook_positions` / `instagram_positions`. Six presets: `feed`, `stories`, `reels`, `stories-reels`, `feed-stories-reels`, `advantage-plus`. Full reference at [`CLI_REFERENCE.md`](./CLI_REFERENCE.md#5-adset).

```bash
# Reels-only ad set, US + age 25-54. Preset merges cleanly with geo + age targeting.
apb adset create --campaign 120... --name "Q2 reels" \
  --optimization-goal LINK_CLICKS --billing-event IMPRESSIONS \
  --lifetime-budget 50 --start-time "2026-06-01T00:00:00-0700" --end-time "2026-06-08T00:00:00-0700" \
  --targeting '{"geo_locations":{"countries":["US"]},"age_min":25,"age_max":54}' \
  --placements reels --advantage-audience 0

# Switch an existing ad set to Stories placements only.
apb adset update-targeting --id 120... \
  --spec '{"geo_locations":{"countries":["US"]}}' --placements stories --execute

# Advantage+ Placements (Meta auto-decides across FB/IG/AN/Messenger).
apb adset create … --placements advantage-plus

# Conflict: operator already supplied publisher_platforms. Exit 2 with both sides named.
apb adset create … --targeting '{"publisher_platforms":["audience_network"]}' --placements reels
# error: --placements reels conflicts with --targeting.publisher_platforms (operator set
#        ["audience_network"], preset wants ["facebook","instagram"]). Remove one of them.
```

**Important quirk:** Instagram's "feed" equivalent in Meta v25 is called `stream`, not `feed`. The preset handles this for you — operators only need to remember the preset name.

### Workflow 5c: Ergonomic creative builders + leadgen ad-create (v0.2.0)

Six ergonomic builders that take flags and generate the v25 `AdCreative` spec internally, plus an end-to-end `leadgen ad-create` orchestrator. Full reference at [`CLI_REFERENCE.md`](./CLI_REFERENCE.md#7-creative). Every builder runs the Sprint 1 auditor; the catalog builder auto-wires matching allows from `--format` intent.

```bash
# Single-image creative — no JSON authoring needed.
apb creative create-image-simple --name "Q2 promo" --page-id PAGE \
  --image ./hero.jpg --headline "Bold coffee" --body "Try Scandalous" \
  --url https://scandalous.example --cta SHOP_NOW --execute

# Video creative with thumbnail (both auto-uploaded if paths).
apb creative create-video-simple --name "Q2 video" --page-id PAGE \
  --video ./ad.mp4 --thumbnail ./thumb.jpg --headline "Watch" --body "..." \
  --url https://x.example --cta LEARN_MORE --execute

# Lead-form ad — first lead_gen_form_id injection in the CLI.
apb creative create-lead-form-ad --name "Lead capture" --page-id PAGE \
  --form-id 999 --image ./hero.jpg --headline "Sign up" --body "Free coffee" \
  --url https://x.example --cta SIGN_UP --execute

# Catalog creative — auto-wires --allow-collection from --format intent.
apb creative create-catalog-creative --name "DPA" --page-id PAGE \
  --catalog-id 123 --product-set-id 456 --hero-image ./hero.jpg \
  --headline "Shop" --format collection --execute
# (Without the builder you'd need to hand-pass --allow-collection AND --allow-catalog-template.)

# Stories-suitable creative — emits 9:16 / safe-zone advisories on result.
apb creative create-story-template --name "Story" --page-id PAGE \
  --image ./vertical-1080x1920.jpg --headline "Try us" --execute

# Reels-suitable video — emits ≤90s + safe-zone advisories.
apb creative create-reels-video-template --name "Reel" --page-id PAGE \
  --video ./reel.mp4 --thumbnail ./thumb.jpg --headline "Bold" --execute

# End-to-end lead-form ad: validates campaign objective + form/page link,
# creates lead-form creative + ad, reverse-pauses on partial failure.
apb leadgen ad-create --name "Lead Q2" --campaign 120... --adset 120... \
  --form-id 999 --image ./hero.jpg --headline "Sign up" --body "Free coffee" --execute
```

### Workflow 5d: Built-in compose presets (v0.2.0)

`compose-from-spec` accepts 6 built-in `--preset` names that produce full campaign + adset + creative + ad stacks from just operator-friendly args. Built-in presets take precedence over user-saved presets; collision = fail-loud.

```bash
# Sales video stack — OUTCOME_SALES + LINK_CLICKS adset + video creative shell.
apb campaign compose-from-spec --preset sales-video \
  --campaign-name "Q2 Sales" --page-id PAGE_ID --pixel-id PX_ID --daily-budget 25

# Lead-form stack — OUTCOME_LEADS + LEAD_GENERATION adset + lead-form creative
# (reuses Sprint 3's lead_gen_form_id CTA shape).
apb campaign compose-from-spec --preset lead-form \
  --campaign-name "Lead capture Q2" --page-id PAGE --form-id FORM_999 --daily-budget 10

# Catalog-sales stack — auto-uses OFFSITE_CONVERSIONS when --pixel-id given,
# otherwise falls back to LINK_CLICKS.
apb campaign compose-from-spec --preset catalog-sales \
  --campaign-name "DPA" --page-id PAGE --catalog-id CAT_1 --product-set-id PS_42 \
  --pixel-id PX_1 --daily-budget 50

# Reels stack — Sprint 2's reels placement preset shape baked into the adset.
apb campaign compose-from-spec --preset reels-video \
  --campaign-name "Reels promo" --page-id PAGE --daily-budget 15

# Other built-ins: sales-carousel, stories-video
```

**Precedence rule:** if you've saved a user preset with the same name as a built-in (e.g. `apb campaign preset save --name sales-video ...`), `compose-from-spec --preset sales-video` exits 2 with a shadowing error. Rename one. Built-in names are reserved.

**Required args per preset** — see `apb campaign compose-from-spec --help`. Common requirements: `--campaign-name`, `--page-id`, `--daily-budget`. Lead-form additionally needs `--form-id`; catalog-sales needs `--catalog-id` + `--product-set-id`.

### Workflow 6: Safe Campaign Update (Plan Lifecycle)

The safest way to make changes is through the plan system:

```bash
# Step 1: Create a plan
apb plan create --campaign 120213456789 \
  --name "pause-campaign" --spec-file payload.json --json

# payload.json: {"status": "PAUSED"}

# Step 2: Validate the plan
apb plan validate --plan-id plan_abc123 --json

# Step 3: Review what will happen
apb plan doctor --plan-id plan_abc123 --json

# Step 4: Execute safely (requires all write gates open)
export META_CTL_ALLOW_MUTATIONS=true
apb plan execute-safe --plan-id plan_abc123 --execute --json
```

### Workflow 7: Campaign Duplication

```bash
# Preview the clone plan (DRY-RUN)
apb campaign duplicate --id 120213456789 --name "Q2 Campaign Copy" --json

# Execute the duplication (all write gates must be open)
export META_CTL_ALLOW_MUTATIONS=true
apb campaign duplicate --id 120213456789 --name "Q2 Campaign Copy" --execute --json
```

### Workflow 8: State Tracking

```bash
# Take a snapshot of current state
apb sync pull --json

# ... time passes, changes happen ...

# Take another snapshot
apb sync pull --json

# Compare snapshots
apb sync diff --json
```

### Workflow 9: Async Reporting

For large reports that take time to generate:

```bash
# Start the report
apb report insights-async start --days 30 --level adset --json
# Returns: {"job_id": "120213456789"}

# Poll status
apb report insights-async status --job-id 120213456789 --json
# Returns: {"status": "Job Running", "percent_complete": "45%"}

# Fetch results when complete
apb report insights-async fetch --job-id 120213456789 --json
```

### Workflow 10: Split-Test Lifecycle (A/B)

```bash
# 1) Create split test (preview by default)
apb split-test create \
  --name "Spring Promo Split" \
  --variant-a-adset 120200001 --variant-a-ad 120300001 \
  --variant-b-adset 120200002 --variant-b-ad 120300002 \
  --daily-budget 20 --duration-days 7 --json

# 2) Execute creation (all write gates open + --execute)
export META_CTL_ALLOW_MUTATIONS=true
apb split-test create \
  --name "Spring Promo Split" \
  --variant-a-adset 120200001 --variant-a-ad 120300001 \
  --variant-b-adset 120200002 --variant-b-ad 120300002 \
  --daily-budget 20 --duration-days 7 --execute --json

# 3) Check current status
apb split-test status --id st_abcd1234 --json

# 4) Evaluate winner by KPI
apb split-test evaluate --id st_abcd1234 --days 7 --kpi purchase --json

# 5) Promote winner and scale budget
apb split-test promote --id st_abcd1234 --winner B --scale 1.5 --execute --json
```

### Workflow 11: Carousel Creative from Spec

```bash
# Preview carousel creative creation (dry-run)
apb creative create-carousel \
  --name "Spring Carousel v1" \
  --spec-file ./carousel-spec.json \
  --json

# Execute once write gates are open
export META_CTL_ALLOW_MUTATIONS=true
apb creative create-carousel \
  --name "Spring Carousel v1" \
  --spec-file ./carousel-spec.json \
  --execute --json
```

Example `carousel-spec.json` shape:

```json
{
  "object_story_spec": {
    "page_id": "123456789",
    "link_data": {
      "message": "Shop the full collection",
      "link": "https://example.com/collection",
      "child_attachments": [
        {"link":"https://example.com/a","name":"Card 1","description":"First","image_hash":"abc"},
        {"link":"https://example.com/b","name":"Card 2","description":"Second","image_hash":"def"}
      ],
      "multi_share_optimized": true,
      "multi_share_end_card": false
    }
  }
}
```

### Workflow 12: Andromeda Plan + Launch

```bash
# 1) Build a volume plan and persist state/andromeda/<plan_id>.json
apb andromeda plan \
  --campaign 120213456789 \
  --adset 120200001 \
  --volume 24 \
  --angles "Pain-point relief,Outcome proof,Objection handling" \
  --formats image,video \
  --days 14 \
  --json

# 2) Preview launch guidance (no creative ids yet)
apb andromeda launch --plan-id andromeda_xxx --json

# 3) Launch ads from creative IDs (write path)
export META_CTL_ALLOW_MUTATIONS=true
apb andromeda launch \
  --plan-id andromeda_xxx \
  --creative-ids 120300001,120300002,120300003 \
  --status PAUSED \
  --execute --json
```

### Workflow 13: Full Account Audit

```bash
# Diagnostics
apb doctor check --json
apb doctor api-compat --json
apb doctor quota --json

# Coverage audit
apb coverage audit --json

# Dataset readiness
apb dataset readiness --days 30 --json

# Agency operations cockpit
apb dataset agency-ops --days 30 --json

# Pixel health
apb dataset pixel-health --json
apb dataset pixel-quality --days 30 --json
```

---

### Workflow 14: Playbook Catalog by Pillar

The catalog returns all 24 playbooks grouped by pillar (`learning`, `signal`, `scaling`, `turnaround`):

```bash
apb playbook catalog --json | jq '.playbooks | group_by(.pillar)'
```

Run a single playbook by slug:

```bash
apb playbook health-score --days 30 --json
apb playbook event-downgrade-ladder --days 90 --json
apb playbook reset-rebuild-advisor --days 90 --json
```

---

### Workflow 15: Learning Phase Diagnosis (deep dive)

When an account is bleeding cash and you suspect Meta's learning phase is the root cause, run the four learning-pillar playbooks together:

```bash
# 1. How much budget is needed to exit learning?
apb playbook learning-accelerator --days 90 --json | jq '.post_learning_impact'

# 2. Should we downgrade the optimization event for any adset?
apb playbook event-downgrade-ladder --days 90 --json | jq '.findings | map(select(.downgrade_required))'

# 3. Are we touching learning-phase adsets too often?
apb playbook no-touch-compliance --json | jq '.data'

# 4. Are we fragmenting low-volume campaigns?
apb playbook consolidation-advisor --days 14 --json | jq '.findings | map(select(.should_consolidate))'

# 5. Pre-launch readiness for new campaigns
apb playbook launch-check --json
```

---

### Workflow 16: Account Turnaround (composite rebuild)

When health-score drops below 60 and multiple red flags are firing, use the composite turnaround playbook:

```bash
# Single composite call — runs health/waste/fatigue/learning in parallel
apb playbook reset-rebuild-advisor --days 90 --json | jq '{
  triggered: .triggered,
  health: .findings.health_score,
  red_flags: .findings.red_flags,
  rebuild_plan: .rebuild_plan
}'
```

When `triggered: true`, the response includes a 4-phase rebuild plan with concrete actions tied to other playbooks. When false, the recommendation is "continue routine optimization" with the underlying health score.

---

### Workflow 17: Scaling Decision (incremental vs duplication)

```bash
# Generate the per-campaign tier grid
apb playbook scale-roadmap --days 90 --json | jq '.findings[] | {
  campaign: .campaign_name,
  current: .current_daily_spend,
  learning_limited: .learning_limited,
  recommended: (.tiers | map(select(.projected_roas >= 1.0)) | sort_by(.daily_budget) | last)
}'
```

The response includes both `incremental` (+20%, +30%, 1.2x) and `duplication` (1.5x, 2x, 3x) tiers per campaign. Learning-limited campaigns auto-force all tiers onto the incremental path so duplication doesn't reset learning.

---

### Workflow 18: Signal Engineering Audit

```bash
# Funnel-stage alignment check
apb playbook event-hierarchy-audit --json

# CAPI coverage check
apb playbook capi-dual-signal --json

# Targeting breadth check
apb playbook broad-targeting-audit --json

# Retargeting window compression
apb playbook retargeting-compression --json

# Creative format diversity + DCO eligibility
apb playbook creative-mix --json

# Audience saturation
apb playbook saturation --days 30 --json
```

---

### Workflow 19: Destructive Cleanup — Delete Test Objects

DELETE is **terminal and irreversible**. Prefer `update-status --status ARCHIVED` for reversible cleanup. Use DELETE only when you intend to fully remove an object (e.g., cleaning up sandbox test campaigns).

```bash
# 1. Discover sandbox test campaigns (by naming convention)
apb campaign list --limit 200 --json \
  | jq -r '.[] | select(.name | startswith("APB-TEST-SANDBOX-")) | .id'

# 2. Dry-run delete (no --execute — just previews blast radius)
apb campaign delete --id 120241514062480265 --confirm-destructive --json
# → {"dry_run": true, "destructive": true, "blocked_reasons": ["--execute flag not provided"]}

# 3. Live delete — requires BOTH --execute AND --confirm-destructive,
#    PLUS the 4 write-gate env vars (READ_ONLY=false, ALLOW_WRITES=true,
#    META_CTL_ALLOW_MUTATIONS=true, APB_ALLOW_MUTATIONS=true).
READ_ONLY=false ALLOW_WRITES=true META_CTL_ALLOW_MUTATIONS=true APB_ALLOW_MUTATIONS=true \
  apb campaign delete \
    --id 120241514062480265 \
    --execute --confirm-destructive --json
# → {"deleted": true, "campaign_id": "120241514062480265", "result": {"success": true}}

# Same surface exists for adsets and ads:
apb adset delete --id <adset_id> --execute --confirm-destructive --json
apb ad    delete --id <ad_id>    --execute --confirm-destructive --json
```

**HTTP equivalents** (same gates — both query params required):

```bash
curl -X DELETE \
  -H "Authorization: Bearer apb_live_ent_..." \
  "https://api.agencyplaybook.io/api/v1/campaigns/120241514062480265?execute=true&confirm_destructive=true"
```

`DELETE` actions are also available through the plan lifecycle as
`campaign.delete` / `adset.delete` / `ad.delete` — each carries blast radius
5 (CRITICAL) and dispatches to `graph_delete` instead of `graph_post` at
execute time.

### Workflow 20: Dayparting / ad scheduling (lifetime-budget required)

Meta's `adset_schedule` (the dayparting / ad-scheduling feature) only works on
**lifetime-budget** ad sets, and the budget *type* is frozen at create. The
right move is to build a **new** lifetime-budget campaign/ad set; you can't
retrofit a daily-budget one.

```bash
# Campaign with no budget (ABO — budget lives on the ad set):
apb campaign create --name "Evening Sales" --objective OUTCOME_SALES \
  --status PAUSED --budget-sharing false --execute

# Ad set: lifetime budget + start/end window + dayparting builder.
# `--daypart-hours` merges consecutive hours into windows; the CLI sets
# `pacing_type=["day_parting"]` automatically when a schedule is present.
apb adset create --campaign <campaign_id> \
  --optimization-goal OFFSITE_CONVERSIONS \
  --bid-strategy LOWEST_COST_WITHOUT_CAP \
  --lifetime-budget 350 \
  --start-time 2026-06-01T00:00:00 --end-time 2026-06-08T23:59:00 \
  --daypart-hours "9,12,16,19,21" --daypart-timezone ADVERTISER \
  --promoted-object '{"pixel_id":"<pixel>","custom_event_type":"ADD_TO_CART"}' \
  --status PAUSED --execute
```

**Pre-flight guards (all fire during `--dry-run` with exit 2, before any network
call) — no false positives, lookup failures and `USER`-timezone windows pass
through:**

| Guard | Triggers when | Since |
|---|---|---|
| **Schedule needs lifetime budget** | `--daypart-hours` / `--adset-schedule` + `--daily-budget` on create; or `adset update --adset-schedule` on a daily-budget ad set (or its CBO parent campaign) | v0.1.15 / v0.1.17 |
| **Windows must fit the flight** | Any `timezone_type=ADVERTISER` window's recurring slot never intersects `start_time → end_time` (e.g. a 10-hour flight with windows past `end_time`). Skipped for flights ≥ 7 days (every weekday + interior days run full windows). | v0.1.20 |
| **Conversion goal needs `promoted_object`** | `--optimization-goal OFFSITE_CONVERSIONS` or `VALUE` and no `--promoted-object` | v0.1.19 |
| **Objective must be ODAX** | `campaign create` (or `compose-from-spec`) with a non-`OUTCOME_*` objective (legacy CONVERSIONS / LINK_CLICKS / …); error includes the mapping hint | v0.1.19 |

**Pacing advisories** (soft, non-blocking) — the create/update result includes
an `advisories[]` array when Meta would accept the setup but it's likely to
under-deliver: flight < 24h, flight < 6 days (Meta's learning phase), or a
lifetime / dayparted ad set with no `--end-time`. Surface these to the
operator; don't treat them as errors.

The dry-run preview's `would_create` (v0.1.20) echoes the full request body —
budget, targeting, `promoted_object`, `pacing_type`, schedule, flight — so the
wiring can be verified before `--execute`. `adset list` rows also include
`pacing_type` alongside the boolean `dayparting` flag.

For full manual control, pass Meta's schedule JSON directly with
`--adset-schedule '<json|file>'` (it overrides `--daypart-hours`).

---

## Unattended Execution

For CI/CD pipelines, cron jobs, AI-agent workflows, and shell scripts, the canonical reference is [`docs/CLI_AUTOMATION.md`](../../docs/CLI_AUTOMATION.md). Highlights:

- `--no-input` promises no stdin reads (does **not** imply approval)
- `--json` gives a structured `{ok, error: {code, message, exit_code, details?}}` envelope on failure
- `--debug` enables stderr tracing with token/secret sanitization
- `--no-color` (or `NO_COLOR=1` / `CLICOLOR=0` env) disables ANSI for log aggregators
- Per-class exit codes (0 success / 1 general / 2 validation / 3 auth / 4 safety gate / 5 network)

See [`SAFETY_MODEL.md → Layer 5: Unattended Execution Contract`](./SAFETY_MODEL.md#layer-5-unattended-execution-contract) for the full safety-gate semantics.

---

## Output Formats

### JSON Mode

Pass `--json` to any command for machine-readable output:

```bash
apb campaign list --limit 3 --json | jq '.[] | .name'
```

### Human Mode

Default mode renders ASCII tables:

```
Campaigns (3) for act_123456:
  id              name                 status  objective     daily_budget
  ---------------  -------------------  ------  -----------   -----------
  120200000001     Summer Sale 2024     ACTIVE  CONVERSIONS   $50.00
  120200000002     Brand Awareness Q2   PAUSED  REACH         $25.00
  120200000003     Retargeting Pool     ACTIVE  CONVERSIONS   $100.00
```

### Piping and Scripting

```bash
# Get all active campaign IDs
apb campaign list --limit 100 --json | jq -r '.[] | select(.status == "ACTIVE") | .id'

# Check if any adset has high frequency
apb learning diagnose --days 14 --json | jq '.diagnostics[] | select(.frequency > 3.0)'

# Export insights to CSV (via jq)
apb report insights --days 7 --json | jq -r '
  ["campaign","impressions","clicks","spend"],
  (.[] | [.campaign, .impressions, .clicks, .spend]) | @csv'
```

---

## Environment Configuration

### Minimal .env for read-only operations

```env
META_ACCESS_TOKEN=EAABsbCS...
```

### Full .env for development with write support

```env
META_ACCESS_TOKEN=EAABsbCS...
META_GRAPH_VERSION=v25.0
META_GRAPH_BASE=https://graph.facebook.com
META_MAX_RETRIES=3

# Safety — opens gates 2 and 3
READ_ONLY=false
ALLOW_WRITES=true
```

### Enabling mutations (gate 4)

Never put this in `.env`. Export it in your shell session when you intend to make changes:

```bash
export META_CTL_ALLOW_MUTATIONS=true

# Now writes will work (with --execute flag)
apb campaign update-status --id 123 --status PAUSED --execute --json

# When done, close the gate
unset META_CTL_ALLOW_MUTATIONS
```

---

## Building ad-set targeting from flags (no JSON)

Instead of hand-authoring `--targeting '{…}'`, build the spec from flags (Tier 3). The two modes are mutually exclusive — passing both fails loud.

```bash
# Women 25–54 in US/CA, interested in interest 6003107902433, on mobile, excluding a CA
apb adset create --campaign 120... --name "TB demo" \
  --optimization-goal LINK_CLICKS --billing-event LINK_CLICKS --daily-budget 50 \
  --countries US,CA --age-min 25 --age-max 54 --genders 2 \
  --interests 6003107902433 --device-platforms mobile \
  --exclude-custom-audiences 99887 \
  --dry-run --json
```

- `--interests` accepts IDs **or names** (a name resolves to the top interest-search match); `--behaviors` and `--custom-audiences` take IDs (find them via `apb targeting interest-search` / `behavior-search`).
- `--regions`/`--cities` take Meta location **keys** from `apb targeting geo-search`.
- Anything the builder doesn't cover: drop to `--targeting` JSON, or inject via `--extra-fields`.

## Escape hatch: `--extra-fields`

`campaign create` and `adset create` accept `--extra-fields '<json-object>'` — keys are merged into the body for Meta fields apb doesn't flag yet. It **bypasses validation** (advisory in the dry-run) and **fails loud** if a key collides with one apb manages. Always `--dry-run` first.

---

## Troubleshooting

### "META_ACCESS_TOKEN is not set"

Your `.env` file is missing or the token is empty. Ensure the file exists in the `rust/` directory and contains a valid token.

### "No ad accounts found for this token"

The token doesn't have access to any ad accounts. Verify with:

```bash
apb auth test --json
```

Check that `ad_accounts` is not empty and that the token has `ads_read` scope.

### API rate limiting

If you see rate limit errors, check quota pressure:

```bash
apb doctor quota --json
```

If pressure is `high` or `critical`, wait before making additional calls. The client automatically retries with exponential backoff (8s, 16s, 32s for rate limits).

### DRY-RUN when you expect a write

Check which gates are blocking:

```bash
apb doctor check --json | jq '.checks[] | select(.check == "write_gates")'
```

All four gates must be open:
1. `--execute` on the command
2. `READ_ONLY=false`
3. `ALLOW_WRITES=true`
4. `META_CTL_ALLOW_MUTATIONS=true`

### Stale data in sync diff

Run `sync pull` to capture a fresh snapshot:

```bash
apb sync pull --json
```

---

## Attribution Windows

The report commands support Meta's attribution window controls:

```bash
# 7-day click + 1-day view attribution
apb report insights --days 30 --attribution "7d_click,1d_view" --json

# Use account-level attribution settings
apb report insights --days 30 --use-account-attribution true --json

# Conversion-time reporting
apb report insights --days 30 --action-report-time conversion --json
```

**Valid windows (common):** `1d_click`, `7d_click`, `28d_click`, `1d_view`, `7d_view`, `28d_view`, `1d_ev`, `dda`, `default`

**Valid report times:** `impression`, `conversion`, `mixed`

> Tip: `--attribution` accepts CSV (for example `7d_click,1d_view`) and the CLI sends it to Meta as an attribution-window array.

### Flexible Metrics, Presets, and Profiles

```bash
# 1) Pull arbitrary metrics directly from insights
apb report metrics \
  --level ad \
  --days 7 \
  --metrics impressions,clicks,spend,ctr,cpc \
  --limit 10 \
  --json

# 2) List and run built-in presets
apb report presets list --json
apb report presets run --name core-performance --days 7 --json

# 3) Save and reuse a custom profile
apb report profile save \
  --name weekly-performance \
  --level campaign \
  --metrics impressions,clicks,spend,purchase_roas \
  --attribution 7d_click,1d_view \
  --action-report-time conversion \
  --use-account-attribution true \
  --json

apb report profile list --json
apb report profile run --name weekly-performance --days 7 --json
```

Profiles are stored in `state/report-profiles/*.json`.

---

## Thresholds Reference

These thresholds are used across learning, action, and diagnostic commands:

| Constant | Value | Used For |
|----------|-------|----------|
| `LOW_CONVERSION_VOLUME` | 10 | Flags adsets with < 10 conversions |
| `HIGH_FREQUENCY` | 4.0 | Flags audience fatigue risk |
| `LOW_CTR_PCT` | 0.5% | Flags weak engagement |
| `HIGH_CPC_USD` | $5.00 | Flags expensive traffic |
| `LOW_SPEND_SIGNAL_USD` | $10.00 | Flags insufficient data |
| `MEANINGFUL_SPEND_USD` | $50.00 | Minimum for meaningful analysis |
| `SCALE_CTR_PCT` | 1.5% | Scale candidate threshold |
| `SCALE_CONVERSION_MIN` | 20 | Scale candidate threshold |
| `SCALE_CPC_USD` | $2.00 | Scale candidate threshold |

### Weekly Learning Thresholds

| Event | Weekly Threshold | Description |
|-------|-----------------|-------------|
| Purchase | 50 | Events needed to exit learning |
| Add to Cart | 150 | Mid-funnel alternative |
| Landing Page View | 1,000 | Top-of-funnel alternative |
