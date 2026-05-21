# Canonical `apb` Workflows

15 examples covering the patterns CLI users actually run. Each one is dry-run-first and exit-code-safe.

---

## 1. First-time setup

```bash
# Generate an API key in the AgencyPlaybook UI at /api-keys, then:
export APB_API_KEY=apb_live_ent_a8f2c93b4d5e6f7g8h9i0j1k2l3m4n5o
# The binary already targets https://api.agencyplaybook.io.
# Local dev only: export APB_API_URL=http://localhost:3750

# Smoke test
apb auth test
# Exit 0 = connected. Exit 3 = bad/expired key (auth). Exit 2 = bad URL. Exit 5 = network.

# Connect Meta if you haven't already
apb auth connect-meta             # opens browser, polls for callback
```

## 2. Dry-run-then-execute (the universal pattern)

```bash
# 1. Dry run — never adds --execute on first attempt
apb campaign create --name "Q3 Launch" --objective OUTCOME_SALES --status PAUSED

# 2. Review the printed diff. If correct, re-run with --execute
apb campaign create --name "Q3 Launch" --objective OUTCOME_SALES --status PAUSED --execute
```

## 3. Plan create → validate → execute with rollback blueprint

For multi-entity workflows (campaign + adsets + ads), always use a plan — `plan validate` writes a rollback blueprint to disk (used by `plan doctor` for drift detection and audit).

```bash
PLAN_ID=$(apb plan create --spec-file my-plan.json --json | jq -r '.data.id')
apb plan validate --plan-id $PLAN_ID
apb plan execute-safe --plan-id $PLAN_ID --require-dry-run-pass --execute
# There is no one-shot replay command. To revert, pause/delete the created
# entities or author a reverse plan; inspect drift with: apb plan doctor --plan-id $PLAN_ID
```

## 4. Multi-account fan-out

```bash
# Run the same playbook across all authorized accounts
apb report insights --accounts all --days 30 --json

# Or specific accounts
apb report insights --accounts act_111,act_222 --days 30
```

## 5. Run a diagnostic playbook end-to-end

```bash
# Quick health check
apb playbook health-score --days 30 --json | jq '.data.composite_score'

# Deep waste audit with dollar projections
apb playbook waste-audit --days 30 --json > waste-report.json
jq '.data.recommendations[] | select(.projected_savings_usd > 100)' waste-report.json

# When health < 60, get a 4-phase rebuild plan
apb playbook reset-rebuild-advisor --days 30
```

## 6. Name-based ID resolution

Skip looking up Meta IDs — pass campaign / adset / ad names directly:

```bash
# Numeric IDs still work
apb campaign get --id 23847562834756123

# But names work too (auto-resolved; must match exactly one campaign)
apb campaign get --id "Q3 Launch"

# Or use aliases. Create one: apb alias set <name> <id>
apb campaign get --id @q3
```

## 7. Audience users-add closed loop (leadgen → custom audience)

```bash
# 1. Export leads from a form (Page Access Token required)
apb leadgen leads-export --form-id 1234567890 --output leads.csv

# 2. Hash & upload into a custom audience for retargeting
apb audience users-add --id 9876543210 --data-file leads.csv --execute

# PII discipline: apb logs only {audience_id, schema, row_count, batch_count}.
# Never the email/phone values.
```

## 8. Full-stack compose (campaign + adsets + creatives + ads in one shot)

```bash
# Spec file holds the full hierarchy
apb campaign compose-from-spec --spec-file q3-launch.json --with-estimates

# Execute with rollback on failure
apb campaign compose-from-spec --spec-file q3-launch.json --execute
# (Auto-pauses created entities in reverse order if any step fails.)
```

## 9. JSON output for shell pipelines

```bash
apb --json report insights --days 30 | jq '.data.campaigns[] | select(.roas > 2)'
```

`--json` is a global flag — it works in any position (most examples here trail it).

## 10. Exit-code branching in bash

```bash
apb auth test --no-input --json
case $? in
  0) echo "OK" ;;
  2) echo "Bad input — e.g. malformed --url; fix and rerun" ;;
  3) echo "Auth failed — bad/expired key or insufficient scope; refresh/upgrade" ;;
  5) echo "Network / rate-limit — back off and retry" ;;
  *) echo "Unexpected (1 = general/unmapped)" ;;
esac
```

## 11. Handling 429s gracefully

The CLI honors Meta's `Retry-After` header automatically. For shell scripts, just retry on exit 5 (network/rate-limit):

```bash
for i in 1 2 3; do
  apb report insights --days 30 --no-input --json && break
  [ $? -eq 5 ] && sleep $((10 * i)) && continue
  break
done
```

## 12. Catalog product set CRUD (DPA / Advantage+ Shopping)

```bash
apb catalog list                                   # list catalogs
apb catalog get --id 1234                          # detail
apb catalog products --id 1234 --after <cursor>    # cursor pagination
apb catalog product-set-create --catalog-id 1234 --name "Bestsellers" --filter '{...}' --execute
```

## 13. Custom conversion (URL-rule event)

```bash
apb custom-conversion create \
  --name "Checkout-Complete-2024" \
  --rule '{"and":[{"url":{"i_contains":"thank-you"}}]}' \
  --custom-event-type OTHER \
  --execute
# Note: rule, custom_event_type, event_source_id are frozen at create time.
```

## 14. Split-test setup

```bash
apb split-test create \
  --name "Q3 creative test" \
  --variant-a-adset 23847001 --variant-a-ad 23847011 \
  --variant-b-adset 23847002 --variant-b-ad 23847012 \
  --objective ctr \
  --duration-days 7 \
  --execute
apb split-test status --id abc123
apb split-test promote --id abc123 --winner B --scale 1.5 --execute --confirm-destructive
```

## 15. Sync local state with Meta

When your on-disk state has drifted from Meta:

```bash
apb sync diff --account act_1234567890   # show drift between local and remote
apb sync pull --account act_1234567890   # refresh local state from Meta
```

---

## Cross-references

- Full per-command reference: `commands.md`
- Tier/scope requirements: `reference/scopes.md`
- Exit codes: `reference/exit-codes.md`
- Setup walkthrough: `workflows/setup.md`
- Automation patterns: `workflows/automation.md`
- Diagnostic playbook picker: `workflows/diagnostics.md`
