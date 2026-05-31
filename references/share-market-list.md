# List 1/1000 shares (hybrid share market) — Bankr agent

Sellers who hold **ERC-1155 units** on hybrid TMPR (`0xD8e0639…`) can list them on **`HybridShareMarketplace`**. This is **not** sell-100% dual list, **not** partial sale pool, **not** OpenSea.

**Autopilot (natural language):** **`share-market-list-autopilot.md`**  
**Buy side:** **`share-market-buy.md`**

---

## What the user means

| User says (examples) | Meaning | You do |
|----------------------|---------|--------|
| **“List my CTO units”** / **“sell 1/1000 shares”** | List ERC-1155 on share market | Resolve `tokenId` → approve → `list` |
| **“List at 0 ETH”** / **“free”** / **“$0”** | **`pricePerUnitWei = 0`** | Valid — buyers pay **0 ETH** (`msg.value = 0`) |
| **“Password protect”** / **“need password to buy”** | Gated listing | **6-arg** `list` with `accessKeyHash` |
| **“1 per wallet”** / **“max 1 per buyer”** | Per-wallet cap | `maxPerWallet = 1` (must be ≤ `quantity`) |
| **“No limit per wallet”** | Anyone can sweep offer | `maxPerWallet = 0` |
| **“List 630 units at 0 with password X”** | One offer, many units | Single `list` tx — qty **630** |
| **“List each unit separately”** | Many single-unit offers | **Multiple** `list` txs (qty **1** each) — only if user explicitly wants separate offers |
| **“First 100 replies get 1 unit free”** | Giveaway-style | List **100** (or N) at **0 ETH**, **`maxPerWallet = 1`**, password in **DM** |

**Do not confuse:**

| Phrase | Wrong flow | Right flow |
|--------|------------|------------|
| List **1/1000 shares** | `POST /api/list/dual` (whole TMPR) | **`HybridShareMarketplace.list`** |
| List **100%** fee rights | Share `list` | **`POST /api/list/dual`** — `listing-channels.md` |
| **Partial sale** 5% | Share market | **GroupBuyEscrowV2** partial |

---

## Contracts (Base mainnet)

| Role | Address |
|------|---------|
| **Hybrid TMPR** (ERC-1155) | `0xD8e0639DfAa1cB2b9f9642EeCbd40b1e5a8b42A7` |
| **HybridShareMarketplace** | `0x90230B59D01c6e0306236eF7afc8105908c4DB0B` |

**No listing API today** for ERC-1155 shares — build calldata on-chain (same as site **List shares** UI).  
**Fixed sale (whole TMPR)** password list: **`POST /api/list/dual`** with optional `"password"` — different product.

**Order book link:** `https://www.tokenmarketplace.shop/listing/shares/t/{hybridTokenId}`

---

## Resolve `tokenId` (mandatory)

Use **`hybrid-id-vocabulary.md`** — **never** `tokenId = serial`.

