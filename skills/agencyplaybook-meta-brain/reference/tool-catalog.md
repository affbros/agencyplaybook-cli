# Tool catalog — the 26 meta-brain MCP tools (+3 Group L when agency-entitled)

The single source you consult for tool selection. **Every tool never throws** — connectivity/
auth/validation problems come back as structured data (often `isError:true` with an
`error.code`) that you reason over. This is **not** a CLI flag reference — it describes MCP tool
inputs/outputs.

Your surface is the **17 `meta_*` tools + the 9 shared/handoff `agency_*` tools = 26**, plus the
informational `gads_health` (Google *analysis* is the sibling `agencyplaybook-google-brain`) and,
for an **agency-entitled** tenant, **+3 Group L** agency tools (§ Group L below). The MCP advertises
**45 tools total** (48 agency-entitled) across BOTH channels — this file covers your 27 (30
agency-entitled); the `gads_*` Google tools beyond `gads_health` are NOT yours to drive. Two of the
9 shared/handoff `agency_*` tools — `agency_rollback_plan` and `agency_export_plan` — are
**channel-aware**: pass `channel:"meta"` and they behave exactly as documented here, but the same
tools work identically for a Google plan row (`channel:"google"`).

**MCP resources + prompts** (planning-docs-001 sprint-pd-003): `resources/read guide://planning/{overview,doctrine,meta,google,handoff}`
for the pipeline/states/blast-radius model, the full plan-EFFECTIVELY decision table + anti-patterns,
and worked examples per channel; `prompts/get plan_effectively` (situation → verb/tool + gates),
`build_campaign_from_brief`, `review_and_execute_plan`, `undo_plan`. See also `## Effective planning`
in `SKILL.md`.

Read tools (Groups A–G, K, L below) carry `readOnlyHint:true` and mutate nothing. The plan/spec
artifacts in Group G are `readOnlyHint:false` (a record is created) but `destructiveHint:false` — no
account changes. The **write tools** (Group I — `meta_apply_change` / `meta_execute_plan`, plus the
channel-aware `agency_rollback_plan`, all `destructiveHint:true`) run ONLY behind the approval
handshake + an explicit human YES (rollback substitutes the plan's own prior approval — see its
entry); the Group H preview/validate tools mint a token but change nothing; `meta_verify_execution`
(Group J) is a read-only post-write readback. Full execution doctrine:
`reference/safety-and-approval.md`.

