# `apb-gads schedule`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Sprint G — schedule read-only playbooks / orchestrators via the system crontab. Emit-cron-lines model: this command group manages a JSON state file and renders a managed crontab section; the OS fires each line. Scheduled jobs are read-only by construction

**Surface:** 👁️ Read-only · **7 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`list`](#apb-gads-schedule-list) | List all registered jobs |
| [`add`](#apb-gads-schedule-add) | Register a new job. |
| [`remove`](#apb-gads-schedule-remove) | Remove a job from the store |
| [`show`](#apb-gads-schedule-show) | Show one job in full |
| [`install`](#apb-gads-schedule-install) | Render the managed crontab section. |
| [`uninstall`](#apb-gads-schedule-uninstall) | Remove the managed section from the user's crontab |
| [`run`](#apb-gads-schedule-run) | Run a job now (shells out to the same apb-gads binary with the stored args). |

---

<a id="apb-gads-schedule-list"></a>
### `apb-gads schedule list`

List all registered jobs

**Usage**

```
Usage: apb-gads schedule list [OPTIONS]
```

_No command-specific options — uses only the [global options](README.md#global-options)._

<a id="apb-gads-schedule-add"></a>
### `apb-gads schedule add`

Register a new job. The invocation that follows `--` must be a read-only apb-gads command — mutations cannot be scheduled.

Example: apb-gads schedule add --id monthly-review --cron "0 9 1 * *" \ --customer 1234567890 -- orchestrate monthly-review

**Usage**

```
Usage: apb-gads schedule add [OPTIONS] --id <ID> --cron <CRON> [COMMAND]...
```

**Arguments**

| Argument | Description |
|---|---|
| `[COMMAND]...` | Trailing invocation tokens. Pass everything apb-gads would see after the global flags, separated by `--` |

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--id <ID>` | Unique operator-chosen id. Used as the filename for captured output and as the trailing crontab marker |
| `--cron <CRON>` | 5-field cron expression or `@hourly` / `@daily` / `@weekly` / `@monthly` / `@yearly` shortcut |
| `--job-customer <JOB_CUSTOMER>` | Per-job customer override. Falls back to `default_customer_id` from the config if omitted |
| `--notes <NOTES>` | Free-form description |

<a id="apb-gads-schedule-remove"></a>
### `apb-gads schedule remove`

Remove a job from the store

**Usage**

```
Usage: apb-gads schedule remove [OPTIONS] --id <ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--id <ID>` | — |

<a id="apb-gads-schedule-show"></a>
### `apb-gads schedule show`

Show one job in full

**Usage**

```
Usage: apb-gads schedule show [OPTIONS] --id <ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--id <ID>` | — |

<a id="apb-gads-schedule-install"></a>
### `apb-gads schedule install`

Render the managed crontab section. Default is dry-run (prints the section + the ready-to-pipe shell command). `--apply` merges it into the user's crontab via `crontab -l | … | crontab -`

**Usage**

```
Usage: apb-gads schedule install [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--apply` | Actually merge the managed section into the user's crontab. |
| `--binary <BINARY>` | Override the apb-gads binary path in emitted cron lines. |

<a id="apb-gads-schedule-uninstall"></a>
### `apb-gads schedule uninstall`

Remove the managed section from the user's crontab

**Usage**

```
Usage: apb-gads schedule uninstall [OPTIONS]
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--apply` | — |

<a id="apb-gads-schedule-run"></a>
### `apb-gads schedule run`

Run a job now (shells out to the same apb-gads binary with the stored args). Handy for a manual smoke test before installing

**Usage**

```
Usage: apb-gads schedule run [OPTIONS] --id <ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--id <ID>` | — |
