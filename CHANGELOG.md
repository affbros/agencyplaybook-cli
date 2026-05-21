# Changelog

All notable changes to the `apb` CLI binary distribution.

Format inspired by [Keep a Changelog](https://keepachangelog.com/). This file is mirrored to the public repo `affbros/agencyplaybook-cli` on every release tag.

## [Unreleased]

## [0.1.8] — 2026-05-21

Behavioral/bugfix release from a live-account review (findings RT-1…RT-10). No command surface change.

### Security
- **Meta access tokens are now redacted from CLI stdout.** Meta Graph responses embed `access_token=EAA…` inside `paging.next`/`paging.previous` URLs; commands that print raw responses (e.g. `pixel stats`, `pixel events`, `catalog products`, and the CAPI `pixel send-event`/`send-batch` success output) leaked that token to terminal scrollback, CI logs, and piped captures. Tokens are now stripped from paging URLs at the source (so the HTTP API is covered too) and the CLI output formatter redacts any residual token. Opaque `paging.cursors` are preserved, so `--after` pagination is unaffected (RT-2).

### Fixed
- **`playbook capi-dual-signal` no longer reports a false "CAPI off / grade F"** on accounts where the Conversions API is actively firing. It sent the pixel `/stats` window as Unix epoch seconds (Meta expects `YYYY-MM-DD`) and read event counts from the wrong field, so it always saw zero server events. It now queries `SERVER_ONLY`/`WEB_ONLY` over a correct date range (RT-3).
- **Diagnostic playbooks now return a distinct "insufficient data" state** (`grade: "N/A"`, `score: null`, `insufficient_data: true`) when there is nothing to analyze, instead of disagreeing — some previously returned grade A/100 ("nothing flagged") and others grade F/0 ("zero average") for the same empty account (RT-1, RT-5).
- **`report insights --days` rejects `0` and negative values** with a clean "value must be ≥ 1" message instead of returning an ambiguous single-day window (`--days 0`) or a confusing `unexpected argument '-5'` (RT-8, RT-9).
- **`waste-audit` no longer prints `Best CPA adset:  at $0.00`** when no ad set had a conversion — it now says `N/A (no conversions in window)` (RT-10a).
- **`leadgen list` / `leadgen leads` give an actionable hint** when Meta returns `(#190) … Page Access Token` instead of surfacing the raw Graph error (RT-10c).

### Changed
- **Pixel-domain flags accept both `--id` and `--pixel-id` everywhere.** Previously `pixel get`/`stats`/`diagnostics` used `--id` while `pixel signal`/`quality`/`events` and `dataset pixel-*` used `--pixel-id`; both spellings now work across the whole pixel domain via aliases (RT-7).
- **Playbook ad-set counts now name their basis** so they reconcile across playbooks: "delivering in window" (health-score) vs "status-ACTIVE" (creative-mix/broad-targeting/event-hierarchy) vs "total" (duplicate-detect) (RT-6).
- **`apb campaign get --help`** now documents that `--id` accepts a numeric ID, an `@alias`, or an exact campaign name (auto-resolved) (NEW-2).

### Notes
- RT-4 (insights cache "ignores date range") was investigated and is **not a bug**: the response cache key already includes the full query (time range, level, increment). A regression test was added to lock this in. The reported identical spend across `--days 1/7/30` matched an account whose entire spend history fell within the shortest window.

## [0.1.7] — 2026-05-21

### Fixed
- **`apb plan` mutating commands now require the `write:campaigns` scope** (Agency tier+), matching the HTTP API. The CLI previously mapped every `plan` subcommand to `read:campaigns`, so a read-only–tier key could create/validate/execute/canary/approve plans from the CLI even though the API correctly rejected the same operations (`POST /plans/*` is gated `write:campaigns`). `plan list` and `plan doctor` remain `read:campaigns`. No change for Agency+ tiers.

## [0.1.6] — 2026-05-21

### Fixed
- **`apb auth login` now uses the baked production API URL.** It (and the stored-credential `base_url()` default) hardcoded `http://localhost:3000` and ignored the compile-time `APB_DEFAULT_API_URL`, so downloaded binaries failed `auth login` with "Failed to connect to SaaS API at http://localhost:3000" unless `--api-url` was passed. Both now fall back to `cli_resolver::DEFAULT_API_URL` (baked `https://api.agencyplaybook.io` in release builds; localhost only for local dev). Other commands were unaffected — they already resolved through that default.

## [0.1.5] — 2026-05-20

### Changed
- **macOS binary is now Developer ID-signed and notarized.** The `build-macos` CI job codesigns the universal binary (hardened runtime + secure timestamp) and submits it to Apple's notary service before publishing, so macOS no longer shows "Apple could not verify 'apb' is free of malware." A bare Mach-O can't be stapled, so Gatekeeper verifies the notarization ticket online by code hash.

## [0.1.4] — 2026-05-19

### Fixed
- **Linux binary glibc compatibility.** v0.1.3 built on `ubuntu-latest` (now Ubuntu 24.04, glibc 2.39), which made the Linux binary fail to run on Debian 12, Ubuntu 22.04 LTS, RHEL 9, and any older distro. Pinned `build-linux` and `publish` jobs to `ubuntu-22.04` (glibc 2.35) for broader compatibility. Same fix applied to the README's platform compatibility note.

## [0.1.3] — 2026-05-19

Adds a global config file so the downloaded binary works from any directory.

### Added
- `~/.apb/.env` global credentials file. The CLI loads it on every invocation after the project-local `.env`, so users with the downloaded binary set `APB_API_KEY` and `APB_API_URL` once and the CLI works from any cwd.
- Precedence order is now: shell env → CWD `.env` → `~/.apb/.env` → compile-time defaults. CWD wins on conflicts (per-project override pattern).
- Public README rewritten with platform-specific setup blocks (Linux/macOS bash + Windows PowerShell).

### Changed
- `rust/crates/apb-cli/src/main.rs` extended with `dotenvy::from_path(home/.apb/.env)` after the existing `dotenvy::dotenv()` call. Uses the existing `dirs` dep — no new deps added.

## [0.1.2] — 2026-05-19

Restores the Windows binary that was erroneously dropped in v0.1.1.

### Added
- `build-windows` job back in the release matrix (`windows-latest`, target `x86_64-pc-windows-msvc`). Produces `apb.exe` with `APB_DEFAULT_API_URL=https://api.agencyplaybook.io` baked in. RUSTFLAGS path-remap covers `C:\Users\runneradmin\.cargo`. Tee-to-file verification pattern matches Linux + macOS jobs.
- Publish job extended to handle 3 artifacts: writes to `bin/linux-x86_64/`, `bin/macos/`, `bin/windows-x86_64/`.

### Why
v0.1.1 dropped Windows after I misinterpreted "macOS/Linux version — which is what Claude Code does" as a directive to remove Windows entirely. It wasn't — the user was specifying the macOS distribution model (one universal binary instead of separate Intel/aarch64), not eliminating Windows. Windows was the one platform that built cleanly across every prior CI attempt; removing it solved no problem.

## [0.1.1] — 2026-05-19

First end-to-end CI release. Build matrix simplified to 2 jobs (Linux + macOS universal) following Claude Code's distribution model. Windows support deferred to WSL2 (run the Linux binary inside Ubuntu — no functionality loss).

### Changed
- Build matrix: 4 jobs → 2 jobs. `macos-x86_64` (Intel Mac runner, indefinitely queued due to GitHub macOS minutes quota) and `windows-x86_64` (deferred) both removed. macOS replaced with a single universal binary built on `macos-14` via `lipo -create` merging both arch slices.
- Public-repo layout: `bin/macos-x86_64/` and `bin/macos-aarch64/` collapsed into `bin/macos/`. `bin/windows-x86_64/` removed.

### Added
- macOS universal binary (Intel + Apple Silicon) shipped natively — runs on both architectures without Rosetta.
- Refreshed Linux x86_64 binary built by CI.

### Notes
- Binaries built with `APB_DEFAULT_API_URL=https://api.agencyplaybook.io` baked in.
- macOS verification step uses tee-to-file pattern (avoids `strings|grep -q` SIGPIPE under macOS toolchain).
- Windows users: see `docs/INSTALL.md` (or the public README) for WSL2 setup.

## [0.1.0] — 2026-05-19

Initial public release.

### Added
- Pre-built `apb` binary for Linux x86_64 (glibc 2.31+). macOS Intel, macOS Apple Silicon, and Windows x86_64 binaries arrive on the first CI tag build (`release.yml` workflow).
- Full CLI surface: 226 commands across 30 domains.
- Public docs: CLI reference, usage guide, safety model, API reference, automation patterns, campaign-composer guide, Meta API field reference.
- Example JSON specs: compose, carousel, lead-gen form, creative collection.
- MIT license on the public-binary repo.

### Notes
- Binary defaults `APB_API_URL` to `https://api.agencyplaybook.io` (the production API endpoint — currently in private beta). Override via the `APB_API_URL` env var for self-hosted endpoints or local development.
- All mutating commands require `--execute` (dry-run is default). Destructive ops additionally require `--confirm-destructive`. See `docs/SAFETY_MODEL.md`.
