# One-line intents — Bankr must execute, not interview

> **Read this first** on every Token Marketplace message. User gives **one sentence**; you run the **full flow** in **one conversation**.

**Full step detail:** `TOKEN-SETUP-COMPLETE-GUIDE.md` · **Sell 100%:** `sell-list-autopilot.md` · **Split 1000:** `split-1000-autopilot.md`

---

## Golden rule

| User provides | You do |
|---------------|--------|
| **Ticker or launch `0x…`** + **intent** (sell / split / partial / redeem / claim) | Resolve token → call APIs → sign txs → verify → reply with **shop URL** or **tx links** |
| **Price in ETH** (for sell/list) | Use it — do **not** ask “what price?” |
| **Linked Bankr wallet** | Use it — do **not** ask “which wallet?” unless multiple launches conflict |

**Only ask ONE question** when truly blocked:

- “Which token — t7 or t5?” (multiple launches, no ticker)
- “What price in ETH?” (sell intent with **no** number)
- Password on **public** tweet (DM for password)

**Never ask:** site vs OpenSea · TMP skill version · paste API URLs · Doppler dashboard · “confirm you want marketplace”

---

## Intent table (what the user means)

| User says (examples) | Means | Flow | Autopilot file | NOT this |
|----------------------|-------|------|----------------|----------|
| **Sell / list [ticker] for 0.01 eth** | Sell **100%** of fee rights at fixed price | **A** | `sell-list-autopilot.md` | Selling ERC-20 supply · OpenSea-only |
| **List my $t7 for 0.01** | Same as above | **A** | `sell-list-autopilot.md` | `0x935e…` ($TMP) |
| **Create NFT for t7** | Mint TMPR only (no sale yet) | **1** | `mint-pending-deposit.md` | List before mint done |
| **Create NFT and list for 0.01 eth** | Mint if needed → dual list | **1→A** | mint + `sell-list-autopilot.md` | Stop after mint |
| **Split [ticker] into 1000** / **1000 nfts** / **fractionalize** | **1000 fee-right units** (ERC-1155), not 1000 ERC-721s | **C** | **`fractionalize-autopilot.md`** | `POST /api/list/dual` · Doppler dashboard |
| **Split into 1000 and keep them all** | Mint if needed → V6 finalize → 1000 units | **C** | **`fractionalize-autopilot.md`** | User pastes mint/status URLs |
| **Just deployed $XXX — fractionalize 1000** | Same as Flow C (compound mint + split) | **C** | **`fractionalize-autopilot.md`** | Stop after deploy without mint |
| **Sell 5% keep 95% for 0.005 eth** | Partial sale forever | **B** | `flows-reference.md` Flow 3 | Dual list |
| **Group buy** / **let people pool** | Many wallets fund 100% | **D** | `flows-reference.md` Flow 4 | Dual list |
| **Give dev 10% for 30 days** | Timed grant, no payment | **E** | `flows-reference.md` Flow 6 | Partial sale |
| **Loan my fees for 0.5 eth for 2 weeks** | Paid time loan | **G** | `dm-intents.md` Path G | Grant |
| **Get my fees back** / **redeem** | Burn TMPR, restore beneficiary | **H** | `redeem-rights-playbook.md` | List |
| **Claim fees for [ticker]** | Hybrid unit claim OR native claim | **K** | `hybrid-claim-autopilot.md` | Skip hybrid-status |
| **Buy cheapest 1/1000 of t7** | Buy share on order book | **I** | `share-market-buy.md` | Dual list · `/listing/sale/` |
| **Buy /listing/sale/1** or **buy listing 1** (shop URL) | Buy **100%** fixed sale | **F** | `buy-fixed-sale-autopilot.md` | `share/list-status` · `0x9023…` |
| **Buy this listing** + `tokenmarketplace.shop/listing/sale/…` | Same — whole TMPR | **F** | `buy-fixed-sale-autopilot.md` | Share market |
| **Cancel my share listing** | Cancel ERC-1155 listing | **J** | `share-market-cancel-autopilot.md` | Fixed sale cancel |
| **Send / gift / airdrop N units** to `0x…` | Move ERC-1155 fee-right units (gift) | **L** | `transfer-units-autopilot.md` | Share market list · dual list |
| **Airdrop units equally** to many wallets | Batch unit transfer | **L** | `transfer-units-autopilot.md` | Mint 1000 NFTs |
| **What did I sell** / **purchases on shop** | Completed sales history | **M** | `profile-completed-sales.md` | Tokens tab only |

---

## Flow A — “Sell this token for 0.01 eth” (most common)

**User:** `Sell t7 for 0.01 eth` · `List $t7 for 0.01` · `Can you sell my token for 0.01 eth on tokenmarketplace`

**You interpret:** **Dual list** — site at **0.01 ETH** **and** OpenSea in the **same** turn (default). **Site only** if password / max-per-wallet / user said site only (`LISTING-VENUES.md`).

**You run (same thread, no stops):**

