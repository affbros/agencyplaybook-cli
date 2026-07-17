# apb batch scripts — watchdogs, scans, reviews + audit bundles (Meta)

Sample, hand-auditable shell scripts that drive the `apb` (Meta) CLI. The library
is four tiers: the daily **watchdogs** (Tier 1), the weekly **opportunity scans**
(Tier 2), the **reviews & change management** (Tier 3), and the generated
**playbook audit bundles** (Family 4) — plus the standalone `check-sufficiency`
gate.

## Operating doctrine (three lines)

- **Watch constantly, change rarely.** Watchdogs observe and alert; they never
  propose or apply a change.
- **One-way valve: daily = eyes, weekly = hands.** A daily watchdog that finds
  something actionable flags it *for weekly review* — it does not act on it.
- **No decision without data sufficiency.** Judgements about change wait until an
  entity clears the sufficiency floor (`thresholds.conf`); watchdogs just report.

## What's here

| Script | Reads | Flags |
|---|---|---|
| `watch-account-pulse.sh` | `report insights` (daily) | spend spike/collapse vs trailing avg, zero-delivery |
| `watch-budget-pacing.sh` | `playbook delivery-pacing` | under-delivery / budget-capped entities |
| `watch-policy-flags.sh` | `ad list` | disapproved / limited / in-review ads |
| `watch-tracking-health.sh` | `pixel health` | stale / silent / no-event pixels |
| `watch-learning-phase.sh` | `learning diagnose` | ad sets in/near learning (hands-off list) |
| `watch-fatigue.sh` | `playbook fatigue-index` | fatiguing top-spender creative |
| `watch-anomalies.sh` | `report insights` (daily) | daily-spend z-score outliers |

`lib/common.sh` (runtime), `lib/sufficiency.sh` (the data-sufficiency gate),
`lib/cooldown.sh` (recent-change lookup), and `thresholds.conf` (tunable floors)
are shared.

## Tier 2 — opportunity scans (weekly)

Read-only analysis → a ranked `opportunities` report. Every candidate is gated
by `sufficient()` (insufficient-data entities are reported as "keep collecting",
never as an opportunity) and `cooldown_check()` (recently-touched entities are
deferred), then ranked largest-impact-first and capped at `change_budget`
(`thresholds.conf`, default 3 — the rest are listed under
`deferred_next_review`). Where the finding maps to one of apb's `--plan`-capable
commands, the scan renders a Track-A plan doc from that same invocation (dry-run
by construction, zero API mutation) and attaches its path as `plan_doc` on every
surviving opportunity; where no clean mapping exists, the opportunity instead
carries a `suggested_command` the operator can run by hand.

| Script | Reads | Plan doc? |
|---|---|---|
| `scan-scaling-readiness.sh` | `playbook scale-roadmap` (+ `rebalance` cross-check) | yes — `scale-roadmap --plan` |
| `scan-waste.sh` | `playbook waste-audit` | yes — `waste-audit --plan` |
| `scan-audience-health.sh` | `audience list` + `audience overlap` | no — `suggested_command` (`audience create-lookalike`) |
| `scan-creative-refresh.sh` | `playbook fatigue-index` (+ `creative-mix` cross-check) | yes — `fatigue-index --plan` |
| `scan-structure-hygiene.sh` | `playbook duplicate-detect` (+ `consolidation-advisor` cross-check) | yes — `duplicate-detect --plan` |
| `scan-query-mining.sh` | `playbook placement-audit` (+ optional `library search` cross-check) | yes — `placement-audit --plan` |

Each writes `<out-dir>/<scan-name>.json` (full structured report:
`opportunities` / `insufficient_data` / `deferred_cooldown` /
`deferred_next_review`) and a short human `<scan-name>.md` summary. Plan docs
land under `<out-dir>/plans/`. **apb note**: `--plan` operates at the
playbook-invocation level (there's no per-entity `--plan` target inside a
playbook run), so all opportunities surfaced by one scan run share that scan's
single rendered plan doc — it's not one doc per entity.

```bash
./scan-waste.sh --account act_1234567890
./scan-structure-hygiene.sh --account act_1234567890 --lookback 30
```

Exit codes match the Tier-1 convention (`0` quiet, `10` opportunities surfaced,
`1` tool/auth error).

## Tier 3 — reviews & change management (the hands)

The only tier that produces plan docs by design. Where Tier 1 is *eyes* and Tier
2 *ranks*, Tier 3 *decides* — under the same three gates (sufficiency · cooldown ·
change budget), just applied to the consolidated set.

| Script | Cadence | What it does | Writes |
|---|---|---|---|
| `weekly-review.sh` | weekly | Consumes the week's Tier-2 scan reports (or runs the scans fresh via `bash` if none ran this week), merges every candidate, dedupes by entity, applies ONE global change budget largest-impact-first, and emits a single consolidated `weekly-review.md` linking the per-action dry-run plan docs the scans already rendered — or an explicit "no changes this week — here's why" report (buckets + counts, an explicitly good outcome). | plan-doc |
| `monthly-strategic-review.sh` | monthly | Long-lookback (90d) strategic bundle — bid-strategy, consolidation-advisor, scale-roadmap, segment-performance, advantage-adoption — into a narrative report + AT MOST one structural plan doc (consolidation, gated on the plan carrying machine-actionable operations). | plan-doc |
| `budget-rebalance.sh` | weekly | Sufficiency-gated, budget-neutral reallocation proposal from the `rebalance` playbook, rendered as a dry-run plan doc via `--plan`. | plan-doc |
| `plan-then-apply.sh` | on-demand | The canonical two-step apply — see below. **The only script that touches the apply path.** | interactive-apply |

