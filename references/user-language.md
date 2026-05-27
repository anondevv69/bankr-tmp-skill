# Plain language ↔ on-chain actions (Bankr agent)

**User-facing:** **`normal-talk-only.md`** — users never need to say poolId, bps, wei, or contract names. This file is **routing** (what they mean → what you do).

Users think in **website words**. Map their phrases **before** answering. **Never** reply “you already own the NFT” without checking **escrow**, **marketplace listing**, and **fee beneficiary** state.

**If user pastes `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e`:** read **`tmpr-collection-address-trap.md`** immediately — **never** token-fees / Clanker on that address.

---

## Vocabulary (TMP skills — full marketplace)

| User / UI says | Technical meaning | Main contract(s) |
|----------------|-------------------|------------------|
| **Create NFT** | Escrow fee rights → mint TMPR receipt | `BankrEscrowV3` / `ClankerEscrowV4` / `ZoraEscrowV1` |
| **NFT** / **TMPR** / **receipt** | ERC-721 proof fee rights are in escrow | `BankrFeeRightsReceipt` `0xCD6634…0C3e` |
| **Sell rights** / **list for X ETH** / **sell 100%** | Fixed sale of all fee rights | `FeeRightsFixedSale` + **`POST /api/list/dual`** + OpenSea skills |
| **Partial sale** / **keep X% sell Y%** | Forever split; buyers fund sold % | `GroupBuyEscrow.createPartialListing` |
| **Group buy** | Many wallets pool ETH | `GroupBuyEscrow.createListing` |
| **Crowdsource** | Creator seeds + backers | `GroupBuyEscrow.createCrowdsource` |
| **Timed fee share** / **employee grant** / **assign 10% for 30 days** | Named wallet, **%** of fees for N days, **no ETH**, then return to you | `FeeRightsTimedGrantEscrow` |
| **Paid time loan** / **bag worker** / **loan rights for X ETH** | **100%** to borrower for N days; **borrower pays** `priceWei`, then return to you | `FeeRightsLoanEscrow` |
| **For sale** / **listed** | Site and/or OpenSea ask | `GET /api/list/status` + OpenSea |
| **Get fee rights back** / **redeem** | Burn TMPR, fees to wallet | `redeemRights(tokenId)` |
| **Bundle & Rebirth** / **merge into $TICKER** / **burn 3 NFTs and launch** | Combine N fee receipts → WETH to **user** → dead-wallet old streams → new Bankr token + initial buy | `FeeRightsBundleEscrow` + `/api/bundle/*` + `token-launches/deploy` |
| **1/1000 share** / **buy cheapest share** / **buy 1 unit** | One ERC-1155 unit from a **listed offer** on the share order book | `HybridShareMarketplace.buy` — **`share-market-buy.md`** |
| **Reply drop** / **first 100 replies get 1%** / **first 1000 replies get 1/1000** | Planned hybrid fee-right campaign; winners get TMPR units that later share fee claims | **Planning only** — **`reply-drop.md`** |
| **Fee rights** | LP / trading fee stream (not launch ERC-20) | Fee manager / locker / Zora payout |
| **Launch token** | Deployed ERC-20 (t7, …) | Token contract address |

**Not the same:**

- **NFT in wallet** ≠ **fee rights in wallet** — TMPR = escrowed; **redeem** restores direct beneficiary.
- **TMPR collection** (`0xCD66…`) ≠ **tokenId** ≠ **user wallet**.
- **Timed fee share** (timed **%**, named wallet, **no ETH**) ≠ **paid time loan** (timed **100%**, borrower **pays**) ≠ **partial sale** (forever %, buyers pay ETH).
- **“Loan my rights for 2 weeks for 0.1 ETH”** → **paid time loan**. **“Give 0x… 15% for 30 days”** → **timed fee share**.
- **“Assign wallet 20%”** without “forever” or “buy” → **timed fee share**; with “buy/fund” → **partial sale**.
- **Dual listing** = site (`/api/list/dual`) + OpenSea — default for **sell 100%**.
- **1/1000 share buy** = pick a **listed unit offer** (cheapest first) — **not** buying the whole TMPR on fixed sale; **not** chipping into a partial-sale pool.
- **“Version 1”** on share market = usually **cheapest offer, quantity 1** — not a serial # inside the NFT.
- **Bundle & Rebirth** = burn **fee-receipt NFTs** + collect fees to **user wallet** + launch **new** Bankr token — **not** merging ERC-20s; **not** platform holding coins or paying the buy.

**Full option matrix:** **`all-escrow-options.md`**. **Bundle (anti-stuck playbook):** **`bundle-rebirth-playbook.md`** · custody/APIs: **`bundle-rebirth.md`**.

---

## Intent router (read this first on every message)

