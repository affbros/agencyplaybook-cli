# SOP: Account intake

Triggered by: first touch on a customer, "profile this account", "is there enough history to
research here", "what data do we even have".

```
0. Resolve + confirm  Turn a name/id into a numeric customer_id and state it back to the user
                       before any costed call. (Same discipline as the brain skill's
                       account-context rule — never guess.)

1. inspect             `inspect --customer <ID>` — account profile + data-availability probe.
                       This is Phase 0 and the FIRST command on any account: it tells you what
                       exists before you spend anything pulling it. Read the coverage/availability
                       fields before deciding what to extract.

2. extract              `extract --customer <ID> [--datasets <...>] [--months <N>]
                       [--monthly-years <N>] [--resume]` — pulls history into the local workspace
                       (NDJSON + manifest). Default depth is 37 months weekly-tier / 11 years
                       monthly-tier (Google's own retention ceiling — don't ask for more). Use
                       `--datasets` to scope a re-pull; use `--resume` to continue from the
                       manifest instead of re-pulling completed chunks (idempotent, safe to retry).
                       This is the only command in the surface that materially waits — budget for
                       it, don't assume it returns instantly.

3. workspace status     `workspace status --customer <ID>` — confirm what actually landed
                       (location, manifest summary, sizes) before analyzing off it. If a prior
                       GAQL pull exists for this customer outside the researcher's own format
                       (`fa` or `poc` layout), use `workspace import --from <DIR> --source-format
                       fa|poc` instead of re-extracting — it keeps provenance and needs no
                       re-pull.

4. analyze readiness   `analyze readiness --customer <ID>` — tracking, policy, landing page,
                       negatives → `ready` | `ready_with_caveats` | `blocked`. Run this even when
                       the user only asked "profile the account" — readiness gates every later
                       recommendation (see the decline-investigation and opportunity-hunt SOPs: a
                       `blocked` verdict there means no relaunch recommendation, full stop).
```

## What to report

State the `customer_id` read, the coverage window `inspect` found, what `extract` actually pulled
(datasets × depth, not "everything"), and the `readiness` status with its `items[]`. If readiness
is `blocked`, say so plainly and stop before any opportunity/restart talk — don't soften it into a
caveat.

## Anti-patterns specific to intake

- Skipping `inspect` and extracting blind — you can pull months of history into a workspace with
  no availability for the dataset you actually need.
- Re-extracting a customer that already has a workspace instead of checking `workspace status`
  first (wastes the Google Ads quota this binary shares with everything else hitting the account).
- Treating `ready_with_caveats` as `ready` when summarizing — the caveats are load-bearing; name
  them.
- See `reference/anti-patterns.md` for the full carried-over list (evidence ids, `not_supported`,
  etc. — they apply from `inspect` onward, not just in decline investigation).
