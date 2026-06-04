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
**Bankr members (chat / X / terminal):** **Site x402** on Launch Studio with **Bankr wallet** — see **`launch-studio-autopilot.md`** (deep link handoff).  
**Legacy ops:** Bankr x402 cloud on `x402.bankr.bot` — not the default for members; see **`launch-studio-payment-rails.md`**.

**Payment:** Bankr users pay **site x402** (~$1 USDC on Base) on tokenmarketplace.shop — same deploy pipeline as the website. Bankr x402 cloud is a separate rail (ops-only).

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
| “Launch MOON on Token Marketplace” | Launch Studio deep link + site x402 |
| “All 1000 units to my wallet” | `split=keep_all`, `wallet=` = linked Bankr wallet |
| “Airdrop 400 to 0xabc…, 600 to 0xdef…” | `split=wallet_list` or user fills list on site |
| “~$1 USDC one payment” | Site x402 on `/launch` (Bankr wallet) |
| “Is it done yet?” | User confirms on Launch Studio page, or poll `status/{jobId}` if shared |

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

1. **`launch-studio-payment-rails.md`** — site x402 (primary) vs legacy Bankr x402 cloud
2. **`launch-studio-user-language.md`** — what users say; what you reply
3. **`launch-studio-completion-reply.md`** — **mandatory Done reply** (BaseScan, OpenSea, Doppler, txs — match website)
4. **`launch-studio-autopilot.md`** — handoff deep link + poll Job ID

---

## Platform notes

| Chain | Bankr member (default) | Website / agents |
|-------|------------------------|-------------------|
| **Base (Bankr deploy)** | Site x402 · `/launch?platform=bankr&wallet=0x…` | `POST /api/launch/concierge/run` |
| **Solana (Pump.fun)** | Site x402 · `/launch?platform=pump&solWallet=…` | `POST /api/launch/concierge/solana/run` |

Do **not** refuse Solana launch — send user to **https://www.tokenmarketplace.shop/launch** with plain steps (connect Solana, choose wallet list or keep all).
