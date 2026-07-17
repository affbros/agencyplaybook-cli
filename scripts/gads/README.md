# apb-gads batch scripts — watchdogs, scans, reviews + audit bundles (Google Ads)

Sample, hand-auditable shell scripts that drive the `apb-gads` (Google Ads) CLI.
The library is four tiers: the daily **watchdogs** (Tier 1), the weekly
**opportunity scans** (Tier 2), the **reviews & change management** (Tier 3), and
the generated **playbook audit bundles** (Family 4), plus the standalone
`check-sufficiency` gate.

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
| `watch-account-pulse.sh` | `playbook account-health` | WARN+ severity findings |
| `watch-budget-pacing.sh` | `playbook budget-pacing` + `impression-share-loss` | off-pace campaigns, lost-IS(budget) |
| `watch-policy-flags.sh` | `playbook policy-compliance` | disapproved / limited ads |
| `watch-tracking-health.sh` | `playbook conversion-tracking-check` + `doctor check` | removed/hidden/unverified conversions, config drift |
| `watch-learning-phase.sh` | `playbook pmax-maturity-gate` | campaigns in learning (hands-off list) |
| `watch-fatigue.sh` | `playbook rsa-quality-audit` | weak/declining ad strength |
| `watch-anomalies.sh` | `playbook anomaly-detection` | week-over-week spend/conv anomalies |

`lib/common.sh` (runtime), `lib/sufficiency.sh` (the data-sufficiency gate),
`lib/cooldown.sh` (recent-change lookup via `change_event`), and `thresholds.conf`
(tunable floors) are shared.

> Note on learning phase: Google exposes no first-class "learning" flag, so
> `watch-learning-phase` keys off the PMAX maturity gate's learning-band
> approximation. Search-campaign learning is approximated by smart-bidding
> readiness in the weekly tier.

## Tier 2 — opportunity scans

Weekly, ranked opportunity scans. Unlike the Tier 1 watchdogs (which only
observe), these gate candidates through `lib/sufficiency.sh` (enough data to
judge?) and `lib/cooldown.sh` (was this entity just changed?), rank survivors
by impact, and cap the output at `CHANGE_BUDGET` (`thresholds.conf`, default
3) per run — the rest are reported under `deferred_next_review`, not dropped.
A candidate with a clean, safe mapping to a `--plan`-capable `apb-gads mutate`
command gets a real dry-run plan doc; everything else gets a `suggested_command`
string for the operator to run by hand. Output: `<scan-name>.json` (structured)
+ `<scan-name>.md` (human summary) alongside the underlying playbook reads.

| Script | Reads | Plan-doc capable? |
|---|---|---|
| `scan-scaling-readiness.sh` | `playbook pmax-scaling-plan` + `smart-bidding-readiness` | PMAX budget scale-ups only (`mutate campaign-budget-update`) |
| `scan-waste.sh` | `playbook waste-audit` + `search-term-cleanup` | Yes — `mutate negative-keyword-add-bulk` (primary real-plan-doc scan) |
| `scan-audience-health.sh` | `playbook audience-performance` + `pmax-asset-coverage` | No — advisory only |
| `scan-creative-refresh.sh` | `playbook rsa-quality-audit` + `ad-rotation-audit` | No — creative swaps need human copywriting |
| `scan-structure-hygiene.sh` | `playbook duplicate-keywords` + `naming-convention-audit` | No — dedup needs a keep/drop judgment call |
| `scan-query-mining.sh` | `playbook search-term-analysis` + `search-term-promotion` | Yes — `mutate keyword-add-bulk` |
| `scan-search-terms.sh` | `keyword list` (seeds) + `plan keyword-ideas` (gads-only, no apb equivalent) | No — new-idea relevance needs a human call |
| `check-sufficiency.sh` | none (pure local `thresholds.conf` computation) | n/a — standalone `--entity-json` spot-check, tier 2 / on-demand |

Exit codes for scans: `0` quiet (no opportunities), `10` opportunities
surfaced, `1` tool/auth error — same convention as Tier 1, with `10` meaning
"opportunities ranked this run" instead of "attention items".

## Tier 3 — reviews & change management (the hands)

The only tier that produces plan docs by design. Where Tier 1 is *eyes* and Tier
2 *ranks*, Tier 3 *decides* — under the same three gates (sufficiency · cooldown ·
change budget), applied to the consolidated set.

