# Agency guardrails — safe multi-client operation (apb-gads)

When you (or an AI agent) drive `apb-gads` across **more than one client (customer)**,
the danger isn't a bad change — it's the *wrong* change on the *wrong* customer: an RSA
final URL on the wrong client's domain (or a placeholder — an account-suspension
signal), the wrong brand in copy, a 10× budget in micros, or a mutation applied to the
wrong customer because the persisted current account was stale. This doctrine keeps
agency work safe. It complements `references/safety-model.md` (the three gates).

## The two dials — match friction to blast radius

1. **Plan ceremony** is for *creating* and *removing*, not for routine edits.
   - **Creating a campaign** (`mutate search-campaign-create` / `performance-max-create` / `demand-gen-create` / `shopping-smart-campaign-create`, or `campaign-launch`), **bulk creates, or removals** → go through the dry-run-first plan path: dry-run → `--save-plan` → review → `mutate apply-plan`. These already run at the stricter `LIVE_VERIFIED` tier — respect it.
   - **Small edits to an existing campaign** (budget update ≤ cap, status change, bid set, match-type) → a single dry-run-then-`--execute` is fine. Don't over-ceremony routine edits.
2. **Content validation** is *always on*. Before any write that sets a final URL, brand/business name, or budget, check it against the client (below). The `LiveVerifyPolicy` (per-customer `allowed_domains`, budget cap, required name) is the enforcement spine — keep it populated per client.

## Before every write — the 4 checks

- **Right customer.** Confirm the operating account. Precedence is `--customer` > persisted (`account use`) > config default; the MCC (`login_customer_id`) never switches. For agency work pass `--customer <id>` explicitly, or `account use <id>` then `account current` to verify — a stale persisted selection is the #1 wrong-customer cause.
- **Domain.** Every RSA/asset final URL must be on the client's own domain (eTLD+1). Placeholder or off-domain URLs risk disapproval/suspension.
- **Brand.** Copy (headlines/descriptions/business name) must carry the client's brand and must NOT name a competitor or another client.
- **Budget.** Budgets are in **micros** — sanity-check the magnitude and currency before `--execute` (a missing/extra factor of 1e6 is a classic blowout).

## Central (server-delivered) guardrail profiles

An agency can author a managed customer's guardrail centrally (the **Agency → Guardrails** editor in the web app, `channel=google`: allowed domains + a daily-budget cap). When `apb-gads` resolves the tenant's `APB_API_KEY`, that profile is **delivered and applied automatically** — synthesized into the customer's `SafetyProfile` + `LiveVerifyPolicy` (allowed-domains + budget cap, new ads forced PAUSED) **without editing `google-ads.yaml`**. A local `google-ads.yaml` profile, if present, always wins (more-specific). So an agency gets the four checks above enforced fleet-wide from one place; per-customer yaml is only needed to override. (Only `enforcement: block` profiles with a non-empty domain allowlist are applied; `warn`/`off` are advisory for now.)

## At scale — review the exceptions, not the list

For a batch across many customers:
1. **Dry-run / `--validate-only` everything first** and read the previews.
2. **Review the exceptions** — the few that look wrong (off-domain, off-brand, over-budget, wrong customer), not the 95% that are fine.
3. **Execute the clean ones; hold the flagged ones** for a fix or an explicit, reasoned override. Don't all-or-nothing a batch. `campaign-launch` halts on a bad spec — fix and re-run.

## Overrides

Every guardrail can be overridden **with a stated reason**, and the override is logged (`audit list`). Use them surgically (one item) — a blanket override is how a wrong-URL ships. **One thing is never overridable:** operating on a customer outside the tenant's membership (`saas_customer_ids` / `account list`). If `account list` doesn't show it, you don't touch it — it must be granted first.

## Quick rules

- Create ⇒ plan (LIVE_VERIFIED). Small edit ⇒ dry-run-then-execute. Removal ⇒ plan.
- Wrong-customer is the #1 agency error — `--customer` explicitly or verify `account current`; never trust a stale persisted selection.
- Budgets are micros; off-domain/placeholder URLs risk suspension — stop and confirm, don't override silently.
- Keep each client isolated; verify `account list` shows the customer before writing to it.
