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
| Launch / deploy new token + 1000 units | **Site x402 API** — Bankr signs in chat, no browser | **`POST /concierge/run`** or **`/solana/run`** + poll · `/launch` deep link = last resort only |

**Wrong routing (common bugs):**

- `/listing/sale/{id}` → **FeeRightsFixedSale** `0xe2A134…` — **not** HybridShareMarketplace `0x9023…`
- `/listing/shares/t/{tokenId}` → share book — **not** fixed sale id `N` on `0xe2A1…`
- Listing **#28** on a card may be **TMPR serial #28** while the buy URL uses **sale id** (e.g. `/listing/sale/25`) — use `buy-status` or on-chain `getListing`.
- Calling **`/concierge/run` after Bankr x402 pay** — double rail; Bankr pay already covers launch via `async-start`
- Calling **`async-start` from an agent** — internal secret only; use site x402 or Bankr x402 instead
- Using **`bankr x402 call` on `x402.bankr.bot/…/token-marketplace-launch`** — **deprecated**; use **site x402** on `/concierge/run` instead (Bankr can sign to tokenmarketplace.shop)

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

---

## Launch Studio — deploy new token + 1000 units

One paid flow per chain:

- **Base (Bankr):** deploy token → mint TMPR → split 1000 ERC-1155 units → deliver  
- **Solana (Pump.fun):** deploy on Pump → split 1000 SPL units → deliver  

Same **site x402** payment model on both chains (~$1 USDC); different wallet and API endpoint.

### Golden rule for agents

**One rail:** **site x402** on `POST /api/launch/concierge/run` (Base) or `/solana/run` (Solana).

**Bankr** signs x402 to **`tokenmarketplace.shop`** directly — same as Cursor, MCP, or any bot. **Do not** use `x402.bankr.bot/…/token-marketplace-launch` (deprecated legacy cloud).

Skill: `tmp-launch-studio/launch-studio-agent-autopilot.md`  
CLI (Base): `bankr-app/scripts/launch-concierge-x402.mjs`

### Recommended path by audience

| Who | Base | Solana |
|-----|------|--------|
| **Any agent including Bankr** | `POST /api/launch/concierge/run` + site x402 sign + poll | `POST /api/launch/concierge/solana/run` + poll |
| **CLI with private key** | `node scripts/launch-concierge-x402.mjs` | Solana x402 client (see `solanaConciergeX402Pay.ts`) |
| **Cannot sign x402 at all** | `/launch?platform=bankr&wallet=0x…` (**last resort**) | `/launch?platform=pump&solWallet=…` (**last resort**) |
| **Human browser only** | `/launch` → Bankr tab | `/launch` → Pump.fun tab |

| Who | Best path | Why |
|-----|-----------|-----|
| **Bankr chat / any agent** | **Site x402** → `/concierge/run` or `/solana/run` | One rail; Bankr signs to tokenmarketplace.shop; no browser |
| **Human browser only** | `/launch` UI | No agent signing |

**Deprecated:** `x402.bankr.bot/…/token-marketplace-launch` — do not use for launches.

**After Base launch:** units on `https://www.tokenmarketplace.shop/profile?tab=nfts` · `https://bankr.bot/launches/{tokenAddress}`  

**After Solana launch:** units on `https://www.tokenmarketplace.shop/profile?tab=pump` · `result.links.token` → pump.fun

**Do not use deep links as agent default.** Deep links are for humans or agents that cannot sign x402.

### Do not chain Bankr x402 → site x402

These are **separate USDC payments** to **different treasuries** with **different facilitators**. A Bankr x402 receipt cannot be replayed as site x402 `PAYMENT-SIGNATURE` headers.

