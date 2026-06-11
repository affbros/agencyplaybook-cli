# Field-level policy limits (Google Ads v24)

`apb-gads` validates inputs against Google's field limits **before** the API call and rejects
out-of-range values locally (the single source of truth is `policy.rs`). Knowing these prevents a
round-trip rejection. **Character counts are double-width-aware: CJK characters (Han, Hiragana,
Katakana, Hangul, fullwidth) count as 2.**

## RSA (Responsive Search Ad)

| Field | Count | Per-item limit |
|---|---|---|
| Headlines | 3–15 | ≤ 30 chars |
| Descriptions | 2–4 | ≤ 90 chars |
| Path1 / Path2 | optional | ≤ 15 chars each |
| Final URLs | ≥ 1 | ≤ 2048 bytes |

Doctrine on top of the limits (see `doctrine.md`): aim for **8–10 sentence-case headlines** (several
< 20 chars) and **2–3 descriptions** (sweet spot 61–70 chars); partial pinning only.

## Performance Max — text assets (per asset group)

| Asset type | Count | Per-item limit |
|---|---|---|
| HEADLINE | 3–15 | ≤ 30 chars |
| LONG_HEADLINE | 1–5 | ≤ 90 chars |
| DESCRIPTION | 2–5 | ≤ 90 chars (**≥1 must be < 60 chars**) |
| BUSINESS_NAME | 1 | ≤ 25 chars |
| **Search themes** | ≤ **25 per asset group** | ≤ 80 chars each |

> Some vendor guides wrongly say 50 search themes — the API cap is **25/asset group**; the CLI
> rejects the 26th pre-API.

## Performance Max — image/video assets (per asset group)

| Asset type | Count | Ratio | Min size | Notes |
|---|---|---|---|---|
| MARKETING_IMAGE | 1–20 | 1.91:1 | 600×314 | ≤ 5120 KB |
| SQUARE_MARKETING_IMAGE | 1–20 | 1:1 | 300×300 | |
| PORTRAIT_MARKETING_IMAGE | 0–20 | 4:5 | 480×600 | optional |
| LOGO | 1–5 | 1:1 | 128×128 | |
| LANDSCAPE_LOGO | 0–5 | 4:1 | 512×128 | optional |
| YOUTUBE_VIDEO | 0–5 | — | — | by video id |

PMAX build hard facts: needs a **non-shared** budget (shared + portfolio strategies are rejected);
bidding at create is `MAXIMIZE_CONVERSIONS` (+optional tCPA) or `MAXIMIZE_CONVERSION_VALUE`
(+optional tROAS) only; assets must exist before the asset group references them (the orchestrator
handles ordering).

## Extension / feed assets

| Asset | Limits |
|---|---|
| Sitelink | link_text ≤ 25; description1/2 ≤ 35 |
| Callout | text ≤ 25 |
| Structured snippet | header from a 13-value allowlist; 3–10 values, each ≤ 25 |
| Promotion | promotion_target ≤ 20; code ≤ 15; percent_off 1–100 |
| Price | 3–8 offerings; header/description ≤ 25 |
| Call | 2-letter country code; phone 7–15 digits |

## URLs

- Final URL ≤ **2048 bytes**; criterion (webpage/placement) URL ≤ **2047 bytes**.
- Must start with `http://` or `https://`. **Never use `example.com`/`test.com`** in live ad URLs
  — placeholder domains are an account-suspension signal.

## Bid modifiers

| Criterion | Range | Note |
|---|---|---|
| Device | 0.0 – 10.0 | `0.0` = opt-out (exclude) |
| Location | 0.1 – 10.0 | |
| Ad schedule | 0.1 – 10.0 | |

Remember (see `doctrine.md`): the five Smart Bidding strategies **ignore** most bid modifiers —
use conversion-value rules / target tuning instead.

## Keywords & structural caps

- Keyword text ≤ 80 chars, ≤ 10 words; rejects `, ! @ % ^ ( ) = [ ] ; ~ \` < > ? \ | *` (`*` is
  allowed only for negatives).
- 20,000 keywords / ad group · 10,000 negatives / campaign · shared negative list 5,000 entries / 20 lists per manager.
- Campaign name ≤ 128 · ad-group name ≤ 255.
- 10,000 campaigns / account · 20,000 ad groups / campaign · 50 active text ads / ad group · 100 PMAX campaigns / account · 100 asset groups / PMAX campaign.
- **10,000 mutate operations per request** (bulk surfaces batch under this).
