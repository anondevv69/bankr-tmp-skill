# Solana CTO — fees, vault, batch claim

## How the fee vault gets SOL

1. Coin trades on Pump → fees accrue in Pump’s system.  
2. **One-time Pump fee split** (listing page, creator wallet): `updateFeeSharesV2` → **100% to listing `fee-vault` PDA**.  
3. **`distributeCreatorFeesV2`** moves accrued fees into the vault (often bundled with Claim on site).  
4. **`claim_fee_shares_for_all`** syncs pool + pays every SPL receipt holder pro-rata.

## Why Claimable ≈ 0 but pump.fun shows ~0.02 unclaimed

| Balance | Location |
|---------|----------|
| pump.fun “Creator rewards” | Pump UI — not the program fee vault |
| Claimable on site | Only SOL already in **fee vault** (your receipt share) |

Until fee split + distribute, batch claim fails with **InsufficientVault** or **no Pump fee-sharing config**.

## What the user should do

1. Listing page → **Pump fee split** (bonding-curve creator wallet, e.g. from pump.fun coin page).  
2. Wait for trading **or** run **Claim** when vault has funds.  
3. Success: **Batch claim paid N holder(s) in one tx**.

## Not the same

- CTO **contribution** (0.001 SOL) → raise vault → seller at finalize.  
- **Trading fees** → fee vault → receipt holders via batch claim.

## App / program

- Site: tokenmarketplace.shop Solana listing detail  
- Program: `EySP2Vcr2xhBQxSGnroM79Nqh5dv4FoJvnjEsPWvZ7zN`
