# Campaign type selection — Search vs PMax vs Demand Gen (2026)

Before building anything greenfield, pick the **right engine for the demand state**. Getting this
wrong is the most expensive structural mistake — a Demand-Gen campaign asked to deliver immediate
sales, or a PMax launched onto zero conversion data, burns budget the gates can't recover.

> **One-liner:** **Search captures demand · PMax scales it · Demand Gen creates it.** Use all three
> together at the right time — but introduce them in that order as the account matures.

## The three engines

| | **Search** — capture demand | **PMax** — scale across the funnel | **Demand Gen** — create demand |
|---|---|---|---|
| **Primary purpose** | capture *existing* demand from people actively searching | maximize conversions/revenue across all Google channels via automation | create *new* demand from people not searching yet |
| **Best for** | high-intent keywords, ready-to-buy traffic | eCommerce + lead-gen at scale, accounts with good conversion data | brand awareness, new launches, top-of-funnel, audience expansion |
| **Where it shows** | Google Search + Search Partners | all Google inventory (Search, YouTube, Display, Gmail, Maps, Discover) | YouTube, Discover, Gmail, Display |
| **Strengths** | high-intent, full keyword control, predictable, lower CPA on hot terms | reaches every channel, finds more conversions, automated, great for scale | builds awareness, engaging visual ads, reaches new audiences |
| **Limitations** | limited to search traffic, higher CPC in competitive verticals | less control/transparency, **needs conversion data**, wastes spend on poor signals/feeds | higher CPMs, hard to measure direct ROI, not for capturing high intent |

## Use-when vs not-ideal-when (the decision rows)

| Engine | Use when | **Not** ideal when |
|---|---|---|
| **Search** | want high-intent leads/sales *now*; have specific converting keywords; need full targeting + ad control | trying to build awareness; audience doesn't know you yet; only a small budget for broad reach |
| **PMax** | have conversion data (**~30+ conv / 30 days** ideal); want to scale efficiently; sell multiple products/services | little/no conversion data; need granular control; **tracking not set up properly** |
| **Demand Gen** | want to build awareness; longer sales cycle; launching something new; filling the funnel | need immediate leads/sales; budget too small; no strong creatives/offers |

**Key success factors** — Search: right keywords, compelling copy, strong landing pages, negatives.
PMax: solid conversion tracking, strong product feed (eCom), high-quality assets, clear audience
signals. Demand Gen: thumb-stopping creatives, clear value prop, strong offer, right audience signals.

## How to decide (3 steps)

```
STEP 1  Is there existing demand for the product/service?      YES → SEARCH
STEP 2  Do you have conversion data and want to scale?         YES → PMAX   (~30+ conv/30d)
STEP 3  Do you want to create demand and grow the audience?    YES → DEMAND GEN
```

These compound — a healthy account usually runs **Search first** (capture the demand that exists),
adds **PMax once it has the conversion signal** to feed the automation, and layers **Demand Gen** to
manufacture future demand. Pair this with the verdict framework: don't add PMax to scale until the
existing Search campaigns clear G3 (signal/tracking healthy) — PMax inherits bad signal and wastes.

## Grounding the decision in the CLI

Two native commands encode this doctrine directly (`gads-v0.1.5`):

- **`apb-gads campaign-type-advisor --goal sales|leads|awareness --demand existing|none --signal-strength
  high|medium|low --budget-daily <N>`** — prescriptive: returns the primary engine + the maturity-ordered
  sequence (Search → PMax → Demand Gen) + use-when / not-ideal reasons + blockers. Pass `--customer <CID>`
  to ground the signal strength in the account's trailing-30d conversion volume (overrides the flag).
- **`apb-gads playbook campaign-type-fit --customer <CID>`** — descriptive: audits every ENABLED campaign's
  channel type vs its conversion signal and flags mismatches (`misaligned` Demand-Gen-for-conversions-with-
  no-signal → Search; `premature` PMax-on-thin-signal → Search-first). The type-level companion to `verdict`.

To answer the three questions from raw reads instead:

- **Existing demand? (Step 1)** — `apb-gads plan keyword-ideas` on seed terms / the site. Real search
  volume on intent keywords ⇒ Search has fuel.
- **Conversion data + tracking ready? (Step 2)** — `apb-gads playbook account-health` (conversion
  counts), `apb-gads playbook conversion-tracking-audit` (is tracking actually healthy?), and
  `apb-gads playbook smart-bidding-readiness` (0–90 readiness for tCPA/tROAS). Below the floor ⇒
  **HOLD** on PMax, keep gathering signal on Search.
- **For an existing PMax, is it mature enough to trust/scale?** — `apb-gads playbook pmax-maturity-gate`.

## Building each type (greenfield)

```bash
B="apb-gads --pretty"
# SEARCH — research → structure → RSA → launch-ready spec, then validate + launch (born PAUSED):
$B --customer <CID> plan campaign full --business "<desc>" --url https://<domain> --export-dir /tmp/build
$B validate campaign-spec --from-file /tmp/build/<spec>.json          # exit 3 = fix before launching
$B --customer <CID> orchestrate campaign-launch --from-file /tmp/build/<spec>.json   # dry-run first

# PMAX — assets must exist first; atomic build (budget → campaign → assets → asset groups → signals):
$B --customer <CID> plan campaign pmax --business "<desc>" --final-url https://<domain> --output /tmp/pmax.json
$B validate pmax-spec --from-file /tmp/pmax.json
$B --customer <CID> orchestrate pmax-build --from-file /tmp/pmax.json   # dry-run first

# DEMAND GEN — the third pillar (gads-v0.1.5). Pre-create video + logo assets, then:
$B --customer <CID> plan campaign demand-gen --campaign-name "<name>" --budget-micros 50000000 \
    --final-url https://<domain> --geo-target-id 2840 --language-id 1000 \
    --bidding-strategy MAXIMIZE_CONVERSIONS --target-cpa-micros 20000000 --ad-group-name "<ag>" \
    --video-asset customers/<CID>/assets/<v> --logo-asset customers/<CID>/assets/<l> > /tmp/dg.json
$B validate demand-gen-spec --from-file <(jq .spec /tmp/dg.json)            # exit 3 = fix before launching
$B --customer <CID> orchestrate demand-gen-build --from-file <(jq .spec /tmp/dg.json)   # dry-run first
$B --customer <CID> orchestrate demand-gen-build --from-file <(jq .spec /tmp/dg.json) --validate-only --execute  # SERVER_VALIDATED Google round-trip
```

Demand Gen is ad-group-based (not PMAX asset groups): a single ad group carries audience signals +
one Demand Gen video-responsive ad. Bidding accepts MAXIMIZE_CLICKS / MAXIMIZE_CONVERSIONS (tCPA) /
MAXIMIZE_CONVERSION_VALUE (tROAS). Born PAUSED; `--validate-only` is the source of truth for the v24
field shapes. Full launch recipes: `references/workflows.md` § W6 + `examples.md`.
