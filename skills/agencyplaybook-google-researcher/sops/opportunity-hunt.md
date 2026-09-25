# SOP: Opportunity hunt

Triggered by: "find alpha", "what used to work", "hunt for relaunch opportunities", "hidden
pockets", "hand me something I can test". Pipeline, in order:
`intents → market refresh → competitors → opportunities → explain → economics scenarios → plan`.

```
1. intents          `intents --customer <ID> [--vertical <v>] [--window FROM..TO]
                    [--buyer-value <$> --margin <$> | --target-cpa <$>] [--intent-file <path>]`
                    → intent taxonomy + cluster economics: profitable / poor / waste / long-tail.
                    Default vertical `personal_loans` (currently the only shipped vertical taxonomy
                    — don't imply others exist). Pass `--buyer-value`/`--margin` (or
                    `--target-cpa`) when you have them; it refines the label per cluster instead of
                    using realized-ROAS bands alone.

2. market refresh   `market refresh --customer <ID> [--max-cost-usd <N>]` — DataForSEO
                    current-market enrichment through the cache; prints the estimated cost BEFORE
                    the call and the spend AFTER, and refuses before any spend if the estimate
                    exceeds `--max-cost-usd` (default 10). Check `market status --customer <ID>`
                    first if unsure of cache coverage/TTL/spend to date, and never skip straight to
                    refresh on an account whose cache is already fresh. Every number this returns
                    carries a `retrieved_at` — never quote one without it (see anti-patterns).

3. competitors      `competitors discover --customer <ID>` (DataForSEO Labs `serp_competitors`,
                    paid, on your top historical intents) → `competitors analyze --customer <ID>`
                    (paid footprint → historical similarity match → themes). `competitors add` /
                    `remove` / `list` manage the known-competitor set directly when the user names
                    domains instead of asking you to discover them.

4. opportunities    `opportunities --customer <ID> [--objective cpa|roas] [--top N]
                    [--grains cluster,device,geo,hour_dow,...] [--buyer-value/--margin |
                    --target-cpa] [--include-rejected]` → ranked Opportunity objects. Default
                    grain is `geo` alone — pass `--grains` explicitly to widen the search.
                    Unsupported grain names come back in `data.unsupported_grains` rather than
                    being silently dropped — surface that if it happens, don't just ignore it.
                    `--include-rejected` surfaces opportunities policy/economics rejected WITH the
                    reason — useful when the user asks "why isn't X considered."

5. opportunity /    `opportunity <id> --explain --customer <ID>` (or the alias `explain <id>
   explain          --customer <ID>`) → the full Opportunity + dossier: historical stats (CVR,
                    CI, shrinkage, uplift, FDR q-value, holdout status), market context, economics
                    scenarios, viability, readiness, policy, and the evidence ids behind every
                    field. This is what you actually read out to the user — never the ranked list
                    alone.

6. economics        `economics --customer <ID> [--buyer-value <$> --margin <$> |
   scenarios        --target-cpa <$>] [--objective cpa|roas]` — deterministic buyer-value/margin
                    or target-CPA derivation with scenario table (conservative / base / historical
                    / improved). Run this standalone when the user wants to stress-test economics
                    inputs independent of a specific opportunity id (opportunity/explain already
                    embeds a scenario table for the ranked candidate).

7. plan             `plan <id> --customer <ID> [--budget <$/day>] [--out <dir>]` → THE hand-off,
                    READ-ONLY: writes `spec.v2.json` (CampaignBuildSpec v2), `brief.yaml` (the
                    planner-skill brief shape, human-editable), and `experiment.md` (hypothesis,
                    eligible inventory, exclusions, economics table, kill/scale criteria, minimum
                    duration, policy notes, evidence list) under `--out` (default
                    `<workspace>/plans/<id>/`). Budget defaults to 5% of the segment's
                    average-week spend / 7, floored at $5/day. Nothing is executed — the printed
                    next step is `apb-gads recipe build --spec <dir>/spec.v2.json --format all`
                    (dry-run), which is a DIFFERENT, write-capable binary behind the normal
                    review → approve → execute gates.
```

## Policy and readiness gates along the way

- `opportunity --explain` carries a `policy` block (`status`, `dropped_signals`,
  `lp_disclosures_required`). A `dropped_signals` entry means a signal was excluded from
  targeting for policy reasons — **never re-propose a dropped/prohibited signal as targeting**
  when you hand-craft anything around the opportunity (see anti-patterns).
- `viability` (`alive`/`last_seen`/`volume_retention`) and `readiness` (from the
  account-intake/decline-investigation SOPs) are both required before recommending `plan` on an
  opportunity — same rule as decline investigation's verdict step. A `blocked` readiness means no
  `plan` recommendation, regardless of how strong the opportunity's economics look.

## What to report

Lead with the ranked shortlist (top N by the requested objective), each with its `confidence` and
the single strongest evidence id. Drill into `explain` only for the ones the user wants to act on
— don't dump every dossier. When you hand off `plan`, name the three output files and the exact
next CLI command to run (verbatim, don't paraphrase it into something that looks executable by
you).
