# AgencyPlaybook MCP — cross-channel plan automation

A hosted **MCP** (Model Context Protocol) endpoint that puts the full Meta (Facebook/Instagram)
and Google Ads planning pipeline in front of any MCP-speaking AI client — Claude Code, Claude
Desktop, or a generic MCP client — authenticated with the same `apb_*` API key you already use
for the `apb` / `apb-gads` CLIs. It is the third way to drive AgencyPlaybook, alongside the two
CLI binaries and the web dashboard, and it shares the same read → plan → validate → write →
verify → roll back lifecycle and the same approval handshake as both CLIs.

| | |
|---|---|
| **Endpoint** | `https://mcp.agencyplaybook.io/mcp` |
| **Transport** | streamable HTTP |
| **Auth** | `Authorization: Bearer <apb_*_key>` — a **user-bound** `apb_*` key |
| **Tools** | 45 always-on; +3 **Group L** agency tools for an agency-entitled key (48 total) |
| **Health** | `GET https://mcp.agencyplaybook.io/healthz` → `200` |

---

## Connect — Claude Code

```bash
claude mcp add --transport http agencyplaybook https://mcp.agencyplaybook.io/mcp \
  --header "Authorization: Bearer apb_live_<your-key>"
```

## Connect — generic MCP client (JSON)

```json
{
  "mcpServers": {
    "agencyplaybook": {
      "type": "http",
      "url": "https://mcp.agencyplaybook.io/mcp",
      "headers": {
        "Authorization": "Bearer apb_live_<your-32hex-key>"
      }
    }
  }
}
```

> Clients vary in dialect — some use `"transport"` instead of `"type"`, or `"serverUrl"`
> instead of `"url"`. The constants are always the same: the URL above, HTTP transport, and
> the `Authorization: Bearer apb_*` header.

---

## The consent handshake

There is **no account fence in the server** — writes target the account your key operates on;
the server is a mechanical executor, not the consent layer. Consent lives in exactly two places:

1. **The approval handshake.** A `preview` or `validate` call runs the change as a dry run and
   **mints** a single-use, ~10-minute, change-bound, account-bound `approval_token`. It changes
   nothing. A different change, a changed plan, a different account, or a reused/expired token is
   auto-refused.
2. **An explicit human "YES."** The connecting client is expected to show the change and its
   projected impact and get a real confirmation before calling the write tool with the token
   **and** `operator_confirmation:true` (**and** `confirm_destructive:true` for anything with
   `blast_radius >= 4`).

Every write is verified afterward with a readback (`meta_verify_execution` /
`gads_verify_execution`) — nothing is reported as landed without one.

---

## The 16 planning tools

| Tool | Channel | Purpose | Example |
|---|---|---|---|
| `meta_create_plan` | Meta | Create a plan RECORD (no import, no write) | `{ "action":"campaign.update-status", "target_id":"120212345678901", "payload":{"status":"PAUSED"} }` |
| `meta_build_campaign_spec` | Meta | Dry-run compose preview of a campaign spec | `{ "preset_name":"sales-video", "campaign_name":"Q3 Sale", "page_id":"auto", "pixel_id":"auto", "daily_budget":5000 }` |
| `meta_validate_plan` | Meta | Validate a plan, mint the approval token, first import | `{ "plan_id":"pln_abc123" }` |
| `meta_get_plan` | Meta | Read a plan back as its v2 envelope | `{ "plan_id":"pln_abc123" }` |
| `meta_execute_plan` | Meta | Approve + execute + poll a validated plan | `{ "plan_id":"pln_abc123", "approval_token":"apt_...", "operator_confirmation":true }` |
| `agency_list_plans` | Meta | List stored plan artifacts | `{ "status":"VALIDATED" }` |
| `agency_get_plan` | either | Fetch one stored plan by id | `{ "plan_id":"pln_abc123" }` |
| `gads_build_campaign_spec` | Google | Assemble a Search or PMAX spec (pure-local, no token) | `{ "spec_kind":"pmax_spec", "campaign_name":"Holiday PMAX", "final_url":"https://example.com", "business_name":"Acme Co", "daily_budget":200 }` |
| `gads_validate_spec` | Google | Validate a spec, mint a token on pass | `{ "spec_kind":"campaign_spec", "spec":{ "campaign_name":"...", "budget_micros":50000000 } }` |
| `gads_export_plan` | Google | Produce + import a plan envelope, mint the token | `{ "customer_id":"1234567890", "change_set":{ "op":"campaign-update-status", "entity_id":"18765432109", "params":{"status":"PAUSED"} } }` |
| `gads_execute_plan` | Google | Approve + execute + poll an imported Google plan | `{ "plan_id":"pln_g_9a3f", "approval_token":"apt_...", "operator_confirmation":true }` |
| `agency_rollback_plan` | either | Undo an executed (or partially-failed) plan | `{ "channel":"meta", "plan_id":"pln_abc123", "operator_confirmation":true, "confirm_destructive":true }` |
| `agency_export_plan` | either | Hand a stored plan to the CLI (envelope + commands) | `{ "channel":"google", "plan_id":"pln_g_9a3f", "format":"handoff" }` |
| `agency_build_plan` | either | A brief → a launch-ready build (`recipe build`) | `{ "channel":"google", "customer_id":"1234567890", "brief":{ "objective":"leads", "final_url":"https://example.com", "daily_budget_micros":20000000 } }` |
| `agency_merge_plans` | either | N plans → ONE ranked, wave-sequenced envelope | `{ "channel":"meta", "plans":["pln_waste_audit","pln_scale"], "mode":"efficiency" }` |
| `agency_forecast_plan` | either | Read-only scenario forecast for a build spec or live entity | `{ "channel":"google", "customer_id":"1234567890", "campaign_id":"18765432109", "budget_scenarios":[50,100,150] }` |

