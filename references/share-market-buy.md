# Buy 1/1000 shares (hybrid share market) — Bankr agent

Users who **split** fee rights into **1,000 tradeable units** (hybrid TMPR / Group buy V6 finalize) can **list units** on the **share market**. Buyers purchase with ETH — **not** the old “buy 100% TMPR” fixed sale and **not** “chip in to a partial sale pool.”

**Plain language:** **`normal-talk-only.md`**. This file is **routing + on-chain steps**.

---

## What the user means

| User says (examples) | Meaning | You do |
|----------------------|---------|--------|
| **“Buy the cheapest share of $t7”** | Lowest **ETH per unit** on that token’s order book | Resolve token → TMPR **tokenId** → pick **rank #1** offer → `buy` **qty 1** |
| **“Buy 1 share”** / **“one unit”** / **“. 1”** (quantity) | **Quantity = 1** on the chosen offer (default: cheapest) | `buy(listingId, 1)` |
| **“Buy 5 shares at the best price”** | Cheapest offer, **qty 5** | Cap by listing `quantity` and `maxPerWallet` |
| **“Buy listing 42”** / **“offer #42”** | Specific **`listingId`** on the marketplace | `getListing(42)` — must be **active** and match token |
| **“Second cheapest”** / **“version 2”** / **“offer 2”** | **Rank #2** after sorting by price (see below) | Use sorted offers `[1]` (0-based index 1) |
| **“Buy version 1”** (ambiguous) | Usually **cheapest offer + 1 unit** | Default: rank #1, qty **1**; if no listings, say so |
| **“Buy a piece of t7 fees”** / **“buy 0.1% of t7”** | **1/1000 share** market (if listings exist) | Same as cheapest / qty from context |

**“Version N”** here means **Nth cheapest listed offer** on the site order book (same sort as the UI: **cheapest first**). It is **not** a serial number inside the NFT — all units for one sale share one ERC-1155 **tokenId**.

**Do not confuse:**

| Phrase | Wrong flow | Right flow |
|--------|------------|------------|
| Buy **cheapest share** | `FeeRightsFixedSale.buy` (whole TMPR) | **HybridShareMarketplace.buy** |
| Buy **5% of fees** / group pool | Partial sale `contribute` | Share market only if **units** are listed |
| **OpenSea** buy TMPR | Seaport | On-chain share market is **only** on Token Marketplace |

---

## Contracts (Base mainnet — hybrid stack)

| Role | Address |
|------|---------|
| **Hybrid TMPR** (ERC-1155 units + ERC-721 receipt) | `0xD8e0639DfAa1cB2b9f9642EeCbd40b1e5a8b42A7` |
| **HybridShareMarketplace** | `0x90230B59D01c6e0306236eF7afc8105908c4DB0B` |
| **GroupBuyEscrowV6** (split → 1000 units) | `0x56bd948671955D0Ed82a88f136779cB76f551e0C` |

Legacy **ERC-721-only** TMPR `0xCD6634…` uses **fixed sale / dual list** — **no** 1/1000 share order book unless the position was migrated to hybrid (rare). If user holds **only** legacy TMPR, explain they need a **split sale** (V6 finalize) first, or buy **100%** via fixed sale.

**Site deep link (after you know tokenId):**  
`https://www.tokenmarketplace.shop/listing/shares/t/{tokenId}`

---

## Agent algorithm

### 1 — Resolve **which token** (human input → `tokenId`)

1. **Ticker / name** → launched ERC-20 via `get_token_launch_info` / `token-fees`.
2. Find **hybrid** position: scan user’s holdings or catalog:
   - ERC-1155 `balanceOf(buyer, tokenId)` on **`0xD8e0639…`** > 0 means they already own units (optional).
   - For **buying**, you need **`tokenId`** for the **sale** (same id used on share market pages).
3. Sources for **tokenId**:
   - User gives **share market link** `/listing/shares/t/123` → `tokenId = 123`.
   - User gives **group buy / hybrid listing id** from V6 — often **equals** share-market **tokenId** after finalize.
   - OpenSea / TMPR: `tokenId` on **hybrid** collection `0xD8e0639…`.
4. If ambiguous among multiple tokens, ask **one** question: “Which coin — $t7 or $TEST?”

### 2 — Load open offers

On **`HybridShareMarketplace`** (`0x30cB…`):

1. `nextListingId()` → scan active `getListing(id)` for recent ids (site scans newest ~250 ids).
2. Keep rows where `active == true`, `collection == 0xD8e0639…`, `tokenId` matches step 1.
3. **Sort** (same as site `sortShareOffers`):
   - Primary: **`pricePerUnitWei` ascending** (cheapest first).
   - Tie-break: lower **`listingId`** first.

### 3 — Pick offer + quantity

| User intent | Pick |
|-------------|------|
| cheapest / best price / default | `offers[0]` |
| second cheapest / version 2 / offer 2 | `offers[1]` (if exists) |
| listing # **K** (explicit id) | `getListing(K)` — verify active + token |
| buy **N** shares | `quantity = N` (clamp) |

**Clamp quantity:**

- `quantity <= listing.quantity` (remaining on that offer).
- If `maxPerWallet > 0`: `purchasedByWallet(listingId, buyer) + quantity <= maxPerWallet`.
- `quantity >= 1`.

**Skip** listings where `seller == buyer` (`SellerCannotBuyOwnListing`).

### 4 — Execute buy (Bankr wallet)

```text
HybridShareMarketplace.buy(listingId, quantity)
msg.value = quantity * pricePerUnitWei   # exact — WrongPayment if off
chain: Base (8453)
```

1. Simulate / `eth_call` with buyer account first.
2. User signs via **`bankr.tx.prepare`** / confirm.
3. After mine: ERC-1155 balance on hybrid TMPR increases; confirm on BaseScan.

**User-facing success (example):**  
“Bought **1 share** of **$t7** fee rights for **0.002 ETH** from the cheapest listing. You now hold **1 of 1000** units — claim your fee slice when the pool distributes.”

Link: `https://www.tokenmarketplace.shop/listing/shares/t/{tokenId}`

### 5 — No listings

If **zero** active offers for that `tokenId`:

- Do **not** call `buy` on a random id.
- Say: “No one is selling a **1/1000 share** of **$t7** on the share market right now.”
- Offer: link to share market page, or **create** a group buy / split if they are the seller.

---

## Errors (plain English)

| Revert / issue | Tell user |
|----------------|-----------|
| `WrongPayment` | Exact ETH = **qty × price each**; retry with correct value |
| `MaxPerWalletExceeded` | This listing caps per wallet — lower qty or another wallet |
| `SellerCannotBuyOwnListing` | Pick another offer (not your own) |
| `ListingInactive` / sold out | Refresh order book; try next-cheapest |
| `WrongQuantity` | Ask for fewer shares than remain on that offer |

---

## QA prompts (Bankr test)

```text
Buy the cheapest 1/1000 share of $t7
```

```text
Buy 1 share of t7 at the best price
```

```text
Buy 3 shares from the second cheapest listing for t7
```

**Pass:** resolves hybrid `tokenId`, sorts offers, `buy` with correct `msg.value`, plain-English receipt.  
**Fail:** routes to `FeeRightsFixedSale`, partial sale `contribute`, or asks user for `listingId` / contract addresses.
