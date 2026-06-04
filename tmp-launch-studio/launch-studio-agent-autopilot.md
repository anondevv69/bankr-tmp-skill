# Launch Studio — any-agent autopilot (no browser)

**When:** Any AI agent — **Bankr**, Cursor, MCP bot, custom script — deploys a **new** token + **1000 units**.

**One payment rail:** **site x402** on `tokenmarketplace.shop`. Bankr signs the same x402 as every other agent.

**Rule:** Pay and deploy **programmatically**. **Never** default to Launch Studio in a browser.

**Completion reply:** **`launch-studio-completion-reply.md`**

**Async (mandatory):** **`launch-studio-async-polling.md`** — poll after 202; never “didn’t submit this turn” / “tell me to retry” before poll.

---

## Site x402 — the only default (Base + Solana)

### 1. Config

```http
GET https://www.tokenmarketplace.shop/api/launch/concierge/config
```

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
| `deliveryAddress` | EVM `0x…` (Base) or base58 (Solana) |
| `walletList` | if `wallet_list` — sum = **1000** |

### 3. Pay + enqueue

| Chain | Endpoint |
|-------|----------|
| **Base** | `POST https://www.tokenmarketplace.shop/api/launch/concierge/run` |
| **Solana** | `POST https://www.tokenmarketplace.shop/api/launch/concierge/solana/run` |

1. POST → **402** (~$1 USDC x402 requirements).  
2. Sign USDC with payer wallet (**Bankr custodial wallet** counts).  
3. POST again with `PAYMENT-SIGNATURE` / `payment-signature` + same JSON.  
4. **202** → `{ jobId, statusUrl }`.

**Bankr:** use site x402 signing tools to **`tokenmarketplace.shop`** — same as Launch Studio UI, no browser.

**Reference:** `bankr-app/src/lib/runConciergeLaunch.ts` · `@x402/fetch` + `@x402/evm` / `@x402/svm`

### 4. Poll

```http
GET https://www.tokenmarketplace.shop/api/launch/concierge/status/{jobId}
```

Every **15–30s** until `completed` or `failed`. **Do not** tell the user to retry or that you “didn’t submit a transaction this turn” while status is `queued` or `running`. See **`launch-studio-async-polling.md`**.

### 5. Reply

**`launch-studio-completion-reply.md`** — BaseScan, OpenSea, Doppler, profile, txs.

---

## CLI (optional — agents with shell + key)

```bash
cd fee-rights-exchange/bankr-app
export PRIVATE_KEY=0x...
node scripts/launch-concierge-x402.mjs \
  --name "Base Keep Test" --symbol BKT \
  --delivery 0x374d... --split keep_all --json
```

Same site x402 rail as Path above.

---

## Browser — last resort only

Use **`/launch?…`** only when the agent **cannot** sign x402 at all.

---

## Solana / Pump.fun

**Read:** **`launch-studio-solana-autopilot.md`**

Same site x402 flow via `POST …/concierge/solana/run`. `deliveryAddress` = **Solana pubkey**, not `0x…`.

---

## Deprecated — do not use

```text
POST https://x402.bankr.bot/…/token-marketplace-launch   ❌
```

Legacy Bankr x402 cloud — separate treasury, `async-start` bridge, 502-prone. **Not** the site x402 rail.

---

## Forbidden

- Deep link as default · “connect wallet on the site” · “ops manual deploy”  
- **`x402.bankr.bot`** for deploy · double-pay site + Bankr cloud  
- Stopping after pay without polling **`status/{jobId}`**

---

## Plain English

> Launching **$BKT** — **~$1 USDC** via Token Marketplace x402 from your Bankr wallet. I’ll post links in ~1–3 min. No website visit needed.
