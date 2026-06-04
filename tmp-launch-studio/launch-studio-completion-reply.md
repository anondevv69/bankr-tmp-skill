# Launch Studio — completion reply (match the website Done screen)

**When:** `GET …/status/{jobId}` returns `"status": "completed"` · you polled after **Bankr x402** pay or site x402 pay · user pastes **Job ID** (Rail B only).

**Forbidden:** “Launch started” / “check the site” without links · “**I didn’t submit a transaction this turn**” · “**tell me to retry**” before poll · omitting BaseScan / Pump / tx links.

**Mandatory:** After **202 + jobId**, poll until **`completed`** or **`failed`** — **`launch-studio-async-polling.md`**.

---

## Get the job result

```http
GET https://www.tokenmarketplace.shop/api/launch/concierge/status/{jobId}
```

Use `result` when `status === "completed"` and `result.ok === true`.  
Token name/symbol: `input.tokenName`, `input.tokenSymbol` on the same JSON (or from user message).

Poll every **15–30s** from the **`jobId` / `statusUrl` in the Bankr x402 response** (Rail A). For site-only launches (Rail B), user may paste Job ID from Done screen.

---

## Base (Bankr) — reply template

Fill from `result` + `input`:

```text
Done — {tokenName} (${tokenSymbol}) is live on Token Marketplace (Base).

Token contract: {result.tokenAddress}
1000 fee-right units → {result.deliveryAddress}
Split plan: {result.splitPlan}

Links:
• BaseScan (token): {result.links.token}
• Receipt / units: {result.links.receipt}
• OpenSea: {result.links.opensea}
• Doppler: https://app.doppler.lol/tokens/base/{result.tokenAddress}
• Bankr launches: https://bankr.bot/launches/{result.tokenAddress}
• Your units: https://www.tokenmarketplace.shop/profile?tab=nfts

TMPR unit id: {result.receiptTokenId}

Transactions:
{for each step in result.steps with hash}
• {step.label}: https://basescan.org/tx/{step.hash}
{end}

Job ID: {jobId}

Next: “list ${tokenSymbol} for 0.01 eth” · “claim fees for ${tokenSymbol}” · “send 100 units to …”
```

---

## Solana (Pump.fun) — reply template

```text
Done — {tokenName} (${tokenSymbol}) is live on Pump.fun via Token Marketplace.

Mint: {result.tokenAddress}
1000 SPL units → {result.deliveryAddress}
Split plan: {result.splitPlan}

Links:
• Pump.fun: {result.links.token}
• Shop listing: {result.links.receipt}
• Your units: https://www.tokenmarketplace.shop/profile?tab=pump

Transactions:
{for each step in result.steps with hash}
• {step.label}: https://solscan.io/tx/{step.hash}
{end}

Job ID: {jobId}
```

If `result.listingAddress` is present, add: `Listing: https://www.tokenmarketplace.shop/listing/sol/{result.listingAddress}`

---

## Wallet list (`splitPlan: wallet_list`)

Add a short plain-English block:

```text
Airdrop delivered per your list (1000 units total). Check each recipient wallet on profile → NFTs (Base) or Pump tab (Solana).
```

Include `result.distributeTxs` / airdrop steps from `result.steps` when present.

---

## Failed jobs

If `status === "failed"`, read `error` and any partial `result.steps` / `result.tokenAddress`. Do not claim success. Say payment may not have settled if failed before pipeline start.

---

## Field map (status JSON)

| Field | Base | Solana |
|-------|------|--------|
| `result.tokenAddress` | ERC-20 contract | Pump mint |
| `result.deliveryAddress` | `0x…` | base58 |
| `result.receiptTokenId` | TMPR id | often listing id |
| `result.links.token` | basescan.org/address/… | pump.fun/coin/… |
| `result.links.receipt` | basescan token | shop listing URL |
| `result.links.opensea` | OpenSea asset | same as receipt |
| `result.steps[]` | deploy, mint, split, deliver | pumpDeploy, split, airdrop |
