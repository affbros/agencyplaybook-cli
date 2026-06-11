# Changelog — apb-gads (Google Ads CLI)

All notable changes to the `apb-gads` CLI binary distribution.

Format inspired by [Keep a Changelog](https://keepachangelog.com/). This file is mirrored to the public repo `affbros/agencyplaybook-cli` (as `CHANGELOG-gads.md`, beside `apb`'s `CHANGELOG.md`) on every `gads-v*` release tag. apb-gads has its own version line (`0.1.x`) and tags (`gads-vX.Y.Z`), independent of `apb`.

## [Unreleased]

## [0.1.0] — 2026-06-11 (first public release)

The first published `apb-gads` binary — operator-grade Google Ads account management (reads, reports, agency "playbooks", and safe gated mutations), authenticated with your existing AgencyPlaybook API key.

### Added
- **3-platform binaries** published to `affbros/agencyplaybook-cli` (`bin/{linux-x86_64,macos,windows-x86_64}/apb-gads[.exe]`), beside `apb`. Downloaded binaries default to `https://api.agencyplaybook.io`.
- **SaaS authentication** — set one `APB_API_KEY` and `apb-gads` resolves Google Ads credentials from the AgencyPlaybook API (`/auth/resolve?provider=google_ads`); the Google refresh token never leaves the server. `apb-gads auth login` writes the shared `~/.apb/.env` (one login serves both `apb` and `apb-gads`); `auth status` and `auth connect-google` (OAuth device flow) round out the flow.
- **Two credential modes** — managed OAuth (server-held refresh token) or BYO local `google-ads.yaml` (`GOOGLE_ADS_OAUTH=DISABLED`); both require `APB_API_KEY` so tier/scope/entitlement are enforced.
- **Entitlement-aware** — the Google Ads add-on (Professional+) gates access; reads need Professional+, writes need Agency+. A read-only plan can't execute writes regardless of local config (the write-policy floor).
- **Safety preserved** — the contract-tested 3-gate write model (dry-run default; `--execute` + config + env gates; per-customer profiles / sandbox) is intact. Mutations are dry-run unless explicitly gated.
- `apb-gads --version`; `--pretty` JSON output; provider-namespaced credential cache (`~/.apb/tenant_context.google_ads.json`).

### Notes
- The **public binary refuses to run without `APB_API_KEY`** — Google Ads access is a paid add-on on the AgencyPlaybook platform.
- Surface: 28 command groups (`customer`, `campaign`, `report`, `playbook`, `mutate`, `plan`, `verify`, `auth`, …). See the bundled docs / `apb-gads --help`.
