---
name: agencyplaybook-google-researcher
description: |
  Historical-alpha research workbench for Google Ads, driven through the READ-ONLY
  `apb-gads-researcher` CLI and, when the AgencyPlaybook MCP is available, the matching
  `gads_research_*` MCP tools. Investigates why a Google Ads account's economics broke, mines
  historical search-term/audience/geo/negative/creative/quality-score data for what used to work,
  refreshes current market context through a budgeted DataForSEO cache, ranks alpha opportunities
  with statistical rigor (shrinkage, holdout, FDR), and hands off a dry-run CampaignBuildSpec v2 +
  brief + experiment sheet for a *separate*, write-capable pipeline to launch (`apb-gads recipe
  build --spec` / `agencyplaybook-planner`). This binary NEVER mutates a Google Ads account — no
  write flags exist in its CLI surface at all, and the read-only guarantee is enforced by an
  automated invariant check in CI.

  USE WHEN the user asks "why did this Google campaign stop being profitable", "should we restart
  campaign X", "what changed around <date>", "find alpha / hidden pockets / what used to work",
  "profile this Google account's history", "mine negative keywords from history", "which
  audiences/geos over-index historically", "quality-score forensics", "which RSA angles won
  historically", "hunt for relaunch opportunities", "what would a profitable Google segment look
  like today", or wants a **historical, evidence-grounded** Google Ads investigation or
  opportunity search — as opposed to a live-account audit/verdict (use
  `agencyplaybook-google-brain`), direct CLI flag lookup for the write-capable `apb-gads` binary
  (use `agencyplaybook-cli-google`), or drafting a brand-new campaign from a brief with no
  historical account to mine (use `agencyplaybook-planner`). NOT for Meta/Facebook/Instagram.
---

# AgencyPlaybook Google Researcher

You drive the **`apb-gads-researcher` CLI** — a read-only, evidence-first workbench over a Google
Ads account's history, current market conditions, and ranked relaunch opportunities. It is a
**separate binary** from `apb-gads` (which writes) and from the AgencyPlaybook MCP's `gads_*`
brain tools (which operate live). Everything here is either a local workspace read/derive step or
a budgeted DataForSEO cache refresh — **nothing here ever calls a live Google Ads write API.**

> Surface (verify with `<binary> --help` / `<subcommand> --help` — the binary is the source of
> truth, never memory): **18 top-level commands, 28 leaf commands total** —
> `inspect · extract · analyze {regimes,decline,compare,readiness} · intents · audiences · geo ·
> waste · creative · qs · competitors {add,remove,list,discover,analyze} · market {refresh,status} ·
> economics · opportunities · opportunity · explain · plan · workspace {status,clear-cache,import} ·
> auth {test}`. Full parameter tables: the CLI's own generated per-command docs (auto-generated
> from `--help`, do not hand-edit) and `reference/tool-catalog.md` below.

**Output contract (every command, frozen):** one JSON document on stdout —
`{data, evidence, run_id, provenance}` on success, `{data:{status,error:{code,message,details}},
evidence:[], run_id, provenance}` on a non-zero exit — with progress on stderr. Money is in
**micros**. Exit codes: `0` ok, `1` runtime error, `2` usage error, `3` = `insufficient_data` |
`policy_blocked` | `not_entitled` (structured-refusal class — read `data.error.code`, don't retry
blindly). **Every number that reaches an answer must carry an evidence id** that would pass
`evidence::validate()` — that is the single rule underneath every SOP and anti-pattern below.

## Division of labor — which Google skill for which job

| Job | Skill |
|---|---|
| **Historical investigation / alpha-hunting** (this) — why did it break, what used to work, rank relaunch opportunities, hand off a dry-run spec | `agencyplaybook-google-researcher` (you are here) |
| Live-account audit/diagnose/verdict/execute via the MCP `gads_*` brain tools | `agencyplaybook-google-brain` |
| Direct `apb-gads` CLI flags/playbooks/mutations for an operator who already knows what to run | `agencyplaybook-cli-google` |
| Draft a **greenfield** campaign from a brief with no historical account to mine | `agencyplaybook-planner` |

This skill's own hand-off (`plan <opportunity-id>`) feeds `agencyplaybook-planner` /
`apb-gads recipe build --spec` for launch — it never launches anything itself.

## SOPs — load the one that matches the request

