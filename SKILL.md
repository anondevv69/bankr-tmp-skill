---
name: bankr-fee-rights
description: TMP skills (Token Marketplace) — fee rights on Base in plain English. Users say tickers and ETH amounts only; agent resolves contracts silently. Mint, sell 100%, buy 1/1000 shares (public or password-gated via access-authorize), partial sale, group buy, crowdsource, timed grant, loan, redeem, bundle & rebirth, and plan reply-drop fee-right campaigns. Read flows-reference.md for every product (agent steps + human language side-by-side).
tags: [bankr, base, tmp, tmp-skills, token-marketplace, cfr, escrow, doppler, fee-rights, tmpre, nft, marketplace, group-buy, partial-sale, employee-grant, loan, bundle-rebirth]
version: 39
metadata:
  clawdbot:
    emoji: "🧾"
    display_name: "TMP skills"
    homepage: "https://github.com/anondevv69/bankr-tmp-skill"
---

# TMP skills — Token Marketplace fee rights (Base)

**Bankr branding:** Refer to this skill pack as **TMP skills** (Token Marketplace skills) in chat — e.g. “Using TMP skills to create your NFT…” Install from this repo’s root: `https://github.com/anondevv69/bankr-tmp-skill`.

Guidance for agents helping users with **creator fee rights** custody (ERC721 **TMPR** receipts) and **BankrEscrowV3** on **Base (chain id 8453)**. **Listing = dual venue:** tokenmarketplace.shop (`FeeRightsFixedSale`) **and** OpenSea.

## Listing policy (read first — dual list API)

When the user says **list**, **sell rights**, **sell for X ETH**, or **create NFT and list for X ETH**:

