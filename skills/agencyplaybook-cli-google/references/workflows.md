# Concrete command workflows

All commands assume the downloaded `apb-gads` binary is on your PATH and a Google account is
connected (see `SKILL.md` § Setup). For brevity: `B="apb-gads --pretty"`. `<CID>` = the operating
customer id (plain numeric, no dashes), passed via the global `--customer <CID>` flag. For writes,
prove the wire shape first with `--validate-only` (SERVER_VALIDATED — see `safety-model.md`) before
re-running with `--execute`.

## W1 — Full diagnosis (read-only, safe anywhere)

```bash
$B --customer <CID> playbook account-health                     # scorecard + next actions
$B --customer <CID> playbook campaign-bid-strategy-audit        # AUTHORITATIVE bidding_strategy_system_status
$B --customer <CID> growth scale-up                             # efficient headroom, ranked by upside
$B --customer <CID> growth consolidation                        # modern-structure doctrine readout
# If PMAX campaigns exist:
$B --customer <CID> playbook pmax-audit                         # asset groups, coverage, waste/dormant flags
$B --customer <CID> report pmax-placements                      # where PMAX ran (impressions-only) + channel proxy
$B --customer <CID> playbook pmax-segmentation-audit            # structure vs margin/objective doctrine
# If Search campaigns exist:
$B --customer <CID> playbook rsa-quality-audit                  # case/length/pinning/ad-strength linting
$B --customer <CID> playbook waste-audit --lookback-days 90     # spend leaks (frame redeployment, not cuts)
```

Read the bid-strategy audit first: `learning_now[]` campaigns are off-limits for
changes this session; `growth_blockers[]` (LIMITED_BY_BUDGET/DATA) are where the
growth plan starts; `misconfigured[]` must be fixed before optimization; its
`by_channel` map tells you whether the PMAX/Search branches apply.

**Output keys worth jq-ing (playbook outputs are large raw GAQL arrays —
target these instead of reading everything):**

