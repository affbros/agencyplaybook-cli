# Canonical `apb` Workflows

16 examples covering the patterns CLI users actually run. Each one is dry-run-first and exit-code-safe.

---

## 1. First-time setup

```bash
# Generate an API key in the AgencyPlaybook UI at /api-keys, then:
export APB_API_KEY=apb_live_ent_a8f2c93b4d5e6f7g8h9i0j1k2l3m4n5o
# The binary already targets https://api.agencyplaybook.io.
# Local dev only: export APB_API_URL=http://localhost:3750

# Smoke test
apb auth test
# Exit 0 = connected. Exit 3 = bad/expired key (auth). Exit 2 = bad URL. Exit 5 = network.

# Connect Meta if you haven't already
apb auth connect-meta             # opens browser, polls for callback
```

## 2. Dry-run-then-execute (the universal pattern)

```bash
# 1. Dry run — never adds --execute on first attempt
apb campaign create --name "Q3 Launch" --objective OUTCOME_SALES --status PAUSED

# 2. Review the printed diff. If correct, re-run with --execute
apb campaign create --name "Q3 Launch" --objective OUTCOME_SALES --status PAUSED --execute
```

## 3. Plan create → validate → execute with rollback blueprint

For multi-entity workflows (campaign + adsets + ads), always use a plan — `plan validate` writes a rollback blueprint to disk (used by `plan doctor` for drift detection and audit).

```bash
PLAN_ID=$(apb plan create --spec-file my-plan.json --json | jq -r '.data.id')
apb plan validate --plan-id $PLAN_ID
apb plan execute-safe --plan-id $PLAN_ID --require-dry-run-pass --execute
# There is no one-shot replay command. To revert, pause/delete the created
# entities or author a reverse plan; inspect drift with: apb plan doctor --plan-id $PLAN_ID
```

## 4. Multi-account fan-out

```bash
# Run the same playbook across all authorized accounts
apb report insights --accounts all --days 30 --json

# Or specific accounts
apb report insights --accounts act_111,act_222 --days 30
```

## 5. Run a diagnostic playbook end-to-end

```bash
# Quick health check
apb playbook health-score --days 30 --json | jq '.data.composite_score'

# Deep waste audit with dollar projections
apb playbook waste-audit --days 30 --json > waste-report.json
jq '.data.recommendations[] | select(.projected_savings_usd > 100)' waste-report.json

# When health < 60, get a 4-phase rebuild plan
apb playbook reset-rebuild-advisor --days 30
```

## 6. Name-based ID resolution

Skip looking up Meta IDs — pass campaign / adset / ad names directly:

```bash
# Numeric IDs still work
apb campaign get --id 23847562834756123

# But names work too (auto-resolved; must match exactly one campaign)
apb campaign get --id "Q3 Launch"

# Or use aliases. Create one: apb alias set <name> <id>
apb campaign get --id @q3
```

## 7. Audience users-add closed loop (leadgen → custom audience)

```bash
# 1. Export leads from a form (Page Access Token required)
apb leadgen leads-export --form-id 1234567890 --output leads.csv

# 2. Hash & upload into a custom audience for retargeting
apb audience users-add --id 9876543210 --data-file leads.csv --execute

# PII discipline: apb logs only {audience_id, schema, row_count, batch_count}.
# Never the email/phone values.
```

## 8. Full-stack compose (campaign + adsets + creatives + ads in one shot)

```bash
# Spec file holds the full hierarchy
apb campaign compose-from-spec --spec-file q3-launch.json --with-estimates

# Execute with rollback on failure
apb campaign compose-from-spec --spec-file q3-launch.json --execute
# (Auto-pauses created entities in reverse order if any step fails.)
```

## 9. JSON output for shell pipelines

```bash
apb --json report insights --days 30 | jq '.data.campaigns[] | select(.roas > 2)'
```

`--json` is a global flag — it works in any position (most examples here trail it).

## 10. Exit-code branching in bash

