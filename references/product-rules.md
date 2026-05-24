# Product rules — what can and cannot be reversed, sold, or tampered with

Read this before any flow involving **loan**, **timed grant**, **partial sale**, **group buy**, or **crowdsource**.

---

## Quick rule table

| Product | Reversible? | Grantee / borrower can sell? | Fees during period go to… | After it ends… |
|---------|-------------|------------------------------|---------------------------|----------------|
| **Timed grant** | Lender can cancel early; otherwise ends at `endTime` | **No** — grantee cannot sell, loan, or redirect | **Grant escrow distributes** grantBps% to grantee, rest to lender | Stream returns to lender |
| **Paid time loan** | Lender can cancel before accept; after accept: auto-returns at `endTime` | **No — must not** (would break return) | **Borrower directly** — not accumulated for return | Stream returns to lender |
| **Partial sale** | **No** — permanent forever | Each party owns their split share | **0xSplits** distributes per locked allocation | Nothing — permanent |
| **Group buy** | **No** — permanent forever | Each party owns their split share | **0xSplits** | Nothing — permanent |
| **Crowdsource** | **No** — permanent forever | Each party owns their split share | **0xSplits** | Nothing — permanent |

---

## TIMED GRANT — "Give wallet X% for N days, then it comes back"

### What the contract guarantees

- **`FeeRightsTimedGrantEscrow`** is the Bankr fee beneficiary for the entire grant period.
- The grantee wallet **only receives ERC-20 token transfers** when `distributeFees(grantId)` is called.
- The grantee **does not hold** the TMPR, **is not** the Bankr/Clanker beneficiary, and **cannot** call `updateBeneficiary`, `redeemRights`, `acceptLoan`, or anything that would change the fee stream.
- At `endTime`: the next `distributeFees` call **sends 100% to the lender** and calls `updateBeneficiary(poolId, lender)` — stream is back.

### Can the grantee do anything malicious?

| Action | Blocked? | How |
|--------|----------|-----|
| Sell the fee rights on Token Marketplace | ✅ Yes (hard) | Grantee has no TMPR and is not the beneficiary — there is nothing to approve or list |
| Loan the stream out | ✅ Yes (hard) | Only the beneficiary can redirect; grant escrow is the beneficiary |
| Redirect fees to another wallet | ✅ Yes (hard) | Grant escrow is beneficiary; `updateBeneficiary` can only be called by the current beneficiary |
| Stop the grant early themselves | ✅ Yes (hard) | Only `lender` can call `cancelGrant` |

### Can the lender take it back early?

Yes — `cancelGrant(grantId)` is callable by the lender at any time. This is intentional (the lender may need an emergency exit). It immediately calls `_restoreFeesToLender` → beneficiary back to lender.

### Important: fees during the grant are NOT bundled back at the end

Each `distributeFees` call **immediately sends** grantBps% to the grantee and the rest to the lender. At `endTime`, the **last batch only** goes 100% to lender — not all prior fees. Any fees that built up but were **not distributed before endTime** are sent 100% to lender on the first distribute after endTime.

**Run `distributeFees` regularly** (weekly is recommended). If no one calls it and `endTime` passes, the grantee misses accumulated undistributed fees — they go to the lender.

---

## PAID TIME LOAN — "Rent 100% for N days for a price"

### What the contract guarantees

- Lender burns TMPR (redeem), points Bankr/Clanker stream at loan escrow (`FeeRightsLoanEscrow`).
- Borrower pays ETH, stream redirected to **borrower** directly.
- After `endTime`: anyone calls `reclaimLoan(loanId)` → stream returns to lender.
- Lender can `cancelLoan` **before** borrower accepts — stream returns to lender.

### Can the borrower sell/loan/tamper?

| Action | Bankr loan | Clanker v4 loan |
|--------|------------|-----------------|
| Sell on Token Marketplace | ✅ Practically blocked (no TMPR to list) | ✅ Blocked |
| Loan out via `FeeRightsLoanEscrow` | Technically possible on-chain if borrower calls `updateBeneficiary` to loan escrow | ✅ Blocked — escrow keeps `rewardAdmin` so only escrow can move it |
| Redirect Bankr beneficiary elsewhere | ⚠️ **Gap** — borrower is live beneficiary, could call `updateBeneficiary` directly | ✅ Blocked — escrow keeps admin |
| Force reclaim to fail | ⚠️ **Gap** — if borrower redirected fees, `reclaimLoan` partial-fails on Bankr | ✅ Not possible — admin override always works |

**Clanker v4 loans are strictly protected.** The loan escrow keeps `rewardAdmin` and only transfers `rewardRecipient` to borrower. At `endTime`, `reclaimLoan` sets both back to lender — no borrower cooperation required.

