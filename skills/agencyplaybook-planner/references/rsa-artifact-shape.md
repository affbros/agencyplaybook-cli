# `build/rsa.json` — the contract for agent-written copy

When `copy.provider: agent`, the planner writes this file itself, in exactly the shape `plan rsa`
emits, so `plan campaign search --rsa build/rsa.json` and the binary's `rsa_quality` lint consume
it unchanged. Shape captured from `apb-gads 0.1.20` output on 2026-09-08.

```json
{
  "command": "plan rsa",
  "provider": "agent",
  "campaigns": [
    {
      "campaign": "campaign-commercial",
      "intent": "commercial",
      "ad_groups": [
        {
          "ad_group": "adgroup-best",
          "cluster": "best",
          "final_urls": ["https://www.example.com/whole-bean"],
          "headlines": [
            { "text": "Best whole bean coffee",      "purpose": "keyword_relevance", "char_count": 22, "valid": true },
            { "text": "Roasted to order",            "purpose": "benefit",           "char_count": 16, "valid": true },
            { "text": "Ships within 48 hours",       "purpose": "benefit",           "char_count": 21, "valid": true },
            { "text": "Rated 4.8 by 2,100 customers","purpose": "trust",             "char_count": 28, "valid": true },
            { "text": "Order fresh beans today",     "purpose": "cta",               "char_count": 23, "valid": true }
          ],
          "descriptions": [
            { "text": "Small-batch beans roasted the day you order and shipped within 48 hours.", "purpose": "benefit", "char_count": 72, "valid": true },
            { "text": "Single origin and espresso blends. Free shipping on orders over $40.",      "purpose": "urgency", "char_count": 68, "valid": true }
          ],
          "pins":  { "HEADLINE_1": ["Best whole bean coffee", "Fresh roasted whole bean"] },
          "paths": ["coffee", "whole-bean"],
          "validation": { "errors": [], "warnings": [] }
        }
      ]
    }
  ]
}
```

## Rules the file must satisfy (the binary checks them; you check first)

- `campaign` / `ad_group` / `cluster` values must match `build/structure.json` exactly — that is the
  join key. Every ad group in the structure gets one entry.
- `char_count` is the real length (spaces included); `valid` is `char_count ≤ 30` for headlines,
  `≤ 90` for descriptions, `≤ 15` for paths.
- `purpose` ∈ `keyword_relevance | benefit | trust | urgency | identity | differentiation | cta | hook`
  (see copy-doctrine.md for the mapping from `ad-creative` angles). At least one
  `keyword_relevance`, one `benefit`, one `cta` per ad group.
- 8–15 headlines, 2–4 descriptions, sentence case, no duplicates or near-duplicates, no Title Case.
- `pins` is optional and **partial**: only positions you must control, and 2–3 alternatives per pinned
  position. `HEADLINE_1..3`, `DESCRIPTION_1..2`.
- Every factual claim (numbers, ratings, "free", awards, guarantees) has a line in
  `build/copy-sources.md` (`claim → source URL / quote`). No source → the claim does not appear.
- `provider` is `"agent"` so the review doc and the summary say where the copy came from.

If the heuristic path was used instead, leave the file as `plan rsa` produced it; the summary must
say `provider: heuristic` and flag *"starter copy — improve before launch"*.
