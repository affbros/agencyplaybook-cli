# Capability matrix — what's proven, and how to trust a write

A `200` / exit-0 from a mutation is **not** proof the change persisted. Some Google Ads v24 fields
are accepted but silently not applied, write-only, or frozen at create. **Never claim a write
landed from the response alone — confirm by readback.** This reference tells you how strongly each
surface has been proven and how to verify the rest yourself.

## Execution tiers (strongest proof a surface has earned)

| Tier | What it means |
|---|---|
| **READ** | Reads/reports — always live, no gates. |
| **DRY_RUN** | Local validators run, no API call. The default for every `mutate`. |
| **SERVER_VALIDATED** | Google validated the full request body (`validateOnly=true`) — schema + policy + auth — and created nothing. Invoke with `--execute --validate-only`. |
| **EXECUTE_SANDBOX** | A real write, but confined to the `$1` `Test-ok-to-delete` sandbox (or a per-customer profile). |
| **LIVE_VERIFIED** | Real entities created via a `verify` chain, **read back to confirm**, then atomically cleaned up and ledger-recorded. |

## What's verified at the top tier

- **LIVE_VERIFIED** (full create → readback → cleanup proven): SEARCH campaign create + targeting
  (`verify search-lifecycle`), RSA create + refresh (`verify rsa-lifecycle` → covers
  `ad-create` + `ad-update-status`), and atomic PMAX launch (`verify pmax-launch`).
- **SERVER_VALIDATED**: the large majority of the 116 `mutate` surfaces have been proven against
  Google's validator via `--validate-only` — schema + policy correct, no state change. This is the
  fastest way to prove *your* payload before writing.
- **EXECUTE_SANDBOX**: every other execute-mode write lands in the `$1` `Test-ok-to-delete`
  sandbox unless a per-customer profile authorizes the specific op (see `SAFETY_MODEL.md`).

Honest caveats to carry into recommendations: **full PMAX lifecycle management** (image/video
upload, every listing-group shape) is partial, and **broad live write surface beyond the
sandbox/profile envelope is intentionally gated**. When you're unsure a surface is hardened, say so
and prove it with `--validate-only` rather than asserting it works.

## How to verify a specific field changed

1. **Before writing** — `--execute --validate-only` to prove the wire shape (SERVER_VALIDATED).
2. **After writing** — read it back and compare to the intended value:
   - `apb-gads --customer <CID> campaign get --campaign-id <ID>` / the matching `report …`
   - or a targeted `apb-gads --customer <CID> gaql query --query "SELECT … WHERE …"`
3. **Report honestly**: "verified by readback" vs "accepted (200) but not confirmable" vs
   "rejected." For multi-entity changes, a `verify` chain does the readback for you and records the
   result in the ledger (`verify list`).

> The runtime is the source of truth for what exists and what's hardened. `apb-gads playbook list`,
> `apb-gads <group> --help`, and `references/commands/<group>.md` are authoritative; this matrix is
> a reasoning aid, not a guarantee.
