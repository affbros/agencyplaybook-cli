# `apb experiment` — Command Reference

4 commands. Auto-generated from the apb binary on 2026-09-10.

### `apb experiment create`

Create a campaign-level A/B experiment from a base campaign. Resolves the base campaign's first ad set/ad as the control variant, splits traffic by `--traffic-split` (treatment %), and — when `--treatment-plan` is given — applies that plan's actions to the treatment arm once it exists (wraps `split-test create`)

**Scope:** `admin:split-test` · **Min tier:** enterprise · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--base-campaign-id` | `<BASE_CAMPAIGN_ID>` |  |
| `--traffic-split` | `<TRAFFIC_SPLIT>` | Treatment arm's traffic share, 1..99 (control gets the rest) [default: 50] |
| `--treatment-plan` | `<TREATMENT_PLAN>` | A plan-envelope-v2 JSON file whose `actions[]` are applied to the treatment campaign after creation (`experiments/-1` temp ref) |
| `--hypothesis` | `<HYPOTHESIS>` |  |
| `--duration-days` | `<DURATION_DAYS>` | [default: 14] |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb experiment create --execute --base-campaign-id <BASE_CAMPAIGN_ID> --traffic-split <TRAFFIC_SPLIT>
```

### `apb experiment end`

End the experiment without promoting either arm — an envelope action when `--plan` is given, executable via `plan apply --from-file`

**Scope:** `admin:split-test` · **Min tier:** enterprise

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb experiment end --id <ID> --plan <PATH>
```

### `apb experiment promote`

Promote the experiment's treatment arm — an envelope action when `--plan` is given, executable via `plan apply --from-file`

**Scope:** `admin:split-test` · **Min tier:** enterprise · **Write op** (requires `--execute`)

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb experiment promote --execute --id <ID> --plan <PATH>
```

### `apb experiment results`

Verdict: control vs. treatment lift, CI, p-value, and WINNER|LOSER|INCONCLUSIVE(+days_needed) per `metric_policy.experiment.{p_value,min_runtime_days}`

**Scope:** `admin:split-test` · **Min tier:** enterprise

| Flag | Value | Description |
|---|---|---|
| `--id` | `<ID>` |  |
| `--metric` | `<METRIC>` | [default: conversions] |
| `--confidence` | `<CONFIDENCE>` | [default: 0.95] |
| `--json` |  | Output as JSON |
| `--execute` |  | Apply changes (opposite of dry-run) |
| `--dry-run` |  | Preview only, do not mutate |
| `--plan` | `<PATH>` | Plan it, don't do it: run the full dry-run pipeline and write `<path>.md` (human plan document) + `<path>.json` (re-playable machine plan). No API mutation is performed. Cannot be combined with `--execute`. plan-first-cli-001 S3 |
| `--fonts` | `<MODE>` | How a rendered HTML review page sources its fonts: `system` (default — system stacks, zero external URLs, opens offline) or `web` (adds the Google Fonts link for nicer online viewing). Applies to `--plan out.html`, `plan export --format html`, and `recipe build`. campaign-build-001 § 3.1 rule 2 [default: system] |
| `--confirm-destructive` |  | Required for destructive operations (DELETE, ARCHIVE, extreme budget changes) |
| `--account` | `<ACCOUNT>` | Target a specific ad account (overrides default/discovered account) |
| `--no-input` |  | Never prompt for input. Required for CI/CD, cron, and AI-agent execution. Mutations still require their existing safety flags (--execute / --confirm-destructive) |
| `--debug` |  | Enable debug-level tracing to stderr. Honors RUST_LOG if already set. Token / OAuth-secret content is sanitized before logging |
| `--no-color` |  | Disable ANSI color in CLI output. Also honors NO_COLOR=1 / CLICOLOR=0 |
| `--ignore-cooldown` |  | Bypass the CLI's filesystem cooldown short-circuit and attempt the call even if the local cooldown file says the account is on a post-429 cooldown window. Sprint 003 — meta-429-mitigation-001 |
| `--allow-domain` | `<HOST>` | Waive the guardrail for a specific final-URL host (repeatable). Requires `--guardrail-reason` |
| `--allow-brand` |  | Waive the guardrail's canonical-brand / blocked-term copy checks. Requires `--guardrail-reason` |
| `--allow-budget` |  | Waive the guardrail's daily-budget cap / currency check. Requires `--guardrail-reason` |
| `--guardrail-reason` | `<TEXT>` | Justification recorded in the audit log when any `--allow-*` override is used. Required whenever an override waives a guardrail violation |
| `--guardrails` | `<MODE>` | Override the guardrail enforcement mode for this command only (`on`/`block`, `warn`, or `off`). Highest precedence over ENV and the stored `~/.apb/guardrails.json` profile |

```bash
apb experiment results --id <ID> --metric <METRIC>
```
