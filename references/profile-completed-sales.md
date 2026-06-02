# Profile — completed sales & purchase history (site UI)

> **Sell 100%** and **fixed-sale purchases** no longer disappear when the NFT leaves the wallet.
> **Group CTO / partial / co-own** finalized sales remain under **Completed group sales**.

**URL:** https://www.tokenmarketplace.shop/profile?tab=completed

---

## What users see

| Section | Contents |
|---------|----------|
| **Fixed-price sales (Sell 100%)** | **You sold** — you listed Sell 100%, someone bought · **You bought** — you purchased `/listing/sale/{id}` |
| **Completed group sales (Base)** | Finalized CTO / partial / co-own / self-split — claim fees, unit balances |
| **Solana fee rights (completed)** | Finalized Pump raises (if Solana enabled) |

Each fixed-sale row: ETH price, listing id, counterparty wallet, links to **listing page** and **BaseScan tx**.

---

## What agents should say

```text
Open your completed sales on the site:
https://www.tokenmarketplace.shop/profile?tab=completed

Under “Fixed-price sales” you’ll see Sell 100% you sold and NFTs you bought. Group CTO history is in “Completed group sales” below.
```

**Do not** tell them to hunt BaseScan only — the site indexes recent **`Sold`** events on all fixed-sale contracts (`0xe2A1…`, legacy `0xeb8a…`, etc.).

---

## Limits

- History scans **recent Base blocks** (~2.5M by default on server). Very old sales may be missing — use BaseScan or `POST /api/alerts/from-tx` with tx hash for proof.
- **Share market** fills (bought/sold units) are **not** in this table yet — only **whole NFT** fixed sales.
- **Active** listings stay on **Profile → NFTs**, not Completed.

---

## Ops / alerts replay

```http
POST https://www.tokenmarketplace.shop/api/alerts/from-tx
Authorization: Bearer <LISTING_PUBLISH_SECRET>
{"txHash":"0x…"}
```

- **List tx** → listing alert (`/webhook/listing`)
- **Buy tx** → sale alert (`/webhook/sale`)

See **`BANKR-PLATFORM-TWEET-INTAKE.md`**.

---

## Related

- **Buy fixed sale:** `buy-fixed-sale-autopilot.md`
- **Sell 100%:** `sell-list-autopilot.md`
- **Send units after split:** `transfer-units-autopilot.md`
