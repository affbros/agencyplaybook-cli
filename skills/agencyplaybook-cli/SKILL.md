---
name: agencyplaybook-cli
description: |
  AgencyPlaybook CLI (`apb`) — command-line automation for Meta (Facebook/Instagram) ad campaigns: list, create, update, duplicate, and delete campaigns/adsets/ads/creatives; run diagnostic playbooks (health-score, waste-audit, fatigue-index, weekly-digest, learning-accelerator and 20+ more); build and execute multi-entity plans with dry-run-first safety; manage audiences (custom + lookalike + PII upload); explore targeting interests/behaviors; configure pixels and CAPI; manage rules, split-tests, catalogs, custom conversions, and leadgen forms. Covers all 229 commands across 34 domains.

  USE WHEN user says "apb", "agencyplaybook cli", "agencyplaybook", "meta campaign automation", "meta ads via cli", "campaign create", "campaign update", "campaign delete", "duplicate campaign", "scale campaign", "pause campaign", "budget update", "ad set targeting", "creative upload", "audience upload", "lookalike audience", "custom audience", "fatigue check", "waste audit", "health score", "weekly digest", "learning accelerator", "playbook diagnostic", "plan execute", "plan validate", "report insights", "compare periods", "split test", "rules engine", "automation rule", "catalog product set", "custom conversion", "leadgen forms", "pixel health", "CAPI dual signal", "growth score", "retargeting compression", "saturation audit", "broad targeting audit", "no-touch compliance", "consolidation advisor", "ROAS recovery", "anomaly detect", "reset rebuild", "scale roadmap", "rebalance", "daypart audit", "placement audit", "creative mix", "event hierarchy", "duplicate detect", "event downgrade ladder", "andromeda", "dataset clone-plan", "sync diff", "alias create", or otherwise needs to programmatically manage Meta ad accounts via the `apb` CLI.
---

# AgencyPlaybook CLI Skill

This skill packages working knowledge of every `apb` command. Generated on 2026-05-25 from the live binary — 229 commands across 34 domains.

## Routing

- **User asks for a specific command** ("what flags does `apb campaign create` accept?") → open `commands.md` (the domain index), then read `reference/commands/<domain>.md` and quote the relevant section.
- **User asks "how do I X" workflow** ("how do I dry-run-then-execute a campaign?") → read `examples.md` and adapt the matching canonical example.
- **User wants step-by-step onboarding** ("set me up with apb") → read `workflows/setup.md`.
- **User wants automation pattern** ("safe rollout with rollback") → read `workflows/automation.md`.
- **User wants diagnostic playbook** ("which playbook for low ROAS?") → read `workflows/diagnostics.md`.
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

## Meta platform constraints (a passing dry-run can still be rejected)

The CLI dry-run validates **your command**, not Meta's account-state rules. Some writes render a clean dry-run and still get rejected by Meta on `--execute`. Known cases the CLI can't fully pre-check:

### Dayparting / ad scheduling requires a LIFETIME budget

`apb adset create … --daypart-hours "9,12,16,19,21"` builds the Meta `adset_schedule` and auto-sets `pacing_type: ["day_parting"]` — but Meta only permits ad scheduling when the **budget is a lifetime budget**, on whichever entity owns the budget:

- **ABO** (budget on the ad set) → use `--lifetime-budget`, **never** `--daily-budget`, on the scheduled ad set.
- **CBO / Advantage Campaign Budget** (budget on the campaign) → the campaign must use a lifetime budget.

A daily budget triggers: **`Campaigns with day parting enabled do not support daily budgets.`**

**The budget *type* is frozen at create — you cannot convert daily ⇄ lifetime on an existing campaign or ad set.** Attempting it returns: **`Invalid parameter: Changing from lifetime to daily budget or vice versa is not allowed for a campaign.`** So you **cannot retrofit** dayparting onto something already running on a daily budget — **create a new campaign/ad set with a lifetime budget from the start**.

The CLI's create-time guard catches `--daypart-hours` passed *together with* `--daily-budget`. It can **not** see the existing budget type when you only add `--daypart-hours` to a **live** ad set/campaign (an `adset update` / `campaign update`), nor a campaign-level CBO daily budget — those pass dry-run and bounce at Meta. See `examples.md` §16.

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
- The account you target must be reachable by your local token — check with `apb account list`, then `apb account set-default --account act_...`.
- If an admin disables your user/key, the next call is rejected (a ~30s resolve cache applies; `rm ~/.apb/tenant_context.json` to force an immediate re-check).

## Updating this skill

This skill tracks the CLI surface. When a new `apb` version ships, grab the latest bundle and re-extract it into `~/.claude/skills/`:

- **From the dashboard** — the **CLI Reference** page has a "Download Skill" button.
- **From GitHub** — <https://github.com/affbros/agencyplaybook-cli/tree/main/skills/agencyplaybook-cli>

Then restart Claude Code.
