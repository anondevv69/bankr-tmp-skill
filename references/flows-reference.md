# All flows — agent steps + human language

Every product on Token Marketplace. Two columns per flow: **what the agent does internally**, **what users say and how the agent replies**.

> **Before any flow involving integrity, reversal, or "what happens to fees":** read **`product-rules.md`** — the definitive table of what can and cannot be reversed for each product.

---

## FLOW 1 — Create NFT (mint TMPR)

### Agent does (internal, silent)
1. **`GET /api/mint/status?tokens=0x…&wallet=0x…`** — read `phase` + `nextStep` (see **`mint-pending-deposit.md`**).
2. If `ready` → stop mint; use `tokenId` for list/bundle.
3. If `needs_transfer` → **do not** `prepareDeposit` → `POST /api/bankr-build-transfer` → `finalizeDeposit` from `signerMustBe`.
4. If `needs_finalize` → **only** `finalizeDeposit(poolId)` from `signerMustBe`.
5. If `needs_prepare` → `prepareDeposit` → build-transfer → `finalizeDeposit`.
6. Verify: TMPR `ownerOf(tokenId)` = expected wallet.

### User says
> "Make a marketplace NFT for my t7 token."  
> "Turn my Surplus trading fees into an NFT I can sell."  
> "Create the receipt for my token."

### Agent replies
> "Done — Token Marketplace receipt #42 created for Surplus. Your trading fees are now in escrow. Ready to list it for sale?"

---

## FLOW 2 — Sell 100% (list for fixed ETH)

### Agent does (internal, silent)
1. **`GET /api/mint/status`** for launched token + seller wallet — execute `nextStep` until `phase === "ready"` (see **`sell-list-autopilot.md`**). **Do not** stop after prepare with “transfer beneficiary manually.”
2. Confirm TMPR exists (or complete Flow 1 via mint/status in step 1).
3. `POST https://www.tokenmarketplace.shop/api/list/dual` `{ tokenId, priceEth, seller }`.
4. Execute returned `site.steps[]` (approve + list on `FeeRightsFixedSale 0xe2A1…`).
5. OpenSea skills → Seaport listing on Base.
6. Verify: `GET /api/list/status?tokenId=` → active on both.

### User says
> "List my t7 fee rights for 0.01 ETH."  
> "Sell all of it — I want 0.05 ETH."  
> "Put it on the marketplace and OpenSea."

### Agent replies
> "Your t7 fee rights are listed at 0.01 ETH — on Token Marketplace and OpenSea. When someone buys it, they get the trading fees permanently. [site link] [OpenSea link]"

---

## FLOW 3 — Sell a slice, keep the rest (partial sale)

### Agent does (internal, silent)
1. Confirm TMPR exists (or run Flow 1 first).
2. Resolve `venueType` + `rightsEscrow` from `positionOf(tokenId)`.
3. `approve(GroupBuyEscrowV2 0x869D…, tokenId)` on TMPR.
4. `createPartialListing(collection, tokenId, priceWei, durationSecs, 0, keepBps, venueType, rightsEscrow)` on V2.
   - "Sell 5%" → `keepBps = 9500`; "sell 20%" → `keepBps = 8000`.
   - `priceWei` = ETH buyers pay for the **sold slice only**.
5. Site shows listing in Group buy tab. Buyers `contribute` ETH until funded.
6. `finalize(listingId)` → 0xSplits created; fees routed per split.

### User says
> "Sell 5% of my test1 fees for 0.005 ETH, keep the rest."  
> "I want to keep 80% and sell 20% for 0.1 ETH."  
> "Let someone buy a piece of my fees, I stay in."

### Agent replies
> "Partial sale is live — you keep 95% of test1's trading fees forever, and buyers can chip in a total of 0.005 ETH for the 5% slice. Once it's fully funded, the split activates automatically. [Group buy tab link]"

---

## FLOW 4 — Group buy (many wallets fund 100%)

### Agent does (internal, silent)
1. Confirm TMPR exists (or Flow 1 first).
2. `approve(GroupBuyEscrowV2 0x869D…, tokenId)`.
3. `createListing(collection, tokenId, priceWei, durationSecs, minContribWei, venueType, rightsEscrow)`.
4. Contributors call `contribute(listingId)` until `totalRaised >= priceWei`.
5. Anyone calls `finalize(listingId)` → 0xSplits; fee stream goes to split.

### User says
> "Let 10 people pool together to buy my Surplus fees."  
> "I want a group buy — anyone who chips in gets a share."  
> "Open it up for people to contribute."

### Agent replies
> "Group buy is open — anyone can contribute ETH toward the 0.5 ETH target. When it's fully funded, contributors each get a proportional share of Surplus's trading fees automatically. [link]"

