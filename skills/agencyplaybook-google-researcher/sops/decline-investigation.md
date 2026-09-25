# SOP: Decline investigation

The historical, CLI-driven version of the AgencyPlaybook MCP brain's investigation SOP
(`agencyplaybook-google-brain/reference/decline-investigation.md`) — **the steps and discipline
are carried over unchanged**, re-pointed at `apb-gads-researcher` commands instead of live
`gads_*` MCP tools, because a decline investigation runs against history whether or not the
account is live-audited today.

Triggered by: "why did campaign X stop being profitable", "should we restart X", "what changed in
X around \<date\>", "find alpha / hidden pockets / what used to work".

```
0. Frame        Account intake already ran (see sops/account-intake.md): inspect → extract →
                workspace status → analyze readiness. If not, run it first — you need coverage
                and a readiness read before anything below is trustworthy.

1. Regimes      `analyze regimes --customer <ID>` → when the economics broke: CPC and CVR change
                points found SEPARATELY, CPA derived from the two (never fit directly on CPA).
                STOP and tell the user if the result is insufficient_data (exit 3) or flags a
                possible tracking change — ask before continuing past a tracking-change boundary.

2. Decline      `analyze decline --customer <ID>` → level-1 CPC/CVR split and ranked factors
                around the break. This is DESCRIPTIVE: say "the cost went to X", never "X caused
                it" unless you have a ledger event or a controlled comparison (step 4). Anything
                before ledger coverage begins is "change: unknown" — never infer a configuration
                change for a period the ledger doesn't cover.

3. Hypotheses   Write 2–4 hypotheses, each naming the evidence id that motivated it and the
                command that would confirm/refute it. E.g. "H2: broad-match expansion drove CVR
                loss → E11; test: `analyze compare --dimension match_type` on the 8 weeks either
                side of the break; expect a mix effect ≥ 0.15."

4. Test         Run the named commands — chiefly `analyze compare --customer <ID> --dimension
                <match_type|device|geo|intent|...>` to compare two windows along one dimension.
                Each hypothesis ends SUPPORTED / REFUTED / INCONCLUSIVE with the evidence ids that
                decided it. Pull in `qs` (quality-score forensics) or `geo`/`creative` when the
                factor split implicates quality score, geography, or creative.

5. Pockets      `intents --customer <ID> --window <profitable-regime>` → which intent clusters
                carried the good period (profitable / poor / waste / long-tail split).
                `opportunities --customer <ID>` → ranked alpha in that same regime. These feed the
                opportunity-hunt SOP if the verdict below is RELAUNCH or RESTRUCTURE.

6. Readiness    `analyze readiness --customer <ID>` (re-check if account intake ran a while ago —
                policy/tracking state can move) → ready | ready_with_caveats | blocked. A
                `blocked` account gets NO relaunch recommendation, full stop — fix tracking/policy/
                landing-page issues first, and say so plainly.

7. Verdict      RELAUNCH (isolated, tighter) / RESTRUCTURE (split by intent/device/geo) / RETIRE
                — cite the single strongest evidence id for each claim, and for anything you
                propose restarting, cite BOTH the viability signal (from `opportunities`/
                `opportunity --explain`) AND the readiness block from step 6. Never recommend a
                restart on one without the other.

8. Experiments  ≤ 3, staged, each: change, eligible inventory (terms/clusters/geos from step 5),
                exclusions (from the negative-mining SOP's `waste` output), budget/bid, primary
                metric, expected effect size (from evidence), minimum duration, kill threshold,
                rollback framing. These are the direct input to `plan <opportunity-id>` in the
                opportunity-hunt SOP.

9. Hand-off     Offer `plan <opportunity-id>` (opportunity-hunt SOP) to produce the
                CampaignBuildSpec v2 + brief + experiment sheet. Never suggest applying anything
                directly — this binary has no write path; the hand-off spec goes through
                `agencyplaybook-planner` / `apb-gads recipe build --spec`, which is where the
                normal approval handshake + human YES lives.
```

## Anti-patterns (carried unchanged from the live-account SOP — see `reference/anti-patterns.md`
for the full, verbatim list and the 3 additions)

The eight shared failure modes apply at every step above without exception: quoting a
number with no evidence id, computing a new ratio from two tool results instead of asking for the
comparison tool to do it, treating `not_supported` as `false`, pooling across a tracking-change
boundary, recommending a restart without both blocks, presenting an inferred cross-grain
composition as observed, causal language on a `descriptive` item, and inferring a configuration
change for a period the ledger doesn't cover.