```bash
apb auth test --no-input --json
case $? in
  0) echo "OK" ;;
  2) echo "Bad input — e.g. malformed --url; fix and rerun" ;;
  3) echo "Auth failed — bad/expired key or insufficient scope; refresh/upgrade" ;;
  5) echo "Network / rate-limit — back off and retry" ;;
  *) echo "Unexpected (1 = general/unmapped)" ;;
esac
```

## 11. Handling 429s gracefully

The CLI honors Meta's `Retry-After` header automatically (Retry-After-aware backoff + a 10-minute cross-invocation cooldown). For shell scripts, the simplest pattern is to retry on **exit 5** (network/rate-limit):

```bash
for i in 1 2 3; do
  apb report insights --days 30 --no-input --json && break
  [ $? -eq 5 ] && sleep $((10 * i)) && continue
  break
done
```

Want a tighter loop? On a rate-limit failure the `--json` envelope carries `error.code = "rate_limited"` and a concrete wait in `error.details.retry_after_ms` — wait exactly that long instead of guessing:

```bash
for i in 1 2 3; do
  out=$(apb report insights --days 30 --no-input --json) && { echo "$out"; break; }
  code=$(jq -r '.error.code // ""' <<<"$out")
  if [ "$code" = "rate_limited" ]; then
    ms=$(jq -r '.error.details.retry_after_ms // 0' <<<"$out")
    sleep "$(awk "BEGIN{print ($ms/1000)+1}")" && continue
  fi
  break   # non-rate-limit failure — don't spin
done
```

To pre-empt throttling entirely on high-fanout agent loops, opt into the preemptive throttle: `export APB_THROTTLE=1`.

## 12. Catalog product set CRUD (DPA / Advantage+ Shopping)

```bash
apb catalog list                                   # list catalogs
apb catalog get --id 1234                          # detail
apb catalog products --id 1234 --after <cursor>    # cursor pagination
apb catalog product-set-create --catalog-id 1234 --name "Bestsellers" --filter '{...}' --execute
```

## 13. Custom conversion (URL-rule event)

```bash
apb custom-conversion create \
  --name "Checkout-Complete-2024" \
  --rule '{"and":[{"url":{"i_contains":"thank-you"}}]}' \
  --custom-event-type OTHER \
  --execute
# Note: rule, custom_event_type, event_source_id are frozen at create time.
```

## 14. Split-test setup

```bash
apb split-test create \
  --name "Q3 creative test" \
  --variant-a-adset 23847001 --variant-a-ad 23847011 \
  --variant-b-adset 23847002 --variant-b-ad 23847012 \
  --objective OUTCOME_TRAFFIC \
  --duration-days 7 \
  --execute
apb split-test status --id abc123
apb split-test promote --id abc123 --winner B --scale 1.5 --execute --confirm-destructive
```

## 15. Sync local state with Meta

When your on-disk state has drifted from Meta:

```bash
apb sync diff --account act_1234567890   # show drift between local and remote
apb sync pull --account act_1234567890   # refresh local state from Meta
```

## 16. Dayparting (ad scheduling) — requires a LIFETIME budget

Ad scheduling only works with a **lifetime budget** — Meta rejects daily budgets when day parting is on, and the budget *type* is frozen at create (you cannot convert a running daily-budget campaign to lifetime). So build a **fresh** campaign/ad set with a lifetime budget rather than editing a live daily-budget one:

```bash
# ABO: budget + bid strategy live on the AD SET (not the campaign).
# --budget-sharing false marks this as ABO; omit it and the CLI sends false anyway.
apb campaign create --name "Evening Sales" --objective OUTCOME_SALES \
  --status PAUSED --budget-sharing false --execute

# Lifetime budget + start/end window are mandatory for a schedule.
apb adset create --campaign <campaign_id> --optimization-goal OFFSITE_CONVERSIONS \
  --bid-strategy LOWEST_COST_WITHOUT_CAP \
  --lifetime-budget 200 \
  --start-time 2026-06-01T00:00:00 --end-time 2026-06-30T23:59:00 \
  --daypart-hours "9,12,16,19,21" --daypart-days "1,2,3,4,5" --daypart-timezone USER \
  --promoted-object '{"pixel_id":"<pixel>","custom_event_type":"ADD_TO_CART"}' \
  --status PAUSED --execute
```

