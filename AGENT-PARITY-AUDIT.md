# Token Marketplace — Full Agent ↔ Human Parity + Response Templates

**Purpose:** Every user intent matches a website flow. Agents execute **identical APIs** + **identical payments**. This doc ensures complete routing, missing response templates, and agent-known-what-to-say.

---

## 1. LAUNCH — Deploy new token + 1000 units

### Human flow (website)

**Path:** `/launch` form → select Base or Solana → fill name, symbol, split → **connect wallet → site x402** → pays ~$1 USDC → **poll until done** → **3-part reply** (token, txs, next steps)

### Agent flow (no browser)

**Path:** Parse intent → JSON body → **sign same site x402** → POST → **202 + jobId** → **poll** (you must do this) → same 3-part reply

### User phrases (agent must handle without asking)

| You say | Agent infers | API |
|---------|--------------|-----|
| **Deploy X on tokenmarketplace via Bankr** (nothing else) | New token, **all 1000 units to your wallet** | `POST /api/launch/concierge/run` (Base) |
| **Deploy X via pumpfun** (nothing else) | Solana Pump, **all 1000 SPL units** | `POST /api/launch/concierge/solana/run` |
| **Deploy X, split 100 / 900 to wallet A / B** | Wallet split at deploy | `wallet_list` summing 1000 |

### Agent algorithm

1. **Parse intent** → extract `tokenName`, `tokenSymbol`, `splitPlan` (`keep_all` or `wallet_list`), delivery wallet(s)
2. **`GET /api/launch/concierge/config`** → read `x402` (price, network, treasury), `statusUrl` pattern
3. **POST body** (identical to website):
   ```json
   {
     "tokenName": "My Token",
     "tokenSymbol": "MYTKN",
     "splitPlan": "keep_all",
     "deliveryAddress": "0x… or base58 pubkey"
   }
   ```
4. **First POST** → **402** (x402 requirements) → **sign USDC** with **user's Bankr wallet** (custodial address counts)
5. **Second POST** → same body + `PAYMENT-SIGNATURE` header → **202** + `{ jobId, statusUrl }`
6. **Poll** `GET statusUrl` every **15–30s** until `status: "completed"` (not `queued` or `running`)
7. **3-part reply** (see below)

### Agent response template (success)

**Must include all three parts or reply is incomplete.**

```text
🚀 **Deployed $MYTKN successfully!**

**Deployment info:**
• Token: $MYTKN
• Token contract: [TOKEN_ADDRESS](https://basescan.io/address/[TOKEN_ADDRESS])
• 1000 fee-right units delivered to: [WALLET]
• Fee-rights receipt (TMPR): Serial #[SERIAL] (ERC-721)
• Job ID: [JOBID]

**Transactions:**
• [Deploy token](https://basescan.io/tx/[HASH])
• [Mint fee-rights receipt](https://basescan.io/tx/[HASH])
• [Split into 1000 units](https://basescan.io/tx/[HASH])
• [Deliver units to your wallet](https://basescan.io/tx/[HASH])

**Your units on Token Marketplace:**
→ https://www.tokenmarketplace.shop/profile?tab=nfts

**What would you like to do next?**
• **List** your fee rights — e.g. "List $MYTKN for 0.01 ETH" (sell on Token Marketplace + OpenSea)
• **List units** on the share market — e.g. "List 100 units of $MYTKN at 0.0001 ETH each"
• **Send / gift units** — e.g. "Send 50 units to 0x…"
• **Claim fees** later — e.g. "Claim fees for $MYTKN" when trading fees accrue
```

**Solana variant:**

```text
Token mint: [MINT_ADDRESS] on Solana
→ Pump.fun: [LINK]
→ Your units profile: https://www.tokenmarketplace.shop/profile?tab=pump
```

**Errors agent must know:**

