# All Token Marketplace options — agent reference

**Site:** https://www.tokenmarketplace.shop · **Chain:** Base `8453` · **TMPR:** `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e`

Use this file to pick the **right flow** before building txs. Read **`user-language.md`** for phrase mapping.

---

## Time-limited rights: two different products (do not mix up)

These sound similar but use **different contracts** and rules.

| | **Paid time loan** (“bag worker”) | **Timed fee share** (“employee / promoter grant”) |
|---|-----------------------------------|---------------------------------------------------|
| **What you want** | “Loan my fee rights for **N days** for **this ETH price**.” | “Give **this wallet** **X%** (or almost all) of fees for **N days**, then it **comes back to me**.” |
| **Contract** | `FeeRightsLoanEscrow` | `FeeRightsTimedGrantEscrow` |
| **Who gets fees during the period** | **Borrower = 100%** of the live fee stream | **Grantee = X%** of each distribution; **you keep the rest** (1–99% on grant) |
| **Does the other party pay ETH?** | **Yes** — borrower calls `acceptLoan` with `priceWei` | **No** — grantee does not buy in |
| **Named wallet?** | Optional (`borrower` on loan; `address(0)` = anyone can accept) | **Yes** — `grantee` address required |
| **How it ends** | After `endTime`, `reclaimLoan` → **100% back to you** | After `endTime`, `distributeFees` / `cancelGrant` → **beneficiary restored to you** |
| **Site UI** | Profile → **Bag worker (loan)** → listing guide | Profile → TMPR → **Timed fee share** |
| **Wrong tool** | Not for “free 10% to my dev for 30 days” | Not for “promoter pays 0.5 ETH for all fees for 2 weeks” |

**If they want ~100% to someone for N days with no payment:** use **timed grant** at max **99%**, or a **loan** with `priceWei = 0` (borrower still must `acceptLoan`). **If they want 100% only when someone pays:** use **loan** with a real price.

---

## Which option should I use? (decision table)

| User goal | Best option | Needs TMPR first? | ETH from counterparty? | Platform today |
|-----------|-------------|-------------------|------------------------|----------------|
| Sell **100%** forever for fixed ETH | **Sell 100%** (`FeeRightsFixedSale` + dual API) | Yes (or mint + sell) | Buyer pays | Bankr, Clanker, Zora TMPR |
| Sell **part of %** forever (e.g. keep 70%, sell 30%) | **Partial sale** (`GroupBuyEscrowV2.createPartialListing`) | Yes | Buyers fund sold slice | **Bankr, Clanker, Zora** TMPR (`venueType` + `rightsEscrow`) |
| **Many wallets** pool ETH to buy rights | **Group buy** (`GroupBuyEscrowV2.createListing`) | Yes | Contributors | **Bankr, Clanker, Zora** TMPR |
| You stay in; **backers** fill raise | **Crowdsource** (`GroupBuyEscrowV2.createCrowdsource`) | Yes | Backers (+ your seed) | **Bankr, Clanker, Zora** TMPR |
| Give **wallet X% of fees for N days**, then rights return (no sale) | **Timed fee share** (`FeeRightsTimedGrantEscrow`) | Redeem TMPR first | **No** | **Bankr, Clanker v4, Zora** (redeploy grant escrow for new ABIs) |
| **Loan** fee rights for **N days for a price** (borrower gets **100%**) | **Paid time loan** / bag worker (`FeeRightsLoanEscrow`) | Redeem TMPR first | Borrower pays `priceWei` | Bankr + Clanker V4 (contract); Zora uses `ZoraFeeRightsEscrow` loan |
| Wrap fees in tradeable NFT | **Create NFT** (mint TMPR) | — | — | Bankr, Clanker, Zora |
| Get fees in wallet again | **Redeem** (`redeemRights`) | Holds TMPR | — | All TMPR types |
| Combine N fee rights → launch new Bankr token + initial buy | **Bundle & Rebirth** (`FeeRightsBundleEscrow` + `/api/bundle/*` + Bankr deploy) | Yes (TMPR per token) | User funds deploy/buy from disband WETH | Bankr/Doppler only (this contract version) |

