# Changelog

All notable changes to the `apb` CLI binary distribution. Format inspired by [Keep a Changelog](https://keepachangelog.com/).

## [0.1.4] — 2026-05-19

### Fixed
- **Linux binary now runs on Debian 12 / Ubuntu 22.04 / RHEL 9.** v0.1.3 was built on Ubuntu 24.04 and required glibc 2.39, which broke on older distros. Build pinned to `ubuntu-22.04` (glibc 2.35). README compat note corrected.

## [0.1.3] — 2026-05-19

### Added
- Global config file support at `~/.apb/.env`. Set `APB_API_KEY` and `APB_API_URL` once and the CLI works from any directory — no need for a `.env` in every project folder. CWD `.env` still wins over the global one for per-project overrides. README install section rewritten with copy-paste setup blocks for Linux/macOS and Windows PowerShell.

### Changed
- README clarifies the credential precedence chain: shell env → CWD `.env` → `~/.apb/.env` → compile-time defaults.

## [0.1.2] — 2026-05-19

Restores the Windows binary that was erroneously dropped in v0.1.1. Three platforms ship from this version onward.

### Added
- `bin/windows-x86_64/apb.exe` — Windows 10 1809+ / Windows 11 native binary (MSVC runtime, statically linked). Built on `windows-latest` GHA runner with the same `APB_DEFAULT_API_URL=https://api.agencyplaybook.io` bake-in as Linux + macOS.
- README install section + PowerShell one-liner for Windows.

### Changed
- README: Windows back as a primary install target; WSL2 demoted to an "alternative" section for users who prefer Linux tooling.

## [0.1.1] — 2026-05-19

**Breaking layout change**: distribution simplified to two platforms.

### Changed
- macOS distribution is now a single **universal binary** at `bin/macos/apb`. Replaces the prior `bin/macos-x86_64/` and `bin/macos-aarch64/` split. Built on macos-14 via `lipo -create` merging both arch slices; runs natively on Intel and Apple Silicon Macs without Rosetta.

### Removed
- `bin/windows-x86_64/` — Windows users should install WSL2 and run the Linux binary inside Ubuntu. Same approach Claude Code used through 2025. Documented in README.

### Added
- macOS universal binary now built natively by CI (was a placeholder in v0.1.0).
- Refreshed Linux x86_64 binary built by CI for consistency.

### Notes
- All binaries built with `APB_DEFAULT_API_URL=https://api.agencyplaybook.io` baked in.
- Both binaries verified to contain no runner host paths.

## [0.1.0] — 2026-05-19

Initial public release.

### Added
- Pre-built `apb` binary for Linux x86_64 (glibc 2.31+). macOS Intel, macOS Apple Silicon, and Windows x86_64 binaries arrive on the first CI tag build.
- Full CLI surface: 226 commands across 30 domains (campaigns, adsets, ads, creatives, audiences, pixels, custom conversions, lead-gen forms, 24 diagnostic playbooks, plan execution, dataset operations, reports, rules, split tests, sync, automation).
- Documentation: CLI reference, usage guide, safety model, API reference, automation patterns, campaign-composer guide, Meta API field reference.
- Example JSON specs: compose, carousel, lead-gen form, creative collection.
- MIT license.

### Notes
- Binary defaults `APB_API_URL` to `https://api.agencyplaybook.io` (the production API endpoint — currently in private beta). Override via the `APB_API_URL` env var for self-hosted endpoints.
- All mutating commands require `--execute` (dry-run is default). Destructive ops additionally require `--confirm-destructive`. See `docs/SAFETY_MODEL.md`.
