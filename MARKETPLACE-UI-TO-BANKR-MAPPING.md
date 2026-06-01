# Marketplace UI → Bankr skill mapping

**Full audit:** Every button on tokenmarketplace.shop → Bankr commands → on-chain contracts → status (working/blocked).

---

## QUICK REFERENCE — What to say to Bankr

| Product | Say this to Bankr | Expected result | Status | Blocker? |
|---------|-------------------|-----------------|--------|----------|
| **Create NFT** | `@bankrbot create nft for $t7` or `@bankrbot mint receipt for my t7 token` | TMPR minted, ready to sell | ✅ **Working** | None — depends on escrow type |
| **Sell 100%** | `@bankrbot sell $t7 for 0.01 eth` or `@bankrbot list t7 on tokenmarketplace for 0.01 eth` | Approve + list on site + OpenSea | ⚠️ **Blocked (custodial)** | `0xe2A1…` unverified scanner on Bankr wallet |
| **Buy 100%** | `buy https://www.tokenmarketplace.shop/listing/sale/1` or `@bankrbot buy this listing` (sale URL) | **`GET /api/list/buy-status`** → `buy(id)` on **`0xe2A1…`** | ✅ **Working** | **Never** use share `list-status` / **`0x9023…`** for `/listing/sale/` |
| **Split 1000** | `@bankrbot split $t7 into 1000 shares` or `@bankrbot fractionalize my t7 fee rights` | 1000 ERC-1155 units on hybrid | ✅ **Working** | None |
| **List units** (after split) | `@bankrbot list 10 $t7 shares at 0.01 eth each` or `@bankrbot list 100 t7 units with password Test, max 1 per wallet` | Units on share order book (`0x9023…`) | ✅ **Working** | None — different contract |
| **Partial sale** | `@bankrbot sell 30% of $t7 fees for 0.05 eth, keep 70%` or `@bankrbot list 30% partial for 0.05 eth` | Group buy pool for the sold % | ✅ **Working** | None |
| **CTO / Group buy** | `@bankrbot raise 1 eth for $t7 with cto` or `@bankrbot group buy $t7 — target 1 eth over 48 hours` | Public pool on Group buy tab | ✅ **Working** | None |
| **Co-own / Crowdsource** | `@bankrbot crowdsource $t7 — raise 0.5 eth, i seed 0.5 eth` or `@bankrbot co-own $t7 — i keep 20%, backers fund the rest` | Pool where you + backers own together | ✅ **Working** | None |
| **Timed grant** | `@bankrbot give 15% of $t7 fees to dev wallet for 30 days` | Dev gets 15% for a month, then back to you | ✅ **Working** | None — grants are permanent (no reversal) |
| **Paid loan** | `@bankrbot loan $t7 fees for 2 weeks for 0.1 eth` | Anyone can pay 0.1 ETH to borrow all fees | ⚠️ **Gap on Bankr** | Borrower could mis-route on Bankr (not Clanker) |
| **Redeem / Get back** | `@bankrbot get my $t7 fee rights back` or `@bankrbot redeem my t7 nft` | TMPR burned, beneficiary = wallet | ✅ **Working** | None |
| **Buy share** | `@bankrbot buy 1 $t7 share at cheapest price` or `@bankrbot buy 10 units of t7, password Test` | Share purchased, added to wallet | ✅ **Working** | None |
| **Claim fees** | `@bankrbot claim t7 fees` or `@bankrbot claim fees for all my tokens` | Fees distributed to wallet | ✅ **Working** | None |
| **Cancel listing** | `@bankrbot cancel my t7 listing 42` or `@bankrbot remove my units from the order book` | Listing removed, NFT returned | ✅ **Working** | None |

---

## AUDIT — Each product in detail

### 1. CREATE NFT (mint TMPR)