---

## FLOW 5 — Crowdsource (you seed + backers fund)

### Agent does (internal, silent)
1. Confirm TMPR exists (or Flow 1 first).
2. `createCrowdsource(collection, tokenId, targetRaise, durationSecs, 0, venueType, rightsEscrow)` with `msg.value = seedWei`.
3. Fee % allocation: creator's seed ÷ (seed + raised). Backers get remaining %.
4. On finalize → backers' ETH to creator; creator's seed returned; split activated.

### User says
> "I'll put in 0.1 ETH myself and raise 0.1 more from backers."  
> "Crowdfund my fee rights — I seed half, community seeds the other half."

### Agent replies
> "Crowdsource open — you seeded 0.1 ETH. Once backers add another 0.1 ETH, you get their contribution, your seed back, and everyone co-owns the trading fees proportionally. [link]"

---

## FLOW 6 — Timed fee share (give someone X% for N days, no payment)

### Agent does (internal, silent)
1. Redeem TMPR if held (`redeemRights(tokenId)` → wallet becomes fee beneficiary).
2. `updateBeneficiary(poolId, grantEscrow 0xb569…)` on fee manager.
3. `createGrantBankr(grantee, grantBps, endTime)` on `FeeRightsTimedGrantEscrow`.
4. Lender (or automation) calls `distributeFees(grantId)` regularly — sends `grantBps%` to grantee, rest to lender.
5. After `endTime`, `distributeFees` returns 100% to lender and ends grant.
6. Lender can `cancelGrant(grantId)` at any time to end early.

### User says
> "Give my developer 15% of my t7 fees for 30 days."  
> "I want to share 10% with a promoter for a month, then it comes back."  
> "Assign my cofounder 20% for 90 days, no payment from them."

### Agent replies
> "Done — your developer gets 15% of t7's trading fees for 30 days. They don't need to do anything. After 30 days all fees come back to you automatically. You'll need to run a distribution once a week or so to release their share — I can remind you or set up automation."

**Key rule:** grantee does NOT pay ETH. If they pay → use loan (Flow 7).

### Integrity rules for timed grants (mandatory — read this)

| Rule | What it means |
|------|---------------|
| **Grantee cannot sell or loan** | Grantee only receives token transfers from `distributeFees`. They are NOT the fee beneficiary, have no TMPR, and cannot redirect the stream. Hard-blocked on-chain. |
| **Lender can cancel early** | `cancelGrant` available to lender at any time; stream returns to lender. By design — tells grantee there is an early-exit option. |
| **Run `distributeFees` BEFORE `endTime`** | Any fees that built up but were NOT distributed before `endTime` go 100% to **lender** at the first distribute call after `endTime`. The grantee loses that uncollected share. Tell the lender to distribute regularly (weekly) and especially just before the end date. |
| **Fees are NOT bundled at end** | Fees are sent out immediately on each `distributeFees` call. There is no "lump sum at the end" — each distribution is live. |

---

## FLOW 7 — Paid time loan ("bag worker")

### Agent does (internal, silent)
1. Redeem TMPR if held → wallet = fee beneficiary.
2. `updateBeneficiary(poolId, loanEscrow 0x9F16…)`.
3. `createLoanBankr(feeManager, poolId, token0, token1, borrower, priceWei, startTime, endTime)`.
4. Borrower calls `acceptLoan(loanId)` with `priceWei` ETH → fees go 100% to borrower.
5. After `endTime`, `reclaimLoan(loanId)` (anyone can call) → fees return to lender.

### User says
> "Loan my Surplus fee rights for 2 weeks — anyone can pay 0.05 ETH for them."  
> "I want to rent out my token's fees for a month."  
> "Bag worker — someone pays me and gets the fees for a while."

### Agent replies
> "Loan listed — anyone can pay 0.05 ETH to borrow all of Surplus's trading fees for 14 days. After that, fees automatically return to you. [loan link]"

**Key rule:** borrower gets 100%. If you want them to only get X% → use timed grant (Flow 6).

### Where fees go during a loan (important — do not confuse with grants)

| Period | Who collects fees? |
|--------|--------------------|
| After `createLoanBankr`, before `acceptLoan` | **Lender** can claim via `claimBankrFeesForLoan` (fees sit in loan escrow) |
| After `acceptLoan`, before `endTime` | **Borrower** directly — fees arrive in borrower's wallet, not escrow |
| After `endTime` → `reclaimLoan` | **Lender** again for all future fees |

Fees during the active loan period belong to the **borrower**. They are **not** returned to the lender at loan end. The lender was paid upfront in ETH. Do NOT tell the lender they will "get their fees back" — they get the **stream back**, not the fees collected during the period.

### No forward sale while loan is active (mandatory)

