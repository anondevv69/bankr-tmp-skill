# Petition autopilot — create, back, refund, poll (Base + Solana)

**Site:** https://www.tokenmarketplace.shop/petition  
**API base:** `https://www.tokenmarketplace.shop/api/petition/…`  
**Guide:** `tmp-site-agent/agent-guide.md` § *Petitions*

Petitions are **not** Launch Studio. No x402 USDC. Backers send **native ETH (Base)** or **SOL (Solana)** to the petition escrow.

---

## When to use

| User says | Use petition | NOT |
|-----------|--------------|-----|
| Create / start a **petition** for $TEST | ✅ | Launch Studio `/launch` |
| **Pre-sale** / community launch / 24h window | ✅ | Immediate deploy |
| **10 units + 0.1 ETH launch buy** on a petition | ✅ | x402 pay |
| Deploy **now** with $1 USDC | ❌ | **Launch Studio** |

Default chain: **Base** when user says Bankr / linked EVM wallet. **Solana** when user says pumpfun / Solana wallet.

---

## Step 0 — Config (always)

```http
GET https://www.tokenmarketplace.shop/api/petition/config
```

Read:

- `config.base.enabled` / `config.solana.enabled`
- `config.base.priceEth`, `config.base.escrowWallet`, `config.base.maxLaunchBuyEth`
- `config.base.tmkClaimService`, `config.base.publicSaleUnitsWithTmkClaim` (999 when opt-in)
- `config.openDurationHours` (default 24)

If rail disabled → say petitions unavailable on that chain; do not invent escrow addresses.

---

## Flow P1 — Create petition

```http
POST https://www.tokenmarketplace.shop/api/petition/create
Content-Type: application/json
```

| Field | Notes |
|-------|-------|
| `chain` | `"base"` or `"solana"` |
| `tokenName` | min 2 chars |
| `tokenSymbol` | no `$`, max 10 |
| `maxUnitsPerWallet` | e.g. `10` for “10 per wallet max” |
| `starterWallet` | linked wallet (optional metadata) |
| `tmkClaimOptIn` | Base only — `true` for @TokenMkp 1-unit claim service |

**Example:**

```json
{
  "chain": "base",
  "tokenName": "test",
  "tokenSymbol": "TEST",
  "maxUnitsPerWallet": 10,
  "starterWallet": "0x374d91a5674fa7cf86e725093b5848b97e1e13b4"
}
```

Save `petition.id`. Share: `https://www.tokenmarketplace.shop/petition?id={id}`

---

## Flow P2 — Pre-order (deposit + confirm)

### Deposit math

```text
total = units × unitPrice + launchBuy
```

Base default unit price: **0.00001 ETH** per unit.

**Example:** 10 units + 0.1 ETH launch buy → **0.1001 ETH** total.

### On-chain transfer (Bankr)

1. **To:** `escrowWallet` from config  
2. **Value:** total wei/lamports  
3. **From:** buyer wallet (must match confirm `wallet`)  
4. Sign with linked Bankr Base wallet (`prepare:transaction` / `bankr.tx`)

Add small extra ETH for gas beyond escrow amount.

### Confirm

```http
POST https://www.tokenmarketplace.shop/api/petition/confirm
Content-Type: application/json
```

```json
{
  "id": "12",
  "wallet": "0x374d91a5674fa7cf86e725093b5848b97e1e13b4",
  "units": 10,
  "signature": "0xDepositTxHash",
  "launchBuyWei": "100000000000000000"
}
```

Solana: `launchBuyLamports` instead of `launchBuyWei`.

**Rules:**

- One active order per wallet — refund before reordering  
- `units` ≤ `maxUnitsPerWallet`  
- Launch buy requires `units ≥ 1`  
- Max launch buy from config (default 5 ETH / 5 SOL)

If response `petition.status === "locked"` → sold out; check `finalization.jobId` and poll (P4).

---

## Flow P3 — Refund

Only while `open` or `expired`:

```http
POST https://www.tokenmarketplace.shop/api/petition/refund
```

```json
{ "id": "12", "wallet": "0x…", "scope": "all" }
```

`scope`: `"units"` or `"all"` (includes launch buy).

---

## Flow P4 — Poll until finalized

```http
GET https://www.tokenmarketplace.shop/api/petition/status?id={id}
```

Poll every **15–30s** when `locked` / `finalizing` (Base launch ~1–3 min).

| status | Action |
|--------|--------|
| `open` | More backers can join |
| `locked` / `finalizing` | Wait — launch pipeline running |
| `finalized` | Reply with full success (below) |
| `failed` | Show `finalError`; recovery via site or support |
| `expired` | No launch — backers refund |

Optional: `GET /api/launch/concierge/status/{finalJobId}` for step-level detail.

---

## Compound example (one thread)

**User:** “Create a petition for $TEST. Max 10 per wallet. Start with 10 units to my wallet plus 0.1 ETH launch buy.”

1. `GET …/petition/config`  
2. `POST …/petition/create` — TEST, maxUnitsPerWallet 10  
3. Send **0.1001 ETH** to escrow  
4. `POST …/petition/confirm` — units 10, launchBuyWei `100000000000000000`  
5. Reply:

```text
Petition #12 is live for $TEST (Base).

• Max 10 units/wallet · 24h window
• Your order: 10 units + 0.1 ETH launch buy (escrowed until sold out)
• Deposit: https://basescan.org/tx/0x…
• Share: https://www.tokenmarketplace.shop/petition?id=12

When 1000/1000 (or 999+1 with TMK claim) sells out, the marketplace deploys automatically and airdrops BFRR units to all backers.
```

If user also asked for TMK claim opt-in → add `"tmkClaimOptIn": true` on create.

---

## Success reply (finalized)

1. **Launch** — `$SYMBOL` · token `0x…` · [Bankr launches](https://bankr.bot/launches/0x…)  
2. **Transactions** — deploy, launch buy, mint, split, each airdrop — BaseScan links from `finalResult.txs` / `steps`  
3. **Receipt** — BFRR link from `finalResult.links.receipt`  
4. **Holdings** — https://www.tokenmarketplace.shop/profile?tab=nfts  
5. **Fees** — check [Bankr token-fees](https://api.bankr.bot/public/doppler/token-fees/0xToken?days=30) after trading; claim via hybrid-status when vault has fees  

---

## Catalog

Open petitions only:

```http
GET https://www.tokenmarketplace.shop/api/petition/list
```

To back an existing petition: `GET …/status?id=` → P2 (skip P1).

---

## Forbidden

- Using **Launch Studio x402** for petition create/back  
- Confirm without a real deposit tx hash  
- Second order from same wallet without refund  
- Saying “launched” when `status` is still `open` / `finalizing`  
- Calling `collectFees` on Bankr fee manager for unit holders (use **hybrid claim**)
