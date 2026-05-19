# apb — AgencyPlaybook CLI

The `apb` command-line tool drives Meta (Facebook/Instagram) ad campaigns through the AgencyPlaybook.io API. It ships with 226 commands across 30 domains — campaign creation, ad serving, audiences, pixels, custom conversions, lead-gen forms, 24 diagnostic playbooks, plan execution, dataset operations, and more.

> **Private beta**: `https://api.agencyplaybook.io` is in private beta and not yet generally available. To get early access or test against your own self-hosted API, set `APB_API_URL` to your endpoint.

## Install

Download the binary for your platform from `bin/<platform>/apb` in this repo:

| Platform | Path | Notes |
|---|---|---|
| Linux x86_64 | `bin/linux-x86_64/apb` | glibc 2.35+ (Ubuntu 22.04+, Debian 12+, RHEL 9+, Fedora 36+) |
| macOS | `bin/macos/apb` | macOS 11+. Universal binary — runs natively on both Intel and Apple Silicon. |
| Windows x86_64 | `bin/windows-x86_64/apb.exe` | Windows 10 1809+ / Windows 11. MSVC runtime statically linked. |

### Quick install (Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/affbros/agencyplaybook-cli/main/bin/linux-x86_64/apb -o /usr/local/bin/apb
chmod +x /usr/local/bin/apb
sha256sum /usr/local/bin/apb  # compare to bin/linux-x86_64/sha256.txt
apb --version
```

### Quick install (macOS)

```bash
curl -fsSL https://raw.githubusercontent.com/affbros/agencyplaybook-cli/main/bin/macos/apb -o /usr/local/bin/apb
chmod +x /usr/local/bin/apb
xattr -d com.apple.quarantine /usr/local/bin/apb 2>/dev/null  # bypass Gatekeeper for downloaded binary
shasum -a 256 /usr/local/bin/apb  # compare to bin/macos/sha256.txt
apb --version
```

### Quick install (Windows PowerShell)

```powershell
# Drop into a directory on your PATH, e.g. ~/bin
$dest = "$env:USERPROFILE\bin\apb.exe"
New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/affbros/agencyplaybook-cli/main/bin/windows-x86_64/apb.exe" -OutFile $dest
Get-FileHash -Algorithm SHA256 $dest  # compare to bin/windows-x86_64/sha256.txt
apb --version
```

If `~/bin` isn't on your PATH yet, add it via *System Properties → Environment Variables → User Variables → Path*.

### Alternative: WSL2 + Linux binary

If you prefer Linux tooling on Windows, install WSL2 (`wsl --install -d Ubuntu`) and run the Linux quick-install block inside Ubuntu. The Linux binary works identically.

## First-time setup

The `apb` CLI looks for your API credentials in this order:

1. Shell environment (`export APB_API_KEY=...`)
2. `.env` file in your current working directory
3. `~/.apb/.env` (global, recommended for the downloaded binary)
4. Compile-time defaults (only `APB_API_URL` defaults to `https://api.agencyplaybook.io`)

The simplest setup uses a global config file so the CLI works from any directory:

```bash
# Linux / macOS — one-time
mkdir -p ~/.apb && chmod 700 ~/.apb
cat > ~/.apb/.env <<'EOF'
APB_API_KEY=apb_live_pro_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
APB_API_URL=https://api.agencyplaybook.io
EOF
chmod 600 ~/.apb/.env

# Verify
apb auth status
apb account list
```

```powershell
# Windows PowerShell — one-time
$apbDir = "$env:USERPROFILE\.apb"
New-Item -ItemType Directory -Force -Path $apbDir | Out-Null
@"
APB_API_KEY=apb_live_pro_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
APB_API_URL=https://api.agencyplaybook.io
"@ | Out-File -Encoding ASCII "$apbDir\.env"

apb auth status
apb account list
```

**Per-project override**: drop a `.env` file in any project's root directory and the values there take precedence over `~/.apb/.env` for invocations from that directory. Useful for switching between accounts or pointing at a self-hosted API.

**Get an API key**: AgencyPlaybook.io is in private beta. Until public signup opens, contact `hi@agencyplaybook.io` for early access, or override `APB_API_URL` to point at your own self-hosted API endpoint.

**Update the CLI**: when a new release ships, re-download the binary from `bin/<platform>/` in this repo. The config file at `~/.apb/.env` carries over — only the binary itself changes.

## Common commands

```bash
apb campaign list                                 # list campaigns
apb campaign list --account act_1234567890        # specific ad account
apb playbook health-score --days 30               # run the health-score diagnostic
apb playbook fatigue-detector --days 7
apb report insights --level campaign --since 30d  # cross-account insights
apb adset update-budget --id 123 --new-daily-budget-usd 50 --execute  # write op (gate-protected)
apb plan list                                     # see saved mutation plans
```

Every mutating command requires `--execute` to actually run; without it you get a dry-run preview. See `docs/SAFETY_MODEL.md` for the full write-gate model.

## Documentation

- [`docs/GETTING_STARTED.md`](docs/GETTING_STARTED.md) — onboarding walkthrough
- [`docs/CLI_REFERENCE.md`](docs/CLI_REFERENCE.md) — full command reference (226 commands × 30 domains)
- [`docs/USAGE_GUIDE.md`](docs/USAGE_GUIDE.md) — practical workflows + examples
- [`docs/SAFETY_MODEL.md`](docs/SAFETY_MODEL.md) — write gates, dry-run, destructive-confirm
- [`docs/CLI_AUTOMATION.md`](docs/CLI_AUTOMATION.md) — CI/CD + AI-agent integration patterns
- [`docs/API_REFERENCE.md`](docs/API_REFERENCE.md) — the underlying HTTP API (227 endpoints) you can hit directly with `curl`
- [`docs/CAMPAIGN_COMPOSER_AND_AUTOPLAN.md`](docs/CAMPAIGN_COMPOSER_AND_AUTOPLAN.md) — full-stack campaign creation pipeline
- [`docs/META_API_FIELDS.md`](docs/META_API_FIELDS.md) — Meta Marketing API field reference
- [`docs/examples/`](docs/examples/) — JSON spec templates (compose, carousel, leadgen, etc.)

## Claude integration

The `apb` CLI is designed to pair with [Claude Code](https://claude.com/claude-code) — see `CLAUDE.md` for guidance on driving it from Claude.

## License

MIT — see [LICENSE](LICENSE).

## Source

This repo ships pre-built binaries + docs only. Source lives in a private repo. Open issues here for binary bugs or doc fixes; feature requests should go through the agencyplaybook.io support channel.
