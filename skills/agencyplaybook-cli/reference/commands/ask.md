# `apb ask` — Command Reference

1 commands. Auto-generated from the apb binary on 2026-05-26.

### `apb ask`

Ask a natural-language question

**Scope:** `read:search` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--question` | `<QUESTION>` | The question to ask |
| `--account` | `<ACCOUNT>` |  |
| `--campaign` | `<CAMPAIGN>` |  |
| `--days` | `<DAYS>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb ask --question <QUESTION> --campaign <CAMPAIGN>
```
