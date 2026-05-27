# Reply Drop / Reply Split (planned hybrid campaign)

Use this when users say:

- "First 100 replies get 1% each."
- "First 1000 people to reply get 1/1000 NFTs."
- "Make a free claim page for the first replies."
- "Password protect the page and let them claim fee rights."

## Status

This is a **planned flow**, not a live execute-today feature on the current contracts.

Do **not** claim Bankr can already run this end-to-end. Explain the model, capture the campaign params, and call out the missing contract/backend pieces.

## What it is

A reply drop gives winners a **share of fee rights**, not ownership of the ERC-20 token supply.

For hybrid TMPR:

- `1000` total units per token
- `1` unit = `0.1%`
- `10` units = `1%`

Always translate user wording into **units** before confirming the plan.

Examples:

- "first 100 get 1%" = `100 x 10 units = 1000 units` = all fee rights
- "first 1000 get 1/1000" = `1000 x 1 unit = 1000 units` = all fee rights
- "first 100 get 1/1000" = `100 x 1 unit = 100 units` = 10% total

## What the agent should say

Say:

- "That would give them a share of the token's fee rights."
- "Each unit gets paid automatically when fees are claimed later."
- "I should map that into 1000 fee-rights units so the split math is exact."

Do not say:

- "They own 1% of the token supply."
- "This is live now" unless the protected-claim flow actually exists.

## Current blockers

1. **Zero-price sale is not live** on current fixed-sale/share-market contracts.
   - `FeeRightsFixedSale.list(..., priceWei)` rejects `priceWei == 0`
   - `HybridShareMarketplace.list(..., pricePerUnitWei)` rejects `pricePerUnitWei == 0`
2. **Password-only pages are not secure enough** by themselves.
   - Real gating should use an allowlist, signed claim, or Merkle proof
3. **Reply → wallet linking** still needs product/backend support
   - Replying on X is not enough by itself; winners must connect/sign with a wallet

## Recommended architecture

1. Deploy token
2. Mint TMPR fee-right receipt
3. Finalize into `1000` hybrid units
4. Create a protected claim campaign:
   - target post / phrase
   - max winners
   - units per wallet
   - optional password
   - optional expiry
   - optional one-per-wallet
5. Winner links wallet and claims units
6. Later claims use the normal hybrid payout flow

## Required params to collect

- token / ticker
- winner cap
- units per winner
- target post or reply phrase
- wallet linking rule
- one-per-wallet or not
- expiry
- leftover-unit handling
- whether the claim should be public, allowlisted, or password-assisted

## Tx explanation rule

Explain every **wallet signature** and every **material custody change** in plain English.

Do not narrate:

- read calls
- simulations
- raw calldata
- poolId / bps / contract internals unless asked

Good:

- "Confirm moving the fee rights into escrow so I can mint the marketplace receipt."
- "Confirm splitting the receipt into 1000 fee-rights units."
- "Confirm creating the protected claim campaign."

Bad:

- "Calling prepareDeposit, then finalizeUnits, then setApprovalForAll..."
