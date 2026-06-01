# Diagnostic playbooks — which to run, when, and how

`apb` ships 34 playbook subcommands — 32 diagnostics across 4 pillars (below), plus `evaluate` (generic rule eval) and `catalog` (lists the playbook catalog). Picking the right one matters more than running them all.

> **Result envelope.** The 32 diagnostics return `{ grade, score, summary, findings, recommendations }`. `score` is `0–100`, or `null` with `grade: "N/A"` and `insufficient_data: true` when there was nothing to analyze — branch on `insufficient_data`, not on a `0` score or an `F` grade. `playbook catalog` is a *listing*, not a diagnostic, so it intentionally has **no** `grade`/`score`.

## Pillar routing

| Symptom | Pillar | Best first playbook |
|---|---|---|
| New campaign that won't exit learning | Learning | `apb playbook learning-accelerator` |
| Performance dropped over the last 7-14 days | Turnaround | `apb playbook roas-recovery` |
| Ads have been live a while; CTR sagging | Signal | `apb playbook fatigue-index` |
| Not enough fresh creative / tests not producing winners | Signal | `apb playbook creative-velocity` |
| Video ads underperforming | Signal | `apb playbook video-engagement` |
| Conversions dropping somewhere in the funnel | Signal | `apb playbook funnel-leak` |
| Ad sets won't spend their budget | Scaling | `apb playbook delivery-pacing` |
| Want to scale spend safely | Scaling | `apb playbook scale-roadmap` |
| "Tell me everything that's wrong" | Turnaround | `apb playbook health-score`, then `reset-rebuild-advisor` if score <60 |

## The 32 diagnostic playbooks

### Learning (5)

- **`launch-check`** — pre-launch readiness checklist
- **`learning-accelerator`** — budget needed to exit learning + post-learning CPA projection
- **`event-downgrade-ladder`** — walk Purchase → IC → ATC → VC, recommend downgrade
- **`no-touch-compliance`** — flag learning-phase adsets edited within last 7 days
- **`consolidation-advisor`** — detect ad-set fragmentation, recommend merging

### Signal (13)

- **`fatigue-index`** — per-ad creative fatigue 0–100
- **`saturation`** — audience saturation + CPA inflation projection
- **`creative-mix`** — format diversity + volume-per-adset + DCO eligibility
- **`placement-audit`** — performance by placement + exclusion candidates
- **`duplicate-detect`** — targeting overlap (auction self-competition)
- **`broad-targeting-audit`** — narrow_score 0–5 per active adset
- **`event-hierarchy-audit`** — TOF/MOF/BOF naming vs optimization_goal alignment
- **`capi-dual-signal`** — pixel CAPI coverage check
- **`creative-velocity`** — fresh-creative cadence, win-rate, single-creative dependency, refresh runway (default 30d)
- **`video-engagement`** — hook vs payoff diagnosis per video (hook/hold rate + retention cliff; default 14d)
- **`funnel-leak`** — leakiest funnel stage (CTR→LPV→ATC→IC→Purchase) + attribution (default 14d)
- **`signal-quality`** — measurement quality (standard-event coverage, CAPI split, advanced-matching, match rate); quality sibling of capi-dual-signal
- **`segment-performance`** — per-segment (device/placement/age/gender) waste audit + value-rule bid-down specs (default 30d)

### Scaling (10)

- **`waste-audit`** — wasted spend with $ savings projection
- **`rebalance`** — top vs bottom quartile budget swap
- **`weekly-digest`** — week-over-week deltas + monthly projections
- **`daypart`** — hourly heatmap
- **`scale-roadmap`** — incremental (+20%/+30%) and duplication (1.5x/2x/3x) tier projections
- **`cbo-vs-abo-audit`** — flag ABO campaigns with high CPA dispersion
- **`retargeting-compression`** — compress retention windows >30d to 7-14d
- **`delivery-pacing`** — under-delivery cause (budget-capped / learning-limited / bid-audience); assesses ABO ad sets **and** CBO campaigns at the campaign level (default 7d)
- **`bid-strategy`** — bid strategy vs realized CPA/ROAS (COST_CAP throttling, uncapped scaled spend, MIN_ROAS miss); CBO-aware — uses the parent-campaign budget + inherited strategy (default 30d)
- **`advantage-adoption`** — Advantage+ structure adoption + manual-sales migration candidates (advisory; default 30d)

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
- `--days <N>` — lookback window (default varies by playbook: e.g. health-score 30, fatigue-index 28, waste-audit 14)
- `--account <act_…>` — scope to one account (playbooks are per-account; there is no `--accounts` fan-out — loop instead)
- `--since YYYY-MM-DD` (or relative, e.g. `28d`) — overrides `--days`. Playbooks take `--since` standalone; the `--since`/`--until` *pair* belongs to `report insights`, not playbooks.
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

Playbook outputs are advisory — there is no `--from-recommendations` flag. To act on the findings, author a plan spec from them, then create the plan from that spec:

```bash
apb playbook waste-audit --days 30 --json > recs.json
# Transform recs.json into a plan spec (see `apb campaign compose-from-spec --help`
# for the schema), then:
apb plan create --spec-file plan-spec.json --json | jq -r '.data.id'
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

Playbooks run per-account — loop to fan out (the `--accounts all` fan-out exists on `report insights`, not playbooks):

```bash
for acct in act_111 act_222 act_333; do
  score=$(apb playbook health-score --account "$acct" --days 30 --json | jq -r '.data.composite_score')
  printf '%s\t%s\n' "$acct" "$score"
done | sort -k2 -n
```

Identifies the weakest accounts first.
