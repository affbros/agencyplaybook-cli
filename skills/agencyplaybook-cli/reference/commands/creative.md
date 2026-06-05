# `apb creative` — Command Reference

18 commands. Auto-generated from the apb binary on 2026-06-05.

### `apb creative asset-audit`

Audit creative assets

**Scope:** `read:campaigns` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--campaign` | `<CAMPAIGN>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative asset-audit --campaign <CAMPAIGN>
```

### `apb creative create-carousel`

Create a carousel creative from object_story_spec.link_data.child_attachments

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--name` | `<NAME>` |  |
| `--spec` | `<SPEC>` |  |
| `--spec-file` | `<SPEC_FILE>` |  |
| `--creative-format` | `<CREATIVE_FORMAT>` | Declared creative format intent (informational; sharpens auditor messages) [possible values: single_image, single_video, carousel, collection, dynamic_creative, catalog, post, automatic] |
| `--allow-carousel` |  | Whitelist CAROUSEL / CAROUSEL_IMAGE / CAROUSEL_VIDEO in asset_feed_spec.ad_formats |
| `--allow-collection` |  | Whitelist COLLECTION in asset_feed_spec.ad_formats |
| `--allow-automatic-format` |  | Whitelist AUTOMATIC_FORMAT in asset_feed_spec.ad_formats |
| `--allow-format-automation` |  | Whitelist FORMAT_AUTOMATION / degrees_of_freedom_spec / contextual_multi_ads |
| `--allow-catalog-template` |  | Whitelist product_set_id / template_url / {{product.*}} template syntax |
| `--strict-format` |  | Upgrade dry-run findings to dry-run errors (CI use — fail loud on any finding) |
| `--audit-only` |  | Audit the spec, surface findings, exit without writing — regardless of --execute |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative create-carousel --execute --name <NAME> --spec <SPEC>
```

### `apb creative create-catalog-creative`

Build a catalog / product-set-linked creative (v0.2.0). The `--format` flag auto-wires the matching Sprint-1 `--allow-*` flag, so an intentional `--format collection` doesn't trip the auditor

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--name` | `<NAME>` |  |
| `--page-id` | `<PAGE_ID>` |  |
| `--catalog-id` | `<CATALOG_ID>` |  |
| `--product-set-id` | `<PRODUCT_SET_ID>` |  |
| `--hero-image` | `<HERO_IMAGE>` | Hero image hash or local file path |
| `--hero-image-name` | `<HERO_IMAGE_NAME>` | Name to store the uploaded hero image under (default: the file's basename) |
| `--headline` | `<HEADLINE>` |  |
| `--body` | `<BODY>` |  |
| `--url` | `<URL>` |  |
| `--cta` | `<CTA>` |  |
| `--format` | `<FORMAT>` | Catalog rendering format. Auto-wires the corresponding auditor allow flag Possible values: - single:     Single product card. Auditor: no extra allow flag - carousel:   Carousel of product cards. Auditor auto-passes `allow_carousel=true` - collection: Collection (catalog mobile shopping). Auditor auto-passes `allow_collection=true` - automatic:  Automatic format selection (Meta picks at delivery). Auditor auto-passes `allow_format_automation=true` AND `allow_automatic_format=true` [default: single] |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative create-catalog-creative --execute --name <NAME> --page-id <PAGE_ID>
```

### `apb creative create-collection`

Create a collection ad creative (catalog-driven mobile shopping format). The full spec is too deeply nested for flag-by-flag construction; pass `--spec-file` containing the complete creative payload. See `docs/examples/creative-collection-spec.json` for a working example

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--name` | `<NAME>` |  |
| `--spec-file` | `<SPEC_FILE>` |  |
| `--creative-format` | `<CREATIVE_FORMAT>` | Declared creative format intent (informational; sharpens auditor messages) [possible values: single_image, single_video, carousel, collection, dynamic_creative, catalog, post, automatic] |
| `--allow-carousel` |  | Whitelist CAROUSEL / CAROUSEL_IMAGE / CAROUSEL_VIDEO in asset_feed_spec.ad_formats |
| `--allow-collection` |  | Whitelist COLLECTION in asset_feed_spec.ad_formats |
| `--allow-automatic-format` |  | Whitelist AUTOMATIC_FORMAT in asset_feed_spec.ad_formats |
| `--allow-format-automation` |  | Whitelist FORMAT_AUTOMATION / degrees_of_freedom_spec / contextual_multi_ads |
| `--allow-catalog-template` |  | Whitelist product_set_id / template_url / {{product.*}} template syntax |
| `--strict-format` |  | Upgrade dry-run findings to dry-run errors (CI use — fail loud on any finding) |
| `--audit-only` |  | Audit the spec, surface findings, exit without writing — regardless of --execute |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative create-collection --execute --name <NAME> --spec-file <SPEC_FILE>
```

### `apb creative create-dynamic`

Create a dynamic creative with asset_feed_spec (Meta optimizes across multiple assets)

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--name` | `<NAME>` |  |
| `--page-id` | `<PAGE_ID>` |  |
| `--spec` | `<SPEC>` | JSON asset_feed_spec or path to file |
| `--spec-file` | `<SPEC_FILE>` |  |
| `--image` | `<IMAGE>` | Inline image hash or path. Repeat for multiple variants. Mutually exclusive with --spec-file/--spec |
| `--title` | `<TITLE>` | Inline title text. Repeat for multiple variants. Mutually exclusive with --spec-file/--spec |
| `--body` | `<BODY>` | Inline body text. Repeat for multiple variants. Mutually exclusive with --spec-file/--spec |
| `--description` | `<DESCRIPTION>` | Inline description text (asset_feed_spec.descriptions[]). Repeat for multiple variants |
| `--video` | `<VIDEO>` | Inline pre-uploaded video ID (asset_feed_spec.videos[]). Repeat for multiple variants. (Paths aren't auto-uploaded here — pre-upload via `creative upload-video`.) |
| `--cta` | `<CTA>` | Call-to-action button (e.g. LEARN_MORE, SHOP_NOW). Used with inline DCO flags |
| `--url` | `<URL>` | Click-through URL. Used with inline DCO flags |
| `--optimization-type` | `<OPTIMIZATION_TYPE>` | asset_feed_spec.optimization_type, e.g. DEGREES_OF_FREEDOM or FORMAT_AUTOMATION (the latter trips the auditor — pair with --allow-format-automation) |
| `--creative-format` | `<CREATIVE_FORMAT>` | Declared creative format intent (informational; sharpens auditor messages) [possible values: single_image, single_video, carousel, collection, dynamic_creative, catalog, post, automatic] |
| `--allow-carousel` |  | Whitelist CAROUSEL / CAROUSEL_IMAGE / CAROUSEL_VIDEO in asset_feed_spec.ad_formats |
| `--allow-collection` |  | Whitelist COLLECTION in asset_feed_spec.ad_formats |
| `--allow-automatic-format` |  | Whitelist AUTOMATIC_FORMAT in asset_feed_spec.ad_formats |
| `--allow-format-automation` |  | Whitelist FORMAT_AUTOMATION / degrees_of_freedom_spec / contextual_multi_ads |
| `--allow-catalog-template` |  | Whitelist product_set_id / template_url / {{product.*}} template syntax |
| `--strict-format` |  | Upgrade dry-run findings to dry-run errors (CI use — fail loud on any finding) |
| `--audit-only` |  | Audit the spec, surface findings, exit without writing — regardless of --execute |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative create-dynamic --execute --name <NAME> --page-id <PAGE_ID>
```

### `apb creative create-image`

Create an image creative

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--name` | `<NAME>` |  |
| `--spec` | `<SPEC>` |  |
| `--path` | `<PATH>` |  |
| `--spec-file` | `<SPEC_FILE>` |  |
| `--creative-format` | `<CREATIVE_FORMAT>` | Declared creative format intent (informational; sharpens auditor messages) [possible values: single_image, single_video, carousel, collection, dynamic_creative, catalog, post, automatic] |
| `--allow-carousel` |  | Whitelist CAROUSEL / CAROUSEL_IMAGE / CAROUSEL_VIDEO in asset_feed_spec.ad_formats |
| `--allow-collection` |  | Whitelist COLLECTION in asset_feed_spec.ad_formats |
| `--allow-automatic-format` |  | Whitelist AUTOMATIC_FORMAT in asset_feed_spec.ad_formats |
| `--allow-format-automation` |  | Whitelist FORMAT_AUTOMATION / degrees_of_freedom_spec / contextual_multi_ads |
| `--allow-catalog-template` |  | Whitelist product_set_id / template_url / {{product.*}} template syntax |
| `--strict-format` |  | Upgrade dry-run findings to dry-run errors (CI use — fail loud on any finding) |
| `--audit-only` |  | Audit the spec, surface findings, exit without writing — regardless of --execute |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative create-image --execute --name <NAME> --spec <SPEC>
```

### `apb creative create-image-simple`

Build an image creative from operator-friendly flags (v0.2.0). Generates the v25 AdCreative spec internally — no JSON authoring needed. Calls the existing service-layer create_from_spec; the Sprint 1 auditor runs

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--name` | `<NAME>` |  |
| `--page-id` | `<PAGE_ID>` |  |
| `--image` | `<IMAGE>` | Image hash, or local file path (auto-uploaded under `--execute`) |
| `--image-name` | `<IMAGE_NAME>` | Name to store the uploaded image under (default: the file's basename) |
| `--headline` | `<HEADLINE>` |  |
| `--body` | `<BODY>` |  |
| `--description` | `<DESCRIPTION>` |  |
| `--url` | `<URL>` |  |
| `--cta` | `<CTA>` | CTA enum (e.g. `SHOP_NOW`, `LEARN_MORE`) |
| `--instagram-actor-id` | `<INSTAGRAM_ACTOR_ID>` | (deprecated) Use --instagram-user-id. Sets object_story_spec.instagram_actor_id |
| `--instagram-user-id` | `<INSTAGRAM_USER_ID>` | Top-level `instagram_user_id` (v25). Preferred over --instagram-actor-id (deprecated 2025-09-09) for IG-placement creatives |
| `--url-tags` | `<URL_TAGS>` |  |
| `--enhancements` | `<ENHANCEMENTS>` | Advantage+ creative enhancements → degrees_of_freedom_spec. `none` (default), or a CSV of UPPERCASE per-feature keys (e.g. `IMAGE_ANIMATION,TEXT_OVERLAY_TRANSLATION`). NOTE: `standard` is deprecated by Meta (the standard_enhancements bundle was removed) → no-op |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative create-image-simple --execute --name <NAME> --page-id <PAGE_ID>
```

### `apb creative create-lead-form-ad`

Build a lead-form ad creative (v0.2.0). FIRST `lead_gen_form_id` injection in the codebase. Validates the form belongs to the page before writing

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--name` | `<NAME>` |  |
| `--page-id` | `<PAGE_ID>` |  |
| `--form-id` | `<FORM_ID>` |  |
| `--image` | `<IMAGE>` | Hero image hash or local file path |
| `--image-name` | `<IMAGE_NAME>` | Name to store the uploaded image under (default: the file's basename) |
| `--headline` | `<HEADLINE>` |  |
| `--body` | `<BODY>` |  |
| `--url` | `<URL>` |  |
| `--cta` | `<CTA>` | CTA. Defaults to `SIGN_UP` for lead-form ads [default: SIGN_UP] |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative create-lead-form-ad --execute --name <NAME> --page-id <PAGE_ID>
```

### `apb creative create-reels-video-template`

Build a Reels-suitable video creative (v0.2.0). Emits Reels-format suitability advisories. NOT a separate Meta endpoint

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--name` | `<NAME>` |  |
| `--page-id` | `<PAGE_ID>` |  |
| `--video` | `<VIDEO>` |  |
| `--video-name` | `<VIDEO_NAME>` | Name to store an uploaded video under (default: the file's basename) |
| `--thumbnail` | `<THUMBNAIL>` |  |
| `--thumbnail-name` | `<THUMBNAIL_NAME>` | Name to store the uploaded thumbnail under (default: the file's basename) |
| `--headline` | `<HEADLINE>` |  |
| `--body` | `<BODY>` |  |
| `--url` | `<URL>` |  |
| `--cta` | `<CTA>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative create-reels-video-template --execute --name <NAME> --page-id <PAGE_ID>
```

### `apb creative create-story-template`

Build a Stories-suitable image or video creative (v0.2.0). Emits Stories-format suitability advisories (vertical 9:16 reminder) in the dry-run preview. NOT a separate Meta endpoint — generates a normal AdCreative spec

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--name` | `<NAME>` |  |
| `--page-id` | `<PAGE_ID>` |  |
| `--image` | `<IMAGE>` | Image hash or path (mutually exclusive with `--video`) |
| `--image-name` | `<IMAGE_NAME>` | Name to store an uploaded image under (default: the file's basename) |
| `--video` | `<VIDEO>` | Video ID or path (mutually exclusive with `--image`) |
| `--video-name` | `<VIDEO_NAME>` | Name to store an uploaded video under (default: the file's basename) |
| `--thumbnail` | `<THUMBNAIL>` | Required when `--video` is used |
| `--thumbnail-name` | `<THUMBNAIL_NAME>` | Name to store the uploaded thumbnail under (default: the file's basename) |
| `--headline` | `<HEADLINE>` |  |
| `--body` | `<BODY>` |  |
| `--url` | `<URL>` |  |
| `--cta` | `<CTA>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative create-story-template --execute --name <NAME> --page-id <PAGE_ID>
```

### `apb creative create-video`

Create a video creative

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--name` | `<NAME>` |  |
| `--spec` | `<SPEC>` |  |
| `--path` | `<PATH>` |  |
| `--spec-file` | `<SPEC_FILE>` |  |
| `--thumbnail` | `<THUMBNAIL>` | Video thumbnail: a local image path (uploaded for you) or an existing Meta image hash. Injected as `video_data.image_hash`, which Meta requires for video creatives. If omitted, the spec must already supply `video_data.image_hash` or `video_data.image_url` |
| `--creative-format` | `<CREATIVE_FORMAT>` | Declared creative format intent (informational; sharpens auditor messages) [possible values: single_image, single_video, carousel, collection, dynamic_creative, catalog, post, automatic] |
| `--allow-carousel` |  | Whitelist CAROUSEL / CAROUSEL_IMAGE / CAROUSEL_VIDEO in asset_feed_spec.ad_formats |
| `--allow-collection` |  | Whitelist COLLECTION in asset_feed_spec.ad_formats |
| `--allow-automatic-format` |  | Whitelist AUTOMATIC_FORMAT in asset_feed_spec.ad_formats |
| `--allow-format-automation` |  | Whitelist FORMAT_AUTOMATION / degrees_of_freedom_spec / contextual_multi_ads |
| `--allow-catalog-template` |  | Whitelist product_set_id / template_url / {{product.*}} template syntax |
| `--strict-format` |  | Upgrade dry-run findings to dry-run errors (CI use — fail loud on any finding) |
| `--audit-only` |  | Audit the spec, surface findings, exit without writing — regardless of --execute |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative create-video --execute --name <NAME> --spec <SPEC>
```

### `apb creative create-video-simple`

Build a video creative from operator-friendly flags (v0.2.0). Same shape as `create-image-simple` for the video path

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--name` | `<NAME>` |  |
| `--page-id` | `<PAGE_ID>` |  |
| `--video` | `<VIDEO>` | Video ID (pre-uploaded) or local file path (auto-uploaded under `--execute`) |
| `--video-name` | `<VIDEO_NAME>` | Name to store an uploaded video under (default: the file's basename). Ignored when --video is a pre-uploaded video ID |
| `--thumbnail` | `<THUMBNAIL>` | Thumbnail: image hash or local file path. Meta requires a thumbnail on every video creative; the builder injects it as `object_story_spec.video_data.image_hash` |
| `--thumbnail-name` | `<THUMBNAIL_NAME>` | Name to store the uploaded thumbnail under (default: the file's basename) |
| `--headline` | `<HEADLINE>` |  |
| `--body` | `<BODY>` |  |
| `--url` | `<URL>` |  |
| `--cta` | `<CTA>` |  |
| `--instagram-actor-id` | `<INSTAGRAM_ACTOR_ID>` | (deprecated) Use --instagram-user-id. Sets object_story_spec.instagram_actor_id |
| `--instagram-user-id` | `<INSTAGRAM_USER_ID>` | Top-level `instagram_user_id` (v25). Preferred over --instagram-actor-id (deprecated 2025-09-09) for IG-placement creatives |
| `--url-tags` | `<URL_TAGS>` |  |
| `--enhancements` | `<ENHANCEMENTS>` | Advantage+ creative enhancements → degrees_of_freedom_spec. `none` (default) or a CSV of UPPERCASE feature keys. `standard` is deprecated by Meta (removed) → no-op |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative create-video-simple --execute --name <NAME> --page-id <PAGE_ID>
```

### `apb creative get`

Get a single creative

**Scope:** `read:campaigns` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--creative-id` | `<CREATIVE_ID>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative get --id <ID> --creative-id <CREATIVE_ID>
```

### `apb creative list`

List creatives

**Scope:** `read:campaigns` · **Min tier:** starter

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--limit` | `<LIMIT>` |  |
| `--after` | `<AFTER>` |  |
| `--all` |  |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative list --limit <LIMIT> --after <AFTER>
```

### `apb creative update`

Update a creative

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--creative-id` | `<CREATIVE_ID>` |  |
| `--name` | `<NAME>` |  |
| `--spec` | `<SPEC>` |  |
| `--spec-file` | `<SPEC_FILE>` |  |
| `--creative-format` | `<CREATIVE_FORMAT>` | Declared creative format intent (informational; sharpens auditor messages) [possible values: single_image, single_video, carousel, collection, dynamic_creative, catalog, post, automatic] |
| `--allow-carousel` |  | Whitelist CAROUSEL / CAROUSEL_IMAGE / CAROUSEL_VIDEO in asset_feed_spec.ad_formats |
| `--allow-collection` |  | Whitelist COLLECTION in asset_feed_spec.ad_formats |
| `--allow-automatic-format` |  | Whitelist AUTOMATIC_FORMAT in asset_feed_spec.ad_formats |
| `--allow-format-automation` |  | Whitelist FORMAT_AUTOMATION / degrees_of_freedom_spec / contextual_multi_ads |
| `--allow-catalog-template` |  | Whitelist product_set_id / template_url / {{product.*}} template syntax |
| `--strict-format` |  | Upgrade dry-run findings to dry-run errors (CI use — fail loud on any finding) |
| `--audit-only` |  | Audit the spec, surface findings, exit without writing — regardless of --execute |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative update --execute --id <ID> --creative-id <CREATIVE_ID>
```

### `apb creative upload-image`

Upload an image asset

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--path` | `<PATH>` |  |
| `--name` | `<NAME>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative upload-image --execute --path <PATH> --name <NAME>
```

### `apb creative upload-video`

Upload a video asset

**Scope:** `write:campaigns` · **Min tier:** agency · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--account` | `<ACCOUNT>` |  |
| `--path` | `<PATH>` |  |
| `--name` | `<NAME>` | Asset name stored in Meta's video library (default: the file's basename) |
| `--title` | `<TITLE>` | Display title shown on the video (default: the asset name) |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative upload-video --execute --path <PATH> --name <NAME>
```

### `apb creative upload-video-status`

Check video upload status

**Scope:** `read:campaigns` · **Min tier:** starter · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |

```bash
apb creative upload-video-status --execute --id <ID>
```
