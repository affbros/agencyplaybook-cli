# Safety model — the three-gate write system

Every `mutate` (and write-capable `orchestrate` / `changes apply`) command is **dry-run by
default**. Gate 1 (`--execute`) always governs whether anything is submitted at all. **Since
gads-write-gate-portability-001 sprint gw1 (2026-07-01), gates 2–3 (config + env) and the
profile/sandbox authorization step are advisory by default** — the binary tells you what a
stricter local posture would have blocked (via `local_gate_advisories` / `advisories` in the guard
output), but it does not stop the operation from reaching Google. The **SaaS read-only floor**
(below) became conditionally advisory too, as of **sprint gw2 (2026-07-01)** — advisory only in
managed mode when the request is confirmed routed through the server-side proxy, otherwise still a
hard block. See "Opt-in strict mode" below to restore gates 2-3's pre-sprint hard-refusal behavior
(the SaaS floor has its own, separate discriminator — `enforce_local_gates` never touches it).
**There is no bypass flag for gate 1, and no *operator-settable* bypass for the SaaS floor** — a
floor rejection is the system working; report it, never work around it.

## The three gates

| # | Gate | How to satisfy | Enforcement |
|---|---|---|---|
| 1 | **CLI** | `--execute` on the command line. Without it the CLI prints the JSON plan it *would* submit and changes nothing. | **Always enforced** — dry-run is a preview, not authorization. |
| 2 | **Config** | `safety.allow_writes: true` **and** `safety.read_only: false` in `google-ads.yaml`. Shipped default is read-only. | **Advisory by default** (sprint gw1) — a failing check is reported in `local_gate_advisories`, not blocked. |
| 3 | **Env** | When `safety.require_mutation_env: true`: `APB_GADS_ALLOW_MUTATIONS=true` (or `=1`) in the environment. | **Advisory by default** (sprint gw1) — same as gate 2. |

Set `safety.enforce_local_gates: true` to restore the pre-sprint hard block on gates 2–3 (see
"Opt-in strict mode" below).

**SaaS read-only floor — advisory only when a server-side proxy re-check exists (sprint gw2).** In
SaaS mode (`APB_API_KEY`), the tenant's resolved write policy is a ceiling the local config can
only *tighten*, never loosen. In BYO mode, or any managed-mode resolve where the proxy routing
didn't actually apply, a read-only entitlement still hard-blocks every execute-mode write — there's
no local opt-out (`enforce_local_gates` doesn't reach this check), because nothing else re-checks
policy for that request. In managed mode, once the request is confirmed routed through the apb-api
Google proxy, the same read-only entitlement is reported as an advisory instead and the binary lets
the write proceed — the proxy independently re-checks `write_policy` server-side, with a fresh DB
read, before it ever calls Google, so a Starter/read-only tenant is still refused, just at the
proxy instead of the binary. Writes additionally require the `write:google:mutations` scope
(Professional+ add-on — see `scopes.md`).

## Then: profile OR sandbox authorization (advisory by default since sprint gw1)

After the gates, `execute_policy_guard` looks at **one** of:

**A per-customer profile** (`safety.profiles[<customer_id>]`), which wins when present:
- `permitted_operations: [...]` — an allowlist of operation slugs.
- `max_budget_micros` — a cap on any `amount_micros`.
- `require_confirmation_above_micros` — operations above this normally need the global **`--confirm`** flag.

**…or the sandbox policy** (the fallback when no profile matches):
- Campaign name must contain the literal `Test-ok-to-delete`.
- Budget must be a positive `$0.01`-multiple at or under the sandbox ceiling (`sandbox_max_budget_micros`, default **$1.00**).
- At most **one** `Test-ok-to-delete` campaign may exist at a time.
- Newly-created ads must be born **PAUSED**.
- Account-level operations (no campaign/ad-group/budget anchor — e.g. `customer-negative-criterion-add`,
  `conversion-action-create`, `shared-set-create`, `user-list-create`) can't be proven confined to the sandbox.

**Since sprint gw1, none of the checks above block the operation by default.** A failing check
surfaces its message in the response's `advisories` array (profile/sandbox branch) or
`local_gate_advisories` (gates 2–3) — the operation still proceeds to Google, subject only to gate
1 and the SaaS read-only floor. This is intentional: consent and authority belong at the MCP
handshake + Skill + the server/proxy, not in a locally-editable config file. Treat the advisories
as diagnostic — they tell you what a stricter local posture would have flagged, not a rejection.

## Opt-in strict mode: `safety.enforce_local_gates: true`

Set this in `google-ads.yaml` if you want the pre-sprint-gw1 hard-refusal behavior back, as a
local safety net layered on top of the SaaS floor — every check above (gates 2–3, the profile
allowlist/budget/confirmation checks, and the sandbox checks including the account-level-op
denial) reverts to blocking with the exact same error messages as before sprint gw1. Default is
`false` (advisory).

```yaml
safety:
  enforce_local_gates: true
```

**Named presets** surface as `active_profile` in guard output so you can see the posture at a
glance: `read_only` → `dry_run_only` → `safe_writes` → `operator_full`. (Display-only — it never
gates anything itself, regardless of `enforce_local_gates`.)

## Capability tiers — how strongly a write has been proven

| Tier | Meaning | How to invoke |
|---|---|---|
| **DRY_RUN** | Local validators run; **no API call**. The default for every `mutate`. | (omit `--execute`) |
| **SERVER_VALIDATED** | Google validates the full request body server-side (`validateOnly=true`) — schema + policy + auth — and **creates nothing**. | `--execute --validate-only` (+ env gate) |
| **LIVE_VERIFIED** | Real entities created via a `verify` chain (PREFLIGHT→CREATE→VERIFY→CLEANUP→POSTCHECK), read back, then atomically cleaned up and ledger-recorded. | `verify search-lifecycle` / `verify rsa-lifecycle` / `verify pmax-launch` |

`--validate-only` is the safest way to prove a new payload shape on a real account before
proposing the write. See `capability-matrix.md` for which surfaces are proven at which tier.

## `verify` chains — a stricter envelope

The `verify` group writes real entities under the `LiveVerifyPolicy` (separate from the $1
sandbox): a **$5/day** cap, a required name substring (default `"test"`), USA-only geo, and an
explicit **customer + domain allowlist**. It **fails closed** — an empty allowlist rejects
everything. Use it to prove a full create→readback→cleanup lifecycle; it never falls through to
the sandbox.

## Audit trail

Every **execute-mode** mutation appends one line to `audit.jsonl` (next to the config by default).
Dry-run and blocked attempts are **not** logged. Inspect with `audit list` / `audit get <id>`;
build a rollback with `mutate inverse-plan` (inverts CREATE and UPDATE verbs; REMOVE is terminal)
or `changes rollback --audit-id <id>`.

## Exit codes (branch on these, not stdout text)

| Code | Meaning |
|---|---|
| `0` | success / a `pass` verdict |
| `1` | runtime / IO error |
| `2` | clap usage error (bad flags) |
| `3` | a **validation `fail`** verdict from `validate campaign-spec`, `validate pmax-spec`, or `mutate ad-validate` (the JSON report is still printed) |

So `apb-gads validate campaign-spec --from-file s.json && apb-gads orchestrate campaign-launch --from-file s.json` halts before launch on a bad spec. More in `automation.md`.