(Sandbox/sanctioned ids used throughout: Meta `act_1476889130308799`, Google
customer-id placeholder `1234567890`. Real keys never appear in examples.)

---

## Plan lifecycle

```
pending -> approved -> executing -> executed | failed -> rolled_back
```

A plan is a **plan-envelope-v2** document — one or more ordered actions, sharing one state
machine on both channels. Imported plans live on the tenant's Plans page
(`/plans` for Meta, `/gads/plans` for Google); approving there and approving through the MCP
handshake are the SAME approval.

- **Produce + import.** Meta: `meta_create_plan` → `meta_validate_plan` (mints the token,
  imports the row). Google: `gads_export_plan` (produces the envelope, imports it, mints the
  token).
- **Approve + execute + poll.** `meta_execute_plan` / `gads_execute_plan`.
- **Undo.** `agency_rollback_plan {channel, plan_id, operator_confirmation:true,
  confirm_destructive:true}` — works on an `executed` plan, and on a `failed` plan whose receipt
  shows `completed_through > 0` (a half-applied create-class plan left real entities behind;
  don't just build a fresh plan on top of the orphans).
- **`{{ref:aN}}` / `{{account}}`.** A create-class plan addresses entities its own earlier
  actions will create, so those ids don't exist when the plan is written and appear as
  placeholders. The executor binds them at run time — the SaaS job runner and both CLIs share
  one ref map across a run. **Never substitute them by hand** — a hand-edited ref fails with
  `unresolved_ref` or silently targets the wrong entity.

---

## Planning effectively

Being able to call a planning tool correctly is not the same as knowing when to reach for which
one:

1. **A single bounded change** (pause a campaign, change one budget) → preview/validate, then
   apply. Skip the plan machinery entirely.
2. **A whole new build from a brief** → `agency_build_plan` (`recipe build` under the hood).
3. **Several playbook outputs that should land together** → `agency_merge_plans` — never strip
   the `wait-for-status` pseudo-actions between waves; `conflicts[]` is for a human to resolve,
   never guessed at.
4. **A budget or scale move** → `agency_forecast_plan` first. It's read-only and cheap — there's
   no reason to skip it.
5. **`blast_radius >= 4`** → `confirm_destructive:true` in addition to
   `operator_confirmation:true`, and a human should read the plan's `review_url` before
   approving — not just see a chat summary. Always keep `agency_rollback_plan` reachable for
   anything create-class. `plan_hash` drift on the CLI side means re-validate, not force through.

---

## Handoff, both directions

**Hosted → CLI** (`agency_export_plan`):

```bash
apb plan validate --from-file plan.json --validate-only   # dry run first
apb plan apply --from-file plan.json --execute             # Meta

apb-gads mutate apply-plan --from-file plan.json --validate-only
apb-gads mutate apply-plan --from-file plan.json --execute  # Google
```

`plan_hash` is re-verified on apply — an edited file needs `--allow-edited-plan`; say so
explicitly rather than adding it silently.

**CLI → hosted:**

```bash
apb-gads recipe build --brief brief.yaml --plan out.json --dry-run

curl -s https://api.agencyplaybook.io/api/v1/gads/plans/import \
  -H "Authorization: Bearer $APB_API_KEY" -H "Content-Type: application/json" \
  -d @out.json | jq .plan_id
```

Any document a CLI produces (`apb ... --plan`, `apb plan export`, `apb-gads recipe build`,
`plan merge`) is imported through the existing import path and appears on the Plans page for a
human approve.

---

## Resources and prompts

Beyond the 16 planning tools, the endpoint registers read-only MCP **resources** and reusable
**prompts** — protocol slots for guidance that doesn't fit a tool description.

**Resources** (`resources/list`, then `resources/read <uri>`):

| URI | Contents |
|---|---|
| `guide://planning/overview` | The plan pipeline, states, blast radius, `{{ref:aN}}` |
| `guide://planning/doctrine` | The full plan-effectively decision table + anti-patterns |
| `guide://planning/meta` | Full Meta worked examples: a `recipe build` brief + the create-class envelope shape |
| `guide://planning/google` | Search + PMAX build → execute, plus the live-Google connected-account caveat |
| `guide://planning/handoff` | Both handoff directions, exact CLI commands + curl |

**Prompts** (`prompts/list`, then `prompts/get <name>`): `plan_effectively` (situation → the
right verb/tool + gate), `build_campaign_from_brief` (channel/account/brief → the filled tool
sequence), `review_and_execute_plan` (plan_id → validate/approve/execute/verify with the
consent rail spelled out), `undo_plan` (channel/plan_id → the rollback sequence).

---

## Still CLI-only

Three of the six CLI planning verbs stay CLI-only — no hosted tool wraps `portfolio plan`,
`experiment`, `recipe search-terms`, or `context`. Run those in a terminal and bring the
resulting plan back through the import path above.

---

## See also

- [README.md](README.md) — the full `apb-gads` command reference index.
- [CAMPAIGN_BUILD.md](CAMPAIGN_BUILD.md) — the greenfield Search/PMAX launch pipeline the
  planning tools wrap.
- [SAFETY_MODEL.md](SAFETY_MODEL.md) — the three-gate write model behind every mutation.
