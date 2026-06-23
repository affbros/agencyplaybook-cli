# Safety & approval — the Google execution handshake (read before any write)

Analysis is read-only. **Execution writes to the customer you operate on, and is gated by a
cryptographic approval handshake plus your explicit human YES.** Consent lives in exactly two
places: the handshake (the single-use token enforces "the approved change to the approved
customer") and the human go-ahead — **never in the binary, which is a mechanical executor.** This
file is the authoritative reference for that path: the sequence, the managed write surface (5 live /
4 deferred), every refusal reason, and the non-negotiables. If you are only analyzing, you never
touch any of this.

## The one write tool

| Tool | What it does | Token comes from |
|---|---|---|
| `gads_apply_change` | applies ONE bounded Google change (the 9 preview ops; 5 executable today) to one campaign / criterion / budget | `gads_preview_change` |

It is `destructiveHint:true`. It applies to the customer you operate on, and requires the single-use,
customer-bound approval token + `operator_confirmation:true` (the human YES) before it touches
anything. **There is no Google plan-orchestration / multi-step execute tool** in this surface
(the gads side has no plan state machine; the token is the interlock) — do not invent one.

## The mandatory sequence (never skip, never reorder)

```
1. analysis           read/audit/verdict → decide the precise change
2. preview            gads_preview_change { customer_id, change:{ op, entity_id, params } }
                      · runs `mutate <op>` WITHOUT --execute → short-circuits before any write
                        gate (guard.allowed:false, status:"dry-run-only", exit 0, nothing changes)
                      · MINTS a single-use approval_token bound to {the exact change-set hash,
                        the customer, platform "google", a ~10-min expiry}. The token embeds only
                        a HASH — no secret.
3. APPROVAL (human)   surface to the user: the EXACT change (op, entity_id, params, from→to),
                      whether it's destructive, and the customer it targets.
                      Get an explicit "yes, do it" for THAT exact change. ← mandatory, every time.
4. execute            gads_apply_change with:
                        { change:{ …byte-identical to step 2… }, approval_token,
                          operator_confirmation: true,
                          confirm_destructive: true   // ONLY for an L4 op (see below) }
5. verify             gads_verify_execution (or trust the auto-verify gads_apply_change runs):
                      report ONLY what the readback confirms — `verified` / `matches`.
```

### Worked example — pause a campaign

1. `gads_preview_change { customer_id:"6523096952", change:{ op:"campaign-update-status",
   entity_id:"21869030350", params:{ status:"PAUSED" } } }` → `{ preview, guard, approval_token,
   change_set_hash, expires_at }`. Nothing changed.
2. Tell the user: *"This will PAUSE campaign 21869030350 on customer 6523096952 (reversible).
   Approve?"* — wait for an explicit yes.
3. `gads_apply_change { customer_id:"6523096952", change:{ op:"campaign-update-status",
   entity_id:"21869030350", params:{ status:"PAUSED" } }, approval_token:"<from step 1>",
   operator_confirmation:true }` — the change **must be byte-identical** to the preview (else
   `hash_mismatch`).
4. Read `verify_result.matches` (the tool auto-verifies). Report "paused — confirmed" only if true.

## L4 (destructive) — needs `confirm_destructive:true`

A change is **L4 destructive** when it is: `criterion-remove`, a status set to **REMOVED**, a
**bidding-strategy swap** (`campaign-update-bidding-strategy`), a budget set to **$0**, or a budget
raised **>200%**. For L4 you must pass BOTH `operator_confirmation:true` AND `confirm_destructive:
true`, and your user-facing approval ask must call out the irreversibility. Without
`confirm_destructive` the tool refuses `confirm_destructive_required` — surface that and re-confirm
with the user before retrying.

## The managed write surface — 5 live, 4 deferred (be honest)

`gads_apply_change`'s production path is the **apb-api `/google` managed-write proxy**: it POSTs a
`googleAds:mutate` operation under the approval token; the entitlement (`write:google:mutations`
scope + `write_policy`) is gated **at the proxy**, not in the binary. The REST body is a pure
function of the approved canonical change, so the executed mutation == the change you approved.

**Live today (5 — the resourceName is fully determined by the hashed canonical descriptor):**

| Op | What it does |
|---|---|
| `campaign-update-status` | pause / enable / set a campaign's status |
| `campaign-budget-update` | set a campaign budget's `amount_micros` |
| `campaign-update-bidding-strategy` | swap the campaign's bidding strategy (L4) |
| `negative-keyword-add` | add an ad-group negative keyword |
| `campaign-negative-keyword-add` | add a campaign-level negative keyword |

**Deferred / refuse today (4 — `fup-014-adgroup-ops`):** `ad-update-status`,
`keyword-update-match-type`, `keyword-bid-set`, `criterion-remove`. These need an `ad_group_id` the
bounded change surface doesn't collect yet (their Google `resourceName` is `adGroupCriteria/{ag}~{crit}`
or `adGroupAds/{ag}~{ad}`). The managed path returns a structured `validation_failed` refusal
(`raw.reason="google_managed_op_requires_ad_group"`) with **NO live call**. If a user asks for one:
say plainly it isn't executable via the managed path yet, name the follow-up, and offer the
analysis + a proposed change instead — never imply it ran.

