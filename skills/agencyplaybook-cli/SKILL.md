---
name: agencyplaybook-cli
description: |
  AgencyPlaybook CLI (`apb`) — command-line automation for Meta (Facebook/Instagram) ad campaigns: list, create, update, duplicate, and delete campaigns/adsets/ads/creatives; run diagnostic playbooks (health-score, waste-audit, fatigue-index, weekly-digest, learning-accelerator and 20+ more); build and execute multi-entity plans with dry-run-first safety; manage audiences (custom + lookalike + PII upload); explore targeting interests/behaviors; configure pixels and CAPI; manage rules, split-tests, catalogs, custom conversions, and leadgen forms. Covers all 246 commands across 35 domains.

  USE WHEN user says "apb", "agencyplaybook cli", "agencyplaybook", "meta campaign automation", "meta ads via cli", "campaign create", "campaign update", "campaign delete", "duplicate campaign", "scale campaign", "pause campaign", "budget update", "ad set targeting", "creative upload", "audience upload", "lookalike audience", "custom audience", "fatigue check", "waste audit", "health score", "weekly digest", "learning accelerator", "playbook diagnostic", "plan execute", "plan validate", "report insights", "compare periods", "split test", "rules engine", "automation rule", "catalog product set", "custom conversion", "leadgen forms", "pixel health", "CAPI dual signal", "growth score", "retargeting compression", "saturation audit", "broad targeting audit", "no-touch compliance", "consolidation advisor", "ROAS recovery", "anomaly detect", "reset rebuild", "scale roadmap", "rebalance", "daypart audit", "placement audit", "creative mix", "event hierarchy", "duplicate detect", "event downgrade ladder", "andromeda", "dataset clone-plan", "sync diff", "alias create", or otherwise needs to programmatically manage Meta ad accounts via the `apb` CLI.
---

# AgencyPlaybook CLI Skill

This skill packages working knowledge of every `apb` command. Generated on 2026-05-30 from the live binary — 246 commands across 35 domains.

## Routing

- **User asks for a specific command** ("what flags does `apb campaign create` accept?") → open `commands.md` (the domain index), then read `reference/commands/<domain>.md` and quote the relevant section.
- **User asks "how do I X" workflow** ("how do I dry-run-then-execute a campaign?") → read `examples.md` and adapt the matching canonical example.
- **User wants step-by-step onboarding** ("set me up with apb") → read `workflows/setup.md`.
- **User wants automation pattern** ("safe rollout with rollback") → read `workflows/automation.md`.
- **User wants diagnostic playbook** ("which playbook for low ROAS?") → read `workflows/diagnostics.md`.
- **User asks to set up day parting / ad scheduling** ("daypart this campaign", "only run ads 9am–9pm", "schedule ads by hour", "run evenings only") → **the campaign type to create is a NEW campaign/ad set on a LIFETIME budget** (ABO: lifetime on the ad set; CBO: lifetime on the campaign). Day parting is impossible on a **daily** budget and budget *type* can't be converted, so **never try to add it to an existing daily-budget campaign** — build a new one. Read "Meta platform constraints" below + `examples.md` §16 before writing any command.
- **User hits a 403** ("insufficient_scope on X") → read `reference/scopes.md` and explain tier gap.
- **User script needs exit-code branching** → read `reference/exit-codes.md` (the canonical table + decision tree).
- **User wants the full CI/CD + AI-agent automation guide** (debugging, log sanitization, plain output) → read `reference/automation-guide.md`.

## Quick start (always check this first)

The downloaded `apb` binary already targets `https://api.agencyplaybook.io` — you only supply an API key:

```bash
mkdir -p ~/.apb
echo 'APB_API_KEY=apb_live_<tier>_<32hex>' > ~/.apb/.env   # key from the /api-keys page
apb auth test                                              # smoke test
apb campaign list                                          # first real call
```

`apb` resolves credentials in order: shell environment → project-local `.env` (cwd) → `~/.apb/.env` (global) → compile-time default. Earlier sources win, so a `export APB_API_KEY=...` always overrides the file. Setting `~/.apb/.env` once makes the CLI work from any directory. You only need `APB_API_URL` if you're pointing at a non-default endpoint (self-hosting, staging, or local dev — see below).

