# Workflows — MCP tool sequences

Each workflow is an ordered sequence of MCP **tool** calls (never CLI commands). They share a
common preamble; skip steps that are already satisfied (e.g. context already pinned). Workflows
A–E are read-only — they end in a recommendation, never an applied change. **Workflow F is the
one that can apply a change — to the account you operate on, behind the approval handshake + an
explicit human YES (`reference/safety-and-approval.md`).**

## Preamble (every workflow)

1. `agency_capabilities` — posture + entitlement. Decides single vs agency mode; in v1 stay
   single-account regardless (multi-account is a later phase).
2. `meta_health` — confirm `connected:true` and `token_valid:true`. If the key didn't resolve,
   tell the user to set `APB_API_KEY`; don't keep calling costed tools.
3. Resolve + pin the account: `meta_resolve_account` (name/id → `act_…`) → `agency_set_context`
   **or** pass `account_id` on each call. **Confirm the account with the user** before costed
   reads. If `meta_resolve_account` returns `candidates[]`, ask which one.

---

## Workflow A — "Audit this account"

Goal: a prioritized health picture + a decisive next step.

1. Preamble.
2. `agency_list_audits` — see the playbooks (slug + pillar + description).
3. `meta_run_audit { audit:"health-score", lookback:30 }` — overall grade/score/summary.
4. Run 1–3 targeted playbooks by symptom or pillar, e.g.:
   - waste / efficiency → `meta_run_audit { audit:"waste-audit" }`
   - creative fatigue → `fatigue-index`; over-saturation → `saturation`
   - conversion drop-off → `funnel-leak`; structure → `cbo-vs-abo-audit`
5. `meta_get_verdict { include_paused:true }` — the per-campaign verb to act on.
6. Summarize: overall grade → top findings (with `$`/grade) → verdict distribution → the 2–3
   highest-impact campaigns and the **proposed** (not applied) change for each.

## Workflow B — "Why did CPA / ROAS / spend move?"

Goal: explain a directional change with evidence.

1. Preamble.
2. `meta_compare_performance { period_a:"30d", period_b:"30d", level:"campaign" }` — the
   period-over-period deltas (current vs prior window of equal length). Adjust the windows to
   the user's timeframe.
3. `meta_get_performance { level:"campaign", date_range:"<window>" }` — the current detail;
   rank `rows` by `spend` to find which campaigns drove the move.
4. Drill the suspect campaign(s): `meta_get_performance { level:"adset", … }`, and run a
   diagnostic that fits the symptom — rising frequency → `fatigue-index`; CTR/CPM shift →
   `creative-mix` / `placement-audit`; conversion loss → `funnel-leak` / `signal-quality`.
5. `meta_get_verdict { include_paused:true }` for the recommended response.
6. Summarize: what moved, the campaign(s) responsible, the likely cause (cite the audit
   finding), and the proposed response.

## Workflow C — "What should I scale / tighten / cut?"

Goal: a ranked decision list.

1. Preamble.
2. `meta_get_verdict { include_paused:true, queue:true }` — the impact-ranked decision queue
   (verb + reasoning + metrics per campaign). `queue:true` gives the ranked view.
3. For each SCALE/CUT/TIGHTEN candidate, confirm with `meta_get_performance` (spend, ROAS,
   trend) and, if useful, the matching audit (`scale-roadmap` for scalers, `waste-audit` for
   cuts).
4. Summarize by verb: SCALE these (and the budget headroom), TIGHTEN/CAP these, CUT these —
   each with the **proposed** change-set in words. Do not apply anything.

> Empty result trap: if `meta_get_verdict` returns `campaign_count:0`, you almost certainly
> ran active-only — re-run with `include_paused:true` before concluding "nothing to do."

## Workflow D — "Weekly performance summary"

Goal: a tight recurring readout.

1. Preamble.
2. `meta_get_performance { level:"campaign", date_range:"7d" }` — week totals + top rows.
3. `meta_compare_performance { period_a:"7d", period_b:"7d" }` — week-over-week deltas.
4. (optional) `meta_run_audit { audit:"weekly-digest" }` for the canned weekly view.
5. `meta_get_verdict { include_paused:true }` — anything needing attention.
6. Summarize: spend + top movers + week-over-week direction + the 1–2 actions to consider.