The CLI merges consecutive hours into windows, builds `adset_schedule`, and sets `pacing_type: ["day_parting"]` for you. `--daypart-days` is 0–6 (0=Sunday, default all 7); `--daypart-timezone` is `USER` or `ADVERTISER` (default `USER`).

Three pre-flight guards fire on `--dry-run` with exit 2 (see `SKILL.md` → "Meta platform constraints" for the full list):

- `--daily-budget` together with day parting → *"adset_schedule (dayparting) requires a lifetime budget…"* → switch to `--lifetime-budget` + `--end-time`.
- Adding day parting to an existing **daily-budget** ad set (or its CBO parent campaign) on `adset update` → the CLI fetches the parent and rejects with the same message. Budget type is frozen at create — create a new entity instead.
- **Daypart windows past `end_time`** (e.g. windows up to 23:00 but `--end-time …T10:00`) → *"N daypart window(s) fall entirely outside the flight…"*, naming the dead windows. Extend `--end-time` (≥1 week is typical for a dayparted lifetime flight) or trim the schedule. Enforced for ADVERTISER-timezone windows; USER-tz is per-viewer-local and skipped.

The dry-run preview's `would_create` echoes the **full** request body so you can verify budget, targeting, `promoted_object`, `pacing_type`, schedule, and flight before `--execute`. The create/update result also carries a soft `advisories[]` array for short-flight (<24h), pre-learning (<6d), or no-`end_time` lifetime setups Meta accepts but that under-deliver — surface those to the user.

For full manual control, pass Meta's schedule JSON directly with `--adset-schedule '<json|file>'` (it overrides `--daypart-hours`).

---

## 17. Creative format auditor — catch unintended format expansion (v0.2.0)

The Scandalous Coffee incident on 2026-05-23 surfaced a class of creative-spec failure: a single-image-intent creative whose `asset_feed_spec.ad_formats` carried `["CAROUSEL","COLLECTION"]` + `optimization_type: "FORMAT_AUTOMATION"` rendered as a carousel in delivery. The auditor (v0.2.0) catches this BEFORE any write.

```bash
# Inspect a spec without writing anything.
apb creative create-image --name "Review" --spec-file ./ad.json --audit-only --json | jq '.format_audit'

# Trap example: this spec lets Meta render the ad as carousel/collection.
cat >/tmp/trap.json <<'JSON'
{"object_story_spec":{"page_id":"P","link_data":{"image_hash":"H","link":"https://x"}},
 "asset_feed_spec":{"ad_formats":["CAROUSEL","COLLECTION"],"optimization_type":"FORMAT_AUTOMATION"}}
JSON

# Dry-run surfaces 3 findings (exit 0).
apb creative create-image --name "test" --spec-file /tmp/trap.json --json | \
  jq '.format_audit.findings | map(.kind)'
# → ["CarouselFormat", "CollectionFormat", "FormatAutomation"]

# --execute blocks with actionable error (exit 2) naming each flag that would unblock.
apb creative create-image --name "test" --spec-file /tmp/trap.json --execute
# → Creative format audit failed: CAROUSEL, COLLECTION, FORMAT_AUTOMATION detected …
#   Pass --allow-carousel --allow-collection --allow-format-automation to override.

# CI: --strict-format upgrades dry-run findings to errors.
apb creative create-image --name "ci" --spec-file ./ad.json --strict-format
```

## 18. Placement presets — Reels / Stories without hand-crafting JSON (v0.2.0)

`adset create` + `adset update-targeting` accept `--placements <preset>` — expands into v25 `publisher_platforms` / `facebook_positions` / `instagram_positions`. Fail-loud on conflict with operator's `--targeting`.

