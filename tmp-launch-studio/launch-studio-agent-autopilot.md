# Launch Studio — any-agent autopilot (no browser)

**When:** Any AI agent (Bankr, Cursor, MCP bot, custom script) deploys a **new** token + **1000 units** on Token Marketplace.

**Rule:** If the agent can **sign x402 USDC**, it **must** pay and deploy **programmatically**. **Never** send the user to open Launch Studio in a browser unless the agent **cannot** sign payments at all.

**Completion reply:** **`launch-studio-completion-reply.md`**

---

## Choose payment rail (one payment only)

| Agent has | Base (Bankr token) | Solana (Pump.fun) |
|-----------|-------------------|-------------------|
| **Wallet + USDC + x402 signing** | **Site x402** → `POST /api/launch/concierge/run` | **Site x402** → `POST /api/launch/concierge/solana/run` |
| **Bankr chat / `bankr x402 call` only** | **Bankr x402 cloud** → `POST x402.bankr.bot/…/token-marketplace-launch` | Site Solana x402 (no Bankr x402 Solana endpoint yet) |
| **No signing capability** | Last resort: `/launch?…` deep link | Last resort: `/launch?platform=pump&…` |

**Forbidden for capable agents:** deep links · “connect wallet on the site” · “paste Job ID” when the agent holds `jobId` from its own API call.

---

## Path 1 — Site x402 (default for any agent with a wallet)

Works for **Cursor**, **custom bots**, **MCP agents**, and **Bankr** when it can sign Base/Solana USDC x402 to third-party URLs.

### 1. Config

```http
GET https://www.tokenmarketplace.shop/api/launch/concierge/config
```

Base: `config.x402` · `config.treasury`  
Solana: `config.solana.x402` · `config.solana.treasury`

### 2. Body

```json
{
  "tokenName": "Base Keep Test",
  "tokenSymbol": "BKT",
  "splitPlan": "keep_all",
  "deliveryAddress": "0x374d91a5674fa7cf86e725093b5848b97e1e13b4"
}
```

| Field | Notes |
|-------|-------|
| `tokenName` | min 2 chars |
| `tokenSymbol` | no `$`, max 12 |
| `splitPlan` | `keep_all` or `wallet_list` |
| `deliveryAddress` | EVM `0x…` (Base) or base58 pubkey (Solana) |
| `walletList` | if `wallet_list` — multiline address + amount, **sum = 1000** |

### 3. Pay + enqueue

**Base:** `POST https://www.tokenmarketplace.shop/api/launch/concierge/run`  
**Solana:** `POST https://www.tokenmarketplace.shop/api/launch/concierge/solana/run`

1. POST without payment → **402** with x402 requirements (~$1 USDC).  
2. Sign USDC authorization with payer wallet (EIP-3009 on Base; Solana scheme on mainnet).  
3. POST again with `PAYMENT-SIGNATURE` / `payment-signature` header + same JSON.  
4. **202** → `{ jobId, statusUrl }`.

**Libraries:** `@x402/core` + `@x402/fetch` + `@x402/evm` (`ExactEvmScheme`, `eip155:8453`) or `@x402/svm` for Solana.  
**Reference:** `bankr-app/src/lib/runConciergeLaunch.ts` · `solanaConciergeX402Pay.ts`

### 4. Poll

```http
GET https://www.tokenmarketplace.shop/api/launch/concierge/status/{jobId}
```

Every **15–30s** until `status` is `completed` or `failed` (Base ~1–3 min; Solana up to ~10 min).

### 5. Reply

Format per **`launch-studio-completion-reply.md`** — BaseScan, OpenSea, Doppler, profile, tx log.

---

## Path 2 — CLI (agents with shell + private key)

From `fee-rights-exchange/bankr-app` (deps installed):

```bash
export PRIVATE_KEY=0x...          # payer with ≥$1 USDC on Base
export BASE_RPC_URL=https://mainnet.base.org   # optional

node scripts/launch-concierge-x402.mjs \
  --name "Base Keep Test" \
  --symbol BKT \
  --delivery 0x374d91a5674fa7cf86e725093b5848b97e1e13b4 \
  --split keep_all \
  --json
```

Agent flow: run script → parse JSON → reply with links. **No browser.**

---

## Path 3 — Bankr x402 cloud (Bankr-native agents · Base only)

When the agent only has **`bankr x402 call`** (not site URL signing):

```http
POST https://x402.bankr.bot/{linkedWallet}/token-marketplace-launch
```

Same JSON body as Path 1. Bankr facilitator collects ~$1 USDC **in chat**. Poll `statusUrl` from response.

**502:** sync `LAUNCH_CONCIERGE_INTERNAL_SECRET` on Vercel + `bankr x402 env set` — see `x402-cloud/README.md`.  
If 502 persists and agent **can** sign site x402 → use **Path 1** instead (different payment, do not double-pay).

Details: **`launch-studio-bankr-chat-autopilot.md`**

---

## Path 4 — Browser (last resort only)

Use **only** when the agent **cannot** sign x402 (no wallet tools, no CLI, no Bankr x402).

```text
https://www.tokenmarketplace.shop/launch?surface=bankr&platform=bankr&wallet=0x…&name=…&symbol=…&split=keep_all
```

Tell the user this is a **fallback** because automated payment is unavailable.

---

## Agent decision tree

```text
User: "Deploy BKT, 1000 units to my wallet"
        │
        ├─ Can sign site x402 (Base wallet + USDC)?
        │     YES → Path 1 (or Path 2 CLI) → poll → completion reply
        │
        ├─ Bankr chat with x402 tool only?
        │     YES → Path 3 → poll → completion reply
        │
        └─ No payment signing at all?
              → Path 4 (browser fallback) — explain why
```

---

## Plain English (while agent works)

> Launching **$BKT** now — one **~$1 USDC** payment from your wallet, then deploy + 1000 units to you. I’ll post links when it finishes (~1–3 min). You don’t need to open the website.

---

## Not Launch Studio

| User says | Route |
|-----------|-------|
| Split **existing** $t7 into 1000 | Main TMP **`fractionalize-autopilot.md`** |
| List / claim / transfer after launch | Main TMP sell / claim / transfer autopilots |
