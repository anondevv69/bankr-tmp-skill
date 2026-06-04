# Launch Studio — website parity (human vs agent)

**Principle:** Launch Studio is **one product**. Humans use the form; agents use **the same JSON + same x402 + same poll**. Only **who inputs** and **who signs USDC** changes.

Full spec: **`tmp-site-agent/agent-guide.md`** § *Human vs agent* and § *Launch Studio*.

---

## Side-by-side (mandatory mental model)

| | Human `/launch` | Bankr / agent |
|--|-----------------|---------------|
| Name, symbol, split | Form fields | `tokenName`, `tokenSymbol`, `splitPlan`, `deliveryAddress`, `walletList` |
| Pay ~$1 USDC | Rainbow / Phantom → site x402 | Bankr site-x402 tools → **same** treasury & facilitator |
| Submit | `POST /api/launch/concierge/run` | **Same URL, same body** |
| After pay | **202** + `jobId` | **202** + `jobId` |
| Wait | UI polls every ~4s (`pollConciergeJobUntilDone`) | Agent polls every 15–30s — **required** |
| Finish | Done screen + links | `launch-studio-completion-reply.md` |

**Forbidden:** treating Bankr as a different product (deep link, “connect on site”, `x402.bankr.bot`, stop after “processing payment”).

---

## Agent checklist (smooth like the website)

1. `GET /api/launch/concierge/config` — price, network, treasury  
2. Build JSON from user sentence (examples in **`launch-studio-agent-autopilot.md`**)  
3. `POST …/concierge/run` (Base) or `…/solana/run` (Solana)  
4. Handle **402** → sign x402 → POST again with payment header  
5. Save **`jobId`** from **202**  
6. Loop `GET …/status/{jobId}` until `completed` or `failed` (≥3 min for Base)  
7. Reply with token + **all** tx links + profile URL + offer list-for-sale  

**Code reference:** `fee-rights-exchange/bankr-app/src/lib/runConciergeLaunch.ts`

---

## Field mapping (UI → JSON)

| Launch Studio form | JSON field |
|--------------------|------------|
| Token name | `tokenName` |
| Symbol | `tokenSymbol` (no `$`) |
| Keep all 1000 / wallet list | `splitPlan`: `keep_all` \| `wallet_list` |
| Your wallet (keep all) | `deliveryAddress` |
| Airdrop lines | `walletList`: `0x… 600\n0x… 400` (sum **1000**) |
| Image / links (optional) | `imageUrl`, `websiteUrl`, `tweetUrl`, `telegramUrl` |

Solana: `deliveryAddress` = **base58** pubkey; same fields otherwise.

---

## Timing (set expectations like the UI)

| Phase | Duration |
|-------|----------|
| x402 sign | seconds |
| 202 queued | immediate |
| `running` | **1–3 min** Base · up to **~10 min** Solana |

Status `running` for 2 minutes = **normal**, not a stall — keep polling.
