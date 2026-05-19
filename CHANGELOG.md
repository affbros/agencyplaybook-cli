# Changelog

All notable changes to the `apb` CLI binary distribution. Format inspired by [Keep a Changelog](https://keepachangelog.com/).

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