| | |
|---------|---------|
| **UI button** | Profile → "Create NFT" or "Mint receipt" |
| **User intent** | Turn trading fees into a tradeable NFT |
| **Bankr phrase** | `create nft for $t7` · `mint receipt for my token` · `turn my fees into an nft` |
| **Expected Bankr flow** | 1. Resolve launch token 2. Call `GET /api/mint/status` 3. Execute `nextStep` (prepare → transfer → finalize) 4. Reply with TMPR id + shop URL |
| **On-chain** | Escrow-specific (Bankr `0x6238…`, Clanker `0x3546…`, Zora `0x7A75…`) |
| **Contract** | Depends on token venue (see `all-escrow-options.md`) |
| **Status** | ✅ **Working** |
| **Blocker** | None — each escrow path is documented |
| **Notes** | **Do not** manually set Doppler beneficiary before `prepareDeposit` (causes `getShares = 0`). Agent must run full `nextStep` chain. |

---

### 2. SELL 100% (Fixed price, one buyer)

| | |
|---------|---------|
| **UI button** | Profile → "Sell 100%" or shop → "List for sale" |
| **User intent** | Sell entire TMPR for fixed ETH to one buyer |
| **Bankr phrase** | `sell t7 for 0.01 eth` · `list my t7 rights for 0.05 eth` · `i want to sell all my fees for a fixed price` |
| **Expected Bankr flow** | 1. `GET /api/mint/status` (confirm TMPR ready or finish mint) 2. `POST /api/list/dual` 3. Sign `approve(0xe2A1…, tokenId)` + `list(...)` 4. OpenSea flow 5. `GET /api/list/status` to verify |
| **On-chain path** | `FeeRightsFixedSale` `0xe2A13499292D43254026DAf0C4F75988242BaA66` |
| **Contracts** | ✅ Works for any TMPR (Bankr / Clanker / Zora) |
| **Status** | ⚠️ **BLOCKED for Bankr custodial wallets** |
| **Blocker** | **`0xe2A1…` unverified on third-party scanner** — Bankr custodial `approve` blocked as "unverified_contract" · Scanner index cold-start (newly deployed marketplace) · May take 24h+ to index |
| **Workarounds** | 1. **Retry 3x** (scanner may update) 2. **Transfer TMPR to user EOA** (MetaMask/Rabby) — then list from there 3. **Escalate to Bankr** to whitelist `0xe2A1…` 4. **Use split + list units** on `0x9023…` (share order book works) |
| **Fix needed** | Skill v78 expects 3 retries + fallback; Bankr v45 may give up after 1 block. Reinstall or escalate. |
| **Notes** | Do **not** say "list manually at ." — always include `https://www.tokenmarketplace.shop` in reply. Default is **dual list** (site + OpenSea). |

---

### 2b. BUY 100% (Fixed sale listing)

| | |
|---------|---------|
| **UI button** | Listing page → "Buy" on `/listing/sale/{id}` |
| **User intent** | Purchase entire TMPR at listed price |
| **Bankr phrase** | `buy https://www.tokenmarketplace.shop/listing/sale/1` · `buy listing 1 on token marketplace` (whole receipt) |
| **Expected Bankr flow** | 1. **`GET /api/list/buy-status?url=<full sale url>`** (mandatory) 2. If password: access-authorize + 3-arg `buy` 3. Else `buy(listingId)` with **`msg.value = priceWei` exactly** 4. Verify `ownerOf(tokenId)` = buyer |
| **On-chain path** | **`FeeRightsFixedSale` `0xe2A1…`** — same contract as sell 100% |
| **Status** | ✅ **Working** (buyer `buy` usually passes custodial scanner even when seller `approve` failed) |
| **Blocker** | **Wrong routing:** agent checks share listing id **N** on **`0x9023…`** when URL is **`/listing/sale/N`** — fixed in v79 + buy-status API |
| **Notes** | Skill: **`buy-fixed-sale-autopilot.md`**. Share buys use **`/listing/shares/…`** + **`share-market-buy.md`**. |

---

### 3. SPLIT INTO 1000 SHARES

