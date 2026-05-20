# Automation workflow — safe multi-step changes

When a change touches more than one entity (e.g. "create a campaign with three ad sets and six ads"), prefer **plans** over ad-hoc commands. Plans are the only mechanism that produces a rollback blueprint on disk.

## The plan lifecycle

```
spec.json → plan create → plan validate → plan execute → (rollback if needed)
              ↓ produces a Plan ID
              ↓ status: CREATED
              → after validate: status VALIDATED
              → after execute:  status EXECUTED
              → if rolled back: status ROLLED_BACK
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

## Step 5 — Rollback if needed

```bash
apb plan rollback --plan-id $PLAN_ID --execute --confirm-destructive
```

The blueprint is on disk; rollback uses it. Note: `--confirm-destructive` is required because rollback can pause/delete entities.

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
# Review all CREATED plans for an account
apb plan review-batch --account act_1234567890 --status CREATED

# Approve a batch (sets all to VALIDATED-equivalent)
apb plan approve-batch --plan-ids p1,p2,p3 --execute
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
  1) echo "Generic failure" ;;
  2) echo "Network/timeout — retry idempotent" ;;
  3) echo "Permission/scope — escalate" ;;
  4) echo "Rate limited — back off and retry" ;;
  5) echo "Validation failed — fix spec" ;;
  6) echo "Destructive op needed --confirm-destructive" ;;
esac
```

Full table: `reference/exit-codes.md`.
