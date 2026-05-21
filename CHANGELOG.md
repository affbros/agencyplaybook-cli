# Changelog

All notable changes to the `apb` CLI binary distribution.

Format inspired by [Keep a Changelog](https://keepachangelog.com/). This file is mirrored to the public repo `affbros/agencyplaybook-cli` on every release tag.

## [Unreleased]

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