1. Resolve launch: **ticker → `get_token_launch_info`** → e.g. t7 = `0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3` (**never** `0x935e…`).
2. `GET /api/mint/status?tokens=0x9021…&wallet=<linked>`.
3. Execute every `nextStep` until **`phase: ready`** (prepare → transfer → finalize if needed).
4. `POST /api/list/dual` with **`tmprTokenId`**, **`priceEth`**, **`seller`** = TMPR `ownerOf` (see `linked-wallet.md`).
5. Sign **`approve`** + **`list`** from `seller`. If approve blocked → **`custodial-approve-block-retry.md`** (3 retries → transfer NFT to user EOA → tell them shop URL).
6. `GET /api/list/status` → reply with **full** `https://www.tokenmarketplace.shop/...` URL.

**Success reply (template):**

```text
Listed t7 fee rights at 0.01 ETH on Token Marketplace. [full shop URL]
```

**Forbidden replies:** “Which marketplace?” · “Phase needs_prepare” without calling mint/status on **0x9021…** · “Update Doppler manually” · “Scanner blocked, list manually at .” (always include **https://www.tokenmarketplace.shop**)

---

## Flow C — “Split into 1000 NFTs” (fractionalize)

**User:** `Split t7 into 1000` · `Fractionalize my $dntfbuy into 1000 shares` · `I just deployed $XXX — keep all units` · `Make 1000 nfts for my token`

**User does NOT need to say:** TMP skill version · `GET /api/mint/status` · escrow `0x047B` · “don’t use Doppler” — **you** know that from **`fractionalize-autopilot.md`**.

**You run (full spec):** **`fractionalize-autopilot.md`**

1. **`GET /api/mint/status`** silently → mint until **`ready`** (never Doppler dashboard; never beneficiary transfer before `prepareDeposit`).
2. If **`platformBlocker`** → **`hybrid-escrow-mint-blocker.md`** plain English.
3. **GroupBuyEscrowV6** split → 1000 units on `0xD8e0639…` · verify **`hybrid-status`**.

**Clarify once if user says “1000 nfts”** — then execute without waiting.

---

## Flow F — “Buy 100%” (`/listing/sale/{id}`)

**User:** `buy https://www.tokenmarketplace.shop/listing/sale/1` · `buy listing 1 on token marketplace` · `purchase the full fee rights at this link`

**You interpret:** **Fixed sale buy** — **not** “buy 1 share” · **not** `GET /api/share/list-status`.

**You run:**

1. **`GET https://www.tokenmarketplace.shop/api/list/buy-status?url=<full shop url>`** (or `?listingId=` only if user gave sale id explicitly).
2. If **`canBuy: false`** → say fixed sale inactive (sold/cancelled) — **do not** cite `0x9023…` share market.
3. If **`passwordProtected`** → `POST /api/listings/access-authorize` then 3-arg `buy`.
4. Else execute **`nextStep`**: `buy(listingId)` on **`0xe2A1…`** with **`value = priceWei` exactly**.
5. Verify buyer owns receipt `tokenId` on `collection` from API response.

**Forbidden:** “Listing inactive on HybridShareMarketplace 0x9023…” when URL contains **`/listing/sale/`**.

Full spec: **`buy-fixed-sale-autopilot.md`** · Regression: **`buy-url-routing-regression.md`**

---

## Flow B — “Sell 5%, keep 95%”

**User:** `Sell 5% of t7 fees for 0.01 eth, keep the rest`

**You interpret:** **Partial sale** on GroupBuyEscrowV2 — permanent split after finalize.

**You run:** TMPR ready → `createPartialListing` with `sellerKeepsBps` → wait/fund → `finalize` → reply with group-buy tab link.

**Do not:** `list/dual`.

---

## Default assumptions (never re-ask)

| Topic | Default |
|-------|---------|
| Chain | Base (8453) |
| List venue | **tokenmarketplace.shop** |
| Sell 100% (plain) | **Dual** — site txs + OpenSea (default) |
| Password / max per wallet / shares | **Site only** — no OpenSea |
| User says site only or OpenSea only | That venue only |
| Wallet | Bankr linked wallet |
| TMPR seller for `list/dual` | On-chain **ownerOf(tokenId)** |
| t7 token | `0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3` |
| `escrowMismatch` + `ready` | **List anyway** — do not remint |

---

## When you MAY stop (real blockers only)

Report **phase + next signer + one action** — never “try smaller steps”:

| Blocker | Say |
|---------|-----|
| Approve blocked 3× | “Moving TMPR to your wallet for you to list at [shop URL]” OR escalate whitelist |
| `not_beneficiary` | “This wallet isn’t the fee owner for that token” |
| `list/dual` reverts | Check seller = owner; Vercel/API; paste error |
| No launch resolved | “Which token — ticker or launch address?” |

---

## Copy-paste examples for users

```text
Sell t7 for 0.01 eth on tokenmarketplace
```

```text
Split t7 into 1000 units — keep all in my wallet
```

```text
Sell 10% of t7 fees for 0.02 eth, I keep 90%
```

```text
Create NFT for t7 and list for 0.01 eth
```

```text
Redeem my t7 fee rights — fees back to my wallet
```

Bankr should execute each without a questionnaire.
