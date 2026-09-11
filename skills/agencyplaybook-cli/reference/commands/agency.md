# `apb agency` — Command Reference

3 commands. Auto-generated from the apb binary on 2026-09-11.

### `apb agency accounts`

List the ad accounts the connected token(s) can see

**Scope:** `read:playbooks:full` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb agency accounts --plan <PATH> --fonts <MODE>
```

### `apb agency connect-meta`

Connect a Meta system-user token (BYO) for the agency portfolio. POSTs to /saas/agency/meta-token; the token is validated + stored server-side

**Scope:** `read:playbooks:full` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--token` | `<TOKEN>` | The Meta system-user access token (with `ads_read`). Pipe from a secret store to keep it out of shell history, e.g. `--token "$(cat token.txt)"` |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb agency connect-meta --token <TOKEN> --plan <PATH>
```

### `apb agency portfolio plan`

LOCAL marginal-return budget allocator (planning-001 S4). Never calls the SaaS API — runs directly against the Meta account(s) the resolved token can see (`APB_API_KEY` still resolves a Meta token when the CLI is SaaS-authed, but no server route is involved). Per ad set: marginal return from 30d/60d conversions-vs-cost slopes, learning status, `bid_constraints.roas_average_floor`, and delivery headroom (`delivery_estimate` / `budget simulate`) gate the move; moves budget from below-median to above-median marginal return in steps <= `--max-step-pct`, never onto LEARNING, never cross-currency. Read-only: this only ever writes files, never mutates the account

**Scope:** `read:playbooks:full` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--accounts` | `<ACCOUNTS>` | Comma-separated ad account ids (e.g. `act_a,act_b`). Default: the single resolved/effective account — there is no local "all connected" discovery (that's the SaaS agency roll-up above) |
| `--objective` | `<OBJECTIVE>` | `conversions` (default) or `value` — which /insights totals drive the marginal-return rate. The ROAS-floor gate always uses purchase value/spend regardless of this choice |
| `--budget-total` | `<BUDGET_TOTAL>` | Cap the SUM of this run's proposed budgets, in --currency's major units. Requires --currency |
| `--currency` | `<CURRENCY>` | Restrict the run to ONE currency group (required with --budget-total; optional otherwise — every currency group found across --accounts is processed and moves never cross a group) |
| `--horizon` | `<HORIZON>` | Primary lookback window, e.g. `30d` (default). The comparison window used for the slope is 2x this |
| `--max-step-pct` | `<MAX_STEP_PCT>` | Max `daily_budget` change per ad set, as a percent (default 10) |
| `--out` | `<OUT>` | Write the plan-envelope-v2 JSON here (also always printed to stdout) |
| `--meta-portfolio-out` | `<META_PORTFOLIO_OUT>` | Also write the Meta half of the cross-channel bridge file that `apb-gads portfolio plan --with-meta <this file>` reads — schema documented in `rust/docs/planning.md` § portfolio plan |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb agency portfolio plan --accounts <ACCOUNTS> --objective <OBJECTIVE>
```