1. User gives **launch `0x…`** and/or **ticker** ($CTO) and/or **TMPR #N**.
2. Inject **linked seller wallet**.
3. **`GET https://www.tokenmarketplace.shop/api/claim/hybrid-status?token=<launch>&wallet=<linked>`** (add `&serial=N` if user said TMPR #N).
4. Use response **`hybridTokenId`** for `balanceOf` and `list`.
5. Confirm **`unitsHeld > 0`** — else explain they need to **buy** units first (`share-market-buy.md`).

---

## Agent algorithm

### 1 — Parse listing params (defaults)

| Field | Default | Notes |
|-------|---------|-------|
| **quantity** | Ask if unclear; else **1** | ≤ seller `balanceOf` |
| **pricePerUnitWei** | User’s ETH price; **0** if “free” / “0 eth” | `parseEther("0")` → `0n` |
| **maxPerWallet** | **0** (no cap) unless user sets cap | **0 = unlimited**; for giveaways use **1** |
| **password** | None unless user gives one | **DM preferred** — never echo in public tweet reply |

**Giveaway pattern (0 ETH + password + 1 per wallet):**

```text
quantity = N          # e.g. 100 units for 100 winners
pricePerUnitWei = 0
maxPerWallet = 1
password = <from user DM>
```

**One bulk offer (630 units, password, 0 ETH, no per-wallet cap):**

```text
quantity = 630
pricePerUnitWei = 0
maxPerWallet = 0
password = <from user>
```

### 2 — Approve marketplace (once per wallet)

If `isApprovedForAll(seller, marketplace) == false`:

```text
Hybrid TMPR.setApprovalForAll(marketplace, true)
```

Wait for mined receipt before `list`.

### 3 — Build `accessKeyHash` (password listings only)

Trim password once. If non-empty:

```text
accessKeyHash = keccak256(encodePacked(
  password,
  marketplace,      // 0x90230B…
  collection,       // 0xD8e0639…
  tokenId,          // hybridTokenId from API
  seller,           // linked wallet
  pricePerUnitWei,
  maxPerWallet
))
```

If password empty → public listing (5-arg `list` with `maxPerWallet`, or 4-arg if `maxPerWallet = 0`).

### 4 — Submit `list`

**Password-protected (required for gated buys):**

```text
HybridShareMarketplace.list(
  collection,
  tokenId,
  quantity,
  pricePerUnitWei,
  maxPerWallet,
  accessKeyHash
)
# 6 args — selector includes accessKeyHash_
msg.value = 0
chain: Base (8453)
```

**Public with per-wallet cap:**

```text
HybridShareMarketplace.list(collection, tokenId, quantity, pricePerUnitWei, maxPerWallet)
```

**Public, no cap:**

```text
HybridShareMarketplace.list(collection, tokenId, quantity, pricePerUnitWei)
# or 5-arg with maxPerWallet = 0
```

Simulate before submit. After mine:

- Event **`ShareListed`**
- If password: `accessKeyHash(listingId) != 0x000…000` — else **fail** (listed public by mistake; cancel and relist)

### 5 — Reply (plain English)

> “Listed **{qty}** share(s) of **$CTO** at **{price} ETH each** on the Token Marketplace order book.{password note}{max per wallet note} [order book link]”

For **0 ETH**: say **“free — buyers pay 0 ETH”**, not “$0”.

**Do not** tell user to paste contract args, `accessKeyHash`, or `hybridTokenId` unless they ask for technical detail.

---

## Zero-price listings

| Rule | Detail |
|------|--------|
| **Valid** | `pricePerUnitWei == 0` is allowed on-chain and in the site UI |
| **Buyer `msg.value`** | Must be **exactly 0** |
| **Platform fee** | 2% of **0** = **0** — seller receives 0 ETH |
| **Password** | Works at 0 ETH — buyers still need **`access-authorize`** + 4-arg `buy` |

---

## `maxPerWallet` rules

| Value | Behavior |
|-------|----------|
| **0** | No per-wallet limit (buyer can take all remaining qty) |
| **1** | Each wallet may buy **1 unit total** from this listing (cumulative) |
| **N** | Cumulative cap per wallet |
| **Constraint** | `maxPerWallet <= quantity` or tx reverts **`InvalidMaxPerWallet`** |

**Site suggestions** when listing many shares: qty ≥100 → suggest cap **1**; qty ≥20 → **5**; etc. (`shareMarketplaceLimits.ts`).

---

## Password listings — seller vs buyer

| Role | Action |
|------|--------|
| **Seller (this file)** | 6-arg `list` + `accessKeyHash` at list time |
| **Buyer** | `POST /api/listings/access-authorize` → 4-arg `buy` — **`share-market-buy.md`** |

Password is **not** a full-page website gate — buyers enter it on the **order book row**.

**Never** post the password in a public @bankrbot reply.

---

## Cancel / update

- **Cancel unsold listing:** `HybridShareMarketplace.cancel(listingId)` — returns unsold units to seller.
- **Change price/password:** cancel + create new listing (terms are fixed at list time).

---

## POST-TX verification (PASS vs FAIL)

| PASS | FAIL |
|------|------|
| **`ShareListed`** event on `0x90230B…` | No listing event |
| Seller balance of `tokenId` decreased by `quantity` | Wrong collection / wrong `tokenId` |
| Password listing: `accessKeyHash(id) != 0` | Password requested but hash is zero (public list) |
| Used **6-arg** `list` when password required | 5-arg public `list` on gated intent |

---

## Bankr runtime note

Listing requires **contract write tools** (`setApprovalForAll`, `list`) on Base — same class of runtime requirement as hybrid fee claim. If agent says “I can read the skill but can’t submit txs”, that is a **tool binding** issue, not missing skill text.

**Tweet intake:** auto-load **`bankr-fee-rights`** on “list shares / sell units” TRIGGER — see **`BANKR-PLATFORM-TWEET-INTAKE.md`**.

---

## Errors (plain English)

| Revert | Tell user |
|--------|-----------|
| `ERC1155: insufficient balance` | Lower quantity or wrong wallet |
| `not owner nor approved` | Run approval tx first |
| `InvalidMaxPerWallet` | Cap cannot exceed listed quantity |
| `ZeroAmount` | Quantity must be ≥ 1 |
| Listed public but wanted password | Cancel listing; re-enter password; confirm **6-arg** tx in wallet |

---

## QA prompts

```text
List 10 CTO shares at 0 ETH with password secret, max 1 per wallet
```

```text
Using the tmp skill list 5 units of 0xb6fB… at 0.001 ETH each
```

**Pass:** hybrid-status → approve if needed → correct `list` args → `ShareListed` → order book link.  
**Fail:** routes to dual list · uses serial as tokenId · 5-arg list when password required · asks user for marketplace address.

---

## Cross-links

- **`share-market-list-autopilot.md`** — tweet/DM autopilot
- **`share-market-buy.md`** — password buy path
- **`hybrid-id-vocabulary.md`** — `hybridTokenId` vs serial
- **`listing-channels.md`** — share vs 100% vs partial
- **`reply-drop.md`** — reply-winner campaigns (design; marketplace gated list is live workaround)
