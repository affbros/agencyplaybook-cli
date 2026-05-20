# Diagnostic playbooks — which to run, when, and how

`apb` ships 24 playbooks across 4 pillars. Picking the right one matters more than running them all.

## Pillar routing

| Symptom | Pillar | Best first playbook |
|---|---|---|
| New campaign that won't exit learning | Learning | `apb playbook learning-accelerator` |
| Performance dropped over the last 7-14 days | Turnaround | `apb playbook roas-recovery` |
| Ads have been live a while; CTR sagging | Signal | `apb playbook fatigue-index` |
| Want to scale spend safely | Scaling | `apb playbook scale-roadmap` |
| "Tell me everything that's wrong" | Turnaround | `apb playbook health-score`, then `reset-rebuild-advisor` if score <60 |

## The 24 playbooks

### Learning (5)

- **`launch-check`** — pre-launch readiness checklist
- **`learning-accelerator`** — budget needed to exit learning + post-learning CPA projection
- **`event-downgrade-ladder`** — walk Purchase → IC → ATC → VC, recommend downgrade
- **`no-touch-compliance`** — flag learning-phase adsets edited within last 7 days
- **`consolidation-advisor`** — detect ad-set fragmentation, recommend merging

### Signal (8)

- **`fatigue-index`** — per-ad creative fatigue 0–100
- **`saturation`** — audience saturation + CPA inflation projection
- **`creative-mix`** — format diversity + volume-per-adset + DCO eligibility
- **`placement-audit`** — performance by placement + exclusion candidates
- **`duplicate-detect`** — targeting overlap (auction self-competition)
- **`broad-targeting-audit`** — narrow_score 0–5 per active adset
- **`event-hierarchy-audit`** — TOF/MOF/BOF naming vs optimization_goal alignment
- **`capi-dual-signal`** — pixel CAPI coverage check

### Scaling (7)

- **`waste-audit`** — wasted spend with $ savings projection
- **`rebalance`** — top vs bottom quartile budget swap
- **`weekly-digest`** — week-over-week deltas + monthly projections
- **`daypart`** — hourly heatmap
- **`scale-roadmap`** — incremental (+20%/+30%) and duplication (1.5x/2x/3x) tier projections
- **`cbo-vs-abo-audit`** — flag ABO campaigns with high CPA dispersion
- **`retargeting-compression`** — compress retention windows >30d to 7-14d

### Turnaround (4)

- **`health-score`** — composite 0-100 with sub-scores
- **`roas-recovery`** — diagnose ROAS decline + prescribe recovery
- **`anomaly-detect`** — flag cost anomalies vs trailing baseline
- **`reset-rebuild-advisor`** — composite 4-phase rebuild plan (triggers when health <60)

## Standard invocation

```bash
apb playbook <name> --days 30 --json | jq '.data'
```

Most playbooks accept:
- `--days <N>` — lookback window (default 30, max 90)
- `--account <act_…>` — scope to one account
- `--accounts all` — fan out across all authorized accounts
- `--since YYYY-MM-DD --until YYYY-MM-DD` — explicit date range
- `--json` — machine-parseable output

## Interpretation patterns

### Health score sub-scores

```bash
apb playbook health-score --days 30 --json | jq '.data.sub_scores'
# {
#   "delivery": 78,      ← are ads reaching audiences?
#   "creative": 62,      ← is the creative still resonating?
#   "audience": 71,      ← is targeting saturated?
#   "structure": 84,     ← is the account hygienic?
#   "economics": 55      ← is spend producing returns?
# }
```

Lowest sub-score points at which playbook to run next.

### Composite reset-rebuild

When `health-score` returns < 60:

```bash
apb playbook reset-rebuild-advisor --days 30 --json
```

This returns a 4-phase plan. Phase 1 (immediate): pause lowest-quartile spend. Phase 2 (week 1): consolidate, refresh creatives. Phase 3 (week 2-3): rebuild with new structure. Phase 4 (week 4+): scale survivors.

### Closed-loop with a plan

Many playbook outputs include `recommended_actions[]` that can be fed straight into a plan:

```bash
apb playbook waste-audit --days 30 --json > recs.json
apb plan create --from-recommendations recs.json --json | jq -r '.data.id'
# Then validate + execute as in workflows/automation.md
```

## Cadence

| Playbook | Recommended cadence |
|---|---|
| `health-score` | Daily |
| `weekly-digest` | Weekly (Monday morning) |
| `waste-audit` | Weekly |
| `fatigue-index` | Weekly |
| `learning-accelerator` | When launching anything new |
| `roas-recovery` | When triggered by anomaly-detect |
| `reset-rebuild-advisor` | When health <60 |

## Multi-account fan-out

```bash
apb playbook health-score --accounts all --days 30 --json | \
  jq -r '.data.per_account[] | "\(.account_id)\t\(.composite_score)"' | \
  sort -k2 -n
```

Identifies the weakest accounts first.
