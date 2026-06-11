# `apb-gads changes`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Artifact pipeline — turn a scored ActionPlan (from `plan from-audit`) into a reviewable Changeset and apply it through the guarded plan path. `from-plan` and dry-run `apply` are read/transform only; `apply --execute` is the single write, and it reuses `mutate apply-plan`'s guards. Honors the global `--validate-only` flag

**Surface:** ✍️ **Write-capable** · **3 command(s)** · [← back to index](README.md)

> ⚠️ Commands here can write to a Google Ads account. Every write is **dry-run by default** and must clear the three independent gates (`--execute` + config + env) plus a per-customer profile or the test sandbox policy. See [`../mutations.md`](../mutations.md).

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`from-plan`](#apb-gads-changes-from-plan) | Convert a scored ActionPlan JSON into a Changeset of raw v24 mutate ops. |
| [`apply`](#apb-gads-changes-apply) | Apply a Changeset. |
| [`rollback`](#apb-gads-changes-rollback) | Generate + apply the inverse of a previously-applied changeset, looked up by audit-log id (reuses `mutate inverse-plan`). |

---

<a id="apb-gads-changes-from-plan"></a>
### `apb-gads changes from-plan`

Convert a scored ActionPlan JSON into a Changeset of raw v24 mutate ops. Pure transform — no write. Only auto-applicable actions are staged unless `--include-review` is set

**Usage**

```
Usage: apb-gads changes from-plan [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to the ActionPlan JSON (from `plan from-audit`) |
| `--include-review` | Also stage actions flagged requires_human_review (default: skip, recording them in the changeset's `skipped[]`) |

<a id="apb-gads-changes-apply"></a>
### `apb-gads changes apply`

Apply a Changeset. Dry-run by default; `--execute` submits. Routes the only write through `apply_plan` (mutation_guard + safety_profile_guard)

**Usage**

```
Usage: apb-gads changes apply [OPTIONS] --from-file <FROM_FILE>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--from-file <FROM_FILE>` | Path to the Changeset JSON (from `changes from-plan`) |

<a id="apb-gads-changes-rollback"></a>
### `apb-gads changes rollback`

Generate + apply the inverse of a previously-applied changeset, looked up by audit-log id (reuses `mutate inverse-plan`). Dry-run by default

**Usage**

```
Usage: apb-gads changes rollback [OPTIONS] --audit-id <AUDIT_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--audit-id <AUDIT_ID>` | — |