**There is no “type wallet address for 10% forever without ETH” on group buy** — use **partial sale** (they contribute ETH) or **timed fee share** (timed %, no ETH from grantee).

---

## Mainnet contracts (May 2026 — verify on BaseScan)

| Contract | Address |
|----------|---------|
| TMPR receipt | `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e` |
| BankrEscrowV3 | `0x6238698212D91845cD1c004DE85951055bB5b292` |
| ClankerEscrowV4 | `0x3546A98C09fc5a3E162d510DB331C4dcEdB6EADa` |
| ClankerEscrowV1 (v3.x) | `0x5Cf158b5915E5b0764Ca87760b0e46beF7A527E3` |
| FeeRightsFixedSale | `0xe2A13499292D43254026DAf0C4F75988242BaA66` |
| GroupBuyEscrow (v1, legacy) | `0x6F00715124d79114E03A94676bEa3BE697F77def` |
| **GroupBuyEscrowV2** (partial / group / crowdsource) | `0x869D11606B94de1206669C55f8628749bCBBFfD4` |
| FeeRightsLoanEscrow | `0x9F167C8dce30ca1e6F46bC2491d6434e30568790` |
| FeeRightsTimedGrantEscrow | `0xb56973cD7Bcb1AD127dFfE112daAE3960a65CC41` |
| ZoraEscrowV1 (mint TMPR) | `0x7A7540B048a8CC96837E83604B32559CCe911D9F` |
| Bankr Doppler fee manager (typical) | `0xBDF938149ac6a781F94FAa0ed45E6A0e984c6544` |
| 0xSplits PushSplit factory (Base) | `0x80f1B766817D04870f115fEBbcCADF8DBF75E017` |
| **FeeRightsBundleEscrow** (Bundle & Rebirth — deployed 2026-05-18) | `0x429Af4F73d9a254607890930848Be2E9f50dBb3F` |

---

## Action 1 — Create NFT (mint TMPR)

| Venue | Escrow | UI / agent |
|-------|--------|------------|
| **Bankr** | `BankrEscrowV3` | `prepareDeposit` → beneficiary → `finalizeDeposit` |
| **Clanker v4** | `ClankerEscrowV4` | prepare → redirect recipient → admin → finalize |
| **Clanker v3** | `ClankerEscrowV1` | same pattern on locker |
| **Zora** | `ZoraEscrowV1` | prepare → `addOwner(escrow)` → `setPayoutRecipient(escrow)` → finalize |

**APIs:** `GET /api/bankr-launches?q=wallet`, `GET /api/clanker-search-creator?creator=wallet`, `GET /api/zora-coin?address=coin`

---

## Action 2 — Sell 100% (fixed price)

**Contract:** `FeeRightsFixedSale` `0xe2A1…aA66`

**Agent default:** `POST https://www.tokenmarketplace.shop/api/list/dual` → execute `site.steps` → OpenSea skills.

**On-chain:** `approve(marketplace, tokenId)` → `list(collection, tokenId, priceWei)` → buyer `buy(listingId)` with exact wei → buyer `redeemRights(tokenId)` on correct escrow.

**Works for any TMPR** (Bankr / Clanker / Zora factory in `positionOf`).

---

## Action 3 — Partial sale (custom keep %)

**Contract:** **`GroupBuyEscrowV2`** `0x869D11606B94de1206669C55f8628749bCBBFfD4`

**Natural language:** “Sell **5%** for **0.05 ETH**” ⇒ `sellerKeepsBps = **9500**` (keep 95%), `priceWei` = wei for the **sold 5% slice** only. **Not** `POST /api/list/dual` (sell 100%).

**What:** Seller keeps `sellerKeepsBps` forever (100–9900); contributors buy the sold % with ETH; finalize → **0xSplits** + fee stream routed per `venueType`.

**Functions:**

```solidity
createPartialListing(
  IERC721 collection,
  uint256 tokenId,
  uint256 priceWei,
  uint256 durationSeconds,
  uint256 minContributionWei,
  uint16 sellerKeepsBps,      // KEEP % — sell 5% => 9500
  uint8 venueType,            // 1=Bankr 2=ClankerV4 3=ClankerV3 4=Zora
  address rightsEscrow       // e.g. 0x6238698212D91845cD1c004DE85951055bB5b292 Bankr
)
contribute(listingId) payable
finalize(listingId)
```

**UI:** tokenmarketplace.shop → **Group buy** / **Use cases** → **Partial sale**, or **My profile** → TMPR → **Partial sale**.

**Claiming fees after finalize:** Claim in Bankr/Clanker (beneficiary = split) → **Distribute** on listing.

**Platform:** **Bankr** live on V2. **Clanker/Zora** need redeployed escrows with `routeFeesTo` / `routePayoutTo` (see **`bankr-agent-test-prompts.md`**).

---

## Action 4 — Group buy (crowdfund 100%)

**Contract:** same `GroupBuyEscrow`

```solidity
createListing(collection, tokenId, priceWei, durationSeconds, minContributionWei, bankrEscrow)
contribute(listingId) payable   // many wallets
finalize(listingId)             // split % = ETH contributed / total
```

**UI:** Group buy tab → **Group buy**. If deadline passes underfunded: `refundAll` or `claimRefund`.

---

## Action 5 — Crowdsource (seller seeds + backers)

```solidity
createCrowdsource(collection, tokenId, targetRaise, durationSeconds, minContributionWei, bankrEscrow)
  payable   // msg.value = creator seed (sets their split %)
contribute(listingId) payable   // outsiders only toward targetRaise
finalize(listingId)             // creator gets raised ETH; seed returned
```

**UI:** Group buy tab → **Crowdsource** or profile → **Crowdsource**.

---

## Action 6 — Timed fee share (grant % to a wallet for N days)

**Contract:** `FeeRightsTimedGrantEscrow` `0xb56973…CC41` · [verified on BaseScan](https://basescan.org/address/0xb56973cd7bcb1ad127dffe112daae3960a65cc41#code)

**What:** Assign a **named wallet** **1–99%** of each fee distribution for **N days**. They collect that slice when you run `distributeFees`; you keep the remainder. **No ETH** from grantee. When time is up, fees route back to you.

**Not a loan:** You are not selling or renting 100% for a price — you are **sharing** a % temporarily.

**Prerequisites (Bankr):**

1. Hold TMPR → **`redeemRights(tokenId)`** (fees to your wallet; TMPR burns).
2. **`IBankrFees.updateBeneficiary(poolId, grantEscrow)`** (build via `POST /api/bankr-build-transfer` with `newBeneficiary` = grant escrow).
3. **`createGrantBankr(feeManager, poolId, token0, token1, grantee, grantBps, startTime, endTime)`**

**Ongoing (claiming — read this for employees):**

1. **Fees do not auto-send to the grantee.** They accrue to the grant escrow (Bankr beneficiary / Clanker locker / Zora payout).
2. **Lender (or anyone)** calls **`distributeFees(grantId)`** after fees are collectible — splits ERC-20: grantee gets `grantBps`, lender gets the rest.
3. **Repeat on a schedule** (e.g. weekly). Run **at least one distribute before `endTime`** while the grant is still active so the grantee gets their % of escrowed fees.
4. **Grantee** does not call Bankr “claim” on Bankr grants — they receive **token transfers** when distribute runs.
5. **After `endTime`**: the **next** `distributeFees` ends the grant, restores **100% future fees** to lender, and pays **that batch only** to lender (not split). Un-distributed fees may never reach the grantee.
6. Early end: lender **`cancelGrant(grantId)`**.

**Site:** **Use cases** tab → “Timed fee share — who claims what” playbook.

**UI:** **My profile** → TMPR → **Timed fee share** (requires `VITE_TIMED_GRANT_ESCROW_ADDRESS` in site build).

**vs paid time loan:** See table at top of this file. Grant = **% split**, no payment. Loan = **100%** stream, borrower pays ETH.

---

## Action 7 — Paid time loan (rent 100% of fees for N days for a price)

**Contract:** `FeeRightsLoanEscrow` `0x9F167C…8790`

**Bankr:**

1. `redeemRights` → `updateBeneficiary(poolId, loanEscrow)`
2. `createLoanBankr(feeManager, poolId, token0, token1, borrower, priceWei, startTime, endTime)`
3. Borrower `acceptLoan(loanId)` payable
4. After `endTime`: `reclaimLoan(loanId)`

**No forward sale during loan:** Lender cannot list (TMPR burned). Borrower must not list/partial/grant/bundle — rights must return to lender. Agent: **`loan-no-forward-sale.md`**.

**Clanker V4:**

1. Redeem TMPR → point locker recipient + admin at loan escrow
2. `createLoanClanker(locker, token, rewardIndex, borrower, priceWei, startTime, endTime)`
3. `acceptLoan` / `reclaimLoan` (escrow keeps admin for reclaim)

**What:** You set **price**, **duration**, and optional **borrower** wallet. Whoever accepts pays ETH and becomes the **sole** fee beneficiary until `endTime`, then you **`reclaimLoan`**.

**UI:** Profile → **Paid time loan** → listing guide (manual steps). **Not** timed fee share.

---

## Action 8 — Zora coin (without TMPR path)

**Mint TMPR:** `ZoraEscrowV1` (see Action 1).

**Direct on coin (separate marketplace contract):** `ZoraFeeRightsEscrow` — fixed sale / loan on `payoutRecipient` via `listForSale` / `listForLoan` (not wired in main shop UI yet). Requires `coin.addOwner(escrow)`.

---

## Action 9 — Redeem / get fee rights back

```solidity
// Pick escrow from positionOf(tokenId).factoryName / isEscrowed reads
BankrEscrowV3.redeemRights(tokenId)
ClankerEscrowV4.redeemRights(tokenId)
ZoraEscrowV1.redeemRights(tokenId)
```

Cancel OpenSea / site listing first if NFT is locked in sale.

---

## Site APIs (read + list)

| Endpoint | Use |
|----------|-----|
| `GET /api/bankr-launches?q=0xWallet` | Bankr tokens user can mint |
| `GET /api/clanker-search-creator?creator=0xWallet` | Clanker tokens |
| `GET /api/zora-coin?address=0xCoin` | Zora coin metadata |
| `POST /api/list/dual` | Sell 100% on site + OpenSea calldata |
| `GET /api/list/status?tokenId=` | Dual listing status |
| `POST /api/bankr-build-transfer` | Beneficiary → escrow / grant / loan |
| `GET /api/opensea-listings` | Browse TMPR asks |

---

## Agent rules

1. **Route by user goal** using the decision table — do not default everything to “list on OpenSea”.
2. **Group buy / partial / crowdsource** use **GroupBuyEscrowV2** with `venueType` + `rightsEscrow` (auto-resolved in UI). Redeploy **ClankerEscrowV4** / **ZoraEscrowV1** with `routeFeesTo` / `routePayoutTo` before finalize works on mainnet.
3. **Timed fee share** = timed + named wallet + **%** + **no ETH**; **paid time loan** = timed + **100%** + borrower **pays**; **partial sale** = forever split + **ETH from buyers**.
4. **Never** call `updateBeneficiary` without explicit user approval.
5. After txs: **Verification & Reporting** (Doppler + Bankr launch links, `feeRecipient` check).
