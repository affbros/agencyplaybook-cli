# Automation, CI/CD & self-hosting

`apb-gads` is built for unattended/agent use: deterministic JSON output, stable exit codes, and a
server-validate mode that proves writes without performing them.

## The JSON contract

- **Every command returns JSON** on stdout. `--pretty` only toggles indentation — the shape is
  identical. Pipe to `jq` for extraction; parse the structured body, never scrape prose.
- `--output <path>` writes the JSON to a file (useful to feed `mutate … --from-file` /
  `plan from-audit --spec-file …`).
- `--save-plan <path>` captures a dry-run mutation as a replayable plan JSON.
- `--lookback-days <N>` overrides a playbook's default window (structural playbooks ignore it; the
  resolved value is echoed back as `lookback_days`).

## Exit codes — branch on these, not on text

| Code | Meaning | Retry? | Typical cause |
|---|---|---|---|
| `0` | success / `pass` verdict | — | normal |
| `1` | runtime / IO / API error | sometimes | network, auth, a Google API error body |
| `2` | usage error | no | bad/missing flags (clap) |
| `3` | validation **`fail`** verdict | no | `validate campaign-spec` / `validate pmax-spec` / `mutate ad-validate` returned `fail` (report still printed) |

```bash
# Halt a launch pipeline on a bad spec (exit 3 short-circuits the &&):
apb-gads validate campaign-spec --from-file build/spec.json \
  && APB_GADS_ALLOW_MUTATIONS=true apb-gads --customer "$CID" --execute \
       orchestrate campaign-launch --from-file build/spec.json

# Explicit branching:
apb-gads --customer "$CID" validate pmax-spec --from-file pmax.json
case $? in
  0) echo "spec ok" ;;
  3) echo "spec rejected — read the printed report"; exit 1 ;;
  *) echo "tool/runtime error"; exit 1 ;;
esac
```

## Proving a write without performing it (SERVER_VALIDATED)

```bash
# Google validates schema + policy + auth for the FULL body; creates nothing:
APB_GADS_ALLOW_MUTATIONS=true apb-gads --customer "$CID" \
  --execute --validate-only mutate campaign-budget-update \
  --budget-resource-name "customers/$CID/campaignBudgets/<BID>" --amount-micros 50000000
```

Use this in CI to catch a malformed payload before it ever touches a real account. See
`safety-model.md` for the full gate model and `capability-matrix.md` for the verification doctrine.

## Scheduling read-only audits

```bash
apb-gads schedule add --id weekly-health --cron "0 9 * * 1" \
  --job-customer "$CID" -- playbook account-health
apb-gads schedule install --apply          # merge the managed crontab section
```

`schedule` is **read-only by construction** — it rejects `--execute`, `mutate`, `sandbox`,
write-capable `orchestrate`, and `audit replay` at registration time. Per-run JSON output is
appended to `{config_dir}/schedule-runs/<id>.jsonl`.

## Extracting values with jq

```bash
apb-gads --customer "$CID" playbook account-health | jq '.health_score, .recommendations[]'
apb-gads --customer "$CID" report campaign-performance-365d --limit 10 \
  | jq -r '.campaigns[] | [.name, .cost_usd, .roas] | @tsv'
```

## Self-hosting / BYO token (developers)

The default path is the SaaS broker (`APB_API_KEY` → the dashboard connection). To run your **own**
Google Ads developer token instead (local dev / self-host):

1. Copy the template: `cp google-ads.example.yaml google-ads.yaml` (the real file is gitignored).
2. Fill in `developer_token`, `client_id`, `client_secret`, `refresh_token`, `login_customer_id`.
3. Point the CLI at it with `--config google-ads.yaml` (the default) and set
   `safety.allow_writes`/`read_only`/`require_mutation_env` to taste (see `safety-model.md`).

`APB_API_URL` overrides the API base for SaaS mode against a non-default endpoint. In SaaS mode you
do **not** manage a yaml — the broker supplies the token.

## Gotchas worth scripting around

- **Customer ids are plain numeric, no dashes.** `login_customer_id` (MCC) must be a parent of the
  `--customer` operating account with ≥ read access, or you get a permission error.
- **GAQL**: date literals are **quoted strings** in `BETWEEN '<start>' AND '<end>'`;
  `DURING LAST_30_DAYS` isn't accepted by every resource view; you can't `SELECT` segments without
  a metric, nor metrics without a resource field.
- **Empty playbook results** usually mean no activity in the default window — retry with
  `--lookback-days 365`.
- **v24 is pinned** — don't assume newer fields exist; the CLI rejects out-of-range inputs pre-API.
