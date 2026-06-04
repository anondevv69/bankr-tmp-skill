# Launch Studio — Bankr chat autopilot (zero manual steps · Base)

**When:** User is in **Bankr chat / X / terminal** and asks to **deploy / launch a new token** on Token Marketplace (Base / Bankr token).

**Prefer:** **`launch-studio-agent-autopilot.md`** Path 1 (site x402) if Bankr can sign external x402 to `tokenmarketplace.shop`.  
**This file:** Path 3 when the agent only has **`bankr x402 call`** on `x402.bankr.bot`.

**Read with:** `launch-studio-completion-reply.md` · `launch-studio-user-language.md` · `launch-studio-payment-rails.md`

---

## Default — Bankr x402 cloud (Rail A)

| Step | Agent action |
|------|----------------|
| 1 | Resolve linked **Bankr EVM wallet** (`0x…`) → `deliveryAddress` |
| 2 | Map plain English → `tokenName`, `tokenSymbol`, `splitPlan` (`keep_all` or `wallet_list`) |
| 3 | **Call Bankr x402** `token-marketplace-launch` — POST with JSON body (see below) |
| 4 | User confirms **~$1 USDC once in Bankr** (custodial wallet) — **not** on tokenmarketplace.shop |
| 5 | **Poll** `statusUrl` from the x402 response every **15–30s** until `completed` or `failed` (1–3 min) |
| 6 | Reply with **full deployment receipt** — **`launch-studio-completion-reply.md`** |

### x402 endpoint (Base only)

```text
POST https://x402.bankr.bot/{linkedWallet}/token-marketplace-launch
```

Example wallet in path: `0x374d91a5674fa7cf86e725093b5848b97e1e13b4` (use the member’s linked wallet).

**Body (JSON):**

```json
{
  "tokenName": "Base Keep Test",
  "tokenSymbol": "BKT",
  "splitPlan": "keep_all",
  "deliveryAddress": "0x374d91a5674fa7cf86e725093b5848b97e1e13b4"
}
```

For `wallet_list`, add `walletList` (multiline `0x… amount`, **sum = 1000**).

**How to invoke in Bankr:** use the platform **x402 / paid API call** tool (same as `bankr x402 call … -X POST -d '{…}'` in terminal). Do **not** paste raw CLI to the user unless they ask.

**Poll:**

```http
GET https://www.tokenmarketplace.shop/api/launch/concierge/status/{jobId}
```

Use `jobId` and `statusUrl` from the x402 **200** response.

---

## Forbidden (Bankr chat · Base deploy)

| Do not | Why |
|--------|-----|
| Send Launch Studio deep link as the **primary** path | User asked Bankr to do it — not a browser handoff |
| Say “open the site, connect wallet, pay x402” | That is **Rail B** (manual) |
| Stop after x402 pay without **polling** `statusUrl` | Job runs async 1–3 min |
| Stop after `completed` without **full links** | **`launch-studio-completion-reply.md`** is mandatory |
| Call **`/concierge/run`** after Bankr x402 pay | Double rail / double charge |
| Call **`async-start`** yourself | Internal secret — only Bankr x402 handler |

---

## Plain English while working

**Good:**

> Paying **~$1 USDC** from your Bankr wallet to launch **Base Keep Test ($BKT)** and deliver all **1000 units** to `0x374d…`. I’ll post your receipt with BaseScan and profile links when the job finishes (~1–3 min).

**Bad:**

> Open Launch Studio · connect wallet · pay on the site · paste Job ID back

---

## If x402 returns 502

The Bankr x402 handler could not enqueue on the site (`async-start` auth bridge).

1. Tell the user: **one-time ops** — `LAUNCH_CONCIERGE_INTERNAL_SECRET` must match on **Vercel production** and **Bankr x402 env** (`bankr x402 env set …`). See `fee-rights-exchange/x402-cloud/README.md` § Troubleshooting 502.
2. Verify: `GET …/api/launch/concierge/config` → `bankrX402.internalAuthConfigured` is `true`.
3. **Only then** offer **Rail B** fallback: Launch Studio deep link (manual site pay) — label it clearly as temporary.

Do **not** default to manual Launch Studio when the user asked for full Bankr automation.

---

## Solana (Pump.fun)

There is **no** Bankr x402 cloud endpoint for Solana yet. For Pump launches in Bankr chat, use **site Solana x402** (`platform=pump` deep link) until a chat-native Solana x402 exists. See **`launch-studio-autopilot.md`** § Solana.

---

## Intent mapping

| User says | x402 body |
|-----------|-----------|
| Deploy BKT on Token Marketplace, all 1000 to my wallet | `tokenName`, `tokenSymbol: BKT`, `splitPlan: keep_all`, `deliveryAddress: linked wallet` |
| Launch MOON, airdrop 400/600 to two wallets | `splitPlan: wallet_list`, `walletList: …`, `deliveryAddress: payer wallet` |
| Split **existing** $t7 | **NOT Launch Studio** → main TMP **`fractionalize-autopilot.md`** |
