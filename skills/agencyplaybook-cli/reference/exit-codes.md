# Exit Codes

Every `apb` failure maps to a stable exit code. **Branch on the exit code, not on stderr text** — codes are a contract; messages are localized and may change.

| Code | Meaning | Retry? | Typical cause |
|---:|---|---|---|
| `0` | Success | — | command completed; dry-run rendered |
| `1` | General / unmapped | no | I/O error, config parse failure, fall-through |
| `2` | Validation / invalid input | no — fix input | bad flag, missing required flag, malformed JSON, invalid `--url` |
| `3` | Auth / permission | no — refresh/upgrade | bad/expired `APB_API_KEY`, insufficient scope, tier upgrade required, account not authorized |
| `4` | Safety gate blocked | no — supply flag | mutation without `--execute`; destructive op without `--confirm-destructive`; `--no-input` on a would-prompt path; env gate (`READ_ONLY` / `ALLOW_WRITES` / `APB_ALLOW_MUTATIONS`) |
| `5` | Network / rate-limit / 5xx | yes — back off | Meta API timeout, 429 throttle, 5xx, connection refused |
| `6` | Partial success | — | reserved for future batch operations (not currently emitted) |

> Without `--execute`, a mutation **dry-runs and exits 0** — it does not exit 4. Exit 4 means you asked to execute but a gate blocked it.

## JSON error envelope

With `--json`, a failing command emits a structured envelope on stdout (stderr empty):

```json
{
  "ok": false,
  "error": {
    "code": "write_blocked",
    "message": "Write blocked: --execute flag not provided",
    "exit_code": 4,
    "details": { "reasons": ["--execute flag not provided", "READ_ONLY=true"] }
  }
}
```

## Agent / script decision tree

Branch on `error.exit_code` (or `$?`):

- `exit 0` → parse `data` and act on findings
- `exit 2` → bad input; surface `error.message`, fix the command, do **not** retry
- `exit 3` → auth/scope; refresh credentials or upgrade tier, do **not** retry blindly
- `exit 4` → safety gate; report `error.details.required_flags`, supply `--execute` / `--confirm-destructive`; never auto-confirm a destructive op
- `exit 5` → transient (network/rate-limit); back off (honor `Retry-After`) and retry up to N times
- `exit 1` → general/unmapped; surface and stop

The full automation guide (CI/CD recipes, debugging, log sanitization, plain output) lives in `reference/automation-guide.md`.
