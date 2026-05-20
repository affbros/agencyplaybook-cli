# Scopes & Tier Requirements

Each apb command requires a SaaS scope, which is granted by your subscription tier.
Hitting a command your tier doesn't cover returns `403 insufficient_scope`.

## Tier scope counts (canonical)

| Tier | Scopes | Rate limit (rpm) |
|---|---|---|
| Starter | 4 | 60 |
| Professional | 11 | 300 |
| Agency | 23 | 600 |
| Enterprise | 27 | 1000 |
| Free Enterprise | 27 | 1000 |

Source: `server/lib/tier-scopes.js` (asserted against `rust/crates/apb-core/src/auth/tier-scopes.json` at Express startup).

## Commands per scope

### `admin:duplicate` (1 commands)

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

### `read:campaigns` (39 commands)

- `apb account info-detailed`
- `apb account instagram-accounts`
- `apb account instagram-media`
- `apb account list`
- `apb account overview`
- `apb account pages`
- `apb account set-default`
- `apb ad create-multi`
- `apb ad get`
- `apb ad list`
- `apb ad preview`
- `apb ad update-status`
- `apb adset get`
- `apb adset list`
- `apb adset update-budget`
- `apb adset update-status`
- `apb adset update-targeting`
- `apb campaign get`
- `apb campaign list`
- `apb campaign pacing`
- `apb campaign preset list`
- `apb campaign preset save`
- `apb campaign preset show`
- `apb campaign update-status`
- `apb creative asset-audit`
- `apb creative get`
- `apb creative list`
- `apb creative upload-image`
- `apb creative upload-video`
- `apb creative upload-video-status`
- `apb library search`
- `apb targeting behavior-search`
- `apb targeting delivery-estimate`
- `apb targeting demographic-search`
- `apb targeting estimate`
- `apb targeting geo-search`
- `apb targeting interest-search`
- `apb targeting interest-suggest`
- `apb targeting interest-validate`

### `read:catalogs` (8 commands)

- `apb catalog get`
- `apb catalog list`
- `apb catalog product-feeds`
- `apb catalog product-set-create`
- `apb catalog product-set-delete`
- `apb catalog product-set-update`
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

### `read:leadgen` (3 commands)

- `apb leadgen get`
- `apb leadgen leads`
- `apb leadgen list`

### `read:pixels` (15 commands)

- `apb pixel audience-create`
- `apb pixel diagnostics`
- `apb pixel events`
- `apb pixel get`
- `apb pixel health`
- `apb pixel list`
- `apb pixel quality`
- `apb pixel share`
- `apb pixel shared-accounts`
- `apb pixel shared-agencies`
- `apb pixel signal`
- `apb pixel stats`
- `apb pixel unshare`
- `apb pixel users`
- `apb pixel validate-events`

### `read:playbooks:core` (26 commands)

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
- `apb playbook fatigue-index`
- `apb playbook health-score`
- `apb playbook launch-check`
- `apb playbook learning-accelerator`
- `apb playbook no-touch-compliance`
- `apb playbook placement-audit`
- `apb playbook rebalance`
- `apb playbook reset-rebuild-advisor`
- `apb playbook retargeting-compression`
- `apb playbook roas-recovery`
- `apb playbook saturation`
- `apb playbook scale-roadmap`
- `apb playbook waste-audit`
- `apb playbook weekly-digest`

### `read:playbooks:full` (3 commands)

- `apb action autoplan`
- `apb action plan`
- `apb growth score`

### `read:reports` (24 commands)

- `apb ask`
- `apb budget simulate`
- `apb learning diagnose`
- `apb learning prescribe`
- `apb learning scorecard`
- `apb learning volume`
- `apb metrics compute`
- `apb metrics creative-quality`
- `apb metrics funnel`
- `apb metrics objective-pack`
- `apb policy profile set`
- `apb policy profile show`
- `apb report breakdown`
- `apb report compare`
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

### `read:rules` (4 commands)

- `apb rules get`
- `apb rules list`
- `apb rules preview`
- `apb rules templates list`

### `read:search` (1 commands)

- `apb search`

### `write:audience-data` (2 commands)

- `apb audience users-add`
- `apb audience users-remove`

### `write:campaigns` (38 commands)

- `apb action apply`
- `apb ad create`
- `apb ad delete`
- `apb ad update`
- `apb adset create`
- `apb adset delete`
- `apb adset update`
- `apb andromeda launch`
- `apb andromeda plan`
- `apb audience create`
- `apb audience create-lookalike`
- `apb campaign budget-schedule create`
- `apb campaign compose`
- `apb campaign compose-from-spec`
- `apb campaign create`
- `apb campaign delete`
- `apb campaign duplicate`
- `apb campaign preset delete`
- `apb campaign update`
- `apb creative create-carousel`
- `apb creative create-collection`
- `apb creative create-dynamic`
- `apb creative create-image`
- `apb creative create-video`
- `apb creative update`
- `apb pixel create`
- `apb pixel send-batch`
- `apb pixel send-event`
- `apb pixel update`
- `apb plan approve-batch`
- `apb plan canary`
- `apb plan create`
- `apb plan doctor`
- `apb plan execute`
- `apb plan execute-safe`
- `apb plan list`
- `apb plan review-batch`
- `apb plan validate`

### `write:catalogs` (2 commands)

- `apb catalog create`
- `apb catalog update`

### `write:custom-conversions` (3 commands)

- `apb custom-conversion create`
- `apb custom-conversion delete`
- `apb custom-conversion update`

### `write:leadgen` (2 commands)

- `apb leadgen create`
- `apb leadgen leads-export`

### `write:rules` (7 commands)

- `apb rules create`
- `apb rules delete`
- `apb rules disable`
- `apb rules enable`
- `apb rules execute`
- `apb rules templates apply`
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
