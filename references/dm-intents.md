# DM / chat — structured intents (Bankr agent)

Ask the user for **facts in one message** so you never guess chain, addresses, or order.

**Plain-language mapping:** see **`ONE-LINE-INTENTS.md`** (one sentence → full flow, no interview).

**All flows:** see **`all-escrow-options.md`** (partial, group buy, crowdsource, employee grant, loan, platform matrix).

## Natural language (preferred — no technical paste required)

Users say things like:

```text
Create NFT for t7
Then list it for 0.0069 eth
```

or in one line: `Create NFT for t7 and list for 0.0069 eth`.

**Agent:** resolve ticker → launch token via `get_token_launch_info` / `token-fees`; use fee manager `0xBDF938149ac6a781F94FAa0ed45E6A0e984c6544` and escrow `0x6238698212D91845cD1c004DE85951055bB5b292` without asking. See main **`SKILL.md`** § **Natural language → full flow**.

Only ask the user for: **wallet** (if unknown), **which token** (if ambiguous among several launches), **ETH price** (if listing and not stated). **Do not** ask site vs OpenSea — **dual list** is the default.

**Listing (agents): dual** — `POST https://www.tokenmarketplace.shop/api/list/dual` after mint, confirm `site.steps`, then [OpenSea skills](https://github.com/BankrBot/skills/tree/main/opensea).

## Portfolio questions (no tx until user picks an action)

User may ask in natural language — answer with on-chain + API reads, then offer to run txs:

| Question | What to return |
|----------|----------------|
| What do I have **for sale**? | OpenSea listings for user's TMPR holdings (read proxy optional) |
| What **NFTs** do I have? | TMPR tokenIds in wallet + ticker from `positionOf` |
| What can I **convert to NFT** / list? | `bankr-launches` + `clanker-search-creator` minus already-escrowed pools |

```text
Chain: Base
My wallet: 0x...
Goal: portfolio_for_sale | portfolio_my_nfts | portfolio_can_create_nft
```

## Sell / split / grant / loan paths

**Path A — Create NFT only:** mint TMPR; no sale. (UI: **Create NFT**.)

**Path B — Sell 100% for ETH:** TMPR exists → **`POST /api/list/dual`** → site steps + OpenSea skills. Contract: `FeeRightsFixedSale` `0xe2A1…aA66`.

**Autopilot execution rule:** If user says "sell/list for X ETH" and provides enough info, complete the full flow in one run: mint (if needed) -> list API -> execute steps -> wait receipts -> verify listing status -> return URL. Do not pause at intermediate steps.

**Path C — Partial sale (custom keep %):** TMPR → approve **`GroupBuyEscrowV2`** `0x869D11606B94de1206669C55f8628749bCBBFfD4` → `createPartialListing(..., sellerKeepsBps, venueType, rightsEscrow)` → buyers `contribute` → `finalize`. **Do not** use `POST /api/list/dual` (that is sell 100% only).

**Path D — Group buy:** `GroupBuyEscrowV2.createListing` → `contribute` → `finalize`.

**Path E — Crowdsource:** `GroupBuyEscrowV2.createCrowdsource` payable (seed) → backers `contribute` → `finalize`. Fee % = each wallet’s ETH ÷ (seed + raised).

**Path F — Timed fee share (% to wallet, no sale):** redeem → beneficiary to grant escrow → `createGrant*` → lender runs `distributeFees` on schedule. **Not** partial sale.

**Path G — Paid time loan (100% for price):** redeem → loan escrow → `createLoan*` → borrower `acceptLoan` → `reclaimLoan`. Borrower claims fees directly.

**Path H — Get fee rights back:** **`redeemRights(tokenId)`** — cancel listings first if needed.

**Path I — Buy 1/1000 share (hybrid share market):** Resolve ticker → hybrid **tokenId** → scan **`HybridShareMarketplace`** `0x90230B…` → sort **cheapest first** → if **`accessKeyHash == 0`**: `buy(listingId, quantity)`; if **protected**: **`POST …/api/listings/access-authorize`** then `buy(listingId, quantity, authDeadline, signature)` — same **`msg.value`**. See **`share-market-buy.md`**. **Not** fixed sale; **not** partial `contribute`.

**Path J — Cancel share / unit listing:** **`GET …/api/share/list-status?wallet=&listingId=`** (or `hybridTokenId` after hybrid-status) → **`cancel(listingId)`** on `0x90230B…` — **`share-market-cancel-autopilot.md`**. **Not** `FeeRightsFixedSale.cancel`.

**Path K — Claim fees on hybrid unit (ERC-1155):** **`hybrid-claim-autopilot.md`** — user says “claim fees for [token]”; agent runs status API + all-holder tx silently. Never ask wallet or API jargon.

**Path L — Tweet / @bankr hybrid claim:** Same as **Path K**. Natural language only — e.g. `@bankrbot claim fees for CTO`.

**Path J — Tweet / @bankr social (list):** Same execution as DM when intent is clear (**sell/list 100% for X ETH**, token or ticker, **on marketplace** / **on tokenmarketplace**). Run **`sell-list-autopilot.md`** (`GET /api/mint/status` → all `nextStep` → `POST /api/list/dual` → site txs → OpenSea). **Do not** stop at “link the site” or “Create NFT tutorial” if wallet + `bankr.tx.prepare` / custodial sign are available. **Guidance-only** only when a real blocker remains (missing wallet, unsigned external EOA with no prepare path, API down) — report **`phase`** + next signer, never “I hit my step limit.” Partial sale / group buy / password share buys on public tweets: route to DM for signing. **Claim hybrid unit fees on tweet:** use **Path L** / **Path K** when wallet available — same as DM.

User should send something like:

```text
Chain: Base
Launched token: 0x...        # ERC20 the pool is for (e.g. t4)
My wallet (seller): 0x...
Escrow (BankrEscrowV3): 0x...   # canonical deploy
BFRR collection: 0x...
Path: receipt_only | list_for_sale_on_opensea
If list_for_sale_on_opensea: list price ETH: <number>   # OpenSea Seaport
```

**You (agent) must then:**

1. Resolve **`feeManager`** (initializer) with the **same resolver** the product uses for **`build-transfer-beneficiary`** — **not** a hardcoded address unless verified.  
2. Resolve **`poolId`**, **`token0`**, **`token1`** (sorted per pool; WETH on Base is `0x4200000000000000000000000000000000000006` when applicable).  
3. Confirm **`allowedFeeManager(feeManager)`** on escrow is **true** (else owner calls `setFeeManagerAllowed` once per manager).  
4. **`eth_call`** `getShares(poolId, seller)` on **that** `feeManager` — must **return a uint** (not revert). **`Revert ≠ “no shares”`** (wrong contract). **`0`** ⇒ `CallerDoesNotOwnRights` if they `prepare` anyway.  
5. Guide **`prepareDeposit` → beneficiary to escrow → finalize`** in that order (see main `SKILL.md`).  
6. If listing: hand off to **[opensea-marketplace](https://github.com/BankrBot/skills/tree/main/opensea/opensea-marketplace)** — confirm Seaport order on OpenSea before saying "listed".

## Quick list only (BFRR already in wallet — ask Bankr product)

Paste to Bankr / marketplace team:

```text
When the seller already holds BFRR (finalize done), add a "List only" path on SELL:
- Collect list price in ETH (> 0).
- Call approve(FeeRightsFixedSale, tokenId) then list(...) — skip prepareDeposit, beneficiary, and mint in the wizard.
- Keep the full orchestration for users who have not finalized yet.
```

## Bankr UI — listing is binary (paste to product)

```text
FeeRightsFixedSale has no "optional listing" state: either the BFRR is listed (held by marketplace until buy/cancel) or it is not (seller holds it).

Please remove "Optional" from the List step in Sell orchestration. Use two explicit flows:
- "Receipt only" = mint BFRR, no list.
- "List for sale" = require price > 0 and run approve + list; cancel listing returns BFRR to seller.

Do not use "0 ETH to skip listing" in the same flow as selling — that contradicts on-chain ZeroPrice.
```

## Bankr worker — `poolId` length (viem bytes31 / bytes33)

```text
Job fails: viem "bytes33" (or bytes31) vs expected bytes32 — the poolId string must be exactly 0x + 64 hex characters (32 bytes). If the error shows 66 hex chars after 0x, something is still appending extra nibbles (e.g. "0000") or concatenating two values. Please log: (1) raw poolId from token-fees API, (2) string length after 0x, (3) value passed into encodeAbiParameters — all three must show 64. Remove any placeholder hex (e.g. abcdef...) in production jobs.

Workaround for users who already hold BFRR: MANAGE → list for sale (skips PREPARE).
```

## Partial sale (GroupBuyEscrowV2)

**Natural language:** “sell 5% for 0.05 ETH” ⇒ `sellerKeepsBps = 9500` (keep 95%, sell 5%). `priceWei` = ETH for the **5% slice**, not whole token.

```text
Chain: Base
TMPR collection: 0xCD66340D93E212bEC6Db1b22476e4f1276380C3e
TMPR tokenId: <uint256>
sellerKeepsBps: <100-9900>       # KEEP % — sell 5% => 9500
priceWei: <wei for SOLD slice>   # e.g. 0.05 ETH if selling 5% slice for 0.05 ETH
durationSeconds: <e.g. 604800>
minContributionWei: <0 or e.g. 0.01e18>
GroupBuyEscrowV2: 0x869D11606B94de1206669C55f8628749bCBBFfD4
venueType: 1                     # 1=Bankr 2=ClankerV4 3=ClankerV3 4=Zora
rightsEscrow: 0x6238698212D91845cD1c004DE85951055bB5b292
```

Seller: `approve(V2, tokenId)` → `createPartialListing` → share listingId → buyers `contribute` on site **Group buy** tab → `finalize`.

**Wrong:** `POST /api/list/dual` · `sellerKeepsBps=500` for “sell 5%” · GroupBuy v1 `0x6F007…` without `venueType`.

## Crowdsource (GroupBuyEscrowV2)

```text
seed (msg.value): e.g. 0.1 ETH
targetRaise: e.g. 0.1 ETH from outsiders (not including seed)
# ten backers × 0.01 ETH => each gets 0.01/(0.1+0.1)=5% of total fees
```

## Timed fee share (Bankr)

```text
Chain: Base
TMPR tokenId: <uint256>          # will redeem first
grantee: 0x...
grantBps: <100-9900>             # e.g. 1000 = 10%
durationDays: <1-365>
FeeRightsTimedGrantEscrow: 0xb56973cD7Bcb1AD127dFfE112daAE3960a65CC41
feeManager / poolId / token0 / token1: from positionOf or token-fees API
```

Sequence: `redeemRights` → `updateBeneficiary` to grant escrow → `createGrantBankr` → lender runs `distributeFees` regularly (grantee receives tokens, does not Bankr-claim during Bankr grants).

## Social / tweet test prompts

See **`bankr-agent-test-prompts.md`** for full QA list.

## Buy a listed BFRR

```text
Chain: Base
listingId: <uint>
My wallet (buyer): 0x...
Marketplace: 0x...
```

Read **`getListing(listingId)`**, confirm **`active`**, then **`buy`** with **`msg.value == priceWei`**.

## After any mined tx — verification block (agent must send)

```text
Tx: <hash> (BaseScan link)
Token: 0x...   # launched ERC20

get_token_launch_info → feeRecipient should be:
  - user wallet after redeemRights
  - escrow after finalize / while TMPR held

Verify:
• Doppler: https://app.doppler.lol/tokens/base/<token>
• Bankr: https://bankr.bot/launches/<token>

If My Launches is stale after redeem, indexer delay — links above are authoritative.
```

Full rules: main **`SKILL.md`** § **Verification & Reporting**.

## Stop / support

If the user is stuck, ask for **the latest tx hash** on BaseScan and whether they are **escrow owner** vs **seller** — many issues are **wrong role** or **wrong step order**.
