# `apb andromeda` — Command Reference

2 commands. Auto-generated from the apb binary on 2026-06-18.

### `apb andromeda launch`

Launch ads from a saved Andromeda plan

**Scope:** `write:automation` · **Min tier:** enterprise

| Flag | Value | Description |
|---|---|---|
| `--plan-id` | `<PLAN_ID>` |  |
| `--adset` | `<ADSET>` |  |
| `--creative-ids` | `<CREATIVE_IDS>` |  |
| `--status` | `<STATUS>` | [default: PAUSED] |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
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
apb andromeda launch --plan-id <PLAN_ID> --adset <ADSET>
```

### `apb andromeda plan`

Build a practical creative volume plan and persist a manifest

**Scope:** `write:automation` · **Min tier:** enterprise

| Flag | Value | Description |
|---|---|---|
| `--campaign` | `<CAMPAIGN>` |  |
| `--adset` | `<ADSET>` |  |
| `--volume` | `<VOLUME>` | [default: 20] |
| `--angles` | `<ANGLES>` |  |
| `--formats` | `<FORMATS>` |  |
| `--days` | `<DAYS>` | [default: 14] |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
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
apb andromeda plan --campaign <CAMPAIGN> --adset <ADSET>
```
