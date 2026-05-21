# Scopes & Tier Requirements

Each `apb` command requires one SaaS scope, granted by your subscription tier.
A command above your tier returns `403 insufficient_scope` (CLI exit 3).

## Tier → scope matrix

| Scope | Starter | Professional | Agency | Enterprise | Free Enterprise |
|---|:-:|:-:|:-:|:-:|:-:|
| `read:analytics` *(API-only)* | · | · | ✓ | ✓ | ✓ |
| `read:audiences` | · | ✓ | ✓ | ✓ | ✓ |
| `read:campaigns` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `read:catalogs` | · | ✓ | ✓ | ✓ | ✓ |
| `read:coverage` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `read:custom-conversions` | · | ✓ | ✓ | ✓ | ✓ |
| `read:datasets` | · | · | ✓ | ✓ | ✓ |
| `read:leadgen` | · | ✓ | ✓ | ✓ | ✓ |
| `read:leadgen:export` | · | · | ✓ | ✓ | ✓ |
| `read:pixels` | · | ✓ | ✓ | ✓ | ✓ |
| `read:playbooks:core` | · | ✓ | ✓ | ✓ | ✓ |
| `read:playbooks:full` | · | · | ✓ | ✓ | ✓ |
| `read:reports` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `read:reports:advanced` | · | ✓ | ✓ | ✓ | ✓ |
| `read:rules` | · | · | ✓ | ✓ | ✓ |
| `read:search` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `write:audience-data` | · | · | ✓ | ✓ | ✓ |
| `write:automation` | · | · | · | ✓ | ✓ |
| `write:budgets` | · | · | ✓ | ✓ | ✓ |
| `write:campaigns` | · | · | ✓ | ✓ | ✓ |
| `write:catalogs` | · | · | ✓ | ✓ | ✓ |
| `write:custom-conversions` | · | · | ✓ | ✓ | ✓ |
| `write:leadgen` | · | · | ✓ | ✓ | ✓ |
| `write:rules` | · | · | ✓ | ✓ | ✓ |
| `admin:duplicate` | · | · | · | ✓ | ✓ |
| `admin:split-test` | · | · | · | ✓ | ✓ |
| `admin:sync` | · | · | · | ✓ | ✓ |

| | Starter | Professional | Agency | Enterprise | Free Enterprise |
|---|:-:|:-:|:-:|:-:|:-:|
| **Scopes** | 4 | 11 | 23 | 27 | 27 |
| **Rate limit (rpm)** | 60 | 300 | 600 | 1000 | 1000 |

`·` = not granted. Scopes marked *(API-only)* gate HTTP-API features that have no `apb` command. Your tier is set by your subscription plan.

## Commands per scope

### `admin:duplicate` (2 commands)

- `apb campaign duplicate`
- `apb duplicate`

### `admin:split-test` (4 commands)

- `apb split-test create`
- `apb split-test evaluate`
- `apb split-test promote`
- `apb split-test status`

### `admin:sync` (2 commands)

- `apb sync diff`
- `apb sync pull`

### `read:audiences` (3 commands)

- `apb audience get`
- `apb audience list`
- `apb audience overlap`

### `read:campaigns` (32 commands)

- `apb account info-detailed`
- `apb account instagram-accounts`
- `apb account instagram-media`
- `apb account list`
- `apb account overview`
- `apb account pages`
- `apb account set-default`
- `apb ad get`
- `apb ad list`
- `apb ad preview`
- `apb adset get`
- `apb adset list`
- `apb campaign get`
- `apb campaign list`
- `apb campaign pacing`
- `apb creative asset-audit`
- `apb creative get`
- `apb creative list`
- `apb creative upload-video-status`
- `apb library search`
- `apb plan doctor`
- `apb plan list`
- `apb policy profile set`
- `apb policy profile show`
- `apb targeting behavior-search`
- `apb targeting delivery-estimate`
- `apb targeting demographic-search`
- `apb targeting estimate`
- `apb targeting geo-search`
- `apb targeting interest-search`
- `apb targeting interest-suggest`
- `apb targeting interest-validate`

### `read:catalogs` (5 commands)

- `apb catalog get`
- `apb catalog list`
- `apb catalog product-feeds`
- `apb catalog product-sets`
- `apb catalog products`

### `read:coverage` (1 commands)

- `apb coverage audit`

### `read:custom-conversions` (2 commands)

- `apb custom-conversion get`
- `apb custom-conversion list`

### `read:datasets` (18 commands)

- `apb dataset action-queue`
- `apb dataset agency-ops`
- `apb dataset bundle`
- `apb dataset clone-plan`
- `apb dataset creative-pipeline`
- `apb dataset execution-plan`
- `apb dataset learning-state`
- `apb dataset learning-velocity`
- `apb dataset pixel-events`
- `apb dataset pixel-health`
- `apb dataset pixel-quality`
- `apb dataset pixel-signal`
- `apb dataset readiness`
- `apb dataset report-contract-v2`
- `apb dataset scale-forecast`
- `apb dataset scenario`
- `apb dataset schema-validate`
- `apb dataset targeting-pack`

### `read:leadgen` (2 commands)

- `apb leadgen get`
- `apb leadgen list`

### `read:leadgen:export` (2 commands)

- `apb leadgen leads`
- `apb leadgen leads-export`

