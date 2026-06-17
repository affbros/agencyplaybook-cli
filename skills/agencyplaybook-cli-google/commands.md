# apb-gads command index

**276 leaf commands across 26 groups** (Google Ads API v24). Per-group flag references live in
`references/commands/<group>.md` (generated from the binary — the accurate per-param source). The
live registry is `apb-gads --help` and `apb-gads playbook list`.

Global flags (on every command): `--config <PATH>` · `--customer <CID>` · `--pretty` · `--execute`
· `--validate-only` · `--confirm` · `--lookback-days <N>` · `--output <PATH>` · `--save-plan <PATH>`
· `-h/--help` · `-V/--version`.

## Auth & health

| Group | # | Purpose | Reference |
|---|--:|---|---|
| `auth` | 6 | resolve/test the SaaS connection; `connect-google`; accessible customers | `references/commands/auth.md` |
| `doctor` | 1 | environment + connectivity health check | `references/commands/doctor.md` |

## Reads — accounts & entities

| Group | # | Purpose | Reference |
|---|--:|---|---|
| `customer` | 2 | list reachable customers; `suggest-brands` | `references/commands/customer.md` |
| `account` | 4 | persist a "current" operating account (MCC child) so commands target it without `--customer`; `use` / `current` / `clear` / `list` | `references/commands/account.md` |
| `campaign` | 2 | list / get campaigns | `references/commands/campaign.md` |
| `ad-group` | 1 | list ad groups | `references/commands/ad-group.md` |
| `ad` | 1 | list ads | `references/commands/ad.md` |
| `keyword` | 1 | list keywords | `references/commands/keyword.md` |
| `negative-keyword` | 1 | list negative keywords | `references/commands/negative-keyword.md` |
| `asset` | 1 | list assets | `references/commands/asset.md` |
| `gaql` | 1 | run raw GAQL (`query --query "…"`) | `references/commands/gaql.md` |

## Reporting & diagnostics

| Group | # | Purpose | Reference |
|---|--:|---|---|
| `report` | 23 | performance/asset/PMAX/shopping/settings reports | `references/commands/report.md` |
| `playbook` | 64 | `list` + **63 diagnostic playbooks** (6 sections) | `references/commands/playbook.md`, `references/playbook-catalog.md` |
| `growth` | 5 | weekly/monthly reviews, `scale-up`, `consolidation`, `monitor` | `references/commands/growth.md` |

## Planning & greenfield

| Group | # | Purpose | Reference |
|---|--:|---|---|
| `plan` | 11 | keyword ideas/metrics; build Search/PMAX launch specs (`plan campaign …`) | `references/commands/plan.md` |
| `validate` | 2 | check a launch spec (`campaign-spec` / `pmax-spec`) — **exit 3 on fail** | `references/commands/validate.md` |
| `context` | 2 | per-customer goal/strategy state (local JSON) | `references/commands/context.md` |

## Mutations & orchestration (write-capable — see `safety-model.md`)

| Group | # | Purpose | Reference |
|---|--:|---|---|
| `mutate` | 116 | the full gated mutation surface (budgets, keywords, ads, bidding, PMAX, assets, criteria) | `references/commands/mutate.md` |
| `orchestrate` | 7 | composite flows (`campaign-launch`, `pmax-build`, `ad-refresh`, …) | `references/commands/orchestrate.md` |
| `changes` | 3 | turn a scored plan into a reviewable changeset and apply it | `references/commands/changes.md` |
| `sandbox` | 1 | `helper full-flow` — exercises the $1 sandbox write policy | `references/commands/sandbox.md` |
| `verify` | 9 | live-write verification chains under `LiveVerifyPolicy` | `references/commands/verify.md` |

## Operations & artifacts

| Group | # | Purpose | Reference |
|---|--:|---|---|
| `audit` | 3 | inspect/replay the execute-mode audit log | `references/commands/audit.md` |
| `schedule` | 7 | cron-install recurring **read-only** runs | `references/commands/schedule.md` |
| `export` | 1 | render an artifact JSON to CSV / JSON / Markdown | `references/commands/export.md` |

> Counts verified against `apb-gads 0.1.2`. The two nesting points are `plan campaign {search,full,pmax}` and `sandbox helper full-flow`.
