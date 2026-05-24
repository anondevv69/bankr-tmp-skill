# Active loan — no forward sale (mandatory)

**Policy:** While a **paid time loan** is open or active for a pool, **fee rights for that token must not be sold, split, bundled, or re-assigned** in a way that prevents **`reclaimLoan`** from returning **100% of the fee stream to the original lender** after `endTime`.

The lender is renting the stream temporarily. It **must come back** to them — not to a buyer, split, or dead wallet.

---

## Who can do what during a loan

| Party | Sell 100% (dual list) | Partial / group buy | Timed grant | Bundle | Loan again |
|-------|----------------------|---------------------|-------------|--------|------------|
| **Original lender** | **No** — TMPR already burned; not fee beneficiary | **No** | **No** | **No** | N/A (they created the loan) |
| **Borrower** (after `acceptLoan`) | **No** — must not mint TMPR and list | **No** | **No** | **No** | **No** |
| **Anyone else** | **No** — they do not own the stream | **No** | **No** | **No** | **No** |

**After `reclaimLoan` succeeds:** lender has fees in wallet again → they may mint a new TMPR (if desired) and then sell / partial / grant per normal flows.

---

## Why the lender cannot “sell forward”

Loan setup **requires**:

1. **`redeemRights(tokenId)`** — TMPR is **burned**.
2. **`updateBeneficiary(poolId, loanEscrow)`** — `FeeRightsLoanEscrow` holds the stream until accept, then borrower.

So there is **no TMPR** to `approve` for `FeeRightsFixedSale` or `GroupBuyEscrowV2`. **`POST /api/list/dual`** needs a `tokenId` the seller still owns — **blocked**.

---

## Borrower must not sell or re-route (Bankr caveat)

On **Bankr**, after accept the **borrower** is the live `updateBeneficiary` target. The loan contract does **not** block the borrower from:

- Redirecting beneficiary elsewhere, or
- Minting a **new** TMPR while they are beneficiary and listing it.

That **breaks the loan** and can make **`reclaimLoan` fail** until manual recovery.

**Agent rule:** If user is the **borrower** on an active loan, **refuse** list / partial / grant / bundle for that token. Tell them: *“These rights are borrowed until [date]; they return to the lender automatically. You can’t sell or split them.”*

**Clanker V4 loans:** `FeeRightsLoanEscrow` keeps **rewardAdmin** — `reclaimLoan` can always pull the stream back to the lender (stronger than Bankr).

---

## Agent pre-flight (before ANY sale / split / grant / bundle)

For the token the user named:

1. **`eth_call`** `getShares(poolId, FeeRightsLoanEscrow)` and check beneficiary on fee manager vs `0x9F167C8dce30ca1e6F46bC2491d6434e30568790`.
2. Read **`getLoan(loanId)`** if loanId known — `accepted && !reclaimed && block.timestamp < endTime` ⇒ **loan active**.
3. If **loan escrow** is beneficiary **or** **borrower** is beneficiary on an accepted unreclaimed loan for that pool → **STOP**.

**Do not run:** `POST /api/list/dual`, `createPartialListing`, `createGrant*`, `POST /api/bundle/prepare` for that pool.

**Reply (plain English):**

> That token’s fee rights are on a **paid loan** until [date]. They have to go back to the original owner when the loan ends — so they can’t be listed or sold right now. After the loan ends and rights are reclaimed, you can list or split them.

---

## What still works during a loan

| Action | Lender | Borrower |
|--------|--------|----------|
| **Collect fees** (Bankr UI) | No (not beneficiary) | Yes — 100% to borrower wallet |
| **Cancel loan** (before accept) | Yes — `cancelLoan` | No |
| **Reclaim** (after endTime) | Anyone — `reclaimLoan` → lender | Must not block reclaim |

---

## Plain English for users

**Good:** “Your Surplus fees are rented out until May 25 — they’ll automatically return to you then. You can’t sell them while the loan is active.”

**Bad:** “Paste tokenId and I’ll list on the marketplace.” (without checking loan state)
