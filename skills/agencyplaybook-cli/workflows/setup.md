# Setup workflow

## Prerequisites

- An AgencyPlaybook account at https://agencyplaybook.io with `cli_api` or `full` access type
- A Meta (Facebook) account that is a Developer/Admin/Tester on the AgencyPlaybook Meta app (Development Mode requirement; Live Mode users skip this)
- The `apb` binary for your platform

## Install apb

Download the pre-built binary for your platform:

```bash
# From the public CLI repo: https://github.com/affbros/agencyplaybook-cli/tree/main/bin
#   bin/linux-x86_64/apb   bin/macos/apb   bin/windows-x86_64/apb.exe
chmod +x apb
sudo mv apb /usr/local/bin/apb     # optional — put it on $PATH
apb --version
```

The **CLI Reference** page inside the AgencyPlaybook dashboard also links the latest binary.

## Get an API key

1. Log into https://agencyplaybook.io
2. Navigate to **API Keys** in the sidebar (under Developer)
3. Click **Generate New Key** and copy it — you'll only see it once

## Configure credentials

The binary already targets `https://api.agencyplaybook.io`, so you only need to supply your key. The recommended setup is a global config file so the CLI works from any directory:

```bash
mkdir -p ~/.apb
echo 'APB_API_KEY=apb_live_<tier>_<32hex>' > ~/.apb/.env
```

`apb` resolves credentials in order: shell environment → project-local `.env` (cwd) → `~/.apb/.env` → compile-time default. Earlier sources win, so a shell `export APB_API_KEY=...` always overrides the file. Only set `APB_API_URL` if you self-host or develop locally (see "wrong endpoint" below).

## Connect Meta

If your tenant doesn't yet have a Meta OAuth connection:

```bash
apb auth connect-meta
# Opens your browser, completes the OAuth dance, drops you back at the CLI.
# Default is the system-user flow. For solo advertisers without a Business
# Portfolio, use:
#   apb auth connect-meta --long-lived-user
```

## Verify

```bash
apb auth test
# Expected: "✓ Authenticated as <user>, tenant <id>, tier <tier>"
# Exit 0 = success.

apb account list
# Should list your authorized ad accounts.

apb campaign list
# Should list campaigns in your default account.
```

## Set a default account (optional)

```bash
apb account set-default --account act_1234567890
# Persists to ~/.apb/config.json so you don't have to pass --account every time.
```

## Common setup failures

- **`apb` not found** → not on $PATH. Either move it to `/usr/local/bin/apb` or run with the full path.
- **Exit 3 on `apb auth test`** → bad/expired API key (auth). Generate a fresh one.
- **Exit 2 on every call** → wrong endpoint. The hosted default is `https://api.agencyplaybook.io`; unset any stale `APB_API_URL`. For local dev, point at Express on `:3750` (not the Rust API on `:3010`).
- **403 insufficient_scope** → your tier doesn't include this command. See `reference/scopes.md` for which tier you need.
- **"App not active" from Meta** → you're not a registered Tester on the dev-mode Meta app. Ask your AgencyPlaybook admin to add you as a Tester.
