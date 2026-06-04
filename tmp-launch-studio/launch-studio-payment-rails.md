# Launch Studio — payment rails

**Same pipeline after payment** (deploy → mint → split → 1000 units). **Different payment entry points.**

---

## Rule for agents (2026-06)

| User is on | **Default payment** | Agent action |
|------------|---------------------|--------------|
| **Bankr chat / @bankrbot / X / terminal** | **Site x402** on Launch Studio | Open `/launch?surface=bankr&wallet=…` — user pays with **Bankr wallet** |
| **tokenmarketplace.shop / Launch Studio UI** | **Site x402** | User pays in browser (same rail as Bankr handoff) |
| **Agent with programmatic x402 + user wallet** | **Site x402** | `POST /api/launch/concierge/run` + poll status |
| **Solana on site** | **Site Solana x402** | `/launch` Solana tab |
| **Legacy ops** | Bankr x402 cloud | `x402.bankr.bot/…/token-marketplace-launch` — not default for members |

**Forbidden:**

- Defaulting Bankr members to **Bankr x402 cloud** when site x402 + deep link works.
- Calling **`/concierge/run` after Bankr x402 cloud pay** (different rails).
- Saying one payment covers both Bankr x402 cloud and site x402.

---

## Primary — Site x402 (Bankr + website)

| | |
|--|--|
| **Entry** | https://www.tokenmarketplace.shop/launch |
| **Bankr handoff** | `?surface=bankr&wallet=0x…&name=…&symbol=…&split=keep_all` |
| **API** | `POST /api/launch/concierge/run` (Base) |
| **Who pays** | User’s wallet (**Bankr custodial or EOA**) — ~$1 USDC on Base |
| **USDC to** | `LAUNCH_CONCIERGE_TREASURY` (site) |
| **Facilitator** | Site (e.g. PayAI) |
| **Settlement** | After pipeline success |
| **Delivery** | 1000 units → `deliveryAddress` (Bankr wallet for keep_all) |
| **Skill** | `launch-studio-autopilot.md` |

```text
Bankr user ──► Launch Studio (site x402, Bankr wallet pays)
                    │
                    ▼ /concierge/run verifies payment
              tokenmarketplace.shop executor ──► token + 1000 units → Bankr wallet
```

---

## Legacy — Bankr x402 cloud (ops / future chat-native pay)

| | |
|--|--|
| **Entry** | Bankr chat CLI `bankr x402 call` on `x402.bankr.bot` |
| **USDC to** | Bankr x402 payTo |
| **Site hook** | `async-start` + secret (`bankrX402Prepaid`) |
| **Status** | Ops-blocked (502) until secret sync + handler redeploy |
| **Member default?** | **No** — use site x402 handoff |

---

## What is shared

- Same **concierge executor** (deploy, mint, V6 split, deliver).
- Same **job store** (`/api/launch/concierge/status/{jobId}`).
- Same **TMP skills after launch**.

---

## Plain English

**Good (Bankr member):**

> I’ll open **Launch Studio** on tokenmarketplace.shop. Connect your **Bankr wallet**, pay **~$1 USDC once**, and all **1000 units** land in that wallet in a few minutes.

**Bad:**

> Pay in Bankr chat x402 (when cloud bridge is down) · “Same payment on either rail”