| | |
|---------|---------|
| **UI button** | Profile → "Split into 1000 shares" |
| **User intent** | Create 1000 ERC-1155 fee-right units (not 1000 separate NFTs) |
| **Bankr phrase** | `split t7 into 1000 shares` · `fractionalize my t7` · `split into 1000 nfts` (agent clarifies = units) |
| **Expected Bankr flow** | 1. `GET /api/mint/status` (TMPR must exist or finish mint) 2. Self-fund CTO on V6: approve TMPR → `createListing` with `durationSecs = huge` (you as buyer, min = full target) 3. Execute on-chain 4. `finalize` → 1000 units to your wallet on hybrid `0xD8e0639…` 5. Confirm `GET /api/claim/hybrid-status?token=...` = 1000 units |
| **On-chain path** | **GroupBuyEscrowV6** (self-split variant) → finalize → **HybridTmpr** `0xD8e0639…` ERC-1155 |
| **Contract** | Not `FeeRightsFixedSale` (whole TMPR), not `list/dual` |
| **Status** | ✅ **Working** |
| **Blocker** | None — different escrow path than sell 100% |
| **Notes** | After split, you own **1 ERC-1155 token** with balance **1000 units** (not 1000 separate token IDs). Profile then shows **"List units (1…1000)"** button. |

---

### 4. LIST UNITS (after split)

| | |
|---------|---------|
| **UI button** | After split: Profile → "List units (1…1000)" |
| **User intent** | Sell N of the 1000 units on the share order book |
| **Bankr phrase** | `list 10 t7 shares at 0.01 eth each` · `list 100 units, max 1 per wallet, password Test` · `list my units on the share market` |
| **Expected Bankr flow** | 1. `GET hybrid-status` (confirm 1000 units in wallet) 2. `POST /api/share/prepare` 3. Approve + `list` on **`HybridShareMarketplace`** `0x9023…` 4. `GET /api/share/list-status?hybridTokenId=...` to verify |
| **On-chain path** | **HybridShareMarketplace** `0x90230B59D01c6e0306236eF7afc8105908c4DB0B` |
| **Contract** | ERC-1155 share order book (different from fixed sale) |
| **Status** | ✅ **Working** — This is what worked for **$CTO listing id 13** |
| **Blocker** | None — approved scanner contract |
| **Notes** | **Site-only** (no OpenSea). Password-protected listings supported. Max-per-wallet supported. Free listings (0 ETH) supported. |

---

### 5. PARTIAL SALE (Keep X%, sell Y% forever)

| | |
|---------|---------|
| **UI button** | Profile → "Partial sale" |
| **User intent** | Keep 70%, sell 30% forever for fixed ETH to one or many buyers |
| **Bankr phrase** | `sell 30% of my t7 fees for 0.05 eth, keep 70%` · `partial sale — i want to keep 80% and sell 20%` · `sell a slice of my fees` |
| **Expected Bankr flow** | 1. `GET mint/status` (TMPR ready) 2. `POST /api/list/dual` with `sellerKeepBps=7000` (keep 70%) 3. Execute site steps (approve + `createPartialListing` on V2) 4. List goes to Group buy tab (not fixed sale) 5. Buyer `contribute` until funded 6. Anyone `finalize` → 0xSplits created (permanent) |
| **On-chain path** | **GroupBuyEscrowV2** `0x869D…` → `createPartialListing` → 0xSplits (immutable) |
| **Contract** | NOT `list/dual` for whole NFT — GroupBuyV2 |
| **Status** | ✅ **Working** |
| **Blocker** | None |
| **Notes** | **Permanent forever** after finalize — cannot be reversed. TMPR burned on finalize. Seller + buyers each collect from split. |

---

### 6. CTO / GROUP BUY (Many wallets fund 100%)