| Situation | SOP |
|---|---|
| "Profile this account", first time touching a customer, "is there enough history here" | `sops/account-intake.md` — `inspect → extract → analyze readiness` |
| "Why did CPA/ROAS break", "should we restart X", "what changed around \<date\>" | `sops/decline-investigation.md` |
| "Find alpha", "what used to work", "hunt for relaunch opportunities", "hand me a spec to test" | `sops/opportunity-hunt.md` — `intents → market refresh → competitors → opportunities → explain → economics scenarios → plan` |
| "Mine negative keywords from history", "what's wasting historical spend" | `sops/negative-mining.md` — `waste` |
| "Which RSA/asset angles won historically", "creative economics forensics" | `sops/creative-forensics.md` — `creative` (paired with `qs` when quality score is implicated) |

Every SOP assumes `inspect` has already run once for the customer (account intake) so the
workspace has a data-availability read — if it hasn't, start there regardless of the ask.

## Global flags (every command; full table in `reference/tool-catalog.md`)

`--customer <ID>` · `--config <PATH>` (BYO google-ads yaml — supplies Google Ads credentials
directly instead of resolving them through the SaaS tenant) · `--workspace <DIR>`
(default `~/.apb-gads-researcher/<customer_id>/`) · `--pretty` · `--no-color` ·
`--format {json,text,md}` (json is the contract; text/md are renderings of the same document) ·
`--output <PATH>` · `--redact` (replace client text with stable placeholders) ·
`--no-input` (fail instead of prompting) · `-h/--help` · `-V/--version`.

**`--config` does not make `APB_API_KEY` optional.** `APB_API_KEY` is the entitlement/auth
credential (it identifies the tenant and its scopes); `--config` only supplies the Google Ads
side of the credentials in place of the SaaS-resolved token. Both are required together — a BYO
yaml with no `APB_API_KEY` set still fails.

**Resolve and confirm the customer before the first costed extract**, exactly like the brain
skill's account-context rule — a name/id must become a numeric `customer_id` you state back to
the user. `--customer` is optional per-invocation once a customer's workspace exists (the
workspace directory is keyed by customer id), but never guess it on the first call.

## Progressive disclosure — load on demand

| Need | Read |
|---|---|
| Exact flags/params for a command, or which MCP tool wraps it | `reference/tool-catalog.md` |
| The failure modes to avoid | `reference/anti-patterns.md` |
| Account intake SOP | `sops/account-intake.md` |
| Decline investigation SOP | `sops/decline-investigation.md` |
| Opportunity hunt SOP | `sops/opportunity-hunt.md` |
| Negative mining SOP | `sops/negative-mining.md` |
| Creative forensics SOP | `sops/creative-forensics.md` |
| Full generated CLI reference (one page per command, always current) | the CLI's own generated per-command docs |

## Reporting shape

Lead with the answer, then the evidence: **finding → the evidence id(s) behind it → recommended
next step**. Never paste a full JSON document — summarize `data`, cite `evidence[]` ids, and note
`confidence` / `viability` / `readiness` where the command returns them. State money in currency
units (divide micros by 1,000,000) even though the wire format is micros. Always name the
`customer_id` you read and the workspace/window the numbers came from.

## Anti-patterns

Full list, item by item, in `reference/anti-patterns.md` — the general evidence-discipline failure
modes that apply to any historical investigation, plus three added specifically for the
market/audience surfaces this binary adds: never propose a prohibited signal as targeting, never
quote a DataForSEO number without its `retrieved_at`, and never treat `UNDETERMINED` demographics
as absence.

## Related skills (references)

- **`agencyplaybook-google-brain`** — the live-account sibling: MCP `gads_*` tools, the
  preview → approval → execute → verify write handshake, and the decline-investigation SOP this
  skill's historical version is modelled on. Read its `reference/anti-patterns.md` for
  the live-write failure modes (out of scope here, since this binary never writes).
- **`agencyplaybook-cli-google`** — the write-capable `apb-gads` CLI (307 commands, 30 groups) that
  a hand-off spec from `plan`/`explain` ultimately launches through (`recipe build --spec`).
- **`agencyplaybook-planner`** — the campaign-planning orchestrator; feed it this skill's `plan`
  output (`spec.v2.json` / `brief.yaml`) instead of starting a build from a blank brief when a
  historical opportunity already exists.
