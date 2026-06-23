# Interpreting results

The MCP returns structured data; your job is to translate it into a decision. Don't paste raw
JSON — read it and report the meaning. All of this is read-only analysis.

## The verdict doctrine (`meta_get_verdict`)

One decisive verb per campaign, from three gates over the account's campaigns:

| Verdict | Meaning | Typical proposed response (NOT applied in v1) |
|---|---|---|
| **SCALE** | Proven winner with headroom | Increase budget in measured steps |
| **OPTIMIZE** | Working but inefficient; fixable | Tune targeting/creative/bids before scaling |
| **TIGHTEN** | Spending without return; rein in | Reduce budget / narrow targeting / cut weak entities |
| **CAP** | Limit spend pending a decision | Cap budget; revisit after a defined window |
| **HOLD** | Fine as-is; no action | Leave alone |
| **CUT** | Not salvageable | Pause / kill and redeploy budget |

Reading the payload:
- `summary` is a verdict→count map (e.g. `{TIGHTEN:45, HOLD:5, OPTIMIZE:4}`) — use it for the
  headline distribution and to name the **dominant** verdict (largest count).
- `verdicts[]` are per-campaign rows with the verb + reasoning + metrics (spend, roas, …).
  Rank by `spend` (or `$` impact) to find the campaigns that matter most.
- `queue:true` returns the impact-ranked decision queue — use it when the user wants "what
  first."
- **`include_paused:true` matters:** an active-only window can return `campaign_count:0`
  (means "none active in window", not "broken" or "all healthy"). For a full picture — and to
  judge paused/reactivation candidates — pass `include_paused:true`.

Growth-first framing: don't reflexively tell a scaler to shrink. Pair every "cut X" with
"redeploy into Y," and read budget-limited winners as a growth signal. SCALE > defensive cuts
when the account is trying to grow.

## Audits / playbooks (`meta_run_audit`, `agency_list_audits`)

- **Grade** (A–F) + **score** (0–100) + **summary** are the headline. A low grade is a
  **prioritization signal**, not a verdict — combine it with `meta_get_verdict` for the action.
- **`findings`** = what's wrong (entities, $ at stake); **`recommendations`** = suggested
  fixes. Large arrays page via `agency_get_result` (`result_id` + `has_more`).
- Pick a playbook by `pillar` / `description` from `agency_list_audits` — don't guess a slug.
  Pillars: **learning** (early-life / consolidation), **signal** (creative / targeting /
  tracking quality), **scaling** (budget / bid-strategy / Advantage+), **turnaround** (anomaly
  / recovery / waste). Examples: waste → `waste-audit`; fatigue → `fatigue-index`;
  over-frequency / saturation → `saturation`; conversion drop-off → `funnel-leak`; structure →
  `cbo-vs-abo-audit`; overall → `health-score`; weekly → `weekly-digest`.
- An unknown slug returns `error.code:"invalid_audit"` (no HTTP call) — list first if unsure.

## Performance metrics (`meta_get_performance`, `meta_compare_performance`)

- **`totals`** (spend / impressions / clicks) summed across **all** rows is the headline.
- Per-row fields you'll reason over: `spend`, `impressions`, `clicks`, `ctr`, `cpc`, `cpm`,
  `reach`, `frequency`, `actions`. Ranking:
  - "biggest / where's the money" → sort `rows` by `spend`.
  - "best / worst efficiency" → sort by CTR / CPC / ROAS as appropriate.
  - "most seen / reach" → sort by `impressions` / `reach`.
- **Frequency** rising while CTR falls ⇒ likely fatigue (corroborate with `fatigue-index`).
- `meta_compare_performance` deltas explain **direction** (why CPA/ROAS moved); the comparison
  is by window **length in days**, not arbitrary calendar dates.
- `source` tells you which path served the read: `insights` (default rich rows) vs `metrics`
  (when you passed explicit `metrics[]`/`breakdowns[]`).

## Capabilities / health (`agency_capabilities`, `meta_health`)

- `agency_capabilities`: `agency_entitled` + `account_scope` decide single vs agency framing;
  `available_tool_groups` is the authoritative callable set; `tier` / `scopes` explain what's
  unlocked; `api_versions` (Meta v25.0 / Google v24) ground field expectations.
- `meta_health`: `connected` (backend up) + `token_valid` (key resolved). If `token_valid` is
  false, the key didn't resolve — fix that before costed reads.

## Errors are data, not dead ends
Every tool returns errors as structured `{error:{code,…}}` (often `isError:true`) — never
exceptions. Branch on `code`:
- `validation_failed` (no account context) → resolve + pin an account.
- `invalid_audit` → list audits and pick a real slug.
- `not_authorized` → the account isn't in the allowlist.
- `result_not_found` / `invalid_cursor` → re-run the source query for a fresh `result_id`.
- `insufficient_scope` / `not_entitled` → surface the upgrade path; offer a read-only
  alternative; **don't loop**.
