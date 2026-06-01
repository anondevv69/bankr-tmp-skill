# Complete Token Setup Guide — All Sale Types (TMP Skills v74)

**Purpose:** End-to-end walkthrough for every sale type on Token Marketplace. Each flow shows what happens at each step, what can go wrong, and how to unstick.

---

## Table of Contents

1. **FLOW A** — Sell 100% for fixed ETH (best for first-time sellers)
2. **FLOW B** — Sell a slice, keep the rest (partial sale)
3. **FLOW C** — Split into 1000 tradeable units (hybrid / share market)
4. **FLOW D** — Group buy (many wallets pool money)
5. **FLOW E** — Timed fee share (give % for N days, no payment)
6. **Troubleshooting** — Common blocks + exact fixes

---

## FLOW A — Sell 100% for Fixed ETH (Whole Rights)

**When to use:** You want to sell **all** your trading fees forever for a fixed ETH price. Buyer gets **100%** of future fees.

**What you say:**
```text
List my $t7 fee rights for 0.01 ETH
```

### Step 1: Check if token can be listed (API call)

**Agent does:**
```
GET /api/mint/status?tokens=0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3&wallet=YOUR_WALLET
```

**What each response means:**

| Response `phase` | What it means | What agent does next |
|------------------|---------------|---------------------|
| `ready` | NFT already minted, ready to list | Skip to **Step 3: Approve & List** |
| `needs_prepare` | Fee manager hasn't registered escrow yet | Run `prepareDeposit` (Step 2a) |
| `needs_transfer` | Escrow is registered but needs shares moved | Run transfer (Step 2b) |
| `needs_finalize` | Shares ready; finalize the NFT mint | Run `finalizeDeposit` (Step 2c) |
| `not_beneficiary` | You're not the fee owner on this token | ❌ Stop — wrong wallet or token |

**If you get `escrowMismatch: true` with `phase: ready`:**
- ✅ This is OK — proceed to listing. The escrow mismatch doesn't block listing, only mint.

### Step 2: Finish minting the NFT (if not `ready`)

**2a — prepareDeposit** (if `phase: needs_prepare`)
- What happens: Fee manager registers your wallet as the escrow's pending seller.
- Sign 1 tx from your wallet.
- What to expect: Low gas (~50k). Should succeed in seconds.
- **If it fails:**
  - `simulation reverted` → probably not the active fee beneficiary. Check Doppler.
  - `execution reverted` → escrow allowlist issue. Escalate to Bankr ops.