## Safety doctrine (apply to every mutation)

1. **Dry-run first.** Every write command requires `--execute`. Without it, the CLI prints what it would do and exits 0 without mutating.
2. **Destructive ops also require `--confirm-destructive`.** This covers `delete`, status changes to DELETED/ARCHIVED, budget reductions to $0, budget increases >200%.
3. **Branch on exit code, not on stdout text.** Exit codes are stable; messages are not. See `reference/exit-codes.md`.
4. **Use `--no-input` for CI/CD and AI-agent execution.** Combine with `--json` for machine-parseable output.
5. **Never `--no-input --execute` a destructive op without `--confirm-destructive` already in the command line.** The CLI will refuse to proceed.
6. **Plans over ad-hoc writes.** For anything spanning 2+ entities, use `apb plan create … validate … execute` so the rollback blueprint exists on disk.

## Meta platform constraints (what the CLI catches before Meta does)

The CLI pre-flights a growing set of Meta-side rejections at dry-run. Each guard below runs **before any network call** and exits 2 with an actionable message — so a bad command fails on `--dry-run` rather than after `--execute`:

1. **Objective must be ODAX** (v0.1.19, in `campaign create` and `campaign compose-from-spec`). Legacy values are rejected with the OUTCOME_* mapping (e.g. `CONVERSIONS → OUTCOME_SALES`, `LINK_CLICKS → OUTCOME_TRAFFIC`). The CLI's `--objective` is also a clap enum, so the spec-file / HTTP API paths are the ones this guard defends.
2. **Conversion goal needs `--promoted-object`** (v0.1.19). `adset create` (and compose) with `--optimization-goal OFFSITE_CONVERSIONS` or `VALUE` and no `--promoted-object` errors with a `{"pixel_id":"…","custom_event_type":"PURCHASE"}` hint. Scoped to website-conversion goals — no false positives on LINK_CLICKS / leads / app-promo.
3. **Dayparting requires a lifetime budget** (v0.1.15 create, v0.1.17 update). `--daypart-hours` / `--adset-schedule` + `--daily-budget` is rejected on create; on update, the CLI fetches the existing ad set (and its CBO parent campaign) and errors if either is on a daily budget. **Budget type is frozen at create — you cannot convert daily ⇄ lifetime — so the fix is always "create a new entity."**
4. **Dayparting windows must fit the flight** (v0.1.20). `adset create`/`update` rejects daypart windows (ADVERTISER timezone) whose recurring slot never intersects `start_time`→`end_time`, naming the dead windows. Catches the "lifetime budget over a too-short flight" class (e.g. $350 over 10 hours leaves 3 windows that can't deliver). USER-tz windows and ≥7-day flights pass through (no false positives).

The create/update result also carries a soft **`advisories[]`** array (v0.1.20, non-blocking) for Meta-accepted setups that usually under-deliver: flight < 24h, flight < 6 days (Meta needs ~6 days to exit the learning phase), or a lifetime / dayparted ad set with no `--end-time`. Surface these to the user; don't block on them. The dry-run preview's `would_create` (v0.1.20) shows the **full** request body — budget, targeting, `promoted_object`, `pacing_type`, schedule, flight — so the wiring can be verified before `--execute`.

5. **Creative format auditor** (v0.2.0). Every `creative create-*` and `creative update` runs a pure-function auditor on the spec. Detects 11 v25 format-expansion risks (CAROUSEL / COLLECTION / FORMAT_AUTOMATION / product_set_id / template_url / {{product.*}} syntax). When `--execute` is set with unwhitelisted findings, exits 2 with an actionable error naming each detected risk and the `--allow-*` flag that whitelists it — fires BEFORE the env-var write gate so the spec-fix message surfaces first. CI use: `--strict-format` upgrades dry-run findings to errors. Spec-review: `--audit-only` runs the auditor and exits 0 without writing. See `reference/auditor.md` for the full risk taxonomy.

6. **Placement presets** (v0.2.0). `adset create` and `adset update-targeting` accept `--placements <feed|stories|reels|stories-reels|feed-stories-reels|advantage-plus>` — expands into v25 `publisher_platforms` / `facebook_positions` / `instagram_positions`. Merges with operator `--targeting` JSON; **fails loud on conflict** (exit 2, names both sides). IG's feed equivalent is called `stream` in v25 — the preset handles that for you.

7. **Ergonomic creative builders** (v0.2.0). `creative create-image-simple` / `create-video-simple` / `create-lead-form-ad` / `create-catalog-creative` / `create-story-template` / `create-reels-video-template` take operator-friendly flags and build the v25 spec internally — no JSON authoring. `--image` / `--video` / `--thumbnail` accept hashes/IDs OR local file paths (auto-uploaded under `--execute`). `create-catalog-creative --format <single|carousel|collection|automatic>` auto-wires the matching `--allow-*` flag so an intentional `--format collection` doesn't trip the auditor. `creative create-lead-form-ad` injects `lead_gen_form_id` into `link_data.call_to_action.value` — the FIRST occurrence of this field in the codebase.

8. **End-to-end leadgen ad-create** (v0.2.0). `apb leadgen ad-create --campaign --adset --form-id --page-id --image --headline --body --cta` validates the campaign objective is `OUTCOME_LEADS`, verifies the form belongs to the page, creates the lead-form creative + ad in sequence, and reverse-pauses on partial failure. The Page-token check fires FIRST so token failures surface before any creative-write attempt.

9. **Built-in compose presets** (v0.2.0). `apb campaign compose-from-spec --preset <sales-video|sales-carousel|lead-form|catalog-sales|reels-video|stories-video>` produces full campaign + adset + creative + ad stacks from operator-friendly args (`--campaign-name`, `--page-id`, `--daily-budget`, plus per-preset extras). Built-in presets take precedence over user-saved presets; **collision = fail-loud** with a shadowing error (exit 2).

10. **Name uploaded assets** (v0.2.2). Whenever the CLI uploads an image/video from a local file, the asset is named by the file's basename (filename + extension) by default. Override it: `creative upload-image --name`, `creative upload-video --name` (+ `--title` for the display title, which defaults to the name), and per-asset `--image-name` / `--video-name` / `--thumbnail-name` / `--hero-image-name` on the `create-*` builders — distinct from each builder's `--name`, which is the *creative* name. A hash or pre-uploaded ID passed instead of a file path is used as-is.

The remaining Meta rejections are account-state rules the CLI can't pre-check (business verification, page permissions, pixel custom-event validity, etc.) — those still bounce on `--execute`.

### Dayparting / ad scheduling → create a LIFETIME-budget campaign

**When day parting is requested, the campaign type to create is a NEW campaign/ad set on a LIFETIME budget.** Choose the structure, then build it fresh:

- **ABO** (budget on the **ad set**) — the usual choice for per-ad-set dayparting: `apb adset create … --lifetime-budget <X> --end-time <T> --daypart-hours "9,12,16,19,21"` (bid strategy also lives on the ad set for ABO). The CLI builds the Meta `adset_schedule` and auto-sets `pacing_type: ["day_parting"]`.
- **CBO / Advantage Campaign Budget** (budget on the **campaign**) — the campaign carries a lifetime budget; the scheduled ad set carries no own budget.

**Do NOT add day parting to an existing campaign unless it is already on a lifetime budget.** Two reasons it can't be retrofitted:

1. A daily budget is rejected outright: **`Campaigns with day parting enabled do not support daily budgets.`**
2. Budget *type* is **frozen at create** — you cannot convert daily ⇄ lifetime: **`Invalid parameter: Changing from lifetime to daily budget or vice versa is not allowed for a campaign.`**

So the only correct move is to **create a new lifetime-budget campaign/ad set from the start** (and pause/retire the old daily-budget one if it's being replaced).

Guards #3 and #4 above (budget-type-vs-schedule + windows-fit-flight) catch both halves at dry-run. The fix is always to **build a new lifetime-budget campaign/ad set with an `--end-time` that covers the schedule** (≥1 week is typical for a dayparted lifetime flight). See `examples.md` §16.

## When to use this skill vs `metaads`

- **`agencyplaybook-cli`** → user wants CLI/script automation, multi-account fan-out, plan/validate/execute safety patterns, exit-code branching, reproducible workflows. Programmatic mindset.
- **`metaads`** → user wants UI-style "publish this campaign" / "what's my ROAS this week" conversational workflows. Doesn't need CLI invocation.

If the user mentions `apb`, scripting, automation, CI/CD, cron, or "rerunning this nightly", route here. If they mention "the dashboard" or just describe a one-off Q&A, route to `metaads`.

## Domain index

See `commands.md` for the domain index; per-command detail lives in `reference/commands/<domain>.md`. Domains:

- **auth, doctor, account, meta** — connection & identity
- **campaign, adset, ad, creative** — entity CRUD
- **audience, targeting, catalog, custom-conversion, leadgen** — supporting primitives
- **report, coverage, metrics, learning** — reporting
- **playbook, growth, action, budget, ask** — diagnostics & recommendations
- **plan** — multi-step mutation orchestration with on-disk rollback blueprints
- **rules, split-test, sync, duplicate, andromeda, alias** — automation & workflow
- **pixel, dataset, library, search, policy** — utility

## Tier-aware planning

Before writing a workflow, check the user's tier. Scopes:

- **Starter** (4 scopes): read-only campaigns/reports/coverage/search
- **Professional** (11): + advanced reports, audiences, pixels, core playbooks, catalogs, custom-conversions, leadgen reads
- **Agency** (23): + writes (campaigns/budgets/rules/catalogs/custom-conversions/leadgen/audience-data), full playbooks, datasets, lead PII export
- **Enterprise** (27): + automation, admin sync, split-test, duplicate

If a workflow needs a scope above the user's tier, surface that clearly before writing the command. See `reference/scopes.md` for the full mapping.

## Self-hosting / local development

The default endpoint is `https://api.agencyplaybook.io` — no override needed for the hosted service. Only set `APB_API_URL` when you run the stack yourself:

```bash
# Local dev — Express middleware on :3750. This is the SaaS entry point: it
# resolves your tenant's encrypted Meta token and forwards to the Rust API on
# :3010. Pointing directly at :3010 bypasses Express and silently fails on any
# call that hits Meta's Graph API — always use :3750 for local dev.
export APB_API_URL=http://localhost:3750
```

## Operator token mode (BYO Meta token)

Set `META_OAUTH=DISABLED` **with** a local `META_ACCESS_TOKEN` to bypass the platform's per-tenant Meta OAuth and use your **own** Meta token for every Graph call. Your `APB_API_KEY` is still validated against AgencyPlaybook on every invocation (login + tier/scope + active-user/key enforcement) — only the Meta token is swapped, never the platform gate.

```bash
# ~/.apb/.env  (or a project-local .env)
APB_API_KEY=apb_live_<tier>_<32hex>   # still REQUIRED — access control stays on
META_ACCESS_TOKEN=EAAB...             # your own (System User) Meta token
META_OAUTH=DISABLED
```

When to use it:
- **Self-hosted / single-operator** setups driving one Meta account.
- **Ad creation while the platform's Meta app is in Development Mode** — the platform OAuth token can't create new page-post creatives (`error_subcode 1885183`), but a System User token from your own (non-dev-mode) app can. Existing/deduped creatives may still go through on the platform token; force a unique creative to surface the block.

Rules:
- `META_OAUTH=DISABLED` **without** `APB_API_KEY` is refused — the CLI won't run ungated off a bare local token. Set the key, or unset `META_OAUTH` to use `apb` as a standalone Meta tool.
- The account you target must be reachable by your local token — check with `apb account current` (shows reachability), then switch with `apb account use <profile|act_...>`. For multiple accounts, save profiles that also carry each account's token: `apb account profile add <name> --account act_... --token-env <ENV_VAR>`, then `apb account use <name>` flips account + token together.
- If an admin disables your user/key, the next call is rejected (a ~30s resolve cache applies; `rm ~/.apb/tenant_context.json` to force an immediate re-check).

## Updating this skill

This skill tracks the CLI surface. When a new `apb` version ships, grab the latest bundle and re-extract it into `~/.claude/skills/`:

- **From the dashboard** — the **CLI Reference** page has a "Download Skill" button.
- **From GitHub** — <https://github.com/affbros/agencyplaybook-cli/tree/main/skills/agencyplaybook-cli>

Then restart Claude Code.
