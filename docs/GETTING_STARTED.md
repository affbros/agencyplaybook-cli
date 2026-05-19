# Getting Started with apb

apb is a platform for managing Meta (Facebook/Instagram) ad campaigns. It offers two ways to work:

## For Web UI Users

1. **Sign up** at agencyplaybook.io — choose your plan (Starter, Professional, Agency, or Enterprise)
2. **Connect your Meta account** — go to Settings > Integrations > "Connect Meta Account"
3. **Start working** — browse campaigns, run playbooks, view reports — all in the browser

## For CLI/API Users

1. **Sign up** at agencyplaybook.io — choose your plan
2. **Connect your Meta account** — go to Settings > Integrations > "Connect Meta Account"
3. **Generate your API key** — go to Settings > API Keys > "Generate New Key"
4. **Save your key** — it's shown once. Copy it immediately.
5. **Set your environment**:
   ```bash
   export APB_API_KEY=apb_live_ent_your_key_here
   export APB_API_URL=https://api.agencyplaybook.io
   ```
6. **First command**:
   ```bash
   apb auth test
   ```
7. **List your campaigns**:
   ```bash
   apb campaign list
   ```

### Direct API Access

Use your API key as a Bearer token:

```bash
curl -H "Authorization: Bearer apb_live_ent_your_key_here" \
  https://api.agencyplaybook.io/api/v1/campaigns
```

## Plans & Tiers

| Tier | Price | RPM | Accounts | Key Features |
|------|-------|-----|----------|-------------|
| Starter | $79/mo | 60 | 1 | Campaigns, reports, 5 core playbooks |
| Professional | $199/mo | 300 | 3 | + Advanced reports, writes, all playbooks |
| Agency | $449/mo | 600 | 10 | + Rules, automation, datasets |
| Enterprise | $999+/mo | 1000 | Unlimited | + Sync, split tests, duplication |

## What You Can Do

- **Campaigns** — list, create, update, pause, duplicate, compose from spec
- **Reports** — insights, compare, pacing, CSV export
- **Playbooks** — health score, waste audit, fatigue index, scale roadmap, and 10 more
- **Creatives** — list, upload images/videos, dynamic creative (DCO)
- **Targeting** — research, audience overlap, reach estimates
- **Rules** — automated rules from templates (kill high CPA, scale winners, etc.)
- **Name resolution** — use campaign names instead of IDs: `apb campaign get --id "Retargeting"`
- **Aliases** — save shortcuts: `apb alias set retarget 120239538597430265`