**Bankr loans have a gap.** After `acceptLoan`, the borrower IS the Bankr fee beneficiary. The contract does not block them from calling `updateBeneficiary` again. If they do:
- `reclaimLoan` will run but the escrow won't have shares, so it sets the flag but cannot actually redirect
- Lender must call `recoverBankrRights` separately (if available) or recover out-of-band

### Fees during the loan belong to the borrower — they are NOT returned to lender

When the borrower is the Bankr/Clanker beneficiary, **trading fees go directly to the borrower's wallet**. This is the whole point of the loan. At loan end:
- **Borrower keeps** all fees they collected during the period
- **Lender gets** the stream back (future fees)
- **Lender already received** the ETH paid by the borrower upfront

There is **no "bundle of accumulated fees" returned to the lender at loan end.** If the lender wants to collect fees from the pool during the open-but-not-yet-accepted period, they can call `claimBankrFeesForLoan(loanId)` — those fees go to the lender.

---

## PARTIAL SALE — "Keep X% forever, sell Y% forever"

### What the contract guarantees

- On `finalize`: TMPR burned, 0xSplits PushSplit created, **Bankr/Clanker beneficiary = split contract**.
- Split created with `owner = address(0)` — **immutable, no owner**. Nobody can change allocations.
- Seller's kept % and buyers' % are **permanently locked** in the split.
- Nobody can call `updateBeneficiary` to redirect the stream because only the current beneficiary (split) can, and the split contract has no such function.

### Can anyone undo or redirect after finalize?

| Action | Possible? |
|--------|-----------|
| Seller reclaims 100% back | **No** — TMPR burned, beneficiary is the immutable split |
| Buyer sells their % on Token Marketplace | **No separate NFT** — buyers only have a wallet address in the split |
| Buyer changes their split share | **No** — split is immutable |
| Anyone redirects Bankr/Clanker fees away from split | **No** — only the split (beneficiary) could call `updateBeneficiary` and it cannot |
| Loan on top of partial sale | **No** — no one holds beneficiary rights to redirect to a loan escrow |

### What each party CAN do after finalize

- **Seller and buyers**: call `distribute` on the 0xSplits contract to push their share to their wallet.
- **Nobody**: change allocations, redirect the stream, or undo the sale.

### Loophole: BEFORE finalize (listing open but not funded)

While a group-buy or partial sale listing is **open** (TMPR in GroupBuyEscrowV2, not yet finalized):
- The TMPR is held by GroupBuyEscrowV2; nobody else can transfer or redeem it
- BankrEscrowV3 is still the Bankr beneficiary
- The seller CANNOT redirect Bankr fees (they're not the beneficiary — BankrEscrowV3 is, and only it calls `updateBeneficiary` on redeem)
- BUT: if someone managed to change the Bankr beneficiary away from BankrEscrowV3 before finalize, `redeemRights` would fail and finalize would revert

**In normal flow this cannot happen.** The attack surface is: any admin-level exploit of BankrEscrowV3 or the Bankr fee manager itself.

---

## GROUP BUY / CROWDSOURCE

Same finality rules as partial sale. Once finalized:
- Split is immutable
- Stream is permanent
- No reversal

Crowdsource additionally: creator's seed ETH is returned on finalize (no fee on seed), outsiders' ETH minus 2% goes to creator, split activated per each wallet's ETH contribution.

---

## Summary: who can do what

| Who | During active grant | During active loan | After partial sale finalize |
|-----|--------------------|--------------------|---------------------------|
| **Grantee** | Receive token transfers when `distributeFees` called; nothing else | N/A | Collect from split only |
| **Borrower** | N/A | Collect fees directly (Bankr gap: could mis-route — Clanker cannot) | N/A |
| **Lender / Seller** | `cancelGrant` (early end) | `cancelLoan` before accept; `reclaimLoan` after endTime | Collect from split only |
| **Anyone** | Call `distributeFees` | Call `reclaimLoan` after endTime | Call `distribute` on split |

---

## Agent rules (enforce in every flow)

1. **Before any loan or grant flow** — check if there is already an active loan or active listing for that pool. Do not stack.
2. **Timed grant grantee** — if the grantee asks to "sell" or "loan" the token, tell them they received a time-limited fee share, not ownership of the stream; they cannot redirect or sell it.
3. **Active loan borrower** — refuse any listing, partial sale, grant, or bundle. See `loan-no-forward-sale.md`.
4. **After partial sale / group buy finalize** — tell users the split is permanent; no TMPR exists anymore; they collect from the split only.
5. **Loan fees** — make clear to both parties: fees during the loan go to **borrower's wallet directly**. The lender gets the ETH upfront, not a bundle of fees at the end.