> `gads_preview_change` will happily preview all 9 ops (the dry-run mints a token for any of them).
> The 5/4 split is enforced at execute time on the managed path — so preview a deferred op if you
> like, but tell the user upfront it can't be applied yet, and don't call `gads_apply_change` for it
> expecting a write.

## The consent guarantee (handshake + human YES — there is no account fence)

The product has **no write-protection / customer-allowlist in the code.** What keeps a write safe is
the consent layer, in two parts:

1. **The handshake** — the approval token is single-use, ~10-min, hash-bound to the EXACT change,
   and bound to the approved customer. So the binary can only ever apply *the change that was
   previewed and approved, to the customer it was approved for*. A different change, a different
   customer, a reused/expired token → auto-refused. This is the cryptographic interlock.
2. **Your explicit human YES** — the token is a tamper/replay/freshness lock, NOT consent. You must
   surface the exact change + impact + the target customer and get the person's go-ahead, every
   time. The binary is a mechanical executor; it does not decide whether a write is allowed — you
   and the handshake do.

**Credential routing (not a restriction).** The path selects HOW the write is delivered, not WHETHER
it is allowed: with no BYO yaml the write goes through the production apb-api `/google` proxy to the
customer you operate on; with a configured BYO Google-Ads write yaml it goes through the gads
subprocess `--execute` (the sandbox test path). Either way the write targets the customer you
operate on, and either way it is gated by the same handshake + human YES + the proxy's entitlement.

**Testing discipline (development).** While building the product, we exercise writes only on a
sandbox customer by configuring sandbox credentials (a BYO write yaml + a $1 budget ceiling on that
path) — so a test write physically reaches only the sandbox. That is a *convention we follow during
development*, not a code fence. In production the write goes to the live customer; the safety
guarantee on every customer is the handshake + the human YES, never an allowlist.

## Every refusal reason (read the `code` / `raw.reason` / `raw.approval_reason`, not the prose)

`gads_apply_change` never throws — a refusal is `isError:true` + a structured error. Branch on it:

| `raw.approval_reason` / `raw.reason` / `error.code` | Meaning | What to do |
|---|---|---|
| `malformed_token` | token isn't a well-formed `<payload>.<sig>` | re-run `gads_preview_change` |
| `bad_signature` | token tampered or wrong server secret | re-preview to mint a valid one |
| `token_expired` | older than ~10 min | re-preview (and re-confirm with the user) |
| `token_already_used` | single-use token replayed | re-preview; never reuse a token |
| `platform_mismatch` | token bound to a different platform | preview on Google (this tool) |
| `account_mismatch` | token bound to a different customer | preview against THIS customer |
| `hash_mismatch` | submitted change ≠ previewed change | re-preview the EXACT change, re-approve |
| `operator_confirmation_required` | you didn't pass `operator_confirmation:true` | get the user's YES, pass it |
| `confirm_destructive_required` | L4 op without `confirm_destructive:true` | re-confirm the irreversible change, pass it |
| `sandbox_budget_exceeded` | a BYO-sandbox budget op above the $1 ceiling | lower `amount_micros` ≤ 1,000,000 when testing on the sandbox |
| `google_managed_op_requires_ad_group` | one of the 4 deferred ops on the managed path | not executable via managed write yet (`fup-014-adgroup-ops`) — propose the change, don't claim it ran |
| `insufficient_scope` / `not_entitled` | missing `write:google:mutations` scope / `write_policy` / `google_addon` | surface the upgrade path; offer a read-only alternative; don't loop |
| `upstream_error` / `config_error` | apb-gads / proxy reported a failure AFTER the gates | no change landed (readback skipped); surface the message |

## Non-negotiables (the doctrine)

1. **Preview + an explicit human YES are BOTH required before execute.** The token is not consent —
   it is a tamper/replay/freshness lock. You still ask the person. This is the consent layer; the
   binary is a mechanical executor and never decides whether a write is allowed.
2. **"Submitted" is not "applied."** Never report a write as done without `gads_verify_execution`
   (or the execute tool's auto-`verify_result`). Report the observed state, not your intent. (Budget
   and negative-keyword adds skip the auto by-id readback — confirm on demand.)
3. **Target the customer deliberately.** The write goes to the customer you operate on; the token is
   customer-bound (a mismatch is auto-refused `account_mismatch`), but name the customer in your
   approval ask and never guess it.
4. **Preview the EXACT change you'll execute.** A different op / id / params all fail `hash_mismatch`
   by design — so build the change once and reuse it verbatim.
5. **One change, one token.** Tokens are single-use and ~10 min. Mint fresh per execution.
6. **Be honest about the deferred 4.** If the user wants `ad-update-status` /
   `keyword-update-match-type` / `keyword-bid-set` / `criterion-remove`, say it can't run via the
   managed path yet — don't claim it ran. (During development, writes are exercised only on a sandbox
   customer by configuring sandbox credentials — a testing discipline, not a code restriction.)
