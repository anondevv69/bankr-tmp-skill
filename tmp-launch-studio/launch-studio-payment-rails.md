# Launch Studio — two payment rails (read before any launch)

**Same pipeline after payment** (deploy → mint → split → 1000 units). **Different payment systems.** Never conflate them.

---

## Rule for agents

| User is on | Payment rail | You use |
|------------|--------------|---------|
| **Bankr chat / @bankrbot / Bankr agent** | **Bankr x402** | `token-marketplace-launch` on `x402.bankr.bot` → poll `statusUrl` |
| **tokenmarketplace.shop / Launch Studio UI** | **Website x402** | User pays in browser — **you do not call Bankr x402** |
| **Solana on site** | **Website Solana x402** | `/launch` + Connect Solana — **not** Bankr x402 |

**Forbidden:**

- Calling **website** `/api/launch/concierge/run` when user paid via **Bankr** x402 (already paid on Bankr rail).
- Calling **Bankr x402** when user is on the **website** (different treasury, different facilitator).
- Saying “same x402 payment” or “same ~$1 flow” as if one payment covers both — **each rail collects USDC separately**.

---

## Rail A — Bankr x402 (agents only)

| | |
|--|--|
| **Entry** | Bankr chat, CLI `bankr x402 call`, any agent with Bankr x402 |
| **Endpoint** | `https://x402.bankr.bot/0x374d91a5674fa7cf86e725093b5848b97e1e13b4/token-marketplace-launch` |
| **Who verifies payment** | **Bankr** (x402 Cloud wraps handler; payment before handler runs) |
| **Facilitator** | `https://api.bankr.bot/facilitator` (Bankr — not the site) |
| **USDC recipient** | Bankr x402 **payTo** wallet (Bankr-hosted — **not** `LAUNCH_CONCIERGE_TREASURY`) |
| **How site is notified** | Bankr handler → `POST /api/launch/concierge/async-start` with shared secret |
| **Site payment check** | **Skipped** — job flagged `bankrX402Prepaid: true` (Bankr already collected) |
| **Skill file** | `launch-studio-autopilot.md` |

| **502 / auth errors** on this rail | Fix **Bankr x402 env** + Vercel `LAUNCH_CONCIERGE_INTERNAL_SECRET` sync. **`LAUNCH_API_BASE_URL` must be `https://www.tokenmarketplace.shop`** (with **www** — apex has no DNS). **Not** website x402 env. |

---

## Rail B — Website x402 (Launch Studio UI)

| | |
|--|--|
| **Entry** | https://www.tokenmarketplace.shop/launch |
| **API** | `POST /api/launch/concierge/run` (Base) or `…/solana/run` (Solana) |
| **Who verifies payment** | **Token Marketplace** (Vercel `conciergeX402.js` / Solana x402) |
| **Facilitator** | Site-configured (e.g. PayAI on Base; local/Solana on Pump path) |
| **USDC recipient** | `LAUNCH_CONCIERGE_TREASURY` (Base) or `LAUNCH_CONCIERGE_SOLANA_TREASURY` |
| **Settlement** | After pipeline **success** on site |
| **Bankr x402** | **Not involved** — no `async-start`, no Bankr facilitator |

User pays **again** if they already tried Bankr x402 and it failed — failed Bankr attempt does **not** count as site payment.

---

## What is shared (both rails)

- Same **concierge executor** (deploy, mint, V6 split, deliver/airdrop).
- Same **job store** (`/api/launch/concierge/status/{jobId}`) once queued.
- Same **TMP skills after launch** (list, claim, transfer units).

---

## Plain English for users

**Good (Bankr):**

> I’ll start your launch through **Bankr’s Launch Studio payment** (~$1 USDC on Base), then poll until your 1000 units land in your wallet.

**Good (website):**

> Open **Launch Studio on tokenmarketplace.shop**, connect your wallet, and pay there — that’s a **separate** site payment, not the same as paying in Bankr chat.

**Bad:**

> “It’s all the same x402” · “Pay once on either site or Bankr interchangeably” · “Use the website API after Bankr x402 pay”

---

## Quick diagram

```text
Bankr chat ──► Bankr x402 (USDC → Bankr payTo)
                    │
                    ▼ async-start + secret (prepaid flag)
              tokenmarketplace.shop executor ──► token + 1000 units

Browser /launch ──► Website x402 (USDC → site treasury)
                    │
                    ▼ /concierge/run verifies payment on site
              same executor ──► token + 1000 units
```
