# Launch Studio autopilot — Bankr x402 only (Rail A)

**User language:** `launch-studio-user-language.md`  
**Payment rails:** **`launch-studio-payment-rails.md`** — Bankr x402 ≠ website x402. This file is **Bankr chat/agents only**. Do **not** send users to site `/api/launch/concierge/run` after Bankr x402 pay.  
**Companion install:** `install TMP Launch Studio at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-launch-studio`

---

## Bankr x402 vs website (one line)

| | **Bankr x402 (this doc)** | **Website Launch Studio** |
|--|---------------------------|---------------------------|
| Payment | Bankr facilitator → Bankr payTo | Site facilitator → site treasury |
| Agent action | `x402.bankr.bot/…/token-marketplace-launch` | User opens `/launch` in browser |
| Site API | `async-start` + secret (`bankrX402Prepaid`) | `/concierge/run` + site x402 headers |

---

## When this flow applies

| Trigger | Use Launch Studio x402 | Use main TMP instead |
|---------|------------------------|----------------------|
| Deploy **new** token + 1000 units | **Yes** | — |
| “Split **existing** $t7 into 1000” | **No** | `fractionalize-autopilot.md` |
| “Create NFT for existing launch” | **No** | `mint-pending-deposit.md` |
| Solana / Pump.fun deploy | **No** (site UI) | Send to `/launch` |
| `receipt_only` (NFT only, no units) | **No** on x402 | Site UI if enabled |

---

## x402 service

| Field | Value |
|-------|--------|
| **URL** | `https://x402.bankr.bot/0x374d91a5674fa7cf86e725093b5848b97e1e13b4/token-marketplace-launch` |
| **Method** | POST |
| **Payment** | ~**$1 USDC** on Base via **Bankr x402** (Bankr facilitator — not site treasury) |
| **Bankr CLI test** | `bankr x402 schema <url>` · `bankr x402 call <url> -i` |

---

## Request body (agent maps from plain English)

| Field | Required | Values |
|-------|----------|--------|
| `tokenName` | yes | Display name, min 2 chars |
| `tokenSymbol` | yes | Ticker without `$`, max 12 |
| `splitPlan` | yes | `keep_all` or `wallet_list` |
| `deliveryAddress` | yes | `0x` + 40 hex — linked Bankr wallet |
| `walletList` | if `wallet_list` | Multiline: `0xAddress amount` per line, **sum = 1000** |
| `imageUrl` | no | https image |
| `websiteUrl` | no | https |
| `tweetUrl` | no | https |

**`deliveryAddress` rules:**

- **`keep_all`:** wallet that receives **all 1000** units (use linked Bankr wallet).
- **`wallet_list`:** **payer** wallet (x402 payer) — units go to **`walletList`**, not to `deliveryAddress`.

**`walletList` example (totals 1000):**

```text
0x1111111111111111111111111111111111111111 400
0x2222222222222222222222222222222222222222 350
0x3333333333333333333333333333333333333333 250
```

Parse user paste (“100 to alice, 400 to bob…”) into this format silently.

---

## Agent steps (same thread — do not stop after x402 pay)

1. **Resolve** linked Bankr wallet → `deliveryAddress` (unless user gave a different recipient for keep_all).
2. **Confirm** name + ticker + plan (only if missing from user message).
3. **Call x402** `token-marketplace-launch` with JSON body (Bankr pays USDC via x402).
4. **Read response:** `jobId`, `statusUrl`, `status` (`queued`).
5. **Poll** `GET statusUrl` every **15–30s** until `status` is **`completed`** or **`failed`** (typically 1–3 min).
6. **On completed:** read `result.tokenAddress`, `result.splitPlan`, `result.links`, `result.steps`.
7. **Reply** using `launch-studio-user-language.md` success template + links:
   - `https://www.tokenmarketplace.shop/profile?tab=nfts`
   - `https://bankr.bot/launches/{tokenAddress}`
   - `https://app.doppler.lol/tokens/base/{tokenAddress}`
8. **Offer next TMP actions** (list / transfer / claim) — one line, no reinstall lecture.

**Forbidden:** stop after x402 with “job started” and no poll · expose `LAUNCH_CONCIERGE_INTERNAL_SECRET` · use x402 for Solana.

---

## Status poll response

`GET https://www.tokenmarketplace.shop/api/launch/concierge/status/{jobId}`

| `status` | Action |
|----------|--------|
| `queued` / `running` | Wait, poll again |
| `completed` | Use `result` — token + txs |
| `failed` | Plain English from `error`; mention payment may not have settled |

**Result fields (completed):**

- `tokenAddress` — launch ERC-20 on Base
- `receiptTokenId` — hybrid TMPR id for units
- `splitPlan`, `deliveryAddress`
- `links.token`, `links.receipt`, `links.opensea`
- `steps[]` — pipeline log (optional detail if user asks)

---

## Intent mapping (one-line)

| User says | `splitPlan` | Extra |
|-----------|-------------|-------|
| all units / keep all / 1000 to me | `keep_all` | — |
| airdrop / split to wallets / team list | `wallet_list` | parse `walletList`, verify sum 1000 |
| deploy MOON, name Moon Token | — | `tokenName`, `tokenSymbol` |

---

## Errors (user-facing)

| Error / case | Reply |
|--------------|-------|
| **502 / endpoint unavailable** after Bankr x402 pay | **1)** `LAUNCH_API_BASE_URL` must be **`https://www.tokenmarketplace.shop`** (with **www** — apex `tokenmarketplace.shop` has no DNS → 502). **2)** `LAUNCH_CONCIERGE_INTERNAL_SECRET` must match Vercel exactly. Check config: `bankrX402.internalAuthConfigured`. Redeploy Bankr x402 after env fix. **Rail B fallback** (separate payment): https://www.tokenmarketplace.shop/launch |
| Wallet launch limit (429) | “This wallet already used its Launch Studio limit — try another wallet or https://www.tokenmarketplace.shop/launch” |
| `walletList` sum ≠ 1000 | “Amounts must total exactly 1000 units — you have X, need Y more.” |
| Job failed mid-pipeline | Explain step from `error`; payment usually not charged on failure |
| User asks Solana on Bankr | Site link `/launch` + Connect Solana |

---

## Distinction from Flow C (fractionalize)

| | **Launch Studio (this file)** | **Flow C fractionalize** |
|--|--------------------------------|----------------------------|
| Token | **Creates new** Bankr deploy | **Existing** launch token |
| User signs | **One x402 payment** | Multiple Base txs (mint → split) |
| Entry | x402 POST | `GET /api/mint/status` |
| Best for | “Launch MOON with 1000 units” | “Split my t7 into 1000” |

---

## QA prompts

See main hub **`references/bankr-agent-test-prompts.md`** § Launch Studio.
