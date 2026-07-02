# Customer context — resolve, confirm, and the MCC caveat

The single most common way to give a wrong answer is to read the **wrong customer**. These rules
keep you honest. They are about which customer the MCP reads — entirely read-only.

## Always resolve + CONFIRM before a costed read

1. **Resolve the hint.** A user says "audit Scandalous" or "1234567890". Call
   `gads_resolve_customer { hint }`:
   - numeric / `customers/<id>` → resolves directly to a bare numeric `customer_id` (no subprocess).
   - a name → matched (case-insensitive; exact then substring) against `gads_list_customers`. One
     match → `{ resolved:true, customer_id }`. Several → `candidates[]` (**ask the user which**).
     None → `reason:"not_found"` (ask for the numeric id).
2. **Pin it.** `agency_set_context { platform:"google", account_id:<customer_id> }` — or pass
   `customer_id` on each read. `agency_set_context` validates against the tenant's
   `allowed_accounts` (empty = allow-all); an unauthorized customer → `error.code:"not_authorized"`
   (context unchanged).
3. **Confirm.** State the customer you're about to read ("Reading customer 1234567890 —
   Scandalous") and let the user correct you. Never silently assume.
4. **Report what you read.** Every read echoes `customer_id`; surface it in the answer.

## Customer-context resolution order (every customer-scoped tool)

`customer_id` arg → the active pinned session customer (`agency_set_context google`) → a structured
`no_customer_context` error. So either pin a customer first, or pass `customer_id` on each call. If
you get `no_customer_context`, resolve + pin (or pass the id) — don't retry blindly.

## MCC vs child customers

`gads_list_customers` returns every customer under the login MCC. Read the rows:

- `level 0` + `manager:true` is the **login MCC** (`login_customer_id`) — surfaced as `mcc`. The MCC
  is **never switched** by these tools; you operate on a CHILD customer, selected via `--customer`
  (the numeric `id`).
- A child customer is what you pin and read/report/write against. When the user names a brand,
  resolve it to the child's numeric id — don't operate on the MCC.
- If the user wants a cross-account / portfolio roll-up across many children, that's a separate
  capability — operate one customer at a time here and say so rather than faking a portfolio.

## Entitlement signals (`agency_capabilities` / `agency_get_context`)

- **`google_addon`** (bool): the paid Google add-on. It gates the `write:google:*` scopes. A tenant
  without it can still READ (reads normalize a missing scope), but `gads_apply_change` will be
  refused `insufficient_scope` / `not_entitled` at the proxy — surface the upgrade path.
- **`write_policy`** (on `agency_get_context.entitlement`): the Google-write floor. `ReadOnly` blocks
  every write regardless of tier — name it if a write is refused.
- `agency_entitled` + `account_scope` describe agency posture; `available_tool_groups` is the
  authoritative callable set.

## Quick reference

| Situation | Do |
|---|---|
| User names a customer | `gads_resolve_customer` → confirm → `agency_set_context google` |
| Ambiguous name (`candidates[]`) | Ask the user to pick; don't choose for them |
| Name not found | Ask for the numeric `customer_id` (see `gads_list_customers`) |
| `no_customer_context` on a read | Pin a customer (or pass `customer_id`); don't retry blindly |
| `not_authorized` on set_context | Tell them the customer isn't in their allowlist |
| User wants a cross-account portfolio | Operate single-customer for now; say a roll-up is separate |
| A write is refused `not_entitled` | Surface `google_addon` / `write_policy` upgrade path; offer a read alternative |
