# `apb-gads experiment`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Google Ads experiment reads. READ-ONLY — no three-gate safety applied (creating and ending experiments lives under `mutate experiment-*`). Use `report experiments` to list the account's experiments and this group to read one experiment's outcome

**Surface:** 👁️ Read-only · **1 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`results`](#apb-gads-experiment-results) | Read one experiment's outcome: the control arm's metrics, the treatment arm's metrics, and — per metric — Google's point estimate, margin of error and p-value for the difference between them |

---

<a id="apb-gads-experiment-results"></a>
### `apb-gads experiment results`

Read one experiment's outcome: the control arm's metrics, the treatment arm's metrics, and — per metric — Google's point estimate, margin of error and p-value for the difference between them.

Two read-only GAQL queries: `FROM experiment` (the ONLY resource that carries the experiment-statistics metrics — the same SELECT against `campaign` or `experiment_arm` is rejected with PROHIBITED_METRIC_IN_SELECT_OR_WHERE_CLAUSE) and `FROM experiment_arm` for the arm/campaign/traffic-split layout.

`significant` is `p_value < 0.05`, and is null while Google has not yet computed a p-value — a freshly created experiment reports nulls until it has accumulated traffic. An unknown experiment id is NOT an error: the command returns `found: false` with a note so scripts can branch on the JSON. Costs are MICROS of the account currency — never sum them across accounts.

**Usage**

```
Usage: apb-gads experiment results [OPTIONS] --experiment-id <EXPERIMENT_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--experiment-id <EXPERIMENT_ID>` | Numeric experiment id (see `report experiments`) |
