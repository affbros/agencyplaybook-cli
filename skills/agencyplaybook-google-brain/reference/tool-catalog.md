# Tool catalog — the Google surface (14 `gads_*` + the shared `agency_*` tools)

The single source you consult for tool selection. **Every tool never throws** — connectivity /
auth / validation problems come back as structured data (often `isError:true` with an
`error.code`) that you reason over. This is **not** a CLI flag reference — it describes MCP tool
inputs/outputs.

The MCP advertises **37 tools** total. **14 are `gads_*`** (Google); the brain also reuses the
**shared `agency_*`** context/discovery/result tools. Of the Google tools, the **9 read tools**
carry `readOnlyHint:true` and mutate nothing; the **3 plan/preview tools**
(`gads_build_campaign_spec` / `gads_validate_spec` / `gads_preview_change`) are
`readOnlyHint:false + destructiveHint:false` (they build an artifact / mint an approval token but
make NO live change); **`gads_apply_change`** is the only write (`destructiveHint:true`, behind the
approval handshake + an explicit human YES); **`gads_verify_execution`** is a read-only post-write
readback. Full execution doctrine: `reference/safety-and-approval.md`.

> Every Google read is an `apb-gads` SUBPROCESS in SaaS-managed mode (`APB_API_KEY` resolves the
> Google token server-side; argv-only `execFile`, no shell, a hard read-flag allowlist that refuses
> `--execute` / `--config` / any write flag pre-spawn). Money is reported in **MICROS verbatim**.

---

## Shared — Discovery, Context, Result paging (`agency_*`)

### `agency_capabilities`
- **Purpose:** what the server can do + what THIS tenant is entitled to. **Call first** to choose
  posture and to read the Google add-on before any costed work.
- **Input:** `{}`.
- **Key output:** `platforms`, `api_versions{meta,google}` (Google v24), `binary_versions`,
  `entity_types{google[]}`, `tool_groups[]`, `available_tool_groups[]`, `tier`, `account_scope`,
  `agency_entitled` (bool), **`google_addon` (bool)**, `scopes` (count), `connected`, `reason?`.
- **Read it as:** `google_addon:true` → the paid Google add-on is active (gates `write:google:*`
  scopes). `available_tool_groups` is the authoritative callable set.

### `agency_get_context`
- **Purpose:** report the active `{platform, account_id}` + a non-secret entitlement summary.
- **Input:** `{}`. **Output:** `platform` (`meta`|`google`|null), `account_id` (or null),
  `entitlement{connected,tier?,account_scope,agency_entitled,google_addon,scopes,allowed_accounts,
  allow_all_accounts,write_policy?}`. **`write_policy`** is the Google-write floor (e.g. `ReadOnly`
  blocks writes even at Agency tier when `google_addon` is off).

