# `recipe build` — a whole campaign, from a brief

> Generated command reference: [`cli-reference/recipe.md`](cli-reference/recipe.md)

`recipe build` takes the thing a PPC expert would hand a junior — a **brief** — and
runs the whole build: keyword research, structure, ad copy, targeting, negatives,
assets, bidding, validation, and a reviewable **plan**. It writes a build
directory, prints a one-screen summary, and launches **nothing** unless you ask.

```bash
apb-gads --customer 1234567890 recipe build --brief briefs/whole-bean.yaml --out build/
```

It **composes** primitives that already ship — `plan keywords`, `plan structure`,
`plan rsa`, `validate campaign-spec`, `mutate ad-validate`, `orchestrate
campaign-launch` — and introduces **zero new API calls**. `--execute` is the
existing launch, through the existing gates, producing the existing receipt.

> **Expert copy + brief:** install the **`agencyplaybook-planner`** skill —
> <https://agencyplaybook.io/downloads>. There is no LLM inside the binary;
> `copy.provider: agent` means the copy *arrives in the brief*.

---

## The eight stages

```
research → structure → copy → targeting → assets → bidding → validate → plan
```

Any of them can be the stop point:

```bash
apb-gads recipe build --brief b.yaml --stage research   # just the keyword pack
apb-gads recipe build --brief b.yaml --stage validate   # spec + verdict, no plan
```

| Stage | What it does | Composes |
|---|---|---|
| `research` | Keyword ideas from the brief's seeds/URL → cluster → intent → seed negatives. Writes `research/{keywords,negatives,clusters}.json` with **every candidate and its decision**. | `plan keywords` |
| `structure` | Clusters → ad groups. Applies `structure.max_ad_groups` (highest real volume first), `research.exclude_intents`, the competitor-brand policy from `context.brand.competitors[]`, and the match-type policy. Writes `structure.json`. | `plan structure` |
| `copy` | `heuristic` (default) generates **starter copy**; `agent` distributes the brief's copy. Writes `rsa.json`. | `plan rsa` |
| `targeting` | Geo include/exclude/type, languages, ad schedule, device modifiers, audiences, demographic exclusions, shared negative sets, brand exclusion. | spec v2 blocks |
| `assets` | Sitelinks, callouts, structured snippets, call, price/promotion, pre-uploaded images, plus tracking template / final-URL suffix / custom params. | spec v2 blocks |
| `bidding` | Strategy from `goals.mode`, portfolio attach, conversion goals (resolved **by name**), new-customer acquisition, network/rotation/URL-expansion settings. | spec v2 blocks |
| `validate` | `validate campaign-spec` + per-ad-group RSA validation + the RSA quality lint. Writes `validate.json`. **Exit 3** when it fails. | `validate campaign-spec`, `ad-validate`, `rsa_quality` |
| `plan` | Launch dry-run → **one plan-envelope-v2 document**. Writes `plan.json`, `plan.md`, `plan.html`. | `orchestrate campaign-launch`, `envelope_out` |

## The build directory

