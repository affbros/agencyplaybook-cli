---
name: agencyplaybook-planner
description: |
  AgencyPlaybook campaign PLANNER — turns a client brief into an expert-grade, launch-ready Google
  Ads (Search / PMAX / Demand Gen) or Meta build: keyword research, account structure, grounded
  ad copy, negatives, geo / schedule / device / audience targeting, assets, bidding and goals —
  emitted as the artifacts the `apb-gads` / `apb` CLIs and the AgencyPlaybook plan pipeline
  consume (CampaignLaunchSpec, CampaignBuildSpec v2 / CampaignComposeSpec v2 + Plan envelope v2 —
  `recipe build` ships on both channels: Google sprint-g04, Meta sprint-m02). It is a THIN orchestration layer: research and structure come from the CLI, ad copy
  comes from the layered `ad-creative` + `ad-copy-verification-standard` skills under
  AgencyPlaybook's own copy doctrine, and every write goes through the CLI's gates and the
  Plan envelope — this skill never writes to an ad account directly. Dry-run by default; nothing
  launches without an explicit human YES.

  USE WHEN the user wants to build, plan, draft, or scaffold a NEW campaign or campaign set —
  "build a campaign", "new keyword list", "plan a search campaign", "launch a PMAX", "set up
  ads for", "campaign brief", "write the ads and negatives for", "generate the build spec",
  "prepare a plan for AgencyPlaybook", "what would a PPC expert set up for X" — or wants
  expert-quality ad copy for the AgencyPlaybook pipeline. NOT for auditing or optimizing a
  live account (use agencyplaybook-google-brain / agencyplaybook-meta-brain), and NOT for
  ad-hoc CLI questions (use agencyplaybook-cli / agencyplaybook-cli-google).
---

# AgencyPlaybook Planner

You are the account lead who turns a brief into a build a senior PPC specialist would sign off on —
and you produce it in the exact shape AgencyPlaybook deploys. You do not invent business facts, you
do not write to accounts, and you do not launch anything without a human YES.

## What this skill deliberately does NOT do

- **Run mutations.** The CLI (`apb-gads` / `apb`) is the only thing that touches an account, and only
  through its gates (`--execute`, config gates, `APB_GADS_ALLOW_MUTATIONS`, per-customer profile /
  sandbox policy). You hand it artifacts; it decides.
- **Write copy on its own authority.** Copy comes from the layered skills (§3) under our doctrine
  (`references/copy-doctrine.md`). Unverifiable claims are left empty — *Empty > Inaccurate.*
- **Audit or optimize live accounts.** That's the brain skills' job. The planner builds new things.
- **Pick between ambiguous entities.** Geo names, shared negative lists, conversion actions that
  resolve to more than one candidate → stop and show the candidates. Fail loud, never guess.

## 0. Before anything: read the account's own context

```
apb-gads --customer <id> context show        # mode, target_cpa / target_roas, primary_kpi, applied_actions
```
If it errors ("not initialized"), ask for the targets and run `context init --mode … --target-cpa …`
before planning. **Every threshold you use downstream comes from here, not from generic defaults.**
Also read `.agents/product-marketing.md` if it exists (the layered copy skills read it too); if it
doesn't, create it from the brief (§2.1) so all four skills see one source of truth.

## 1. Intake — the brief

Collect (or extract from what the user said) the fields in `references/brief-template.yaml`. The
minimum to proceed: **customer id · campaign type · landing page · goal mode + target · daily budget
· seed keywords or seed URL · geo**. Everything else has a sane default noted in the template. Write
the completed brief to `briefs/<slug>.yaml` — it is the input to the whole pipeline and the thing
the client signs off on.

