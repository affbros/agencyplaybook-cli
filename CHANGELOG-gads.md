# Changelog — apb-gads (Google Ads CLI)

All notable changes to the `apb-gads` CLI binary distribution.

Format inspired by [Keep a Changelog](https://keepachangelog.com/). This file is mirrored to the public repo `affbros/agencyplaybook-cli` (as `CHANGELOG-gads.md`, beside `apb`'s `CHANGELOG.md`) on every `gads-v*` release tag. apb-gads has its own version line (`0.1.x`) and tags (`gads-vX.Y.Z`), independent of `apb`.

## [Unreleased]

## [0.1.2] — 2026-06-16

### Added
- **`account` command group** (`list` / `use` / `current` / `clear`) — persistent operating-account selection for agencies managing many accounts under one manager (MCC). Pick a current child account once (`apb-gads account use <customer_id>`, persisted to `~/.apb-gads/state.json` with `0600` perms) and every later command targets it **without repeating `--customer`**. Resolution precedence: `--customer` flag > persisted selection > config/SaaS default. The manager account (`login_customer_id`) is never switched — only the operating account. `account use` validates the id against your accessible accounts in SaaS mode, and `account current` reports the resolved account and where it came from.

### Changed
- Internal hardening: the gads crates now build clean under `cargo clippy -- -D warnings` and `rustfmt --check`, both CI hard-gated.

## [0.1.1] — 2026-06-12

### Added
- **Proxy auth mode (S008b)** — when the tenant is in proxy mode, `apb-gads` calls the AgencyPlaybook API edge authenticated with its `APB_API_KEY`; the real Google access/developer tokens are injected server-side and never disclosed to the binary.
- **Docs + Claude skill at `apb` parity** — full `apb-gads` command/flag reference, the `agencyplaybook-cli-google` Claude skill, and an in-app `/cli-reference/google` page. CI hard-gates skill / catalogue / generated-doc drift against the binary.

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
