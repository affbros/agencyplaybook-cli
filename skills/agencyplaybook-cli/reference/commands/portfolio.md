# `apb portfolio` — Command Reference

1 commands. Auto-generated from the apb binary on 2026-06-18.

### `apb portfolio`

Cross-channel portfolio — rank Meta + Google campaigns by the SAME gate-verdict (SCALE / OPTIMIZE / TIGHTEN / CAP / HOLD / CUT), with a per-channel rollup + cross-channel reallocation. Server-side (needs APB_API_KEY); `--include-google` adds Google Ads when the add-on is connected (degrades soft to Meta-only)

**Scope:** `read:playbooks:full` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--days` | `<DAYS>` | Lookback window in days (default 30) |
| `--since` | `<SINCE>` | Alternative to --days: YYYY-MM-DD or relative e.g. 30d |
| `--target-roas` | `<TARGET_ROAS>` | Target ROAS for the Efficiency gate |
| `--target-cpa` | `<TARGET_CPA>` | Target CPA (USD) for the Efficiency gate |
| `--min-age-days` | `<MIN_AGE_DAYS>` | Maturity floor — min age in days before a campaign is judged (default 30) |
| `--min-conversions` | `<MIN_CONVERSIONS>` | Maturity floor — min conversions before a campaign is judged (default 50) |
| `--include-google` |  | Include Google Ads (requires the Google Ads add-on; Meta-only otherwise) |
| `--include-paused` |  | Also include PAUSED campaigns (reactivation / post-mortem lens) on both channels |
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
apb portfolio --days <DAYS> --since <SINCE>
```
