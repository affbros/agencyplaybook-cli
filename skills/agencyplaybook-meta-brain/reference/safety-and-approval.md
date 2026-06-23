# Safety & approval — the execution handshake (read before any write)

Analysis is read-only. **Execution writes to the account you operate on, and is gated by a
cryptographic approval handshake plus your explicit human YES.** Consent lives in exactly two
places: the handshake (the single-use token enforces "the approved change to the approved account")
and the human go-ahead — **never in the binary, which is a mechanical executor.** This file is the
authoritative reference for that path: the sequence, the two flavours (single change vs plan), every
refusal reason, and the non-negotiables. If you are only analyzing, you never touch any of this.

## The two write tools

| Tool | What it does | Token comes from |
|---|---|---|
| `meta_apply_change` | applies ONE bounded change: `pause` · `resume` · `enable` · `set_status` · `set_budget` · `update_budget` · `archive` · `delete` to one campaign/adset/ad | `meta_preview_change` |
| `meta_execute_plan` | runs a VALIDATED apb-api plan (can be a multi-step mutation; blast_radius 0–5) | `meta_validate_plan` |

Both are `destructiveHint:true`. Both apply to the account you operate on, and both require the
single-use, account-bound approval token + `operator_confirmation:true` (the human YES) before they
touch anything.

## The mandatory sequence (never skip, never reorder)

```
1. analysis            read/audit/verdict → decide the precise change
2. preview / validate  meta_preview_change (one change)  OR  meta_create_plan → meta_validate_plan
                       · this MINTS a single-use approval_token bound to {the exact change-set,
                         the account, platform "meta", a ~10-min expiry}. It changes NOTHING and
                         sends NO execute. The token embeds only a HASH — no secret.
3. APPROVAL (human)    surface to the user: the EXACT change-set (entity, field, from→to), the
                       projected impact + blast radius, and the account it targets.
                       Get an explicit "yes, do it" for THAT exact change. ← mandatory, every time.
4. execute             meta_apply_change / meta_execute_plan with:
                         { ...the change / plan_id..., approval_token,
                           operator_confirmation: true,
                           confirm_destructive: true   // ONLY for an L4 op (see below)
                           path: "http" (production) | "subprocess" (BYO sandbox)  // omit for default }
5. verify              meta_verify_execution (or trust the auto-verify the execute tool runs):
                       report ONLY what the readback confirms — `verified` / `matches`.
```

### Single change (worked example — pause a campaign)

1. `meta_preview_change { account_id:"act_<ID>", change:{ op:"pause", target_id:"120…", target_type:"campaign" } }`
   → returns `{ preview, impact, approval_token, change_set_hash, expires_at }`. Nothing changed.
2. Tell the user: *"This will PAUSE campaign 120… on account act_<ID> (reversible, MODERATE).
   Approve?"* — wait for an explicit yes.
3. `meta_apply_change { account_id:"act_<ID>", change:{ op:"pause", target_id:"120…", target_type:"campaign" }, approval_token:"<from step 1>", operator_confirmation:true }`
   — the change **must be byte-identical** to what you previewed (else `hash_mismatch`).
4. Read `verify_result.matches` (the tool auto-verifies). Report "paused — confirmed" only if true.

### Plan (worked example — execute a validated plan)

1. `meta_create_plan { action:"campaign.update-status", target_id:"120…", payload:{ status:"PAUSED" } }` → `plan_id`, state CREATED.
2. `meta_validate_plan { plan_id, account_id:"act_<ID>" }` → state VALIDATED + `blast_radius` + `approval_token`. (An INVALID plan mints NO token — fix it and re-validate.)
3. Surface the plan + blast radius + the target account → get an explicit user YES.
4. `meta_execute_plan { plan_id, account_id:"act_<ID>", approval_token, operator_confirmation:true [, confirm_destructive:true] }`.
   - The tool **re-validates the plan first**, so if the plan changed since you minted the token the
     hash differs → `hash_mismatch` (re-validate + re-approve). This is the freshness guarantee.
5. Verify the primary target.

## L4 (destructive) — needs `confirm_destructive:true`

A change/plan is **L4 destructive** when it is: `delete`, `archive`, sets budget to **$0**, or
raises budget **>200%** (a plan reports this as a **CRITICAL** / blast score ≥ 4 blast_radius).
For L4 you must pass BOTH `operator_confirmation:true` AND `confirm_destructive:true`, and your
user-facing approval ask must call out the irreversibility (delete is terminal and cascades to
children; archive halts delivery). Without `confirm_destructive` the tool refuses
`confirm_destructive_required` — surface that and re-confirm with the user before retrying.