```
User message
    │
    ├─ "what do I have for sale" / "listed" / "on the market"
    │     → Portfolio: FOR SALE (OpenSea; site only if user already used site UI)
    │
    ├─ "what NFTs" / "TMPR" / "receipts in my wallet"
    │     → Portfolio: NFTS IN WALLET (unlisted + listed separately)
    │
    ├─ "what can I list" / "convert to NFT" / "create NFT" / "eligible tokens"
    │     → Portfolio: CAN CREATE NFT (launches with shares, not yet escrowed)
    │
    ├─ "get back" / "return" / "convert back" / "owner again" / "redeem"
    │     → DISAMBIGUATE (see below) — then full tx flow
    │
    ├─ pasted address is 0xCD6634… / 0xcd6634… (TMPR collection)
    │     → STOP — tmpr-collection-address-trap.md — NOT token-fees, NOT "unsupported token"
    │
    ├─ "sell … for X ETH" / "list for X" / "sell 100%"
    │     → If no TMPR: CREATE NFT → **dual list** (`POST /api/list/dual` + OpenSea)
    │     → If TMPR in wallet: dual list only
    │
    ├─ "buy cheapest share" / "buy 1/1000" / "buy 1 share of $t7" / "buy version 1"
    │     → **Share market buy** — share-market-buy.md — HybridShareMarketplace
    │     → NOT FeeRightsFixedSale; NOT partial sale contribute
    │
    ├─ "partial" / "keep 70%" / "sell 30% of fees" / "sell 5% for 0.05 eth"
    │     → **Partial sale** — GroupBuyEscrowV2 — see all-escrow-options.md
    │     → sell 5% => sellerKeepsBps 9500; NOT /api/list/dual
    │
    ├─ "group buy" / "crowdfund" / "pool ETH"
    │     → **Group buy** — GroupBuyEscrow.createListing
    │
    ├─ "crowdsource" / "seed" / "backers"
    │     → **Crowdsource** — createCrowdsource + seed
    │
    ├─ "employee" / "assign 10%" / "give wallet % for N days" / "they get fees then it returns"
    │     → **Timed fee share** — FeeRightsTimedGrantEscrow (NOT loan)
    │
    ├─ "@bankr sell 5% for X" / tweet partial sale
    │     → **Partial sale** intent + link tokenmarketplace.shop; wallet required
    │
    ├─ "loan" / "rent fees" / "bag worker" / "borrower pays" / "all fees for N days for X ETH"
    │     → **Paid time loan** — FeeRightsLoanEscrow (100%, paid — NOT % grant)
    │
    ├─ "bundle" / "rebirth" / "merge into" / "burn N NFTs and launch" / "combine tokens and deploy"
    │     → **Bundle & Rebirth** — bundle-rebirth-playbook.md — TMPR scan → mint if needed → prepare → claim → disband (feesTo=user) → deploy → buy
    │     → Never say platform holds tokens or pays initial buy
    │
    ├─ "first 100 replies get 1%" / "first 1000 get 1/1000" / "password protect the claim page"
    │     → **Reply drop** — planning/spec only — read reply-drop.md
    │     → Explain fee-right units, not token supply; do not pretend current contracts can execute free/password claims
    │
    ├─ "create nft for <ticker>" / "convert … to nft" / "create nft … token contract 0x…"
    │     → Resolve launch token (ticker → address via API)
    │     → feeManager 0xBDF938… + escrow 0x6238… (defaults — user does not say these)
    │
    ├─ compound: "create nft … and list for X eth" (one or two messages)
    │     → Mint (3 txs) + **OpenSea** list (see § Compound requests below)
    │
    └─ OpenSea link or tokenId only
          → Resolve tokenId → positionOf → state table → offer correct action
```

---

## “Get it back” / “return to my wallet” — mandatory checks

When user wants to **get fee rights back** or **stop being an NFT holder**:

1. **`ownerOf(tokenId)`** on TMPR — who holds the NFT?
2. **`positionOf(tokenId)`** — `feeManager`, `poolId`, `token0`, `token1`, factory
3. **`isEscrowed(poolId)`** on `BankrEscrowV3` (or Clanker `isEscrowed(key)`) — still in escrow?
4. **OpenSea** — active Seaport listing? (agents default venue)
5. **Site** `FeeRightsFixedSale` — only if user already listed there via UI (not agent-initiated)

| State | What user wants | Action (orchestrate full tx sequence) |
|-------|-----------------|--------------------------------------|
| NFT in user wallet, **not** listed | Get fee rights back | **`redeemRights(tokenId)`** on escrow from `positionOf` (Bankr or Clanker V4) |
| NFT listed on **OpenSea** | Unlist first OR get rights back | Cancel OpenSea listing, then **`redeemRights`** |
| User says “return NFT” but already holds NFT | They mean **fee rights**, not transfer | Explain + offer **redeemRights** |
| Not escrowed / no TMPR | Raw fee rights on fee manager | No redeem — they already have beneficiary role; use **create NFT** only if they want a receipt |

