# Launch Studio — completion reply (mandatory after deploy)

**When:** `GET …/status/{jobId}` returns `"status": "completed"` (poll per **`launch-studio-async-polling.md`**).

Every successful launch reply has **three parts** — never skip any:

1. **Deployment info** — token name, symbol, contract/mint, units delivered, wallet  
2. **Transactions** — every on-chain step with explorer link (deploy, mint, split, deliver, listing if any)  
3. **What you can do next** — plain-English offers (list, claim, send units)

**Forbidden:** one-liner “it’s live” · no tx links · no next-step offers · “tell me to retry” / “didn’t submit this turn”

---

## Get the job result

```http
GET https://www.tokenmarketplace.shop/api/launch/concierge/status/{jobId}
```

Use `result` when `status === "completed"` and `result.ok === true`.  
Fill from `input.tokenName`, `input.tokenSymbol`, `result.*`, and **`result.steps[]`** (each step: `label`, `hash`).

---

## Part 1 — Deployment info (always include)

| Show user | Source |
|-----------|--------|
| Token name + **$SYMBOL** | `input` or user message |
| **Token contract** (Base) or **mint** (Solana) | `result.tokenAddress` |
| **1000 fee-right units** delivered to | `result.deliveryAddress` |
| **Fee-rights receipt** (TMPR serial / hybrid id) | `result.receiptTokenId` when present |
| **Split** | `result.splitPlan` — “all 1000 to your wallet” for `keep_all` |
| **Job ID** | `{jobId}` |

---

## Part 2 — Transactions (always list every step)

Loop **`result.steps`** — each line = human **label** + full explorer URL.

**Base** — typical steps:

| Step label (examples) | Link |
|----------------------|------|
| Deploy token | `https://basescan.org/tx/{hash}` |
| Mint fee-rights receipt | `https://basescan.org/tx/{hash}` |
| Split into 1000 units | `https://basescan.org/tx/{hash}` |
| Deliver units to your wallet | `https://basescan.org/tx/{hash}` |
| OpenSea / share listing (if present) | `https://basescan.org/tx/{hash}` |

Also include **browse links** (not txs):

- Token: `result.links.token` or `https://basescan.org/address/{result.tokenAddress}`
- Your units: `https://www.tokenmarketplace.shop/profile?tab=nfts`
- OpenSea: `result.links.opensea`
- Doppler: `https://app.doppler.lol/tokens/base/{result.tokenAddress}`
- Bankr: `https://bankr.bot/launches/{result.tokenAddress}`

**Solana** — use `https://solscan.io/tx/{hash}` · Pump: `result.links.token` · profile: `profile?tab=pump`

---

## Part 3 — What you can do next (always offer)

End every success reply with **2–4 plain-English options** — invite the user to pick one (do not require jargon):

```text
What would you like next?

• **List** your fee rights — e.g. “List $BKT for 0.01 ETH” (sell on Token Marketplace + OpenSea)
• **List units** on the share market — e.g. “List 100 units of $BKT at 0.0001 ETH each”
• **Send / gift units** — e.g. “Send 50 units of $BKT to 0x…”
• **Claim fees** later — e.g. “Claim fees for $BKT” when trading fees accrue
```

Route after user picks:

| They say | Main TMP skill |
|----------|----------------|
| List for X ETH (whole rights) | `sell-list-autopilot.md` |
| List units / shares | share-market list flows |
| Send / gift / airdrop units | `transfer-units-autopilot.md` |
| Claim fees | `hybrid-claim-autopilot.md` |

One conversational line is enough — e.g. *“Want to list $BKT for sale? Say a price in ETH.”*

---

## Base — full reply template

```text
Done — {tokenName} (${tokenSymbol}) is live on Token Marketplace (Base).

**Token:** {result.tokenAddress}
**1000 fee-right units** → {result.deliveryAddress}
**Receipt (TMPR):** {result.receiptTokenId}

**Links**
• Token: {result.links.token}
• Your wallet (units): https://www.tokenmarketplace.shop/profile?tab=nfts
• OpenSea: {result.links.opensea}
• Doppler: https://app.doppler.lol/tokens/base/{result.tokenAddress}
• Bankr: https://bankr.bot/launches/{result.tokenAddress}

**Transactions**
• {step.label}: https://basescan.org/tx/{step.hash}
  (repeat for every step in result.steps)

Job ID: {jobId}

**What next?**
Want to **list ${tokenSymbol} for sale**? Say e.g. “List $SYMBOL for 0.01 ETH”.
Or **send units** to someone, or **claim fees** when they accrue — just ask.
```

---

## Solana (Pump.fun) — full reply template

```text
Done — {tokenName} (${tokenSymbol}) is live on Pump.fun via Token Marketplace.

**Mint:** {result.tokenAddress}
**1000 units** → {result.deliveryAddress}

**Links**
• Pump.fun: {result.links.token}
• Shop: {result.links.receipt}
• Your units: https://www.tokenmarketplace.shop/profile?tab=pump

**Transactions**
• {step.label}: https://solscan.io/tx/{step.hash}

Job ID: {jobId}

**What next?**
Want to **list units**, **transfer** to another wallet, or **claim** — say what you’d like for $SYMBOL.
```

---

## Real example (Base — $BKT)

Use this shape when status JSON is sparse but chain data exists:

```text
Done — Base Keep Test ($BKT) is live on Token Marketplace (Base).

**Token:** 0x2B78E2b79D25B3377DF421d473F02EF78377CBa3
**1000 fee-right units** → 0x374d91a5674fa7cf86e725093b5848b97e1e13b4

**Links**
• https://basescan.org/address/0x2B78E2b79D25B3377DF421d473F02EF78377CBa3
• https://www.tokenmarketplace.shop/profile?tab=nfts
• https://bankr.bot/launches/0x2B78E2b79D25B3377DF421d473F02EF78377CBa3

**Transactions**
• Deliver 1000 units: https://basescan.org/tx/0x1bdc1c5ea7ffd364b1585d04eb7e7f10223a0fcf7680d9c783705f7246c78a1a
• Listing (if any): https://basescan.org/tx/0x6553262063d1c68aefcf7abd268c90c1a1aaa8213358c9edf71f844166bdf86a

**What next?**
Want to **list $BKT for 0.01 ETH**, **send units** to a friend, or **claim fees** later? Just say the word.
```

---

## Wallet list (`splitPlan: wallet_list`)

Add: *“Airdrop delivered per your list (1000 total). Each recipient can check profile → NFTs (Base) or Pump (Solana).”*

---

## Failed jobs

If `status === "failed"`, report `error` and any partial `result.steps`. Do not claim success. Do not offer “list for sale” until deploy succeeded.

---

## Field map (status JSON)

| Field | Base | Solana |
|-------|------|--------|
| `result.tokenAddress` | ERC-20 contract | Pump mint |
| `result.deliveryAddress` | `0x…` | base58 |
| `result.receiptTokenId` | TMPR id | listing id |
| `result.steps[]` | deploy, mint, split, deliver, … | pumpDeploy, split, airdrop, … |
| `result.links.token` | BaseScan | pump.fun |
| `result.links.opensea` | OpenSea | — |