```bash
./weekly-review.sh --account act_1234567890            # exit 10 = changes proposed
./monthly-strategic-review.sh --account act_1234567890 --lookback 90
./budget-rebalance.sh --account act_1234567890
```

**Doctrine: `weekly-review` is deliberately NOT scheduled by default — a human
runs it.** That's the whole point of the one-way valve: daily watchdogs are eyes
(cron-safe), the weekly review is hands (a person, at a keyboard, deciding). Only
the watchdogs (and the read-only scans) belong in cron.

### `plan-then-apply.sh` — the only apply path

```bash
./plan-then-apply.sh <plan.md>            # interactive; requires a terminal
./plan-then-apply.sh <plan.md> --print-only   # non-interactive dry preview
```

Takes an existing plan doc (the `<name>.md` a `--plan` run wrote), finds its JSON
twin, prints the doc, and walks you through a **typed-confirmation** apply. It
**refuses to run without a TTY** (uncron-able by design) unless `--print-only`,
which stops before any confirmation. Crucially, **the apply flag is never written
in the script's source** — it's learned from the binary's own `--help` at runtime
and you must re-type it verbatim, so a `curl | bash` reader can verify the file
cannot compose a live mutation on its own. Dry-run-first and consent-at-the-rail
survive distribution.

## Family 4 — playbook audit bundles (generated)

`audit-full.sh` runs **every** read-only diagnostic playbook; the sectioned
`audit-<section>.sh` (creative · bidding · structure · signal · health) run a
thematic subset. Each writes one JSON per playbook into a timestamped results dir
+ an `index.md`. Zero API mutations.

```bash
./audit-full.sh --account act_1234567890                       # all playbooks
./audit-creative.sh --account act_1234567890 --lookback 14
./audit-full.sh --account act_1234567890 --only health-score,waste-audit
```

These files are **generated** by `scripts/gen_scripts.py` from the committed CLI
catalogue (`# GENERATED by gen_scripts.py — do not hand-edit`). CI runs
`gen_scripts.py --check` next to the parity gate, so a newly-shipped playbook
cannot be silently missing from `audit-full`. Regenerate after a catalogue change
with `python3 scripts/gen_scripts.py`.

## `check-sufficiency` — standalone gate

Ask "does this entity have enough data to judge?" directly, without running a
full scan:

```bash
./check-sufficiency.sh --account act_1234567890 \
  --entity-json '{"conversions": 3, "spend_usd": 40, "impressions": 500}'
```

Prints the verdict (`pass` or the `fail — insufficient data — keep collecting
(...)` wording used everywhere else in this library). Exit `0` pass, `10` fail,
`1` tool/arg error. `tier: 2`, `cadence: on-demand`, `writes: never`.

## Usage

```bash
export APB_API_KEY=apb_live_...          # your key — scripts inherit it, none is embedded
apb account list                         # find your act_ id
./watch-account-pulse.sh --account act_1234567890
./watch-fatigue.sh --account act_1234567890 --lookback 14
```

Flags: `--account <act_id>` (or env `APB_WATCH_ACCOUNT`), `--lookback <days>`
(per-script default), `--out-dir <dir>`, `--quiet`. `APB_BIN=/path/to/apb`
overrides binary discovery.

Status files land under `./apb-watch/<account>/<YYYY-MM-DD>/<name>.json` so the
future weekly review can diff a day against yesterday and consume the week.

## Cron

Plain cron with `--no-input` (the wrapper already adds it). Exit 10 means "look";
route it to a notifier:

```cron
# 07:00 daily pulse; page me only when there's something to see (exit 10)
0 7 * * *  cd /opt/apb-scripts && APB_API_KEY=apb_live_... \
  ./watch-account-pulse.sh --account act_1234567890 \
  || [ $? -eq 10 ] && mail -s "apb pulse: attention" me@example.com < ./apb-watch/act_1234567890/$(date +\%F)/account-pulse.json
```

## Exit codes

Per `docs/CLI_AUTOMATION.md`, layered with the watchdog convention:

| Code | Meaning |
|---|---|
| `0` | Quiet — nothing to flag. |
| `10` | Attention items found (printed as `[ATTN] …` on stdout). For weekly review. |
| `1` | Tool/auth error — the underlying `apb` call failed. |

## `thresholds.conf` tuning

`sufficient '<json>'` (in `lib/sufficiency.sh`) reads `thresholds.conf`. Defaults
mirror apb's compiled constants (`rust/crates/apb-core/src/common.rs`:
`LOW_CONVERSION_VOLUME`, `MEANINGFUL_SPEND_USD`, …). The schema is versioned
(`thresholds_schema=1`) — tune the values, keep the schema line. Tier 1 watchdogs
report raw and do **not** gate on sufficiency; the gate is for the weekly
opportunity/change tiers.

## Support posture

These are **MIT-licensed samples**, provided as-is, **no SLA**. They encode a way
of working, not a managed service. Every line is a CLI call + `jq` — read them in
60 seconds and adapt them. Bug reports/PRs welcome; response is best-effort.

## Safety

Read-only by default; plan-emitting where actionable (Tier 3). **No script's
source contains `--execute`** — CI-enforced across every `.sh`, *including*
`plan-then-apply.sh`, which learns the apply flag from the binary at runtime and
makes you re-type it rather than composing it itself. `plan-then-apply.sh` is the
single sanctioned apply path, and it is interactive-only (refuses cron). No
credentials are embedded — scripts inherit `APB_API_KEY` / `~/.apb/.env` exactly
like a bare `apb` call.