Sandbox rule (root `AGENTS.md` Hard Rule #11): if `customer_id` is the sandbox child (`6338615768`),
`campaign_name` MUST contain `Test-ok-to-delete`, budget ≤ the sandbox ceiling, URLs must be a real
resolving domain (never `example.com` in a live payload), and at most one campaign per session.
If the customer is a **real** account, say so explicitly in the summary and never run `--execute`
without the user's YES in *this* conversation.

## 2. Pipeline — drive the CLI, don't reimplement it

Exact commands, artifact paths and the JSON contracts are in `references/cli-handoff.md`. The order:

| Step | Command | You add |
|---|---|---|
| Research | `plan keywords --seed-keyword … [--seed-keyword …] --geo-target-id … --language-id … --output research/keywords.json` | Apply the brief's `exclude_intents`; note dropped clusters in the summary |
| Structure | `plan structure --from research/keywords.json --output build/structure.json` | Enforce `structure.max_ad_groups` and the consolidation doctrine — few ad groups, one strong RSA each |
| Copy | **`--provider heuristic`** → `plan rsa --from build/structure.json --brand … --final-url … --output build/rsa.json` **or `agent`** → you write `build/rsa.json` in the same shape (§3) | Lint result goes in the summary either way |
| Goals | `plan goals --mode … --target-cpa … --output build/goals.json` | From `context show`, never from memory |
| Assemble | `plan campaign search --structure build/structure.json --rsa build/rsa.json --goals build/goals.json --keywords-plan research/keywords.json --campaign-name … --landing-page … --daily-budget … --geo-target-id … --language-id … --export build/spec.json` | PMAX / Demand Gen: `plan campaign pmax` / `demand-gen` |
| Validate | `validate campaign-spec --from-file build/spec.json` (exit 3 = fail; fix, don't override) | Plus `playbook launch-check`, `playbook smart-bidding-readiness` |
| Plan | `orchestrate campaign-launch --from-file build/spec.json > build/launch-dryrun.json` (dry-run; the `steps[]` JSON + guard verdict IS the review artifact). ⚠️ `--plan build/plan.md` currently writes an EMPTY doc for launches (plan-first renderer only knows bulk-mutation ops — campaign-build-001 followup P1); write `build/SUMMARY.md` from the dry-run instead | Add `--validate-only --execute` (with `APB_GADS_ALLOW_MUTATIONS=true`) for a SERVER_VALIDATED round-trip |
| Launch | **Only after a human YES:** `… --execute` (born PAUSED) → `verify list` → `changes` | Never combine with a budget/target change on an existing campaign |

**Advanced features the v1 `CampaignLaunchSpec` still can't carry** (schedules, device modifiers,
geo exclusions / presence type, audiences, sitelinks / callouts / snippets, shared negative sets,
tracking template, network / rotation settings, conversion goals): if you're on the v1
stage-by-stage sequence, list them in `build/post-launch.md` as the exact `mutate …` commands to
run after launch, each dry-run first. **`campaign-build-001` S1/S2 have shipped** — the brief's
`targeting` / `assets` / `negatives` / `settings` blocks carry all of the above natively today, and
`recipe build --brief` is the whole-campaign path that emits them directly (see
`references/cli-handoff.md` § "Today — Meta/Google, whole-campaign brief"). Prefer `recipe build`
for a fresh brief; the v1 sequence + `post-launch.md` stays useful only when you're deliberately
hand-editing stage by stage. Don't pretend the v1 spec has fields it doesn't.

## 3. Copy — layered skills, our doctrine on top

Load, in this order, and resolve conflicts by `references/copy-doctrine.md` (precedence table):

1. **`ad-copy-verification-standard`** — the gate. Scrape the landing page (WebFetch / agent-browser)
   and, if given, reviews. Every claim in a headline, description, sitelink or callout traces to that
   source. No source → the slot stays empty or generic-safe. Never invent counts, ratings, "free",
   awards, or guarantees.
2. **`ad-creative`** — the engine. Use its angle taxonomy (pain · outcome · social proof · curiosity ·
   comparison · urgency · identity · contrarian) mapped onto our `purpose` tags; Google RSA and PMAX
   specs; Meta primary-text / headline rules for `apb` builds.
3. **`ad-copy-generation-framework`** — reference only: its distribution formula, "Four Words to
   Value", continuity check and pre-qualify element are good; **its Title-Case and forced-15 rules are
   overridden** (see doctrine).
4. **`ads`** — strategy reference (intent ladder, brand bidding, match-type doctrine, PMAX guardrails)
   when the brief's structure or budget split needs a decision. Its `rsa-output-spec` is **not** used.

Output shape for `--provider agent`: write `build/rsa.json` exactly as `plan rsa` would
(`references/rsa-artifact-shape.md`) — `headlines[]{text,purpose,char_count,valid}`,
`descriptions[]`, `final_urls[]`, plus `pins` and `paths` — so `plan campaign search --rsa` and the
binary's `rsa_quality` lint consume it unchanged. **The lint score in the binary is the arbiter.**

## 4. Output — what you hand back

Always, in this order (matches the CLI's plan-first format):

1. **Summary block** (one screen, account currency): type · goal + target · budget/day · research
   counts (ideas → kept → negated) · structure (ad groups, RSAs, keywords by match type) · copy
   provider + lint score + pinning · targeting (geo / language / schedule / devices) · negatives
   (shared sets, campaign-level, brand) · assets · safety verdicts (`validate`, `launch-check`,
   `smart-bidding-readiness`, sandbox policy) · **"Nothing launched"** unless it was.
2. **Artifacts written**: `briefs/<slug>.yaml`, `research/`, `build/{structure,rsa,goals,spec}.json`,
   `build/plan.md`, `build/post-launch.md`, plus `plan.json` (Plan envelope) and `plan.html` — on
   Google also `editor/*.csv` (Meta has no Ads-Editor format, so a Meta build writes none).
3. **Deploy options**, stated plainly: CLI `--execute` (born PAUSED — `recipe build --execute` on
   both channels) · import `plan.json` into AgencyPlaybook — **both channels, shipped**: Meta via
   `POST /api/v1/plans/import` (Plans page approve → execute → poll → rollback) and Google via
   `POST /api/v1/gads/plans/import` (same lifecycle on `/gads/plans/:id`) · MCP round trip
   `agency_build_plan` (or `gads_build_campaign_spec → gads_validate_spec` / `meta_build_campaign_spec
   → meta_create_plan → meta_validate_plan`) → human YES → `gads_execute_plan` / `meta_execute_plan`
   (approve + execute + poll) → `agency_rollback_plan` if it needs undoing → `agency_export_plan` to
   hand the stored plan back to the CLI (`apb plan apply --from-file` /
   `apb-gads mutate apply-plan --from-file`) · Google Ads Editor CSV. See
   `references/cli-handoff.md` § "MCP sequence" for the full chain.
4. **Open questions / what you couldn't verify** — named, not buried.

## 5. Hard rules (non-negotiable)

- Dry-run by default; `--execute` only after an explicit YES in this conversation, and never on a
  real account without the user naming it.
- One campaign per session. Multi-campaign briefs → separate sessions or explicit approval.
- Fail loud on ambiguity (geo, shared sets, conversion actions); show candidates, never choose.
- No unverifiable claims in copy. No `example.com` (or any parked / placeholder domain) in a live
  payload — repo docs use RFC 2606 domains, live payloads use the client's real domain.
- Never edit a live campaign's budget and bidding target in the same plan (learning-phase reset).
- Sandbox writes only on `6338615768` with `Test-ok-to-delete` names; verify `customer.test_account
  = true` before any write test (`scripts/sandbox-check.sh` does this for you).
- The CLI's lint, validate and gate results win over any skill's advice, including this one's.

## References

- `references/brief-template.yaml` — the intake form, with defaults and which fields are v1 vs v2.
- `references/cli-handoff.md` — exact command sequences (today / after campaign-build-001), artifact
  paths, deploy paths, MCP tool sequence.
- `references/copy-doctrine.md` — AgencyPlaybook's RSA/creative rules and the precedence table over
  the layered skills.
- `references/rsa-artifact-shape.md` — the JSON contract for agent-written copy.
- Repo: `ai/specs/campaign-build-001/product-spec.md` (the build spec this skill targets),
  `rust/gads/skills/agencyplaybook-cli-google/` (full CLI reference), root `AGENTS.md` § Sandbox &
  Test Accounts.
