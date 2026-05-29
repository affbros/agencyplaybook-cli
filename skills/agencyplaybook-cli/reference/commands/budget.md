# `apb budget` — Command Reference

1 commands. Auto-generated from the apb binary on 2026-05-29.

### `apb budget simulate`

Run budget simulation

**Scope:** `write:budgets` · **Min tier:** agency

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--campaign` | `<CAMPAIGN>` |  |
| `--daily-budget` | `<DAILY_BUDGET>` |  |
| `--budget` | `<BUDGET>` |  |
| `--days` | `<DAYS>` |  |
| `--shift-from` | `<SHIFT_FROM>` |  |
| `--shift-to` | `<SHIFT_TO>` |  |
| `--pct` | `<PCT>` |  |
| `--from` | `<FROM>` |  |
| `--to` | `<TO>` |  |
| `--strategy` | `<STRATEGY>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb budget simulate --campaign <CAMPAIGN> --daily-budget <DAILY_BUDGET>
```