Drift note: this is the verified P6 surface. `agency_capabilities` reports the live
`available_tool_groups` (and whether you're agency-entitled, which exposes Group L), so trust that
over this table if they ever differ.

---

## Group A — Discovery & Health

### `agency_capabilities`
- **Purpose:** what the server can do + what THIS tenant is entitled to. **Call first** to
  choose single vs agency mode before any costed work.
- **Input:** `{}` (none).
- **Key output:** `platforms`, `api_versions{meta,google}`, `binary_versions`,
  `entity_types{meta[],google[]}`, `tool_groups[]`, `available_tool_groups[]`, `tier`,
  `account_scope` (`single`|`agency`), `agency_entitled` (bool), `google_addon` (bool),
  `scopes` (count), `connected`, `reason?`.
- **Read it as:** `agency_entitled:false` → single-account, agency tools not exposed.
  `agency_entitled` + `account_scope:"agency"` → agency posture (but multi-account targeting
  is a later phase). `google_addon:true` → Google add-on active.

### `meta_health`
- **Purpose:** Meta backend reachable + key resolves a tenant context.
- **Input:** `{}`.
- **Key output:** `connected` (backend up), `token_valid` (key resolved), `base_url`,
  `tenant?`, `tier?`, `scopes[]?`, `reason?`. Never returns the Meta token.

### `gads_health`
- **Purpose:** Google Ads CLI connectivity (informational here; Google analysis is the
  sibling brain). Read-only.
- **Input:** `{}`. **Output:** `connected`, `version?`, `customers[]?`, `reason?`.

---

## Group B — Account / Customer Context

### `agency_get_context`
- **Purpose:** report the active `{platform, account_id}` + a non-secret entitlement summary.
- **Input:** `{}`. **Output:** `platform` (`meta`|`google`|null), `account_id` (or null),
  `entitlement{connected,tier?,account_scope,agency_entitled,google_addon,scopes,
  allowed_accounts,allow_all_accounts,write_policy?}`.

### `agency_set_context`
- **Purpose:** pin the active platform (and optionally account) for later account-specific
  tools. **Touches only MCP session memory — no ad account is modified** (so it's read-only).
- **Input:** `{ platform: "meta"|"google", account_id?: string }`.
- **Output:** the new `{platform, account_id, entitlement}`. An unauthorized account →
  `isError` with `error.code:"not_authorized"` + `allowed_accounts`, leaving context
  unchanged. (`allowed_accounts` empty = allow-all.)

### `meta_list_accounts`
- **Purpose:** the Meta ad accounts this tenant/key can target.
- **Backing:** `GET /api/v1/auth/accounts` + `/auth/resolve` + `/account/info`.
- **Input:** `{ page?: number }` (first-page size, default 50, max 500).
- **Output:** `accounts[]{id, name?, currency?, account_status?, account_status_label?,
  is_default?}`, `total`, `count`, `result_id?`, `cursor?`, `has_more`, `note`.
- **Caveat:** over HTTP, rich fields (name/currency/status) populate only for the **default**
  account; bound non-default accounts are id-only. Page the rest via `agency_get_result`.

### `meta_resolve_account`
- **Purpose:** turn a hint (name / `act_<id>` / numeric id) into a single account id.
- **Input:** `{ hint: string }`.
- **Output:** `{ resolved:bool, id?:"act_…", candidates?[{id,name?}], reason? }`. A numeric/
  `act_` hint resolves directly; a name is matched (exact then substring) against
  `meta_list_accounts`. Ambiguous → `candidates[]` (ask the user); none → `reason:"not_found"`.

---

## Group C — Entity Inspection

### `meta_list_entities`
- **Purpose:** list entities of one type for the operating account.
- **`entity_type` enum:** `campaign` · `adset` · `ad` · `creative` · `audience` · `pixel` ·
  `custom_conversion`.
- **Backing:** `GET /api/v1/<segment>` (campaigns/adsets/ads/creatives/audiences/pixels/
  custom-conversions).
- **Input:** `{ entity_type, account_id?, filters?{status?,limit?,since?,until?}, page? }`.
- **Output:** `{ entity_type, account_context, items[], total, count, result_id?, cursor?,
  has_more, note }`. Account: `account_id` arg → session context → structured
  `no_account_context`. Reads the tenant default account (see `account-context.md`).

### `meta_get_entity`
- **Purpose:** fetch one entity by id.
- **Input:** `{ entity_type, id, account_id?, resolve_names? }` (`resolve_names:true` →
  `?resolve_names=true`, resolve id from a name where supported).
- **Backing:** `GET /api/v1/<segment>/<id>`. **Output:** `{ entity_type, account_context, id,
  entity, note }`.

---

## Group D — Reporting & Performance

### `meta_get_performance`
- **Purpose:** insights/metrics for the operating account over a window, at a level.
- **Backing (auto-routed):** `GET /api/v1/reports/insights` (default rich rows: spend,
  impressions, clicks, ctr, cpc, cpm, reach, frequency, actions…). When you pass `metrics[]`
  and/or `breakdowns[]`, it routes to `GET /api/v1/reports/metrics` instead (the only path
  that honors explicit metrics/breakdowns).
- **Input:** `{ account_id?, level?("account"|"campaign"|"adset"|"ad"; default campaign),
  date_range?("30"|"90d"; default 30), since?, until?, metrics?[], breakdowns?[], limit?,
  page? }`. `since/until` (YYYY-MM-DD) override `date_range`.
- **Output:** `{ level, account_context, source("insights"|"metrics"), window, rows[], total,
  count, totals{spend?,impressions?,clicks?}, result_id?, cursor?, has_more, note }`.
- **Note:** `totals` sums **all** rows (not just the page). For "biggest" rank rows by
  `spend`; for "best/worst" rank by efficiency. Large → page via `agency_get_result`.

### `meta_compare_performance`
- **Purpose:** period-over-period — a current window vs a prior window.
- **Backing:** `GET /api/v1/reports/compare` (works in window **lengths in days**, not
  arbitrary calendar dates).
- **Input:** `{ account_id?, period_a (current window day-count, required), period_b? (prior
  window length; defaults to period_a), level?, limit? }`.
- **Output:** `{ level, account_context, current_days, prior_days, data, note }`. Use this
  for "why did CPA/ROAS move" — read the deltas in `data`.

---

## Group E — Audits (diagnostic playbooks)

### `agency_list_audits`
- **Purpose:** the available diagnostic playbooks (slugs + one-line descriptions + pillar).
  These slugs are the valid `meta_run_audit.audit` values.
- **Backing:** catalogue-derived list, enriched live from `GET /api/v1/playbooks/catalog`.
- **Input:** `{ platform?: "meta" }` (default meta).
- **Output:** `{ platform, total, audits[]{slug, name?, pillar?, description?,
  default_days?}, source("catalogue+live"|"catalogue"), note? }`. Pillars seen:
  `learning`, `signal`, `scaling`, `turnaround`. (32 Meta playbooks live.)

### `meta_run_audit`
- **Purpose:** run one playbook against the operating account → structured findings.
- **Backing:** `GET /api/v1/playbooks/<slug>` (named per-slug routes; `?days=<lookback>`).
- **Input:** `{ audit (a valid slug — see `agency_list_audits`), account_id?, lookback? }`.
- **Output:** `{ audit, account_context, lookback_days?, grade?, score?, pillar?, summary?,
  findings?, recommendations?, result_id?, has_more?, cursor?, data?, note }`. An **unknown
  slug** returns `isError` with `error.code:"invalid_audit"` **without** an HTTP call — so
  never guess a slug; list first. Large findings page via `agency_get_result`.

---

## Group F — Decision

### `meta_get_verdict`
- **Purpose:** the decisive verb per campaign — **SCALE / OPTIMIZE / TIGHTEN / CAP / HOLD /
  CUT** — from the AgencyPlaybook verdict doctrine (3 gates).
- **Backing:** `GET /api/v1/verdict` (params `days`, `include_paused`, `queue`, `target_roas`,
  `target_cpa`). There is **no** campaign filter on the backend.
- **Input:** `{ account_id?, campaign_id? (filters returned rows client-side), include_paused?
  (default false — recommend true), queue? (impact-ranked decision queue), lookback? (default
  30) }`.
- **Output:** `{ account_context, account?, lookback_days?, include_paused, campaign_count,
  summary{<VERDICT>:count}, verdicts[], targets?, notes?, note }`.
- **Read it as:** `summary` is the headline distribution; `verdicts[]` are per-campaign with
  reasoning + metrics. **Pass `include_paused:true`** — active-only windows can return
  `campaign_count:0` (means "none active in window", not broken).

---

## Group G — Plan (records / artifacts; NO account change)

These create or read plan/spec **artifacts** over the apb-api plan framework
(CREATED → VALIDATED → EXECUTED). The create tools are `readOnlyHint:false` (a record is created)
but `destructiveHint:false` — they POST WITHOUT any execute flag and perform NO Meta API call. The
live change is a later, gated phase (validate → approve → execute, Groups H/I).

### `meta_create_plan`
- **Purpose:** create a Meta change PLAN as a dry-run RECORD (state CREATED) with a computed
  `blast_radius` (0–5). No account change.
- **Backing:** `POST /api/v1/plans` (no execute flag).
- **Input:** `{ action ("campaign.pause"|"campaign.update-status"|"adset.budget.update"|…),
  target_id? OR target_ids[]?, payload?{…} (e.g. {status:"PAUSED"} / {daily_budget:5000}),
  account_id? }`.
- **Output:** `{ plan_id, state:"CREATED", action, target_id?, target_ids?, blast_radius?,
  dry_run_preview?, envelope_id?, note }`. Take the `plan_id` to `meta_validate_plan` →
  `meta_execute_plan`. `envelope_id` (saas-plans SP4) is present on a SaaS session — a
  best-effort import that puts the plan on the tenant's Plans page immediately; absent on a
  non-SaaS session or if the import didn't succeed (the plan record itself is unaffected either way).

  ```json
  {"action": "campaign.update-status", "target_id": "120212345678901", "payload": {"status": "PAUSED"}}
  ```

### `meta_build_campaign_spec`
- **Purpose:** build a launch-ready Meta campaign SPEC and preview it in DRY-RUN mode — the
  structure is validated + costed but NOTHING is created.
- **Backing:** `POST /api/v1/campaigns/compose-from-spec` (no execute flag). **Note:** the compose
  service is **Enterprise-gated** (`admin:duplicate`) and the scope gate runs before the dry-run
  branch — so even the preview returns a clean tier error on Agency/Pro tenants.
- **Input:** `{ account_id?, spec?{ campaign:{name,objective,…}, ad_sets:[…] } OR
  preset_name? ("sales-video"|"sales-carousel"|"lead-form"|"catalog-sales"|"reels-video"|
  "stories-video"), campaign_name?/page_id?/pixel_id?/form_id?/product_set_id?/catalog_id?,
  daily_budget?, with_estimates? }`.
- **Output:** `{ account_context, mode:"dry_run", spec_preview, note }`.

### `agency_list_plans`
- **Purpose:** list the tenant's stored change plans (the artifacts `meta_create_plan` made).
- **Backing:** `GET /api/v1/plans` (each plan's `{plan_id, action, target_id, status, risk_level,
  created_at}`). Large lists offload to the result store.
- **Input:** `{ page? (first-page size, default 50, max 500) }`.

  ```json
  {"status": "VALIDATED"}
  ```
- **Output:** `{ platform, items[], total, count, result_id?, cursor?, has_more, note? }`. Page the
  rest via `agency_get_result`.

### `agency_get_plan`
- **Purpose:** fetch one stored plan by id — its state, action, risk level, and preflight checks.
- **Backing:** reads `GET /api/v1/plans` + selects the id, then enriches with
  `GET /api/v1/plans/:id/doctor` (`{safe_to_execute, checks[]}`).
- **Input:** `{ plan_id (from `meta_create_plan` / `agency_list_plans`) }`.
- **Output:** `{ plan_id, found, state?, action?, target_id?, risk_level?, created_at?, doctor?,
  note }`. An unknown id returns `found:false` (NOT an error).

  ```json
  {"plan_id": "pln_abc123"}
  ```

### `meta_get_plan` (saas-plans SP4)
- **Purpose:** read one plan as its **plan-envelope-v2 document**. `readOnlyHint:true`.
- **Backing:** `GET /api/v1/plans/:id` — works with EITHER a native plan id (`meta_create_plan`)
  or a SaaS envelope-row id (`meta_create_plan`'s `envelope_id`, or the row
  `meta_validate_plan`/`meta_execute_plan` imports on a SaaS session) — both additively carry an
  `envelope` field.
- **Input:** `{ plan_id }`.
- **Output:** `{ plan_id, channel:"meta", state, envelope, envelope_note?, note }`. `state` is
  the envelope row's SaaS state (`pending`/`approved`/…/`executed`) when the id resolves to one,
  else the native plan's status. `envelope` is `null` (+ `envelope_note`) for a plan with no
  envelope form (e.g. a `cap` bookkeeping plan).
- **On a SaaS session:** this is how you check on a plan that lives on the tenant's Plans page —
  see `reference/safety-and-approval.md` § SaaS sessions.

  ```json
  {"plan_id": "pln_abc123"}
  ```

---

## Group K — Result paging

### `agency_get_result`
- **Purpose:** fetch the next page of a large result a paginating tool offloaded server-side.
  Keeps responses token-efficient instead of dumping every row.
- **Input:** `{ result_id, cursor? }` (omit cursor for the first page again).
- **Output:** `{ result_id, items[], total, count, cursor, has_more, page_size }`. Unknown/
  expired id → `error.code:"result_not_found"`; bad cursor → `invalid_cursor` (re-run the
  source query for a fresh id). Source tools: `meta_list_entities`, `meta_list_accounts`,
  `meta_get_performance`, `meta_run_audit`.

---

## Group H — Preview / Validate (mint an approval token; NO change)

These produce a dry-run preview / validate a plan and **MINT a single-use, hash-bound
`approval_token`** — they change NOTHING and send NO `execute`. `readOnlyHint:false`
(state/preview side-effects) but `destructiveHint:false`. Full rules: `reference/safety-and-approval.md`.

### `meta_preview_change`
- **Purpose:** dry-run impact preview of ONE bounded change + mint a token bound to that exact change.
- **Input:** `{ account_id?, change:{ op, target_id, target_type?, status?, budget?, current_budget? } }`.
  `op` ∈ `pause`·`resume`·`enable`·`set_status`·`set_budget`·`update_budget`·`archive`·`delete`.
- **Output:** `{ account_context, change, preview, impact{blast_radius,requires_confirm_destructive,
  reversible}, approval_token, change_set_hash, expires_at(~10 min), risk:"mutation", note }`.
- **Read it as:** nothing changed; carry `approval_token` to `meta_apply_change` with a **byte-identical**
  `change`. `current_budget` only feeds the impact flag (>200%) — it does NOT affect the hash.

### `meta_validate_plan`
- **Purpose:** validate a CREATED plan (`POST /api/v1/plans/:id/validate` — no write gate, no Meta call)
  → VALIDATED + blast_radius; on PASS, mint a token bound to the plan-execution descriptor.
- **Input:** `{ plan_id, account_id? }`.
- **Output:** `{ plan_id, state("VALIDATED"|"INVALID"), validation_errors[], blast_radius?,
  requires_confirm_destructive, approval_token?(only on VALIDATED), change_set_hash?, expires_at?,
  risk?, note }`. INVALID ⇒ **no token** (fix + re-validate).

  ```json
  {"plan_id": "pln_abc123"}
  ```

---

## Group I — Execute (WRITE behind the handshake)

The ONLY tools that mutate an account. `readOnlyHint:false` + `destructiveHint:true`. They write to
the account you operate on, and require a valid `approval_token` + `operator_confirmation:true`
(+ `confirm_destructive:true` for an L4 op) — the consent layer (handshake + human YES); there is no
account fence. They auto-run `meta_verify_execution` after the write. Path selection is credential
routing (`http` = production API → real account; `subprocess` = BYO sandbox), with the default taken
from configuration — NOT a restriction.

### `meta_apply_change`
- **Purpose:** apply ONE bounded change behind the handshake (+ the human YES).
- **Input:** `{ account_id?, change:{ op, target_id, target_type?, status?, budget? }, approval_token,
  operator_confirmation:true, confirm_destructive?, path?("http"|"subprocess") }`. `change`
  must hash-match the previewed one. Omit `path` to use the configured default.
- **Output:** `{ account_context, change, change_set_hash, path, applied, result, verify_result,
  approval_jti, audit_id, note }` (or `{error}` with `raw.reason`/`raw.approval_reason`).
- **L4** (delete/archive/$0/>200%) ⇒ `confirm_destructive:true` required (else `confirm_destructive_required`).

### `meta_execute_plan`
- **Purpose:** execute a VALIDATED plan behind the handshake (+ the human YES). **Re-validates the plan
  first** (recovers the current descriptor + enforces freshness — a changed plan ⇒ `hash_mismatch`).
- **Input:** `{ plan_id, account_id?, approval_token, operator_confirmation:true, confirm_destructive?,
  path?("http"|"subprocess") }`.
- **Output:** `{ account_context, plan_id, envelope_id?, job_id?, state, change_set, change_set_hash,
  blast_radius, path, executed, result, execution_receipt?, poll_timed_out?, verify_result,
  approval_jti, audit_id, note }` (or `{error}`). Refuses `not_found` (no such plan) /
  `plan_not_validated` (not VALIDATED) before the handshake.
- **L4** (CRITICAL / blast score ≥ 4) ⇒ `confirm_destructive:true` required.
- **saas-plans SP4 — on a SaaS session (`path:"http"`, the default):** goes through the SaaS
  handshake instead of a direct execute — import (bind `sha256(approval_token)`) → `POST
  /plans/:id/approve {mcp_token: approval_token}` (skipped if a human already approved on the web)
  → `POST /plans/:id/execute` (202, async job) → polls `GET /plans/:id` to a terminal state
  (`executed`/`failed`/`rolled_back`, ~2s interval, ~10 min ceiling). `envelope_id`/`job_id`/
  `execution_receipt`/`poll_timed_out` are present only on this path. A plan with no envelope form
  falls back to the pre-SP4 direct execute unchanged. See `reference/safety-and-approval.md`.

  ```json
  {"plan_id": "pln_abc123", "approval_token": "apt_...", "operator_confirmation": true}
  ```

---

## Group — Plan handoff (channel-aware: works for BOTH `meta` and `google` plan rows)

### `agency_rollback_plan`
- **Purpose:** undo an EXECUTED plan, or a `failed` plan whose receipt shows the run created at
  least one resource, on **either** channel. `readOnlyHint:false + destructiveHint:true`. The API
  builds the inverse plan from the original's recorded prior values + its execution receipt,
  imports it as its own row, and runs it as a job.
- **Consent — NO approval token, deliberately:** the SaaS row being undone IS the consent record
  (it could not have executed without being approved), and the inverse plan inherits that approval.
  What this tool requires instead is the same human gate an execute carries:
  `operator_confirmation:true` AND `confirm_destructive:true` (an undo removes created entities).
- **Input:** `{ channel:"meta"|"google", plan_id, operator_confirmation:true, confirm_destructive:true }`.
- **Output:** `{ channel, plan_id, account, state_before, state_after, rollback_plan_id, job_id,
  actions, not_invertible, rolled_back, poll_timed_out, result, audit_id, note }` (or `{error}`).
  `not_invertible` is REPORTED, never guessed at — anything listed there is still live and needs a
  manual decision. Eligibility refusals: `plan_not_executed` (a `failed` plan that created nothing),
  `no_execution_receipt`, `plan_not_invertible`.

  ```json
  {"channel": "meta", "plan_id": "pln_abc123", "operator_confirmation": true, "confirm_destructive": true}
  ```

### `agency_export_plan`
- **Purpose:** hand a stored SaaS plan row BACK to the CLI as its plan-envelope-v2 document.
  `readOnlyHint:true` — never approves, executes or mutates anything. This is the **SaaS → CLI**
  half of the handoff; the **CLI → SaaS** half needs no tool (a CLI-produced document is imported
  by the existing import path — `meta_execute_plan`'s handshake for Meta, `gads_export_plan` for
  Google — and shows on the same `/plans/<id>` Plans page for a human Approve).
- **Input:** `{ channel:"meta"|"google", plan_id, format?:"envelope"(default)|"handoff" }`.
  `"envelope"` returns the full document (write it verbatim to `plan.json`); `"handoff"` returns
  only the commands/metadata for a smaller response.
- **Output:** `{ plan_id, channel, state, plan_hash, has_temp_refs, envelope?, summary,
  cli:{apply_command, validate_command, rollback_command}, urls:{review_html, editor_zip?}, note }`
  (or `{error}`). `apply_command` — `apb plan apply --from-file plan.json --execute` (Meta,
  validate first with `apb plan validate --from-file`) or `apb-gads mutate apply-plan --from-file
  plan.json --execute` (Google, `--validate-only` first). `plan_hash` is re-verified on apply — a
  file edited after export needs `--allow-edited-plan`, and you should say so explicitly rather
  than adding it silently. `has_temp_refs:true` means the envelope still carries `{{ref:aN}}` /
  `{{account}}` — the EXECUTOR binds those at run time; never substitute them by hand.

  ```json
  {"channel": "google", "plan_id": "pln_g_9a3f", "format": "handoff"}
  ```

---

## Group — CLI-planning producers (channel-aware; read-only — none of these writes)

### `agency_build_plan`
- **Purpose:** turn a BRIEF into a launch-ready build — runs `apb recipe build` on Meta (pass
  `channel:"meta"`) as a dry-run subprocess. `readOnlyHint:false + destructiveHint:false` (no
  `--execute` is ever built, so nothing is created in the account). On a SaaS session the envelope
  is ALSO imported to the Plans page with a freshly minted approval token → `plan_id` +
  `review_url`.
- **Input:** `{ channel:"meta", brief (YAML string | object), account_id?, format?:"envelope"|
  "handoff" }`. (`stage` is Google-only and refused by name on Meta.)
- **Output:** `{ channel, account, plan_id?, plan_hash, has_temp_refs, action_count, blast_radius,
  summary, spec, verdict, artifacts[], envelope?, result_id?, review_url, approval_token,
  change_set_hash, expires_at, cli:{apply_command,validate_command,rollback_command}, note }` (or
  `{error}`). Next step after human YES: `meta_execute_plan` or `agency_export_plan` → CLI apply.
  Undo an executed build with `agency_rollback_plan`.

  ```json
  {"channel": "meta", "brief": {"customer_id": "act_1476889130308799", "objective": "leads", "final_url": "https://example.com", "daily_budget": 50}}
  ```

### `agency_merge_plans`
- **Purpose:** merge N plan envelopes into ONE ranked, wave-sequenced envelope (`plan merge`) —
  read-only producer.
- **Input:** `{ channel:"meta", plans[] (1..20 — plan_id strings and/or inline plan-envelope-v2 objects), mode?
  ("growth"|"efficiency"), account_id?, format? }`. (`--learning-window-days` is Meta-only.)

  ```json
  {"channel": "meta", "plans": ["pln_waste_audit", "pln_scale"], "mode": "efficiency"}
  ```
- **Output:** `{ channel, account, inputs, mode, plan_id?, plan_hash, has_temp_refs, action_count,
  blast_radius, summary, waves, conflicts, envelope?, result_id?, review_url, approval_token,
  change_set_hash, expires_at, cli, note }`. `waves` carries `wait-for-status` pseudo-actions the
  EXECUTOR waits on between waves — never strip them. `conflicts[]` needs a human to settle before
  re-merging.

### `agency_forecast_plan`
- **Purpose:** forecast a build spec (`agency_build_plan`'s `spec`) or a live ad set
  (`plan forecast`) — read-only, no plan artifact produced.
- **Input:** `{ channel:"meta", spec? | adset_id?, plan_id? (account-resolution only),
  budget_scenarios? (array, max 10), period?, account_id? }` — exactly one of `spec`/`adset_id`.

  ```json
  {"channel": "meta", "adset_id": "120210000000000", "budget_scenarios": [50, 75, 100]}
  ```
- **Output:** `{ channel, account, source, forecast, scenarios?, result_id?, caveats[], note }` (or
  `{error}`). Meta returns the delivery-estimate scenario table — read `caveats` before quoting a
  number to a client.

---

## Group J — Verify (post-write readback)

### `meta_verify_execution`
- **Purpose:** read an entity back AFTER a write and report OBSERVED state; with `expected`, whether
  the change landed. `readOnlyHint:true`. The execute tools call it automatically — also standalone.
- **Input:** `{ account_id?, target_id, target_type?("campaign"(default)|"adset"|"ad"),
  path?("http"|"subprocess"), expected?{status?|daily_budget?} }` (path follows the write it verifies).
- **Output:** `{ account_context, target_id, target_type, path, observed, entity, expected?, matches?,
  verified, note }`. `verified:true` = the readback succeeded; it CONFIRMS the change only when
  `matches:true` (requires `expected`). **Never report a write as landed without this.**

---

## Group L — Agency portfolio (registers ONLY for an agency-entitled tenant)

These 3 tools are exposed **only when `agency_capabilities` reports `agency_entitled:true`** (an
agency-class tier). A non-agency tenant never sees them — don't reach for them otherwise. All
`readOnlyHint:true` (they touch NO ad account; selecting a sub-account changes only this MCP
session's selection). Full rules: `reference/account-context.md`.

### `meta_agency_list_accounts`
- **Purpose:** the merged Meta ad-account portfolio across ALL connected Meta tokens (primary +
  each additional connection), deduped (primary wins). Live-validates each connection and reports
  degraded ones honestly.
- **Backing:** `GET /api/v1/saas/agency/accounts` (Bearer `APB_API_KEY`).
- **Input:** `{}`.
- **Output:** `{ connected, account_count, accounts[{account_id,name?,connection_id?,
  connection_label?,is_primary?}], connections[{id?,is_primary?,label?,business_id?,account_count?,
  status,error?}], notes?[] }`. A stale connection appears as `status:"error"` with a note — surface
  it, don't claim all-connected. A non-agency key → `403 agency_tier_required`.

### `agency_select_subaccount`
- **Purpose:** pick which portfolio sub-account to operate on next — validates the id against the
  LIVE portfolio (not the key's `allowed_accounts`) and, on a match, pins `{platform:"meta",
  account_id}` into this MCP session. Touches NO ad account.
- **Input:** `{ account_id (act_… / numeric / a hint matching a portfolio account) }`.
- **Output:** on a match `{ selected:true, platform:"meta", account_id, matched_name? }`; on a miss
  `{ selected:false, …, error.code:"not_in_portfolio" }` (context unchanged).

### `agency_get_portfolio`
- **Purpose:** the cross-channel per-account triage roll-up — ONE call returns every managed account
  across BOTH Meta (BYO-token insights, merged across connections) and Google (the MCC children),
  each with a per-account SCALE/OPTIMIZE/TIGHTEN/CAP/HOLD/CUT verdict, PER-CURRENCY totals (never
  summed across currencies), and per-channel degradation notes.
- **Backing:** `GET /api/v1/saas/agency/portfolio` (Bearer `APB_API_KEY`). Per-account rows offload
  to the result store.
- **Input (all optional):** `{ days (1–730, default 30), channel ("meta"|"google"|"all"),
  group_by ("currency"|"channel"|"client"), compare?, date_from?/date_to? }`.
- **Output:** `{ scope:"agency", window, items[{account_id,name,channel,currency,status,reachable,
  spend,conversions,revenue,roas,cpa,ctr,impressions,verdict,…}], total, count, result_id?, cursor,
  has_more, totals_by_currency[], totals{account_count,hidden_count,client_count,channels}, notes? }`.
  Page the rest via `agency_get_result`; drill into a winner/loser with `agency_select_subaccount`.

---

## Common structured-error codes (all returned, never thrown)
`validation_failed` (e.g. no account context; also carries `raw.reason` like
`operator_confirmation_required` / `confirm_destructive_required` / `plan_not_validated`, or
`raw.approval_reason` like `hash_mismatch` / `token_expired` / `token_already_used` /
`account_mismatch` / `platform_mismatch` / `bad_signature` / `malformed_token`) · `invalid_audit`
(unknown slug) · `not_found` (plan/entity missing) · `result_not_found` / `invalid_cursor` (paging) ·
`not_in_portfolio` (`agency_select_subaccount` — id not a portfolio member) ·
`agency_tier_required` (Group L on a non-agency key) ·
`insufficient_scope` / `not_entitled` (tier/scope gap — surface the upgrade path, don't loop) ·
`upstream_error` / `config_error` (apb/apb-api failure after the gates). Branch on the **code**
(and `raw.reason`/`raw.approval_reason`), not the message.