| Response status | Agent reply |
|---|---|
| `status: "completed"`, `result.ok: false` | ❌ Deploy failed during pipeline. Reason: `result.error`. **Contact support** with job ID `[JOBID]` |
| `status: "failed"` | Same — pipeline execution failed |
| User didn't get **202 + jobId** after pay | ❌ Payment may not have confirmed. Check x402 receipt; if USDC moved, try polling `GET [statusUrl]` again |

---

## 2. SELL fee rights (100% fixed sale on Base)

### Human flow

**Website:** Profile → [token card] → **List** → fill 0.01 ETH → site x402 appears? → pay (or **no x402 today**; seller signs ETH txs) → **execute** `approve` + `list` on chain → shop URL

**Reality today:** No x402 for sell; user **signs Base ETH txs** (`approve`, `list` calldata).

### Agent flow (today)

1. **`GET /api/mint/status`** — resolve token, check if ready to list
2. **`POST /api/list/dual`** — get site + OpenSea calldata
3. **Execute** `approve` on TMPR, then `list` on `FeeRightsFixedSale`
4. **Verify** `GET /api/list/status?listingId=`
5. **Reply** with shop URL + OpenSea link (if dual)

### User phrases

| You say | Agent infers | Default |
|---------|--------------|---------|
| **Sell rights of X for 0.01 ETH** | 100% fixed sale | **Dual** (site + OpenSea) |
| **List X for 0.01 ETH on site only** | Fixed sale, no OpenSea | Site only |
| **List my units at 0 ETH** | ERC-1155 share market (1/1000) | Not this flow — use `share-market-list` |

### Agent algorithm

1. **Parse intent** → token ticker/address, price in ETH
2. **`GET /api/mint/status?tokens=[token]&wallet=[seller]`**
   - If `phase !== "ready"` → execute `nextStep` txs first (this conversation)
   - If `phase === "ready"` → proceed to list
3. **`POST /api/list/dual`** body:
   ```json
   {
     "tokenId": "[from mint/status]",
     "priceEth": "0.01",
     "seller": "[seller wallet]"
   }
   ```
4. **Execute `site.steps`** → `approve` + `list` on chain
5. **`GET /api/list/status?listingId=[from response]`** until `listedOnSite: true`
6. **If dual:** load **`opensea-marketplace`** skill to complete Seaport leg
7. **Reply** (see below)

### Agent response template (success)

```text
✅ Listed $MYTKN fee rights for 0.01 ETH

**Listing info:**
• Token: $MYTKN
• Price: **0.01 ETH**
• Your wallet (fee recipient): [SELLER]
• Fee-rights receipt (TMPR): Serial #[SERIAL]

**Transactions:**
• [Approve TMPR](https://basescan.io/tx/[HASH])
• [List on Token Marketplace](https://basescan.io/tx/[HASH])

**Shop link:**
→ https://www.tokenmarketplace.shop/listing/sale/[LISTING_ID]

**OpenSea link:**
→ https://opensea.io/assets/base/[COLLECTION]/[TOKEN_ID]

**What would you like next?**
• **Cancel** this listing
• **Update price** — relist at a different price
• **List units** on the share market if you split later
• View your [listing on the profile](https://www.tokenmarketplace.shop/profile?tab=nfts)
```

**Errors agent must know:**

