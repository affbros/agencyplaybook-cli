# SOP: Negative mining

Triggered by: "mine negative keywords from history", "what's wasting historical spend", "find
waste themes", "what should we exclude before relaunching".

```
1. Intake check   Confirm account intake has run (sops/account-intake.md) so `waste` has search-
                  term history to cluster against. If the workspace is empty for `search_terms`,
                  run `extract` first (scoped with `--datasets search_terms` if you only need
                  this SOP).

2. waste          `waste --customer <ID> [--min-spend <$>]` — negative themes clustered, with
                  spend. Default `--min-spend` is $500 (theme-level, not per-term) — lower it only
                  when the user explicitly wants long-tail/low-spend themes surfaced, and say so
                  (a lower floor pulls in noisier, less-confident clusters). This command NEVER
                  applies anything — it is analysis only, exactly like the header says.

3. Cross-check    If a waste theme overlaps a cluster `intents` already classified `waste` or
   with intents    `poor`, say so explicitly — it corroborates the finding with a second,
                  independently-derived signal. If it doesn't overlap, don't force the connection.

4. Policy check   Before handing a negative list to anyone downstream, check whether any waste
                  theme term is itself a policy-sensitive signal (e.g. overlaps a
                  `dropped_signals` entry from a prior `opportunity --explain` run on this
                  customer). A term Google's policy layer already excludes from targeting doesn't
                  need to be re-proposed as a negative with extra emphasis — note it plainly
                  instead.

5. Hand-off       Negative themes from this SOP are one of the direct inputs to
                  `plan <opportunity-id>` in the opportunity-hunt SOP (`experiment.md`'s
                  exclusions section) and to the decline-investigation SOP's step 8 (experiment
                  exclusions). Cite the waste evidence ids when they feed either.
```

## What to report

Report clusters by spend (highest first), each with its theme, spend, and evidence id — not a
flat term list. State the `--min-spend` floor used so the user knows what was filtered out. Never
imply a negative list from this command has been applied anywhere — it hasn't; there is no apply
path in this binary at all.

## Anti-patterns specific to negative mining

- Reporting a waste theme's spend as a certainty when the underlying window is short or thin —
  carry the same evidence-id discipline as everywhere else (`reference/anti-patterns.md`).
- Treating a low-spend theme excluded by the `--min-spend` floor as "no waste there" — it means
  "not surfaced at this floor," not "clean."
