# Interpreting results

The MCP returns structured data; your job is to translate it into a decision. Don't paste raw JSON —
read it and report the meaning. All of this is read-only analysis. **Google money is in MICROS** —
always convert to currency units (`micros / 1,000,000`) before reporting.

## The verdict doctrine (`gads_get_verdict`)

One decisive verb per campaign, from three gates over the customer's campaigns:

| Verdict | Meaning | Typical proposed response |
|---|---|---|
| **SCALE** | Proven winner with headroom | Increase budget in measured steps |
| **OPTIMIZE** | Working but inefficient; fixable | Tune targeting/creative/bids before scaling |
| **TIGHTEN** | Spending without return; rein in | Reduce budget / narrow targeting / add negatives |
| **CAP** | Limit spend pending a decision | Cap budget; revisit after a defined window |
| **HOLD** | Fine as-is; no action | Leave alone |
| **CUT** | Not salvageable | Pause and redeploy budget |

Reading the payload:
- `summary` is a verdict→count map (e.g. `{TIGHTEN:3}`) — use it for the headline distribution and
  to name the **dominant** verdict (largest count).
- `verdicts[]` are per-campaign rows with the verb + gate reasoning + metrics. Rank by `$` impact to
  find the campaigns that matter most.
- `queue:true` returns the impact-ranked decision queue — use it when the user wants "what first."
- **`include_paused:true` matters:** an active-only window can return `campaign_count:0` (means
  "none active in window", not "broken" or "all healthy"). For a full picture — and to judge
  paused/reactivation candidates — pass `include_paused:true` (`mode` becomes `reactivation`;
  delivery is "n/a" for a paused campaign, so SCALE never fires there).

Growth-first framing: don't reflexively tell a scaler to shrink. Pair every "cut X" with "redeploy
into Y," and read budget-limited winners as a growth signal. On Google specifically, never reflexively
disrupt a converged Smart-Bidding campaign (tROAS/tCPA in a healthy learning state).

## Audits / playbooks (`gads_run_audit`, `agency_list_audits {platform:"google"}`)

- The gads playbook payload is a **nested structured object** (not a flat `{findings, summary}`) —
  e.g. `account-health` returns `{ account, ad_groups, … }`. Read its `summary` (when present) and
  the finding arrays; a large top-level array is offloaded to `result_id` (page via
  `agency_get_result`).
- A low grade / heavy finding count is a **prioritization signal**, not a verdict — combine it with
  `gads_get_verdict` for the action.
- Pick a playbook by description from `agency_list_audits {platform:"google"}` — don't guess a slug.
  The 66-playbook catalogue spans account-health, waste, learning/scaling/turnaround, PMAX, RSA
  quality, bid-strategy audits, and more. Examples: waste → `waste-audit`; overall → `account-health`;
  PMAX → `pmax-audit`; ad copy → `rsa-quality-audit`.
- An unknown slug returns `error.code:"invalid_audit"` (no subprocess) — list first if unsure.

## Performance / GAQL (`gads_get_performance`, `gads_run_gaql`)

- `gads_get_performance` runs one of the **23 catalogue reports** (`campaign-performance-365d`,
  `search-terms-365d`, `pmax-summary`, …). An unknown report → `invalid_report` (no subprocess).
- Per-row fields are raw GAQL-shaped (`campaign.name`, `metrics.cost_micros`, `metrics.conversions`,
  `metrics.conversions_value`, …). Ranking:
  - "biggest / where's the money" → sort by `cost_micros`.
  - "best / worst efficiency" → derive ROAS (`conversions_value / cost`) or CPA (`cost / conversions`).
  - "most seen" → sort by `impressions`.
- **Money is MICROS verbatim** — `costMicros: 5230000` is $5.23. Convert before you report.
- An **empty window is not a failure**: search-term / term-view reports on paused campaigns are
  legitimately empty at a short lookback — use a `-365d` report name. The tool attaches a `note`
  saying so.
- `gads_run_gaql` is the escape hatch for an ad-hoc SELECT (read-guarded: SELECT only, no mutate
  token). Use it when no catalogue report fits — e.g. a custom rank or a single field.

## Capabilities / health (`agency_capabilities`, `gads_health`)

- `agency_capabilities`: `tier` / `scopes` / `google_addon` / `write_policy` explain what's unlocked;
  `available_tool_groups` is the authoritative callable set; `api_versions.google` (v24) grounds
  field expectations. `google_addon:true` is the floor for any Google write.
- `gads_health`: `connected` (the binary ran + creds resolved) + `version` + `customers[]`. If not
  connected, fix the Google credential resolution before costed reads.

## Errors are data, not dead ends
Every tool returns errors as structured `{error:{code,…}}` (often `isError:true`) — never exceptions.
Branch on `code`:
- `no_customer_context` → resolve + pin a customer (or pass `customer_id`).
- `not_authorized` → the customer isn't in the allowlist.
- `invalid_audit` / `invalid_report` / `invalid_query` → use a real slug / report / a SELECT.
- `result_not_found` / `invalid_cursor` → re-run the source query for a fresh `result_id`.
- `insufficient_scope` / `not_entitled` → surface the `google_addon` / `write_policy` upgrade path;
  offer a read-only alternative; **don't loop**.
- the approval `raw.approval_reason` family + `google_managed_op_requires_ad_group` → see
  `reference/safety-and-approval.md`.
