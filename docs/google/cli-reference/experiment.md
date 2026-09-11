# `apb-gads experiment`

> ⚙️ **Auto-generated** from `apb-gads --help` by [`scripts/gen_cli_docs.py`](../../scripts/gen_cli_docs.py). **Do not edit by hand** — re-run the generator after any CLI change (`python3 scripts/gen_cli_docs.py`). Drift is caught by `--check`. See AGENTS.md § *CLI documentation*.

Google Ads experiment loop: `results` (read-only) and `promote` (creating/ending an experiment lives under `mutate experiment-*`; `promote` lives here for skill-vocabulary parity with Meta's `experiment create|results|promote`, planning-001 sprint-g09). `promote` is a real write and goes through the same three-gate safety model as any `mutate` command — dry-run by default, `--execute` required to graduate the treatment for real

**Surface:** 👁️ Read-only · **2 command(s)** · [← back to index](README.md)

---

## Subcommands

| Subcommand | Summary |
|---|---|
| [`results`](#apb-gads-experiment-results) | Read one experiment's outcome: the control arm's metrics, the treatment arm's metrics, and — per metric — Google's point estimate, margin of error and p-value for the difference between them, plus a WINNER/LOSER/INCONCLUSIVE verdict on the chosen `--metric` (planning-001 sprint-g09) using `metric_policy.experiment.{p_value, min_runtime_days}` |
| [`promote`](#apb-gads-experiment-promote) | Graduate an experiment's treatment into the live production change (the `GraduateExperiment` RPC — a dedicated endpoint, not a `googleAds:mutate` operation, so it cannot be batched with other writes). |

---

<a id="apb-gads-experiment-results"></a>
### `apb-gads experiment results`

Read one experiment's outcome: the control arm's metrics, the treatment arm's metrics, and — per metric — Google's point estimate, margin of error and p-value for the difference between them, plus a WINNER/LOSER/INCONCLUSIVE verdict on the chosen `--metric` (planning-001 sprint-g09) using `metric_policy.experiment.{p_value, min_runtime_days}`.

Two read-only GAQL queries: `FROM experiment` (the ONLY resource that carries the experiment-statistics metrics — the same SELECT against `campaign` or `experiment_arm` is rejected with PROHIBITED_METRIC_IN_SELECT_OR_WHERE_CLAUSE) and `FROM experiment_arm` for the arm/campaign/traffic-split layout.

`significant` is `p_value < --confidence`'s complement (default 0.05), and is null while Google has not yet computed a p-value — a freshly created experiment reports nulls until it has accumulated traffic. An unknown experiment id is NOT an error: the command returns `found: false` with a note so scripts can branch on the JSON. Costs are MICROS of the account currency — never sum them across accounts.

**Usage**

```
Usage: apb-gads experiment results [OPTIONS] --experiment-id <EXPERIMENT_ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--experiment-id <EXPERIMENT_ID>` | Numeric experiment id (see `report experiments`) |
| `--metric <METRIC>` | Which metric's verdict to compute: conversions \| cost_per_conversion \| conversion_value_per_cost (any EXPERIMENT_STAT_METRICS label is accepted; the full per-metric table is always returned in `statistics`) |
| `--confidence <CONFIDENCE>` | Confidence level for the verdict (0 < c < 1); alpha = 1 - confidence. Defaults to metric_policy.experiment.p_value, else 0.05 (95% confidence). Passing this flag overrides both for this invocation only. |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. |

<a id="apb-gads-experiment-promote"></a>
### `apb-gads experiment promote`

Graduate an experiment's treatment into the live production change (the `GraduateExperiment` RPC — a dedicated endpoint, not a `googleAds:mutate` operation, so it cannot be batched with other writes). Dry-run by default like any mutate command; `--execute` to graduate for real. `--plan <path>` (the global flag) emits this as a one-action `experiment-promote` envelope instead of executing, so it can be reviewed/approved and later run through `mutate apply-plan --execute`

**Usage**

```
Usage: apb-gads experiment promote [OPTIONS] --id <ID>
```

**Options** (command-specific; the [global options](README.md#global-options) also apply)

| Option | Description |
|---|---|
| `--id <ID>` | Numeric experiment id (see `report experiments`) |
| `--no-color` | Disable ANSI color in any output this invocation writes (equivalent to NO_COLOR=1). No-op when output is JSON — apb-gads never colors JSON — but every human-readable surface (eprintln progress lines, a future colorized renderer) checks this instead of assuming a TTY, so scripts and CI can pass it unconditionally (sprint-g05c, CONTRACTS.md § 10.4). |
| `--debug` | Print extra operator-facing progress lines to stderr (JSON stdout output is unaffected). Currently used by `plan forecast`'s scenario runner to show inter-call pacing (1 QPS/CID). |
| `--fonts <FONTS>` | system (default) \| web — font source for any .html plan output this invocation writes (--plan <path>.html, `recipe build`'s plan.html). `web` adds a Google Fonts <link>; `system` stays fully offline-safe. [default: system] |
