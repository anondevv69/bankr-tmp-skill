# Buy anything on Token Marketplace (autopilot)

> **Hub file** for all purchase flows — Base + Solana + OpenSea TMP.  
> **Site agent guide:** https://www.tokenmarketplace.shop/agent.md

Install **this repo** for full marketplace coverage, or install focused companions only (same behavior when docs are loaded).

---

## Pick the flow from what the user said

| User wants | URL / signal | Playbook | API (first step) |
|------------|--------------|----------|------------------|
| **Buy whole fee rights** (100% sale) | `/listing/sale/{id}` | **`buy-fixed-sale-autopilot.md`** | `GET /api/list/buy-status?url=…` |
| **Buy 1 share** / cheapest unit / 1/1000 | `/listing/shares/t/{tokenId}` | **`share-market-buy.md`** | scan marketplace + `buy(listingId, qty)` |
| **Chip in to CTO / group buy / co-own** | `/listing/group/{escrow}/{id}` | **`flows-reference.md` Flow 4** | `contribute(listingId)` + `msg.value` |
| **Buy on Solana CTO** | `/listing/sol/{pubkey}` | **`tmp-solana-cto/solana-buy-autopilot.md`** | `GET /api/solana/buy-status` |
| **Buy TMPR on OpenSea** | opensea.io / Seaport | **OpenSea skill** + verify collection | Seaport fulfill (not fixed-sale API) |

**FORBIDDEN:** `GET /api/share/list-status` when URL is **`/listing/sale/`**. Sale id **N** ≠ share listing id **N**.

---

## 1 — Buy fixed sale (100% on site)

```http
GET https://www.tokenmarketplace.shop/api/list/buy-status?url=https://www.tokenmarketplace.shop/listing/sale/27
```

- Contract: **`FeeRightsFixedSale` `0xe2A13499292D43254026DAf0C4F75988242BaA66`** (also try legacy `0xeb8a…` if API says so)
- Pay **`msg.value = priceWei` exactly**
- Password listing → `POST /api/listings/access-authorize` then `buy(id, deadline, sig)`

Full steps: **`buy-fixed-sale-autopilot.md`** · regression: **`buy-url-routing-regression.md`**

---

## 2 — Buy ERC-1155 shares (after split / CTO finalize)

- Marketplace: **`HybridShareMarketplace` `0x90230B59D01c6e0306236eF7afc8105908c4DB0B`**
- Sort offers by **price per unit** ascending → pick rank #1 (or user’s rank N)
- `buy(listingId, quantity)` with exact ETH = `pricePerUnitWei * quantity`
- Password-gated shares: authorize like fixed sale, then buy with signature

Full steps: **`share-market-buy.md`**

---

## 3 — Participate in Base CTO / group buy (not “buy listing”)

User is **funding a pool**, not buying a listed share or fixed sale.

1. Open listing: `https://www.tokenmarketplace.shop/listing/group/0x56bd948671955D0Ed82a88f136779cB76f551e0C/{listingId}`
2. Read target `priceWei`, `minContributionWei`, deadline
3. `contribute(listingId)` on **GroupBuyEscrowV6** `0x56bd948671955D0Ed82a88f136779cB76f551e0C` with `msg.value`
4. When pool full → seller (or anyone) `finalize` → buyers get ERC-1155 units pro-rata

Partial sale (seller keeps %): **`flows-reference.md` Flow 3** — different `sellerKeepsBps`.

---

## 4 — Buy on Solana (Pump.fun CTO)

**Requires companion skill** (or this repo’s `tmp-solana-cto/` folder):

```text
install TMP Solana CTO at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-solana-cto
```

```http
GET https://www.tokenmarketplace.shop/api/solana/buy-status?listing=<pubkey>&wallet=<sol>&password=…&quantity=1
```

Until Bankr Solana signing: direct user to **site** with Solana wallet connected.

---

## 5 — Buy TMPR on OpenSea

- Collection: **Token Marketplace** on Base (hybrid TMPR `0xD8e0639…`)
- Use **Bankr OpenSea / Seaport** skills — not `FeeRightsFixedSale.buy`
- After purchase, user holds NFT on OpenSea; fee claims still via site claim router if they hold units

Install: `install opensea skills at https://github.com/BankrBot/skills`

---

## Success reply template

```text
Bought {what} for {price} on Token Marketplace.
Link: {full shop URL}
tx: 0x…
```

Always include **full** `https://www.tokenmarketplace.shop/...` URL.

---

## Companion install lines

| Skill | Install |
|-------|---------|
| **All buys + site APIs (this repo)** | `install TMP skills at https://github.com/anondevv69/bankr-tmp-skill` |
| **Listing only** | `install TMP listing at https://github.com/anondevv69/TMP-Skill-Listing` |
| **Split 1000 only** | `install TMP split 1000 at https://github.com/anondevv69/TMP-Skill-Split-1000` |
| **Solana buy/claim** | `install TMP Solana CTO at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-solana-cto` |
