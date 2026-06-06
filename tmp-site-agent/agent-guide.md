# Token Marketplace — Agent guide

**Site:** https://www.tokenmarketplace.shop  
**Chain:** Base (8453) · **Solana:** mainnet-beta (CTO / Pump.fun listings)  
**Community:** [X @TokenMkp](https://x.com/TokenMkp) · [Telegram](https://t.me/tokenmkp)  
**$TMP (platform token):** `0x935e13a28849095db45e63040f109c34b757aba3` — DexScreener / chart only; **never** use as a user’s launch token.

This document is for **any AI agent** (Bankr, Cursor, custom bots) that should list, buy, split, or claim **fee rights** on Token Marketplace. **Bankr:** install **`tmp-site-agent`** skill (same content as this file). For step-by-step autopilot flows, install the TMP skill pack (see bottom).

---

## Golden rules

1. **One sentence from the user → run the full flow** in one thread. Do not ask “site or OpenSea?” unless they said OpenSea only.
2. **Resolve the user’s launch token** (ticker → contract via Bankr `get_token_launch_info` or Clanker API). **Never** substitute `$TMP` (`0x935e…`) for their coin.
3. **Call site APIs first** — they return `nextStep` calldata, correct contract addresses, and shop URLs.
4. **Reply with full URLs** — always `https://www.tokenmarketplace.shop/...`, never a bare “list on the site”.
5. **Hybrid TMPR** is one collection (`0xD8e0639…`): ERC-721 receipt + ERC-1155 units (up to 1000 per sale after finalize).

---

## Human vs agent — same APIs, same x402 (only input differs)

**One product.** Humans use the website UI; agents use the **same HTTP APIs and the same site x402 payment**. The backend, executor, job queue, and status polling are **identical**.

| Step | Human on `/launch` | Agent (Bankr, Cursor, bot) |
|------|-------------------|----------------------------|
| **1. Fill launch fields** | User types name, symbol, split plan, wallet list in the form | Agent maps user’s sentence → **same JSON body** (see Launch Studio §) |
| **2. Config (optional)** | UI loads automatically | `GET /api/launch/concierge/config` |
| **3. Pay** | User connects wallet → signs **~$1 USDC** site x402 | Agent signs **same x402** with user’s wallet (Bankr custodial wallet counts) |
| **4. Enqueue** | `POST /api/launch/concierge/run` (or `/solana/run`) → **202** + `jobId` | **Same POST**, same headers, same body |
| **5. Wait** | UI shows “Processing” (~1–3 min Base) | Agent **polls** `GET /api/launch/concierge/status/{jobId}` every 15–30s (site UI uses ~4s) |
| **6. Done** | Done screen: token address, BaseScan, profile, all tx links | Agent replies with **same links** (`launch-studio-completion-reply.md`) |

**What is NOT different:** treasury, price (~$1 USDC), facilitator, executor txs, mint/split/deliver pipeline, job store, or status API.

**What IS different:** who types the fields (human vs agent) and who clicks/signs x402 (human wallet in browser vs agent signing tools). **Do not** invent a separate “Bankr launch rail” or browser handoff when the agent can sign site x402.

**Website reference (copy this behavior):**

| Layer | Human UI | Agent equivalent |
|-------|----------|------------------|
| x402 + POST | `src/lib/runConciergeLaunch.ts` → `runConciergeLaunchX402` | Same libraries or Bankr site-x402 signing |
| Poll until done | `pollConciergeJobUntilDone` (4s interval, 8 min timeout) | **Mandatory** — see `launch-studio-bankr-mirror-website.md` |
| Page | `src/pages/LaunchStudioPage.tsx` | Not needed if API + poll |

**CLI (same rail):** `bankr-app/scripts/launch-concierge-x402.mjs`

**List / buy / claim / split (existing tokens):** same rule — humans click through profile; agents call the **status APIs** in the table below (`mint/status`, `buy-status`, `hybrid-status`, etc.) and sign `nextStep` txs. No separate agent product.

---

## What users can do (intent → you)

| User says | Meaning | First API / path |
|-----------|---------|------------------|
| Sell / list $TICKER for 0.01 eth | 100% fixed sale (dual: site + OpenSea default) | `GET /api/mint/status` → `POST /api/list/dual` |
| Split / fractionalize into 1000 | Mint TMPR if needed → V6 group buy self-split → 1000 ERC-1155 units | `GET /api/mint/status` → on-chain V6 finalize |
| Buy `…/listing/sale/27` | Buy **whole** fee-right NFT (fixed sale) | `GET /api/list/buy-status?url=…` |
| Buy cheapest share / 1/1000 | Buy **one** ERC-1155 unit on share market | `GET /api/share/list-status` (not buy-status) |
| Group buy / CTO / co-own | Pool ETH → finalize → units | Group buy escrow + `/listing/group/…` |
| Claim fees for $TICKER | Distribute trading fees to unit holders | `GET /api/claim/hybrid-status` → claim router |
| Cancel share listing | Delist ERC-1155 on share market | `GET /api/share/list-status` → `cancel` on `0x9023…` |
| Send / gift / airdrop units | Move 1…1000 ERC-1155 units to other wallets (after split) | Profile → **NFTs** → **Send shares** · Bankr skill `transfer-units-autopilot.md` |
| What did I sell / purchase history | Past Sell 100% + group finalized sales | Profile → **Completed sales** (`?tab=completed`) |
| Redeem fees / get fees back | Burn TMPR, restore beneficiary | Redeem on mint escrow (Bankr skill Flow H) |
| Launch / deploy new token + 1000 units | **Same as `/launch` UI** — site x402 + poll | **`POST /concierge/run`** or **`/solana/run`** + poll · browser only if agent cannot sign x402 |
| **Deploy X via Bankr** (nothing else) | Base launch · **all 1000 units** to linked EVM wallet | `splitPlan: keep_all` · `POST /concierge/run` |
| **Deploy X via pumpfun** (nothing else) | Solana Pump · **all 1000 SPL units** | `splitPlan: keep_all` · `POST /concierge/solana/run` |
| **Deploy … split: A gets 100, B gets 900** | Wallet list at launch (sum **1000**) | `splitPlan: wallet_list` · multiline `address amount` |
| **Sell rights of X for 0.01 ETH** | 100% fixed sale (dual default) | `mint/status` → `list/dual` |
| **Sell rights of X for 0.01 SOL** | Solana listing / CTO | Solana program + `buy-status` / listing UI parity · see Solana § |
| **Buy X shares of this listing** | ERC-1155 share market | `share/list-status` · **not** `/listing/sale/` |
| **Buy the rights of this token** | Whole TMPR (fixed sale) | `list/buy-status?url=` |
| **Redeem this token** | Burn TMPR · fee beneficiary back to signer | `redeemRights(tokenId)` on correct escrow |
| **Claim fees for X for all holders** | Hybrid claim · **every** unit holder paid | `claim/hybrid-status` → `claimFeesForToken` |
| **Create a petition for $TEST** / **start a pre-sale** | 24h community pre-sale → launch at sold out | `GET /api/petition/config` → `POST /api/petition/create` → deposit → `POST /api/petition/confirm` |
| **Buy N units in petition #12** / **back petition $TEST** | Pre-order fee-right units (+ optional launch buy) | `GET /api/petition/prepare-deposit` → **`bankr.tx.prepare`** → `POST /confirm` |
| **Share petition link + “get me 400 units”** | Participate in existing petition from URL | Parse `id` from URL → `GET /prepare-deposit?url=` → **`bankr.tx.prepare`** → `POST /confirm` |
| **Can I participate in this petition with 400 units?** | Eligibility + quote | `GET /api/petition/status?url=` → `GET /prepare-deposit` → quote `deposit.totalEth` |
| **Refund my petition units** | While petition `open` or `expired` | `POST /api/petition/refund` |
| **Cancel empty duplicate petition** | Creator closes zero-sale petition | `POST /api/petition/cancel` |
| **Check petition progress** | Sold units, status, launch job | `GET /api/petition/status?id=` · catalog: `GET /api/petition/list` |

**Defaults (do not ask unless ambiguous):**

| Topic | Default |
|-------|---------|
| Launch units | **1000** delivered (`keep_all` or `wallet_list` summing 1000) |
| Deploy chain | **“via Bankr”** → Base · **“via pumpfun”** → Solana |
| Sell venue | **Dual** (site + OpenSea) unless password / shares / user said site only |
| Claim scope | **All** unit holders (even if user omits “for all”) |
| Petition chain | **“via Bankr” / Base wallet** → Base petition · **“pumpfun” / Solana** → Solana petition |
| Petition vs Launch Studio | **Petition** = micro unit fees in ETH/SOL escrow, community fills 1000, executor deploys at sold out · **Launch Studio** = ~$1 USDC x402, deploy immediately |

**Wrong routing (common bugs):**

- `/listing/sale/{id}` → **FeeRightsFixedSale** `0xe2A134…` — **not** HybridShareMarketplace `0x9023…`
- `/listing/shares/t/{tokenId}` → share book — **not** fixed sale id `N` on `0xe2A1…`
- Listing **#28** on a card may be **TMPR serial #28** while the buy URL uses **sale id** (e.g. `/listing/sale/25`) — use `buy-status` or on-chain `getListing`.
- Calling **`/concierge/run` after Bankr x402 pay on `x402.bankr.bot`** — double rail / **402**; use **`async-start`** (Option B) instead
- Calling **`async-start` from a chat agent** — internal secret only; Bankr **product** calls it after bankr.bot pay
- **Orphan USDC** — sending $1 to site treasury without **site x402** on the POST (use Option A correctly or Option B, not a plain transfer)

---

## Canonical contracts (Base, May 2026)

| Role | Address |
|------|---------|
| Hybrid TMPR (ERC-721 + ERC-1155) | `0xD8e0639DfAa1cB2b9f9642EeCbd40b1e5a8b42A7` |
| FeeRightsFixedSale (100% list/buy) | `0xe2A13499292D43254026DAf0C4F75988242BaA66` |
| Legacy fixed sale (older listings) | `0xeb8aC71B8B19f86d08B7802193952938a70bdCB4` |
| HybridShareMarketplace (unit order book) | `0x90230B59D01c6e0306236eF7afc8105908c4DB0B` |
| GroupBuyEscrowV6 (split / CTO / partial) | `0x56bd948671955D0Ed82a88f136779cB76f551e0C` |
| Hybrid claim router | `0x0f5148A4CdDd74e011fbe516ADddBFd61Af2E8bb` |
| Bankr hybrid mint escrow | `0x047B292FF5e3abDFFfed08C151729BB0999aDFFA` |
| Clanker v4 hybrid mint escrow | `0xdCCe61A7f7cD3ff664714A5C4a40011e4e033aD9` |

---

## Public HTTP APIs (no wallet required to read)

Base URL: `https://www.tokenmarketplace.shop`

| Endpoint | Use |
|----------|-----|
| `GET /api/mint/status?tokens={launch0x}&wallet={seller}` | Mint pipeline: `phase`, `nextStep` txs until `ready` |
| `POST /api/list/dual` | Build dual list (site + OpenSea) after mint ready |
| `GET /api/list/status?wallet={seller}&tokenId={tmprId}` | Confirm listing + shop URL |
| `GET /api/list/buy-status?url={listing/sale/…}` | Preflight **fixed sale** buy (`msg.value`, contract) |
| `GET /api/share/list-status?wallet={seller}&hybridTokenId=` | Active share listings + cancel calldata |
| `GET /api/claim/hybrid-status?tokenId={tmprId}` | Claim readiness, cap table, router calldata hints |
| `GET /api/bankr-launches?wallet={address}` | Bankr-launched tokens for profile |
| `GET /api/launch/concierge/config` | Launch Studio pricing, treasury, x402 network, job URLs (no secrets) |
| `POST /api/launch/concierge/run` | **Base Launch Studio** — x402 USDC → deploy + mint + split + deliver (agents) |
| `POST /api/launch/concierge/solana/run` | **Solana Launch Studio** — x402 USDC → Pump deploy + split + deliver |
| `GET /api/launch/concierge/status/{jobId}` | Launch Studio job poll (`queued` → `running` → `completed`) |
| `GET /api/petition/config` | Petition rails: unit price, escrow, goal units, launch-buy caps, TMK claim opt-in |
| `GET /api/petition/list` | Open petitions catalog (sold-out / finalized omitted) |
| `GET /api/petition/status?id={id}` | Full petition + orders; syncs finalization job when `finalizing` |
| `GET /api/petition/prepare-deposit?id=&wallet=&units=&launchBuyWei=` | **Agent deposit preflight** — accepts **`url=`** share link; returns `nextStep` for `bankr.tx.prepare` + `afterDeposit` confirm body |
| `POST /api/petition/create` | Create 24h pre-sale petition |
| `POST /api/petition/confirm` | After on-chain deposit tx — records units + optional launch buy; auto-starts launch if sold out |
| `POST /api/petition/cancel` | Cancel **empty** open petition (creator wallet or admin Bearer) |
| `POST /api/petition/refund` | Refund active units (and optional launch buy) while `open` or `expired` |
| `POST /api/listings/notify` | After listing tx (Bearer `LISTING_PUBLISH_SECRET`) — X/Telegram alert |
| `POST /api/alerts/from-tx` | Replay alert from tx hash (ops; same secret) |

Solana (when enabled):

| Endpoint | Use |
|----------|-----|
| `GET /api/solana/buy-status?listing={pubkey}` | CTO / raise buy preflight |
| `GET /api/solana/claim-status?listing={pubkey}` | Batch claim preflight |

---

## Shop URL patterns

| Path | Listing type |
|------|----------------|
| `/listing/sale/{id}` | Fixed price — 100% of fee rights |
| `/listing/group/{escrow}/{id}` | Group buy / CTO / partial / self-split |
| `/listing/shares/t/{tokenId}` | ERC-1155 share order book (cheapest first) |
| `/listing/sol/{pubkey}` | Solana Pump.fun CTO / raise |
| `/profile` | Wallet NFTs, units, list flows |
| `/profile?tab=nfts` | Wallet NFTs, units, listings, send shares (`tab=listed` still works) |
| `/profile?tab=completed` | **Sell 100%** sold/bought history + completed group sales |
| `/petition` | Create petition · back open petitions · track status (`?id=`) |
| `/petition?create=1` | New petition form (human) |
| `/petition?id={id}` | Petition detail + pre-order (human) |

---

## Petitions — 24h pre-sale → community launch

**Different from Launch Studio:** no x402 USDC. Backers pay **micro unit fees** (+ optional **launch buy** in native ETH or SOL) into a petition escrow. When sold out, the **launch executor** deploys the token, mints 1000 BFRR/SPL units, and **airdrops pro-rata to every backer wallet**. Petitions stay open up to **24 hours**; refundable while `open` or `expired` (not after `locked` / launch started).

**Human UI:** https://www.tokenmarketplace.shop/petition  
**Agent autopilot:** `petition-autopilot.md` (Bankr skill pack)

### Human vs agent (petitions)

| Step | Human on `/petition` | Agent (Bankr) |
|------|---------------------|---------------|
| Config | UI loads | `GET /api/petition/config` |
| Create | Form submit | `POST /api/petition/create` |
| Pre-order | Connect wallet → send ETH/SOL | **`prepare:transaction`** or `bankr.tx` — native transfer to `escrowWallet` |
| Confirm | UI calls confirm after tx | `POST /api/petition/confirm` with `signature` = tx hash |
| Sold out | UI shows “launch starting” | Same confirm response may include `finalization.jobId` — **poll status** |
| Done | Token + BFRR links | `GET /api/petition/status?id=` until `finalized`; reply with token, receipt, all txs |

**Not x402.** Do **not** use `POST /api/launch/concierge/run` for petitions unless user explicitly wants **immediate** Launch Studio instead.

**Wrong page:** Petitions live at **`/petition`** — not [Launch Studio `/launch`](https://www.tokenmarketplace.shop/launch) (that is immediate ~$1 USDC deploy).

### Agent execution (Bankr) — deposit is mandatory

Creating a petition (`POST /create`) only registers metadata. **Units are not recorded until a real on-chain deposit + confirm.**

| Step | Tool | Notes |
|------|------|-------|
| Preflight deposit | `GET /api/petition/prepare-deposit` | Returns `nextStep.to`, `nextStep.value`, `deposit.totalEth` |
| Sign & send | **`bankr.tx.prepare`** | Native ETH transfer — `data: "0x"`, `value` from `nextStep` |
| Record order | `POST /api/petition/confirm` | `signature` = deposit tx hash from step above |

**Forbidden:** Stopping after `useskill` / reading the skill pack — that is **READ-ONLY** and does **not** submit transactions. When the user says **confirm** / **send**, you **must** call `bankr.tx.prepare` with `prepare-deposit` output.

**Before create:** `GET /api/petition/list` — if the user already has an open petition for the same ticker, **reuse that id** instead of creating duplicates.

### Participate from a shared link (most common for backers)

User pastes **`https://www.tokenmarketplace.shop/petition?id=15`** and says:

- “Get me **400 units** and **0.01 ETH** launch buy”
- “Can I participate in this petition with **400 units**?”
- “Back this petition — **50 units**, no launch buy”

**Parse id from URL** (query `id=`, or bare `#15` / `petition/15`). Then:

1. `GET /api/petition/status?url={fullShareUrl}` — read `agentParticipation.maxUnitsPerWallet`, `remainingUnits`, `$SYMBOL`  
2. If user only asked eligibility → answer yes/no + max + remaining + price formula  
3. `GET /api/petition/prepare-deposit?url={shareUrl}&wallet={linked}&units=400&launchBuyWei=100000000000000000`  
4. Quote **`deposit.totalEth`** — on user **confirm** → **`bankr.tx.prepare(nextStep)`**  
5. `POST /api/petition/confirm` with deposit tx hash  
6. Reply with units recorded, deposit tx, progress `{sold}/{goal}`, share link

**No create step** — shared link means an existing petition.

### Cancel empty duplicate petition

When multiple `$TEST` petitions were created by mistake (zero sales):

```http
POST /api/petition/cancel
Content-Type: application/json

{ "id": "14", "wallet": "0xCreatorWallet", "reason": "duplicate" }
```

Only works when **`soldUnits === 0`** and no active orders. Cancelled petitions drop from `/list` but status URL still works.

### Pricing (read from config — do not hardcode)

| Chain | Unit fee | Launch buy (optional) | Escrow |
|-------|----------|----------------------|--------|
| **Base** | `config.base.priceEth` (default **0.00001 ETH**/unit) | `launchBuyWei` — max `config.base.maxLaunchBuyEth` (default **5 ETH**) | `config.base.escrowWallet` (launch executor) |
| **Solana** | `config.solana.priceSol` (default **0.00015 SOL**/unit) | `launchBuyLamports` — max 5 SOL | `config.solana.escrowWallet` (executor pubkey) |

**Deposit formula:**

```text
total = (units × unitPrice) + launchBuy
```

Example (Base): **10 units + 0.1 ETH launch buy** → `10 × 0.00001 + 0.1 = 0.1001 ETH` to escrow (+ wallet gas).

**Launch buy rules:** requires **≥1 unit** in the same order; escrowed until sold out; swapped on the Bankr pool / Pump curve **at deploy** (pro-rata to all backers who opted in).

### Create petition — `POST /api/petition/create`

| Field | Required | Notes |
|-------|----------|-------|
| `chain` | yes | `"base"` or `"solana"` — default **base** when user says Bankr |
| `tokenName` | yes | min 2 chars — e.g. `"test"` from “$TEST” |
| `tokenSymbol` | yes | no `$`, max 10 — e.g. `"TEST"` |
| `maxUnitsPerWallet` | no | default **10** — user: “10 per wallet max” → `10` |
| `starterWallet` | no | linked EVM/Solana wallet (proposer metadata) |
| `description`, `imageUrl`, `websiteUrl`, `tweetUrl`, `telegramUrl` | no | https URLs where applicable |
| `tmkClaimOptIn` | no | Base only — reserve **1** unit for @TokenMkp fee-claim service → public cap **999** units |

**Example — “create petition for $TEST, 10 max per wallet”:**

```json
{
  "chain": "base",
  "tokenName": "test",
  "tokenSymbol": "TEST",
  "maxUnitsPerWallet": 10,
  "starterWallet": "0xYourLinkedBankrWallet"
}
```

Response: `{ ok: true, petition: { id, status: "open", goalUnits: 1000, ... } }`  
Share URL: `https://www.tokenmarketplace.shop/petition?id={id}`

### Pre-order (create + participate) — `POST /api/petition/confirm`

After the user’s wallet sends the deposit tx:

1. **To:** `petition.escrowWallet` from config/status  
2. **Value:** `(units × unitPrice) + launchBuy` (see formula)  
3. **From:** buyer wallet (must match `wallet` in confirm body)

```json
{
  "id": "12",
  "wallet": "0xYourLinkedBankrWallet",
  "units": 10,
  "signature": "0xDepositTxHash",
  "launchBuyWei": "100000000000000000"
}
```

Solana: use `launchBuyLamports` instead of `launchBuyWei`; `signature` = Solana tx sig.

**One active order per wallet** — refund before changing units. `units` must be ≤ `maxUnitsPerWallet` and ≤ remaining public units.

**Example — full user sentence in one thread:**

> “Create a petition for $TEST. Max 10 per wallet. Start it with 10 units to my wallet plus 0.1 ETH launch buy.”

Agent steps:

1. `GET /api/petition/config` — verify `base.enabled`  
2. `GET /api/petition/list` — reuse existing open petition if same ticker/creator  
3. `POST /api/petition/create` — `{ chain: "base", tokenName: "test", tokenSymbol: "TEST", maxUnitsPerWallet: 10, starterWallet }` (skip if reusing id)  
4. `GET /api/petition/prepare-deposit?id={id}&wallet={wallet}&units=10&launchBuyWei=100000000000000000`  
5. **`bankr.tx.prepare`** — submit `nextStep` (native ETH to escrow)  
6. `POST /api/petition/confirm` — `{ id, wallet, units: 10, signature: <txHash>, launchBuyWei: "100000000000000000" }`  
7. Reply with petition URL, deposit tx, units recorded, time remaining

### Refund — `POST /api/petition/refund`

While `status` is `open` or `expired`:

```json
{ "id": "12", "wallet": "0x…", "scope": "all" }
```

`scope`: `"units"` (unit fees only) or `"all"` (units + launch buy). Executor wallet signs refund from escrow.

### Poll until launch completes

```http
GET /api/petition/status?id={id}
```

| `status` | Meaning |
|----------|---------|
| `open` | Accepting pre-orders |
| `locked` | Sold out — finalization queued/running |
| `finalizing` | Deploy pipeline in progress |
| `finalized` | Token live — `finalResult.tokenAddress`, `receiptTokenId`, `txs` |
| `failed` | Launch error — `finalError`; recovery APIs exist |
| `expired` | 24h ended before sold out — refunds only |
| `cancelled` | Creator cancelled empty petition — no deposits accepted |

When `finalJobId` is set, optional cross-check: `GET /api/launch/concierge/status/{finalJobId}` (same job store as Launch Studio).

**Success reply (petition finalized):**

1. Petition `#id` · `$SYMBOL` · [Bankr token](https://basescan.org/address/0x…)  
2. Every pipeline tx (deploy, launch buy, mint, split, airdrops) with BaseScan links  
3. BFRR receipt link · profile `?tab=nfts` · **claim fees** when pool has volume ([Bankr token-fees API](https://docs.bankr.bot/token-launching/reading-fees/))

### Base TMK claim opt-in (`tmkClaimOptIn: true`)

- Public pre-sale cap: **999** units (+ **1** reserved for @TokenMkp)  
- Enables tweet/agent hybrid fee claims once TMK holds a unit  
- Disclose in reply when enabled

### Petition vs Launch Studio (routing)

| User wants | Route |
|------------|-------|
| Community pre-sale, 24h window, backers fill 1000 | **Petition** |
| Deploy **now**, I pay ~$1 USDC, all units to me | **Launch Studio** (`/launch`) |
| “Create petition” + “launch buy 0.1 ETH” | **Petition** (launch buy is escrow, not immediate buy) |

**Wrong routing:** Using x402 `/concierge/run` for a petition · Using petition APIs for immediate solo launch · Stopping after create without deposit when user asked to **fund** their own order

---

## Launch Studio — deploy new token + 1000 units

One paid flow per chain — **human UI and agents use the same endpoints**:

- **Base (Bankr):** deploy token → mint TMPR → split 1000 ERC-1155 units → deliver  
- **Solana (Pump.fun):** deploy on Pump → split 1000 SPL units → deliver  

Same **site x402** payment model on both chains (~$1 USDC); same JSON fields as the Launch Studio form.

### Golden rule

**One rail for everyone:** **site x402** on `POST /api/launch/concierge/run` (Base) or `/solana/run` (Solana) → **202** → poll `GET /api/launch/concierge/status/{jobId}` until `completed`.

Humans: form → wallet sign → UI polls.  
Agents: JSON body → wallet sign via agent tools → **you poll** (same as `runConciergeLaunch.ts`).

**Do not** use `x402.bankr.bot/…/token-marketplace-launch` (deprecated).  
**Do not** send agents to `/launch` deep links when they can sign site x402.

Skill: `tmp-launch-studio/launch-studio-agent-autopilot.md` · parity: `launch-studio-bankr-mirror-website.md`  
CLI (Base): `bankr-app/scripts/launch-concierge-x402.mjs`

### Who uses what (same backend)

| Who | How they input | How they pay | API |
|-----|----------------|--------------|-----|
| **Human** | `/launch` form | Connect wallet → site x402 | `POST /concierge/run` or `/solana/run` |
| **Bankr / any agent** | Natural language → JSON | Agent signs site x402 | **Same POST** |
| **Script / CLI** | Flags → JSON | Private key → site x402 | **Same POST** |
| **Agent cannot sign x402** | Prefilled `/launch` URL | Human pays in browser | Last resort only |

**Deprecated:** separate Bankr x402 cloud path · deep links as agent default.

**After Base launch:** units on `https://www.tokenmarketplace.shop/profile?tab=nfts` · `https://bankr.bot/launches/{tokenAddress}`  

**After Solana launch:** units on `https://www.tokenmarketplace.shop/profile?tab=pump` · `result.links.token` → pump.fun

### Bankr on Base — Option A vs Option B (pick one)

Bankr must use **exactly one** payment rail per launch. Skills: [`launch-studio-bankr-base-x402-rails.md`](https://github.com/anondevv69/bankr-tmp-skill/blob/main/tmp-launch-studio/launch-studio-bankr-base-x402-rails.md).

| Option | When | Action | Stop when |
|--------|------|--------|-----------|
| **A — site x402** | Bankr can sign **site** x402 with linked **Base** wallet | `POST …/concierge/run` → 402 → sign → POST + payment header → **202** | **202** + real `jobId`; poll status |
| **B — Bankr prepaid** | Bankr **already** charged **`x402.bankr.bot/…/token-marketplace-launch`** this session | Bankr server: `POST …/async-start` with `source: "bankr-x402"` — **not** `/concierge/run` again | **202** + real `jobId`; poll status |

**Never:** pay on bankr.bot then `POST /concierge/run` (402 / orphan USDC). **Never:** plain USDC transfer to site treasury without x402 on the POST.

`GET …/config` → `config.bankrX402.asyncStartUrl` for Option B.

### Do not chain Bankr x402 → site x402

These are **separate USDC payments** to **different treasuries** with **different facilitators**. A Bankr x402 receipt **cannot** be replayed as site x402 `PAYMENT-SIGNATURE` headers.

| Approach | Verdict |
|----------|---------|
| Bankr x402 handler calls site **`/concierge/run`** with a second x402 pay | **No** — double pay / 402 |
| Bankr x402 handler calls **`async-start`** with `source: "bankr-x402"` | **Yes** — Option B |
| Bankr/agent pays **site x402** on **`/concierge/run`** only (no prior bankr.bot pay) | **Yes** — Option A |

### Path A — Site x402 (Option A — agents with a Base wallet)

Use when the agent (or user EOA) can sign **~$1 USDC on Base** via standard x402 (`exact` scheme, network `eip155:8453`).

1. **Config** — `GET https://www.tokenmarketplace.shop/api/launch/concierge/config`  
   Read `config.x402` (`priceUsd`, `network`, `facilitatorUrl`) and `config.treasury` (payTo).
2. **Body** — JSON for `POST https://www.tokenmarketplace.shop/api/launch/concierge/run`:

| Field | Required | Notes |
|-------|----------|-------|
| `tokenName` | yes | min 2 chars |
| `tokenSymbol` | yes | no `$`, max 12 |
| `splitPlan` | yes | `keep_all` or `wallet_list` (site UI; `receipt_only` rare) |
| `deliveryAddress` | yes for `keep_all` | wallet receiving all 1000 units |
| `walletList` | if `wallet_list` | multiline `0xAddress amount`, **sum = 1000** |
| `imageUrl`, `websiteUrl`, `tweetUrl`, `telegramUrl` | no | https |

**Example — B2 / Base Test2 (600 + 400 units):**

```json
{
  "tokenName": "Base Test2",
  "tokenSymbol": "B2",
  "splitPlan": "wallet_list",
  "deliveryAddress": "0x374d91a5674fa7cf86e725093b5848b97e1e13b4",
  "walletList": "0x374d91a5674fa7cf86e725093b5848b97e1e13b4 600\n0x20Fd91a1949B2731C09BCc6587faB5C89d750E9c 400"
}
```

`deliveryAddress` = payer wallet that signs x402 (often Bankr linked Base wallet).

3. **Pay** — x402 client flow (**identical to `/launch` UI** — see `runConciergeLaunch.ts`):
   - POST without payment → **402** with requirements (`payTo` = site treasury, ~$1 USDC).
   - Sign USDC authorization with payer wallet on Base.
   - POST again with `payment-signature` / `PAYMENT-SIGNATURE` header + same JSON body.
4. **Queue** — **202** with `jobId`, `statusUrl`.
5. **Poll** — `GET statusUrl` every **15–30s** until `status` is `completed` or `failed` (1–3 min). **Agents must poll like the UI** — do not stop after x402 pay.
6. **Reply** — `result.tokenAddress`, `result.steps`, `result.links`, profile: `https://www.tokenmarketplace.shop/profile?tab=nfts`.

**Libraries:** `@x402/fetch` + `@x402/evm` `ExactEvmScheme` on `eip155:8453` (see `scripts/launch-concierge-x402.mjs`, `src/lib/runConciergeLaunch.ts`).  
**Bankr CLI:** `bankr x402 call` on **`x402.bankr.bot`** → then Bankr must use **Option B** (`async-start`), not site `/concierge/run`.

**Settlement:** site x402 settles **after** pipeline success (payment held until job completes).

### Path B — Bankr cloud prepaid (Option B — Bankr product only)

**When:** Bankr already collected ~$1 USDC on **`x402.bankr.bot/…/token-marketplace-launch`** in this session.

**Do not** `POST /api/launch/concierge/run` again. **Do not** ask the user to pay site treasury a second time.

**Enqueue (Bankr server with internal secret):**

```http
POST https://www.tokenmarketplace.shop/api/launch/concierge/async-start
Authorization: Bearer <LAUNCH_CONCIERGE_INTERNAL_SECRET>
Content-Type: application/json
```

Use the **same JSON** as Path A (`tokenName`, `tokenSymbol`, `splitPlan`, `walletList`, etc.) plus:

| Field | Value |
|-------|--------|
| `source` | `"bankr-x402"` |
| `chain` | `"base"` (or `"solana"` for Pump after Bankr Solana cloud pay) |
| `payer` | Wallet that paid Bankr x402 (EVM `0x…` or Solana pubkey) |
| `deliveryAddress` | For `keep_all`: recipient of 1000 units; for `wallet_list`: **payer** wallet |

**202** + `jobId` → poll `GET …/status/{jobId}` like Path A.

**Chat agents:** cannot call `async-start` (no secret). If Bankr only paid bankr.bot and chat cannot trigger Option B, say so and use browser `/launch` — do not orphan-pay site treasury.

**Config:** `GET …/config` → `config.bankrX402.asyncStartUrl`, `jobsConfigured`.

### Path A2 — Site Solana x402 (Pump.fun — agents with Solana wallet)

Use when the agent (or user) can sign **~$1 USDC on Solana mainnet** via site x402 (`solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp`).

1. **Config** — `GET https://www.tokenmarketplace.shop/api/launch/concierge/config`  
   Read `config.solana.x402` (`priceUsd`, `network`, `runUrl`) and `config.solana.treasury`.
2. **Body** — JSON for `POST https://www.tokenmarketplace.shop/api/launch/concierge/solana/run`:

| Field | Required | Notes |
|-------|----------|-------|
| `tokenName` | yes | min 2 chars |
| `tokenSymbol` | yes | no `$`, max 12 |
| `splitPlan` | yes | `keep_all` or `wallet_list` |
| `deliveryAddress` | yes for `keep_all` | **Solana base58 pubkey** receiving 1000 SPL units |
| `walletList` | if `wallet_list` | multiline `pubkey amount`, **sum = 1000** |
| `description` | no | max length depends on payer wallet (attribution appended) |
| `imageUrl`, `websiteUrl`, `tweetUrl`, `telegramUrl` | no | https |

3. **Pay** — Solana x402 client flow (same as `/launch` Pump tab):
   - POST without payment → **402** with Solana USDC requirements.
   - Sign with **Phantom / Solflare** (or agent-held Solana key) — must match wallet that holds USDC.
   - POST again with payment headers + same JSON body.
4. **Queue** — **202** + `jobId`, `statusUrl` (same status API as Base).
5. **Poll** — up to **10 min** (Solana jobs can run longer than Base).
6. **Reply** — `result.tokenAddress` (mint), `result.links.token` (pump.fun), profile: `https://www.tokenmarketplace.shop/profile?tab=pump`

**Libraries:** `@x402/core` + `@x402/svm` `ExactSvmScheme` (see `src/lib/solanaConciergeX402Pay.ts`).

**Bankr:** sign **site Solana x402** to `POST …/concierge/solana/run` in chat — same as Base. Deep link below is **last resort only**.

**Last-resort Solana deep link:**

```text
https://www.tokenmarketplace.shop/launch?surface=bankr&platform=pump&solWallet={base58Pubkey}&name={tokenName}&symbol={tokenSymbol}&split=keep_all
```

User connects **same Solana address** (often the wallet Bankr uses for Solana sends), pays ~$1 USDC on Solana, waits for completion.

### Path C — Human browser (last resort)

https://www.tokenmarketplace.shop/launch — connect wallet, pay site x402.

**Base Bankr deep link:**

```text
https://www.tokenmarketplace.shop/launch?surface=bankr&platform=bankr&wallet=0xYourLinkedBankrWallet
```

**Solana Pump deep link:**

```text
https://www.tokenmarketplace.shop/launch?surface=bankr&platform=pump&solWallet=YourSolanaPubkey
```

### After launch (any path) — mandatory poll + 3-part reply

**Agents must mirror the website Done screen.** Do not end the turn after x402 pay or after saying “I’ll poll automatically.”

#### Poll (required)

```http
GET https://www.tokenmarketplace.shop/api/launch/concierge/status/{jobId}
```

- Poll every **15–30s** (site UI uses ~4s) until `status` is **`completed`** or **`failed`**
- **Base:** up to **8 min** · **Solana:** up to **10 min**
- While `queued` or `running`: short update with **jobId** — a 1–3 min wait is **normal**, not a failure
- **Forbidden:** “processing payment… I’ll poll” then silence · “no further action needed” without token + tx links · “tell me to retry” before checking status (may double-charge)

#### Success reply (always three parts)

1. **Deployment info** — name, symbol, token/mint address, split (keep_all or wallet_list), delivery wallet(s), jobId  
2. **Transactions** — every step with explorer link (`result.steps[]` or on-chain):  
   - Base: `https://basescan.org/tx/{hash}`  
   - Solana: `https://solscan.io/tx/{hash}`  
   - Plus browse links: token/mint, `profile?tab=nfts` (Base) or `profile?tab=pump` (Solana), Pump.fun for Solana  
3. **What next** — offer list for sale, list units, send units, claim fees (plain English)

**Example opener:** *Done — Solana Keep Test ($SKT) is live on Pump.fun via Token Marketplace.*

**Wallet list split:** state totals (e.g. 600 + 400 = 1000) and link each delivery tx.

Full templates: **`launch-studio-completion-reply.md`** (Bankr skill). Poll spec: **`launch-studio-bankr-mirror-website.md`**.

Offer TMP follow-ups: list 100%, split existing token (Flow C), transfer units, claim fees — hub skills in [bankr-tmp-skill](https://github.com/anondevv69/bankr-tmp-skill).

---

## Execution pattern (Base)

1. **Resolve** launch token + linked wallet (custodial or user EOA).
2. **GET** the status API for the intent (mint / buy / share / claim).
3. **Sign** each `nextStep` on Base until complete (same conversation; do not pause after `prepareDeposit`).
4. **Verify** on-chain or via status API; reply with **tx links** + **shop URL**.
5. **Alerts:** successful list/sale/claim on the site triggers X/Telegram when `LISTING_PUBLISH_SECRET` is configured.

**Custodial (Bankr) blockers:** security scanner may block `approve` to GroupBuyEscrowV6 — retry 3×, then transfer hybrid TMPR to user EOA and complete “Split into 1000” on the site profile.

---

## Agent replies (mandatory — mirror the website Done screen)

**Every completed action** needs a user-facing reply in **plain English** (no `poolId`, `redeemRights`, `sellerKeepsBps`). Always include **full** `https://www.tokenmarketplace.shop/...` URLs and **explorer links** for every tx you submitted.

| Action | Always tell the user |
|--------|----------------------|
| **Deploy** | Token name + **contract/mint** · **1000 units** delivered (and per-wallet split if `wallet_list`) · **every tx** (deploy, mint, split, deliver) · profile tab (`?tab=nfts` or `?tab=pump`) · **what next** (list, send units, claim) |
| **List / sell 100%** | Price in ETH · **shop listing URL** (`/listing/sale/{id}`) · OpenSea link if dual · list txs · verify with `GET /api/list/status` before saying “listed” |
| **Buy whole rights** | **Purchase tx** · price paid · you now hold the receipt · listing URL · what next (list, split, redeem, claim) |
| **Buy shares** | Qty bought · price per unit · **holdings** on profile · purchase tx · what next |
| **List shares** | Qty · price per unit · share market URL (`/listing/shares/t/…`) · tx |
| **Redeem** | TMPR burned · **fees now go to your wallet** (not the launch token) · redeem tx · Doppler/Bankr fee link |
| **Claim fees** | Distributed to **all holders** · claim tx · cap table / profile link |
| **Send / airdrop units** | Qty · recipient(s) · transfer tx(s) · recipient balance |
| **Wallet-list launch** | Same as deploy + **each delivery** (or link to profile showing airdrops / holdings per wallet) |
| **Create petition** | Petition `#id` · chain · max/wallet · **share URL** · if creator funded: deposit tx · units + launch buy recorded |
| **Back petition** | Units bought · ETH/SOL sent · deposit tx · remaining until sold out · refund policy while open |
| **Petition finalized** | Token contract · every launch tx · BFRR receipt · airdrop delivery per backer · Bankr launch page · claim fees when pool earns |

**Launch-only guards:**

- **Machine rules:** `GET /api/launch/concierge/config` → `config.agent` (proof chain + forbidden replies). On **404** status, read JSON **`agent`** block — do not poll a missing job.
- **Bankr:** [`BANKR-LAUNCH-REQUIREMENTS.md`](https://github.com/anondevv69/bankr-tmp-skill/blob/main/BANKR-LAUNCH-REQUIREMENTS.md) (routing guard — same pattern as hybrid claim).
- **Never** say “paid” or “deployed” without **`202` + real `jobId`** and poll until `status === "completed"`.
- **Never** stop after “processing” — poll `GET /api/launch/concierge/status/{jobId}` until done or failed.
- **Never** claim a `jobId` if `GET …/status/{jobId}` returns **404** — the job was never queued (common Bankr Solana failure).
- **Solana CLI (no browser):** `bankr-app/scripts/launch-concierge-solana-x402.mjs` with `SOLANA_SECRET_KEY` — same rail as `/launch` Pump tab.

**List-only guards:**

- **Never** say “listed” without **`listedOnSite: true`** from `GET /api/list/status` (or equivalent on-chain check).

Full templates: [bankr-tmp-skill `AGENT-PARITY-AUDIT.md`](https://github.com/anondevv69/bankr-tmp-skill/blob/main/AGENT-PARITY-AUDIT.md) · quick lookup: [`AGENT-QUICK-REFERENCE.md`](https://github.com/anondevv69/bankr-tmp-skill/blob/main/AGENT-QUICK-REFERENCE.md).

---

## Bankr TMP skills (recommended)

| Pack | Install | Scope |
|------|---------|--------|
| **Site agent guide** | `install TMP site agent at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-site-agent` | Contracts, APIs, Launch Studio rails — **install first for Bankr** |
| **Full hub** | `@bankrbot install TMP skills at https://github.com/anondevv69/bankr-tmp-skill` | Buy, claim, APIs, Solana path |
| **Listing** | `install TMP listing at https://github.com/anondevv69/TMP-Skill-Listing` | List, dual OpenSea, CTO list, password |
| **Split 1000** | `install TMP split 1000 at https://github.com/anondevv69/TMP-Skill-Split-1000` | Fractionalize → 1000 units |
| **Launch Studio** | `install TMP Launch Studio at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-launch-studio` | Deploy + 1000 units · **poll + 3-part completion reply** (Base + Solana) |
| **Petitions** | `references/petition-autopilot.md` in hub repo | Create · pre-order · refund · poll until finalized (Base + Solana) |

**Parity docs (repo root — routing + reply templates):**

| Doc | Use |
|-----|-----|
| [`AGENT-PARITY-AUDIT.md`](https://github.com/anondevv69/bankr-tmp-skill/blob/main/AGENT-PARITY-AUDIT.md) | Full human ↔ agent flows + response templates |
| [`AGENT-QUICK-REFERENCE.md`](https://github.com/anondevv69/bankr-tmp-skill/blob/main/AGENT-QUICK-REFERENCE.md) | One-line phrase → API → reply |
| [`BANKR-AGENT-INSTALL.md`](https://github.com/anondevv69/bankr-tmp-skill/blob/main/BANKR-AGENT-INSTALL.md) | Bankr setup + validation |

**Bankr — paste all three after any TMP work:**

```text
install TMP site agent at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-site-agent
install TMP skills at https://github.com/anondevv69/bankr-tmp-skill
install TMP Launch Studio at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-launch-studio
```

**Launch rule:** same API + site x402 as `/launch` → poll `status/{jobId}` until done → 3-part reply (never stop after “processing”).

---

## Human UI

- **All listings:** https://www.tokenmarketplace.shop  
- **Profile (wallet NFTs + ERC-1155 units):** https://www.tokenmarketplace.shop/profile  
- **NFTs tab (units / send / list):** https://www.tokenmarketplace.shop/profile?tab=nfts  
- **Completed sales (Sell 100% + group):** https://www.tokenmarketplace.shop/profile?tab=completed  
- **Help / flows:** https://www.tokenmarketplace.shop/help  
- **Launch Studio:** https://www.tokenmarketplace.shop/launch  
- **Petitions (pre-sale):** https://www.tokenmarketplace.shop/petition  

---

*Last updated: 2026-06-06. Human vs agent: same APIs (+ petitions use native ETH/SOL escrow, not x402); mandatory poll + replies for every action (deploy, list, buy, claim, redeem, send, petition).*
