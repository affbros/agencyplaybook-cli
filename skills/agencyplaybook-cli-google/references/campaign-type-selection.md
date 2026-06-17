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

## Grounding the decision in the CLI (use existing reads)

Native `campaign-type-advisor` / `campaign-type-fit` commands are planned but not yet shipped —
until then, answer the three questions from existing reads:

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
```

**Demand Gen has no greenfield builder in the CLI yet** — set it up in the Google Ads UI for now (a
native `plan campaign demand-gen` builder is a planned third pillar, not yet shipped).
Full launch recipes: `references/workflows.md` § W6 + `examples.md`.
