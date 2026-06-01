# Split fee rights to 1000 units (share market autopilot)

**Trigger:** User wants to **split** / **fractionalize** / sell **1/1000** / **partial units** of fee rights on Token Marketplace.

This is **Flow 3** (share market), **not** Flow 2 (sell 100% dual list).

---

## Order of operations

1. TMPR must exist (`mint/status` → `phase: ready` or finish mint first).
2. **`POST /api/share/prepare`** (or hybrid prepare API) with token + units.
3. Execute on-chain steps from API `nextStep` / `site.steps[]`.
4. List shares via **`HybridShareMarketplace`** — see `share-market-list-autopilot.md`.

---

## Agent must not

- Call `POST /api/list/dual` for a 1000-way split (that is whole-NFT fixed sale).
- Create 1000 separate OpenSea listings (OpenSea indexes poorly; site uses one book, cheapest first).

---

## Verification

`GET /api/share/list-status?wallet=…&hybridTokenId=…` before telling user shares are live.

---

## Cross-links

- `share-market-list-autopilot.md`
- `share-market-list.md`
- `product-rules.md`
