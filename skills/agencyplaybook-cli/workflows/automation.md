# Automation workflow — safe multi-step changes

When a change touches more than one entity (e.g. "create a campaign with three ad sets and six ads"), prefer **plans** over ad-hoc commands. Plans are the only mechanism that produces a rollback blueprint on disk.

## The plan lifecycle

```
spec.json → plan create → plan validate → plan execute-safe
              ↓ produces a Plan ID
              ↓ status: CREATED
              → after validate: status VALIDATED (rollback blueprint written to disk)
              → after execute:  status EXECUTED
```

## Step 1 — Author a spec

```json
{
  "campaign": {
    "name": "Q3 Launch",
    "objective": "OUTCOME_SALES",
    "status": "PAUSED",
    "daily_budget": 5000
  },
  "adsets": [
    { "name": "Lookalike 1%", "targeting_spec": { ... }, "daily_budget": 2000 },
    { "name": "Interest Stack", "targeting_spec": { ... }, "daily_budget": 3000 }
  ],
  "ads": [
    { "adset_ref": "Lookalike 1%", "creative_ref": "hero-video-v3" },
    { "adset_ref": "Interest Stack", "creative_ref": "hero-image-v3" }
  ]
}
```

See `apb campaign compose-from-spec --help` for the full schema.

## Step 2 — Create the plan

```bash
PLAN_ID=$(apb plan create --spec-file spec.json --json | jq -r '.data.id')
echo $PLAN_ID
# 01HSXQK6N4P9Z3R7VW2YDFKJM5
```

Status now: `CREATED`. Nothing has been written to Meta.

## Step 3 — Validate (dry-run)

```bash
apb plan validate --plan-id $PLAN_ID --json | jq '.data'
```

This walks the spec, checks Meta API compatibility, computes blast radius (0–5), and writes a rollback blueprint to disk. Status now: `VALIDATED`. If validation fails (e.g. `blast_radius > 3` without explicit acknowledgement), nothing executes.

## Step 4 — Execute with safety belt

```bash
apb plan execute-safe \
  --plan-id $PLAN_ID \
  --require-dry-run-pass \
  --execute
```

`execute-safe` refuses to run unless validation has passed. The plain `apb plan execute` skips that check — only use it when scripting and you've validated separately.

## Step 5 — Reverting

There is no one-shot `plan rollback` command. `plan validate` writes a rollback **blueprint** to disk for audit and drift detection. To revert an executed plan, inspect it then pause/delete the entities it created, or author a reverse plan:

```bash
# Inspect what was created and check for drift from Meta state
apb plan doctor --plan-id $PLAN_ID
# Revert by pausing/deleting the created entities, e.g.:
apb campaign update-status --id <created-id> --status PAUSED --execute
```

For single-command full-stack builds, `apb campaign compose-from-spec` instead **auto-pauses** every entity it created (in reverse order) if any step fails — unless you pass `--no-rollback`.

## Blast radius reference

| Radius | Meaning | Examples |
|---|---|---|
| 0 | No-op | Status check, pause already-paused ad |
| 1 | Read-only mutation | Budget bump <10% |
| 2 | Bounded write | Single-entity update |
| 3 | Multi-entity write | Compose adset + ads |
| 4 | Account-spanning | Cross-account sync |
| 5 | Irreversible | Delete campaign + descendants |

Radius ≥3 prints a confirmation prompt unless `--no-input` is set. Radius 5 always requires `--confirm-destructive`.

## Batch review (for human-in-the-loop systems)

```bash
# Review a batch of plans for an account (--all, or --ids p1,p2,p3)
apb plan review-batch --all --account act_1234567890

# Approve specific plans (sets all to VALIDATED-equivalent)
apb plan approve-batch --ids p1,p2,p3 --execute
```

## Canary execution

For high-blast-radius plans, run a fraction first:

```bash
apb plan canary --plan-id $PLAN_ID --pct 10 --execute
# Watch metrics for an hour, then promote:
apb plan canary --plan-id $PLAN_ID --pct 100 --execute
```

## Health check

```bash
apb plan doctor --plan-id $PLAN_ID
# Reports stale validations, missing blueprints, and divergence from Meta state.
```

## Exit-code branching for CI/CD

```bash
apb plan execute-safe --plan-id $PLAN_ID --require-dry-run-pass --execute --no-input --json
case $? in
  0) echo "Plan executed cleanly" ;;
  1) echo "Generic / unmapped failure" ;;
  2) echo "Validation failed — fix the spec, do not retry" ;;
  3) echo "Auth / scope — escalate" ;;
  4) echo "Safety gate — --execute set but an env gate (READ_ONLY/ALLOW_WRITES/APB_ALLOW_MUTATIONS) blocked the write" ;;
  5) echo "Network / rate-limit / 5xx — back off and retry" ;;
  6) echo "Partial success (reserved)" ;;
esac
```

Full table: `reference/exit-codes.md`.