| | |
|---------|---------|
| **UI button** | Profile → "CTO — Coin takeover" |
| **User intent** | Let many wallets pool ETH to buy 100% of your fees together |
| **Bankr phrase** | `raise 1 eth for t7 cto` · `group buy my fees — target 1 eth over 48 hours` · `let people pool together to buy my rights` |
| **Expected Bankr flow** | 1. `GET mint/status` 2. `POST /api/list/dual` with no `sellerKeepBps` (sell 100%) 3. `createListing` on GroupBuyV2 4. List shows on Group buy tab 5. Contributors `contribute` until target reached 6. Anyone `finalize` → 0xSplits per wallet ETH |
| **On-chain path** | **GroupBuyEscrowV2** `0x869D…` → `createListing` → 0xSplits |
| **Contract** | Same GroupBuyV2 as partial, but `keepBps=0` |
| **Status** | ✅ **Working** |
| **Blocker** | None |
| **Notes** | Permanent after finalize. Split allocations proportional to ETH contributed. |

---

### 7. CO-OWN / CROWDSOURCE (You seed + backers fill)

| | |
|---------|---------|
| **UI button** | Profile → "Co-own" |
| **User intent** | You seed ETH + backers contribute; everyone owns proportionally |
| **Bankr phrase** | `crowdsource t7 — i seed 0.1 eth, raise 0.1 more` · `co-own my fees — i keep part based on my seed` · `i seed 50% you fund 50%` |
| **Expected Bankr flow** | 1. `GET mint/status` 2. `POST /api/list/dual` with `crowdsource=true` + seedWei 3. `createCrowdsource` on GroupBuyV2 (with `msg.value = seedWei`) 4. Backers contribute 5. Anyone `finalize` → 0xSplits per contribution % (including your seed) |
| **On-chain path** | **GroupBuyEscrowV2** `0x869D…` → `createCrowdsource` → 0xSplits |
| **Contract** | GroupBuyV2 crowdsource variant |
| **Status** | ✅ **Working** |
| **Blocker** | None |
| **Notes** | Permanent. Your allocation = `seedWei / (seedWei + backerWei)`. After finalize, you get backers' ETH + seed back, split activated. |

---

### 8. TIMED FEE SHARE (Give X% for N days, then returns)

| | |
|---------|---------|
| **UI button** | Profile → "Timed fee share" |
| **User intent** | Give wallet X% of fees for N days with no ETH payment; then fees come back |
| **Bankr phrase** | `give 15% of my t7 fees to 0xDevWallet for 30 days` · `timed fee share — 20% for 60 days` · `grant my dev 10% for a month` |
| **Expected Bankr flow** | 1. Redeem TMPR (if held) → wallet becomes beneficiary 2. `POST /api/grant/...` with grantee address, grantBps, durationSecs 3. Grant escrow becomes beneficiary 4. On finalize: distributor calls `distributeFees` weekly; grantBps% → grantee, rest → you 5. After `endTime`: `distributeFees` sends 100% to you, grant ends |
| **On-chain path** | **FeeRightsTimedGrantEscrow** `0xb569…` (becomes beneficiary) |
| **Contract** | Timed grant (different from loans) |
| **Status** | ✅ **Working** |
| **Blocker** | None |
| **Important rules** | 1. **Grantee cannot sell, loan, or redirect** — they only get ERC-20 transfers 2. **You can cancel early** 3. **Fees are NOT bundled at end** — distribute regularly or grantee loses undistributed share 4. Grantee receives no NFT. |

---

### 9. PAID TIME LOAN (Rent 100% for N days for ETH)

