# Launch Studio — any-agent autopilot (no browser)

**When:** Any AI agent — **Bankr**, Cursor, MCP bot, custom script — deploys a **new** token + **1000 units**.

**Parity rule:** Same as a human on **`/launch`** — only **who fills JSON** and **who signs x402** differs. Read **`launch-studio-website-parity.md`** and **`tmp-site-agent/agent-guide.md`** § *Human vs agent* and § *After launch* (inline poll + 3-part reply).

**Read first:** **`tmp-site-agent/agent-guide.md`** — § Launch Studio · § *Bankr on Base — Option A vs Option B*.

**Bankr on Base:** **`launch-studio-bankr-base-x402-rails.md`** — Option A (site x402) vs Option B (`async-start` after bankr.bot pay).

**One payment rail per launch:** either **site x402** (Option A) or **Bankr prepaid + async-start** (Option B) — never both.

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

**Example — 600 + 400 split (B2 / Base Test2):**

```json
{
  "tokenName": "Base Test2",
  "tokenSymbol": "B2",
  "splitPlan": "wallet_list",
  "deliveryAddress": "0x374d91a5674fa7cf86e725093b5848b97e1e13b4",
  "walletList": "0x374d91a5674fa7cf86e725093b5848b97e1e13b4 600\n0x20Fd91a1949B2731C09BCc6587faB5C89d750E9c 400"
}
```

Same JSON for **Option B** `async-start` plus `"source": "bankr-x402"`, `"chain": "base"`, `"payer": "0x374d…"`.

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

## Bankr cloud (`x402.bankr.bot`)

If Bankr charged **`x402.bankr.bot/…/token-marketplace-launch`**, use **Option B** (`async-start`) — see **`launch-studio-bankr-base-x402-rails.md`**.  
**Do not** follow bankr.bot with **`/concierge/run`** (second pay / 402).

---

## Forbidden

- Deep link as default · “connect wallet on the site” · “ops manual deploy”  
- **`x402.bankr.bot`** for deploy · double-pay site + Bankr cloud  
- Stopping after pay without polling **`status/{jobId}`**

---

## Plain English

> Launching **$BKT** — **~$1 USDC** via Token Marketplace x402 from your Bankr wallet. I’ll post links in ~1–3 min. No website visit needed.
