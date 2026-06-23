# Anti-patterns — the failure modes to avoid

Each is a real way to give a wrong or unsafe answer. Avoid them.

## 1. Claiming you changed an account when you only analyzed
During analysis there is no change — never say or imply you paused, scaled, edited, launched, or
budgeted anything. A change only ever happens through the explicit execute handshake (Workflow F).
- ❌ "I paused the three losers and bumped the winner's budget." (when you only ran a verdict)
- ✅ "Verdict: CUT on these three, SCALE on this one. Here's the exact change I'd propose for
  each. To apply any of them: preview → your approval → execute → verify."
- `agency_set_context` changes only the MCP session's selected account — it touches **no** ad
  account, so using it is not "making a change."

## 1b. Executing without preview/validate AND an explicit user YES (the cardinal WRITE sin)
The write tools (`meta_apply_change` / `meta_execute_plan`) require a single-use approval token
from `meta_preview_change` / `meta_validate_plan` AND `operator_confirmation:true` — but the
token is a tamper/replay/freshness lock, **not** the human's consent.
- ❌ Minting a token then immediately executing, without surfacing the change-set + impact and
  getting the user to say "yes, do it."
- ❌ Reusing/aging a token (single-use, ~10 min — fails `token_already_used` / `token_expired`).
- ✅ preview/validate → SURFACE the exact change-set + impact + the target account → GET an
  explicit YES → execute with the fresh token → verify. Full rules: `reference/safety-and-approval.md`.

## 1c. Claiming a write landed without verifying it
"Submitted" ≠ "applied". The execute tools auto-run a readback; trust it, not your intention.
- ❌ "Done — paused." straight off the execute call's submit.
- ✅ Read `verify_result.matches` / `verified` (or call `meta_verify_execution`) and report the
  observed state — "paused, confirmed by readback" or "submitted but readback couldn't confirm".

## 1d. Writing without surfacing the change-set + target account and getting a human YES
The consent layer is the handshake (the token) PLUS your explicit human YES — the binary is a
mechanical executor and never decides whether a write is allowed. Bypassing either is the sin.
- ❌ Executing off a freshly-minted token without naming the exact change + the target account and
  getting the user's go-ahead. ❌ Treating "I have a valid token" as "I have consent."
- ✅ Always surface { entity, field, from→to, impact, the account } and wait for an explicit YES
  before calling an execute tool. (During development, exercise writes only on a sandbox account by
  configuring sandbox credentials — a testing discipline, not a code restriction.)

## 2. Guessing the account
Reading the wrong account is the most common factual error.
- ❌ Assuming "the account" without resolving it.
- ✅ `meta_resolve_account` → confirm with the user → `agency_set_context` (or pass
  `account_id`). On `candidates[]`, ask which one. Surface the `account_context` you read.

## 3. Inventing tools, flags, or slugs
The surface is exactly the 23 tools (+3 Group L when agency-entitled); audit slugs come from
`agency_list_audits`.
- ❌ Calling `meta_pause_campaign`, `meta_update_budget`, or
  `meta_run_audit { audit:"spend-waste" }` (made-up slug). The ONLY way to mutate is
  `meta_apply_change` / `meta_execute_plan` behind the handshake — there is no direct
  `meta_pause_*`. (The portfolio roll-up IS a real tool — `agency_get_portfolio` — but only
  when the tenant is agency-entitled; don't reach for it otherwise.)
- ✅ Use only the listed tools. List audits first and pick a real slug — an unknown slug returns
  `invalid_audit` and wastes a turn. There is no CLI flag layer here; you call tools.

## 4. Dumping raw JSON
A wall of JSON is not an answer.
- ❌ Pasting every `verdicts[]` / `rows[]` / `findings[]` object.
- ✅ Summarize (distribution, totals, top N by impact); page large results with
  `agency_get_result` instead of forcing everything inline; offer to drill in.

## 5. Looping on an entitlement / scope error
- ❌ Retrying the same call after `not_entitled` / `insufficient_scope`.
- ✅ State what tier/scope is required, surface the upgrade path, and offer a read-only
  alternative (an audit/report you *can* run). Branch on the error `code`, not the message.

## 6. Reaching for agency / multi-account behavior v1 can't do
- ❌ Promising a cross-account portfolio roll-up, or reading the default account and labeling
  it "the portfolio."
- ✅ Default to single-account. `available_tool_groups` is the callable truth — there's no
  portfolio tool in v1. If asked, say multi-account is a later phase and operate one account.

## 7. Misreading an empty verdict as "broken" or "all healthy"
- ❌ Concluding "nothing to do" when `meta_get_verdict` returns `campaign_count:0`.
- ✅ That usually means you ran active-only — re-run with `include_paused:true`. `0` active
  campaigns in window ≠ a healthy or broken account.

## 8. Trusting a non-default account read
- ❌ Reporting the default account's numbers as if they were account B's.
- ✅ The reports/playbooks/verdict/entity paths read the tenant **default** account in v1
  (each tool says so in its `note`). Surface that; don't over-claim per-account targeting.

## 9. Treating a structured error as a crash
The tools never throw — `{error:{code,…}}` / `isError:true` is normal control flow. Read the
code and route (resolve account, list audits, re-page, surface upgrade) rather than reporting
"the tool failed."

## 10. Skipping the capability/health preamble on a fresh session
- ❌ Jumping straight to a costed read and getting a confusing failure.
- ✅ `agency_capabilities` (mode) + `meta_health` (`token_valid`) first; then resolve + read.

## 11. Confusing this skill with the CLI skills
- ❌ Emitting `apb …` / `apb-gads …` shell commands.
- ✅ This brain drives the **MCP tools**. Direct-CLI users have `agencyplaybook-cli` (Meta) /
  `agencyplaybook-cli-google` (Google). Google ad analysis via MCP is the sibling
  `agencyplaybook-google-ads-brain`.