| | |
|---------|---------|
| **UI button** | Profile → "Paid time loan" or "Bag worker" |
| **User intent** | Borrow your 100% fee stream for N days for an ETH price |
| **Bankr phrase** | `loan my t7 fees for 2 weeks for 0.1 eth` · `bag worker — anyone can pay 0.1 eth to borrow my fees for 30 days` · `paid loan for 14 days at 0.05 eth` |
| **Expected Bankr flow** | 1. Redeem TMPR (if held) 2. `POST /api/loan/...` with priceWei, durationSecs 3. Loan escrow becomes beneficiary 4. Borrower calls `acceptLoan(loanId)` with priceWei ETH 5. Fees go 100% to borrower's wallet 6. After `endTime`: `reclaimLoan` (anyone) → stream back to you |
| **On-chain path** | **FeeRightsLoanEscrow** `0x9F16…` (Bankr only; Clanker safer with admin override) |
| **Contract** | Loan escrow |
| **Status** | ⚠️ **Working but Bankr has a gap** |
| **Blocker** | **Bankr:** After accept, borrower is live beneficiary — could call `updateBeneficiary` directly. `reclaimLoan` would fail or partial-fail. Clanker v4 doesn't have this (escrow keeps admin). |
| **Important rules** | 1. **Borrower collects 100%** of fees during the loan 2. **You get ETH upfront**, not fees at end 3. **Cannot list/sell/loan on top** while active 4. **After `endTime`, stream returns** (no fees bundled back) |

---

### 10. REDEEM / GET FEE RIGHTS BACK

| | |
|---------|---------|
| **UI button** | Profile → "Get fee rights back" or "Redeem NFT" |
| **User intent** | Burn TMPR, restore beneficiary to your wallet |
| **Bankr phrase** | `get my t7 fees back` · `redeem my nft` · `return my fee rights to my wallet` |
| **Expected Bankr flow** | 1. Resolve TMPR tokenId (from link, scan, or user) 2. Confirm you own it (`ownerOf = wallet`) 3. `redeemRights(tokenId)` on correct escrow (Bankr/Clanker/Zora) 4. Verify beneficiary = wallet |
| **On-chain path** | Escrow-specific (`0x6238…` Bankr, `0x3546…` Clanker, `0x7A75…` Zora) |
| **Contract** | Redeem function on escrow (works for any TMPR) |
| **Status** | ✅ **Working** |
| **Blocker** | None — you must own the TMPR |
| **Notes** | Only NFT holder can redeem. Burnable one-way. After redeem, no NFT exists; fees are in wallet. |

---

### 11. BUY SHARE (one buyer, order book)

| | |
|---------|---------|
| **UI button** | Share market → "Buy" or "Add to cart" |
| **User intent** | Buy N units from the share order book (1–1000 units per seller) |
| **Bankr phrase** | `buy 10 t7 shares at best price` · `buy 1 unit of t7, password is Test` · `buy the cheapest share of cto` |
| **Expected Bankr flow** | 1. `GET /api/share/list-status` (find cheapest/available offers) 2. If password: `POST /api/listings/access-authorize` + sign 3. `buy(listingId, qty, [authDeadline, authSig])` on **`0x9023…`** 4. Verify `GET hybrid-status` = units added |
| **On-chain path** | **HybridShareMarketplace** `0x9023…` → `buy` (2-arg or 4-arg with auth) |
| **Contract** | Share market (different from fixed sale) |
| **Status** | ✅ **Working** |
| **Blocker** | None |
| **Notes** | Password shares require `access-authorize` first. Quantity capped by `maxPerWallet`. |

---

### 12. CLAIM FEES (collect rewards)

| | |
|---------|---------|
| **UI button** | Any TMPR or units → "Claim" or "Collect" |
| **User intent** | Collect accrued trading fees to wallet |
| **Bankr phrase** | `claim my t7 fees` · `collect fees for all my tokens` · `claim cto rewards` |
| **Expected Bankr flow** | 1. Identify token/listing 2. `GET /api/claim/hybrid-status` (units) or on-chain fee state 3. Call claim function (Bankr / Clanker / splits / vaults depending on listing type) 4. Fees transferred to wallet |
| **On-chain path** | Depends on product: hybrid (ERC-1155), splits (partial/group), loan escrow, grant escrow, or direct |
| **Contract** | Multiple (context-dependent) |
| **Status** | ✅ **Working** |
| **Blocker** | None |
| **Notes** | Automatic for many; some require agent/owner to push claim on splits. |

---

### 13. CANCEL LISTING

