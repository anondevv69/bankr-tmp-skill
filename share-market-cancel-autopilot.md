# Share market cancel autopilot — natural language only

> **Users say:** “cancel my share listing” / “remove my CTO units from sale” / “cancel listing 13”  
> **You:** resolve listing id, submit **`cancel(listingId)`**, verify receipt — **never** ask them for listingId if the API returns it.

**Full spec:** **`share-market-list.md`** § Cancel · **`share-market-list-autopilot.md`** (list path)

---

## TRIGGER

Match any of:

- **cancel / remove / delist** + **share(s) / unit(s) / 1/1000 / order book**
- **cancel listing** + optional **listing id** (e.g. “13”) or **$TICKER**
- **undo my list** on hybrid share marketplace

**NOT this file:**

| User intent | Route to |
|-------------|----------|
| Cancel **100% TMPR** fixed sale | **`FeeRightsFixedSale.cancel`** — dual list / sell-list-autopilot |
| Cancel **partial / group buy** | GroupBuyEscrow cancel rules — **`listing-channels.md`** |
| Cancel **OpenSea only** | OpenSea UI — separate from share order book |

**Load:** `bankr-fee-rights` → **this file** + **`share-market-list.md`**.

---

## MANDATORY FIRST STEP

**`GET https://www.tokenmarketplace.shop/api/share/list-status?wallet=<linked>&listingId=<id>`**

If user gave **ticker only** (e.g. $CTO):

1. **`GET …/api/claim/hybrid-status?token=<launch>&wallet=<linked>`** → **`hybridTokenId`**
2. **`GET …/api/share/list-status?wallet=<linked>&hybridTokenId=<hybridTokenId>`**

If **no listingId** in tweet, scan response **`listings[]`** — pick the active row (newest if one match). **Do not ask** “do you have the listing id?” when API returned **`nextStep`**.

---

## Routing guard

```
if user wants to cancel ERC-1155 share / unit listing:
  1. GET /api/share/list-status (linked wallet + listingId OR hybridTokenId)
  2. if !canCancel → explain wrong wallet or already cancelled → STOP
  3. submit nextStep.data to HybridShareMarketplace (0x90230B…)
  4. verify ShareListingCancelled in receipt
  5. plain English reply + order book link (still valid page; offer gone) → STOP

elif user wants cancel 100% TMPR fixed sale:
  → FeeRightsFixedSale.cancel — NOT this file

elif user wants cancel dual list:
  → cancel site fixed sale first; share cancel only if they also listed units
```

**FORBIDDEN:** `FeeRightsFixedSale.cancel` for share listings · guessing listingId · “I don’t have cancel in the skill” (this file exists).

---

## Execution steps (autopilot)

1. **Resolve** listing:
   - User said **“listing 13”** → `GET …/share/list-status?wallet=0x…&listingId=13`
   - User said **“cancel my CTO shares”** → hybrid-status → share/list-status with `hybridTokenId`
   - User pasted **shop URL** `/listing/shares/t/{hybridTokenId}` → extract token id → share/list-status
2. **Confirm** `selectedListing.canCancel === true` (linked wallet = seller).
3. **Submit** `nextStep.data` — **`cancel(listingId)`** on **`0x90230B59D01c6e0306236eF7afc8105908c4DB0B`**.
4. **Verify** receipt logs **`ShareListingCancelled(listingId, …)`** — unsold quantity returns to seller wallet.
5. **Reply** — units back in wallet; listing removed from order book. Include tx hash. **STOP**.

---

## Example — cancel listing 13 (CTO)

**User:** “@bankrbot cancel my share listing 13”

```http
GET …/api/share/list-status?wallet=0x374D…&listingId=13
→ active: true, canCancel: true, quantity: 10, nextStep.data: 0x…
```

Submit cancel tx → verify → reply:

> Cancelled your **10-share $CTO** listing (id **13**). Unsold units are back in your wallet.  
> tx: 0x…

---

## X / tweet reply (mandatory)

After successful cancel on @bankrbot tweet:

- Confirm **cancelled** + **quantity returned**
- Include **tx hash** (BaseScan)
- Optional: order book URL (buyers will no longer see your offer)

**FORBIDDEN:** “I need the listing id” when user already said **13** or API returned listings.

---

## When tools are missing (honest reply)

> “I can cancel share listings on Token Marketplace, but I can’t submit txs from this session. Open your [order book link](https://www.tokenmarketplace.shop/listing/shares/t/…) and use **Cancel listing** with the same wallet that listed. Or retry after TMP skills load.”

---

## Cross-links

- **`share-market-list-autopilot.md`** — list path
- **`share-market-buy.md`** — buy path (not cancel)
- **`AGENT-ROUTING-LISTINGS.md`**
