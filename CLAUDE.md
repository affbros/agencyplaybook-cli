# Using `apb` with Claude Code

This file gives Claude Code (and other AI coding assistants) the context they need to drive the `apb` CLI safely and effectively.

## What `apb` is

A Rust-based CLI for managing Meta (Facebook/Instagram) ad campaigns through the AgencyPlaybook.io SaaS API. 226 commands across 30 domains (campaigns, adsets, ads, creatives, audiences, pixels, custom conversions, lead-gen, 24 playbooks, plan execution, datasets, reports, rules, split tests, sync, automation).

## Required environment

- `APB_API_KEY` — `apb_live_*` or `apb_test_*` token. Required for everything except `--help`.
- `APB_API_URL` — optional override. Release builds default to `https://api.agencyplaybook.io` (currently in private beta — until then, point at your own self-hosted endpoint).

## Safety contract — DRY-RUN FIRST

Every mutating command **requires the `--execute` flag**. Without it, you get a dry-run preview showing what *would* change. This is not optional — the absence of `--execute` is the difference between "preview my plan" and "irreversibly modify a live ad account".

```bash
# Dry-run preview (safe; no Meta API mutation)
apb campaign update-status --id 123456789 --status PAUSED

# Actually pause it
apb campaign update-status --id 123456789 --status PAUSED --execute
```

**Destructive operations** additionally require `--confirm-destructive`:
- Setting status to `DELETED` or `ARCHIVED`
- Budget set to $0
- Budget increase >200%
- Rule deletion
- Any `*.delete` plan action

When in doubt, run without `--execute` first, read the preview, then decide.

## Calling pattern Claude should use

1. **Discovery first**: `apb account list`, `apb campaign list`, `apb adset list --campaign <id>`. Use these to find IDs before any mutation.
2. **Always dry-run mutations first**: omit `--execute` to see the proposed change. Report it to the user. Only proceed with `--execute` after explicit user confirmation.
3. **Never bypass `--confirm-destructive`** unless the user has explicitly approved a destructive change.
4. **Plan complex changes**: `apb plan create ...` saves a multi-step mutation as a reviewable plan. Then `plan validate` → `plan execute --execute`. Plans give you a rollback audit trail.

## Error handling

- `401` → `APB_API_KEY` is missing, expired, or wrong tier. Run `apb auth status` to see current key state.
- `403` → key is valid but doesn't have the required scope for that command. Check `apb auth status` for the scope list.
- `429` → rate-limited. `apb` automatically backs off; just wait.

## Common Claude tasks

| Task | Commands |
|---|---|
| "What's my current ad account state?" | `apb account list && apb campaign list --status ACTIVE` |
| "Why are conversions dropping?" | `apb playbook health-score --days 30 && apb playbook fatigue-detector --days 7` |
| "Pause campaign X" | `apb campaign update-status --id X --status PAUSED` (preview), then add `--execute` |
| "Set budget on adset Y to $50/day" | `apb adset update-budget --id Y --new-daily-budget-usd 50` (preview), then add `--execute` |
| "Show me last week's spend" | `apb report insights --level campaign --since 7d` |

## Output

All commands print human-readable tables to stdout by default. Add `--output json` for machine-readable JSON (suitable for piping into `jq` or feeding back into another `apb` invocation).

## Where to learn more

- [`docs/CLI_REFERENCE.md`](docs/CLI_REFERENCE.md) — every command and flag
- [`docs/SAFETY_MODEL.md`](docs/SAFETY_MODEL.md) — the full write-gate model
- [`docs/CLI_AUTOMATION.md`](docs/CLI_AUTOMATION.md) — CI/CD + AI-agent invocation patterns

---

# Sibling CLI: `apb-gads` (Google Ads)

`apb-gads` is the Google Ads counterpart to `apb` — a **separate binary** for operator-grade Google Ads + Performance Max management (271 commands across 24 domains, Google Ads API v24): reads/reports, 63 diagnostic playbooks, growth-first planning, greenfield Search/PMAX launch, and 116 dry-run-first gated mutations behind a three-gate safety model.

- **Same auth model**: set `APB_API_KEY` (Google Ads is a paid add-on — connect a Google account in the AgencyPlaybook dashboard). The binary defaults to `https://api.agencyplaybook.io`.
- **Same DRY-RUN-FIRST contract**: every mutation needs `--execute`; there is no bypass flag. Prove wire shapes with `--execute --validate-only` (Google validates server-side, creates nothing). Exit codes: `0` ok · `1` runtime · `2` usage · `3` validation fail.
- **Binary**: [`bin/`](bin) (`apb-gads`). **Skill**: [`skills/agencyplaybook-cli-google/`](skills/agencyplaybook-cli-google). **Docs**: [`docs/google/`](docs/google) — start with [`docs/google/GETTING_STARTED.md`](docs/google/GETTING_STARTED.md).