| Step | Action |
|------|--------|
| 1 | Mint TMPR if needed (3 escrow txs) |
| 2 | `POST https://www.tokenmarketplace.shop/api/list/dual` with `{ tokenId, priceEth, seller }` |
| 3 | Execute each `site.steps[]` via **`bankr.tx.prepare` / `confirmTransaction`** (approve → list) |
| 4 | **[OpenSea skills](https://github.com/BankrBot/skills/tree/main/opensea)** — `opensea-marketplace` create Seaport listing on Base |
| 5 | Verify: `GET /api/list/status?tokenId=` — site listing active **and** OpenSea order (or user confirms manual OS step) |

**Do not** hand-build `approve`/`list` calldata — use the API response. **Do not** say **“prepared for sale”** after mint only.

**“Create NFT and list for 0.0069”** = mint (3 txs) → dual API → site txs → OpenSea skill.

**Primary UX:** DMs / Ask Bankr / [Bankr Apps](https://docs.bankr.bot/apps/overview) (`apps/token-marketplace/` in repo) — see [QR Coin skill pattern](https://github.com/BankrBot/skills/blob/main/qrcoin/SKILL.md).

## START HERE — primary references

**Every product (agent steps + human language side-by-side):** **`references/flows-reference.md`** — the master reference for all flows (mint, sell, **buy 1/1000 share**, partial, group buy, …). Each flow shows exactly what the agent does silently AND what users say AND how the agent replies in plain English. Read this before any other reference.

**Normal talk only:** **`references/normal-talk-only.md`** — never expose poolId, bps, wei, escrow addresses, `approve GroupBuyEscrow`, or contract names to users. Resolve silently; reply in plain English always.

**CRITICAL — user pasted `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e`:** That is the **TMPR NFT collection**, not a token. Do not run `token-fees` on it. Read **`references/tmpr-collection-address-trap.md`** → ask for the token name or ticker instead.

**Active loan — no forward sale:** While a token is on a **paid time loan**, **do not** dual-list, partial-sell, grant, or bundle that pool. Fee rights must **return to the original lender** on `reclaimLoan` — not be sold forward. Lender has no TMPR to list; borrower must not list either. Read **`references/loan-no-forward-sale.md`** before any sale flow.

**What can be reversed vs not — the master rule:** **`references/product-rules.md`** — covers every product. Key rules: (1) partial sale / group buy / crowdsource are **permanent** once finalized — no undo; (2) timed grants lock the grantee OUT of the stream — they only receive token transfers, cannot sell or loan; (3) loans auto-return at `endTime` — **fees during the loan go to the borrower directly**, not bundled back to lender; (4) after a finalized split, no one can redirect the underlying stream. Read before any grant, loan, or sale-integrity question.

**Plain language intent routing:** **`references/user-language.md`** — maps spoken phrases to flows. **`references/all-escrow-options.md`** — full decision table + all mainnet addresses.

**Other references (load as needed):** `listing-channels.md` (site vs OpenSea), **`share-market-buy.md`** (**buy 1/1000 shares — “cheapest”, “buy 1”, offer rank**), `reply-drop.md` (**planned reply-drop / reply-split campaign rules**), `redeem-rights-playbook.md` (redeem failures), `partial-sale-resolve-token.md` (token resolution for partial sales), **`bundle-rebirth-playbook.md`** (Bundle & Rebirth — **read first; stops agents getting stuck on mint/bundle**), **`mint-pending-deposit.md`** (stuck `prepareDeposit` / `needs_transfer`), `bundle-rebirth.md` (custody + APIs), `dm-intents.md` (DM templates), `bankr-agent-test-prompts.md` (QA).

---

## Bundle & Rebirth (one prompt — mandatory)

When user says **bundle**, **rebirth**, **merge into $TICKER**, **burn N NFTs and launch**, or **use fees for initial buy**:

| Rule | Detail |
|------|--------|
| **One conversation** | Chain: `POST /api/bundle/prepare` → claim → `POST /api/bundle/disband` (`feesTo` = **user wallet**) → `POST api.bankr.bot/token-launches/deploy` → WETH swap (initial buy). Do not stop after bundle unless they only asked to bundle. |
| **Custody** | User signs all txs; WETH goes to **user** on disband; initial buy from **user** WETH. **Never** say Token Marketplace holds their coins or pays from a platform wallet. |
| **Plain English** | “Fee receipts” / “fee rights” — not `createBundle`, `poolId`, `feesTo` in chat. |
| **What burns** | TMPR fee-receipt NFTs + old **fee streams** (dead wallet). **Not** destroying the 3 launched ERC-20 tokens on chain. |
| **Contract** | `FeeRightsBundleEscrow` `0x429Af4F73d9a254607890930848Be2E9f50dBb3F` · Vercel: `BUNDLE_ESCROW_ADDRESS` |

**Mandatory before bundle execute:** **`references/bundle-rebirth-playbook.md`** (TMPR scan first, mint→confirm→bundle, explain vs execute). Custody/APIs: **`references/bundle-rebirth.md`** · Flow 9: **`references/flows-reference.md`**.

⚠️ **Critical:** (1) **Explain** vs **execute** — "what is bundle & rebirth?" is not a verification request. (2) **`GET /api/mint/status` before any mint tx** — never re-`prepareDeposit` when phase is `needs_transfer` / `needs_finalize`. (3) User says **"start minting / do all steps"** → run `nextStep` from mint/status (Bankr wallet may sign; user does not need a separate dashboard step). (4) Sign transfer + finalize from **`signerMustBe`**, not a random wallet. (5) **`phase: needs_transfer_tmpr`** → `safeTransferFrom` TMPR from `tmprOwner` (often Bankr `0x374D…`) to user **before** `POST /api/bundle/prepare` with user as `owner`. (6) **Clanker TMPR listings** on deployed `ClankerEscrowV4` `0x3546…` — **`finalize()` reverts** (no `routeFeesTo`); use ops `releaseRights` + `completeAfterExternalClankerRoute` — **never** tell user to retry MetaMask finalize.

---

## Reply Drop / Reply Split (planned hybrid campaign)

When user says **first 100 replies get 1% each**, **first 1000 get 1/1000**, **free claim page**, or **password protect the page**:

| Rule | Detail |
|------|--------|
| **This is fee rights, not token supply** | Always explain it as a share of future **claimable fees**, not ownership of the ERC-20 supply. |
| **Translate to units** | Hybrid TMPR uses `1000` units total. `1` unit = `0.1%`; `10` units = `1%`. |
| **Automated reply → claim** | **Not live** — winner selection and wallet linking still need backend. |
| **Password-gated marketplace buy** | **Live** on share + fixed sale (`0x9023…` / `0xe2A1…`) — see **`share-market-buy.md` § Password-protected listings**; this is **not** the same as auto-claiming from a tweet. |
| **What to do today** | For reply drops: explain units + capture params. For “buy with password”: execute **`access-authorize`** + gated `buy` if user provides password + wallet. |
| **Read first** | `references/reply-drop.md` |

---

## User vocabulary (website-aligned)

| UI / user phrase | Agent action |
|------------------|--------------|
| **Create NFT** | `prepareDeposit` → fee beneficiary to escrow → `finalizeDeposit` (mints TMPR) |
| **Sell rights** / **list for X ETH** / **sell 100%** | **Dual list:** `POST /api/list/dual` → site steps + OpenSea skills (§ Where to list) |
| **Partial sale** / **sell 5% for X ETH** / **keep 95% sell 5%** | **`GroupBuyEscrowV2.createPartialListing`** — `sellerKeepsBps` = **keep** % (sell 5% ⇒ **9500**); `priceWei` = ETH for **sold slice only**; `venueType` + `rightsEscrow` |
| **Group buy** / **crowdfund fee rights** | **`GroupBuyEscrowV2.createListing`** → `contribute` → `finalize` |
| **Crowdsource** / **I seed 0.1 raise 0.1 from backers** | **`GroupBuyEscrowV2.createCrowdsource`** payable (seed) — co-own by ETH; **not** partial sale |
| **Timed fee share** / **give 10% for 30 days** / **assign wallet X%** | **`FeeRightsTimedGrantEscrow`** — no ETH from grantee; lender runs **`distributeFees`** on schedule |
| **Paid time loan** / **loan fees for N days for X ETH** | **`FeeRightsLoanEscrow`** — borrower gets **100%**; claims fees directly; **not** grant distribute |
| **Get fee rights back** / **return to wallet** / **be the reward person again** / **convert NFT back** | `redeemRights(tokenId)` on correct escrow — **not** an NFT transfer (see § Get fee rights back) |
| **What’s for sale?** | `GET /api/list/status` — site + OpenSea; group buy listings on site **Group buy** tab |
| **What NFTs do I have?** | TMPR balance + `positionOf` per tokenId |
| **What can I convert to NFT?** | Launches API + `getShares` > 0, not escrowed, no receipt yet |
| **Bundle & Rebirth** / **merge into $TICKER** | `/api/bundle/prepare` → claim → disband (`feesTo` = user) → Bankr deploy → initial buy — see § Bundle & Rebirth |
| **Buy a 1/1000 share** / **cheapest share** / **buy 1 unit of $t7** | **`HybridShareMarketplace.buy`** on hybrid stack — see **`references/share-market-buy.md`** |
| **Buy N shares with password `…`** / **password-protected share** | Read `accessKeyHash` → **`POST …/api/listings/access-authorize`** → **`buy(listingId, qty, authDeadline, signature)`** — **`share-market-buy.md` § Password-protected listings** |
| **List shares with password** / **free gated share listing** | Seller: site **List shares** (6-arg `list`) or fixed-sale **`POST /api/list/dual`** with `"password"` for whole TMPR — **`share-market-buy.md`** |
| **Reply drop** / **first 100 replies** / **first 1000 replies get 1/1000** | **Planned** hybrid fee-right campaign — explain as units, capture params, do **not** claim live execution |

Full intent router, portfolio steps, and **which option** table: **`references/user-language.md`** + **`references/all-escrow-options.md`**.

For repo contracts, ABIs, and launch QA: **`LAUNCH_CHECKLIST.md`**, **`BANKR_APP.md`**, **`README.md`** in [fee-rights-exchange](https://github.com/anondevv69/bankrtokennft).

---

## Natural language → full flow (how humans talk)

Users speak in **tickers, token names, and ETH prices** — not fee managers or escrow addresses. **Resolve everything yourself** from the tables below + Bankr APIs, then orchestrate txs.

**User-facing voice:** Follow **`references/normal-talk-only.md`**. Technical names (`sellerKeepsBps`, `redeemRights`, contract hex) are for **your** planning and tool calls only — not for questions or default replies.

**Do not** ask them to paste `feeManager`, `poolId`, `tokenId`, or escrow addresses. If stuck, ask **one** human question (ticker, OpenSea link, or “do you already have the marketplace NFT?”).

### Phrases you must handle without extra questions

| User says (examples) | You infer | What you do |
|----------------------|-----------|---------------|
| “Create NFT for **t7**” | Launch token **t7** | Resolve `0x9021…3ba3` via `get_token_launch_info` or `token-fees` |
| “Create NFT for my **test** token” / “**testing**” | Match name/symbol from launches API | Same — pick the ERC-20 they mean |
| “Create NFT for … **token contract** `0x9021…`” | That hex is the **launched ERC-20** | Use it as `tokenAddress` — **not** as fee manager |
| “**Then list** it for **0.0069** eth” / “list for **.0069**” | Second step on **same** token | `POST /api/list/dual` → site txs → OpenSea skills |
| “Create NFT for t7 **and list** for 0.0069 eth” | **Compound** mint + **dual** sell | Mint (3 txs) → dual API → site + OpenSea |
| “sell the rights of $t7” / “list it” (no venue) | **Dual list** (shop + OpenSea) | Do **not** ask “site or OpenSea?” — run both via API + skills |
| “**sell 5%** of $t7 for **0.05 eth**” / “keep 95% sell 5%” | **Partial sale** — **not** dual list, **not** grant | `sellerKeepsBps=9500`, `priceWei` for 5% slice, **GroupBuyEscrowV2** |
| “sell 5% of **0x7942…** / **test1** for **0.005 eth**” | **Partial sale** + resolve token | See **`partial-sale-resolve-token.md`** — scan TMPR first; **ERC-20 balance ≠ fee rights** |
| “@bankr sell 5% of this token for X” (tweet/DM) | Same as partial sale | Ask token/TMPR + wallet; link **tokenmarketplace.shop**; **cannot** list without signatures |
| “**Buy the cheapest** 1/1000 share of **$t7**” / “buy **1** share at best price” | **Share market buy** — **not** fixed sale, **not** partial pool | Sort offers by price → `buy(listingId, qty)` — **`share-market-buy.md`** |
| “**Buy 1** share of **$CTO** with password **`xxx`**” / “mint me 1 with password xxx” | **Gated share buy** (usually **buy**, not mint) | `access-authorize` + 4-arg `buy` — **`share-market-buy.md` § Password-protected listings** |
| “Buy **version 2**” / “**second cheapest** offer” | **Offer rank #2** (after sort) | Same — pick `offers[1]` if it exists |
| “I'll seed 0.1 ETH, raise 0.1 from 10 people” | **Crowdsource** | `msg.value=0.1`, `targetRaise=0.1` — fee % = ETH / (seed+raised) |
| “Convert my fee rights for t7 to an NFT” | Same as Create NFT | Never treat a random `0x…` as fee manager |
| “return **0xCD6634…** to my wallet” / “fees for 0xcd6634…” | **TMPR collection trap** — **not** token-fees | See **`tmpr-collection-address-trap.md`** — ask tokenId or ticker |
| “First **100 replies** get **1% each**” / “first **1000 replies** get **1/1000**” | **Reply drop** request | Translate to units, explain it is a **planned** fee-right campaign, and gather campaign params via **`reply-drop.md`** |

### Silent resolution checklist (run before first tx)

Given **ticker and/or launch token address** and **optional list price in ETH**:

1. **`tokenAddress`** — from user’s contract, or `get_token_launch_info(ticker)`, or `GET …/doppler/token-fees/{token}`.
2. **`poolId`**, **token0**, **token1** — from that API / launch info (WETH on Base = `0x4200000000000000000000000000000000000006`).
3. **`feeManager`** — production Bankr Doppler: **`0xBDF938149ac6a781F94FAa0ed45E6A0e984c6544`** unless registry + `getShares` prove another.
4. **`escrow`** — **`0x6238698212D91845cD1c004DE85951055bB5b292`** (BankrEscrowV3).
5. **`allowedFeeManager(feeManager)`** on escrow — must be **true** (it is for `0xBDF938…`).
6. **`getShares(poolId, userWallet)`** on fee manager — must be **> 0** before `prepareDeposit`.
7. **List price** — parse `0.0069` / `.0069` → **`6900000000000000`** wei (18 decimals).

**Users should never need to say:** “Use fee manager 0xBDF938…” — that is **your** default for Bankr launches on this marketplace.

### Example A — two messages (human style)

**User:** “Create NFT for t7.”  
**Agent (internal):** token `0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3`, poolId from token-fees, feeManager `0xBDF938…`, escrow `0x6238…`.  
**Agent (user-facing):** Queue prepare → beneficiary → finalize; show BaseScan links per step.

**User:** “Then list it for 0.0069 eth.”  
**Agent:** Resolve `tokenId` → `POST /api/list/dual` → confirm site steps → **OpenSea skills**. **Verification:** `GET /api/list/status?tokenId=`.

### Example B — one message (compound) — default today

**User:** “Create NFT for t7 and list it for 0.0069 eth.”  
(or: “sell the rights of $t7, list for 0.0069 ETH” — **dual list implied**)

**Agent:** One job:

1. **Mint (3 txs):** `prepareDeposit` → beneficiary → escrow → `finalizeDeposit`
2. **`POST /api/list/dual`** — body: `{ "tokenId": "<from mint>", "priceEth": "0.0069", "seller": "<wallet>" }`
3. **Site:** for each step in `response.site.steps`, `prepare:transaction` with `to`, `data`, `value`
4. **OpenSea:** `opensea-marketplace` using `response.openSea` hints
5. **Verify:** `GET /api/list/status?tokenId=` + Doppler/Bankr launch links — **never** claim “listed” without site + OpenSea (or documented OS fallback)

### Example C — what NOT to do (from real failure)

**User:** “Convert fee rights for `0x935E…ABA3` to NFT, list 0.0069 eth.”  
**Wrong:** Treat `0x935E…` as fee manager → “not allowlisted” → stop.  
**Right:** `0x935E…` is not a launch token; user meant **t7** → resolve **`0x9021…`** + fee manager **`0xBDF938…`** → proceed.

More phrase → action rows: **`references/user-language.md`** § **Compound requests**.

---

## Canonical deployments (verify before mainnet advice)

These are **example production addresses** from this project’s Base deploy; **always confirm** on BaseScan / repo if user reports a mismatch.

| Role | Address |
|------|---------|
| **BankrEscrowV3** | `0x6238698212D91845cD1c004DE85951055bB5b292` *(Token Marketplace bundle — verify)* |
| **TMPR receipt (`CFR`)** | `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e` *(from `escrow.receipt()` — verify)* |
| **Legacy (do not use)** | Escrow `0x7BD14E540Ac55E229587Bf3Cd0Fc815A7afcf461` → BFRR `0x02441aDdC542A3a3283c4468780eB876F9ADA8BA` |
| **FeeRightsFixedSale** (site) | `0xe2A13499292D43254026DAf0C4F75988242BaA66` — list via **`POST /api/list/dual`** |
| **GroupBuyEscrowV2** (group / partial / crowdsource) | `0x869D11606B94de1206669C55f8628749bCBBFfD4` — `venueType` + `rightsEscrow` on `create*` |
| GroupBuyEscrow v1 (legacy) | `0x6F00715124d79114E03A94676bEa3BE697F77def` — Bankr-only finalize |
| **FeeRightsLoanEscrow** (bag worker, 100% loan) | `0x9F167C8dce30ca1e6F46bC2491d6434e30568790` |
| **FeeRightsTimedGrantEscrow** (employee grant, timed %) | `0xb56973cD7Bcb1AD127dFfE112daAE3960a65CC41` |
| **ClankerEscrowV4** | `0x3546A98C09fc5a3E162d510DB331C4dcEdB6EADa` |
| **ZoraEscrowV1** (mint TMPR for Zora) | `0x7A7540B048a8CC96837E83604B32559CCe911D9F` |
| **Hybrid TMPR** (1/1000 ERC-1155 units) | `0xD8e0639DfAa1cB2b9f9642EeCbd40b1e5a8b42A7` |
| **HybridShareMarketplace** (buy/sell units) | `0x90230B59D01c6e0306236eF7afc8105908c4DB0B` |
| **GroupBuyEscrowV6** (split into 1000 units) | `0x56bd948671955D0Ed82a88f136779cB76f551e0C` |
| **Bankr Doppler fee manager** (allowlisted on production escrow) | `0xBDF938149ac6a781F94FAa0ed45E6A0e984c6544` — verify with `allowedFeeManager` on escrow |

Other addresses (**poolId**, **token0/token1**, **launched ERC20**) are **per launch** — resolve from Bankr APIs or on-chain reads. Wrong `poolId` / token order ⇒ `prepareDeposit` reverts or wrong pool.

**Platform support (summary):** Mint + sell 100% + redeem → **Bankr, Clanker, Zora TMPR**. Group buy / partial / crowdsource → **GroupBuyEscrowV2** (Bankr live on mainnet; Clanker/Zora need redeployed escrows with `routeFeesTo` / `routePayoutTo`). Timed fee share → Bankr on `0xb569…`; Clanker/Zora grants need new grant deploy. Loan → **Bankr + Clanker** on-chain. Details: **`references/all-escrow-options.md`**.

**Site UX:** https://www.tokenmarketplace.shop → **Use cases** tab (examples + grant claiming playbook).

---

## Address disambiguation (do not confuse roles)

Users often paste **one** `0x…` address. **Never** assume it is the **fee manager** without verification.

| What the user means | Typical address | Used for |
|---------------------|-----------------|----------|
| **Launched token** (t7, t9, …) | ERC20 e.g. `0x9021…3ba3` | `tokenAddress` in Bankr APIs, Doppler/Bankr launch links |
| **Fee manager** (Doppler initializer) | e.g. `0xBDF938…6544` on production Bankr | **`prepareDeposit(feeManager, …)`** — must be **allowlisted** on escrow |
| **Escrow** | `0x6238…b292` | Beneficiary during escrow; `newBeneficiary` in transfer |
| **TMPR receipt** | `0xCD6634…0C3e` | NFT collection for list/buy/redeem |

**Wrong pattern (blocks users incorrectly):** User says “convert fee rights for `0x935E…`” → agent treats `0x935E…` as **fee manager** for **t7** (`0x9021…`).  
`0x935E…` is **not** a valid Bankr launch token (`token-fees` returns error) and **`getShares` reverts** on that contract for t7’s pool — it is **not** the fee manager.

**Correct pattern for “Create NFT for t7” / “convert fee rights for t7”:**

1. **`GET /public/doppler/token-fees/0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3`** → read **`poolId`**, confirm user **`share` > 0**.
2. **`feeManager`** = production Bankr manager **`0xBDF938149ac6a781F94FAa0ed45E6A0e984c6544`** unless `build-transfer-beneficiary` / internal registry names a **different** contract **and** `getShares(poolId, user)` **returns a uint (no revert)** on that contract.
3. **`eth_call`** `allowedFeeManager(feeManager)` on **`BankrEscrowV3`** — must be **`true`** before promising escrow. If **`false`** only for a **verified** fee manager (step 2), escalate **owner** `setFeeManagerAllowed(feeManager, true)` — do **not** stop when the user pasted the wrong address.
4. Proceed: **`prepareDeposit` → beneficiary → escrow → `finalizeDeposit` → `list` at price**.

**Common mistake — redeem (FAILURE MODE — do not repeat):** User pastes **`0xCD66340D93E212bEC6Db1b22476e4f1276380C3e`** and says “return this to my wallet” / “return fees.”

**Wrong agent behavior (never do this):** Call `token-fees` or Clanker `tokenRewards` on `0xCD66…` → conclude “not a Bankr Doppler token” / “no Clanker v4” / “cannot transfer fee rights — unsupported on Base.” That is **incorrect**.

**Right agent behavior:**

1. Recognize `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e` = **TMPR collection** (canonical on Base).
2. Explain it is **not** a launch ERC-20 and **not** their wallet.
3. Ask for **OpenSea TMPR link** (extract `tokenId`) **or** launch **ticker** if they never minted.
4. If they hold TMPR → **`redeemRights(tokenId)`** on correct escrow (`positionOf`).
5. If they never minted → resolve **launched token** via ticker/API; fees may already be on wallet via `getShares` on fee manager — **no redeem**.

Full script: **`references/tmpr-collection-address-trap.md`**.

---

## Get fee rights back (redeem) — what users mean

**Yes:** If they bought or hold a **TMPR on OpenSea** and want to **be the fee / reward recipient again** (Doppler “fee recipient” = their wallet), that is **`redeemRights(tokenId)`** on the correct escrow — it **burns** the TMPR and points the underlying Bankr/Clanker fee stream back to **their wallet**.

**Not the same as:**

- Transferring the NFT to their wallet (they often **already** hold the NFT after an OpenSea buy).
- “Returning” the **collection address** `0xCD66…` (that is the whole TMPR contract, not one NFT).

**What you need:** the **`tokenId`** (uint256) for **their** TMPR — from OpenSea URL, `ownerOf` scan, or `positionOf`. Then **`redeemRights(tokenId)`** on **BankrEscrowV3** or **ClankerEscrowV4** from `positionOf(tokenId).launchFactory`.

**If listed:** cancel OpenSea / site listing first if the NFT is locked in a sale flow.

**Redeem tx rules (read `references/redeem-rights-playbook.md`):**

- **`msg.sender` = `ownerOf(tokenId)`** — wrong wallet → `UnauthorizedCaller`; **never** fix with `setApprovalForAll(escrow)`.
- **No NFT approval** needed for redeem; escrow burns as `authorizedEscrow`.
- **`BankrEscrowV3` is verified on BaseScan** — do not block redeem claiming “unverified escrow.”
- Pre-flight: `eth_call redeemRights` **from `ownerOf`** before submit.

### Phrases users say → TMP skills action

| User says (natural language) | Agent does |
|----------------------------|------------|
| “**Get fee rights back**” / “**return fee rights to my wallet**” | `redeemRights(tokenId)` |
| “I want to be the **reward person** again” / “**fee recipient** in my wallet” | Same — explain redeem restores **fee beneficiary**, not the ERC-20 token |
| “I bought this on **OpenSea**, how do I get the fees?” | Resolve **tokenId** from OS link → redeem if they hold TMPR |
| “`0xCD66…` return to my wallet” | **Clarify:** that’s the **collection**; ask for **ticker**, **OpenSea link**, or **tokenId** |
| “Burn the NFT and get my rights back” | `redeemRights` (burn is a side effect) |

### What users say (no TMP jargon needed)

```text
I bought the fee NFT for t7 on OpenSea — put the trading fees back in my wallet.
```

```text
Sell 5% of test1 for 0.005 eth. I want to keep the rest.
```

```text
List all my t7 fee rights for 0.01 eth on the marketplace and OpenSea.
```

**Agent:** execute silently; reply in plain English. Internal: redeem / partial sale / dual list per tables above. Run **Verification & Reporting** after txs — tell user “fees now go to your wallet” with Doppler/Bankr links, not `feeRecipient` hex unless they ask.

---

## On-chain flow (order matters — do not invert)

**Hard rule:** **`prepareDeposit` comes before moving the fee beneficiary to the escrow address.**  
`prepareDeposit` checks **`getShares(poolId, msg.sender) > 0`** on the **fee manager** while the **seller still holds** the on-chain position. If beneficiary is already pointed at escrow first, the seller may show **`getShares = 0`** and **`prepareDeposit` fails** — that is a **ordering bug**, not “register first.”

1. **`prepareDeposit(feeManager, poolId, token0, token1)`** on **Escrow** — pending seller = `msg.sender`; **`getShares(poolId, msg.sender) > 0`** on **`feeManager`**.
2. **Fee beneficiary → escrow** — `newBeneficiary` = escrow. Bankr APIs need a valid **`tokenAddress`** (the **launched token**, e.g. t4), or **`build-transfer-beneficiary`** returns `Valid tokenAddress required`. See [Transferring fees](https://docs.bankr.bot/token-launching/transferring-fees).
3. **`finalizeDeposit(poolId)`** — seller only; escrow must hold shares; mints **BFRR**.
4. **List / buy** — **`FeeRightsFixedSale`** (different contract from escrow): approve + **`list`**; **`buy(listingId)`** with exact **`msg.value`**.

Never tell the user **“success”** until the matching tx **mined** and reads match (e.g. `pendingSeller`, shares on escrow).

---

## Fee manager resolution (most common production bug)

- The **`feeManager`** argument to **`prepareDeposit`** must be the **same on-chain contract** where **`getShares(bytes32 poolId, address beneficiary)`** is defined for that pool — typically the same target **`build-transfer-beneficiary`** uses for that **launched token**.
- **`getShares` that reverts** on `eth_call` usually means **wrong `feeManager` address or invalid pool for that contract** — **not** the same as “shares are zero.” **`0`** returned (no revert) means no position for that wallet on **that** manager.
- **`GET /public/doppler/token-fees/:tokenAddress`** returns **`poolId`** and beneficiary **`address`** / **`share`** in some responses — it may **not** include the **initializer / fee manager**; resolve that from the **same internal registry** the product uses for beneficiary transfers, not guesses.

---

## Escrow allowlist (owner, once per manager contract)

- **`setFeeManagerAllowed(feeManager, bool)`** on escrow — **`onlyOwner`**. Not `allowFeeManager`.
- **Per fee manager contract address**, not per user wallet. New sellers reuse the same allowlisted manager.
- Deploy-time: set **`BANKR_FEE_MANAGERS`** / **`INITIAL_FEE_MANAGERS`** CSV so allowlist is included in the deploy broadcast.
- **Production Token Marketplace deploy** allowlists **`0xBDF938149ac6a781F94FAa0ed45E6A0e984c6544`** — standard Bankr Doppler launches (t7, t9, etc.) use this manager.

**Before telling the user “we can’t convert until allowlist”:**

1. Confirm you resolved the **correct** `feeManager` (see **Address disambiguation**) — not a random pasted address.
2. `eth_call` `allowedFeeManager(feeManager)` on `0x6238698212D91845cD1c004DE85951055bB5b292`.
3. If **`true`** → proceed with Create NFT; **do not** claim allowlist is blocking.
4. If **`false`** for a **verified** new manager only → operator (escrow **owner**) must broadcast:

```text
setFeeManagerAllowed(<feeManager>, true)
```

on **BankrEscrowV3** (`0x6238…b292`). One tx per new manager contract; all sellers on that manager benefit.

---

## Common agent mistakes (do not repeat)

| Wrong advice | Why it’s wrong |
|--------------|----------------|
| Approve **WETH** to **`0xFb28…`** for **`prepareDeposit`** | **`prepareDeposit`** is **`value: 0`**; it does not spend user WETH. |
| Call **`0xFb28…` the “marketplace”** | **Listings** are **`FeeRightsFixedSale`** (`0xe2A1…` production). **`0x6238…` / `0xFb28…`** is **escrow** (`BankrEscrowV3`). |
| User says **“list”** without naming a venue | **Dual list** via `POST /api/list/dual` + OpenSea skills |
| **`list(tokenId, price)`** two-arg call | Must be **`list(TMPR, tokenId, priceWei)`** — three args |
| “Move beneficiary to escrow **before** prepare so shares exist” | **Inverted order** — see section above. |
| “`getShares` reverted ⇒ user has no position” | **Revert ⇒ wrong target / ABI**, until proven otherwise. Off-chain **token-fees** may still show **share %** for the user. |
| **`balanceOf`** on fee manager for shares | Use **`getShares(poolId, address)`** per **`IBankrFees`**. |
| “User can **`approve`** marketplace as soon as BaseScan verifies” | **Bankr-custodial** wallets may still block until a **third-party scanner index** updates — sometimes **24h+**; offer **WalletConnect / MetaMask** or **`safeTransferFrom`** BFRR to user EOA. See **`INTEGRATION_NOTES.md`**. |
| User pasted `0x…` ⇒ use as **fee manager** | **Launched token** vs **fee manager** vs escrow — verify with **`token-fees`** + **`getShares`** on **`0xBDF938…6544`** |
| “Fee manager not allowlisted” without checking **`0xBDF938…`** | Blocks valid Bankr launches — check allowlist on the **real** manager first |

---

## Custodial scanner vs listing (Bankr marketplace)

- **`list`** on **`FeeRightsFixedSale`** requires prior **`approve`/`setApprovalForAll`** on **BFRR** for the marketplace address — **two** txs (or a deliberate multicall), not one magic **`list`**.  
- If **`approve`** is blocked with **`unverified_contract`** / **"dangerous"** / **"malicious"** despite BaseScan + Sourcify verification: root cause is a **third-party risk index cold-start** (e.g. GoPlus) — no reputation yet for a newly deployed contract. Bankr's custodial signer blocks the tx as a safety measure. **Not** a contract bug.
  - Workaround 1: **wait** and retry (index usually catches up in minutes–hours after verification push).
  - Workaround 2: **escalate** to Bankr with verified BaseScan URL for manual whitelist.
  - Workaround 3 (fastest): Bankr broadcasts **`safeTransferFrom(BFRR, custodialWallet → userEOA, tokenId)`** (NFT transfers typically not blocked), then user calls **`approve` + `list`** from their own wallet (MetaMask / Rabby / WalletConnect) with gas.

---

## `prepareDeposit` encoding (critical)

- **Function:** `prepareDeposit(address feeManager, bytes32 poolId, address token0, address token1)`
- **Selector:** `0x6ac71ccc` (**four** arguments only — not a five-argument overload.)
- **Chain:** Base mainnet (`8453`).

### Example (t4-style pool — **verify `feeManager` before use**)

Illustrative only — **`feeManager` must match on-chain reality** for that token (see **Fee manager resolution**). Example tuple: poolId `0xc4db87d196ba3cdc05950eeec2d35de8cf76fb81cde996a5613682e99808cc8f`, token0 WETH `0x4200000000000000000000000000000000000006`, token1 `0xfc8ff3050def72b18083b119ce0cecab86b43ba3`.

Structured prompt for Bankr (substitute **verified** `feeManager`):

```text
Send transaction to 0xFb28D9C636514f8a9D129873750F9b886707d95F on Base calling
prepareDeposit(
  <VERIFIED_FEE_MANAGER>,
  0xc4db87d196ba3cdc05950eeec2d35de8cf76fb81cde996a5613682e99808cc8f,
  0x4200000000000000000000000000000000000006,
  0xfc8ff3050def72b18083b119ce0cecab86b43ba3
)
```

---

## Other selectors (reference)

| Function | Selector |
|----------|----------|
| `finalizeDeposit(bytes32)` | `0x3585ca61` |
| `list(address,uint256,uint256)` | `0xdda342bb` |
| `buy(uint256)` | `0xd96a094a` |

---

## Common `prepareDeposit` reverts (Escrow V3)

| Situation | Likely revert | What to check |
|-----------|---------------|----------------|
| Fee manager not allowlisted | `FeeManagerNotAllowed` | `allowedFeeManager(feeManager)` on escrow |
| Caller has no shares for pool | `CallerDoesNotOwnRights` | `getShares(poolId, user)` on fee manager; **signing wallet** must match rights holder |
| Pool already escrowed | `RightsAlreadyEscrowed` | Do not prepare again for same pool |
| Pending prepare exists | `DepositAlreadyPending` | Same pool; finish or cancel per product flow |
| `token0 == token1` or zero addr | `DuplicateTokenAddress` / `ZeroAddress` | Token pair |
| Stale fee dust on pool | `UnwithdrawnFees` | Accounting on that pool |

---

## Beneficiary transfer (prefer API over chat JSON)

- Bankr wallet: `POST /user/doppler/execute-transfer-beneficiary` (see [Transferring fees](https://docs.bankr.bot/token-launching/transferring-fees)).
- External wallet: `POST /public/doppler/build-transfer-beneficiary` → user signs returned `to`/`data`.

`newBeneficiary` must be the **canonical escrow** address (see table above for this deploy).

---

## Where to list (dual — shop + OpenSea)

**Default:** every **list / sell for X ETH** → **`POST https://www.tokenmarketplace.shop/api/list/dual`** → site txs → **OpenSea skills**.

| Step | Agent action |
|------|----------------|
| After mint | **`tokenId`** from mint / `tokenIdFor(feeManager, poolId)` |
| Prepare | `POST /api/list/dual` with `tokenId`, `priceEth`, `seller` |
| Site | `prepare:transaction` for each `site.steps` entry (`approve`, then `list`) |
| OpenSea | **[opensea-marketplace](https://github.com/BankrBot/skills/tree/main/opensea)** on collection **`tokenmarketplace`** |
| Verify | `GET /api/list/status?tokenId=` — `listedOnSite` + `openSea.hasListing` |
| Fallback | OpenSea UI at `openSea.itemUrl` from API response |

### Automated OpenSea listing (install with TMP skills)

Bankr maintains a separate skill pack for Seaport writes. **TMP skills do not replace it** — they **hand off** after mint.

**Install (in addition to TMP skills):**

```text
install the skill at https://github.com/BankrBot/skills/tree/main/opensea
```

Then read **`opensea-marketplace/SKILL.md`** (create listing) and **`opensea-wallet/SKILL.md`** (Bankr signing). Requires:

- `OPENSEA_API_KEY` — [instant agent key](https://docs.opensea.io/reference/api-keys)
- Wallet provider — **`BANKR_API_KEY`** for agent wallet signing per [opensea-wallet](https://github.com/BankrBot/skills/tree/main/opensea/opensea-wallet)

**After TMP mint, agent should:**

1. Run **`POST /api/list/dual`** first — use returned calldata for site steps (do not guess selectors).
2. After site steps confirm, **`opensea-marketplace`** — create Seaport listing on **Base** for:
   - contract `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e`
   - `tokenId` from mint
   - price **0.0069 ETH** (or user amount)
3. Run **Verification & Reporting** (Doppler + Bankr launch for **launch token**, not TMPR collection).

**User message (mint done, list on OpenSea):**

```text
Using TMP skills: t7 TMPR minted — tokenId 102827652914408433121415002298223515805764633656416579128953185902816790019438. POST /api/list/dual for 0.0069 ETH, confirm site steps, then OpenSea skills for Seaport listing.
```

**If OpenSea signing is blocked:** site listing may still succeed via API steps; give manual OpenSea UI link from `openSea.itemUrl`.

### List on OpenSea (default — manual UI fallback)

1. Connect the wallet that holds the TMPR (**same address that finalized mint**, e.g. `0x374d…13b4`).
2. Open **[Token Marketplace on OpenSea](https://opensea.io/collection/tokenmarketplace)** → **Profile** → your TMPR(s), **or** search the collection for **t7** / your token.
3. Open the **t7** item → **List for sale** → **0.0069 ETH** (or user’s price) → confirm signature(s).
4. Optional direct item URL (replace `tokenId` from mint / `tokenIdFor` on escrow):

   `https://opensea.io/item/base/0xcd66340d93e212bec6db1b22476e4f1276380c3e/<tokenId>`

   For **t7** (pool `0x3937…5fe9`, fee manager `0xBDF938…`): deterministic id  
   `102827652914408433121415002298223515805764633656416579128953185902816790019438`  
   → [OpenSea item link](https://opensea.io/item/base/0xcd66340d93e212bec6db1b22476e4f1276380c3e/102827652914408433121415002298223515805764633656416579128953185902816790019438)

5. After the listing is live, confirm on OpenSea and give **Doppler** + **Bankr launch** links for launched token `0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3`.

**API reference:**

```http
POST https://www.tokenmarketplace.shop/api/list/dual
Content-Type: application/json

{ "tokenId": "<uint256>", "priceEth": "0.0069", "seller": "0x...", "chainId": 8453 }
```

```http
GET https://www.tokenmarketplace.shop/api/list/status?tokenId=<uint256>
```

---

## Site marketplace (`FeeRightsFixedSale`)

**Agents:** use **`POST /api/list/dual`** — returns `approve` + `list` calldata for `0xe2A13499292D43254026DAf0C4F75988242BaA66`. Execute via **`prepare:transaction`**, not raw `/wallet/submit`.

**On-chain:** `list(TMPR, tokenId, priceWei)` — NFT in marketplace custody until `buy` or `cancel`. Pair with OpenSea listing for dual visibility.

---

## Buy BFRR that is listed (buyer)

1. **Get `listingId`** — from marketplace UI, `Listed` events on `FeeRightsFixedSale`, or ask the seller. Optionally **verify on-chain** before paying:

   - Call **`getListing(listingId)`** on the marketplace — check **`active`**, read **`priceWei`**, **`collection`**, **`tokenId`**, **`seller`**.

2. **Pay exactly `priceWei` ETH** in the same transaction as `buy`:

```text
Send transaction to 0xA8163A62030a74F946eC73422EE692efE68AFE0B on Base
with value <priceWei> wei
calling buy(<listingId>)
```

**Critical:** `msg.value` must **equal** `listing.priceWei` exactly or the contract reverts **`WrongPayment`**. If the listing was cancelled or sold, **`ListingInactive`**.

3. After success, the buyer **holds the BFRR** in their wallet; **redemption / fee claims** still go through **`BankrEscrowV3`** per receipt rules (not covered in one tx here).

---

## Marketplace read helpers (agent / support)

| Call | Purpose |
|------|---------|
| `getListing(listingId)` | `collection`, `tokenId`, `seller`, `priceWei`, `active` |
| `nextListingId()` | Upper bound; scan `Listed` logs or app index for open listings |

---

## List / buy reverts (`FeeRightsFixedSale`)

| Revert | Meaning |
|--------|---------|
| `WrongPayment` | `buy`: `msg.value` ≠ listed `priceWei` |
| `ListingInactive` | `buy` / `cancel`: no active listing for that id |
| `AlreadyListed` | `list`: asset already has an active listing |
| `ZeroPrice` | `list`: `priceWei` must be > 0 |
| `NotSeller` | `cancel`: caller is not listing seller |

---

## Verification & Reporting

**Mandatory after every state-changing tx** — `prepareDeposit`, beneficiary transfer, `finalizeDeposit`, `list`, `buy`, `cancel`, `redeemRights`, `acceptOffer`, or equivalent OpenSea completion. Do this in the **same turn** as the success summary; do not wait for the user to ask “did it work?”

### Workflow

1. **Wait for a mined receipt** — never claim success on submit alone.
2. **Resolve the launched token contract** (`tokenAddress`) from:
   - the user’s stated ticker/address,
   - **`positionOf(tokenId)`** on TMPR (non-WETH leg of `token0` / `token1`), or
   - the tx / launch context you just used.
3. **Fetch fresh launch metadata** — call Bankr **`get_token_launch_info`** with that **`tokenAddress`**.  
   If the tool is unavailable, use **`GET https://api.bankr.bot/public/doppler/token-fees/{tokenAddress}`** and read beneficiary / share fields from the JSON.
4. **Confirm `feeRecipient` (or equivalent beneficiary field)** matches what the user should see **now**:

   | Action just completed | Expected fee recipient |
   |----------------------|-------------------------|
   | **`redeemRights`** (burned TMPR) | **User’s wallet** — direct Bankr/Clanker fee beneficiary again |
   | **`finalizeDeposit`** / fees moved to escrow | **Escrow contract** (`BankrEscrowV3` or Clanker escrow for that receipt) |
   | **`buy`** on site (buyer holds TMPR) | Still escrowed until buyer redeems — beneficiary remains **escrow** until buyer calls **`redeemRights`** |
   | Beneficiary transfer **to escrow** (pre-finalize) | **Escrow address** on fee manager / Doppler view |

   If the tool shows a different address, say so plainly and suggest waiting for indexer refresh or re-querying in ~1–2 minutes.

5. **Always include verification links** in the final reply (substitute the real `tokenAddress`):

   - **Doppler:** `https://app.doppler.lol/tokens/base/{tokenAddress}`
   - **Bankr launch:** `https://bankr.bot/launches/{tokenAddress}`

   Example (t7): `https://app.doppler.lol/tokens/base/0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3` and `https://bankr.bot/launches/0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3`

6. **“My Launches” / portfolio UI lag** — Bankr’s launches list often filters to tokens where the user is the **active beneficiary**. Right after **`redeemRights`**, the token may **briefly disappear** until the indexer catches up (beneficiary moved from escrow → wallet). Tell the user to use the **Doppler** and **Bankr launch** links above for live fee-recipient status; the change is already on-chain if step 4 matches.

### Example closing (after `redeemRights`)

```text
✅ redeemRights mined — TMPR burned; fee stream beneficiary is your wallet again.

Verification (t7):
• Doppler: https://app.doppler.lol/tokens/base/0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3
• Bankr launch: https://bankr.bot/launches/0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3

get_token_launch_info shows feeRecipient: 0x374d91a5674fa7cf86e725093b5848b97e1e13b4 (your wallet).

If My Launches hasn’t updated yet, that’s normal indexer delay — use the links above.
```

---

## All marketplace options (agent orchestration)

**Read first:** **`references/all-escrow-options.md`** (decision table + full steps).

### Quick routing (user language)

| User says | Flow | Main contract |
|-----------|------|----------------|
| “Sell all rights for 0.5 ETH” | Sell 100% | `FeeRightsFixedSale` + `/api/list/dual` |
| “Sell 5% for 0.05 ETH” / “keep 95% sell 5%” | Partial sale | `GroupBuyEscrowV2` · `sellerKeepsBps=9500` |
| “Keep 80%, sell 20%” / “partial sale” | Partial sale | `createPartialListing` on **V2** |
| “Pool ETH to buy my fees” | Group buy | `GroupBuyEscrowV2.createListing` |
| “I’ll put in 0.1 ETH, raise 0.1 from backers” | Crowdsource | `createCrowdsource` (payable seed) |
| “Give employee 10% for 60 days” / “assign 0x… 20%” | Timed fee share | `FeeRightsTimedGrantEscrow` |
| “Loan rights for 2 weeks for 0.1 ETH” | Paid time loan | `FeeRightsLoanEscrow` |
| “@bankr sell 5%…” (social) | Partial sale (guide + link) | No auto-tx without wallet |
| “Create NFT” / “convert fees to NFT” | Mint TMPR | Bankr / Clanker / Zora escrow |

**Do not confuse:** **Timed fee share** (timed %, **no ETH**) vs **partial sale** (forever %, buyers pay ETH) vs **paid time loan** (**100%**, borrower pays) vs **crowdsource** (co-own by pooled ETH).

### GroupBuyEscrowV2 (partial / group / crowdsource)

**Address:** `0x869D11606B94de1206669C55f8628749bCBBFfD4` · [BaseScan](https://basescan.org/address/0x869d11606b94de1206669c55f8628749bcbbffd4)

**`venueType` (uint8):** `0` = none, `1` = Bankr, `2` = ClankerV4, `3` = ClankerV3, `4` = Zora.

**`rightsEscrow`:** `0x6238698212D91845cD1c004DE85951055bB5b292` (Bankr) · `0x3546A98C09fc5a3E162d510DB331C4dcEdB6EADa` (Clanker v4) · `0x7A7540B048a8CC96837E83604B32559CCe911D9F` (Zora).

**Seller (after holding TMPR):**

1. `approve(GroupBuyEscrowV2, tokenId)` on TMPR (or `setApprovalForAll`).
2. Create listing:
   - **Partial:** `createPartialListing(collection, tokenId, priceWei, durationSeconds, minContributionWei, sellerKeepsBps, venueType, rightsEscrow)` — e.g. sell **5%** ⇒ `sellerKeepsBps = **9500**` (keep 95%). `priceWei` = ETH buyers pay for the **sold 5% only**.
   - **Group:** `createListing(..., venueType, rightsEscrow)` — `sellerKeepsBps` implicit 0.
   - **Crowdsource:** `createCrowdsource(..., venueType, rightsEscrow)` with `msg.value` = creator seed; `targetRaise` = ETH from outsiders only.
3. Buyers `contribute(listingId)` with ETH until `totalRaised >= priceWei` (crowdsource: outsiders only; seed does not count toward target).
4. Anyone `finalize(listingId)` → 0xSplits; fees route per `venueType`.
5. **Claim:** Bankr/Clanker claim → site **Distribute** on listing (group buy tab).

**Do not use `POST /api/list/dual` for partial sale** — that is sell **100%** only.

**Clanker/Zora finalize on mainnet:** requires **redeployed** escrows with `routeFeesTo` / `routePayoutTo` (see **`references/bankr-agent-test-prompts.md`** § known stuck points).

### Timed fee share (grant % to named wallet)

**Address (Bankr grants, deployed):** `0xb56973cD7Bcb1AD127dFfE112daAE3960a65CC41`

**Site:** **My profile** → TMPR → **Timed fee share** · playbook: site **Use cases** tab.

1. `redeemRights(tokenId)` if TMPR held.
2. Beneficiary → grant escrow (`POST /api/bankr-build-transfer` on Bankr).
3. `createGrantBankr` / `createGrantClanker` / `createGrantZora` (latter two need **new** grant deploy).
4. **Lender** runs `distributeFees(grantId)` on a schedule — **grantee does not** “claim in Bankr” for Bankr grants; they receive ERC-20 on distribute.
5. Run **last distribute before `endTime`** or grantee may miss un-split fees.

### Paid time loan (100% for period)

**Address:** `0x9F167C8dce30ca1e6F46bC2491d6434e30568790`

1. Redeem TMPR → point fee stream at loan escrow (`updateBeneficiary` or Clanker locker admin/recipient).
2. `createLoanBankr` or `createLoanClanker` with `borrower`, `priceWei`, `endTime`.
3. Borrower `acceptLoan(loanId)` payable.
4. After `endTime`: `reclaimLoan(loanId)` (permissionless).

### Example prompts → agent jobs

```text
Give my employee 0xABC… 15% of t7 fees for 90 days
→ Timed fee share: redeem → beneficiary to grant escrow → createGrantBankr(1500 bps) → explain distributeFees schedule
```

```text
Sell 5% of t7 fees for 0.05 ETH over 7 days
→ Partial sale: GroupBuyEscrowV2, sellerKeepsBps=9500, priceWei=0.05e18 (sold slice), venueType=1, rightsEscrow=0x6238…
→ NOT /api/list/dual
```

```text
Keep 75% of fees, sell 25% for 0.2 ETH over 7 days
→ Partial sale: sellerKeepsBps=7500, priceWei for 25% slice only
```

```text
I'll seed 0.1 ETH and raise 0.1 ETH from backers
→ Crowdsource: createCrowdsource{value:0.1e18}(targetRaise=0.1e18, …)
```

```text
Let wallets pool 1 ETH to buy my fee rights
→ Group buy: createListing(priceWei=1e18, sellerKeepsBps=0, …) → contribute → finalize
```

```text
@bankr sell 5% of $t7 for 0.05 eth
→ Partial sale intent; ask wallet + confirm TMPR; link tokenmarketplace.shop Group buy / profile; cannot execute without user signing
```

---

## Zora coins (`ZoraEscrowV1`)

Zora creator payout rights use the **same TMPR** collection as Bankr/Clanker. Deploy with `script/DeployZoraEscrowV1.s.sol` (**compile with `--via-ir`**). Set `VITE_ZORA_ESCROW_ADDRESS` after deploy.

**Flow:** `prepareDeposit(coin, coin, WETH)` → `coin.addOwner(escrow)` → `coin.setPayoutRecipient(escrow)` → `finalizeDeposit(coin)` → dual list via **`POST /api/list/dual`** + OpenSea skills.

**Discover coin:** `GET https://www.tokenmarketplace.shop/api/zora-coin?address=<coin>`.

Row metadata: `__launchVenue: "Zora"` or `zoraCoin: 0x…`.

---

## Bankr Apps (in-terminal)

Install from repo:

- **All venues:** `apps/token-marketplace/` — [Apps overview](https://docs.bankr.bot/apps/overview)
- **Bankr only:** `apps/bankr-fee-rights/`

```text
build me the Token Marketplace app from https://github.com/anondevv69/bankrtokennft/tree/main/apps/token-marketplace
```

Scripts call `POST /api/list/dual` and `GET /api/list/status`; UI uses `bankr.confirmTransaction` for site steps and `bankr.askChat` for OpenSea handoff.

---

## Agent rules of thumb

1. **Route intent first** — use **`references/all-escrow-options.md`** (employee grant vs partial sale vs loan vs sell 100%).
2. **Resolve** `feeManager`, `poolId`, `token0`, `token1` from the **same pipeline** as production beneficiary tooling — **never hardcode** a fee manager unless **`getShares`** returns cleanly for that wallet + pool.
3. **Never** instruct users to rely on **pasting** transaction JSON as the only broadcast path; align with **mini-app `confirmTransaction`** and show **tx hash** + BaseScan after submit.
4. **Gate** steps on **receipts** + contract reads (`pendingSeller`, shares on escrow for finalize).
5. **DMs:** ask for the **structured block** in **`references/dm-intents.md`** so one thread can drive **sell**, **split**, **grant**, or **buy** without guessing.
6. **Partial / group / crowdsource:** use **GroupBuyEscrowV2** + `venueType` / `rightsEscrow` — never v1-only `bankrEscrow` arg on V2. **Sell X% for price** ⇒ partial sale, **not** dual list.
7. **Clanker/Zora** group flows: need redeployed venue escrows; if not deployed, say so and offer Bankr TMPR or sell 100%.
8. **Testing Bankr:** run prompts in **`references/bankr-agent-test-prompts.md`** and log where the agent stops.
9. **After every state-changing tx:** run **Verification & Reporting** — `get_token_launch_info` + Doppler + Bankr launch links + explicit `feeRecipient` check.
10. **User-facing tx narration:** explain each wallet signature and each material custody change in plain English; skip raw calldata, read calls, and low-level contract jargon unless the user explicitly asks.

---

## Links

- **Repo:** [github.com/anondevv69/bankrtokennft](https://github.com/anondevv69/bankrtokennft)
- **Escrow (BaseScan):** [0xFb28…d95F](https://basescan.org/address/0xfb28d9c636514f8a9d129873750f9b886707d95f)
- **BFRR (BaseScan):** [0xB9E5…00db](https://basescan.org/address/0xb9e56da4b83e77657296d7de694754bd8b7d00db)
- **Marketplace (BaseScan):** [0xA816…FE0B](https://basescan.org/address/0xa8163a62030a74f946ec73422ee692efe68afe0b)
- **Install skills in Bankr:** [Install a Skill from GitHub](https://docs.bankr.bot/skills/in-bankr/from-github/)

Install line (folder URL; call it **TMP skills** in chat):

```text
install TMP skills at https://github.com/anondevv69/bankr-tmp-skill
```

---

## Install note

Bankr expects a **public** GitHub folder URL whose root contains **`SKILL.md`** ([docs](https://docs.bankr.bot/skills/in-bankr/from-github/)). This repository **is** that folder — install the repo URL directly (not a subpath).
