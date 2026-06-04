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
**Any agent (Cursor, MCP, Bankr, bots):** **`launch-studio-agent-autopilot.md`** — site x402 API or CLI, poll, full receipt. **No browser.**  
**Bankr chat (x402.cloud only):** **`launch-studio-bankr-chat-autopilot.md`** when site x402 signing unavailable.  
**Payment rails:** **`launch-studio-payment-rails.md`**.

**Payment:** Capable agents pay **site x402** (~$1 USDC) programmatically. Bankr cloud x402 is an alternate Base rail when site signing is unavailable.

Mint / list / claim / send units on an **existing** launch still use the **main** TMP skill (`fractionalize-autopilot.md`, `sell-list-autopilot.md`, etc.). This companion is **only** for **new deploy + split + deliver** in one concierge job.

---

## When to load this skill

| User says | Flow |
|-----------|------|
| Launch / deploy a **new** token on Token Marketplace | **`launch-studio-agent-autopilot.md`** |
| Deploy $MOON and give me all 1000 units | **`launch-studio-agent-autopilot.md`** · `splitPlan: keep_all` |
| Launch and airdrop 100/400/500 to these wallets | **`launch-studio-agent-autopilot.md`** · `wallet_list` |
| Launch Studio / pay once and you sign everything | **`launch-studio-agent-autopilot.md`** |
| Bankr chat · only `bankr x402 call` available | **`launch-studio-bankr-chat-autopilot.md`** |
| Split **existing** $t7 into 1000 | **Main TMP** · **`fractionalize-autopilot.md`** — **NOT** Launch Studio |

**User does not need:** “use Launch Studio skill”, “call x402”, “poll statusUrl”, or pasted API URLs.

---

## Plain English vs agent work

| User-facing (yes) | Agent-internal (never require from user) |
|-------------------|------------------------------------------|
| “Launch MOON on Token Marketplace” | Bankr x402 `token-marketplace-launch` + poll |
| “All 1000 units to my wallet” | `splitPlan: keep_all`, `deliveryAddress` = linked Bankr wallet |
| “Airdrop 400 to 0xabc…, 600 to 0xdef…” | `splitPlan: wallet_list`, `walletList` sum 1000 |
| “~$1 USDC one payment” | Bankr x402 in chat (Base) |
| “Is it done yet?” | Poll `status/{jobId}` — agent owns the jobId from x402 response |

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

1. **`launch-studio-agent-autopilot.md`** — **any agent** (site x402, CLI, no browser)
2. **`launch-studio-bankr-chat-autopilot.md`** — Bankr x402.cloud when site signing unavailable
3. **`launch-studio-payment-rails.md`** — rails + forbidden double-pay
4. **`launch-studio-user-language.md`** — plain English
5. **`launch-studio-completion-reply.md`** — mandatory Done reply
6. **`launch-studio-autopilot.md`** — quick index + last-resort deep links

---

## Platform notes

| Chain | Any agent (default) | Browser last resort |
|-------|---------------------|---------------------|
| **Base** | Site x402 · `POST /concierge/run` · `scripts/launch-concierge-x402.mjs` | `/launch?platform=bankr&wallet=0x…` |
| **Solana** | Site x402 · `POST /concierge/solana/run` | `/launch?platform=pump&solWallet=…` |

Do **not** refuse Solana launch — send user to **https://www.tokenmarketplace.shop/launch** with plain steps (connect Solana, choose wallet list or keep all).