| Command | Keys to read |
|---|---|
| `account-health` | `.score` (0-100 heuristic; sandbox ≈65, don't over-read), `.summary.campaign_counts`, `.recommendations[]` |
| `campaign-bid-strategy-audit` | `.learning_now[]`, `.growth_blockers[]`, `.misconfigured[]`, `.by_channel`, `.by_system_status_state` |
| `growth scale-up` | the per-lever arrays (budget-limited winners, expansion-ready, search-term promotions, roas nudges) — empty arrays on zero-data accounts are CORRECT |
| `pmax-audit` | `.diagnostics.findings[].flags` (waste/dormant/missing_required_assets), `.diagnostics.findings[].missing_field_types` (REMOVED entities already filtered out) |
| `report pmax-placements` | `.channel_proxy_by_placement_type`, `.api_limits[]` (be honest about what v24 can't show), `.lookback_days` |
| `rsa-quality-audit` | `.rsa_count`, `.refresh_candidates[]` (POOR-strength only), `.severity_totals`, per-ad `.findings[].code` |

## W2 — Audit → ranked plan → reviewed changeset (artifact pipeline)

```bash
$B --customer <CID> playbook search-term-promotion --output-spec /tmp/spec.json
$B --customer <CID> plan from-audit --from-file /tmp/spec.json --output /tmp/plan.json   # GrowthFirst ranking by default
$B --customer <CID> changes from-plan --from-file /tmp/plan.json --output /tmp/changeset.json
$B --customer <CID> changes apply --from-file /tmp/changeset.json                        # DRY-RUN: review per-item ops
# ... show the user, get approval, then:
APB_GADS_ALLOW_MUTATIONS=true $B --customer <CID> --execute changes apply --from-file /tmp/changeset.json
$B export render --from /tmp/plan.json --format markdown > /tmp/plan.md   # human-readable artifact
```

## W3 — Safe bid/budget change (learning-phase protocol)

```bash
# 1. Dry-run — the envelope carries a `learning_advisory` (F1):
$B --customer <CID> mutate campaign-budget-update \
  --budget-resource-name customers/<CID>/campaignBudgets/<BID> --amount-micros <NEW>
# 2. Read advisory: will_reset_learning yes|likely|no + recommendation.
#    - "no"      → proceed after user approval
#    - "likely"  → offer the smaller step the advisory suggests (≤15% budget / ≤10% target)
#    - "yes"     → recommend mutate experiment-create instead, or explicit user override
# 3. NEVER pair a budget change with a target change in the same session window.
# 4. Execute (after approval): same command + --execute (+ env gate; --confirm above profile threshold).
# 5. Verify: $B --customer <CID> audit list | tail; inverse available via mutate inverse-plan.
```

Same protocol for `campaign-update-bidding-strategy` (target moves) and
`bidding-seasonality-adjustment-create` (window ≤7d, CVR 30-50%).

## W4 — RSA refresh (doctrine-conformant)

```bash
$B --customer <CID> playbook rsa-quality-audit            # only POOR strength = refresh candidate
$B --customer <CID> playbook ad-refresh                   # rotation recommendation per ad group
# Validate new copy BEFORE building (exit 3 on fail):
$B mutate ad-validate --from-file new_rsa.json
# Refresh = NEW ad (created PAUSED) + pause the loser — never heavy in-place edits:
$B --customer <CID> orchestrate ad-refresh --ad-group-id <AG> --from-file new_rsa.json   # dry-run first
```

Copy rules: sentence case; 8-10 unique headlines, several <20 chars; descriptions
61-70 chars; partial pinning only (2-3 variants per pinned position).

## W5 — PMAX guardrail pass

```bash
$B --customer <CID> report pmax-placements                # junk placements → exclusion candidates
$B --customer <CID> playbook pmax-url-exclusion-audit --output-spec /tmp/web.json
#   → wrap items as {items:[...]} → mutate campaign-negative-webpage-add-bulk --from-file
$B --customer <CID> playbook brand-exclusion-audit        # brand bleed into non-brand PMAX
#   → customer suggest-brands --prefix <brand> → mutate campaign-brand-list-exclude
$B --customer <CID> mutate campaign-update-url-expansion-opt-out --campaign-id <ID> --opt-out   # lead-gen LP control
$B --customer <CID> mutate pmax-audience-signal-attach --asset-group-id <AG> --signal-type SEARCH_THEME --text "<theme>"  # ≤25/AG
```

## W6 — Greenfield launch pipelines

```bash
# SEARCH (one command end-to-end research → launch-ready specs):
$B --customer <CID> plan campaign full --business "<desc>" --url https://<domain> --export-dir /tmp/build
$B validate campaign-spec --from-file /tmp/build/<spec>.json        # exit 3 = fix before launching
$B --customer <CID> orchestrate campaign-launch --from-file /tmp/build/<spec>.json          # dry-run
# PMAX (assets must exist first - asset-create-image / bootstrap):
$B --customer <CID> plan campaign pmax --business "<desc>" --final-url https://<domain> ... --output /tmp/pmax.json
$B validate pmax-spec --from-file /tmp/pmax.json
$B --customer <CID> orchestrate pmax-build --from-file /tmp/pmax.json                        # dry-run
# Execute only after user approval; entities are born PAUSED either way.
```

## W7 — Wire-shape proof without writing (SERVER_VALIDATED)

```bash
APB_GADS_ALLOW_MUTATIONS=true $B --customer <CID> \
  --execute --validate-only mutate <slug> <flags...>
# Google validates schema+policy+auth server-side; creates NOTHING. Use for new
# payload shapes before proposing them on a real account.
```

## Reading the learning/status enums (quick key)

| `bidding_strategy_system_status` | Meaning | Action |
|---|---|---|
| `ENABLED` | converged | normal ops; changes within W3 bounds |
| `LEARNING_*` | in learning (suffix says why) | hands off; wait for ENABLED or use experiments |
| `LIMITED_BY_BUDGET` | wants more budget | **growth signal** — raise budget ≤20% steps |
| `LIMITED_BY_DATA` | too few conversions | consolidate, broaden, fix tracking — don't go manual |
| `MISCONFIGURED_*` | broken setup | fix config first; nothing else matters |

Trap: this status is **independent of `campaign.status`** — a PAUSED campaign
typically still reports `ENABLED` here, and at zero spend "converged" is vacuous.
Always read it alongside campaign status + actual spend before drawing conclusions.
