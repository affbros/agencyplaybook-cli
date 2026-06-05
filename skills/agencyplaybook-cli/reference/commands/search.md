# `apb search` — Command Reference

1 commands. Auto-generated from the apb binary on 2026-06-05.

### `apb search`

Search objects

**Scope:** `read:search` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--query` | `<QUERY>` | Search query |
| `--account` | `<ACCOUNT>` |  |
| `--search-type` | `<SEARCH_TYPE>` | Object type to search |
| `--scope` | `<SCOPE>` | Alias for search_type, accepts comma-separated scopes |
| `--limit` | `<LIMIT>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb search --query <QUERY> --search-type <SEARCH_TYPE>
```