**After redeem:** TMPR is **burned**; user is **fee beneficiary** again on Bankr/Clanker. They do **not** receive the launch ERC-20 token.

**After redeem — verification (required):** Call **`get_token_launch_info`** for the launch token address; confirm **`feeRecipient`** is the user’s wallet. Always send:

- `https://app.doppler.lol/tokens/base/{tokenAddress}`
- `https://bankr.bot/launches/{tokenAddress}`

If **My Launches** is empty or stale, explain **indexer delay** — Doppler/Bankr launch pages show the live beneficiary sooner.

---

## Portfolio queries (answer from chain + APIs)

Use the user’s **wallet address** (`0x…`, 42 chars). Chain: **Base 8453**.

### A) “What tokens do I have **for sale** right now?”

1. **OpenSea (TMPR):** collection `tokenmarketplace` — user's active Seaport orders; optional read proxy `GET https://tokenmarketplace.shop/api/opensea-listings` (read-only, not for agent listing).
2. **Site** (optional read): only if user may have listed via website UI before — do **not** suggest new site listings.
3. Summarize: *“You have N listings on OpenSea: $TICKER at X ETH…”*

### B) “Which tokens do I have as **NFTs** currently?”

1. NFT balance on TMPR `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e` (and aliases if needed) — Alchemy `getNFTsForOwner` or app scan pattern.
2. For each tokenId: **`positionOf`** → show **name/symbol** from token0/token1 ERC-20 `symbol()`.
3. Split:
   - **In wallet, not listed** → “NFT in wallet — can list on OpenSea or Get fee rights back”
   - **Listed on OpenSea** → under FOR SALE

### C) “Which tokens can I **list** or **convert to NFT**?”

1. **Bankr:** `GET https://tokenmarketplace.shop/api/bankr-launches?q=WALLET` — tokens where user has creator/fee role.
2. **Clanker:** `GET https://tokenmarketplace.shop/api/clanker-search-creator?creator=WALLET`
3. On-chain: **`getShares(poolId, user) > 0`** on fee manager **`0xBDF938149ac6a781F94FAa0ed45E6A0e984c6544`** (production Bankr) unless registry proves another; **`allowedFeeManager`** must be true; **`!isEscrowed(poolId)`**.
4. Exclude pools that already have a TMPR in wallet (same `tokenIdFor(feeManager, poolId)`).
5. Summarize: *“You can Create NFT for: $A, $B …”*

### D) “Sell this NFT / rights for **X ETH**”

| Starting state | Steps to orchestrate |
|----------------|----------------------|
| No TMPR yet | **Create NFT** (3 txs) → **OpenSea** list via opensea-marketplace |
| TMPR in wallet | **OpenSea** list only — hand off to OpenSea skills |
| Already listed on OpenSea | OpenSea UI to cancel/update, or cancel + re-list |

Convert user ETH → wei for Seaport; confirm listing live on OpenSea before saying "listed".

---

## Compound requests (Create NFT + list — natural language)

Users often split this across **two chat messages** or say it **once**. Treat both the same.

| How the user says it | You resolve | On-chain sequence |
|----------------------|-------------|-------------------|
| “Create NFT for **t7**” | `get_token_launch_info` / `token-fees` → `0x9021…3ba3` | prepare → beneficiary → finalize |
| “Then **list it** for **0.0069** eth” | Same token from thread; price in ETH | **OpenSea** listing after mint |
| “Create NFT for **t7** and list for **0.0069** eth” | Same as both rows | Mint (3 txs) + **OpenSea** list |
| “Create NFT for my **test** token — `0x9021…`” | `0x9021…` = **launch token** only | Same; do **not** use that address as fee manager |
| “List **t7** for .0069” (no NFT yet) | t7 → create NFT first, then OpenSea | mint + OpenSea |
| “List **t7** for .0069” (TMPR already in wallet) | Skip mint | OpenSea list only |

**Defaults you apply (Bankr Doppler on Token Marketplace — do not ask the user):**

- **feeManager:** `0xBDF938149ac6a781F94FAa0ed45E6A0e984c6544`
- **escrow:** `0x6238698212D91845cD1c004DE85951055bB5b292`
- **TMPR collection:** `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e`
- **listing venue:** **OpenSea** collection `tokenmarketplace` — **not** tokenmarketplace.shop until API exists

**Reply style:** Confirm in plain English (“I’ll mint your TMPR, then list it for 0.0069 ETH **on OpenSea**”) — then mint txs + **OpenSea skills** handoff. Never mention site marketplace listing.

