# Decision verdicts — one decisive verb per campaign

The playbooks output scores, grades, and findings. Operators want a **decision**. This doctrine
collapses any diagnosis into **one decisive verb per campaign** (and per account), derived from
explicit pass/fail **gates** — not from a fuzzy score.

> **The verdict is based on gates, not a score.** A 78/100 tells you nothing actionable; "this
> campaign passes Efficiency and Delivery but has budget headroom → **SCALE**" does. Gates make the
> *why* legible and the *next action* obvious. This is the same model the apb-gads (Google Ads) skill
> uses — identical verbs and gates, only the playbooks that feed each gate differ. The web overview's
> attention badge is the weighted-score cousin of this; the gates are the sharper instrument.

## The six verbs

Anchored on the four an operator actually asks for (SCALE / TIGHTEN / OPTIMIZE / CAP), bracketed by
HOLD (not enough data to judge) and CUT (terminal).

| Verb | When | Default next action |
|---|---|---|
| **SCALE** | all gates pass **and** there's headroom (budget-capped while efficient) | raise budget into the headroom |
| **OPTIMIZE** | gates pass but mid-tier / **no headroom** | refine settings — don't scale yet |
| **TIGHTEN** | exactly **one** gate at-risk (none failing) | restrict: negatives, narrow targeting, trim budget |
| **CAP** | **two or more** gates fail (recoverable) | freeze spend until the failing gate clears |
| **HOLD** | insufficient data / still in learning | wait; protect learning |
| **CUT** | chronic multi-window failure / negative net value | pause or archive |

## The three gates

Each gate is computable from data the CLI already pulls. Thresholds are **referenced from the
runtime** (`apb-core/src/common.rs` — `LOW_CONVERSION_VOLUME`, `MEANINGFUL_SPEND_USD`, `SCALE_*` —
and the `health-score` sub-scores), never hardcoded here, so they can't drift from the binary.

- **G1 — Efficiency (unit economics).** ROAS ≥ `target_roas` (or CPA ≤ `target_cpa`); reflected in the
  `health-score` `economics` sub-score. **star/performer** (at or under target CPA / at or over target
  ROAS) = **pass**; **underperformer** = **at-risk**; **problem** (well past target) = **fail**.
- **G2 — Delivery / headroom.** Is it delivering, and is there room to grow? `delivery-pacing`
  classifies under-delivery cause: **budget-capped + still efficient = headroom** (the SCALE signal);
  learning-/bid-/audience-limited = **at-risk**; delivering normally with no cap = **pass (no headroom)**.
- **G3 — Quality / signal integrity.** Conversions ≥ learning floor (`LOW_CONVERSION_VOLUME`) **and**
  low waste % **and** measurement healthy (`signal-quality`) **and** creative not saturated/fatigued.
  Any one failing = **gate fail**.

## Verdict logic — gates decide the verb

| Data sufficiency | G1 Efficiency | G2 Delivery | G3 Quality | → Verdict |
|---|---|---|---|---|
| insufficient (conv < floor, or age < maturity) | — | — | — | **HOLD** |
| sufficient | pass | pass **+ headroom** | pass | **SCALE** |
| sufficient | pass | pass (no headroom) | pass | **OPTIMIZE** |
| sufficient | at-risk **(or G3 at-risk)** — exactly one | pass | pass | **TIGHTEN** |
| sufficient | ≥2 of {G1,G2,G3} **fail** (recoverable) | | | **CAP** |
| sufficient | chronic across windows / negative net value | | | **CUT** |

## How to apply it (the loop)

```
DIAGNOSE (run the gate playbooks) → VERDICT (assign a verb per campaign)
→ QUEUE (sort by $ impact) → ACT (top verb first, dry-run → approve → execute)
```

Growth-first still governs: a CAP or TIGHTEN is always paired with *where the freed budget
redeploys* (the top SCALE candidate). Don't read "budget-capped" as a problem — on a G1-passing
campaign it's the headroom that makes the verdict **SCALE**.

## Per-gate playbook map (Meta)

Compose these existing playbooks to evaluate each gate (`apb playbook <slug>`):

| Gate | Playbooks |
|---|---|
| **G1 Efficiency** | `roas-recovery`, `bid-strategy`, `scale-roadmap` |
| **G2 Delivery / headroom** | `delivery-pacing` (under-delivery cause incl. budget-capped), `rebalance` |
| **G3 Quality / signal** | `waste-audit`, `signal-quality`, `saturation`, `fatigue-index` |

`health-score` is the fast spine: its lowest sub-score (`economics`/`delivery`/`creative`/`audience`)
points at which gate is failing and which playbook to run next.

## Verb → action (Meta)

| Verdict | How to act |
|---|---|
| **SCALE** | `apb action autoplan` proposes the scale step; size it with `apb playbook scale-roadmap` (+20%/+30% tiers); execute through the safe plan path (below) |
| **OPTIMIZE** | `apb playbook bid-strategy`, `apb playbook creative-velocity` — fix bidding / refresh creative, hold budget flat |
| **TIGHTEN** | `apb playbook waste-audit`, `apb playbook segment-performance` (emits value-rule bid-down specs), `apb playbook broad-targeting-audit` (narrow the widest ad sets) |
| **CAP** | freeze: `apb campaign update-status` the worst offenders to `PAUSED`, clear the failing gate, then re-verdict |
| **HOLD** | `apb playbook learning-accelerator` — budget to exit learning + CPA projection; change nothing structural |
| **CUT** | chronic: `apb campaign update-status --status ARCHIVED` (reversible — prefer over `DELETED`) |

**Exec path for any verb that writes** — for anything spanning 2+ entities, route through the plan
framework so the rollback blueprint exists on disk (dry-run by default; destructive steps also need
`--confirm-destructive`):

```bash
apb playbook scale-roadmap --account act_123 --json > recs.json   # findings to act on
# Author a plan spec from recs.json (see `apb campaign compose-from-spec --help` for the schema), then:
apb plan create --account act_123 --spec-file plan-spec.json --json
apb plan execute-safe --plan-id <id> --require-dry-run-pass --execute
```

`apb action autoplan` is the one-shot alternative for a single-campaign budget step (dry-run without
`--execute`); the plan path is preferred whenever the change spans multiple entities.

## Worked example

```
Verdict   Campaign         Gates                                                       → Action
SCALE     Prospecting-BR   G1 pass (ROAS 3.4x ≥ 3.0) · G2 headroom (budget-capped) · G3 pass   raise budget into headroom
TIGHTEN   Broad-Test       G1 at-risk (ROAS 2.2x) · G2 pass · G3 pass                            narrow + add negatives
CAP       Affiliates       G1 fail (1.2x) · G3 fail (18% zero-conv spend)                       freeze until ROAS ≥ 3.0x
HOLD      Launch-New       < 6 days & < 50 conv                                                  protect learning
```

The queue is the payload: sort verdicts by dollar impact, redeploy CAP'd/TIGHTENed budget into the
top SCALE candidate, and act on one verb at a time — dry-run → approve → execute.

> **Status note.** This is skill doctrine: Claude composes the verbs over **existing** playbooks.
> A native top-level `verdict` command that emits this rollup directly is on the near-term roadmap —
> until it ships, run the gate playbooks above and apply the table.