| Script | Cadence | What it does | Writes |
|---|---|---|---|
| `weekly-review.sh` | weekly | Consumes the week's Tier-2 scan reports (or runs the scans fresh via `bash` if none ran this week), merges every candidate, dedupes by entity, applies ONE global change budget largest-impact-first, and emits a single consolidated `weekly-review.md` linking the per-action dry-run plan docs the scans already rendered — or an explicit "no changes this week — here's why" report (buckets + counts, an explicitly good outcome). | plan-doc |
| `monthly-strategic-review.sh` | monthly | Long-lookback (90d) strategic bundle — campaign-bid-strategy-audit, account-structure-audit, budget-rebalance, audience-performance — into a narrative report + AT MOST one structural plan doc (account structure, gated on the plan carrying machine-actionable operations). | plan-doc |
| `budget-rebalance.sh` | weekly | Sufficiency-gated pacing reallocation: reads `budget-pacing`, resolves the top off-pace campaign's budget resource via a read-only `gaql query`, and renders `mutate campaign-budget-update --plan` (dry-run) for the single reallocation. | plan-doc |
| `plan-then-apply.sh` | on-demand | The canonical two-step apply — see below. **The only script that touches the apply path.** | interactive-apply |

```bash
./weekly-review.sh --customer 6338615768               # exit 10 = changes proposed
./monthly-strategic-review.sh --customer 6338615768 --lookback 90
./budget-rebalance.sh --customer 6338615768
```

**Doctrine: `weekly-review` is deliberately NOT scheduled by default — a human
runs it.** Daily watchdogs are eyes (cron-safe via `apb-gads schedule add`); the
weekly review is hands (a person deciding).

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
cannot compose a live mutation. BYO credentials via
`GADS_EXTRA_ARGS="--config /path/to/google-ads.yaml"`.

## Family 4 — playbook audit bundles (generated)

`audit-full.sh` runs **every** read-only diagnostic playbook; the sectioned
`audit-<section>.sh` (pmax · creative · keywords · bidding · audience · structure ·
signal · health) run a thematic subset. Each writes one JSON per playbook into a
timestamped results dir + an `index.md`. Zero API mutations.

```bash
./audit-full.sh --customer 6338615768                          # all playbooks
./audit-pmax.sh --customer 6338615768 --lookback 30
./audit-full.sh --customer 6338615768 --only account-health,waste-audit
```

These files are **generated** by `scripts/gen_scripts.py` from the committed
`gads-cli-catalogue.json` (`# GENERATED by gen_scripts.py — do not hand-edit`). CI
runs `gen_scripts.py --check` next to the parity gate, so a newly-shipped playbook
cannot be silently missing from `audit-full`. Regenerate after a catalogue change
with `python3 scripts/gen_scripts.py`.

## Usage

```bash
# BYO credentials: point at your google-ads.yaml (never embedded in a script)
export GADS_EXTRA_ARGS="--config /path/to/google-ads.yaml"
apb-gads account list                    # find your customer id
./watch-account-pulse.sh --customer 6338615768
./watch-fatigue.sh --customer 6338615768 --lookback 30
```

Flags: `--customer <id>` (or env `GADS_WATCH_CUSTOMER`), `--lookback <days>`
(maps to `--lookback-days`), `--out-dir <dir>`, `--quiet`.
`APB_GADS_BIN=/path/to/apb-gads` overrides binary discovery.

Status files land under `./gads-watch/<customer>/<YYYY-MM-DD>/<name>.json`.

## Scheduling

apb-gads has a native, read-only-by-construction scheduler:
`apb-gads schedule add` **rejects anything containing `--execute`, `mutate`, or
write-capable orchestrators at registration time** — so these Tier 1 watchdogs
register safely. It renders a managed crontab section the OS fires:

```bash
apb-gads schedule add --customer 6338615768 playbook account-health --cron "0 7 * * *"
apb-gads schedule install
```

You can equally wrap the scripts in plain cron and branch on exit 10 (see the apb
README for the pattern).

## Exit codes

| Code | Meaning |
|---|---|
| `0` | Quiet — nothing to flag. |
| `10` | Attention items found (printed as `[ATTN] …` on stdout). For weekly review. |
| `1` | Tool/auth error — the underlying `apb-gads` call failed. |

## `thresholds.conf` tuning

`sufficient '<json>'` (in `lib/sufficiency.sh`) reads `thresholds.conf`. Defaults
mirror apb-gads's metric-policy compiled defaults
(`rust/gads/crates/ads-core/src/config.rs` +
`client/playbooks_impl.rs::resolve_metric`). Schema is versioned
(`thresholds_schema=1`) — tune the values, keep the schema line. Tier 1 watchdogs
report raw and do **not** gate on sufficiency.

## Support posture

**MIT-licensed samples, as-is, no SLA.** They encode a way of working, not a
managed service. Every line is a CLI call + `jq`. Bug reports/PRs welcome;
response is best-effort.

## Safety

Read-only by default; plan-emitting where actionable (Tier 3). **No script's
source contains `--execute`** — CI-enforced across every `.sh`, *including*
`plan-then-apply.sh`, which learns the apply flag from the binary at runtime and
makes you re-type it rather than composing it itself. `plan-then-apply.sh` is the
single sanctioned apply path, and it is interactive-only (refuses cron). No
credentials are embedded — scripts inherit `APB_API_KEY` / `google-ads.yaml`
exactly like a bare `apb-gads` call.
