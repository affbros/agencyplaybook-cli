# AgencyPlaybook copy doctrine — what wins when the layered skills disagree

The planner composes four upstream skills. They are good; they also contradict each other and, in
two places, contradict the evidence our RSA linter (`rust/gads/crates/ads-core/src/rsa_quality.rs`)
is built on. This file is the tie-breaker. **The binary's lint score is the final arbiter** — if a
rule here and the lint disagree, the lint is right and this file has a bug.

## Precedence (highest first)

1. **Platform hard limits** — 30 / 90 / 15 chars, 3–15 headlines, 2–4 descriptions, ≤3 RSAs per ad
   group, policy (no unsupported claims). Source: Google; enforced by `ad-validate` / `validate
   campaign-spec`. Non-negotiable.
2. **`ad-copy-verification-standard`** (fourteenwm) — every claim traces to the landing page or a
   verified review. *Empty > Inaccurate.* Overrides every "make it punchy" instinct below.
3. **This doctrine** (the evidence-based rules in the next section).
4. **`ad-creative`** (coreyhaines31) — angles, modes, platform specs, Meta rules.
5. **`ad-copy-generation-framework`** (fourteenwm) — distribution formula, "Four Words to Value",
   continuity, pre-qualify. Reference, not mandate.
6. **`ads`** (coreyhaines31) — strategy only. Its `rsa-output-spec` is not used.

## The evidence-based rules (why we override two upstream rules)

Large-N data (Optmyzr, ~20k accounts, 2024 + Apr-2026 studies; corroborated in the June-2026
PPC-Mastery research in `rust/gads/docs/tasks/2026-06-09-ppcmastery-research-and-opportunities.md`):

| Rule | Upstream says | We do | Why |
|---|---|---|---|
| **Case** | `ad-copy-generation-framework` Tier-1: "Capitalize Each Word (Title Case)" | **Sentence case.** Title Case is a lint *penalty* (`is_title_case`) | Title Case ran **3.7× worse CPA** ($27.47 vs $7.46) — the largest single formatting effect measured |
| **Headline count** | Both frameworks: exactly 15 | **8–10 unique, strong headlines; 15 only if each is genuinely distinct.** Never pad with rewordings | 1→2→3 RSAs and 10→15 headlines show small, diminishing lift; filler dilutes |
| **Headline length** | — | Prefer **< 20 chars** where the claim survives; keep 2–3 short ones | Short headlines: $9.35 vs $18.27 CPA |
| **Descriptions** | 4 × ≤90 | **2–3 descriptions in the 61–70 char band**; a 4th only if distinct | Maxing characters showed no improvement; 61–70 was the sweet spot |
| **Pinning** | `ads`: "default unpinned"; framework: pin brand | **Partial pinning**: pin only what must be controlled (brand / legal / offer), and pin **2–3 alternatives to the same position** | Partial-pin $13.68 vs $32.57–$61.11 for full-pin / no-pin |
| **Ad Strength** | Implicit "reach Excellent" | Treat as a completeness checklist, **never a KPI**; accept "Average" | "Average" ads had the best CPA/CVR in both studies; Ad Strength is not an Ad Rank factor |
| **RSAs per ad group** | up to 3 | **1 strong RSA**; a 2nd only as a deliberate test | Incremental lift 1→2 = +6.6%, 2→3 = +3.7% |
| **Refresh** | edit in place | **New ad, pause old** (`orchestrate ad-refresh`) | In-place edits re-enter learning and break history |

## What to take from each skill (and what to leave)

**`ad-copy-verification-standard`** — take all of it. Scrape first (WebFetch / agent-browser), keep
a source map (`claim → URL/quote`) in `build/copy-sources.md`, and stop if the scrape fails.

**`ad-creative`** — take: the eight angles (map to our `purpose` tags below), the four modes, the
"headlines must work in any combination" rule, Meta primary-text front-loading. Leave: the
"15 headline mix" as a hard target.

**`ad-copy-generation-framework`** — take: the distribution *ratio* (keyword : social proof : USP :
CTA ≈ 3 : 2 : 4 : 2, scaled down to our count), "Four Words to Value", continuity with the landing
page H1, pre-qualify headlines for lead-gen. Leave: Title Case, the pun slot, sentiment scoring as a
target.

**`ads`** — take: intent ladder (brand → high-intent non-brand → competitor → problem-aware), brand
bidding default, "capture before you create", match-type loosening rules, PMAX guardrails, the
weekly search-terms ritual (it is our `recipe search-terms`). Leave: `rsa-output-spec.md` entirely.

## Angle → `purpose` tag mapping (what `rsa_quality::classify_angle` expects)

| `ad-creative` angle | `purpose` value | Notes |
|---|---|---|
| keyword / relevance | `keyword_relevance` | ≥1 headline mirrors the ad group's core term; H1 candidates |
| outcome / benefit | `benefit` | |
| social proof | `trust` | only with a verified source |
| urgency / offer | `urgency` | only if the offer is real and dated |
| identity ("for X") | `identity` | |
| comparison / contrarian | `differentiation` | claims must be verifiable |
| CTA | `cta` | ≥1 headline, ≥1 description |
| pain point / curiosity | `hook` | sparingly on Search; primary tool on Meta |

## Meta (`apb`) builds

Same precedence. Platform specs from `ad-creative` (primary text 125 visible / 2,200 max; headline
40; description 30). Andromeda-era doctrine from `ads`: creative volume over polish, broad audience +
specific creative, long primary text for context. Grounding rule unchanged. Note the Meta sandbox
cannot create creatives (Page permission) — creative validation there is structural only.
