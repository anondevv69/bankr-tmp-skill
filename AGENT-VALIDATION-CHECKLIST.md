# Agent Parity Validation Checklist — Verify all flows work end-to-end

**Run this after updating any API, contract, or skill.** Every flow must match the website behavior AND respond with correct agent format.

---

## ✅ Launch (Deploy new token + 1000 units)

### Base (Bankr)

- [ ] User says "Deploy X on Bankr" → agent infers `keep_all`, all 1000 to linked EVM wallet
- [ ] User says "Deploy X split 100/900 to A / B" → agent builds `wallet_list` summing 1000
- [ ] Agent calls `GET /api/launch/concierge/config` → reads `x402` price, network, treasury
- [ ] Agent calls `POST /api/launch/concierge/run` with JSON body → **gets 402** with x402 requirements
- [ ] Agent signs USDC with Bankr custodial wallet → no human browser needed
- [ ] Agent POST again with `PAYMENT-SIGNATURE` header → **gets 202 + jobId + statusUrl**
- [ ] Agent **polls** `GET statusUrl` every 15–30s until `status: "completed"`
- [ ] Agent reply includes:
  - ✅ Token name, symbol, **contract address** (clickable BaseScan link)
  - ✅ 1000 units delivered to **[wallet]** (full address)
  - ✅ Fee-rights receipt serial #[SERIAL]
  - ✅ All transaction links (Deploy, Mint, Split, Deliver) → BaseScan
  - ✅ Profile link: `https://www.tokenmarketplace.shop/profile?tab=nfts`
  - ✅ Next-step offers (List, Send, Claim, Split units)
- [ ] **No one-liner replies** — must be 3-part (info, txs, next steps)
- [ ] **No "tell me to retry"** — agent polled fully

### Solana (Pump.fun)

