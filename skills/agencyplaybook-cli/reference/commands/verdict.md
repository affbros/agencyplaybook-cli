# `apb verdict` — Command Reference

1 commands. Auto-generated from the apb binary on 2026-09-09.

### `apb verdict`

Per-campaign decision verdict — one verb (SCALE / OPTIMIZE / TIGHTEN / CAP / HOLD / CUT) per ACTIVE campaign, from 3 gates (Efficiency / Delivery+headroom / Quality). Read-only, ranked by spend. Provide --target-roas or --target-cpa for the Efficiency gate

**Scope:** `read:playbooks:full` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--days` | `<DAYS>` | Lookback window in days (default 30) |
| `--since` | `<SINCE>` | Alternative to --days: YYYY-MM-DD or relative e.g. 30d |
| `--target-roas` | `<TARGET_ROAS>` | Target ROAS for the Efficiency gate (overrides --target-cpa precedence is CPA-first) |
| `--target-cpa` | `<TARGET_CPA>` | Target CPA (USD) for the Efficiency gate |
| `--min-age-days` | `<MIN_AGE_DAYS>` | Maturity floor — min age in days before a campaign is judged (default 30) |
| `--min-conversions` | `<MIN_CONVERSIONS>` | Maturity floor — min conversions before a campaign is judged (default 50) |
| `--queue` |  | Rank the verdicts into a decision queue ($ impact/day + next-action command + reallocation) |
| `--include-paused` |  | Also judge PAUSED campaigns (reactivation / post-mortem lens). Paused campaigns carry delivery "n/a" so SCALE can't fire; read OPTIMIZE=relaunch, CUT=correctly killed |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
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
apb verdict --days <DAYS> --since <SINCE>
```