**2b — Transfer beneficiary to escrow** (if `phase: needs_transfer`)
- What happens: API calls `POST /api/bankr-build-transfer` (this is **automatic**, you don't sign).
- Then you sign `finalizeDeposit` from your Bankr custodial wallet.
- What to expect: Transfer takes 1–2 blocks. Then finalize (~120k gas).
- **If build-transfer fails:** Usually a Doppler rate limit or permission issue. Retry once after 30 seconds.

**2c — finalizeDeposit** (if `phase: needs_finalize`)
- What happens: Your fee rights move into escrow. An NFT (TMPR receipt) is minted and sent to your wallet.
- Sign 1 tx from the wallet in `signerMustBe`.
- What to expect: Minting takes 1–2 blocks. You'll see a new NFT in OpenSea under `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e`.
- **If it fails:**
  - `RightsNotEscrowed` → beneficiary wasn't transferred. Re-run step 2b.
  - `execution reverted` → escrow not authorized on TMPR collection. Bankr ops needs to authorize.

**After mint completes, re-check mint/status. You should now see `phase: ready`.**

### Step 3: Approve Marketplace Contract

**Agent does:**
```
POST /api/list/dual {
  tokenId: "102827652914408433121415002298223515805764633656416579128953185902816790019438",
  priceEth: "0.01",
  seller: "0x374D91a5674Fa7Cf86E725093b5848b97e1e13b4"
}
```

**What it returns:**
- Two txs: `approve` (marketplace gets permission to move your NFT) + `list` (set price).
- Calldata for each tx (you copy into your wallet and sign).

**What to expect:**
- Approve: ~45k gas, 1–2 blocks.
- List: ~80k gas, 1–2 blocks.
- Total cost: ~$3–8 on Base (cheap).

**If approve is blocked:**
- ❌ **"unverified_contract"** error → Custodial security scanner flagged the marketplace as new.
  - **Fix 1** (fastest): Transfer your NFT to your personal wallet (MetaMask/Rabby), then list from there.
  - **Fix 2** (wait): Retry approve 3 times with 60-second delays. Scanner usually updates within 2–4 hours.
  - **Fix 3** (escalate): Ask Bankr ops to pre-whitelist `0xe2A13499292D43254026DAf0C4F75988242BaA66` (the marketplace contract).

### Step 4: Execute Approve & List

**Agent does:**
- You sign `approve` from the seller wallet (usually `0x374D…` if on custodial, or your EOA if transferred).
- You sign `list` right after.

**What each tx does:**

| Tx | What it does | What could go wrong |
|----|-------------|---------------------|
| **approve** | Marketplace gets permission to move your NFT | Blocked by custodial scanner (see above) |
| **list** | Your NFT price is set on-chain; listed for sale | Rarely fails; usually a reorg or gas issue. Retry. |

**After both txs mine:**
- Your NFT is **live on Token Marketplace**.
- URL: `https://www.tokenmarketplace.shop/listing/sale/LISTING_ID`

### Step 5: Optional — List on OpenSea Too

**Agent does** (separate OpenSea skill):
- Calls OpenSea Seaport API to list your receipt on OpenSea.
- You may sign an `approve` for OpenSea separately.

**What to expect:**
- OpenSea listing appears in 10–30 minutes (indexing delay).
- Price can be different from Token Marketplace (your choice).

---

## FLOW B — Partial Sale (Sell Slice, Keep Rest)

**When to use:** You want to sell **5% of fees** to a buyer for **0.005 ETH**, but **keep 95% forever**.

**What you say:**
```text
Sell 5% of my $t7 fees for 0.005 ETH, I keep 95%
```

### Prerequisites

- NFT (TMPR) must be **minted** (`phase: ready` from Step 1 of Flow A).
- You hold the NFT in your wallet.

### Step 1: Create partial listing

**Agent does:**
```
createPartialListing(
  collection: 0xCD66340D93E212bEC6Db1b22476e4f1276380C3e,
  tokenId: 102827...,
  priceWei: 0.005 ETH in wei,
  keepBps: 9500,  // 95% = 9500 bps
  venueType: BankrEscrowV3,
  rightsEscrow: 0x6238...
)
```

**What happens:**
- Listing appears in **Group Buy** tab on Token Marketplace.
- Buyer can `contribute` ETH toward the 0.005 ETH target.
- You keep 95%; buyer gets 5%.

**What to expect:**
- 1 tx (approve + list combined).
- Low gas (~100k total).
- Listing goes live immediately.

**If it fails:**
- `InvalidBps` → keep% + sell% don't add to 100. Check math.
- `NotAuthorized` → TMPR not approved to escrow. Run `approve(GroupBuyEscrowV2, tokenId)`.

### Step 2: Wait for funding

**What happens:**
- Buyers can contribute up to 0.005 ETH total.
- You can see contributions in real-time on the site.

**What could go wrong:**
- Listing never funds → Buyer interest wasn't there. You can cancel anytime.

### Step 3: Finalize the split

**Agent does** (you or anyone can trigger):
```
finalize(listingId)
```

**What happens:**
- Buyer's 0.005 ETH is sent to you.
- An **immutable 0xSplits contract** is created.
- Future fees are routed: 95% → your wallet, 5% → buyer's wallet.
- **Original NFT is burned** — no more listing.

**What to expect:**
- 1 tx from any wallet (~200k gas).
- Split activation takes 1 block.
- Fees auto-split forever; no manual claims.

**If it fails:**
- Not fully funded → You can only finalize once target is reached.
- `RightsNotEscrowed` → TMPR wasn't escrowed properly. Backtrack to Flow A mint check.

**After finalize, you cannot undo this.** The 95/5 split is permanent. See `product-rules.md` for what can and cannot be reversed.

---

## FLOW C — Split into 1000 Units (Hybrid / Share Market)

**When to use:** You want to split your **whole** receipt into **1000 tradeable units**, so buyers can purchase 1/1000, 2/1000, etc. Useful for giveaways or fractional sales.

**What you say:**
```text
Split my $t7 fee rights into 1000 units for my wallet
```

### Prerequisites

- NFT must be minted (`ready`).
- You own the TMPR.

### Step 1: Create a group-buy listing with V6

**Agent does:**
```
GroupBuyEscrowV6.createListing(
  collection: 0xCD66340D93E212bEC6Db1b22476e4f1276380C3e,
  tokenId: 102827...,
  priceWei: TARGET_ETH,
  venueType: BankrEscrowV3,
  rightsEscrow: 0x6238...
)
```

If you're funding it yourself (to keep all 1000 units):
- `priceWei` = amount you contribute yourself.
- On finalize, you get all 1000 units on the **hybrid TMPR collection** (`0xD8e0639…`).

**What to expect:**
- Listing appears in **Group Buy** tab.
- 1 tx (~120k gas).

### Step 2: Fund the listing (if needed)

**Agent does** (if you're splitting for yourself):
```
contribute(listingId, msg.value = priceWei)
```

**What happens:**
- Listing is fully funded.
- Ready to finalize.

### Step 3: Finalize → Mint 1000 units

**Agent does**:
```
finalize(listingId)
```

**What happens:**
- Hybrid TMPR is minted: **`0xD8e0639DfAa1cB2b9f9642EeCbd40b1e5a8b42A7`** (ERC-1155).
- You receive **1000 ERC-1155 tokens** (units) in your wallet.
- Original legacy TMPR (`0xCD66…`) is burned.
- A **0xSplits** is created (if funding split was uneven) OR you control the whole unit set.

**What to expect:**
- 1 tx (~350k gas).
- Takes 1–2 blocks.
- Units appear in your wallet on BaseScan.

**If it fails:**
- `NotFullyFunded` → You didn't contribute enough or no one else did. Fund more, then finalize.
- `AlreadyFinalized` → Someone already called finalize. Check on-chain.

### Step 4: Optional — List units on share market

**Agent does** (if you want to sell some units):
```
GET /api/claim/hybrid-status?token=0x9021...&wallet=YOUR_WALLET

// Then list units on HybridShareMarketplace
list(tokenId, quantity, pricePerUnit, ...)
```

**What happens:**
- Individual units are listed on the share market order book.
- Cheapest price shows first.
- Buyers can purchase 1/1000, 10/1000, etc.

**What to expect:**
- 2 txs: `setApprovalForAll` + `list`.
- Low gas (~80k total).
- Units are instantly tradeable.

---

## FLOW D — Group Buy (Many Wallets Pool Money)

**When to use:** You want to sell **all 100%** of your rights, but let **many wallets contribute** ETH. Each contributor owns a **proportional share** of future fees.

**What you say:**
```text
I want a group buy for $t7 — let 10 people contribute 0.5 ETH each and share the fees
```

### Step 1: Create group listing

**Agent does:**
```
GroupBuyEscrowV2.createListing(
  collection: 0xCD66340D93E212bEC6Db1b22476e4f1276380C3e,
  tokenId: 102827...,
  priceWei: 5 ETH (total target),
  minContribWei: 0.1 ETH (optional minimum per contributor),
  venueType: BankrEscrowV3,
  rightsEscrow: 0x6238...
)
```

**What to expect:**
- Listing in **Group Buy** tab.
- 1 tx (~120k gas).
- Status: "Open for contributions".

### Step 2: Wait for contributions

**What happens:**
- Wallets contribute ETH toward the 5 ETH target.
- Contributors can see real-time progress.

**What could go wrong:**
- Listing never funds → Not enough interest. You can cancel (cancel before finalize).

### Step 3: Finalize (when 5 ETH is reached)

**Agent does** (you or anyone):
```
finalize(listingId)
```

**What happens:**
- Contributions are locked in.
- A **0xSplits** is created.
- Fees are routed to split: **each contributor gets fees ÷ (their ETH ÷ total ETH)**.
- Example: If person A contributed 1 ETH out of 5 total, they get 20% of fees forever.
- Your 5 ETH goes to your wallet.

**What to expect:**
- 1 tx (~300k gas).
- Split is permanent and immutable.

---

## FLOW E — Timed Fee Share (Give % for N Days)

**When to use:** You want to **temporarily** give someone (e.g., a developer or promoter) **X% of fees for 30 days**, then the fees **come back to you**. **No ETH payment** from them.

**What you say:**
```text
Give my developer 15% of $t7 fees for 30 days — no payment from them
```

### Prerequisites

- **Redeem your TMPR first** (burn the NFT, move fees back to your wallet as beneficiary).
- Cannot share while fees are held in escrow on an NFT.

### Step 1: Redeem the NFT

**Agent does:**
```
redeemRights(tokenId)
```

**What happens:**
- TMPR is burned.
- Fee rights return to your wallet (you become the active beneficiary again).

**What to expect:**
- 1 tx (~120k gas).
- Takes 1 block.

### Step 2: Create timed grant

**Agent does:**
```
createGrant(
  grantee: 0xDEVELOPER_WALLET,
  bps: 1500,  // 15% = 1500 bps
  endTime: UNIX_TIMESTAMP (30 days from now),
  venueType: BankrEscrowV3,
  ...
)
```

**What to expect:**
- 1 tx (~150k gas).
- Grant is live immediately.
- Grantee sees fees flowing to them in real-time.

### Step 3: Manually distribute fees (weekly or as needed)

**Agent does** (you or grantee, weekly):
```
distributeFees(grantId)
```

**What happens:**
- Accumulated fees are split:
  - 15% → grantee wallet
  - 85% → your wallet

**What to expect:**
- Depends on trading volume. Weekly or bi-weekly calls are typical.

### Step 4: After endTime, get fees back

**Agent does** (after endTime):
```
cancelGrant(grantId)
```

**What happens:**
- Grantee is removed.
- All future fees come back to you.
- Any unclaimed fees from the grant period go to the grantee (they had their chance to claim).

**What to expect:**
- 1 tx (~100k gas).
- Grant is closed.

---

## Troubleshooting — Common Blocks & Fixes

### "NFT listed but I can't see it on the site"

| Symptom | Cause | Fix |
|---------|-------|-----|
| Listed, but site shows "No sales" | Indexing delay (up to 5 min) | Wait 5 minutes, refresh browser |
| Listed on blockchain, not on UI | TMPR collection mismatch | Make sure `tmprCollection` from API matches on-chain owner |
| Listing disappeared after approve | Tx reverted on second step | Check BaseScan for revert reason; retry if out-of-gas |

### "Approve blocked by custodial scanner"

| Error | Fix |
|-------|-----|
| `unverified_contract` | **Option 1 (fastest):** Transfer NFT to your EOA, list from there. **Option 2 (wait 2–4 hours):** Retry approve. **Option 3 (escalate):** Ask Bankr ops to whitelist marketplace. |
| `dangerous` | Same as above. |
| `contract not whitelisted` | Bankr custodial wallet needs permission. Escalate to ops. |

### "mintStatus says `needs_prepare` but I already called prepareDeposit"

| Possible cause | Fix |
|---|---|
| Tx was reverted | Check BaseScan; look at gas / revert reason. Retry. |
| Tx is still pending | Wait for confirmation; then re-check mint/status. |
| Fee manager is wrong (custodial issue) | Verify you're using the right Bankr wallet + fee manager address from Doppler. |

### "Can't finalize partial sale — says not fully funded"

**Cause:** Buyers didn't contribute the full target amount.

**Fix:**
- Wait longer for contributions.
- Lower the target price.
- Cancel and create a new listing with a lower ask.

### "Fees aren't being distributed after finalize"

| Scenario | Next step |
|----------|-----------|
| Partial sale (95/5 split) | Fees are **automatic** — split contract handles it. Check your wallet after a few hours. |
| Group buy | Call `distributeFees(...)` manually or wait for someone to call it. |
| Timed grant (ended) | Call `cancelGrant(...)` to stop paying grantee and get your share back. |

---

## Quick Reference: What Each Skill File Covers

| File | Covers |
|------|--------|
| **sell-list-autopilot.md** | Flow A (sell 100% for ETH) — step-by-step with API details |
| **split-1000-autopilot.md** | Flow C (split to 1000 units) — high-level overview |
| **share-market-list-autopilot.md** | Flow C continued — how to list units after split |
| **product-rules.md** | What can/cannot be reversed for each flow (read before any sale) |
| **custodial-approve-block-retry.md** | How to handle scanner blocks (approve failures) |
| **t7-wrong-token-935e-trap.md** | Don't use $TMP token address for t7 |
| **linked-wallet.md** | Custodial wallet vs your EOA (important for signing) |
| **runtime-contract.md** | Agent failure rules (hard stops + escalation paths) |

---

## You Should Never Get Stuck If…

✅ **You read the right file** before asking Bankr.
- Selling 100%? → `sell-list-autopilot.md`
- Selling a slice? → `product-rules.md` first, then `FLOW B` above
- Splitting 1000? → `split-1000-autopilot.md`

✅ **You use the exact token address**, not `$TMP`.
- t7 = `0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3`
- Never `0x935e…` ($TMP) or `0xCD66…` (TMPR collection)

✅ **You wait for each step to complete** before the next.
- Don't move to "approve" until NFT is minted (phase `ready`).
- Don't assume listing is live until site confirms it.

✅ **You use the "right" wallet to sign**.
- Usually **Bankr custodial** `0x374D…` for approve/list.
- **Your EOA** (MetaMask/Rabby) if NFT was transferred to you.

✅ **You know what to do if approve is blocked**.
- Read `custodial-approve-block-retry.md` **before** asking Bankr for help.

---

## Example: Complete "Sell 100%" Flow Start to Finish

```
You: "List my $t7 for 0.01 eth"

Bankr:
1. ✓ Checked mint/status → phase: ready
2. ✓ Checked seller wallet → 0x374D… (custodial)
3. ✓ Called list/dual API
4. ✓ You signed approve (approve succeeded)
5. ✓ You signed list (list succeeded)
6. ✓ Confirmed on-chain with list/status
7. ✓ Replied with listing URL: https://www.tokenmarketplace.shop/listing/sale/123

You: ✓ Listed and ready to sell!
```

---

**If you get stuck after reading this, include:**
- What flow you're on (A, B, C, D, E)
- The exact error message
- Which step you're stuck on
- The mint/status response (if applicable)

Then Bankr or we can debug fast.
