# `apb policy` — Command Reference

2 commands. Auto-generated from the apb binary on 2026-05-25.

### `apb policy profile set`

Set a policy profile value

**Scope:** `read:campaigns` · **Min tier:** starter · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--profile` | `<PROFILE>` |  |
| `--value` | `<VALUE>` |  |
| `--value-type` | `<VALUE_TYPE>` |  |
| `--account` | `<ACCOUNT>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb policy profile set --execute --profile <PROFILE> --value <VALUE>
```

### `apb policy profile show`

Show current policy profile

**Scope:** `read:campaigns` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--profile` | `<PROFILE>` |  |
| `--account` | `<ACCOUNT>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb policy profile show --profile <PROFILE>
```
