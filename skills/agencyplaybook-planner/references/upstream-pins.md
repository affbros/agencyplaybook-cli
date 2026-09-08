# Upstream skill pins — what this planner was validated against

Both upstream repos are actively maintained (coreyhaines31/marketingskills and fourteenwm/ppc-ai-skills
both pushed in late Aug 2026). We **do not vendor their content** — the planner layers them by name from
`~/.claude/skills/`. This file records the commit each was validated against so a refresh is a diff,
not a surprise.

| Skill | Repo path | Validated commit · date | Installed |
|---|---|---|---|
| `ads` | `coreyhaines31/marketingskills` · `skills/ads` | 4664d94f2183  2026-08-23 | 2026-09-08 |
| `ad-creative` | `coreyhaines31/marketingskills` · `skills/ad-creative` | 115cc3a3fc9b  2026-08-23 | 2026-09-08 |
| `ad-copy-verification-standard` | `fourteenwm/ppc-ai-skills` · `ad-copy-verification-standard` | 5baee3e042cb  2026-08-03 | 2026-09-08 |
| `ad-copy-generation-framework` | `fourteenwm/ppc-ai-skills` · `ad-copy-generation-framework` | 5baee3e042cb  2026-08-03 | 2026-09-08 |

## Refresh procedure (never overwrites silently)

1. Check for movement: `gh api "repos/<repo>/commits?path=<path>&per_page=1" --jq '.[0].sha'` vs the pin.
2. Fetch the new tree into a **scratch dir** (`/tmp/skill-refresh/<name>`), never straight into
   `~/.claude/skills/`.
3. `diff -r ~/.claude/skills/<name> /tmp/skill-refresh/<name>` — read what changed. The things that
   can break the planner: renamed reference files the SKILL.md routes to, changed angle names
   (copy-doctrine.md mapping), new hard rules that conflict with copy-doctrine.md precedence.
4. **Ask the operator before replacing** (repo feedback: no rm/mv of user files without approval).
   On approval: move the old dir to `~/.claude/skills/_archive/<name>-<pin>`, copy the new one in.
5. Re-run one planner dry-run on the sandbox (`cli-handoff.md` steps 1–7) and update the table above.

Cadence: check on the first planner use each month, or when a build's copy looks off.
