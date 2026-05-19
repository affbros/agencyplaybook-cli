# Meta Graph API Fields Reference

Complete reference of all Meta Graph API fields, endpoints, and parameters used by `apb`.

---

## Endpoints

### Identity & Account

| Endpoint | Method | Description |
|----------|--------|-------------|
| `debug_token` | GET | Token introspection (scopes, expiry) |
| `me` | GET | Current user identity |
| `me/adaccounts` | GET | List ad accounts for current user |
| `me/accounts` | GET | List pages the user manages |
| `{account}` | GET | Ad account details |
| `{account}/promote_pages` | GET | Pages linked to ad account |

### Campaigns

| Endpoint | Method | Description |
|----------|--------|-------------|
| `{account}/campaigns` | GET | List campaigns |
| `{account}/campaigns` | POST | Create campaign |
| `{campaign_id}` | GET | Get campaign details |
| `{campaign_id}` | POST | Update campaign (status, etc.) |
| `{campaign_id}/adsets` | GET | List adsets for campaign |
| `{campaign_id}/budget_schedules` | POST | Create budget schedule |
| `{campaign_id}/insights` | GET | Campaign-level insights |

### Ad Sets

| Endpoint | Method | Description |
|----------|--------|-------------|
| `{account}/adsets` | GET | List adsets |
| `{account}/adsets` | POST | Create adset |
| `{adset_id}` | GET | Get adset details |
| `{adset_id}` | POST | Update adset (budget, targeting) |
| `{adset_id}/ads` | GET | List ads for adset |

### Ads

| Endpoint | Method | Description |
|----------|--------|-------------|
| `{account}/ads` | GET | List ads |
| `{account}/ads` | POST | Create ad |
| `{ad_id}` | GET | Get ad details |
| `{ad_id}` | POST | Update ad (status) |

### Creatives

| Endpoint | Method | Description |
|----------|--------|-------------|
| `{account}/adcreatives` | GET | List creatives |
| `{account}/adcreatives` | POST | Create creative |
| `{creative_id}` | GET | Get creative details |
| `{creative_id}` | POST | Update creative fields |
| `{account}/adimages` | POST | Upload image (multipart) |
| `{account}/advideos` | POST | Upload video (multipart) |
| `{video_id}` | GET | Video processing status |

### Audiences

| Endpoint | Method | Description |
|----------|--------|-------------|
| `{account}/customaudiences` | GET | List custom audiences |
| `{account}/saved_audiences` | GET | List saved audiences |

### Targeting Research

| Endpoint | Method | Description |
|----------|--------|-------------|
| `search?type=adinterest` | GET | Search interests by keyword |
| `search?type=adinterestsuggestion` | GET | Suggest related interests |
| `search?type=adinterestvalid` | GET | Validate interest IDs |
| `search?type=adTargetingCategory&class=behaviors` | GET | List behavior options |
| `search?type=adTargetingCategory&class={cls}` | GET | List demographic options |
| `search?type=adgeolocation` | GET | Search geographic locations |
| `{account}/delivery_estimate` | GET | Audience size estimate |

### Insights & Reporting

| Endpoint | Method | Description |
|----------|--------|-------------|
| `{account}/insights` | GET | Synchronous insights query |
| `{account}/insights` | POST | Start async insights report |
| `{report_run_id}` | GET | Async report status |
| `{report_run_id}/insights` | GET | Fetch async report results |

---

## Fields by Entity

### Campaign Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Campaign ID |
| `name` | string | Campaign name |
| `status` | enum | `ACTIVE`, `PAUSED`, `DELETED`, `ARCHIVED` |
| `effective_status` | enum | Computed delivery status |
| `objective` | string | Campaign objective (CONVERSIONS, REACH, etc.) |
| `daily_budget` | string | Daily budget in cents |
| `lifetime_budget` | string | Lifetime budget in cents |
| `budget_remaining` | string | Remaining budget in cents |
| `bid_strategy` | string | LOWEST_COST_WITHOUT_CAP, COST_CAP, etc. |
| `buying_type` | string | AUCTION, RESERVED |
| `special_ad_categories` | array | HOUSING, CREDIT, EMPLOYMENT, etc. |
| `start_time` | datetime | Campaign start |
| `stop_time` | datetime | Campaign end |
| `created_time` | datetime | Creation timestamp |
| `updated_time` | datetime | Last update timestamp |

### Ad Set Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Adset ID |
| `name` | string | Adset name |
| `status` | enum | ACTIVE, PAUSED, DELETED, ARCHIVED |
| `effective_status` | enum | Computed delivery status |
| `campaign_id` | string | Parent campaign |
| `daily_budget` | string | Daily budget in cents |
| `lifetime_budget` | string | Lifetime budget in cents |
| `budget_remaining` | string | Remaining budget |
| `optimization_goal` | string | IMPRESSIONS, REACH, LINK_CLICKS, etc. |
| `bid_strategy` | string | Bidding strategy |
| `bid_amount` | string | Bid amount in cents |
| `billing_event` | string | IMPRESSIONS, LINK_CLICKS, etc. |
| `targeting` | object | Full targeting specification |
| `promoted_object` | object | Pixel ID, app, page, etc. |
| `destination_type` | string | WEBSITE, APP, MESSENGER, etc. |
| `attribution_spec` | array | Attribution settings |
| `start_time` | datetime | Delivery start |
| `end_time` | datetime | Delivery end |
| `created_time` | datetime | Creation timestamp |
| `updated_time` | datetime | Last update |

