# Anti-patterns — the failure modes to avoid

Each is a real way to give a wrong or unsafe answer. Avoid them.

## 1. Claiming you changed a customer when you only analyzed
During analysis there is no change — never say or imply you paused, scaled, edited, launched, or
budgeted anything. A change only ever happens through the explicit execute handshake.
- ❌ "I paused the three losers and bumped the winner's budget." (when you only ran a verdict)
- ✅ "Verdict: CUT on these three, SCALE on this one. Here's the exact change I'd propose for
  each. To apply any of them: preview → your approval → execute → verify."
- `agency_set_context` changes only the MCP session's selected customer — it touches **no** Google
  account, so using it is not "making a change."

## 1b. Executing without a preview token AND an explicit user YES (the cardinal WRITE sin)
`gads_apply_change` requires a single-use approval token from `gads_preview_change` AND
`operator_confirmation:true` — but the token is a tamper/replay/freshness lock, **not** the human's
consent.
- ❌ Minting a token then immediately executing, without surfacing the change + impact and getting
  the user to say "yes, do it."
- ❌ Reusing/aging a token (single-use, ~10 min — fails `token_already_used` / `token_expired`).
- ✅ preview → SURFACE the exact change + impact + the target customer → GET an explicit YES →
  execute with the fresh token → verify. Full rules: `reference/safety-and-approval.md`.

## 1c. Claiming a write landed without verifying it
A 2xx from the proxy / exit 0 is "submitted", not "applied". The execute tool auto-runs a readback;
trust it, not your intention.
- ❌ "Done — paused." straight off the execute call's submit.
- ✅ Read `verify_result.matches` / `verified` (or call `gads_verify_execution`) and report the
  observed state — "paused, confirmed by readback" or "submitted but readback couldn't confirm".
  (Budget and negative-keyword adds skip the auto by-id readback — confirm on demand.)

## 1d. Writing without surfacing the change + target customer and getting a human YES
The consent layer is the handshake (the token) PLUS your explicit human YES — the binary is a
mechanical executor and never decides whether a write is allowed. Bypassing either is the sin.
- ❌ Executing off a freshly-minted token without naming the exact change + the target customer and
  getting the user's go-ahead. ❌ Treating "I have a valid token" as "I have consent."
- ✅ Always surface { op, entity_id, params (from→to), impact, the customer } and wait for an
  explicit YES before calling `gads_apply_change`. (During development, exercise writes only on a
  sandbox customer by configuring sandbox credentials — a testing discipline, not a code restriction.)

## 1e. Promising one of the 4 deferred managed ops
The managed proxy executes only 5 of the 9 preview ops today. `ad-update-status`,
`keyword-update-match-type`, `keyword-bid-set`, and `criterion-remove` return
`google_managed_op_requires_ad_group` with NO live call.
- ❌ "I updated the keyword's match type." / quietly calling `gads_apply_change` for a deferred op
  and reporting success.
- ✅ Say it isn't executable via the managed path yet (follow-up `fup-014-adgroup-ops`), and offer
  the analysis + a proposed change. You may still PREVIEW it to show the impact — just don't claim
  it ran.

## 2. Guessing the customer
Reading the wrong customer is the most common factual error.
- ❌ Assuming "the account" without resolving it.
- ✅ `gads_resolve_customer` → confirm with the user → `agency_set_context google` (or pass
  `customer_id`). On `candidates[]`, ask which one. Surface the `customer_id` you read.

## 3. Inventing tools, flags, slugs, or reports
The surface is exactly the 14 `gads_*` + the shared `agency_*` tools; audit slugs come from
`agency_list_audits {platform:"google"}`; report names from the catalogue.
- ❌ Calling `gads_pause_campaign`, a "plan execute"/"launch" tool, `gads_run_audit { audit:"spend-
  waste" }` (made-up slug), or `gads_get_performance { report:"last-month" }` (made-up report). The
  ONLY way to mutate is `gads_apply_change` behind the handshake — there is no direct `gads_pause_*`,
  and there is no Google plan-orchestration tool.
- ✅ Use only the registered tools. List audits / use a catalogue report name — an unknown slug
  returns `invalid_audit`, an unknown report `invalid_report`, both without a subprocess. There is no
  CLI flag layer here; you call tools.

## 4. Forgetting micros
Google money is in MICROS verbatim.
- ❌ Reporting `costMicros: 5230000` as "$5,230,000".
- ✅ Divide by 1,000,000 — "$5.23". Same for `amountMicros`, `cpc_bid_micros`, `conversionsValue`.

## 5. Dumping raw JSON
A wall of JSON is not an answer.
- ❌ Pasting every `verdicts[]` / `rows[]` / playbook-finding object.
- ✅ Summarize (distribution, totals, top N by impact); page large results with `agency_get_result`
  instead of forcing everything inline; offer to drill in.

## 6. Looping on an entitlement / scope error
- ❌ Retrying the same call after `not_entitled` / `insufficient_scope`.
- ✅ State what's needed (`google_addon`, `write:google:mutations`, `write_policy`), surface the
  upgrade path, and offer a read-only alternative (an audit/report you *can* run). Branch on the
  error `code`, not the message.

## 7. Misreading an empty verdict / report as "broken" or "all healthy"
- ❌ Concluding "nothing to do" when `gads_get_verdict` returns `campaign_count:0`, or treating an
  empty `gads_get_performance` result as a failure.
- ✅ An active-only window can return `campaign_count:0` — re-run with `include_paused:true`. A short
  window on a paused campaign is legitimately empty — use a `-365d` report. `0` ≠ healthy or broken.

## 8. Running GAQL that isn't a read
`gads_run_gaql` is READ-ONLY (must start with `SELECT`, no mutate token) — a non-SELECT is refused
`invalid_query` pre-spawn.
- ❌ Trying to "UPDATE" or sneak a mutate through GAQL.
- ✅ Use a SELECT for reads; for a change, go through preview → approval → `gads_apply_change`.

## 9. Treating a structured error as a crash
The tools never throw — `{error:{code,…}}` / `isError:true` is normal control flow. Read the code
and route (resolve customer, list audits, re-page, surface upgrade, re-preview on `hash_mismatch`)
rather than reporting "the tool failed."

## 10. Skipping the capability/health preamble on a fresh session
- ❌ Jumping straight to a costed read and getting a confusing failure.
- ✅ `agency_capabilities` (posture + `google_addon`) + `gads_health` (creds resolve) first; then
  resolve + read.

## 11. Confusing this skill with the CLI skill or the Meta brain
- ❌ Emitting `apb-gads …` / `apb …` shell commands; using this for Meta.
- ✅ This brain drives the **MCP `gads_*` tools**. Direct-CLI Google users have
  `agencyplaybook-cli-google`. Meta ad analysis/execution via MCP is the sibling
  `agencyplaybook-meta-brain`.
