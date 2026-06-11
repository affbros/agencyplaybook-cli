# apb-gads — Google Ads CLI documentation

Operator-grade Google Ads + Performance Max management from the command line.
**271 commands across 24 groups** — 116 gated mutations, 63 diagnostic playbooks, 23 reports —
every write dry-run by default behind a three-gate safety model. Google Ads API **v24**.

`apb-gads` is the Google Ads sibling of `apb` (the Meta CLI). It connects through your
AgencyPlaybook account (the Google Ads add-on) and is driven by the same `APB_API_KEY`.

## Start here

| Doc | What it covers |
|---|---|
| [GETTING_STARTED.md](GETTING_STARTED.md) | Install, connect Google Ads, set your API key, first commands |
| [USAGE_GUIDE.md](USAGE_GUIDE.md) | Task-oriented end-to-end workflows (diagnose → plan → change → launch) |
| [cli-reference/](cli-reference/README.md) | Complete per-command, per-flag reference (generated from the binary) |

## Reference

| Doc | What it covers |
|---|---|
| [SAFETY_MODEL.md](SAFETY_MODEL.md) | The three-gate write model, sandbox/profile policy, capability tiers |
| [CAPABILITY.md](CAPABILITY.md) | What's proven at which tier; how to confirm a write actually persisted |
| [SCOPES_AND_TIERS.md](SCOPES_AND_TIERS.md) | The 7 Google add-on scopes × subscription tier |
| [PLAYBOOK_CATALOG.md](PLAYBOOK_CATALOG.md) | All 63 diagnostic playbooks, grouped by section |
| [DOCTRINE.md](DOCTRINE.md) | Modern Google Ads doctrine (Smart Bidding, learning phase, RSA, PMAX) |
| [POLICY_LIMITS.md](POLICY_LIMITS.md) | Field-level limits (RSA / PMAX / extensions / URLs / bid modifiers) |
| [CAMPAIGN_BUILD.md](CAMPAIGN_BUILD.md) | Greenfield Search & PMAX launch pipeline + spec formats |
| [CLI_AUTOMATION.md](CLI_AUTOMATION.md) | Exit codes, `--validate-only`, JSON contract, CI/agent patterns, self-hosting |
| [examples/](examples/) | Validated launch-spec samples (`campaign-launch-spec.json`, `pmax-launch-spec.json`) |

## Drive it with Claude

A Claude skill (`agencyplaybook-cli-google`) packages this knowledge so Claude Code writes correct,
dry-run-first `apb-gads` automation. See the [`skills/`](../skills/) directory.

## Two prime directives (the operating posture)

1. **Growth-first.** Rank by growth headroom; read `LIMITED_BY_BUDGET` as a signal to scale, never
   "shrink to save waste." Pair every cut with a redeploy.
2. **Protect the learning phase.** Before any bid/budget/strategy change, read the CLI's
   `learning_advisory`; stay inside ≤10-15% target / ≤15-20% budget moves, never both at once.

The runtime is the source of truth — when a doc and the binary disagree, the binary wins
(`apb-gads --help`, `apb-gads playbook list`).