**While a paid loan is open or active for this token, do not list, partial-sell, grant, or bundle those fee rights.** They must **`reclaimLoan` back to the original lender** after `endTime` — not to a buyer or split.

| Who | Can sell / list forward? |
|-----|--------------------------|
| **Lender** | **No** — TMPR burned at loan setup; no receipt to list on marketplace |
| **Borrower** | **No** — agent must refuse; selling would break return-to-lender |
| **Anyone** | **No** for that pool until loan reclaimed |

**Agent:** Pre-flight **`loan-no-forward-sale.md`** before Flow 2–6, 9. If loan active → stop and explain in plain English.

**Bankr on-chain gap:** Borrower could mis-route beneficiary without agent/UI blocking — **Clanker V4** loans are safer (escrow keeps admin for reclaim).

---

## FLOW 8 — Get fee rights back (redeem)

### Agent does (internal, silent)
1. Resolve `tokenId` from OpenSea link, TMPR scan, or user-provided #.
2. Confirm `ownerOf(tokenId)` = user's wallet (only NFT holder can redeem).
3. `redeemRights(tokenId)` on **`BankrEscrowV3 0x6238…`** (Bankr), `ClankerEscrowV4 0x3546…`, or `ZoraEscrowV1 0xe1E1…` — from `positionOf(tokenId).feeManager`.
4. Verify: fee beneficiary on token = user wallet.

**Do NOT:** `setApprovalForAll` for redeem. **Do NOT:** say "escrow unverified." **Do NOT:** submit from wrong wallet.

### User says
> "Get my t7 fees back in my wallet."  
> "I bought the NFT on OpenSea — put the trading fees back to me."  
> "Burn the receipt and give me back my fees."  
> "Return my fee rights."

### Agent replies
> "Done — Token Marketplace receipt #20 burned. Your t7 trading fees now go directly to your wallet again. [Doppler verification link]"

---

## FLOW 9 — Bundle & Rebirth (combine N fee rights → launch new Bankr token)

**Read first:** **`bundle-rebirth-playbook.md`** (explain vs execute, TMPR scan, anti-stuck). **Custody/API:** `bundle-rebirth.md`.

**One user prompt → agent chains all steps.** User wallet funds everything. **Bundle accepts TMPR NFTs only** — not raw fee rights.

### Explain vs execute

| User says | Agent |
|-----------|--------|
| "What is bundle & rebirth?" | Plain explanation only — **no** token verification spam. |
| Token list + deploy name/ticker, or "start minting and do all steps" | **Execute** full chain — **no** "confirm if you already minted." |

### Agent does (internal, silent)
1. **TMPR wallet scan** per launch token (`positionOf` → match ERC‑20). APIs (`token-fees`, `creator-fees`) are **optional** — failures do not stop.
2. Per-token table: ready (has TMPR) vs needs Flow 1 mint. **`getShares > 0`** required to mint.
3. Mint missing TMPRs → **wait for confirm** before bundle.
4. `POST /api/bundle/prepare { tokenIds, escrows, owner }` → approve × N + createBundle.
5. `POST /api/bundle/claim { bundleId }`.
6. `POST /api/bundle/disband { bundleId, owner, feesTo: userWallet }`.
7. `POST https://api.bankr.bot/token-launches/deploy` + user `X-API-Key`.
8. Swap WETH → new token (initial buy).

