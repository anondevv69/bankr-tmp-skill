# Launch Studio — payment rails

**One pipeline** after payment: deploy → mint → split → 1000 units.

**One default rail for all agents (including Bankr):** **site x402** on `tokenmarketplace.shop`.

---

## Site x402 (only default)

| | |
|--|--|
| **Base API** | `POST https://www.tokenmarketplace.shop/api/launch/concierge/run` |
| **Solana API** | `POST https://www.tokenmarketplace.shop/api/launch/concierge/solana/run` |
| **Who pays** | Payer wallet (~$1 USDC) — **Bankr custodial wallet** when in Bankr chat |
| **USDC to** | Site treasury |
| **Facilitator** | Site (PayAI / local Solana) |
| **Agent doc** | **`launch-studio-agent-autopilot.md`** |
| **Browser?** | **No** |

```text
Bankr / Cursor / any agent ──► POST /concierge/run (site x402 sign)
                                    │
                                    ▼
                              executor ──► token + 1000 units
```

---

## Deprecated — Bankr x402 cloud

`x402.bankr.bot/…/token-marketplace-launch` — **do not use** for launches. Separate payment, broken bridge (502), not the site x402 you built for agents.

---

## Last resort — browser

`/launch` on tokenmarketplace.shop — only when agent **cannot** sign x402.

---

## Plain English

> One **~$1 USDC** payment on Token Marketplace — I deploy and deliver **1000 units**. Same for Bankr chat and any agent.
