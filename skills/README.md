# Claude skills

A [Claude Code](https://claude.com/claude-code) / Claude Agent skill for driving the AgencyPlaybook CLI (`apb`).

## `agencyplaybook-cli`

Packages working knowledge of every `apb` command — 254 commands across 35 domains — so Claude can write correct, dry-run-first automation for Meta (Facebook/Instagram) ad campaigns: campaign/adset/ad/creative CRUD, diagnostic playbooks, multi-entity plans with rollback, audiences, targeting, pixels/CAPI, rules, split-tests, catalogs, custom conversions, and leadgen.

| | |
|---|---|
| **Browse the skill** | [`agencyplaybook-cli/`](./agencyplaybook-cli) — `SKILL.md`, `commands.md`, `examples.md`, `workflows/`, `reference/` |
| **One-step install** | [`agencyplaybook-cli.tar.gz`](./agencyplaybook-cli.tar.gz) |

### Install

```bash
# Download the bundle, then extract into your Claude skills directory:
mkdir -p ~/.claude/skills
tar xzf agencyplaybook-cli.tar.gz -C ~/.claude/skills/

# Restart Claude Code. Ask "set me up with apb" to verify the skill activates.
```

You can also clone this repo and copy the directory directly:

```bash
mkdir -p ~/.claude/skills
cp -r agencyplaybook-cli ~/.claude/skills/
```

### Pair it with the binary

The skill drives the `apb` binary — grab it from [`../bin`](../bin) and set your API key once:

```bash
mkdir -p ~/.apb
echo 'APB_API_KEY=apb_live_<tier>_<32hex>' > ~/.apb/.env   # key from the dashboard /api-keys page
apb auth test
```

The binary already targets `https://api.agencyplaybook.io`; you only set `APB_API_URL` when self-hosting or developing locally.

### Staying current

This skill tracks the CLI surface and is refreshed on each release. The same bundle is downloadable from the **CLI Reference** page inside the AgencyPlaybook dashboard. See the top-level [`CLAUDE.md`](../CLAUDE.md) for broader guidance on driving `apb` from Claude Code.

## `agencyplaybook-cli-google`

A Claude skill for driving the **apb-gads** CLI — operator-grade Google Ads + Performance Max management: reads/reports, 63 diagnostic playbooks, growth-first planning, greenfield Search/PMAX launch, and 116 dry-run-first gated mutations. 271 commands across 24 domains (Google Ads API v24).

| | |
|---|---|
| **Browse the skill** | [`agencyplaybook-cli-google/`](./agencyplaybook-cli-google) — `SKILL.md`, `commands.md`, `examples.md`, `references/` |
| **One-step install** | [`agencyplaybook-cli-google.tar.gz`](./agencyplaybook-cli-google.tar.gz) |

### Install

```bash
mkdir -p ~/.claude/skills
tar xzf agencyplaybook-cli-google.tar.gz -C ~/.claude/skills/
# Restart Claude Code. Ask "set me up with apb-gads" to verify the skill activates.
```

### Pair it with the binary

The skill drives the `apb-gads` binary — grab it from [`../bin`](../bin) (`apb-gads`) and set your API key once:

```bash
mkdir -p ~/.apb
echo 'APB_API_KEY=apb_live_<tier>_<32hex>' > ~/.apb/.env   # key from the dashboard /api-keys page
apb-gads auth test
```

Google Ads is a paid add-on — connect a Google account in the AgencyPlaybook dashboard (Integrations → Connect Google Ads). Full docs: [`../docs/google/`](../docs/google).