| Issue | Agent reply |
|---|---|
| `phase !== "ready"` (mint incomplete) | ⚠️ Your fee rights aren't ready yet — finishing mint steps first (this conversation). Then listing. |
| `approve` blocked by Bankr custodial signer | 🔒 Bankr is blocking the `approve` tx (new contract safety check). **Retry** — if persists, use [Launch Studio](https://www.tokenmarketplace.shop/launch) browser link |
| `listedOnSite: false` after tx | ❌ Listing txs executed but site backend lag. Wait 30s and check shop link again. |

---

## 3. BUY fee rights (100% fixed sale on Base)

### Human flow

**Website:** `/listing/sale/[id]` → **Buy** → confirm ETH amount → **sign** → tx → "Purchased"

### Agent flow

1. **`GET /api/list/buy-status?url=[listing_url]`** or `?listingId=[id]`
2. Check `canBuy: true`, read `priceWei`, `nextStep`
3. **If password-protected:** `POST /api/listings/access-authorize` first
4. **Execute** `nextStep` (FeeRightsFixedSale.buy) → `msg.value = priceWei`
5. **Verify** buyer owns NFT: `ownerOf(tokenId)` on collection
6. **Reply** (see below)

### User phrases

| You say | Agent infers | API |
|---------|--------------|-----|
| **Buy https://www.tokenmarketplace.shop/listing/sale/27** | Buy listing 27 | `buy-status?url=` |
| **Buy listing 27** | Same | `buy-status?listingId=27` |
| **Buy the full fee rights** + URL | Same | |

### Agent response template (success)

```text
✅ Purchased $MYTKN fee rights for 0.01 ETH

**Purchase info:**
• Token: $MYTKN
• Price: **0.01 ETH**
• Seller: [SELLER]
• Your wallet: [BUYER]

**Transaction:**
• [Buy on marketplace](https://basescan.io/tx/[HASH])

**Your receipt (TMPR) is now on your wallet:**
→ https://basescan.io/address/[BUYER]?token=[TMPR_COLLECTION]

**What would you like next?**
• **List it** for a higher price — e.g. "List for 0.02 ETH"
• **Split into 1000 units** — e.g. "Fractionalize $MYTKN"
• **Send** to another wallet — e.g. "Send to 0x…"
• **Claim fees** when trading fees accrue — e.g. "Claim fees for $MYTKN"
• **Sell it again** — e.g. "List for 0.015 ETH"
```

**Errors agent must know:**

| Issue | Agent reply |
|---|---|
| `canBuy: false` | ❌ Listing is inactive, already sold, or cancelled. Try another [listing on the shop](https://www.tokenmarketplace.shop/profile) |
| `WrongPayment` | ❌ Exact ETH amount required: **0.01 ETH exactly**. Retry with correct value. |
| `passwordProtected: true` | 🔐 This listing is password-protected. Provide the password to unlock it. |

---

## 4. BUY shares (ERC-1155 units from share market)

### Human flow

**Website:** Token profile → **Share market** tab → sort by price → **Buy 1** at cheapest → **sign** → received 1/1000 unit

### Agent flow

1. **Resolve token** → get `hybridTokenId` from mint/status or ticker
2. **`GET /api/share/list-status?wallet=&hybridTokenId=[id]`** → sort `offers[]` by price
3. Pick cheapest (rank #1) or user's specified rank
4. **If password:** `POST /api/listings/access-authorize`
5. **Execute** `HybridShareMarketplace.buy(listingId, quantity)` → `msg.value = qty × pricePerUnitWei`
6. **Verify** buyer balance increased: `balanceOf(buyer, tokenId)` on hybrid TMPR
7. **Reply** (see below)

### User phrases

| You say | Agent infers | Qty | Default |
|---------|--------------|-----|---------|
| **Buy the cheapest share of $t7** | Buy 1 share | 1 | Rank #1 offer |
| **Buy 5 shares at best price** | Buy 5 units | 5 | Rank #1 offer |
| **Buy version 2** | 2nd-cheapest offer | User's qty or 1 | Rank #2 |
| **Buy 1 share with password X** | Gated buy | 1 | Rank #1 |

### Agent response template (success)

```text
✅ Bought 1 share of $t7 fee rights

**Purchase info:**
• Token: $t7
• Shares: **1 / 1000** (~0.001%)
• Price: **0.00001 ETH per unit**
• Your wallet: [BUYER]

**Transaction:**
• [Buy on hybrid marketplace](https://basescan.io/tx/[HASH])

**Your units:**
→ https://www.tokenmarketplace.shop/profile?tab=nfts (see **Your holdings**)

**What would you like next?**
• **Buy more** — "Buy 5 more shares at best price"
• **List these** for sale — e.g. "List my 1 unit for 0.00002 ETH"
• **Send** to another wallet — e.g. "Send my unit to 0x…"
• **Claim fees** from this share — e.g. "Claim fees for $t7"
```

---

## 5. LIST shares (ERC-1155 on share market)

### Human flow

**Website:** Profile → [token card] → **List units** → qty, price, password (optional), max per wallet → **sign** 6-arg `list` → active on order book

### Agent flow

1. **`GET /api/claim/hybrid-status?token=[token]&wallet=[seller]&serial=`**
   - Check `unitsFinalized: true`
   - Read seller's unit balance
2. **Parse intent** → quantity, price, optional password, optional max per wallet
3. **Build calldata** → `list(collection, tokenId, quantity, pricePerUnitWei, maxPerWallet, [accessKeyHash if password])`
4. **Execute** `approve(marketplace, quantity)` then `list` on `HybridShareMarketplace`
5. **Verify** listing active: `getListing(id)` on marketplace
6. **Reply** (see below)

### User phrases

| You say | Agent infers |
|---------|--------------|
| **List 100 units of $t7 at 0.0001 ETH each** | Qty 100, price per unit 0.0001 |
| **List my units with password "SECRET"** | Default qty (all held), price (ask), gated |
| **List 1 unit each to max 5 per wallet** | Qty + maxPerWallet cap |
| **List for free** | Price = 0 (airdrop / free share) |

### Agent response template (success)

```text
✅ Listed 100 units of $t7 on the share market

**Listing info:**
• Token: $t7
• Units: **100 / 1000**
• Price per unit: **0.0001 ETH**
• Max per wallet: Unlimited
• Password: None (public)

**Transaction:**
• [List on hybrid marketplace](https://basescan.io/tx/[HASH])

**Share market link:**
→ https://www.tokenmarketplace.shop/listing/shares/t/[HYBRID_TOKEN_ID]

**What would you like next?**
• **Update price** — relist at a new price
• **Add more** — list additional units
• **Cancel** — delist remaining units
• **Monitor** — track who's buying your units on [profile](https://www.tokenmarketplace.shop/profile?tab=nfts)
```

---

## 6. REDEEM fee rights (burn TMPR, get beneficiary back)

### Human flow

**Website:** Profile → OpenSea TMPR → click **Redeem** (if site UI has it, or manual tx) → `redeemRights(tokenId)` on correct escrow → NFT burns, fee-admin back to your wallet

### Agent flow

1. **Resolve tokenId** from TMPR serial, OpenSea link, or ticker
2. **`GET /api/mint/status?tokens=[token]&wallet=[user]`**
   - Read `nextStep.tmprTokenId` (on-chain uint256)
   - Read escrow address from `nextStep.to` or use canonical `BankrEscrowV3` `0x6238…`
3. **Pre-flight:** `eth_call redeemRights(tokenId)` from user's wallet → must succeed
4. **Execute** `redeemRights(tokenId)` on escrow → **from NFT owner wallet only**
5. **Verify** TMPR burned: `ownerOf(tokenId)` reverts `TokenNotFound`
6. **Reply** (see below)

### User phrases

| You say | Agent infers |
|---------|--------------|
| **Redeem this token** (hold TMPR) | Burn TMPR, restore fee beneficiary |
| **Get fee rights back** | Same |
| **Return 0xcd6634… to my wallet** | **Trap:** this is TMPR collection, not token. Ask for tokenId (serial). |
| **Burn the NFT and get my rights back** | Same as redeem |

### Agent response template (success)

```text
✅ Redeemed fee rights for $MYTKN

**Redemption info:**
• TMPR (receipt): **Burned** (#Serial)
• Fee beneficiary: **Restored to your wallet**
• Token: $MYTKN
• Pool: [POOL_ID]

**Transaction:**
• [Redeem fee rights](https://basescan.io/tx/[HASH])

**Fee status on Doppler:**
→ https://app.doppler.lol/tokens/base/[TOKEN_ADDRESS]

**What does this mean?**
Your wallet is now the official **fee recipient** for **all trading fees** on $MYTKN (instead of the escrow holding them for the TMPR buyer). You can claim fees directly from Doppler or this marketplace.

**What's next?**
• **Claim fees** when they accrue — e.g. "Claim fees for $MYTKN"
• **Re-list** fee rights if you want to sell again
```

**Errors agent must know:**

| Revert | Agent reply |
|---|---|
| `UnauthorizedCaller` | ❌ You don't own this TMPR. Check that you're signing from the wallet listed on OpenSea. |
| `RightsNotEscrowed` | ❌ Fee rights were already redeemed or released. Check on [Doppler](https://app.doppler.lol/) if you're already the fee recipient. |

---

## 7. CLAIM fees (distribute to all unit holders)

### Human flow

**Website:** Token profile (after split into 1000) → **Claim** tab → **Claim for all holders** → `claimFeesForToken` on router → ETH paid to each unit holder pro-rata

### Agent flow

1. **`GET /api/claim/hybrid-status?token=[token]&wallet=[user]`**
   - Read `canClaimForToken: true`
   - Read `holders[]` (cap table)
   - Read claim router contract + calldata hints
2. **Execute** `claimFeesForToken([tokenId])` on `HybridClaimRouter` → gas paid by caller
3. **Monitor** claim completion (1–3 min for many holders)
4. **Reply** (see below)

### User phrases

| You say | Agent infers |
|---------|--------------|
| **Claim fees for $MYTKN for all holders** | Distribute to every unit holder |
| **Claim fees for $MYTKN** (nothing extra) | **Default:** all holders |
| **Claim my unit fees** | Same |

### Agent response template (success)

```text
✅ Claimed fees for $MYTKN — distributed to all unit holders

**Claim info:**
• Token: $MYTKN
• Total holders: **114**
• Fee pool (ETH): **0.456 ETH**
• Distributed: **All 1000 units pro-rata**

**Transaction:**
• [Claim for all holders](https://basescan.io/tx/[HASH])

**Cap table (who got what):**
→ https://www.tokenmarketplace.shop/profile?tab=nfts (see **Claim history**)

**What's next?**
• **View accrued fees** — visit your [profile](https://www.tokenmarketplace.shop/profile?tab=nfts)
• **Claim again** — more fees may have accrued
```

**Errors agent must know:**

| Issue | Agent reply |
|---|---|
| `canClaimForToken: false` | ❌ No fees to claim yet, or token not split. Wait for trading fees to accrue, then try again. |
| User says "claim for just me" | ⚠️ On hybrid units, there's **no** self-claim; claiming distributes to **all 1000 units** proportionally. That's the design — fees pool for everyone. |
| `claimtokenfees` route | ❌ **Don't** route to Bankr `claimtokenfees`; use hybrid-claim router. These are different products. |

---

## 8. SEND / GIFT / AIRDROP units (ERC-1155 transfer)

### Human flow

**Website:** Profile → [token card] → **Send shares** → qty, recipient(s) → **sign** `safeTransferFrom` or batch → units moved

### Agent flow

1. **Resolve token** → get `hybridTokenId`
2. **`GET /api/claim/hybrid-status?token=[token]&wallet=[sender]`**
   - Read sender's balance
   - Check `unitsFinalized: true`
3. **Parse recipients** → list of (wallet, qty) pairs; sum them (≤ sender balance)
4. **Execute** `safeTransferFrom(sender, recipient, tokenId, qty, data)` for each recipient
   - Or batch if contract supports `safeBatchTransferFrom`
5. **Verify** recipient balances increased
6. **Reply** (see below)

### User phrases

| You say | Agent infers |
|---------|--------------|
| **Send 50 units of $t7 to 0xABC…** | Single recipient, qty 50 |
| **Airdrop 10 units to each: 0x… 0x… 0x…** | Batch, 10 per recipient |
| **Split my 100 units equally to 4 wallets** | Divide: 25 each |
| **Send remaining units to 0x…** | Send all held (resolve from balance) |

### Agent response template (success)

```text
✅ Sent 50 units of $t7 fee rights

**Transfer info:**
• Token: $t7
• Units: **50 / 1000**
• From: [SENDER]
• To: [RECIPIENT]

**Transaction:**
• [Transfer on hybrid TMPR](https://basescan.io/tx/[HASH])

**Recipient now holds:**
→ 50 / 1000 units of $t7 fee rights

**What's next?**
• **Send more** — e.g. "Send 30 more units to 0x…"
• **List remaining** — e.g. "List my 50 units for sale"
• **Gift to multiple** — e.g. "Airdrop 10 units each to 0x… 0x…"
```

---

## 9. SELL on Solana (0.01 SOL share listing)

### Human flow

**Website (Solana tab):** Token page → **List at 0.01 SOL** → seller signs → live on `/listing/sol/[pubkey]`

### Agent flow

1. **Resolve Solana token mint** from ticker or address
2. **`GET /api/solana/claim-status?listing=[listing_pubkey]`** (if exists) or create new listing
3. **`POST /api/solana/list`** (if exists) body:
   ```json
   {
     "tokenMint": "[mint]",
     "priceSol": 0.01,
     "seller": "[seller pubkey]"
   }
   ```
   **Note:** This endpoint may not be fully documented; mirror Base `list/dual` shape
4. **Sign with Solana key** (user's SPL wallet)
5. **Monitor** listing active on-chain
6. **Reply** (see below)

### User phrases

| You say | Agent infers | Chain |
|---------|--------------|-------|
| **Sell rights of X for 0.01 SOL** | 0.01 SOL raise/listing | **Solana** |
| **Deploy X via pumpfun, list for 0.1 SOL** | Pump deploy + immediate pricing | **Solana** |

### Agent response template (success)

```text
✅ Listed $SOLTKN fee rights for 0.01 SOL

**Listing info:**
• Token: $SOLTKN
• Price: **0.01 SOL per share**
• Your wallet: [SELLER]
• Listing pubkey: [LISTING_PUBKEY]

**Share link:**
→ https://www.tokenmarketplace.shop/listing/sol/[LISTING_PUBKEY]

**What would you like next?**
• **Update price** — e.g. "List for 0.02 SOL"
• **Cancel** listing
• **Monitor** sales on your [profile](https://www.tokenmarketplace.shop/profile?tab=pump)
```

**Note:** Solana listing agent APIs are **weaker than Base** today. If Solana endpoints missing, provide browser link as fallback.

---

## 10. FRACTIONALIZE / SPLIT into 1000 (post-launch)

### Human flow

**Website:** Profile → [token card] → **Split into 1000** → self-split finalize → 1000 ERC-1155 units minted

### Agent flow

1. **`GET /api/mint/status?tokens=[token]&wallet=[user]`**
   - Check `phase === "ready"` (NFT already minted)
   - Read next `step.functionName === "finalize"` or similar
2. **Execute** finalize on `GroupBuyEscrowV6` or self-split logic
3. **Verify** `unitsFinalized(tokenId) === true` on hybrid TMPR
4. **Reply** (see below)

### User phrases

| You say | Agent infers |
|---------|--------------|
| **Split $MYTKN into 1000 units** | Self-split finalize |
| **Fractionalize $MYTKN** | Same |
| **Keep all 1000 units** (post-deploy) | Same (units created at deploy already) |

### Agent response template (success)

```text
✅ Split $MYTKN into 1000 tradeable units

**Split info:**
• Token: $MYTKN
• Units created: **1000 / 1000**
• Your holdings: **1000 units**
• TMPR receipt: Serial #[SERIAL]

**Transaction:**
• [Finalize split](https://basescan.io/tx/[HASH])

**Share market:**
→ https://www.tokenmarketplace.shop/listing/shares/t/[HYBRID_TOKEN_ID]

**What would you like next?**
• **List units** — e.g. "List 100 units for 0.0001 ETH each"
• **Send units** — e.g. "Send 50 units to 0x…"
• **Keep all** — hold all 1000 units
```

---

## Summary: Agent ↔ Human parity

| Action | Human (website) | Agent (API) | **Key difference** |
|--------|---|---|---|
| **Deploy** | Form + x402 + poll | JSON + x402 + **agent polls** | Agent must poll (UI does auto) |
| **Sell 100%** | List form → ETH txs | mint/status → list/dual → ETH txs | Same ETH cost; no x402 today |
| **Buy whole** | buy-status → ETH tx | buy-status → ETH tx | Identical |
| **Buy shares** | Share market UI → qty/price → tx | share list-status → sort → tx | Identical |
| **List shares** | Send shares UI → recipients → batch tx | hybrid-status → qty/recipients → batch tx | Identical |
| **Redeem** | Profile → Redeem button → tx | mint/status → redeemRights → tx | Same tx; agent must know right escrow |
| **Claim** | Claim button → router tx | claim/hybrid-status → claimFeesForToken → tx | **No self-claim** on hybrid (all holders) |
| **Send units** | Send shares → batch tx | hybrid-status → safeTransferFrom → tx | Identical |
| **Solana sell** | Pump tab → price → tx | TBD API → tx | **Weaker agent API vs Base** |

**Pattern:** Except launch (agent must poll) and Solana (incomplete APIs), **agent code ≈ remove UI layer + call APIs + sign txs**.

---

## Critical guardrails (agent must enforce)

1. **Never say "paid"** without `202 + jobId` (launch) or `listedOnSite: true` (list)
2. **Always poll after x402** — do not stop at 402 or 202; full job completion required
3. **Never route `claim` to Bankr `claimtokenfees`** — hybrid claims are different
4. **Never ask "site or OpenSea?" for sell** — default is dual; only ask if user explicitly said one venue
5. **Never ask "1000 units?" or "keep_all?" on deploy** — always default all 1000 unless split specified
6. **All responses must include shop URLs** (not bare tx hashes)
7. **Always offer next steps** — user shouldn't guess what to do after an action completes

---

## Response checklist

After every action, agent reply must have:

- ✅ **Action verb + confirmation** — "✅ Deployed", "✅ Listed", etc.
- ✅ **Info summary** — token name, amount, price (if applicable), wallet/recipient
- ✅ **Transaction link(s)** — explorer URL (BaseScan / Solscan), not bare hash
- ✅ **Shop/profile link** — https://www.tokenmarketplace.shop/… full URL
- ✅ **Next steps** (1–4 plain-English options) — user should never ask "what now?"
- ✅ **No jargon** — no `poolId`, `redeemRights` function names, `sellerKeepsBps`; use plain English

**If missing any of these, reply is incomplete and agent should revise.**

---

## Known gaps / limitations (agent should warn if hit)

| Gap | Workaround |
|---|---|
| **Solana sell API incomplete** | Provide browser Launch Studio link + explain "Solana listing may require manual browser step" |
| **List concierge (x402 for sell)** not deployed | Explain "Seller signs ETH gas only; no x402 fee for listing yet" |
| **Bankr Solana x402 unreliable** | If Bankr can't sign Solana x402, fall back to "here's the Launch Studio link; connect Solana wallet in browser" |
| **Approve blocked by Bankr custodial** | Retry; if persists, "Contract too new for Bankr signer safety check; use browser UI or wait for safety score to update" |
| **Batch-send units API/contract** | If no batch support, send 1-by-1 with separate tx per recipient (slower) |

---

## Install / verify

Agents loading this file should:

1. **Load launch file** → `tmp-launch-studio/launch-studio-agent-autopilot.md` (deploy + x402 + poll)
2. **Load sell file** → `sell-list-autopilot.md` (mint/status → list/dual)
3. **Load buy files** → `buy-fixed-sale-autopilot.md`, `share-market-buy.md`
4. **Load claim file** → `hybrid-claim-autopilot.md` (all holders)
5. **Load redeem file** → `redeem-rights-playbook.md`
6. **Load send file** → `transfer-units-autopilot.md`
7. **For Solana:** `tmp-solana-cto/solana-buy-autopilot.md`, `solana-claim-autopilot.md`

Then consult this summary + templates for routing + response format.

