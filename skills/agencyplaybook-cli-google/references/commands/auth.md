# `apb-gads auth`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Authentication checks against the configured OAuth credentials.

**Surface:** 👁️ Read-only · **6 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`test`](#apb-gads-auth-test) |  |
| [`accessible-customers`](#apb-gads-auth-accessible-customers) |  |
| [`refresh-token-help`](#apb-gads-auth-refresh-token-help) |  |
| [`login`](#apb-gads-auth-login) | Validate an AgencyPlaybook API key and save it to the shared `~/.apb/.env` (one login serves both `apb` and `apb-gads`) |
| [`status`](#apb-gads-auth-status) | Show the Google Ads connection status for the current API key |
| [`connect-google`](#apb-gads-auth-connect-google) | Connect Google Ads via the OAuth device flow (opens your browser, then polls) |

---

<a id="apb-gads-auth-test"></a>
### `apb-gads auth test`

**Usage**

```
Usage: apb-gads auth test [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-auth-accessible-customers"></a>
### `apb-gads auth accessible-customers`

**Usage**

```
Usage: apb-gads auth accessible-customers [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-auth-refresh-token-help"></a>
### `apb-gads auth refresh-token-help`

**Usage**

```
Usage: apb-gads auth refresh-token-help [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-auth-login"></a>
### `apb-gads auth login`

Validate an AgencyPlaybook API key and save it to the shared `~/.apb/.env` (one login serves both `apb` and `apb-gads`)

**Usage**

```
Usage: apb-gads auth login [OPTIONS] --api-key <API_KEY>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--api-key <API_KEY>` | Your AgencyPlaybook API key (apb_...) |
| `--api-url <API_URL>` | Override the AgencyPlaybook API base URL |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-auth-status"></a>
### `apb-gads auth status`

Show the Google Ads connection status for the current API key

**Usage**

```
Usage: apb-gads auth status [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |

<a id="apb-gads-auth-connect-google"></a>
### `apb-gads auth connect-google`

Connect Google Ads via the OAuth device flow (opens your browser, then polls)

**Usage**

```
Usage: apb-gads auth connect-google [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--timeout <TIMEOUT>` | Seconds to wait for browser authorization [default: 300] |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |
