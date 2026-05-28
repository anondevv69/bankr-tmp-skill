# Bankr agent test prompts — TMP skills QA

Use this file when testing **Bankr** (chat / X / DMs) with **TMP skills** installed. For each prompt, note **where the agent gets stuck** and fix skills or product.

**Install:**

```text
install TMP skills at https://github.com/anondevv69/bankr-tmp-skill
```

**Site:** https://www.tokenmarketplace.shop · **Use cases tab** on site has examples + grant claiming playbook.

---

## Canonical addresses (May 2026 — Base)

| Contract | Address | Notes |
|----------|---------|--------|
| TMPR | `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e` | |
| BankrEscrowV3 | `0x6238698212D91845cD1c004DE85951055bB5b292` | |
| **GroupBuyEscrowV2** | `0x869D11606B94de1206669C55f8628749bCBBFfD4` | **Use for partial / group / crowdsource** |
| GroupBuyEscrow v1 | `0x6F00715124d79114E03A94676bEa3BE697F77def` | Bankr-only finalize; legacy |
| FeeRightsFixedSale | `0xe2A13499292D43254026DAf0C4F75988242BaA66` | Sell 100% |
| FeeRightsTimedGrantEscrow (Bankr grants) | `0xb56973cD7Bcb1AD127dFfE112daAE3960a65CC41` | Old deploy = Bankr-only ABI |
| FeeRightsLoanEscrow | `0x9F167C8dce30ca1e6F46bC2491d6434e30568790` | |
| ClankerEscrowV4 | `0x3546A98C09fc5a3E162d510DB331C4dcEdB6EADa` | Redeploy needed for `routeFeesTo` on mainnet |
| ZoraEscrowV1 | `0x7A7540B048a8CC96837E83604B32559CCe911D9F` | Verified on BaseScan; TMPR authorized (Safe tx `0x058a6947…`) |
| Bankr fee manager | `0xBDF938149ac6a781F94FAa0ed45E6A0e984c6544` | |
| **FeeRightsBundleEscrow** | `0x429Af4F73d9a254607890930848Be2E9f50dBb3F` | Bundle & Rebirth (2026-05-18) |
| **Hybrid TMPR** (1/1000 units) | `0xD8e0639DfAa1cB2b9f9642EeCbd40b1e5a8b42A7` | ERC-1155 + receipt |
| **HybridShareMarketplace** | `0x90230B59D01c6e0306236eF7afc8105908c4DB0B` | Buy listed units |
| **GroupBuyEscrowV6** | `0x56bd948671955D0Ed82a88f136779cB76f551e0C` | Split → 1000 shares |

**Env on site (Vercel):** `VITE_GROUP_BUY_ESCROW_V2_ADDRESS=0x869D11606B94de1206669C55f8628749bCBBFfD4`  
**Hybrid env:** `VITE_TMPR_HYBRID_ADDRESS`, `VITE_HYBRID_SHARE_MARKETPLACE_ADDRESS`, `VITE_GROUP_BUY_ESCROW_V6_ADDRESS`  
**Env for bundle APIs (Vercel server):** `BUNDLE_ESCROW_ADDRESS=0x429Af4F73d9a254607890930848Be2E9f50dBb3F`

---

## CRITICAL failure — do not repeat (real Bankr test)

**User said:** `return 0xcd66340d93e212bec6db1b22476e4f1276380c3e to my wallet fees`

| Wrong (what Bankr did) | Right |
|------------------------|--------|
| Treated `0xCD66…` as launch ERC-20 | Recognize **TMPR collection** address |
| `token-fees` / Clanker lookup → “unsupported token” | **Never** call token-fees on `0xCD6634…` |
| “Cannot transfer fee rights” | Ask **tokenId** (OpenSea) or **ticker**; then **redeem** or explain direct shares |

**Read:** `tmpr-collection-address-trap.md`

### Redeem failure — do not repeat (real Bankr test #2)

**User:** `Burn the NFT 0xcd6634… and get my rights back`  
**Bankr:** `redeemRights` reverted; tried `setApprovalForAll`; “escrow unverified”

| Wrong | Right |
|-------|--------|
| `setApprovalForAll(escrow)` for redeem | **Not needed** — holder calls `redeemRights` only |
| “Escrow unverified” | `0x6238…` **is verified** on BaseScan |
| Tx from wallet that is not `ownerOf` | Submit from **`ownerOf(tokenId)`** (e.g. Bankr custodial wallet holding TMPR) |

**tokenId #20 example:** `48377155880238308705550034476083964778932907704334934787124089488714520594345` — `eth_call` redeem from owner succeeds on Base.

**Read:** `redeem-rights-playbook.md`

### Partial sale — token-fees missing (real Bankr test #3)

**User:** sell 5% of test1 `0x794220dDcd649aeE829c74f00b39FE554D1A6b75` for 0.005 ETH  
**Bankr:** correct partial + TMPR; then stuck — no launch record; asks TMPR / Clanker / Uniswap pool

| Better | Worse |
|--------|--------|
| Scan TMPR `positionOf` for `token1 == 0x7942…` | Ask Uniswap pool when user gave launch ERC-20 |
| `creator-fees(wallet)` when token-fees 404 | “You hold token balance” ⇒ fee rights |
| `sellerKeepsBps=9500`, `priceWei=5000000000000000` | `/api/list/dual` |

**Read:** `partial-sale-resolve-token.md`

---

## Expected routing (agent must pick ONE flow)

| # | User prompt (example) | Correct flow | Common wrong picks |
|---|----------------------|--------------|-------------------|
| 1 | “Sell 5% of **$TICKER** fee rights for **0.05 ETH**” | **Partial sale** — `sellerKeepsBps=9500`, `priceWei`=0.05 ETH for **sold 5% slice** | Sell 100%; crowdsource; grant |
| 2 | “Keep 95% sell 5% for 0.05 eth” | **Partial sale** — `sellerKeepsBps=9500` | Same as #1 |
| 3 | “Hey Bankr sell 5% of this token for 0.05 ETH” | **Partial sale** — ask **which token/TMPR** if missing | Dual list sell 100% |
| 3b | “Sell 5% of **test1** `0x794220…` for **0.005 ETH**” | Partial — `sellerKeepsBps=9500`, `priceWei=5e15`; resolve via TMPR scan + **creator-fees** | “You hold token balance” = fee rights; ask Uniswap pool first |
| 4 | “I'll seed 0.1 ETH, raise 0.1 from 10 people” | **Crowdsource** — seed + `targetRaise` | Partial sale |
| 5 | “Give employee **0x…** 10% for 30 days” | **Timed fee share** — no ETH from grantee | Partial sale; loan |
| 6 | “Loan my fees for 2 weeks for 0.1 ETH” | **Paid time loan** — 100%, `acceptLoan` | Grant; partial |
| 7 | “Sell all my **t7** fees for 0.5 ETH” | **Sell 100%** — `POST /api/list/dual` | Partial sale |
| 8 | “Create NFT for t7 and list 0.0069 eth” | Mint → **dual list** | Partial sale |
| 9 | “10 wallets pool 0.5 ETH to buy my fees” | **Group buy** — `createListing`, no seed | Crowdsource if no seed |
| 10 | “return 0xcd6634… to my wallet fees” | **TMPR collection** → ask tokenId / ticker; **redeem** | token-fees on 0xCD66… |
| 11 | “Burn these 3 NFTs and merge into **$TEST** — use fees for initial buy” | **Bundle & Rebirth** — full chain; `feesTo` = user wallet | “We hold your tokens”; platform pays buy; stop after bundle only |
| 12 | “**Buy the cheapest** 1/1000 share of **$t7**” / “buy **1** share at best price” | **Share market** — sort offers → `HybridShareMarketplace.buy` | Fixed sale `buy`; partial `contribute`; ask user for listingId hex |

**Read:** `share-market-buy.md`

---

## Bundle & Rebirth — agent checklist

**User:** “Hey Bankr, burn these 3 token NFTs and merge into $TEST — use the fees from those for the initial buy.”

Agent should:

1. Route to **Bundle & Rebirth** — read **`bundle-rebirth-playbook.md`** then **`bundle-rebirth.md`**.
2. Resolve 3 TMPRs (mint first if needed).
3. `POST /api/bundle/prepare` → user signs approve + createBundle.
4. `POST /api/bundle/claim` (and repeat if accumulating).
5. `POST /api/bundle/disband` with **`feesTo` = user's wallet** (not platform treasury).
6. `POST https://api.bankr.bot/token-launches/deploy` with user's Bankr API key.
7. Swap user's WETH → new token (initial buy).
8. Reply in plain English — **never** “we hold your tokens” or “platform wallet bought in.”

**Wrong:** “Token Marketplace merged your 3 coins.” **Right:** “Combined fee rights, sent WETH to your wallet, turned off old fee streams, launched $TEST, first buy from your fees.”

---

## Share market buy — agent checklist

**User:** “Buy the cheapest 1/1000 share of $t7” / “buy 1 share at the best price”

Agent should:

1. Route to **share market buy** — read **`share-market-buy.md`**.
2. Resolve **$t7** → hybrid TMPR **tokenId** (collection `0xD8e0639…`).
3. Scan **`HybridShareMarketplace`** `0x90230B…` — sort by **lowest price per unit**; read **`accessKeyHash`** per offer.
4. Default: **cheapest offer**, **quantity 1** — “version 2” = second-cheapest offer.
5. **Public** offer: `buy(listingId, quantity)` with **`msg.value = quantity × pricePerUnitWei`** on Base.
6. **Password** offer: `POST https://www.tokenmarketplace.shop/api/listings/access-authorize` → `buy(listingId, quantity, authDeadline, signature)` — see **`share-market-buy.md` § Password-protected listings**.
7. Reply in plain English + link `https://www.tokenmarketplace.shop/listing/shares/t/{tokenId}`.

**Wrong:** `FeeRightsFixedSale.buy` (whole NFT). **Wrong:** partial sale `contribute`. **Wrong:** 2-arg `buy` on protected listing. **Wrong:** ask user to paste marketplace contract address.

**Password QA:**

```text
Buy 1 share of $CTO with password mysecret
```

**Pass:** `access-authorize` + 4-arg `buy`. **Fail:** public `buy` only · password only in tweet with no wallet.

---

## Password-gated buy — dedicated QA matrix

Run these prompts specifically to verify the agent handles password-protected share listings end-to-end without falling back to "manual only" unless truly required.

| # | Prompt | Expected agent behavior | Fail pattern |
|---|--------|-------------------------|--------------|
| P1 | "Buy cheapest 1/1000 share of $CTO with password CTO" | Resolve token → find protected offer → call `access-authorize` → submit 4-arg `buy` | Uses 2-arg `buy` and reverts `AuthorizationRequired` |
| P2 | "Buy 1 share of $CTO, password is ` CTO `" | Trim password once, preserve case, retry with normalized input | Sends raw spaced password and reports generic revert |
| P3 | "Buy second cheapest password listing of $CTO with password CTO" | Sort by price, pick rank #2 protected listing, enforce quantity caps | Ignores rank and buys cheapest |
| P4 | "Buy 3 shares of $CTO with password CTO" | Clamp by `quantity` + `maxPerWallet`, explain if reduced | Sends invalid quantity and fails on-chain |
| P5 | "Buy cheapest protected share of $CTO" (no password) | Ask exactly one direct question for password | Says "cannot do on-chain, use website" immediately |
| P6 | "Buy 1 share with password wrongpass" | Re-fetch listing state, report explicit password mismatch, request correct password | Generic "simulation failed" with no diagnosis |
| P7 | "Buy 1 share with password CTO" after waiting >10m | Detect/handle expired auth ticket, re-run `access-authorize`, then buy | Reuses stale signature and fails `AuthorizationExpired` |

**Pass criteria:** Agent succeeds with `access-authorize` + 4-arg `buy`, keeps password out of public narration, and surfaces explicit causes (`InvalidAccessKey`, expiry, listing changed).

**Fail criteria:** Agent routes to fixed sale / partial contribute, asks user for contract internals, or defaults to manual site flow when automated path is available.

---

## Runtime contract acceptance suite (must pass before rollout)

Use these prompts to verify strict autopilot behavior from `runtime-contract.md`.

| # | Prompt | Expected outcome | Hard fail |
|---|--------|------------------|-----------|
| R1 | "Sell my t7 rights for 0.01 ETH" | Agent completes mint (if needed) + list flow end-to-end, then returns tokenmarketplace listing URL | Stops at "prepared" or asks user to finish manually without blocker |
| R2 | "Create NFT for t7 and list for 0.01" | One conversation, all dependent txs mined, listing status verified | Reports success before mined receipts |
| R3 | "Buy cheapest CTO share, password CTO" | `access-authorize` + 4-arg buy + receipt + balance check | Uses 2-arg buy or reports simulation as final |
| R4 | "Did it work? <successful tx hash>" | Agent reads receipt, confirms ownership/listing state, answers definitively | Says "I didn't submit tx" when hash proves success |
| R5 | "Retry buy after successful fill" | Agent explains listing now inactive because prior success filled it | Generic unknown revert with no state check |

**Minimum telemetry per state-changing run (internal):**
- intent, selected listing/tokenId, auth path used, tx hash(es), receipt status, post-state check result.

---

## Canonical X-thread regression test (CTO listing 9)

Replay this sequence exactly:
1. User: buy cheapest from `https://tokenmarketplace.shop/listing/shares/t/82162810189150381448686192642592435479296266651479359308798582033011722422011`, password `CTO`.
2. Agent must execute gated buy flow (not manual handoff).
3. User posts success tx: [0x65d05ab...](https://basescan.org/tx/0x65d05ab67e1f7d07ed5e793c8aa33248fab8cb563d64400a0df2eddff4d92d7c).
4. Agent answer to "did it work?" must be **yes**, with concise proof (receipt success + ERC-1155 transfer/balance).

Any response similar to:
- "simulation reverted, do it manually"
- "I didn't actually submit a transaction"

is an automatic fail for runtime compliance.

---

## Partial sale — agent checklist

**User:** “Sell 5% of t7 fees for 0.05 ETH over 7 days.”

Agent should:

1. Resolve **t7** → launch token + pool (`token-fees` / `get_token_launch_info`).
2. Confirm user has **TMPR** (`tokenId`) or guide **Create NFT** first.
3. **Not** use `POST /api/list/dual` (that is sell **100%**).
4. Use **GroupBuyEscrowV2** `0x869D…fD4` (not v1 `0x6F007…` unless V2 unset on site).
5. `createPartialListing` args:
   - `collection` = TMPR `0xCD6634…`
   - `sellerKeepsBps` = **9500** (keep 95%, sell 5%)
   - `priceWei` = wei for **sold slice only** (0.05 ETH)
   - `venueType` = **1** (Bankr)
   - `rightsEscrow` = **0x6238698212D91845cD1c004DE85951055bB5b292**
6. Before list: `approve(GroupBuyEscrowV2, tokenId)` on TMPR.
7. Tell user: buyers **contribute ETH** on site **Group buy** tab → anyone **finalize** → claim via split.
8. Deep link: https://www.tokenmarketplace.shop → **Group buy** or **My profile** → TMPR → **Partial sale**.

**sellerKeepsBps formula:** `keepPercent * 100` → e.g. keep 95% ⇒ **9500**; sell 5% ⇒ keep **9500**, not 500.

---

## Crowdsource — agent checklist

**User:** “I commit 0.1 ETH, want another 0.1 ETH from backers (maybe 10×0.01).”

1. **Crowdsource** — not partial (no fixed keep/sold split forever).
2. `createCrowdsource` with `msg.value` = **0.1 ETH** seed, `targetRaise` = **0.1 ETH**.
3. Fee % after finalize: creator = `seed / (seed + raised)`; each backer = `theirContrib / (seed + raised)`.
4. Example: 0.1 + 0.1, ten equal backers → creator **50%**, each backer **5%** of fees (not 10% each of total unless they mean 10% of backer half).

---

## Timed fee share — agent checklist

**User:** “Give 0xEmployee 10% of fees for 30 days.”

1. **Timed fee share** — **not** partial sale (no ETH from employee).
2. Redeem TMPR if needed → beneficiary to grant escrow → `createGrantBankr`.
3. Warn: **lender must run `distributeFees` regularly**; grantee does **not** claim in Bankr during Bankr grants.
4. Site: **My profile** → **Timed fee share**.
5. If agent only knows old grant address `0xb569…` — Bankr-only; Clanker/Zora grants need **new** grant escrow deploy.

---

## Paid time loan — agent checklist

**User:** “Someone pays 0.2 ETH for 100% of fees for 14 days.”

1. **FeeRightsLoanEscrow** — borrower claims fees **directly** in Bankr/Clanker.
2. **Not** `distributeFees` (that is grants).
3. Site: profile → **Paid time loan** → listing guide.

**User (during active loan):** “Sell my Surplus fees for 0.1 ETH” — same token on loan.

1. **STOP** — read **`loan-no-forward-sale.md`**.
2. **Do not** dual list, partial sale, grant, or bundle that pool.
3. Reply: fees are rented until loan ends; they return to the original owner; listing blocked until reclaim.

---


## Tweet / social prompts (expect guidance, not auto-tx)

**User tweets:** “@bankr sell 5% of $t7 fees for 0.05 eth”

Agent should:

- Reply with **intent** (partial sale), **missing facts** (wallet, TMPR exists?, duration), link to **tokenmarketplace.shop** (Group buy / profile).
- **Not** claim listing is live without wallet signatures.
- **Not** confuse with sell-100% dual list.

**Note:** Repo `twitter-bot` only **posts alerts**; it does **not** read mentions. Tweet handling requires **Bankr product** + skills.

---

## Known stuck points (infra — not skill-only)

| Issue | Symptom | Fix |
|-------|---------|-----|
| Agent uses GroupBuy **v1** | Wrong contract / Bankr-only | Skills say **V2** `0x869D…`; set Vercel env |
| Agent uses `bankrEscrow` arg only on V2 | Revert / wrong ABI | V2 needs `venueType` + `rightsEscrow` |
| Clanker partial finalize | Revert on finalize | Redeploy **ClankerEscrowV4** with `routeFeesTo` |
| Zora partial finalize | Revert | Redeploy **ZoraEscrowV1** with `routePayoutTo` |
| Clanker/Zora timed grant | `createGrantClanker` missing | Deploy **new** FeeRightsTimedGrantEscrow |
| “Sell 5%” → `sellerKeepsBps=500` | Wrong economics | Must be **9500** to *keep* 95% |
| `priceWei` = full token price | Overpriced raise | `priceWei` = ETH for **sold % only** |
| Grantee “claim in Bankr” | User confusion | Explain **distributeFees** by lender |

---

## Test log template (paste results)

```text
Prompt: ...
Agent chose flow: ...
Stuck at step: ...
Wrong contract/address: ...
Asked user unnecessary question: ...
Should have linked: tokenmarketplace.shop / Use cases / Group buy
Notes:
```

---

## After testing — where to fix

| Stuck area | Update |
|------------|--------|
| Wrong flow choice | `user-language.md`, `SKILL.md` § routing |
| Wrong addresses | `SKILL.md` § deployments, `all-escrow-options.md` |
| Missing tweet/social | `SKILL.md` § social, this file |
| Wrong bps math | `dm-intents.md` § partial sale |
| Product gaps | Bankr app / site — skills only document intended behavior |