---

## Example user prompts → agent behavior

| User says | Agent does |
|-----------|------------|
| What tokens do I have for sale? | Run portfolio **A**, plain list |
| What NFTs do I have? | Run portfolio **B** |
| What can I turn into an NFT? | Run portfolio **C** |
| Create an NFT for my $t5 token | **Create NFT** full flow (3+ txs), gate on receipts |
| Create NFT for t7 | Resolve t7 → `0x9021…`; feeManager `0xBDF938…`; prepare → transfer → finalize |
| Then list it for 0.0069 eth | **OpenSea** via opensea-marketplace — not site marketplace |
| Create NFT for t7 and list for 0.0069 eth | Mint (3 txs) → **OpenSea** list via opensea-marketplace + verification |
| Convert fee rights for `0x…` / list for X ETH | If `0x…` is not a launch token, resolve **ticker** → token `0x9021…`; fee manager **`0xBDF938…`** — never block on wrong pasted address |
| First 100 replies get 1% each | Explain this as `10` units each on a `1000`-unit hybrid split; gather campaign params; mark as **planned**, not live execute |
| First 1000 replies get 1/1000 each | Explain this as `1` unit per winner; gather claim / wallet-linking rules; mark as **planned**, not live execute |
| Sell my KITT rights for 0.01 ETH | If NFT exists → **Sell rights**; else Create NFT first |
| List TMPR #19 for 0.005 ETH | **Sell rights** with tokenId from receipt |
| Get this back to my wallet / convert NFT to rights | **Disambiguate** table → **redeemRights** or cancel then redeem |
| I want to be the fee owner / **reward person** again | **`redeemRights(tokenId)`** — verify Doppler `feeRecipient` = user wallet after |
| `0xCD66…` return to my wallet | **Wrong target** — collection contract; ask ticker, OpenSea URL, or tokenId |
| Bought TMPR on OpenSea — get fees in my wallet | **redeemRights** if they hold the NFT |
| Cancel my sale | Cancel on **OpenSea** + site `FeeRightsFixedSale.cancel` if dual-listed |
| Give employee 10% for 30 days | **Employee grant** — redeem → grant escrow → `createGrantBankr` |
| Sell 5% for 0.05 ETH | **Partial sale** — `sellerKeepsBps=9500`, `priceWei` for 5% slice, GroupBuyEscrowV2 |
| Keep 80% sell 20% for 0.1 ETH | **Partial sale** — `createPartialListing(8000 bps, …)` |
| @bankr sell 5% of $TICKER for X | **Partial sale** guide + site link; no auto-tx |
| Pool 0.5 ETH to buy my fees | **Group buy** — `createListing` + `contribute` + `finalize` |
| Loan my fees for 2 weeks | **Loan** — `FeeRightsLoanEscrow` (not employee grant) |
| Clanker token partial sale | Explain: group/partial UI is **Bankr TMPR** today; Clanker → sell 100% or loan |

---

## Full transaction orchestration (agent rules)

1. **Resolve** wallet, token/NFT id, and goal using the router above.
2. **Read** state on-chain before proposing txs.
3. **Queue** mint txs in order: never invert prepare vs beneficiary. **Listing** = OpenSea handoff after mint — not site `approve`/`list`.
4. Use Bankr **`confirmTransaction`** / mini-app when available; otherwise structured “Send transaction to … calling …” blocks.
5. **Report** after each mined tx: BaseScan link + what changed (shares, owner, listing active).
6. **Verification & Reporting** (every state-changing tx): **`get_token_launch_info`**, confirm **`feeRecipient`**, show **Doppler** + **Bankr launch** URLs — see main **`SKILL.md`** § Verification & Reporting.
7. On success, link site listing + **OpenSea item URL** (`/item/base/{TMPR}/{tokenId}`) when dual-listed.

---

## Canonical addresses (Base)

| Role | Address |
|------|---------|
| BankrEscrowV3 | `0x6238698212D91845cD1c004DE85951055bB5b292` |
| TMPR (CFR) | `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e` |
| FeeRightsFixedSale (agents: do not list) | `0xe2A13499292D43254026DAf0C4F75988242BaA66` — operators only |
| ClankerEscrowV4 | `0x3546A98C09fc5a3E162d510DB331C4dcEdB6EADa` |
| GroupBuyEscrow | `0x6F00715124d79114E03A94676bEa3BE697F77def` |
| FeeRightsLoanEscrow | `0x9F167C8dce30ca1e6F46bC2491d6434e30568790` |
| FeeRightsTimedGrantEscrow | `0xb56973cD7Bcb1AD127dFfE112daAE3960a65CC41` |
| ZoraEscrowV1 | `0x7A7540B048a8CC96837E83604B32559CCe911D9F` |
