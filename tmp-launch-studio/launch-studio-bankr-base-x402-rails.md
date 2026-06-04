# Bankr — Base launch x402 rails (Option A vs Option B)

**Load for every Bankr deploy on Token Marketplace (Base).** Pick **one** rail per launch — never both.

**Also read:** `BANKR-LAUNCH-REQUIREMENTS.md` · `launch-studio-agent-autopilot.md` · site `agent.md` § *Bankr on Base*.

---

## Decision (mandatory)

```
if Bankr already collected ~$1 USDC on x402.bankr.bot/…/token-marketplace-launch in THIS session:
  → Option B only (async-start). Do NOT POST /concierge/run again.
elif Bankr can sign site x402 to tokenmarketplace.shop (linked Base wallet):
  → Option A (site x402 on /concierge/run).
else:
  → Say limitation once; browser /launch last resort. Do NOT send orphan USDC to site treasury.
```

| | **Option A — site x402** | **Option B — Bankr cloud prepaid** |
|---|--------------------------|-------------------------------------|
| **When** | Bankr signs **site** x402 with user’s Base wallet | Bankr **already** charged on **`x402.bankr.bot`** |
| **Pay** | `POST …/concierge/run` → 402 → sign → POST + payment header → **202** | **No second USDC** on site |
| **Enqueue** | Same POST after x402 verify | `POST …/async-start` (Bankr server + secret) |
| **Who calls async-start** | **Not** chat agents | **Bankr product** only |
| **Forbidden** | `x402.bankr.bot` then `/concierge/run` (double pay / 402) | `/concierge/run` after bankr.bot pay |
| **Forbidden** | Plain USDC transfer to site treasury without x402 header | Chat agent calling `async-start` without secret |

---

## Option A — site x402 (preferred in Bankr chat when possible)

**Same as website `/launch` (Bankr tab) and CLI `launch-concierge-x402.mjs`.**

1. `GET https://www.tokenmarketplace.shop/api/launch/concierge/config` → `config.x402`, `config.treasury`.
2. Build JSON body (see examples below).
3. `POST https://www.tokenmarketplace.shop/api/launch/concierge/run`
4. **402** → sign **ExactEvm** ~$1 USDC on Base (`eip155:8453`) — use `wrapFetchWithPaymentFromConfig` + `ExactEvmScheme`, **not** a generic “send USDC” tool.
5. **POST again** with `PAYMENT-SIGNATURE` / `payment-signature` + **same JSON body**.
6. **202** + `jobId` + `statusUrl` — only then say “paid” or “processing”.
7. Poll `GET …/status/{jobId}` until `completed` → **`launch-studio-completion-reply.md`**.

**Reference impl:** `fee-rights-exchange/bankr-app/scripts/launch-concierge-x402.mjs`

### Example — B2 wallet_list (600 + 400)

```json
{
  "tokenName": "Base Test2",
  "tokenSymbol": "B2",
  "splitPlan": "wallet_list",
  "deliveryAddress": "0x374d91a5674fa7cf86e725093b5848b97e1e13b4",
  "walletList": "0x374d91a5674fa7cf86e725093b5848b97e1e13b4 600\n0x20Fd91a1949B2731C09BCc6587faB5C89d750E9c 400"
}
```

`deliveryAddress` = **payer** (Bankr linked Base wallet that signed x402). `walletList` lines must sum **1000**.

---

## Option B — Bankr cloud already paid (`async-start`)

**When:** User/Bankr completed **`x402.bankr.bot/…/token-marketplace-launch`** (~$1 USDC) in this flow.

**Do not** `POST /api/launch/concierge/run` — site will return **402** (second payment / wrong signature). **Do not** send another $1 USDC to site treasury.

**Bankr backend** (not chat agent) enqueues:

```http
POST https://www.tokenmarketplace.shop/api/launch/concierge/async-start
Authorization: Bearer <LAUNCH_CONCIERGE_INTERNAL_SECRET>
Content-Type: application/json
```

```json
{
  "source": "bankr-x402",
  "chain": "base",
  "tokenName": "Base Test2",
  "tokenSymbol": "B2",
  "splitPlan": "wallet_list",
  "deliveryAddress": "0x374d91a5674fa7cf86e725093b5848b97e1e13b4",
  "payer": "0x374d91a5674fa7cf86e725093b5848b97e1e13b4",
  "walletList": "0x374d91a5674fa7cf86e725093b5848b97e1e13b4 600\n0x20Fd91a1949B2731C09BCc6587faB5C89d750E9c 400"
}
```

| Field | Option B notes |
|-------|----------------|
| `source` | **`bankr-x402`** (required) |
| `chain` | **`base`** or **`solana`** |
| `deliveryAddress` | For `wallet_list`: **payer** wallet (who paid Bankr x402) |
| `walletList` | Required when `splitPlan` is `wallet_list`; sum **1000** |
| `bankrX402Prepaid` | Set automatically when `source` is `bankr-x402` |

Response: **202** + `jobId` + `statusUrl` — same poll loop as Option A.

**Config:** `GET …/config` → `config.bankrX402.asyncStartUrl`, `jobsConfigured`, `internalAuthConfigured`.

**Solana Option B:** same body with `"chain": "solana"`, Solana pubkeys, after Bankr Solana cloud pay (when supported).

---

## Self-check (Bankr)

1. Did user pay on **bankr.bot** this session? → **Option B** (async-start), not `/concierge/run`.
2. Signing **site** x402 on `tokenmarketplace.shop`? → **Option A** only; never bankr.bot first.
3. Got **202** + new `jobId` before “processing”? → required for both options.
4. Sent USDC to treasury **without** x402 on POST? → **orphan payment** — stop, no retry.

---

## Forbidden (both options)

- `/concierge/run` **after** bankr.bot x402 pay (402 / double charge).
- `POST /concierge/run` with only a USDC transfer tx (no `PAYMENT-SIGNATURE`).
- Chat agent calling `async-start` without Bankr’s internal secret.
- Fake `jobId` or “polling” when `GET status` returns **404**.