| File | What it is |
|---|---|
| `spec.v2.json` | The machine build. Hand-editable; re-run it with `--spec`. |
| `plan.json` | The plan-envelope-v2 document — the deployable unit (`mutate apply-plan`, the SaaS import, the web Plans page). |
| `plan.md` | The human review document. |
| `plan.html` | The self-contained review page (no CDN, no JS required, light/dark). |
| `research/keywords.json` | Every candidate: volume, competition, suggested bid, intent, cluster, **final match types**, kept/dropped **and why**. |
| `research/negatives.json` | Research seeds + brief campaign negatives + excluded terms + competitor brands + requested shared sets. |
| `research/clusters.json` | The raw clusters plus what curation removed. |
| `structure.json` / `rsa.json` | The intermediate artifacts, so a stage can be inspected on its own. |
| `validate.json` | Spec + ad + copy-lint verdicts (and Google's own verdict under `--validate-only`). |
| `launch.json` | The launch receipt — **only** with `--execute`. Feed it to `orchestrate rollback --from-receipt`. |
| `editor/*.csv` | The Google Ads Editor CSV bundle — one file per entity type the plan actually created (`campaigns.csv`, `ad-groups.csv`, `keywords.csv`, `rsas.csv`, plus `negatives.csv` / `negatives-shared.csv` / `sitelinks.csv` / etc. when the plan carries them). Sprint-g05. |

`--format` narrows it: `spec` (spec + research), `plan` (plan.json), `review`
(plan.md), `html` (plan.html), `editor-csv` (**only** `editor/*.csv`), `all`
(default — everything, `editor/` included). An entity type with zero matching
actions produces no file — never a header-only CSV (CONTRACTS.md §10.6 B9 /
§10.7).

```bash
# Just the Editor bundle, nothing else:
apb-gads recipe build --brief b.yaml --format editor-csv --out build/

# Re-export the Editor bundle from an already-written plan.json (read-only,
# no customer id, no network — what the SaaS editor.zip route shells to):
apb-gads plan export --from-file build/plan.json --format editor-csv --out build/
```

`--fonts system|web` controls `plan.html`'s font source (`system`, the
default, stays fully offline-safe; `web` adds a Google Fonts `<link>`).

`--out` defaults to `./build-<YYYYmmdd-HHMM>/`.

## The brief

Full schema and comments: the `agencyplaybook-planner` skill's `references/brief-template.yaml`.

```yaml
customer_id: "1234567890"
type: search                       # search | pmax | demand-gen
campaign_name: "Test-ok-to-delete Whole Bean — US"
business:
  brand: "Example Roasters"
  landing_page: https://www.example.com/whole-bean
goals:
  mode: target_cpa                 # target_cpa | target_roas | maximize_conversions |
  target_cpa: 18.00                #   maximize_conversion_value | manual_cpc
  daily_budget: 75.00
  conversion_actions: ["Purchase"] # BY NAME → resolved, ambiguity fails loud
research:
  seed_keywords: ["whole bean coffee", "single origin coffee"]
  exclude_intents: [jobs, wholesale]
  match_type_policy: { default: PHRASE, exact_for_top_n: 15, broad: false }
structure:
  max_ad_groups: 8
targeting:
  geo: { include: ["US"], exclude: ["Alaska"], type: PRESENCE }
  languages: ["en"]
  schedule: { days: [MON,TUE,WED,THU,FRI], hours: "06-22" }
  devices: { mobile: +10, tablet: -100 }        # −100 % = excluded
negatives:
  shared_sets: ["Global brand-safety negatives"]  # BY NAME
  campaign_level: ["free", "k-cup"]
  brand_exclusion: true
assets:
  sitelinks: [{ text: "Subscriptions", url: https://www.example.com/subscribe }]
  callouts: ["Roasted to order", "Free shipping over $40"]
copy:
  provider: heuristic              # heuristic | agent
settings:
  networks: { search_partners: false }
safety:
  name_prefix: "Test-ok-to-delete"  # required on the sandbox
  born_paused: true
```

YAML or JSON — both go through the same parser. Unknown keys are **ignored**, so
a brief written for a newer binary still loads.

## What it refuses to do

Every one of these is a deliberate stop, not a limitation:

| Situation | What happens |
|---|---|
| A required field is missing | `brief_invalid: <field> …`, naming the field |
| `copy.provider: agent` with no `copy.headlines` | `brief_invalid: copy.provider=agent needs copy.headlines` — `agent` means the copy *arrives in the brief* |
| A geo/shared-set/conversion-action/audience name matches 0 rows | error listing what the account **does** have |
| …matches more than one row | error listing **every** candidate — "Springfield" is 31 places, and the binary will not pick one |
| `--type` or `--customer` disagrees with the brief | error naming **both** sides |
| `safety.name_prefix` is set but `campaign_name` doesn't contain it | error — the binary never renames your campaign |
| `--type pmax` with a brief block PMAX has no equivalent for | error naming the block — never a silent drop |
| `targeting.demographics.include` | error — Google campaign demographics are exclusion-only |
| `settings.ai_max: true` | error — no mutation surface until the AI Max block ships |
| A failing validate stage | full report on stdout, **exit 3** |