### Ad Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Ad ID |
| `name` | string | Ad name |
| `status` | enum | ACTIVE, PAUSED, DELETED, ARCHIVED |
| `effective_status` | enum | Computed delivery status |
| `adset_id` | string | Parent adset |
| `campaign_id` | string | Parent campaign |
| `creative` | object | `{id, name}` — linked creative |
| `created_time` | datetime | Creation timestamp |
| `updated_time` | datetime | Last update |

### Creative Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Creative ID |
| `name` | string | Creative name |
| `status` | string | Creative status |
| `title` | string | Ad title |
| `body` | string | Ad body text |
| `call_to_action_type` | string | SHOP_NOW, LEARN_MORE, etc. |
| `image_url` | string | Image URL |
| `image_hash` | string | Image hash for reference |
| `thumbnail_url` | string | Video thumbnail URL |
| `object_type` | string | PHOTO, VIDEO, SHARE, etc. |
| `object_story_spec` | object | Page post spec (page_id, link_data, video_data) |
| `asset_feed_spec` | object | Dynamic creative assets |
| `url_tags` | string | URL tracking parameters |

### Insights Fields

| Field | Type | Description |
|-------|------|-------------|
| `campaign_name` | string | Campaign name |
| `adset_name` | string | Adset name |
| `adset_id` | string | Adset ID |
| `ad_name` | string | Ad name |
| `impressions` | string | Total impressions |
| `clicks` | string | Total clicks |
| `spend` | string | Total spend (decimal USD) |
| `cpc` | string | Cost per click |
| `cpm` | string | Cost per 1000 impressions |
| `ctr` | string | Click-through rate (%) |
| `reach` | string | Unique users reached |
| `frequency` | string | Average impressions per user |
| `actions` | array | Conversion events `[{action_type, value}]` |
| `action_values` | array | Revenue values `[{action_type, value}]` |
| `outbound_clicks` | array | Off-platform clicks |
| `inline_link_clicks` | string | Inline link clicks |
| `video_play_actions` | array | Video plays |
| `video_p25_watched_actions` | array | Watched 25%+ |
| `video_p50_watched_actions` | array | Watched 50%+ |
| `video_p75_watched_actions` | array | Watched 75%+ |
| `video_p100_watched_actions` | array | Watched 100% |
| `video_30_sec_watched_actions` | array | Watched 30+ seconds |
| `video_thruplay_watched_actions` | array | Thruplays |

---

## Action Types

### Conversion Types (used in `extract_conversions`)

```
offsite_conversion.fb_pixel_purchase
offsite_conversion.fb_pixel_complete_registration
offsite_conversion.fb_pixel_lead
purchase
complete_registration
lead
omni_purchase
onsite_conversion.messaging_conversation_started_7d
```

### Purchase Types (used in `extract_purchase_value`)

```
offsite_conversion.fb_pixel_purchase
purchase
omni_purchase
```

### Purchase Value Types

```
offsite_conversion.fb_pixel_purchase
purchase
omni_purchase
```

### Lead Types

```
offsite_conversion.fb_pixel_lead
lead
onsite_conversion.lead_grouped
onsite_conversion.messaging_conversation_started_7d
```

### Add to Cart Types

```
offsite_conversion.fb_pixel_add_to_cart
add_to_cart
```

### Landing Page View Types

```
landing_page_view
offsite_conversion.fb_pixel_view_content
```

### Initiate Checkout Types

```
offsite_conversion.fb_pixel_initiate_checkout
initiate_checkout
```

### Engagement Types

```
post_engagement
page_engagement
post_reaction
comment
post
like
photo_view
video_view
link_click
```

---

## Attribution Windows

| Window | Description |
|--------|-------------|
| `1d_click` | 1-day click-through |
| `7d_click` | 7-day click-through |
| `28d_click` | 28-day click-through |
| `1d_view` | 1-day view-through |
| `7d_view` | 7-day view-through |
| `28d_view` | 28-day view-through |
| `1d_ev` | 1-day engaged view |
| `7d_ev` | 7-day engaged view |

---

## Rate Limit Headers

| Header | Description |
|--------|-------------|
| `x-app-usage` | Application-level quota `{call_count, total_cputime, total_time}` (0-100%) |
| `x-page-usage` | Page-level quota |
| `x-ad-account-usage` | Ad account-level quota `{acc_id_util_pct}` |

---

## Account Status Codes

| Code | Status |
|------|--------|
| 1 | ACTIVE |
| 2 | DISABLED |
| 3 | UNSETTLED |
| 7 | PENDING_RISK_REVIEW |
| 8 | PENDING_SETTLEMENT |
| 9 | IN_GRACE_PERIOD |
| 100 | PENDING_CLOSURE |
| 101 | CLOSED |
| 201 | ANY_ACTIVE |
| 202 | ANY_CLOSED |

---

## Budget Encoding

The Meta API represents budgets in **cents** (integer). `apb` accepts and displays budgets in **USD** (decimal) and converts internally:

- User input: `--daily-budget 50.00` (USD)
- API value: `daily_budget: 5000` (cents)
- Display: `$50.00` (USD)

Safety cap: Maximum `$10,000/day` for `adset update-budget`.
