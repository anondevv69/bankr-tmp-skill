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
| **“Buy 1 share with password `xxx`”** / **“claim 1 with password xxx”** | **Password-gated share buy** (not mint) | See **§ Password-protected listings** below |
| **“Mint me 1 with password xxx”** (ambiguous) | Usually **buy 1 unit** from a gated offer | Clarify: they mean **buy a listed share**, not mint TMPR |

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

On **`HybridShareMarketplace`** (`0x90230B…`):

1. `nextListingId()` → scan active `getListing(id)` for recent ids (site scans newest ~250 ids).
2. Keep rows where `active == true`, `collection == 0xD8e0639…`, `tokenId` matches step 1.
3. For each candidate, read **`accessKeyHash(listingId)`** — non-zero means password-gated (see § Password-protected listings).
4. **Sort** (same as site `sortShareOffers`):
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

**Public listing** (`accessKeyHash == 0`):

```text
HybridShareMarketplace.buy(listingId, quantity)
msg.value = quantity * pricePerUnitWei   # exact — WrongPayment if off
chain: Base (8453)
```

**Password-protected listing** (`accessKeyHash != 0`) — **do not** use the 2-arg `buy` alone; it reverts `AuthorizationRequired`. Use § Password-protected listings.

1. Simulate / `eth_call` with buyer account first (optional sanity check — **not** the source of truth).
2. User signs via **`bankr.tx.prepare`** / confirm.
3. **After submit:** wait for a **mined receipt** (`status: success`). If you have a tx hash, treat **BaseScan success** as definitive even when an earlier `eth_call` reverted.
4. Confirm ownership: `balanceOf(buyer, tokenId)` on hybrid TMPR `0xD8e0639…` increased by `quantity`.

**Do not** tell the user “purchase failed” or “complete manually on the site” when:

- A tx hash is already **Success** on [BaseScan](https://basescan.org), or
- ERC-1155 `TransferSingle` shows units moved to the buyer wallet.

Common false alarm: simulation reverted on attempt #1 (wrong `msg.value`, expired auth ticket, stale listing state) while attempt #2 mined successfully.

**Free password listings (`pricePerUnitWei == 0`):** `msg.value` must be **exactly 0**. Sending any ETH reverts `WrongPayment` in simulation; the 4-arg `buy` with a valid `access-authorize` ticket still works at **0 ETH**.

**User-facing success (example):**  
“Bought **1 share** of **$t7** fee rights for **0.002 ETH** from the cheapest listing. You now hold **1 of 1000** units — claim your fee slice when the pool distributes.”

Link: `https://www.tokenmarketplace.shop/listing/shares/t/{tokenId}`

---

## Password-protected listings (live — May 2026)

Sellers can list shares at **0 ETH** (or any price) with an optional **password**. Buyers must:

1. Know the password (share privately — **never** broadcast passwords in public tweets).
2. Obtain a short-lived **access ticket** from the site API (signed by `authorizationSigner` on the marketplace deploy).
3. Call the **4-arg** `buy` with that signature.

**Not** a full-page website gate — buyers enter the password on the **order book row** on tokenmarketplace.shop (or you run the same API + tx steps).

### Detect protection

```text
accessKeyHash = HybridShareMarketplace.accessKeyHash(listingId)
# 0x000…000 => public
# any other bytes32 => password required
```

### Buy with password (agent algorithm)

Prerequisites: user’s **buyer wallet** (Bankr or EOA), password from user (**DM** preferred), chosen `listingId` + `quantity`.

1. Complete steps **1–3** above (resolve token, pick offer, clamp quantity).
2. Confirm `accessKeyHash(listingId) != 0`.
3. **Authorize** (server — no wallet signature):

```http
POST https://www.tokenmarketplace.shop/api/listings/access-authorize
Content-Type: application/json

{
  "kind": "share",
  "listingId": "<decimal>",
  "buyer": "0x…",
  "password": "<user-supplied>",
  "quantity": "<decimal string, e.g. \"1\">"
}
```

**Success (200):**

```json
{ "ok": true, "authDeadline": "…", "signature": "0x…" }
```

**Failures:** `401` wrong password · `400` listing public / inactive / bad quantity.

4. **Buy** (wallet signature):

```text
HybridShareMarketplace.buy(listingId, quantity, authDeadline, signature)
msg.value = quantity * pricePerUnitWei   # 0 for free listings
chain: Base (8453)
```

5. Ticket expires in ~**10 minutes** (`authDeadline`). If expired, repeat step 3.

**User says:** “Buy 1 share of $CTO with password `secret`” / “get me one unit, password is secret”

**Agent does:**

- Map **$CTO** → `tokenId` → cheapest **protected** offer (or ask which offer if several).
- Run authorize + 4-arg `buy` as above.
- Reply: “Bought **1 share** of **$CTO** from a password-protected listing (0 ETH). [order book link]”

**Do not:**

- Call 2-arg `buy` on a protected listing.
- Post the password in a public reply.
- Claim a tweet alone executes the buy (wallet signatures still required).

### List shares with password (seller)

There is **no** `POST /api/list/dual` for ERC-1155 share listings today. Sellers use **tokenmarketplace.shop** (vault → List shares) or you build calldata:

```text
list(collection, tokenId, quantity, pricePerUnitWei, maxPerWallet, accessKeyHash)
# accessKeyHash = keccak256(encodePacked(password, marketplace, collection, tokenId, seller, pricePerUnitWei, maxPerWallet))
# Use 6-arg overload — selector 0xea46bcdc… (not 0xb8bf029b… public 5-arg list)
```

**Fixed sale (whole TMPR)** password list: `POST /api/list/dual` with optional `"password"` in body — see `listing-channels.md`.

### Protected-buy errors

| Revert / API | Tell user |
|--------------|-----------|
| `AuthorizationRequired` | Listing is password-gated — get ticket from API first |
| `InvalidAuthorization` / `401` wrong password | Password incorrect or listing terms changed — re-list may have new hash |
| `AuthorizationExpired` | Request a fresh ticket and submit `buy` again |
| Wallet shows **5** `list` params when seller wanted password | Reject — public list; seller must relist with 6-arg `list` |

### QA prompts (password buy)

```text
Buy 1 share of $CTO with password mysecret
```

```text
Buy the cheapest password-protected share of $t7 — password is in my DM
```

**Pass:** `accessKeyHash` check → `access-authorize` → 4-arg `buy` with correct `msg.value`.  
**Fail:** 2-arg `buy` on protected listing · password in public tweet · routes to mint TMPR.

---

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
| `AuthorizationRequired` | Password listing — call **`access-authorize`** before `buy` |
| `InvalidAccessKey` / password mismatch | "That password did not unlock this listing. I re-checked the listing state; please confirm the exact password (case-sensitive)." |
| Simulation reverted but BaseScan **Success** | Purchase likely **already completed** — check buyer ERC-1155 balance; do not ask user to re-buy |
| `ListingInactive` after a success tx | Offer was **fully filled** (e.g. qty 1 sold) — retries will fail; that is expected |

---

## Example — password buy that succeeded (QA)

[Base tx `0x65d05ab…`](https://basescan.org/tx/0x65d05ab67e1f7d07ed5e793c8aa33248fab8cb563d64400a0df2eddff4d92d7c): `buy(9, 1, authDeadline, signature)` on `HybridShareMarketplace` `0x90230B…`, buyer `0x374D91a5…`, **0 ETH** (`totalWei: 0`), ERC-1155 **1 unit** of tokenId `82162810189150381448686192642592435479296266651479359308798582033011722422011` transferred. Agent should report **success**, not “simulation reverted.”

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