## Workflow E — "Inspect / list my campaigns (or adsets/ads/audiences/pixels)"

1. Preamble.
2. `meta_list_entities { entity_type:"campaign" }` (or adset/ad/creative/audience/pixel/
   custom_conversion). Page with `agency_get_result` if `has_more`.
3. For one entity: `meta_get_entity { entity_type, id }` (use `resolve_names:true` to look up
   by name where supported).
4. Summarize the list (don't paste every row); offer to drill into one.

---

## Workflow F — "Apply this change / execute this plan" (behind the handshake + a human YES)

Goal: actually make a change — bounded, approved, verified — on the account you operate on. This is
the ONLY workflow that mutates anything. The consent layer is the approval handshake (the token)
PLUS your explicit human YES; the binary is a mechanical executor, not a guard. Full rules + every
refusal reason: `reference/safety-and-approval.md`. If you do NOT have a fresh token or the user has
NOT said yes, do not write — preview to mint a token, surface the change-set, and ask for the
go-ahead.

**Single bounded change** (e.g. "pause this loser"):

1. Preamble — resolve + CONFIRM the target account (you write to the account you operate on; name it).
2. (If you haven't already decided the change) analyze: `meta_get_verdict` / the relevant audit to
   ground WHICH entity and WHAT change.
3. `meta_preview_change { account_id:"act_<ID>", change:{ op, target_id, target_type, … } }`
   — returns the impact + a single-use `approval_token`. **Nothing changed yet.**
4. **APPROVAL:** tell the user the exact change-set + impact + blast radius + the target account,
   and get an explicit "yes." (For an L4 op — delete/archive/$0/>200% — call out the irreversibility.)
5. `meta_apply_change { account_id:"act_<ID>", change:{ …byte-identical to step 3… },
   approval_token, operator_confirmation:true [, confirm_destructive:true for L4] }`. (Omit `path`
   to use the configured default — the MCP routes production vs the BYO sandbox.)
6. Read the auto `verify_result` (or call `meta_verify_execution`). Report ONLY what it confirms
   (`matches` / `verified`) — never "done" off the submit alone.

**A validated plan** (e.g. "execute plan plan_abc"):

1. Preamble + confirm the target account (as above).
2. `meta_create_plan { action, target_id, payload }` → `plan_id` (state CREATED) — if not already made.
3. `meta_validate_plan { plan_id, account_id:"act_<ID>" }` → VALIDATED + `blast_radius` +
   `approval_token`. (INVALID ⇒ no token; fix + re-validate.)
4. **APPROVAL:** surface the plan + blast radius + the target account → explicit user yes.
5. `meta_execute_plan { plan_id, account_id:"act_<ID>", approval_token, operator_confirmation:true
   [, confirm_destructive:true for a CRITICAL plan] }`. It **re-validates** the plan first, so a plan
   that changed since you minted the token fails `hash_mismatch` → re-validate + re-approve.
6. Verify the primary target; report only the confirmed state.

> Refusal handling: every gate failure is structured (`isError:true` + `error.raw.reason`). Read
> the reason and route per the table in `reference/safety-and-approval.md` — `hash_mismatch` /
> `token_expired` / `token_already_used` mean re-preview + re-approve; `account_mismatch` means the
> token is for a different account (re-preview against this one); `confirm_destructive_required`
> means re-confirm the irreversible change with the user.

---

## Stopping rules
- Stop when you can answer the question — don't run every step reflexively.
- On a `not_entitled`/`insufficient_scope` error, **don't loop**: state what tier/scope is
  needed, surface the upgrade path, and offer a read-only alternative.
- For a **read** workflow (A–E): never end by claiming a change was made — the deliverable is
  analysis + recommendation + a proposed (un-applied) change-set.
- For the **execute** workflow (F): never claim a change landed without `meta_verify_execution`,
  and never execute without a preview/validate token AND an explicit user YES — that handshake +
  human go-ahead is the consent layer.
