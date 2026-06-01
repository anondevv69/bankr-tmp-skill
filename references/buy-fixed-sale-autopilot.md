# Buy 100% fee rights (fixed sale) — mandatory routing

> **Regression:** Bankr read **share** listing id `1` on `0x9023…` as inactive when user pasted **`/listing/sale/1`** (fixed sale id `1` on `0xe2A1…`, which was **active**). See **`buy-url-routing-regression.md`**.

**Load this file** on any **buy / purchase** message that includes:

- `tokenmarketplace.shop/listing/sale/…`
- **buy listing N** / **buy this listing** + shop URL
- **buy 100%** / **buy the full fee rights** / **buy the whole NFT**

**NOT this file** (use **`share-market-buy.md`**):

- **buy 1 share** / **cheapest share** / **1/1000** / `/listing/shares/…`

---

## Golden rule — URL → contract

| URL path | Product | Contract | API |
|----------|---------|----------|-----|
| `/listing/sale/{id}` | **Sell 100%** (whole receipt) | **`FeeRightsFixedSale` `0xe2A13499292D43254026DAf0C4F75988242BaA66`** | **`GET /api/list/buy-status`** |
| `/listing/shares/t/{tokenId}` | Share units | `HybridShareMarketplace` `0x90230B…` | share list-status + share-market-buy |
| `/listing/group/…` | CTO / partial / pool | `GroupBuyEscrowV2` | contribute — flows-reference |

**FORBIDDEN:** Call **`GET /api/share/list-status?listingId=`** when user gave **`/listing/sale/{id}`**. Share listing id **N** ≠ fixed sale listing id **N**.

---

## Mandatory first step

```http
GET https://www.tokenmarketplace.shop/api/list/buy-status?url=https://www.tokenmarketplace.shop/listing/sale/1
```

or

```http
GET https://www.tokenmarketplace.shop/api/list/buy-status?listingId=1
```

Read **`canBuy`**, **`priceWei`**, **`nextStep`**. If response says **`route: shareMarket`** — you parsed the wrong URL; switch to share-market-buy.

---

## Agent algorithm (same thread)

1. **`GET /api/list/buy-status`** with **`url=`** (preferred) or **`listingId=`**.
2. If **`!canBuy`** → reply: inactive / sold / cancelled + link to shop home; **do not** claim share market inactive.
3. If **`passwordProtected`** → **`POST /api/listings/access-authorize`** `{ kind: "fixed", listingId, buyer, password }` → **`buy(listingId, authDeadline, signature)`** with **`msg.value = priceWei`**.
4. Else execute **`nextStep`**: `to` = marketplace, `data`, **`value` = priceWei exactly** (or tx reverts `WrongPayment`).
5. Verify buyer received NFT: `ownerOf(tokenId)` on **`collection`** from response = buyer wallet.
6. Reply with **listing URL**, **price ETH**, **tx hash**.

---

## User phrases → this flow

| User says | You do |
|-----------|--------|
| `buy https://www.tokenmarketplace.shop/listing/sale/1` | buy-status → buy(1) |
| `buy listing 1 on token marketplace` | buy-status?listingId=1 — **fixed sale**, not share |
| `buy the full fee rights` + sale URL | This file |
| `buy 1 share of t7` | **share-market-buy.md** |
| `buy t7 for 0.01 eth` (no URL) | Find active fixed sale via token: `GET /api/list/status?tokenId=` or shop index; or ask for sale URL |

---

## On-chain (if API unavailable)

| Field | Value |
|-------|--------|
| Marketplace | `0xe2A13499292D43254026DAf0C4F75988242BaA66` |
| Function | `buy(uint256 listingId)` payable |
| Payment | **`msg.value` must equal `getListing(id).priceWei` exactly** |

```text
Never use HybridShareMarketplace 0x90230B59D01c6e0306236eF7afc8105908c4DB0B for /listing/sale/ URLs.
```

---

## Success reply template

```text
Bought listing #{id} — full fee rights for {priceEth} ETH.
Shop: https://www.tokenmarketplace.shop/listing/sale/{id}
tx: 0x…
You now hold the receipt NFT — claim/redeem per profile.
```

---

## Cross-links

- **`share-market-buy.md`** — 1/1000 units only
- **`sell-list-autopilot.md`** — seller list path
- **`buy-url-routing-regression.md`** — why sale/1 ≠ share id 1
