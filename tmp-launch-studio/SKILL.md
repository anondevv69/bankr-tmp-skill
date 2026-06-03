---
name: tmp-launch-studio
description: >-
  Token Marketplace Launch Studio — deploy a new Bankr token on Base, mint fee-rights,
  split into 1000 units, and deliver or airdrop in one paid x402 flow (~$1 USDC).
  Pairs with main TMP skills for list/claim/transfer after launch. Install alongside bankr-fee-rights.
tags: [bankr, base, tmp, token-marketplace, launch-studio, x402, deploy, split, airdrop, fee-rights]
version: 1
tmp_skill_version: "1"
homepage: https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-launch-studio
---

# TMP Launch Studio (deploy + 1000 units in one flow)

**Install with main TMP skill:**

```text
install TMP skills at https://github.com/anondevv69/bankr-tmp-skill
install TMP Launch Studio at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-launch-studio
```

**Human UI (any chain):** https://www.tokenmarketplace.shop/launch  
**Bankr agent path (Base only):** **Bankr x402** `token-marketplace-launch` — see **`launch-studio-autopilot.md`**.

**Two payment rails (mandatory):** **`launch-studio-payment-rails.md`** — Bankr x402 (chat/agents) and website x402 (Launch Studio UI) are **separate** USDC payments, facilitators, and treasuries. Same deploy pipeline after enqueue; **never** mix APIs across rails.

Mint / list / claim / send units on an **existing** launch still use the **main** TMP skill (`fractionalize-autopilot.md`, `sell-list-autopilot.md`, etc.). This companion is **only** for **new deploy + split + deliver** in one concierge job.

---

## When to load this skill

| User says | Flow |
|-----------|------|
| Launch / deploy a **new** token on Token Marketplace | **`launch-studio-autopilot.md`** |
| Deploy $MOON and give me all 1000 units | **`launch-studio-autopilot.md`** · `splitPlan: keep_all` |
| Launch and airdrop 100/400/500 to these wallets | **`launch-studio-autopilot.md`** · `splitPlan: wallet_list` |
| Launch Studio / pay once and you sign everything | **`launch-studio-autopilot.md`** |
| Split **existing** $t7 into 1000 | **Main TMP** · **`fractionalize-autopilot.md`** — **NOT** Launch Studio |

**User does not need:** “use Launch Studio skill”, “call x402”, “poll statusUrl”, or pasted API URLs.

---

## Plain English vs agent work

| User-facing (yes) | Agent-internal (never require from user) |
|-------------------|------------------------------------------|
| “Launch MOON on Token Marketplace” | `token-marketplace-launch` x402 POST |
| “All 1000 units to my wallet” | `splitPlan: keep_all`, `deliveryAddress` = linked wallet |
| “Airdrop 400 to 0xabc…, 600 to 0xdef…” | `splitPlan: wallet_list`, `walletList` multiline |
| “~$1 USDC one payment” | x402 settle on Base |
| “Is it done yet?” | Poll `statusUrl` every 15–30s |

Full phrase table: **`launch-studio-user-language.md`**.

---

## After launch — hand off to main TMP skills

| User wants next | Main TMP autopilot |
|-----------------|-------------------|
| List fee rights for 0.01 ETH | `sell-list-autopilot.md` |
| Send / gift units to friends | `transfer-units-autopilot.md` |
| Claim fees for holders | `hybrid-claim-autopilot.md` |
| Buy shares on someone else’s launch | `buy-marketplace-autopilot.md` |

---

## Read first (this folder)

1. **`launch-studio-payment-rails.md`** — Bankr x402 vs website x402 (**separate payments**)
2. **`launch-studio-user-language.md`** — what users say; what you reply
3. **`launch-studio-autopilot.md`** — Bankr x402 only: call, poll, errors

---

## Platform notes

| Chain | Bankr agent (Rail A) | Website (Rail B) |
|-------|----------------------|------------------|
| **Base (Bankr deploy)** | **Bankr x402** — `token-marketplace-launch` | https://www.tokenmarketplace.shop/launch — **site x402** (different payment) |
| **Solana (Pump.fun)** | **Not on Bankr x402** | Launch Studio UI + Solana wallet |

Do **not** refuse Solana launch — send user to **https://www.tokenmarketplace.shop/launch** with plain steps (connect Solana, choose wallet list or keep all).
