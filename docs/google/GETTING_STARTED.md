# Getting Started with apb-gads

`apb-gads` is an operator-grade command-line tool for Google Ads + Performance Max — diagnose, report, plan, and safely change accounts from your terminal. It ships **271 commands across 24 groups** (116 gated mutations, 63 diagnostic playbooks, 23 reports) against Google Ads **API v24**. Every response is JSON and every write is dry-run by default.

> This is the on-ramp. For the exhaustive command/flag enumeration see [`cli-reference/README.md`](cli-reference/README.md); for the write-safety model see [`SAFETY_MODEL.md`](SAFETY_MODEL.md); for tiers/scopes see [`SCOPES_AND_TIERS.md`](SCOPES_AND_TIERS.md). The runtime is always the source of truth — when a doc and the binary disagree, the binary wins.

## Install

Grab the pre-built binary for your platform from the public repo's `bin/` directory:

- **Linux x86_64** — `bin/linux-x86_64/apb-gads`
- **macOS universal** (Intel + Apple Silicon) — `bin/macos-universal/apb-gads`
- **Windows x86_64** — `bin/windows-x86_64/apb-gads.exe`

The downloaded binary already targets `https://api.agencyplaybook.io` — no URL configuration needed. Put it on your `PATH` and confirm it runs:

```bash
chmod +x apb-gads          # macOS/Linux
apb-gads --version         # -> apb-gads 0.1.0
```

## Connect Google Ads

Google Ads is a paid **add-on** layered on your AgencyPlaybook subscription (it must be enabled on your account by an admin). Connect it once in the web dashboard:

1. Sign in at **agencyplaybook.io**.
2. Go to **Integrations → Connect Google Ads** and complete the Google OAuth consent.
3. Use the **account picker** to select the operating account the CLI will manage.

That's it — the connection is stored server-side against your tenant. The CLI authenticates with your API key (next section); it never needs Google credentials of its own.

## Set your API key

Create an API key on the dashboard's **API Keys** page (`/api-keys`), then drop it into the global config file the CLI reads from any directory:

```bash
mkdir -p ~/.apb
echo 'APB_API_KEY=apb_live_<tier>_<32hex>' > ~/.apb/.env
```

Credentials resolve in this order (first match wins):

1. **Shell environment** — `export APB_API_KEY=apb_live_<tier>_<32hex>`
2. **Project-local `.env`** — in the current working directory
3. **`~/.apb/.env`** — global, recommended for the downloaded binary

Set `~/.apb/.env` once and the CLI works from anywhere. Only set `APB_API_URL` if you're pointing at a non-default endpoint (self-hosting or local dev).

## Verify

```bash
apb-gads --pretty auth test       # auth resolves + the Google connection is live
apb-gads --pretty doctor check    # environment + config sanity
apb-gads --pretty customer list   # the Google Ads accounts your connection can reach
```

`--pretty` only toggles JSON indentation — output is always JSON, so pipe to `jq` for extraction.

**Select the operating account** with the global `--customer <CID>` flag. `<CID>` is a 10-digit Google Ads customer id, **plain numeric, no dashes** (`1234567890`, not `123-456-7890`):

```bash
apb-gads --pretty --customer <CID> playbook account-health
```

If your connection reaches exactly one account it is auto-selected; otherwise the dashboard account picker sets the default and `--customer` overrides per invocation.

## Plans & tiers

The Google add-on grants **7 `*:google:*` scopes** as an additive overlay on your subscription tier (it does not change your Meta scope counts):

- **Reads** — all 63 playbooks, all 23 reports, keyword planning, raw GAQL — at **Professional+**.
- **Writes** — the 116 `mutate` subcommands, the orchestrators, and the verify chains — at **Agency+**.
- **Scheduled automation** — recurring read-only `schedule` jobs — at **Enterprise+**.

A `403 insufficient_scope` means your tier or add-on doesn't cover the command — the fix is a higher tier or enabling the add-on, not a CLI flag. Even a key with empty stored scopes resolves the overlay live from your tier + add-on, so you don't re-issue keys when an admin turns it on. Full matrix and upgrade path: [`SCOPES_AND_TIERS.md`](SCOPES_AND_TIERS.md).

## What you can do

- **Diagnose** — run any of **63 playbooks** (`apb-gads --customer <CID> playbook account-health`, `playbook waste-audit`, `playbook campaign-bid-strategy-audit`, `playbook pmax-audit`, `playbook rsa-quality-audit`, …); browse them in [`PLAYBOOK_CATALOG.md`](PLAYBOOK_CATALOG.md).
- **Report** — 23 reports plus the `growth` reviews (`apb-gads --customer <CID> growth scale-up`).
- **Plan & launch greenfield** — Search: `plan campaign full` → `validate campaign-spec` → `orchestrate campaign-launch`. PMAX: `plan campaign pmax` → `validate pmax-spec` → `orchestrate pmax-build`. Entities are born PAUSED.
- **Change safely** — 116 gated mutations, **dry-run first**. The protocol: dry-run → read the JSON plan + advisories → approve → re-run with `--execute`. See [`SAFETY_MODEL.md`](SAFETY_MODEL.md) for the three-gate model.
- **Run raw GAQL** — `apb-gads --customer <CID> gaql query --query "SELECT campaign.name FROM campaign"` for anything the named reports don't cover.
- **Schedule read-only audits** — `apb-gads schedule add` registers recurring read-only runs; mutations cannot be scheduled by construction.

The exhaustive command + flag reference is [`cli-reference/README.md`](cli-reference/README.md) (auto-generated from the binary).

## Self-hosting / BYO token

Developers can run `apb-gads` against their own Google Ads developer token instead of the SaaS broker. Copy the template `google-ads.example.yaml` to `google-ads.yaml`, fill in your credentials, and point the CLI at a non-default `APB_API_URL` as needed. The `google-ads.yaml` file is gitignored — never commit live secrets. Details (exit codes, `--validate-only`, JSON contract, CI/agent patterns, and the self-hosting setup) are in [`CLI_AUTOMATION.md`](CLI_AUTOMATION.md).
