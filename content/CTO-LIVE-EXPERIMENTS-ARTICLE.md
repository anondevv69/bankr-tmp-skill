# The First CTOs Are Live — Two Chains, One Ticker, One Primitive

**TokenMarketplace** is running the first public **Community Takeover (CTO)** experiments in the wild: two live **`$CTO`** fee-right markets — one on **Base (Bankr)**, one on **Solana (Pump.fun)**. Neither is fully sold out yet. We are asking wallets to help **finish the first-ever on-chain CTO** where **many holders own the revenue stream**, not the meme supply.

Updates: [@TokenMkp](https://x.com/TokenMkp) — [post 1](https://x.com/TokenMkp/status/2061791593753985088) · [post 2](https://x.com/TokenMkp/status/2061793515097526392)

---

## What a CTO Actually Is (30 seconds)

A **CTO** on TokenMarketplace is a **group buy for fee rights**:

1. Fee rights for a coin are wrapped in a marketplace receipt (TMPR on Base, SPL receipts on Solana).
2. Wallets pool **ETH** (Base) or **SOL** (Solana) until the raise target is met.
3. After finalize, rights split into **1,000 tradeable units**. Your **units ÷ 1,000** = your **% of future trading fees**.
4. The **meme token supply does not move**. No dev dump. No “team sold.” You bought **cash flow**, not speculation on the chart.

The token stays the token. The fees become a market.

---

## Experiment 1 — Base · Bankr · `$CTO`

| | |
|---|---|
| **Chain** | Base |
| **Launch platform** | **Bankr** (fee beneficiary on Bankr’s Uniswap/Doppler pool) |
| **Meme token** | `0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3` |
| **Marketplace sale** | Hybrid TMPR **#12** · [unit order book](https://www.tokenmarketplace.shop/listing/shares/t/82162810189150381448686192642592435479296266651479359308798582033011722422011) |
| **What you buy** | **ERC-1155 fee-right units** (1,000 total). **1 unit = 0.1%** of the fee stream tied to this sale. |
| **Status (live)** | CTO path has **minted units to the community** (~**630 / 1,000** units already held across **100+ wallets**). **~370 units** still available on the share book — help us close the first Bankr CTO. |
| **Raise note** | Early CTO economics included roughly **~4 ETH** committed in the experiment window (long-dated listing mechanics — **deadline out to 2069** on the group-buy lane so the pool stays open for wallets to finish). |

### How Bankr fees work here

- Traders swap the **`$CTO` ERC-20** on Base.
- Swap fees accrue to Bankr’s **fee beneficiary** for that pool.
- After CTO finalize, those fees route through the marketplace **split / hybrid vault**, then pay **unit holders pro-rata** when someone runs **Claim** (pull fees in → distribute to all unit balances).

**Fee rate (important):** Bankr pools use a **pool fee tier** set at launch (commonly **1%** swap fee on many Bankr memecoins — confirm on the live Bankr pool for `$CTO`). Your units do **not** entitle you to 1% of volume directly — you get **`(your_units / 1000) × (100% of the fee-right slice)`** of whatever was actually collected.

---

## Experiment 2 — Solana · Pump.fun · `$CTO`

| | |
|---|---|
| **Chain** | Solana |
| **Launch platform** | **Pump.fun** (creator / trading fee sharing) |
| **Mint** | `ErVwSeH3Ui4HQP5zhdq1Hevi95L8bzhqsMfQPddbpump` |
| **Listing** | [Solana CTO page](https://www.tokenmarketplace.shop/listing/sol/FuSpfsCRGRvRcJqMQwG8SyWw8yKuANZspQp6cQBRNJPN) |
| **What you buy** | **SPL receipt units** (1,000 total). **1 unit = 0.1%** of the Pump fee stream after CTO completes. |
| **Status (live)** | CTO / share book **not fully sold** — cheapest public lots and password-gated lots still on the book. **Fee vault** for live Pump trading fees may still be **empty until CTO + Pump fee split + claim** steps finish (raise SOL ≠ trading fees). |

### How Pump fees work here

- Pump routes **creator / trading fees** to shareholders configured in **`update_fee_shares_v2`** (one-time lock).
- For CTO, the plan is **`fee_vault` 100%** → marketplace splits to **1,000 SPL units** pro-rata.
- Holders **Claim** on the listing page: Pump **distribute** into the vault, then batch pay unit holders.

**Fee rate (important):** Pump fees depend on **bonding-curve vs migrated AMM** phase. For math below we use an **illustrative ~1% of traded notional** reaching the creator fee vault (adjust down if your phase is lower). This is **not** a guarantee — only **on-chain claims** count.

---

## You Own a Share of Fees — What Does That Mean?

### What you **do** get

| Action | Result |
|--------|--------|
| Hold **1 unit** | **0.1%** of every fee distribution for this listing |
| Hold **10 units** | **1%** |
| Hold **100 units** | **10%** |
| Hold **500 units** | **50%** |
| Someone runs **Claim** | Fees already pulled into the vault/split are paid **pro-rata** to all units |
| **Trade units** | Buy/sell on the share order book — still no token dump |
| **Free airdrop of 1 unit** | You still only earn **0.1%** of collected fees — but if volume is real, 0.1% adds up (see table) |

Units show in **Profile → NFTs → Your fee-rights units** (Base ERC-1155 or Solana SPL).

### What you **do not** get

- Voting rights in the ERC-20
- Ability to mint or burn the meme token
- Liquidity pool ownership (unless you separately buy the coin)
- Automatic payouts — fees must **accrue from trading**, then a holder/keeper runs **Claim / Distribute**

---

## Hypothetical Payouts (Illustrative Only)

Assume:

- **Fee pool** = `volume × effective_fee_rate`
- **Your share** = `(units ÷ 1000) × fee_pool`
- **Effective fee rate** = **1%** of volume to the fee-right pool (round number for math; real Bankr/Pump rates vary)

### One free airdrop unit (0.1%)

| Trading volume (notional) | ~1% fee pool | **Your 1 unit (0.1%)** |
|---------------------------|--------------|-------------------------|
| $100,000 | $1,000 | **$1** |
| $500,000 | $5,000 | **$5** |
| **$1,000,000** | **$10,000** | **$10** |
| $2,000,000 | $20,000 | **$20** |
| $3,000,000 | $30,000 | **$30** |
| $5,000,000 | $50,000 | **$50** |
| **$10,000,000** | **$100,000** | **$100** |

### If you bought 10 units (1%)

| Volume | Fee pool (~1%) | **Your 10 units** |
|--------|----------------|-------------------|
| $1M | $10,000 | **$100** |
| $2M | $20,000 | **$200** |
| $5M | $50,000 | **$500** |
| $10M | $100,000 | **$1,000** |

### If you bought 100 units (10%) — “serious CTO seat”

| Volume | Fee pool (~1%) | **Your 100 units** |
|--------|----------------|---------------------|
| $1M | $10,000 | **$1,000** |
| $2M | $20,000 | **$2,000** |
| $5M | $50,000 | **$5,000** |
| $10M | $100,000 | **$10,000** |

**Reality check:** `$CTO` on DexScreener today is **early** — most upside in these tables is **if** attention and volume show up **after** you hold units. Fee rights are a bet on **activity**, not market cap.

---

## Base vs Sol — Side by Side

| | **Base (Bankr)** | **Solana (Pump)** |
|--|------------------|-------------------|
| **Coin** | Bankr-launched `$CTO` | Pump.fun `$CTO` (`…pump`) |
| **Fee source** | Bankr pool swap fees | Pump creator + trading fee share |
| **Unit token** | ERC-1155 on hybrid TMPR `0xD8e0639…` | SPL receipt mint |
| **Finish the experiment** | [Buy remaining units](https://www.tokenmarketplace.shop/listing/shares/t/82162810189150381448686192642592435479296266651479359308798582033011722422011) | [Sol listing](https://www.tokenmarketplace.shop/listing/sol/FuSpfsCRGRvRcJqMQwG8SyWw8yKuANZspQp6cQBRNJPN) |
| **Claim** | Profile / hybrid claim router | Listing → **Claim** |

---

## Why We’re Pushing Wallets to Finish

Historically, “CTO” meant social takeover and chart chaos.

This CTO means:

- **200 wallets** can own the **business** (fees) instead of fighting over supply
- Transparent **on-chain** caps (1,000 units)
- **No contract migration** — same token, new ownership of revenue

We’re trying to prove the primitive: **the first fully distributed fee-right CTO** — on **Bankr** and **Pump**, same ticker, same idea.

---

## Get Involved

- **Site:** [tokenmarketplace.shop](https://www.tokenmarketplace.shop)
- **Skills:** [github.com/anondevv69/bankr-tmp-skill](https://github.com/anondevv69/bankr-tmp-skill)

**TokenMarketplace — fee rights as a market.**
