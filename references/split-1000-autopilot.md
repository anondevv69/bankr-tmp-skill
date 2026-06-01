# Split fee rights to 1000 units (on-chain steps after mint)

> **Start here for user messages:** **`fractionalize-autopilot.md`** (mint + split, plain English, no user-facing APIs).

**Trigger:** User wants **split** / **fractionalize** / **“1000 nfts”** / **1/1000** fee rights.

**Prerequisite:** **`GET /api/mint/status`** → **`phase: "ready"`** (hybrid TMPR `0xD8e0639…`). If not ready, **`fractionalize-autopilot.md`** runs mint first.

This is **Flow C** — **not** `POST /api/list/dual` (sell 100%).

---

## V6 split (keep all 1000 units)

Same as site **Split into 1000 shares** wizard (`SplitIntoSharesWizard.tsx`) — **private self-split**, not public CTO.

| Step | Contract | Action |
|------|----------|--------|
| 1 | Hybrid TMPR `0xD8e0639…` | `approve` → **GroupBuyEscrowV6** `0x56bd948671955D0Ed82a88f136779cB76f551e0C` |
| 2 | V6 | `createPartialSale` — `designatedBuyer` = seller, `sellerKeepsBps=0`, price ≈ **0.0001 ETH** (self-split) |
| 3 | V6 | `contribute(listingId)` with `msg.value` = listing price |
| 4 | V6 | `finalize(listingId)` → **1000** ERC-1155 units to seller |

**`rightsEscrow` / `venueType`:** from `GET /api/mint/status` → `nextStep.rightsEscrow` (dntfbuy: `0xf288…`).

**Custodial approve blocked?** → **`split-custodial-approve-block.md`** (3 retries → transfer receipt to user EOA → site wizard). User “yes bypass” may still fail.

**Verify:** `GET /api/claim/hybrid-status?token=<launch>&wallet=<linked>` → **`unitsHeld`** = 1000 (or expected).

**List units later:** `share-market-list-autopilot.md`.

---

## Agent must not

- `POST /api/list/dual` (whole NFT fixed sale)
- 1000 separate OpenSea listings
- Split before mint **`ready`**
- Mint on **legacy** escrow `0x6238…` then expect 1000-unit split (legacy receipt `0xCD66…` is wrong collection)

---

## Cross-links

- **`fractionalize-autopilot.md`** — user phrases + mint loop  
- **`hybrid-escrow-mint-blocker.md`** — hybrid `prepareDeposit` platform block  
- `TOKEN-SETUP-COMPLETE-GUIDE.md` Flow C  
- `product-rules.md`