| Approach | Verdict |
|----------|---------|
| Bankr x402 handler calls site **`/concierge/run`** with a second x402 pay | **No** — would require paying site treasury again (or a server wallet relay — ops nightmare) |
| Bankr x402 handler calls **`async-start`** + `bankrX402Prepaid: true` | **Yes** — this is the designed bridge: Bankr collected USDC, site skips its own x402 verify |
| Agent pays **site x402** directly on **`/concierge/run`** | **Yes** — simplest for agents that can sign Base USDC x402 |

**Easier ops:** fix `async-start` secret sync for Bankr chat **or** have agents use **site x402** when they control a Base wallet. Do not build a third “relay x402” layer.

### Path A — Site x402 (preferred for agents with a Base wallet)

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

3. **Pay** — x402 client flow (same as `/launch` UI):
   - POST without payment → **402** with requirements (`payTo` = site treasury, ~$1 USDC).
   - Sign USDC authorization with payer wallet on Base.
   - POST again with `payment-signature` / `PAYMENT-SIGNATURE` header + same JSON body.
4. **Queue** — **202** with `jobId`, `statusUrl`.
5. **Poll** — `GET statusUrl` every **15–30s** until `status` is `completed` or `failed` (1–3 min).
6. **Reply** — `result.tokenAddress`, `result.steps`, `result.links`, profile: `https://www.tokenmarketplace.shop/profile?tab=nfts`.

**Libraries:** `@x402/core` + `@x402/evm` `ExactEvmScheme` on `eip155:8453` (see site `src/lib/runConciergeLaunch.ts`).  
**Bankr CLI:** `bankr x402 call` works only on **`x402.bankr.bot`** — not on `tokenmarketplace.shop` URLs.

**Settlement:** site x402 settles **after** pipeline success (payment held until job completes).

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

### Path B — Deprecated Bankr x402 cloud

**Do not use** `x402.bankr.bot/…/token-marketplace-launch`. Use **site x402** Path A only.

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

### After launch (any path)

When `status === completed`, reply with **full links** like the website Done screen — see **`launch-studio-completion-reply.md`** in tmp-launch-studio (BaseScan, OpenSea, Doppler, Bankr launches, Solscan, tx log). User pastes **Job ID** from Done screen, or agent polls `GET /api/launch/concierge/status/{jobId}`.

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

## Bankr TMP skills (recommended)

| Pack | Install | Scope |
|------|---------|--------|
| **Site agent guide** | `install TMP site agent at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-site-agent` | Contracts, APIs, Launch Studio rails — **install first for Bankr** |
| **Full hub** | `@bankrbot install TMP skills at https://github.com/anondevv69/bankr-tmp-skill` | Buy, claim, APIs, Solana path |
| **Listing** | `install TMP listing at https://github.com/anondevv69/TMP-Skill-Listing` | List, dual OpenSea, CTO list, password |
| **Split 1000** | `install TMP split 1000 at https://github.com/anondevv69/TMP-Skill-Split-1000` | Fractionalize → 1000 units |
| **Launch Studio** | `install TMP Launch Studio at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-launch-studio` | New deploy + 1000 units (x402 Base) |

Hub buy guide: `buy-marketplace-autopilot.md` in [bankr-tmp-skill](https://github.com/anondevv69/bankr-tmp-skill).  
Launch guide: `tmp-launch-studio/launch-studio-agent-autopilot.md` · `launch-studio-payment-rails.md` · **this file § Launch Studio**.

---

## Human UI

- **All listings:** https://www.tokenmarketplace.shop  
- **Profile (wallet NFTs + ERC-1155 units):** https://www.tokenmarketplace.shop/profile  
- **NFTs tab (units / send / list):** https://www.tokenmarketplace.shop/profile?tab=nfts  
- **Completed sales (Sell 100% + group):** https://www.tokenmarketplace.shop/profile?tab=completed  
- **Help / flows:** https://www.tokenmarketplace.shop/help  
- **Launch Studio:** https://www.tokenmarketplace.shop/launch  

---

*Last updated: 2026-06-03. Launch Studio: site x402 in chat (Path A / A2) for Bankr and all agents; browser `/launch` last resort only.*
