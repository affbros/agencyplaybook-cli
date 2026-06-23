# Account context — resolve, confirm, and the default-account caveat

The single most common way to give a wrong answer is to read the **wrong account**. These
rules keep you honest. They are about which account the MCP reads — entirely read-only.

## Always resolve + CONFIRM before a costed read

1. **Resolve the hint.** A user says "audit Scandalous" or "act_123". Call
   `meta_resolve_account { hint }`:
   - numeric / `act_<id>` → resolves directly to `act_<digits>`.
   - a name → matched (exact, then substring) against `meta_list_accounts`. One match →
     `resolved:true, id`. Several → `candidates[]` (**ask the user which**). None →
     `reason:"not_found"` (ask for the id; name match only works for accounts whose name is
     known — on the HTTP path that's typically the default account).
2. **Pin it.** `agency_set_context { platform:"meta", account_id }` — or pass `account_id` on
   each read. `agency_set_context` validates against the tenant's `allowed_accounts` (empty =
   allow-all); an unauthorized account → `error.code:"not_authorized"` (context unchanged).
3. **Confirm.** State the account you're about to read ("Reading act_… — scandalouscoffee's
   ad account") and let the user correct you. Never silently assume.
4. **Report what you read.** Every read echoes `account_context`; surface it in the answer.

## The default-account caveat (v1 reality)

The apb-api `reports` / `playbooks` / `verdict` / entity-list paths operate on the **tenant's
resolved/default account** — there is **no per-request account override** in v1. So:

- `account_id` on a read is used to (a) require an explicit operating account and (b) validate
  it — but the **data returned is the tenant default account's**. Each tool says so in its
  `note`. **Trust and surface that note**; don't claim you read an arbitrary non-default
  account.
- True multi-account / per-account targeting is a **later phase** (a known apb-api gap). If
  the user needs account B and the default is A, say so plainly rather than returning A's data
  labeled as B's.

## Single-account vs agency mode

`agency_capabilities` returns two signals:

- **Entitlement (CAN they):** `agency_entitled:true` iff tier ∈ {Agency, Enterprise,
  Free Enterprise}. `google_addon:true` iff a `*:google:*` scope is present.
- **Posture (DO they operate that way):** `account_scope` ∈ {`single`, `agency`}.

**v1 behavior — default to single-account regardless:**
- The agency / multi-account / portfolio tools are a **later phase** and are **not exposed**
  in v1 (no Group L tools registered). `available_tool_groups` reflects exactly what's
  callable — there is no portfolio tool to call.
- So even for an `agency_entitled` + `account_scope:"agency"` tenant, operate one account at a
  time: resolve + pin + read a single account. If the user asks for a portfolio roll-up across
  sub-accounts, explain it's a future capability — don't fake it by reading the default
  account and calling it the portfolio.
- Never claim agency/portfolio behavior the current tool surface can't deliver.

## Quick reference

| Situation | Do |
|---|---|
| User names an account | `meta_resolve_account` → confirm → `agency_set_context` |
| Ambiguous name (`candidates[]`) | Ask the user to pick; don't choose for them |
| Name not found | Ask for the `act_<id>` (non-default names aren't matchable on HTTP) |
| `not_authorized` on set_context | Tell them the account isn't in their allowlist |
| User wants account B but default is A | Read returns A's data — say so; per-account is a later phase |
| User wants a cross-account portfolio | Future capability; operate single-account for now |
