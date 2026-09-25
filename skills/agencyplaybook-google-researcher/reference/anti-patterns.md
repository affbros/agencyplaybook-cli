# Anti-patterns — the failure modes to avoid

This list is shared, unchanged, with the live-account decline-investigation SOP (see
`agencyplaybook-google-brain`), plus three additions specific to this workbench's market/audience
surfaces. Do not paraphrase or drop an item.

## Shared with the decline-investigation SOP

1. **Quoting a number without an evidence id.** Every number that reaches an answer must carry an
   evidence id that would pass `evidence::validate()` — this is the rule every other item below
   is a special case of.
2. **Computing a new ratio from two tool results.** Don't derive CPA from a CPC number here and a
   CVR number there yourself — use the comparison/derived tool (`analyze regimes` derives CPA from
   CPC+CVR breaks the correct way; don't hand-roll it).
3. **Treating "not_supported" as "false".** A factor or field the data can't determine is not
   evidence *against* it — it's an absence of evidence, and must be reported as such.
4. **Pooling across a tracking-change boundary.** If `analyze regimes` (or any tool) flags a
   possible tracking change, do not average/compare metrics from before and after it as if they
   were the same measurement — stop and ask before continuing past the boundary.
5. **Recommending a restart without a viability AND readiness block.** Every restart
   recommendation needs both `viability` (is the opportunity still alive / how much volume
   remains) and `readiness` (`analyze readiness`'s ready / ready_with_caveats / blocked) cited —
   never just one.
6. **Presenting an inferred cross-grain composition as observed.** If a finding is composed by
   combining results across grains/dimensions inferentially, say so — never present it with the
   same confidence as a directly observed reading.
7. **Using causal language on a `descriptive` item.** `analyze decline` and similar are
   DESCRIPTIVE by design — say "the cost went to X", never "X caused it", unless a ledger event or
   a controlled comparison (`analyze compare`) supports the causal claim.
8. **Inferring a configuration change for a period the ledger does not cover.** Anything before
   ledger coverage begins is "change: unknown" — do not infer what changed from a step-shaped
   break alone when there's no ledger entry to confirm it.

## Added for this workbench

9. **Never propose a prohibited signal as targeting.** If `opportunity --explain`'s `policy` block
   lists a `dropped_signals` entry, that signal was excluded for a policy reason — do not
   re-surface it as a targeting suggestion, in a negative list emphasis, or anywhere else framed
   as actionable.
10. **Never quote a DataForSEO number without its `retrieved_at`.** Every market-layer number
    (`market refresh`, the `market` block inside `opportunity --explain`) carries a `retrieved_at`
    timestamp — cite it alongside the number, every time, so staleness is visible to the reader.
11. **UNDETERMINED demographics are not absence.** `audiences` returning `UNDETERMINED` for a
    segment means the data can't classify it — not "this segment doesn't exist" or "there's no
    signal here." Report it as undetermined, not as a negative finding.

## Where these apply

All eleven apply throughout every SOP in this skill, not only `sops/decline-investigation.md` —
items 1–4, 6–8 are general evidence discipline (account intake, opportunity hunt, negative mining,
creative forensics all produce numbers and derived claims); item 5 applies wherever a restart/
relaunch is recommended (decline investigation step 7, opportunity hunt's `plan` hand-off); items
9–11 apply specifically wherever this workbench touches policy signals, DataForSEO market data, or
the `audiences` command.
