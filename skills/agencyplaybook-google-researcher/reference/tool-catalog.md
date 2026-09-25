# Tool catalogue — `apb-gads-researcher`

Verified against `apb-gads-researcher --help` / `<command> --help` — re-verify this file against
the binary's own `--help` output after any CLI update; it must never drift from the binary.
**18 top-level commands, 28 leaf commands total.** Full per-flag pages: the CLI's own generated
per-command docs (auto-generated from `--help`, do not hand-edit those).

Every command accepts the global flags listed in `SKILL.md` under "Global flags"
(`--customer --config --workspace --pretty --no-color --format --output --redact --no-input`);
only command-specific flags are repeated below.

When the AgencyPlaybook MCP server is available, 10 of these are also exposed as MCP tools in the
`gads-research` group — the "MCP tool" column names the wrapper where one exists. The MCP wrapper
is a **subprocess spawn of the same binary** — nothing about the CLI's read-only guarantee changes
when called that way.

| Command | Leaf(s) | What it does | Key flags beyond global | MCP tool |
|---|---|---|---|---|
| `inspect` | `inspect` | Account profile + data-availability probe. Phase 0 — run first on any account. | — | `gads_research_inspect` |
| `extract` | `extract` | Pull history into the workspace (NDJSON + manifest). | `--datasets <list>` `--months <N>` (≤37) `--monthly-years <N>` (≤11) `--resume` | `gads_research_extract` (long-running; 180s timeout) |
| `analyze regimes` | 1 of 4 | When economics broke: CPC and CVR change points found separately, CPA derived. | — | `gads_research_analyze` |
| `analyze decline` | 1 of 4 | Why: level-1 CPC/CVR split + ranked factors around a break (DESCRIPTIVE). | — | `gads_research_analyze` |
| `analyze compare` | 1 of 4 | Compare two windows along one dimension (match type, device, geo, intent, …). | — | `gads_research_analyze` |
| `analyze readiness` | 1 of 4 | Restart readiness: tracking, policy, LP, negatives → ready \| ready_with_caveats \| blocked. | — | `gads_research_analyze` |
| `intents` | `intents` | Intent taxonomy + cluster economics: profitable / poor / waste / long-tail. | `--vertical` (default `personal_loans`) `--window FROM..TO` `--intent-file <path>` `--buyer-value` `--margin` `--target-cpa` `--current-cpc` | `gads_research_intents` |
| `audiences` | `audiences` | Age/gender/income/parental/in-market over-index. **DESCRIPTIVE ONLY.** | `--window` | — (CLI-only) |
| `geo` | `geo` | Geo economics, policy-tagged (postal level = analysis only, never a targeting output). | `--level {region,metro,city,postal}` `--intent` `--window` | — (CLI-only) |
| `waste` | `waste` | Negative themes clustered, with spend. Never applied. | `--min-spend` (default 500) | — (CLI-only) |
| `creative` | `creative` | RSA/asset/headline economics vs CVR/CPA, angle classification. | `--window` | — (CLI-only) |
| `qs` | `qs` | Quality-score forensics: strong economics × weak QS components. | `--window` | — (CLI-only) |
| `competitors add` | 1 of 5 | Add a known competitor domain. | — | `gads_research_competitors` |
| `competitors remove` | 1 of 5 | Remove a competitor domain. | — | `gads_research_competitors` |
| `competitors list` | 1 of 5 | List known + discovered competitors. | — | `gads_research_competitors` |
| `competitors discover` | 1 of 5 | DataForSEO Labs `serp_competitors` (paid) on top historical intents. | — | `gads_research_competitors` |
| `competitors analyze` | 1 of 5 | Paid footprint → historical similarity match → themes. | — | `gads_research_competitors` |
| `market refresh` | 1 of 2 | DataForSEO current-market enrichment through the cache; prints estimated cost before, spend after. | — | `gads_research_market_refresh` |
| `market status` | 1 of 2 | Cache coverage, TTLs, spend to date. | — | — (CLI-only; check before `refresh`) |
| `economics` | `economics` | Deterministic economics: buyer value/margin or target CPA, scenarios. | `--buyer-value` `--margin` `--target-cpa` `--objective {cpa,roas}` | — (CLI-only; also embedded in `opportunity --explain`) |
| `opportunities` | `opportunities` | Ranked Opportunity objects. | `--objective` `--top` (default 20) `--grains` (default `geo`) `--buyer-value` `--margin` `--target-cpa` `--include-rejected` | `gads_research_opportunities` |
| `opportunity` | `opportunity <id>` | The full Opportunity + dossier. | `--explain` | `gads_research_opportunity` |
| `explain` | `explain <id>` | Alias of `opportunity <id> --explain`. | — | `gads_research_opportunity` (via `--explain`) |
| `plan` | `plan <id>` | CampaignBuildSpec v2 + brief + experiment sheet for an opportunity. READ-ONLY — writes local files only. | `--budget` `--out` | `gads_research_plan` |
| `workspace status` | 1 of 3 | Workspace location, manifest summary, sizes. | — | — (CLI-only) |
| `workspace clear-cache` | 1 of 3 | Clear derived (regenerable) caches; `--market` also clears the DataForSEO cache. | `--market` | — (CLI-only) |
| `workspace import` | 1 of 3 | Import an existing GAQL pull into the workspace format — no re-pull, provenance kept. | `--from <DIR>` `--source-format <fa\|poc>` | — (CLI-only) |
| `auth test` | `auth test` | Check the SaaS key (`APB_API_KEY`) or the BYO `--config` yaml, read-only. | — | — (CLI-only) |

An 11th MCP tool, `gads_research_evidence_get`, has **no CLI equivalent** — it re-fetches a full
`Evidence` object by `(run_id, evidence_id)` from the MCP server's in-process cache of evidence
seen during the current session's `gads_research_*` calls. It is not a durable, cross-session
lookup (the binary has no `evidence get` leaf and does not yet persist full evidence objects
across runs) — a miss returns a structured `not_found` whose remediation is "re-run the tool that
produced it," not "try again." When operating via the CLI directly (no MCP), re-run the producing
command instead.

## Output contract (every command)

`{data, evidence, run_id, provenance}` on stdout, one JSON document, progress on stderr. Errors
still produce the same envelope shape: `{data:{status,error:{code,message,details}}, evidence:[],
run_id, provenance}`. Exit codes: `0` ok · `1` runtime error · `2` usage error · `3` structured
refusal (`data.error.code` ∈ `insufficient_data` | `policy_blocked` | `not_entitled`). `--format
text`/`--format md` render the same document for a human terminal — `json` is the one to parse.

## Never invent

Do not propose a command, subcommand, or flag not in this table (or not confirmed via
`--help`) — an unrecognized leaf exits `2` (usage error), not a graceful structured refusal. If a
capability sounds plausible but isn't listed here, say so and point at the nearest real command
rather than guessing a name.