## Determinism, and the `--spec` round trip

The same brief produces the same `spec_hash`; the spec it wrote, fed back with
`--spec`, produces the same `spec_hash` **and** the same envelope
`integrity.hash`. Ranking that feeds the spec (EXACT-top-N, `max_ad_groups`)
breaks ties deterministically, the advisory `_generation` block is stripped
before hashing, and the brief-only facts the envelope needs
(`safety.name_prefix`, the copy provider) round-trip inside it.

```bash
apb-gads recipe build --brief b.yaml --out build/a
# edit build/a/spec.v2.json — 5 ad groups instead of 6
apb-gads recipe build --spec build/a/spec.v2.json --out build/b
```

## Launching

```bash
# 1. server-validate the WHOLE launch body — creates nothing
apb-gads --customer 1234567890 recipe build --brief b.yaml --validate-only

# 2. launch it, born PAUSED, through the three gates
APB_GADS_ALLOW_MUTATIONS=true apb-gads --customer 1234567890 \
    recipe build --brief b.yaml --out build/ --execute

# 3. undo it
apb-gads --customer 1234567890 orchestrate rollback --from-receipt build/launch.json --execute
```

`--execute` and `--validate-only` are mutually exclusive: one creates the
campaign, the other guarantees nothing is created, and a flag combination that
is ambiguous about which gets refused rather than guessed.

The other two deploy paths take the **same** `plan.json`: `mutate apply-plan`
locally, or an import into AgencyPlaybook for approval in the web app.

### What the plan contains

`plan.json` lists **every** mutation the launch performs — the plan and the
launch are generated from one step table, so they cannot disagree
(CONTRACTS.md §10.4 I4):

| Group | Actions |
|---|---|
| `g1` — the head mutate | `campaign-budget-create`, `campaign-create`, `campaign-geo-add` × positive geos, `campaign-language-add` × languages, `campaign-negative-keyword-add` × campaign-level negatives, `campaign-update-bidding-strategy` (when the brief's `goals.mode` sets one) |
| `g2`, `g3`, … — one per ad group | `ad-group-create`, `ad-create`, `keyword-add-bulk` (the ad group's keywords as one batch), `negative-keyword-add` × ad-group negatives |
| the v2 sequential tail, attached to `g1` | extra RSAs, geo exclusions + `campaign-update-geo-target-type` + location bid modifiers, proximity, ad schedules, device modifiers, audiences, demographic exclusions, shared negative sets + attaches, brand exclusion, assets + attaches, tracking, `campaign-update-network-settings` / rotation / URL expansion, conversion goals, customer acquisition, portfolio bidding |

Every action carries an `atomic_group`, so nothing in the document is work
nobody submits. A tail action whose body can only be built against the real
campaign id is listed with a summary and no `preview` — it is still part of the
plan.

`mutate apply-plan --execute` re-derives that action set from the build spec the
plan carries and **refuses before any API call** if the two no longer match:

```json
{"status": "refused", "code": "plan_envelope_mismatch",
 "envelope_ops": {"campaign-geo-add": 0}, "recomputed_ops": {"campaign-geo-add": 1}}
```

(exit 3). Re-generate the plan with `recipe build` on the current binary and
review it again — the refusal means the document you were about to approve is
not what would have run.

## Safety

Everything in [`recipes.md` § Safety](recipes.md#safety) applies. In addition:

- the campaign is born **PAUSED** and the plan says so (`policy.born_paused`);
- **one campaign per session** — a build is exactly one campaign;
- on a sandbox account every entity carries `safety.name_prefix`, and the plan
  records it under `policy.sandbox.required_name_substring`;
- 🔴 write tests run against the Google **test child** only (AGENTS.md Hard Rule
  #11). A payload that reaches Google must carry a **real, resolving domain** —
  `example.com` is forbidden in a live payload even though it is required in
  committed text (Hard Rule #10).