- [ ] User says "Deploy X via pumpfun" → agent infers Solana, all 1000 SPL to linked Solana wallet
- [ ] Agent calls `POST /api/launch/concierge/solana/run` (same x402 + poll logic as Base)
- [ ] Agent signs USDC on Solana mainnet (custodial Solana key or user's wallet)
- [ ] Polling works (up to 10 min for Solana)
- [ ] Agent reply includes:
  - ✅ Token mint address (clickable Solscan link)
  - ✅ Pump.fun link
  - ✅ Profile link: `https://www.tokenmarketplace.shop/profile?tab=pump`
  - ✅ All tx links
  - ✅ Next steps

---

## ✅ Sell / List fee rights (100% fixed sale, Base only)

### Happy path (mint ready, dual list)

- [ ] User says "Sell X for 0.01 ETH" → agent infers **dual list** (site + OpenSea)
- [ ] Agent calls `GET /api/mint/status?tokens=[token]&wallet=[seller]` → reads `phase`
  - [ ] If `phase === "ready"` → skip to list
  - [ ] If `phase !== "ready"` → execute `nextStep` txs (same conversation)
- [ ] Agent calls `POST /api/list/dual` body: `{ tokenId, priceEth: "0.01", seller }`
- [ ] API returns `site.steps` + `openSea` hints
- [ ] Agent executes `site.steps` (approve + list) on chain
- [ ] Agent verifies `GET /api/list/status?listingId=` returns `listedOnSite: true`
- [ ] Agent loads **opensea-marketplace** skill to complete Seaport leg (same conversation)
- [ ] Agent reply includes:
  - ✅ Token, price (0.01 ETH)
  - ✅ **Shop URL**: `https://www.tokenmarketplace.shop/listing/sale/[ID]`
  - ✅ **OpenSea URL**: full link (not bare link)
  - ✅ Approve + List transaction links
  - ✅ Next-step offers (Cancel, Relist, Send, Split units)
- [ ] **No "site only because OpenSea slow"** — both legs in same conversation

### Site-only exceptions

- [ ] User says "List X for 0.01 ETH with password" → agent infers **site only**
  - [ ] No OpenSea leg
  - [ ] Agent reply mentions password gate
- [ ] User says "List 100 units for 0.0001 each" → agent infers **share market, not fixed sale**
  - [ ] Routes to `share-market-list-autopilot.md` instead
- [ ] User says "List on site only" → agent respects override
  - [ ] No "want OpenSea?" question

---

## ✅ Buy fee rights (100% fixed sale)

### Happy path

- [ ] User provides `/listing/sale/[id]` URL or just listing ID
- [ ] Agent calls `GET /api/list/buy-status?url=` or `?listingId=`
- [ ] Agent checks `canBuy: true`
- [ ] Agent reads `nextStep` (FeeRightsFixedSale.buy calldata)
- [ ] Agent signs + executes → `msg.value = priceWei` exactly
- [ ] Agent verifies `ownerOf(tokenId)` on collection = buyer wallet
- [ ] Agent reply includes:
  - ✅ Token, price (ETH)
  - ✅ Buyer wallet
  - ✅ Transaction link (BaseScan)
  - ✅ Listing URL (shop)
  - ✅ "Your receipt is on your wallet" (or serial #)
  - ✅ Next steps (List, Split, Send, Claim)
- [ ] **Errors properly handled:**
  - [ ] `canBuy: false` → "Listing inactive/sold" (not "try share market")
  - [ ] `WrongPayment` → "Exact ETH required"
  - [ ] Password → "Unlock with password"

### Routing guards

- [ ] **Never** call `share/list-status` when URL is `/listing/sale/…`
- [ ] **Never** say "this is inactive on share market" for fixed sale errors

---

## ✅ Buy shares (ERC-1155, 1/1000 units)

### Happy path

- [ ] User says "Buy cheapest share of $X" or "Buy 5 units at best price"
- [ ] Agent resolves token → gets `hybridTokenId`
- [ ] Agent calls `GET /api/share/list-status?wallet=&hybridTokenId=[id]`
- [ ] Agent sorts `offers` by price (ascending) → picks rank #1 (or user's rank N)
- [ ] Agent reads `pricePerUnitWei`, `listingId`, `qty`
- [ ] Agent signs + executes `HybridShareMarketplace.buy(listingId, qty)` → `msg.value = qty × pricePerUnitWei`
- [ ] Agent verifies `balanceOf(buyer, tokenId)` increased by qty
- [ ] Agent reply includes:
  - ✅ Token, qty purchased, price per unit
  - ✅ Total ETH spent
  - ✅ Buyer wallet
  - ✅ Transaction link
  - ✅ Profile link + holdings
  - ✅ Next steps (Buy more, List, Send, Claim)
- [ ] **Errors properly handled:**
  - [ ] `MaxPerWalletExceeded` → "This listing caps per wallet"
  - [ ] No listings → "No active shares; try [creating group buy]"

---

## ✅ List shares (ERC-1155 on market)

### Happy path

- [ ] User says "List 100 units of $X at 0.0001 ETH each"
- [ ] Agent calls `GET /api/claim/hybrid-status?token=&wallet=[seller]&serial=`
- [ ] Agent checks `unitsFinalized: true` + seller's balance ≥ qty
- [ ] Agent parses qty, price, optional password, optional max per wallet
- [ ] Agent builds calldata: `list(collection, tokenId, qty, pricePerUnitWei, maxPerWallet, [accessKeyHash])`
- [ ] Agent signs `approve(marketplace, qty)` then `list` on `HybridShareMarketplace`
- [ ] Agent verifies listing active: `getListing(id)` exists
- [ ] Agent reply includes:
  - ✅ Token, qty, price per unit, total value
  - ✅ Max per wallet (if set)
  - ✅ Password protection (if set)
  - ✅ Transaction link
  - ✅ Share market URL
  - ✅ Next steps (Update price, Add units, Cancel)

---

## ✅ Redeem fee rights (burn TMPR)

### Happy path

- [ ] User says "Redeem" or "Get fee rights back" (holds TMPR)
- [ ] Agent resolves `tokenId` from serial, OpenSea link, or ticker
- [ ] Agent calls `GET /api/mint/status?tokens=[token]&wallet=[user]` → reads escrow address + confirms TMPR owner
- [ ] Agent does `eth_call redeemRights(tokenId)` from user wallet → preflight check
- [ ] Agent signs + executes `redeemRights(tokenId)` on correct escrow (`BankrEscrowV3` `0x6238…` for Bankr) **from NFT owner wallet only**
- [ ] Agent verifies TMPR burned: `ownerOf(tokenId)` reverts
- [ ] Agent verifies `getShares(poolId, userWallet) > 0` on fee manager
- [ ] Agent reply includes:
  - ✅ TMPR serial: **Burned**
  - ✅ Fee beneficiary: **Restored to your wallet**
  - ✅ Token name
  - ✅ Transaction link
  - ✅ Doppler link (fee status verification)
  - ✅ Explanation: "You now receive all trading fees directly"
  - ✅ Next steps (Claim fees, Re-list)
- [ ] **Errors properly handled:**
  - [ ] `UnauthorizedCaller` → "You don't own this TMPR; sign from [owner]"
  - [ ] `RightsNotEscrowed` → "Already redeemed; check [Doppler]"

### Guard rails

- [ ] **Never** ask user to approve escrow first (redeem doesn't need approval)
- [ ] **Never** say "escrow unverified" as blocker (BaseScan verified)

---

## ✅ Claim fees (all unit holders)

### Happy path

- [ ] User says "Claim fees for $X" or "Claim fees for all holders"
- [ ] Agent calls `GET /api/claim/hybrid-status?token=[token]&wallet=[user]`
- [ ] Agent checks `canClaimForToken: true`
- [ ] Agent reads holders count + estimated fee pool (ETH)
- [ ] Agent executes `claimFeesForToken([tokenId])` on `HybridClaimRouter`
- [ ] Agent monitors tx → completed (1–3 min)
- [ ] Agent reply includes:
  - ✅ Token
  - ✅ Total holders paid
  - ✅ Fee pool (ETH) distributed
  - ✅ Distribution: "pro-rata to all 1000 units"
  - ✅ Transaction link
  - ✅ Profile link (claim history)
  - ✅ Next step: "Claim again when new fees accrue"
- [ ] **User says "claim for just me"** → ❌ Explain: "Hybrid claims pay ALL holders; no self-only option"
- [ ] **Never route to `claimtokenfees`** (Bankr native fee claim — different product)

---

## ✅ Send / gift / airdrop units (ERC-1155)

### Happy path

- [ ] User says "Send 50 units of $X to 0xABC…"
- [ ] Agent calls `GET /api/claim/hybrid-status?token=[token]&wallet=[sender]`
- [ ] Agent checks `unitsFinalized: true` + sender balance ≥ qty
- [ ] Agent parses recipients (single or batch)
- [ ] Agent signs `safeTransferFrom(sender, recipient, tokenId, qty, data)` for each recipient
- [ ] Agent verifies recipient balances increased
- [ ] Agent reply includes:
  - ✅ Token, qty transferred
  - ✅ Sender, recipient(s)
  - ✅ Transaction link
  - ✅ "Recipient now holds [QTY] units"
  - ✅ Next steps (Send more, List, Claim)
- [ ] **Batch airdrops** work: "Airdrop 10 units to each: 0x… 0x…"

---

## ✅ Fractionalize / split into 1000 (post-launch)

### Happy path

- [ ] User says "Split $X into 1000 units" or "Fractionalize $X"
- [ ] Agent calls `GET /api/mint/status?tokens=[token]&wallet=[user]`
- [ ] Agent reads `phase === "ready"` (TMPR already minted)
- [ ] Agent executes finalize on `GroupBuyEscrowV6` or self-split logic
- [ ] Agent verifies `unitsFinalized(tokenId) === true`
- [ ] Agent reply includes:
  - ✅ Token
  - ✅ "Split into 1000 tradeable units"
  - ✅ User's holdings: 1000 units
  - ✅ Transaction link
  - ✅ Share market URL
  - ✅ Next steps (List units, Send, Claim)

---

## ✅ Solana flows (weak agent APIs today)

### Deploy on Pump

- [ ] Same as Base: `POST /api/launch/concierge/solana/run` + poll
- [ ] Agent must sign Solana x402 (custodial or user wallet)
- [ ] Reply format includes Pump.fun link, Solscan txs, profile?tab=pump

### Buy on Solana CTO

- [ ] User provides `/listing/sol/[pubkey]` URL
- [ ] Agent calls `GET /api/solana/buy-status?listing=[pubkey]`
- [ ] Agent builds calldata, signs, executes
- [ ] Reply format: token mint, buyer, SOL price, Solscan links

### Claim on Solana

- [ ] Agent calls `GET /api/solana/claim-status?listing=[pubkey]`
- [ ] Executes claim, distributes to holders
- [ ] Reply format: token mint, holders, SOL distributed

### Known gap

- [ ] **No `/api/solana/list` parity with Base `/api/list/dual`** — Solana sell agent APIs incomplete; consider browser fallback doc or SDK guide

---

## 🚨 Mandatory guardrails (agent must follow every time)

| Rule | Check |
|---|---|
| **Never "paid" without jobId** | Launch: only after `202 + jobId` |
| **Always poll after x402** | Launch: poll until `completed`, not `queued` |
| **Always include shop URLs** | Not bare hashes; full `https://www.tokenmarketplace.shop/…` |
| **Always offer next steps** | 1–4 options at end of reply |
| **No jargon in replies** | Users don't see: `poolId`, `redeemRights`, `sellerKeepsBps`, `priceWei` |
| **Default 1000 units on deploy** | Don't ask "want 1000?"; just do it unless split specified |
| **Default dual list on sell** | Don't ask "site or OpenSea?"; do both unless user said one |
| **Default all holders on claim** | Don't ask "everyone or just me?"; pay all unless user said self-only |
| **No "I hit step limit"** | Complete polls + flows even if multi-turn |
| **Verify before replying** | Shop URL from API response, not guessed |

---

## Post-update checklist (after changing API or skill)

- [ ] Read the updated API response schema
- [ ] Cross-check agent.md match (Base `/launch`, Solana `/solana`)
- [ ] Verify response template includes all fields from API
- [ ] Run happy-path test (end-to-end, same device)
- [ ] Run error-path test (one API field missing, one contract revert)
- [ ] Agent reply format matches this checklist
- [ ] No jargon leaks into user-facing reply
- [ ] All links clickable + correct domain (`tokenmarketplace.shop`, `basescan.io`, etc.)
- [ ] Next steps are real (not "I don't know what's next")
- [ ] Commit to repo, sync to `tmp-site-agent` if `agent.md` changed

---

## Sign-off

**When you've verified all flows above**, update this file with date + pass/fail summary, and the agent is ready for production.

```text
Date: [TODAY]
Auditor: [NAME / TOOL]
Result: [PASS / FAIL + items]
Deploy ready: [YES / NO]
```

