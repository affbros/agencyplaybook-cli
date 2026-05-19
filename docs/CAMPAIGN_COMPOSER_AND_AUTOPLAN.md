# Campaign Composer + Action Autoplan (Rust CLI)

## 1) Strict Like-for-Like Duplicate
Use `campaign duplicate` for campaign -> adset -> ads cloning.

```bash
apb campaign duplicate \
  --id <source_campaign_id> \
  --name "My Campaign Copy" \
  --json --dry-run

# execute
READ_ONLY=false ALLOW_WRITES=true META_CTL_ALLOW_MUTATIONS=true \
apb campaign duplicate --id <source_campaign_id> --name "My Campaign Copy" --json --execute
```

Expected output includes:
- `new_campaign_id`
- `adsets_created`
- `ads_created`
- `adset_map`
- `ad_map`

## 2) Campaign Composer
Compose a new campaign from selected source campaigns/adsets/ads.

```bash
apb campaign compose \
  --name "Q2 Hybrid Sales" \
  --source-campaigns <id1,id2> \
  --source-adsets <adset_id1,adset_id2> \
  --source-ads <ad_id1,ad_id2> \
  --objective OUTCOME_SALES \
  --json --dry-run

# execute
READ_ONLY=false ALLOW_WRITES=true META_CTL_ALLOW_MUTATIONS=true \
apb campaign compose --name "Q2 Hybrid Sales" --source-campaigns <id1,id2> --source-adsets <...> --source-ads <...> --objective OUTCOME_SALES --json --execute
```

Notes:
- `--source-campaigns` is required.
- `--source-adsets` and `--source-ads` are optional filters.
- If filters are omitted, selected entities are inferred from source campaign trees.

## 3) Action Autoplan (agent-ready plan seeds)
Generate safe plan seeds from recent diagnostics.

```bash
apb action autoplan --days 14 --limit 10 --json
```

Output includes `plan_seeds[]` with:
- `action`
- `target_id`
- `payload`
- `risk_level`
- `reason`
- `suggested_next_command`

No write execution is performed by `action autoplan`.
Use suggested commands with `plan create -> validate -> execute-safe`.
