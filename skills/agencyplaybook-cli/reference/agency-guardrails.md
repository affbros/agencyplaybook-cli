# Agency guardrails — safe multi-client operation

When you (or an AI agent) drive `apb` across **more than one client account**, the
risk is not a bad change — it's the *wrong* change on the *wrong* client: a campaign
pointed at the wrong landing page, the wrong brand in the copy, a 10× budget, or an
edit applied to Client B while you thought you were on Client A. This doctrine keeps
agency work safe.

The `apb` CLI now **enforces** a per-account guardrail profile locally on write commands
(see **The guardrail profile** below). It is mistake-prevention for trusted operators +
AI agents, not an adversarial boundary — a stated, logged override is always available.
Treat the rules below as mandatory operating procedure whether or not a profile is set.

## The two dials — match friction to blast radius

1. **Plan ceremony** is for *creating* and *destroying*, not for tweaking.
   - **Creating a campaign / ad set / ad, duplicating, or anything destructive** → build a **plan** first: `apb plan create …` → review → `apb plan execute …`. Never one-shot `--execute` a brand-new campaign.
   - **Small edits to an existing campaign** (budget nudge, pause/resume, targeting tweak; blast radius ≤ 3) → direct `--execute` is fine. Don't over-ceremony routine edits.
2. **Content validation** is *always on*, regardless of plan vs direct. Before any write that sets a URL, brand, or budget, check it against the client (below).

## Before every write — the 4 checks

- **Right account.** Confirm the target account is the intended client. The bare `apb …` resolves the key's default/discovered account — for agency work pass `--account act_<id>` explicitly, and run `apb meta cache --clear` after switching so a stale discovery can't mis-target.
- **Domain.** Every `--link` / final URL must be on the client's own domain (eTLD+1). A landing page on the wrong client's site — or a placeholder/typo'd domain — is the classic agency disaster.
- **Brand.** Ad copy (headline / primary text / name) must carry the client's brand and must NOT name a competitor or another client.
- **Budget.** Sanity-check the amount and currency against the account's norm before `--execute`.

## The guardrail profile — author it once, enforce automatically

Store a per-account profile in `~/.apb/guardrails.json` and the CLI checks every
guarded write against it. The checks map 1:1 to the four checks above (domain, brand,
budget; the account boundary stays server-side and is never overridable).

```bash
# Author / update a client's profile (re-run to change fields; partial updates merge):
apb guardrails set --account act_123 \
  --allowed-domains "client.com,shop.client.com" \
  --canonical-brands "ClientCo" \
  --blocked-terms "competitor,placeholder" \
  --max-daily-budget 500 --currency USD \
  --enforcement block          # block (default) | warn | off

apb guardrails show --account act_123      # resolved profile (file + ENV + flags)
apb guardrails test --account act_123 \    # dry-check a hypothetical write — no API call
  --link https://wrong.com/lp --copy "Buy now" --budget 9000
apb guardrails clear --account act_123     # remove the profile
```

**What's enforced, and when.** On a real write (`--execute`) to `creative create-*`,
`adset create` / `update-budget`, and `campaign create` / `update` / `compose-from-spec`,
the CLI extracts the final URLs, copy, and daily budget and checks them:
- **`block`** (default) → the write is refused with **exit code 4** before any Meta call.
- **`warn`** → the violations print to stderr and the write proceeds.
- **`off`** → no enforcement.
- **No profile for the account** → nothing is enforced (backward compatible).

Precedence (highest first): `--guardrails on|warn|off` flag → `APB_GUARDRAIL_*` env →
`~/.apb/guardrails.json` → none. The env keys are `APB_GUARDRAIL_ALLOWED_DOMAINS`,
`APB_GUARDRAIL_CANONICAL_BRANDS`, `APB_GUARDRAIL_BLOCKED_TERMS`,
`APB_GUARDRAIL_MAX_DAILY_BUDGET`, and `APB_GUARDRAIL_ENFORCEMENT` (handy in CI).

## At scale — review the exceptions, not the list

For a batch across many clients:
1. **Dry-run everything first** (omit `--execute`) and read the previews.
2. **Group and review the exceptions** — the few that look wrong (off-domain, off-brand, over-budget, wrong account), not the 95% that are fine. A wall of green is rubber-stamping.
3. **Execute the clean ones; hold the flagged ones** for a fix or an explicit, reasoned override. Don't all-or-nothing a batch.

## Overrides

Every guardrail can be overridden **with a stated reason** — and the override is logged to `logs/apb.jsonl`. The override flags are per-command and surgical:

- `--allow-domain <host>` — waive one specific off-allowlist host (repeatable). Prefer this over a blanket relax.
- `--allow-brand` — waive the canonical-brand / blocked-term copy checks for this command.
- `--allow-budget` — waive the daily-budget cap / currency check for this command.
- `--guardrail-reason "<why>"` — **required** with any `--allow-*`; recorded in the audit log.

Use them on the one item that's a legitimate exception, not as a habit ("ignore all domain warnings" is how a wrong-URL ships). **One thing is never overridable:** operating on an account that isn't in the tenant's connected portfolio. If `apb agency accounts` doesn't list it, you don't touch it — the owner must connect/delegate it first.

## Quick rules

- Author a profile per client (`apb guardrails set …`) so domain/brand/budget are enforced automatically; `apb guardrails test …` to preview.
- Create ⇒ plan. Small edit ⇒ direct. Destructive ⇒ plan + `--confirm-destructive`.
- Wrong-account is the #1 agency error — pass `--account` explicitly, never rely on a stale default.
- Off-domain / off-brand / over-budget → stop and confirm with the client, don't override silently.
- Keep each client's work isolated; verify `apb agency accounts` shows the account before writing to it.