```bash
# Reels placement, merges with geo + age.
apb adset create --campaign 120... --name "Q2 reels" \
  --optimization-goal LINK_CLICKS --billing-event IMPRESSIONS --lifetime-budget 50 \
  --start-time 2026-06-01T00:00:00 --end-time 2026-06-08T00:00:00 \
  --targeting '{"geo_locations":{"countries":["US"]},"age_min":25,"age_max":54}' \
  --placements reels --advantage-audience 0 --execute

# Stories. Advantage+ Placements. Feed. Combinations.
apb adset create … --placements stories
apb adset create … --placements advantage-plus
apb adset create … --placements feed-stories-reels
```

## 19. Ergonomic creative builders — no JSON authoring (v0.2.0)

```bash
# Single image — image is hash or path (auto-uploaded).
apb creative create-image-simple --name "Promo" --page-id PAGE \
  --image ./hero.jpg --headline "Bold coffee" --body "Try Scandalous" \
  --url https://scandalous.example --cta SHOP_NOW --execute

# Lead-form ad — first lead_gen_form_id injection in the codebase.
apb creative create-lead-form-ad --name "Lead Q2" --page-id PAGE --form-id FORM_999 \
  --image ./hero.jpg --headline "Sign up" --body "Free coffee" --execute

# Catalog creative — --format auto-wires matching auditor --allow-* flag.
apb creative create-catalog-creative --name "DPA" --page-id PAGE \
  --catalog-id 123 --product-set-id 456 --hero-image ./hero.jpg \
  --format collection --execute
```

## 20. End-to-end leadgen ad-create (v0.2.0)

One command validates everything + creates the creative + ad + reverse-pauses on partial failure:

```bash
apb leadgen ad-create --name "Lead Q2" --campaign 120... --adset 120... \
  --form-id FORM_999 --image ./hero.jpg --headline "Sign up" --body "Free" \
  --execute --json
```

Pre-flight order: form-read (Page-token check) → campaign objective is `OUTCOME_LEADS` → image upload → creative create → ad create. On ad-create failure, the orphan creative is paused.

## 21. Built-in compose presets — full stacks from one command (v0.2.0)

```bash
# Lead-form stack (OUTCOME_LEADS + LEAD_GENERATION adset + form-attached creative).
apb campaign compose-from-spec --preset lead-form \
  --campaign-name "Lead Q2" --page-id PAGE --form-id FORM_999 --daily-budget 10

# Catalog-sales — pixel switches optimization goal to OFFSITE_CONVERSIONS.
apb campaign compose-from-spec --preset catalog-sales \
  --campaign-name "DPA" --page-id PAGE --catalog-id CAT --product-set-id PS \
  --pixel-id PX --daily-budget 50

# Other built-ins: sales-video, sales-carousel, reels-video, stories-video.
```

Built-in preset names are reserved — if a user-saved preset shares the name, `compose-from-spec --preset <name>` exits 2 with a shadowing error.

## 22. Naming uploaded assets (v0.2.2)

Uploads default the asset name to the file's basename; override per asset:

```bash
# Standalone uploads — explicit asset name + (video) display title.
apb creative upload-image --path ./hero.jpg --name "Q2 Hero" --execute
apb creative upload-video --path ./promo.mp4 --name "Q2 Promo" --title "Watch now" --execute

# Builders — per-asset name flags (distinct from --name, which is the creative name).
apb creative create-video-simple --name "Promo creative" --page-id PAGE \
  --video ./promo.mp4 --video-name "Q2 Promo" \
  --thumbnail ./thumb.jpg --thumbnail-name "Q2 Promo thumb" \
  --headline "Bold" --url https://x.example --cta LEARN_MORE --execute

# Omit a *-name flag → the asset is named by the filename (e.g. promo.mp4).
```

---

## Cross-references

- Full per-command reference: `commands.md`
- Tier/scope requirements: `reference/scopes.md`
- Exit codes: `reference/exit-codes.md`
- Setup walkthrough: `workflows/setup.md`
- Automation patterns: `workflows/automation.md`
- Diagnostic playbook picker: `workflows/diagnostics.md`