### `read:pixels` (19 commands)

- `apb pixel audience-create`
- `apb pixel create`
- `apb pixel diagnostics`
- `apb pixel events`
- `apb pixel get`
- `apb pixel health`
- `apb pixel list`
- `apb pixel quality`
- `apb pixel send-batch`
- `apb pixel send-event`
- `apb pixel share`
- `apb pixel shared-accounts`
- `apb pixel shared-agencies`
- `apb pixel signal`
- `apb pixel stats`
- `apb pixel unshare`
- `apb pixel update`
- `apb pixel users`
- `apb pixel validate-events`

### `read:playbooks:core` (5 commands)

- `apb playbook fatigue-index`
- `apb playbook health-score`
- `apb playbook launch-check`
- `apb playbook waste-audit`
- `apb playbook weekly-digest`

### `read:playbooks:full` (21 commands)

- `apb playbook anomaly-detect`
- `apb playbook broad-targeting-audit`
- `apb playbook capi-dual-signal`
- `apb playbook catalog`
- `apb playbook cbo-vs-abo-audit`
- `apb playbook consolidation-advisor`
- `apb playbook creative-mix`
- `apb playbook daypart`
- `apb playbook duplicate-detect`
- `apb playbook evaluate`
- `apb playbook event-downgrade-ladder`
- `apb playbook event-hierarchy-audit`
- `apb playbook learning-accelerator`
- `apb playbook no-touch-compliance`
- `apb playbook placement-audit`
- `apb playbook rebalance`
- `apb playbook reset-rebuild-advisor`
- `apb playbook retargeting-compression`
- `apb playbook roas-recovery`
- `apb playbook saturation`
- `apb playbook scale-roadmap`

### `read:reports` (20 commands)

- `apb growth score`
- `apb learning diagnose`
- `apb learning prescribe`
- `apb learning scorecard`
- `apb learning volume`
- `apb metrics compute`
- `apb metrics creative-quality`
- `apb metrics funnel`
- `apb metrics objective-pack`
- `apb report breakdown`
- `apb report insights`
- `apb report insights-async fetch`
- `apb report insights-async start`
- `apb report insights-async status`
- `apb report metrics`
- `apb report presets list`
- `apb report presets run`
- `apb report profile list`
- `apb report profile run`
- `apb report profile save`

### `read:reports:advanced` (1 commands)

- `apb report compare`

### `read:rules` (4 commands)

- `apb rules get`
- `apb rules list`
- `apb rules templates apply`
- `apb rules templates list`

### `read:search` (2 commands)

- `apb ask`
- `apb search`

### `write:audience-data` (2 commands)

- `apb audience users-add`
- `apb audience users-remove`

### `write:automation` (5 commands)

- `apb action apply`
- `apb action autoplan`
- `apb action plan`
- `apb andromeda launch`
- `apb andromeda plan`

### `write:budgets` (1 commands)

- `apb budget simulate`

### `write:campaigns` (39 commands)

- `apb ad create`
- `apb ad create-multi`
- `apb ad delete`
- `apb ad update`
- `apb ad update-status`
- `apb adset create`
- `apb adset delete`
- `apb adset update`
- `apb adset update-budget`
- `apb adset update-status`
- `apb adset update-targeting`
- `apb audience create`
- `apb audience create-lookalike`
- `apb campaign budget-schedule create`
- `apb campaign compose`
- `apb campaign compose-from-spec`
- `apb campaign create`
- `apb campaign delete`
- `apb campaign preset delete`
- `apb campaign preset list`
- `apb campaign preset save`
- `apb campaign preset show`
- `apb campaign update`
- `apb campaign update-status`
- `apb creative create-carousel`
- `apb creative create-collection`
- `apb creative create-dynamic`
- `apb creative create-image`
- `apb creative create-video`
- `apb creative update`
- `apb creative upload-image`
- `apb creative upload-video`
- `apb plan approve-batch`
- `apb plan canary`
- `apb plan create`
- `apb plan execute`
- `apb plan execute-safe`
- `apb plan review-batch`
- `apb plan validate`

### `write:catalogs` (5 commands)

- `apb catalog create`
- `apb catalog product-set-create`
- `apb catalog product-set-delete`
- `apb catalog product-set-update`
- `apb catalog update`

### `write:custom-conversions` (3 commands)

- `apb custom-conversion create`
- `apb custom-conversion delete`
- `apb custom-conversion update`

### `write:leadgen` (1 commands)

- `apb leadgen create`

### `write:rules` (7 commands)

- `apb rules create`
- `apb rules delete`
- `apb rules disable`
- `apb rules enable`
- `apb rules execute`
- `apb rules preview`
- `apb rules update`

### `—` (20 commands)

- `apb alias list`
- `apb alias remove`
- `apb alias set`
- `apb auth accounts add`
- `apb auth accounts list`
- `apb auth accounts remove`
- `apb auth connect-meta`
- `apb auth keys create`
- `apb auth keys list`
- `apb auth keys revoke`
- `apb auth keys rotate`
- `apb auth login`
- `apb auth status`
- `apb auth test`
- `apb doctor api-compat`
- `apb doctor check`
- `apb doctor quota`
- `apb doctor validate-only-matrix`
- `apb meta cache`
- `apb meta status`
