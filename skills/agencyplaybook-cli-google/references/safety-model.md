# Safety model — the three-gate write system

Every `mutate` (and write-capable `orchestrate` / `changes apply`) command is **dry-run by
default**. A write only goes to Google when **all three independent gates pass** *and* a
per-customer **profile** or the **sandbox** policy authorizes that specific operation. **There is
no bypass flag** — a guard rejection is the system working; report it, never work around it.

## The three gates

| # | Gate | How to satisfy |
|---|---|---|
| 1 | **CLI** | `--execute` on the command line. Without it the CLI prints the JSON plan it *would* submit and changes nothing. |
| 2 | **Config** | `safety.allow_writes: true` **and** `safety.read_only: false` in `google-ads.yaml`. Shipped default is read-only. |
| 3 | **Env** | When `safety.require_mutation_env: true`: `APB_GADS_ALLOW_MUTATIONS=true` (or `=1`) in the environment. |

**SaaS read-only floor.** In SaaS mode (`APB_API_KEY`), the tenant's resolved write policy is a
ceiling the local config can only *tighten*, never loosen — if your entitlement is read-only,
every execute-mode write is blocked regardless of any local yaml. Writes additionally require the
`write:google:mutations` scope (Agency+ add-on — see `scopes.md`).

## Then: profile OR sandbox must authorize the op

After the three gates, `execute_policy_guard` requires **one** of:

**A per-customer profile** (`safety.profiles[<customer_id>]`), which wins when present:
- `permitted_operations: [...]` — an allowlist of operation slugs.
- `max_budget_micros` — a hard cap on any `amount_micros`.
- `require_confirmation_above_micros` — operations above this need the global **`--confirm`** flag.

**…or the sandbox policy** (the deny-by-default fallback when no profile matches):
- Campaign name must contain the literal `Test-ok-to-delete`.
- Budget must be a positive `$0.01`-multiple at or under the sandbox ceiling (`sandbox_max_budget_micros`, default **$1.00**).
- At most **one** `Test-ok-to-delete` campaign may exist at a time.
- Newly-created ads must be born **PAUSED**.
- **Account-level operations fail closed.** An op with no campaign/ad-group/budget anchor (e.g.
  `customer-negative-criterion-add`, `conversion-action-create`, `shared-set-create`,
  `user-list-create`) can't be proven confined to the sandbox, so it's rejected without a profile.

**Named presets** surface as `active_profile` in guard output so you can see the posture at a
glance: `read_only` → `dry_run_only` → `safe_writes` → `operator_full`.

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
