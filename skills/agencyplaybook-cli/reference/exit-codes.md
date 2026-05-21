# Exit Codes

Every `apb` failure maps to a stable exit code. **Branch on the exit code, not on stderr text** — codes are a contract; messages are localized and may change.

| Code | Meaning | Retry? | Typical cause |
|---:|---|---|---|
| `0` | Success | — | command completed; **dry-run rendered** (a mutation run without `--execute`) |
| `1` | General / unmapped | no | I/O error, config parse failure, fall-through |
| `2` | Validation / invalid input | no — fix input | bad/missing flag, malformed JSON, invalid `--url`, unpaired `--since`/`--until`, **missing `--confirm-destructive` on a destructive op** |
| `3` | Auth / permission | no — refresh/upgrade | bad/expired `APB_API_KEY`, insufficient scope, tier upgrade required, account not authorized |
| `4` | Safety gate blocked | no — set gate | `--execute` was given **but** an env gate (`READ_ONLY` / `ALLOW_WRITES` / `APB_ALLOW_MUTATIONS`) blocked the write (`write_blocked`); or `--no-input` blocked a required prompt (`safety_gate_blocked`) |
| `5` | Network / rate-limit / 5xx | yes — back off | Meta API timeout, 429 throttle, 5xx, connection refused |
| `6` | Partial success | — | reserved for future batch operations (not currently emitted) |

> **What is NOT exit 4:** a mutation run **without** `--execute` **dry-runs and exits `0`** (it does not mutate). Forgetting `--confirm-destructive` on a destructive op is **exit `2`** (`validation_error`). Exit `4` is specifically the env-gate / `--no-input`-prompt block — you asked to execute and a gate refused.

## JSON error envelope

With `--json`, a failing command emits a structured envelope on stdout (stderr empty):

```json
{
  "ok": false,
  "error": {
    "code": "write_blocked",
    "message": "Write blocked: READ_ONLY != false",
    "exit_code": 4,
    "details": { "reasons": ["READ_ONLY != false"] }
  }
}
```

`error.details` is present **only** for these codes: `write_blocked` (`reasons`), `safety_gate_blocked` (`gate`, `required_flags`), `insufficient_scope` (`required_scope`, `current_tier`, `minimum_tier`), `account_not_authorized` (`account_id`), `rate_limited` (`retry_after_ms`). **Every other error is flat** — `code` + `message` + `exit_code`, no `details` (e.g. `validation_error`, `auth_error`).

## Agent / script decision tree

Branch on `error.exit_code` (or `$?`):

- `exit 0` → success or dry-run preview; parse `data` / `dry_run` and act
- `exit 2` → bad input (incl. missing `--confirm-destructive`); fix the command, do **not** retry
- `exit 3` → auth/scope; if `insufficient_scope`, read `details.required_scope` / `details.minimum_tier`; refresh creds or upgrade tier
- `exit 4` → env/prompt gate; read `details.reasons` / `details.required_flags`; set the env gates (or supply the prompt); never auto-confirm a destructive op
- `exit 5` → transient (network/rate-limit); back off (honor `Retry-After` / `details.retry_after_ms`) and retry up to N times
- `exit 1` → general/unmapped; surface and stop

The full automation guide (CI/CD recipes, debugging, log sanitization, plain output) lives in `reference/automation-guide.md`.