| | |
|---------|---------|
| **UI button** | Listings tab → "Cancel" or "Remove" |
| **User intent** | Remove listing before anyone buys; return NFT or units to wallet |
| **Bankr phrase** | `cancel my t7 listing 42` · `remove my share units from sale` · `delist my partial sale` |
| **Expected Bankr flow** | **For share units:** 1. `GET /api/share/list-status?listingId=42` 2. `cancel(listingId)` on **`0x9023…`** 3. Verify units back in wallet | **For fixed sale:** Use UI (site) only — agent cannot call `FeeRightsFixedSale.cancel` safely |
| **On-chain path** | **HybridShareMarketplace** `0x9023…` → `cancel` (share units only) |
| **Contract** | Share market (NOT fixed sale) |
| **Status** | ✅ **Working for shares** ⚠️ **Agent cannot cancel fixed sale (site-only)** |
| **Blocker** | Fixed-sale cancel not exposed to agent — user must use UI |
| **Notes** | Share cancels are agent-safe. Fixed-sale listings must be cancelled on https://www.tokenmarketplace.shop directly. |

---

## SUMMARY TABLE — Status & blockers

| Product | Status | Blocker | Workaround |
|---------|--------|---------|-----------|
| Create NFT | ✅ | None | Run `nextStep` chain fully |
| **Sell 100%** | ⚠️ | Custodial scanner on `0xe2A1…` | Retry 3x OR transfer to EOA OR escalate to Bankr |
| Split 1000 | ✅ | None | Works on different contract |
| List units | ✅ | None | Works after split |
| Partial sale | ✅ | None | Different flow from sell 100% |
| CTO | ✅ | None | GroupBuyV2 |
| Co-own | ✅ | None | Crowdsource variant |
| Timed grant | ✅ | None | Grantee cannot sell/loan |
| Paid loan | ⚠️ | Bankr: borrower can mis-route | Use Clanker v4 if available |
| Redeem | ✅ | None | Must own TMPR |
| Buy share | ✅ | None | Password shares need auth |
| Claim fees | ✅ | None | Context-dependent flow |
| Cancel listing | ✅ (shares) / ⚠️ (fixed) | Fixed-sale cancel not exposed | Use site UI for fixed sale |

---

## Skill readiness — v78

✅ **All flows documented** in `flow-reference.md`  
✅ **Product rules** in `product-rules.md`  
✅ **Bankr routing** in `AGENT-ROUTING-LISTINGS.md` + `ONE-LINE-INTENTS.md`  
✅ **One-line intents** map user phrases → flows  
⚠️ **Known blockers:** custodial `0xe2A1…` approve, Bankr loan borrower gap  

---

## How to communicate each product to Bankr

### Short form (user to @bankrbot, one line)

```
@bankrbot create nft for $t7
@bankrbot sell $t7 for 0.01 eth
@bankrbot split $t7 into 1000 shares
@bankrbot list 10 t7 shares at 0 eth, password Test, max 1 per wallet
@bankrbot sell 30% of my t7 fees for 0.05 eth, keep 70%
@bankrbot raise 1 eth for my t7 cto — 48 hour deadline
@bankrbot crowdsource $t7 — i seed 0.1 eth, raise 0.1 more
@bankrbot give my dev 15% of my t7 fees for 30 days
@bankrbot loan my t7 fees for 2 weeks for 0.1 eth
@bankrbot get my t7 fee rights back
@bankrbot buy 10 t7 shares at best price
@bankrbot claim my t7 fees
@bankrbot cancel my t7 listing 42
```

### Expected Bankr v78 behavior (after reinstall)

Each phrase above triggers the correct **Flow** + **autopilot** without asking follow-up questions.

### If Bankr says "blocked" or asks questions

- **Skill version:** `@bankrbot install TMP skills at https://github.com/anondevv69/bankr-tmp-skill` (should be v78)
- **Sell 100% approve blocked:** Retry 3x, or transfer TMPR to MetaMask, or escalate to Bankr
- **Loans on Bankr:** Consider Clanker v4 (safer) or accept borrower mis-route risk
- **Fixed sale cancel:** Use site UI only
