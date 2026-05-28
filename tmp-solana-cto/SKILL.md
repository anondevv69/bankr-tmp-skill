---
name: tmp-solana-cto
description: Solana CTO fee rights on Token Marketplace — Pump fee split to fee vault, SPL receipt units (1000), batch claim for all holders. Install alongside main TMP Base skill.
tags: [bankr, solana, tmp, pump, cto, fee-rights, token-marketplace]
version: 1
tmp_skill_version: "1"
homepage: https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-solana-cto
---

# TMP Solana CTO & fee claims

**Install:**

```text
install TMP skills at https://github.com/anondevv69/bankr-tmp-skill
install TMP Solana CTO at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-solana-cto
```

Base (t7, dual list, TMPR) stays in the **main** skill at repo root.

---

## User vocabulary

| User says | Meaning |
|-----------|---------|
| Solana CTO / contributed SOL | Raise on listing; receipt SPL units pro-rata |
| Claim fees / batch claim | One tx pays **all** SPL receipt holders from **fee vault** |
| Pump creator rewards | **Not** the same as vault claimable — see references |

---

## Read first

**solana-cto-fees-and-claim.md** — Pump fee split → fee vault → distribute → batch claim; why Claimable ≈ 0 while pump.fun shows unclaimed SOL.

---

## Program (mainnet)

`EySP2Vcr2xhBQxSGnroM79Nqh5dv4FoJvnjEsPWvZ7zN` — TakeoverListings

---

## Agent rules

1. **CTO complete** ≠ fees in vault — check Pump fee split step (100% to fee vault PDA).  
2. **Claim** runs Pump **distribute** (when sharing config exists) + **`claim_fee_shares_for_all`**.  
3. CTO contribution SOL is **not** trading fees in the fee vault.  
4. Pump **creator rewards** on pump.fun go to creator until fee split + distribute into vault.
