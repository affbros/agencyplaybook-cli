# SOP: Creative forensics

Triggered by: "which RSA/asset angles won historically", "creative economics forensics", "why did
this ad's quality score lag even though the economics were strong", "what headline angles should
we reuse".

```
1. Intake check   Confirm account intake has run (sops/account-intake.md) so `ads` history exists
                  in the workspace. Scope `extract --datasets ads` if you only need this SOP and
                  haven't pulled ads history yet.

2. creative       `creative --customer <ID> [--window YYYY-MM-DD..YYYY-MM-DD]` — RSA / asset /
                  headline economics vs CVR/CPA, with angle classification. Default window is the
                  workspace's full `ads` history. Read the angle classification alongside the raw
                  economics — a winning angle with thin volume is a different signal than a
                  winning angle with deep, stable history.

3. qs (paired     `qs --customer <ID> [--window ...]` — quality-score forensics: strong economics
   when QS is       paired against weak QS components. Run this alongside `creative` whenever the
   implicated)     user's question is "why didn't this convert as well as its economics suggest"
                  or when a decline-investigation hypothesis (sops/decline-investigation.md,
                  step 3–4) names ad relevance / landing-page experience / expected CTR as a
                  candidate factor. `qs` never asserts causation on its own — pair a QS-component
                  weakness with the creative angle it's attached to before drawing a conclusion.

4. Rank angles    Rank the angle classes by the economics `creative` returns (not by raw
                  impressions or by recency) — the point of this SOP is finding what to REUSE, not
                  what ran most. Note which angles are UNDETERMINED or thin-sample rather than
                  silently dropping them from the ranking.

5. Hand-off       Winning angles feed `plan <opportunity-id>`'s RSA seeds (opportunity-hunt SOP —
                  RSA seeds drawn from the best historical RSA angles, linted to length limits).
                  If the user wants net-new copy drafted from these angles (not just the
                  historical economics reported), route to `agencyplaybook-planner`, which layers
                  the `ad-creative` + `ad-copy-verification-standard` skills — this skill reports
                  what won historically, it does not draft new ad copy itself.
```

## What to report

Lead with the top 2–3 angle classes by economics, each with its evidence id, sample depth, and
(when `qs` was run) the paired quality-score read. Always state the window the numbers came from.
Never present a thin-sample angle with the same confidence as a deep one — carry the confidence
field through, don't flatten it into a single ranked list with no caveat.

## Anti-patterns specific to creative forensics

- Treating a strong `creative` economics read as license to skip `qs` when the user's actual
  question is about quality score, not raw performance.
- Drafting new ad copy directly inside this SOP instead of routing to `agencyplaybook-planner` +
  `ad-creative` for that step — this skill's job stops at "here's what historically won and why."
