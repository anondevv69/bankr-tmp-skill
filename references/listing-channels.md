# Where listings live — site, API, OpenSea, partial %

## Two different products

| User wants | Mechanism | Site | `POST /api/list/dual` | OpenSea |
|------------|-----------|------|----------------------|---------|
| **Sell 100%** for X ETH | `FeeRightsFixedSale.list` | Fixed-price buy | **Yes** — returns approve + list calldata + OS hints | **Yes** — via OpenSea skills after dual API |
| **Sell 5%** (keep 95%) for X ETH | `GroupBuyEscrowV2.createPartialListing` | **My profile** → partial sale — **one buyer** pays full price | **No** — do not use dual API | **Not integrated today** |
| **Private partial** (5% for one wallet only) | `GroupBuyEscrowV3.createPrivatePartialListing` | **My profile** — checkbox + buyer `0x…` | No | No — not public browse |
| **Group buy** (many wallets, 100% slice) | `createListing` | Group buy tab | No | Not integrated |
| **Crowdsource** | `createCrowdsource` | Group buy tab | No | Not integrated |

**Bankr / agents:** For **100%**, call **`POST https://www.tokenmarketplace.shop/api/list/dual`**. For **partial %**, use **on-chain** `createPartialListing` (or site UI) — there is **no** dual-list API yet.

---

## Does Bankr need an API to list on the marketplace?

**Sell 100%:** Yes — **`POST /api/list/dual`** with `{ tokenId, priceEth, seller }` so the agent gets correct **approve** + **list** calldata for `FeeRightsFixedSale` and OpenSea orchestration hints. Status: **`GET /api/list/status?tokenId=`**.

**Partial sale (5%):** Today **no** agent API. The agent (or user on site) must:

1. Hold TMPR for that launch.
2. `approve(GroupBuyEscrowV2, tokenId)` on TMPR `0xCD6634…`.
3. `createPartialListing(..., sellerKeepsBps=9500, priceWei=…)` on **`0x869D11606B94de1206669C55f8628749bCBBFfD4`**.

**Private partial (one buyer wallet):** deploy **`GroupBuyEscrowV3`**, set `VITE_GROUP_BUY_ESCROW_V3_ADDRESS`, then `createPrivatePartialListing(..., designatedBuyer_)`. Only that address can `contribute()`. Not shown on public Group buy browse.

**Cancel before payment:** seller calls `cancel(listingId)` on V2 or V3 while `totalRaised == 0` — NFT returns to seller. **After any payment**, cancel reverts (`HasContributions`).

**Future (repo gap):** add e.g. **`POST /api/group-buy/partial`** returning calldata + human summary (“keep 95%, sell 5% for 0.005 ETH”) and index active partial listings in **`GET /api/listings/shop`**.

---

## Is there a separate “5% NFT”?

**No.** One **TMPR** = receipt that fee rights were escrowed (usually **100%** of your launch share at mint time).

**Partial sale** does **not** mint a 5% NFT. It:

1. Locks **your existing TMPR** in `GroupBuyEscrowV2`.
2. Waits for **one buyer** to pay the **full listed price** in a single transaction (UI sets `minContributionWei = priceWei` on new listings).
3. On **finalize**, burns TMPR via `redeemRights`, routes fees to a **0xSplits** contract (seller keep-% + buyer’s sold-%).

The buyer gets **100% of the sold slice** of future fees — **not** a new OpenSea collectible for “5%.” This is **not** a group pool where many wallets chip in (that’s group buy / crowdsource).

---

## Can the 5% slice be listed on OpenSea?

**Not as a first-class flow today.**

| Approach | Reality |
|----------|---------|
| Dual list + OpenSea | **100% only** — wrong product for partial |
| List TMPR on OpenSea **while** partial sale active | NFT is held by **GroupBuyEscrowV2** after `createPartialListing` — seller no longer owns it; OS listing stale/invalid |
| List on OpenSea **before** partial, then partial on site | Possible but confusing: on-chain metadata still describes **full** receipt, not “5% for sale” |
| After finalize, sell “5%” on OpenSea | No 5% NFT exists — only **split addresses** |

**Recommendation for users:** Partial sales are discovered on **https://www.tokenmarketplace.shop** → **Group buy** (read `getListing` on V2 for `sellerKeepsBps`, `priceWei`, `tokenId`).

**If OpenSea visibility is required later:** either (a) OpenSea listing **title/description** set via Seaport metadata at list time (off-chain, agent-written: “5% fee rights — complete purchase on Token Marketplace”), or (b) product change: fractional receipts / updated `tokenURI` (on-chain work).

---

## Metadata and “5% ownership” on the NFT

**Current TMPR `tokenURI` (on-chain):** Serial, launch factory, ticker, token name, pair, token contract, original seller, fee manager. **Does not** include keep-% / sold-% / partial listing state.

**Partial sale terms** live on **`GroupBuyEscrowV2` listings** (`sellerKeepsBps`, `priceWei`, `deadline`) — not in ERC-721 metadata.

**What buyers should see (today):**

- Site **Group buy** UI copy: “Keep 95%, sell 5% for 0.005 ETH.”
- On-chain: `getListing(listingId)` on `0x869D…fD4`.

**To “make metadata highlight 5%” (work needed):**

1. **Site / API (lighter):** Shop indexer includes V2 listings; cards show **“Selling 5% · Keep 95% · 0.005 ETH”** from `sellerKeepsBps`.
2. **OpenSea listing text (medium):** Only for **100%** dual path — Seaport `name` / `description` in OpenSea skills.
3. **On-chain receipt (heavier):** Extend `BankrFeeRightsReceipt` or use dynamic base URI with listing id + % (new contract version + redeploy).

---

## Agent plain-English summary (user-facing)

> **Sell everything for 0.01 ETH** → marketplace + OpenSea (I use our list API).  
> **Sell 5% and keep the rest** → group sale on Token Marketplace; buyers chip in ETH; you keep 95% of fees forever. That’s not a separate 5% NFT on OpenSea — the site shows the split.

See also: **`normal-talk-only.md`**, **`partial-sale-resolve-token.md`**, **`all-escrow-options.md`**.