### `agency_set_context`
- **Purpose:** pin the active platform (and optionally customer) for later customer-specific tools.
  **Touches only MCP session memory — no Google account is modified** (so it's read-only).
- **Input:** `{ platform:"google", account_id?: <customer_id> }`.
- **Output:** the new `{platform, account_id, entitlement}`. An unauthorized customer →
  `isError` with `error.code:"not_authorized"` + `allowed_accounts` (context unchanged;
  `allowed_accounts` empty = allow-all).

### `agency_list_audits` (the Google branch)
- **Purpose:** the available diagnostic playbooks. For Google, pass `platform:"google"` → the
  catalogue-derived gads playbook slugs (+ one-line descriptions). These slugs are the valid
  `gads_run_audit.audit` values.
- **Input:** `{ platform:"google" }`.
- **Output:** `{ platform:"google", total, audits[]{slug, name?, pillar?, description?}, source }`.
  (`source:"catalogue"` — no live call; gads is a subprocess.) The Google catalogue has 66
  diagnostic playbooks (account-health, waste-audit, pmax-audit, rsa-quality-audit, …).

### `agency_get_result`
- **Purpose:** fetch the next page of a large result a paginating tool offloaded server-side.
- **Input:** `{ result_id, cursor? }`. **Output:** `{ result_id, items[], total, count, cursor,
  has_more, page_size }`. Unknown/expired id → `result_not_found`; bad cursor → `invalid_cursor`
  (re-run the source query). Source tools: `gads_list_entities`, `gads_get_performance`,
  `gads_run_gaql`, `gads_run_audit`, `gads_build_campaign_spec`.

---

## Group A — Google Health

### `gads_health`
- **Purpose:** Google Ads connectivity via the `apb-gads` release binary — version + accessible
  customers. Read-only; never passes a write flag.
- **Input:** `{}`. **Output:** `connected` (binary ran AND reported usable creds), `version?`
  (e.g. `0.1.x`), `customers[]?` (accessible numeric ids), `reason?`.

---

## Group — Customer read

### `gads_list_customers`
- **Purpose:** the Google customers this tenant/key can reach (under the login MCC). Read-only.
- **Backing:** `apb-gads customer list`.
- **Input:** `{}`. **Output:** `customers[]{ id, descriptive_name?, currency_code?, time_zone?,
  manager?, level? }`, `mcc?` (the login MCC = level 0 + manager), `total`, `note`. The numeric
  `id` is the `--customer` selector for every other gads tool.

### `gads_resolve_customer`
- **Purpose:** turn a hint (name / numeric id / `customers/<id>`) into a single `customer_id`.
- **Input:** `{ hint }`. **Output:** `{ resolved:bool, customer_id?, candidates?[{id,
  descriptive_name?}], reason? }`. A numeric / `customers/<id>` hint passes through with no
  subprocess call; a name is matched (case-insensitive, exact then substring) against
  `gads_list_customers`. Ambiguous → `candidates[]` (ask the user); none → `reason:"not_found"`.

### `gads_list_entities`
- **Purpose:** list entities of one type for the operating customer.
- **`entity_type` enum:** `campaign` · `ad_group` · `ad` · `keyword` · `negative_keyword` · `asset`.
- **Backing:** `apb-gads <group> list --customer <id> [--limit N]`.
- **Input:** `{ entity_type, customer_id?, limit?, page? }`. Customer: `customer_id` arg → pinned
  session customer (`agency_set_context google`) → structured `no_customer_context`.
- **Output:** `{ entity_type, customer_id, items[] (raw GAQL-shaped rows), total, count, result_id?,
  cursor?, has_more, field_mask? }`. Large lists offload to the result store.

### `gads_get_entity`
- **Purpose:** fetch one entity by id. A campaign uses `apb-gads campaign get --campaign-id <id>`;
  the others are fetched via a SELECT-by-id GAQL through the read runner (no per-type `get` leaf).
- **Input:** `{ entity_type, id (numeric), customer_id? }`.
- **Output:** `{ entity_type, customer_id, id, entity (object or GAQL rows), note? }`. Non-campaign
  rows are minimal (id column) — use `gads_list_entities` for full rows.

---

## Group — Reporting

### `gads_get_performance`
- **Purpose:** run one of the **23 catalogue reports** for the operating customer.
- **Backing:** `apb-gads report <name> --customer <id> [--lookback-days N] [--limit N]`.
- **Input:** `{ report (a catalogue report name — unknown → structured `invalid_report`, NO
  subprocess), customer_id?, lookback?, limit?, page? }`. Examples: `campaign-performance-365d`,
  `search-terms-365d`, `pmax-summary`.
- **Output:** `{ report, customer_id, lookback_days?, rows[], total, count, field_mask?, result_id?,
  cursor?, has_more, note }`. **Money is in MICROS verbatim.** Use a `-365d` report name for
  search-term / term-view data — a short window on paused campaigns is legitimately empty.

### `gads_run_gaql`
- **Purpose:** run a raw GAQL **SELECT** against the operating customer. **READ-GUARDED**: the
  query MUST start with `SELECT` and MUST NOT contain a mutate token — otherwise it's refused
  PRE-SPAWN with a structured `invalid_query` (no subprocess). The query is a single argv element,
  never interpolated.
- **Backing:** `apb-gads gaql query --customer <id> --query "<GAQL>"`.
- **Input:** `{ customer_id?, query, page? }`.
- **Output:** `{ customer_id, query, rows[], total, count, field_mask?, result_id?, cursor?,
  has_more }`.

---

## Group — Audits (diagnostic playbooks)

### `gads_run_audit`
- **Purpose:** run one of the **66 Google playbooks** against the operating customer → structured
  findings. An **unknown slug** returns `error.code:"invalid_audit"` **without** a subprocess — so
  list first via `agency_list_audits {platform:"google"}`.
- **Backing:** `apb-gads playbook <slug> --customer <id> [--lookback-days N]`.
- **Input:** `{ audit (a valid slug), customer_id?, lookback? }`. Examples: `account-health`,
  `waste-audit`, `pmax-audit`, `rsa-quality-audit`.
- **Output:** `{ audit, customer_id, lookback_days?, findings (the nested structured playbook
  payload), summary?, result_id?, has_more?, cursor?, note }`. A large top-level array in the
  payload is offloaded to the result store.

---

## Group — Decision

### `gads_get_verdict`
- **Purpose:** the decisive verb per campaign — **SCALE / OPTIMIZE / TIGHTEN / CAP / HOLD / CUT** —
  from the gads verdict doctrine (3 gates). The Google twin of `meta_get_verdict`.
- **Backing:** `apb-gads verdict --customer <id> [--include-paused] [--queue] [--target-roas R]
  [--target-cpa C] [--lookback-days N]`.
- **Input:** `{ customer_id?, include_paused? (default false — recommend true), queue?
  (impact-ranked decision queue), lookback? (default 30), target_roas?, target_cpa? }`.
- **Output:** `{ customer_id, campaign_count, lookback_days?, include_paused, mode?,
  summary{<VERDICT>:count}, verdicts[] (per-campaign verb + gates + metrics), targets?, notes?,
  note }`.
- **Read it as:** `summary` is the headline distribution; `verdicts[]` are per-campaign. **Pass
  `include_paused:true`** — active-only windows can return `campaign_count:0` (means "none active in
  window", not broken; `mode` becomes `reactivation`).

---

## Group G — Plan / spec build + spec validate (NO change; one may mint a token)

These are **pure-local** (no Google API call) — they build an artifact / validate a spec.
`readOnlyHint:false + destructiveHint:false`.

### `gads_build_campaign_spec`
- **Purpose:** assemble a launch-ready Search or PMAX campaign **spec**, in DRY-RUN — built and
  previewed but **nothing is created**. Mints **NO** token.
- **Backing (NO `--execute`):** `apb-gads plan campaign search|pmax …` (a pure transform, no API).
- **Input:** `{ spec_kind:"campaign_spec"|"pmax_spec" (default campaign_spec), customer_id?,
  structure_path?, rsa_path?, goals_path?, keywords_plan_path?, final_url?, business_name?,
  daily_budget?, budget_micros?, campaign_name?, landing_page?, target_cpa? }`. Search needs
  `structure_path` + `rsa_path` + `daily_budget`; PMAX needs `campaign_name` + `final_url` +
  `business_name` + a budget.
- **Output:** `{ kind, customer_id, mode:"dry_run", spec_preview, result_id?, note }`. The full spec
  is at `result_id` — page via `agency_get_result`.

### `gads_validate_spec`
- **Purpose:** validate a launch spec for launch-readiness and, on a PASS, **mint a single-use
  approval token** bound to that EXACT spec. Pure-local validator (no API, no write).
- **Backing (NO `--execute`):** `apb-gads validate campaign-spec|pmax-spec --from-file <f>`.
- **Input:** `{ spec_kind?, customer_id?, spec? (inline object) | from_file? (path) }` — provide one
  of `spec` / `from_file`.
- **Output:** `{ kind, customer_id, overall ("pass"|"fail"), report, requires_confirm_destructive
  (false for a spec), approval_token? (ONLY on pass), change_set_hash?, expires_at?, risk?, note }`.
  A failing validation mints **no token** — fix `report.errors` and re-validate.
- **Note:** there is **no Google "launch" / plan-execute MCP tool** in this surface to consume a
  spec token (deferred); `gads_apply_change` consumes only a `gads_preview_change` token for a
  single bounded change. Don't imply a launch you can't perform.

---

## Group H — Preview a single change (mint an approval token; NO change)

### `gads_preview_change`
- **Purpose:** dry-run preview of ONE bounded Google change + mint a token bound to that exact
  change. `readOnlyHint:false + destructiveHint:false`.
- **Backing (NO `--execute`):** `apb-gads mutate <op> --customer <id> [op flags]` — without
  `--execute` the binary short-circuits BEFORE any write gate and returns the would-be `operation`
  + a `guard` block (`{ allowed:false, mode:"dry-run", reason:"--execute not provided" }`), exit 0,
  changing nothing.
- **Bounded `op` enum:** `campaign-update-status` · `ad-update-status` · `campaign-budget-update` ·
  `keyword-update-match-type` · `keyword-bid-set` · `campaign-update-bidding-strategy` ·
  `negative-keyword-add` · `campaign-negative-keyword-add` · `criterion-remove`. (9 ops at preview;
  only **5 are executable via the managed proxy** today — see `reference/safety-and-approval.md`.)
- **Input:** `{ customer_id?, change:{ op, entity_id, params? } }`. `params` carries the change-
  defining flags — e.g. `{ status:"PAUSED" }`, `{ amount_micros:5000000 }`, `{ match_type:"PHRASE" }`,
  `{ text:"free" }`, `{ bidding_strategy_type:"MAXIMIZE_CONVERSIONS" }`. Pass `current_amount_micros`
  (impact-only; NOT hashed) to flag a >200% budget jump.
- **Output:** `{ customer_id, change, preview (would-be `operation` + `applied:false`), guard,
  status:"dry-run-only", requires_confirm_destructive, approval_token, change_set_hash, expires_at
  (~10 min), risk:"mutation", note }`. Carry `approval_token` to `gads_apply_change` with a
  **byte-identical** `change` (else `hash_mismatch`).

---

## Group I — Execute the change (WRITE behind the handshake)

### `gads_apply_change`
- **Purpose:** apply ONE bounded Google change to the customer you operate on, behind the full
  approval handshake (+ the human YES). The ONLY tool that mutates a Google account.
  `readOnlyHint:false + destructiveHint:true`.
- **Handshake (enforced IN ORDER; first failure stops with its reason):** resolve customer →
  reconstruct the canonical change (SHARED builder; byte-identical to `gads_preview_change`) →
  `verifyAndConsume(approval_token)` (single-use; refuses malformed / bad-signature / expired /
  reused / platform / account / hash mismatch) → `operator_confirmation:true` → `confirm_destructive:
  true` for an L4 op → budget guard → submit on the selected path → auto-`gads_verify_execution` →
  audit.
- **Input:** `{ customer_id?, change:{ op, entity_id, params? } (must hash-match the token),
  approval_token, operator_confirmation:true, confirm_destructive? }`.
- **Output:** `{ customer_id, change, change_set_hash, applied, result, verify_result, approval_jti,
  audit_id, note }` (or `{error}` with `raw.reason` / `raw.approval_reason`).
- **Path selection is credential routing, NOT a fence.** Production (no BYO yaml) → the apb-api
  `/google` managed-write proxy (`googleAds:mutate`; scope `write:google:mutations` + `write_policy`
  gated upstream). The BYO sandbox test path (a configured write yaml) → the gads subprocess with
  `--execute`. **Only 5 of the 9 ops are executable via the managed proxy today** — the other 4 are
  refused `google_managed_op_requires_ad_group` with no live call (see
  `reference/safety-and-approval.md`).

---

## Group J — Verify (post-write readback)

### `gads_verify_execution`
- **Purpose:** read a Google entity back AFTER a write and report OBSERVED state (status /
  amount_micros / match_type / cpc_bid_micros); with `expected`, whether the change landed.
  `readOnlyHint:true`. `gads_apply_change` calls it automatically — also standalone.
- **Backing (READ path):** a campaign via `apb-gads campaign get`; ad/keyword/negative_keyword/
  ad_group/asset via a digits-validated SELECT-by-id GAQL. **Never a write flag.**
- **Input:** `{ customer_id?, entity_id (numeric), entity_type? ("campaign" default | "ad" |
  "keyword" | "negative_keyword" | "ad_group" | "asset"), expected? }`.
- **Output:** `{ customer_id, entity_id, entity_type, observed, entity, expected?, matches?,
  verified, note }`. `verified:true` = the readback succeeded; it CONFIRMS the change only when
  `matches:true` (requires `expected`). **Never report a write as landed without this.** Budget and
  negative-keyword adds skip the auto by-id readback (the mutate response is the proof; confirm on
  demand with this tool).

---

## Common structured-error codes (all returned, never thrown)
`no_customer_context` (no pinned customer) · `not_authorized` (customer not in allowlist) ·
`invalid_audit` (unknown playbook slug) · `invalid_report` (unknown report name) · `invalid_query`
(GAQL not a SELECT / contains a mutate token) · `not_entitled` / `insufficient_scope` (tier/scope/
`google_addon` gap — surface the upgrade path, don't loop) · `result_not_found` / `invalid_cursor`
(paging) · the approval `raw.approval_reason` family (`hash_mismatch` / `token_expired` /
`token_already_used` / `account_mismatch` / `platform_mismatch` / `bad_signature` /
`malformed_token`) · `operator_confirmation_required` / `confirm_destructive_required` ·
`google_managed_op_requires_ad_group` (one of the 4 deferred managed ops) ·
`upstream_error` / `config_error` (apb-gads / proxy failure after the gates). Branch on the **code**
(and `raw.reason` / `raw.approval_reason`), not the message.