## The consent guarantee (handshake + human YES — there is no account fence)

The product has **no write-protection / account-allowlist in the code.** What keeps a write safe is
the consent layer, in two parts:

1. **The handshake** — the approval token is single-use, ~10-min, hash-bound to the EXACT change,
   and bound to the approved account. So the binary can only ever apply *the change that was
   previewed and approved, to the account it was approved for*. A different change, a changed plan,
   a different account, a reused/expired token → auto-refused. This is the cryptographic interlock.
2. **Your explicit human YES** — the token is a tamper/replay/freshness lock, NOT consent. You must
   surface the exact change-set + impact + the target account and get the person's go-ahead, every
   time. The binary is a mechanical executor; it does not decide whether a write is allowed — you and
   the handshake do.

**Credential routing (not a restriction).** The `path` selects HOW the write is delivered, not WHETHER
it is allowed: `http` goes through the production API to the account you operate on; `subprocess` goes
through the BYO sandbox path. The MCP picks the default from configuration (a configured BYO Meta
write env ⇒ the sandbox subprocess; otherwise the production API). Either way the write targets the
account you operate on, and either way it is gated by the same handshake + human YES.

**Testing discipline (development).** While building the product, we exercise writes only on a
sandbox account by configuring sandbox credentials — so a test write physically reaches only the
sandbox. That is a *convention we follow during development*, not a code fence. In production the
write goes to the live account; the safety guarantee on every account is the handshake + the human
YES, never an allowlist.

## Every refusal reason (read the `code` / `raw.reason`, not the prose)

The write tools never throw — a refusal is `isError:true` + a structured error. Branch on it:

| `raw.reason` / `error.code` | Meaning | What to do |
|---|---|---|
| `not_found` (on execute_plan) | the plan id doesn't exist at re-validate | re-create the plan; check the id |
| `plan_not_validated` | the plan isn't VALIDATED (INVALID / other state) | fix the plan, `meta_validate_plan` until VALIDATED, re-approve |
| `malformed_token` | token isn't a well-formed `<payload>.<sig>` | re-run preview/validate to mint a fresh one |
| `bad_signature` | token tampered or wrong server secret | re-mint via preview/validate |
| `token_expired` | older than ~10 min | re-mint (and re-confirm with the user) |
| `token_already_used` | single-use token replayed | re-mint; never reuse a token |
| `platform_mismatch` | token bound to a different platform | mint on Meta (this tool) |
| `account_mismatch` | token bound to a different account | preview/validate against THIS account |
| `hash_mismatch` | submitted change ≠ previewed change, OR the plan changed since mint | re-preview/re-validate the EXACT thing, re-approve |
| `operator_confirmation_required` | you didn't pass `operator_confirmation:true` | get the user's YES, pass it |
| `confirm_destructive_required` | L4 op without `confirm_destructive:true` | re-confirm the irreversible change, pass it |
| `upstream_error` / `config_error` (on submit) | apb / apb-api reported a failure AFTER the gates | no change landed (readback skipped); surface the message |

## Non-negotiables (the doctrine)

1. **Preview/validate + an explicit human YES are BOTH required before execute.** The token is not
   consent — it is a tamper/replay/freshness lock. You still ask the person. This is the consent
   layer; the binary is a mechanical executor and never decides whether a write is allowed.
2. **"Submitted" is not "applied."** Never report a write as done without `meta_verify_execution`
   (or the execute tool's auto-`verify_result`). Report the observed state, not your intent.
3. **Target the account deliberately.** The write goes to the account you operate on; the token is
   account-bound (a mismatch is auto-refused `account_mismatch`), but name the account in your
   approval ask and never guess it.
4. **Preview the EXACT change you'll execute.** A different op / id / budget / a changed plan all
   fail `hash_mismatch` by design — so build the change once and reuse it verbatim.
5. **One change, one token.** Tokens are single-use and ~10 min. Mint fresh per execution.
6. **Surface the target account + the impact honestly** in your approval ask so the user's YES is
   informed. (During development, writes are exercised only on a sandbox account by configuring
   sandbox credentials — a testing discipline, not a code restriction.)
