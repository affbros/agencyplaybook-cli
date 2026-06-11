# Scopes & tiers — the Google Ads add-on

Google Ads is a **paid add-on** layered on your AgencyPlaybook subscription tier. It is enabled
per tenant (`google_ads_addon=true`, set by an admin) and grants **7 `*:google:*` scopes** as an
*additive overlay* on top of your Meta tier scopes — it does not change the Meta scope counts.

When a command needs a scope your tier/add-on doesn't grant, the API returns
`403 insufficient_scope` (exit 3 on the HTTP path) with an upgrade hint. The fix is a higher tier
or enabling the add-on — not a CLI flag.

## Scope → minimum tier

| Scope | Min tier | What it gates |
|---|---|---|
| `read:google:campaigns` | **Professional** | account/campaign/ad-group/ad/keyword reads, `gaql query` |
| `read:google:reports` | **Professional** | the `report` group (23 reports) |
| `read:google:playbooks` | **Professional** | the 63 `playbook` audits + `growth` reviews |
| `read:google:planning` | **Professional** | the `plan` group (keyword ideas/metrics, greenfield specs) |
| `write:google:mutations` | **Agency** | the 116 `mutate` subcommands + `orchestrate` + `changes apply --execute` |
| `write:google:verify` | **Agency** | the `verify` live-write chains |
| `admin:google:automation` | **Enterprise** | `schedule` automation (cron-installed recurring runs) |

## Capability by tier (rule of thumb)

- **Starter** — no Google add-on scopes (the add-on is Professional+).
- **Professional** — **read everything**: all reports, all 63 playbooks, keyword planning, GAQL.
- **Agency** — adds **writes**: every mutation, the orchestrators, the changeset apply path, and
  the live-verify chains.
- **Enterprise** (and Free Enterprise) — adds **scheduled automation**.

Reads at Professional+, writes at Agency+, automation at Enterprise+ — the same shape as the Meta
side. Even a key with empty stored scopes resolves the `*:google:*` overlay live from the tier +
add-on flag, so you don't re-issue keys when an admin enables the add-on.