**If one token mint fails:** fix **that** token (e.g. fee recipient on dashboard); tokens already `ready` (e.g. TMPR #17) can still be named in status — do not claim "cannot bundle anything."

**Contract:** `FeeRightsBundleEscrow` `0x429Af4F73d9a254607890930848Be2E9f50dBb3F`.

### User says
> "Burn these 3 NFTs and merge into **$TEST** — use the fees for the initial buy."  
> "Start minting and then do all the steps."  
> "What is bundle & rebirth?" (explain only)

### Agent replies
> "I'll combine your fee receipts, send WETH to **your** wallet, turn off old fee streams, launch **$TEST** on Bankr, and use your fees for the first buy. You sign each step."

**On complete:**
> "Done — WETH is in your wallet, old fee rights are off, and **$TEST** is live. [links]"

---

## FLOW 10 — Check what you have / portfolio

### Agent does (internal, silent)
1. `GET /api/bankr-launches?q=wallet` — all Bankr launches with fee share.
2. `TMPR.balanceOf(wallet)` → for each tokenId: `positionOf(tokenId)` → ticker + poolId.
3. Cross-reference: escrowed? listed? loan open?
4. Present as plain list — no addresses unless asked.

### User says
> "What tokens do I have fee rights for?"  
> "Show me what's listed."  
> "What can I turn into an NFT?"

### Agent replies
> "You have fee rights on 3 tokens:
> - Surplus — receipt NFT in your wallet (not listed)
> - SI — receipt NFT in your wallet (not listed)
> - t7 — listed for 0.05 ETH on the marketplace"
> 
> Want to list Surplus or SI, or do anything with them?

---

## FLOW 11 — Buy a 1/1000 share (cheapest offer)

**When:** User split fee rights into **1000 units** (hybrid / Group buy V6) and sellers listed units on the **share market**.

### User says
> "Buy the cheapest 1/1000 share of $t7"  
> "Buy 1 share at the best price"  
> "Get me version 1" / "second cheapest offer, buy 2"

### Agent does (silent)
1. Resolve **$t7** → hybrid TMPR **tokenId** (`0xD8e0639…` collection).
2. Read active listings on **`HybridShareMarketplace`** `0x90230B…`; filter `tokenId`; read **`accessKeyHash`** per offer; sort by **lowest ETH per unit**.
3. Pick offer: default **rank #1**; "version 2" / "second cheapest" → rank #2; explicit **listing id** if given.
4. Set **quantity** (default **1**); respect remaining qty + **maxPerWallet**.
5. If **public**: `buy(listingId, quantity)` — **exact** ETH = qty × price each.
6. If **password-gated**: user supplies password (DM) → **`POST /api/listings/access-authorize`** → `buy(listingId, quantity, authDeadline, signature)` — Base.

### Agent replies
> "Bought **1 share** (1 of 1000) of **$t7** fee rights for **0.002 ETH** from the cheapest listing. [link to share market]"

> (password listing) "Bought **1 share** of **$CTO** from a password-protected listing (0 ETH). [link]"

**Full spec:** **`share-market-buy.md`** (including **§ Password-protected listings**)

---

## FLOW 12 — Reply drop / reply split (planned)

**When:** User wants reply-driven fee-right distribution, like **first 100 replies get 1% each** or **first 1000 get 1/1000**.

### User says
> "Deploy X. First 100 replies get 1% each."
> "Make the first 1000 replies get 1/1000 fee-right NFTs."
> "Set up a password-protected free claim page for the first replies."

### Agent does (silent)
1. Explain this as a **fee-right campaign**, not ERC-20 supply ownership.
2. Translate percentages into **hybrid units** on a `1000`-unit scale.
3. Capture campaign params: winner cap, units per winner, reply rule, wallet-linking rule, expiry, leftovers.
4. Call out current blockers:
   - **automated reply → wallet → claim** is **not** live yet
   - **password-gated share/fixed listings** **are** live for manual/API buys (`share-market-buy.md`) — different from reply-winner automation
5. For reply drops: route to design / capture params. For “buy 1 with password”: execute gated buy if wallet + password provided.

### Agent replies
> "That would give winners a share of **future claimable fees**, not the token supply itself. On the hybrid TMPR model there are **1000 total units**, so I should map your campaign into units first. For example, **1% = 10 units**. Full reply-drop automation isn’t live yet — but I can help you **list** or **buy** password-gated shares on the marketplace today if you connect a wallet."

**Read first:** **`reply-drop.md`**

---

## Human ↔ Agent quick reference

| What you say | What it means | Bankr does |
|---|---|---|
| "Make the marketplace NFT for my coin" | Create receipt | Mint TMPR (3 txs) |
| "Sell my [token] fees for X ETH" | Sell everything | Dual list (site + OpenSea) |
| "Sell 5%, keep the rest" | Partial forever | Partial sale on Group buy |
| "Let people pool to buy my fees" | Group buy | Group buy listing |
| "I'll seed some, raise the rest" | Crowdsource | Crowdsource listing |
| "Give [person] X% for N days, they don't pay" | Timed share | Timed fee grant |
| "Rent my fees out for N days for X ETH" | Paid loan | Loan listing |
| "Get my fees back" / "return rights" | Reclaim | Redeem TMPR |
| "Combine 3 tokens and launch a new one" | Bundle & Rebirth | Bundle → WETH → deploy |
| "What do I have?" | Portfolio | Scan launches + TMPR |
| "Buy cheapest 1/1000 share of $t7" | Share market | HybridShareMarketplace.buy |
| "Buy 1 share with password xxx" | Gated share buy | access-authorize + buy(…, signature) |
| "First 100 replies get 1%" | Reply drop | Explain unit math + gather campaign params |

---

## What users NEVER need to say

Contract addresses · poolId · sellerKeepsBps · priceWei · venueType · rightsEscrow · feeManager · tokenId (just say the token name or paste an OpenSea link) · approve escrow · setApprovalForAll.

Agent resolves everything silently. If stuck, ask **one** human question (which token? OpenSea link? which wallet?).
