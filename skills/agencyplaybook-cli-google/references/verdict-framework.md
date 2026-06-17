# Decision verdicts — one decisive verb per campaign

The playbooks output scores, grades, and findings. Operators want a **decision**. This doctrine
collapses any diagnosis into **one decisive verb per campaign** (and per account), derived from
explicit pass/fail **gates** — not from a fuzzy score.

> **The verdict is based on gates, not a score.** A 78/100 tells you nothing actionable; "this
> campaign passes Efficiency and Delivery but has budget headroom → **SCALE**" does. Gates make the
> *why* legible and the *next action* obvious. This is the same model the apb (Meta) skill uses —
> identical verbs and gates, only the playbooks that feed each gate differ. The web overview's
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
runtime** (`pmax-maturity-gate`'s performance tiers + `policy.rs`), never hardcoded here — so they
can't drift out of sync with the binary.

- **G1 — Efficiency (unit economics).** ROAS ≥ `target_roas` (or CPA ≤ `target_cpa`). Tiered exactly
  like `pmax-maturity-gate`: **star/performer** (≤100% of target CPA, or ≥ target ROAS) = **pass**;
  **underperformer** (100–130%) = **at-risk**; **problem** (>130%) = **fail**.
- **G2 — Delivery / headroom.** Is it delivering, and is there room to grow? **budget-capped + still
  efficient = headroom** (the SCALE signal); under-delivering / starved = **at-risk**; delivering
  normally with no cap = **pass (no headroom)**.
- **G3 — Quality / signal integrity.** Conversion volume ≥ learning floor **and** low waste %
  **and** no policy disapprovals **and** conversion tracking healthy. Any one failing = **gate fail**.

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
redeploys* (the top SCALE candidate). Never read `LIMITED_BY_BUDGET` as a problem — on a G1-passing
campaign it's the headroom that makes the verdict **SCALE**.

## Per-gate playbook map (Google Ads)

Compose these existing playbooks to evaluate each gate (`apb-gads playbook <slug>`):

| Gate | Playbooks |
|---|---|
| **G1 Efficiency** | `campaign-bid-strategy-audit`, `pmax-maturity-gate`, `roas-nudge-recommendation`, `bid-strategy-mismatch` |
| **G2 Delivery / headroom** | `impression-share-loss`, `budget-pacing`, `expansion-readiness` (+ `growth scale-up` for the ranked headroom readout) |
| **G3 Quality / signal** | `waste-audit`, `waste-cluster-audit`, `policy-compliance`, `conversion-tracking-audit`, `quality-score-audit` |

`campaign-bid-strategy-audit` is the spine: its `learning_now[]` forces **HOLD**, `growth_blockers[]`
(`LIMITED_BY_BUDGET`) is the G2 headroom signal, `misconfigured[]` is a G3 fail.

## Verb → action (Google Ads)

| Verdict | How to act |
|---|---|
| **SCALE** | `apb-gads growth scale-up` to size the headroom; for PMax, `apb-gads playbook pmax-scaling-plan --output-spec scale.json` (Go/No-Go, single step capped at +50%) → review → execute the budget lift (see exec path below) |
| **OPTIMIZE** | `apb-gads playbook campaign-bid-strategy-audit`, `apb-gads playbook smart-bidding-readiness`, `apb-gads playbook rsa-quality-audit` — fix bidding / creative, hold budget flat |
| **TIGHTEN** | `apb-gads playbook waste-cluster-audit --output-spec neg.json` / `apb-gads playbook search-term-cleanup` → negatives via `apb-gads mutate campaign-negative-keyword-add-bulk`; trim budget a step |
| **CAP** | freeze with a release condition: `apb-gads mutate campaign-cap --campaign-id <id> --until "roas>=3.0"` (pauses + records the gate; `apb-gads mutate campaign-check-caps` re-evaluates current metrics and un-pauses when it clears — never frozen without a way out). Or `campaign-budget-update` down |
| **HOLD** | `apb-gads playbook smart-bidding-readiness`, `apb-gads playbook pmax-maturity-gate` (`collect_data`) — protect learning, change nothing structural |
| **CUT** | chronic: `apb-gads mutate campaign-update-status` → `PAUSED` (reversible) before archiving |

**Exec path for any verb that writes** — never hand off raw budget edits; route through the guarded
artifact pipeline (dry-run by default, three gates):

```bash
B="apb-gads --pretty"
$B --customer <CID> playbook pmax-scaling-plan --output-spec /tmp/spec.json     # emits budget_update_candidates
$B --customer <CID> plan from-audit --from-file /tmp/spec.json --output /tmp/plan.json    # GrowthFirst ranking
$B --customer <CID> changes from-plan --from-file /tmp/plan.json --output /tmp/cs.json
$B --customer <CID> changes apply --from-file /tmp/cs.json                       # DRY-RUN: review per-item ops
# ... show the user, get approval, then (env gate + --execute):
APB_GADS_ALLOW_MUTATIONS=true $B --customer <CID> --execute changes apply --from-file /tmp/cs.json
```

## Worked example

```
Verdict   Campaign        Gates                                                          → Action
SCALE     Brand-Search    G1 pass (ROAS 5.3x ≥ 4.0) · G2 headroom (IS-lost-budget 34%) · G3 pass   raise budget into headroom
TIGHTEN   Generic-Search  G1 at-risk (ROAS 2.1x) · G2 pass · G3 pass                                add negatives, trim a step
CAP       Display-RMKT    G1 fail (1.1x) · G3 fail (60% zero-conv terms)                            freeze until ROAS ≥ target
HOLD      PMax-New        < 30d & < 50 conv                                                          collect data, protect learning
```

The queue is the payload: sort verdicts by dollar impact, redeploy CAP'd/TIGHTENed budget into the
top SCALE candidate, and act on one verb at a time — dry-run → approve → execute.

> **Shortcut — the native command.** `apb-gads verdict --customer <CID>` emits this rollup directly:
> one verb per ENABLED campaign with the 3 gate states, blockers, and a `next` action, ranked by
> spend (`--target-roas`/`--target-cpa` set the efficiency target; `--lookback-days` the window). Add
> **`--queue`** for a decision queue ranked by **$ impact/day**, each with a next-action command + a
> reallocation line (freed CAP'd budget → top SCALE). The gate-playbook route above is the deep dive
> when a verdict needs evidence. Act on the verbs via `growth scale-up` / `playbook pmax-scaling-plan`
> (SCALE), `waste-cluster-audit` → negatives (TIGHTEN), or `mutate campaign-update-status` (CAP/CUT) —
> gads has no plan framework, so the freeze is a manual `mutate`, not apb's conditional `plan cap`.
