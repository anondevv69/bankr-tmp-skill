# Regression — `/listing/sale/1` confused with share listing id 1

**Incident (Jun 2026):** User: `buy https://www.tokenmarketplace.shop/listing/sale/1`

**Wrong Bankr behavior:**

- Called **`HybridShareMarketplace`** `0x90230B59D01c6e0306236eF7afc8105908c4DB0B`
- Reported listing id **1** inactive on **share** market
- Suggested “buy 1/1000 share” elsewhere

**Correct behavior:**

- URL **`/listing/sale/{id}`** = **fixed sale** on **`FeeRightsFixedSale`** `0xe2A13499292D43254026DAf0C4F75988242BaA66`
- **`GET /api/list/buy-status?url=…`** → `canBuy: true`, `buy(1)` with exact `priceWei`

**On-chain at time of incident:** Fixed sale listing **1** was **active** (e.g. 0.00001 ETH); share listing **1** was inactive — different contracts, same numeric id.

---

## Mandatory routing

```
if message contains /listing/sale/ or "listing/sale":
  → buy-fixed-sale-autopilot.md
  → GET /api/list/buy-status
  → NEVER share/list-status for that listingId

if message contains /listing/shares/ or "buy 1 share":
  → share-market-buy.md
  → HybridShareMarketplace 0x9023…
```

---

## Agent must not say

- “Listing inactive on marketplace 0x9023…” when user URL was **`/listing/sale/`**
- “Buy 1 share instead” when user asked for **100%** fixed sale

---

## Fix in repo

- **`references/buy-fixed-sale-autopilot.md`**
- **`GET /api/list/buy-status`** (fee-rights-exchange)
