# Hybrid unit fee claim — Bankr agent (mandatory)

**Read this before any “claim fees / collect fees / claim my CTO” request when the user holds a TMPR *Unit* (ERC-1155) or bought shares on the hybrid share market.**

## P0 regression — do NOT use Bankr launch claim

| Wrong (forbidden for hybrid units) | Right (Token Marketplace path) |
|-----------------------------------|--------------------------------|
| Bankr `collectFees(poolId)` on fee manager `0xBDF938…` **from the user’s wallet** | **`HybridClaimRouter.claimFeesForToken`** |
| Assumes user wallet is the **sole fee beneficiary** | Pulls via **`BankrSplitFeeCollector`** → pays **every ERC-1155 unit holder** |
| Often succeeds with **0 WETH / 0 token** — misleading “✅ claimed” | Distributes ETH + pool tokens pro-rata to all holders |

**May 2026 regression (CTO / TMPR #12):** User held **“TMPR #12 · Unit”** on hybrid collection `0xD8e0639…`. Bankr called fee-manager `collectFees` from the Bankr smart wallet. On-chain **Collect** event showed **fees0 = 0, fees1 = 0**. Fees were **not** lost — they were never pulled from the collector vault. **Never repeat this path for unit holders.**

---

## When this playbook applies

| User holds | Claim path |
|------------|------------|
| **Hybrid ERC-1155 units** (`balanceOf(wallet, tokenId) > 0` on `0xD8e0639…`) | **This doc** — `claimFeesForToken` |
| **100% ERC-721 TMPR** on legacy `0xCD6634…` (sole owner, not split) | Fees still in escrow — **`redeemRights`** first, then Bankr app claim as direct beneficiary |
| **Group buy V2–V5** (Liquid Split, not hybrid) | Pull via **`BankrSplitFeeCollector`** + **0xSplits distribute** — site **Completed group sales** tab |
| **Direct Bankr beneficiary** (no TMPR; `getShares(poolId, wallet) > 0`) | Bankr native **`collectFees`** is correct |
| **Paid time loan borrower** | Borrower claims **directly** in Bankr/Clanker — not hybrid router |
| **Solana SPL receipt / Pump** | **Out of scope** — website + Phantom only |

---

## Contracts (Base mainnet, chain 8453)

| Role | Address |
|------|---------|
| Hybrid TMPR (ERC-721 + ERC-1155) | `0xD8e0639DfAa1cB2b9f9642EeCbd40b1e5a8b42A7` |
| HybridClaimRouter | `0x0f5148A4CdDd74e011fbe516ADddBFd61Af2E8bb` |
| BankrSplitFeeCollector V7 | `0x9939eBB359005f42B3DCE1B00a30ef7d0Cf5C6A6` |
| Bankr fee manager (typical) | `0xBDF938149ac6a781F94FAa0ed45E6A0e984c6544` |
| GroupBuyEscrow V6 (hybrid finalize) | `0x56bd948671955D0Ed82a88f136779cB76f551e0C` |

**Beneficiary for hybrid sales:** `BankrSplitFeeCollector` — **not** the unit holder’s wallet.

---

## Agent flow (execute silently)

### 0 — Status API (mandatory for tweets and “claim CTO”)

**Before any hybrid claim**, call:

```text
GET https://www.tokenmarketplace.shop/api/claim/hybrid-status?token=0x…&wallet=0x…
```

| Response field | Use |
|----------------|-----|
| `hybridTokenId` | On-chain id for `claimFeesForToken` (NOT the UI serial “#12”) |
| `serialLabel` | Human label e.g. `"12"` → “TMPR #12” |
| `unitsHeld` / `userSharePct` | User’s ERC-1155 position |
| `phase` | `ready` \| `vault_empty` \| `no_units_in_wallet` \| `needs_holder_scan` \| `not_finalized` |
| `nextStep.data` | Pre-encoded `claimFeesForToken` when holder indexer is complete |
| `nextStep.agentMustNot` | Never Bankr `collectFees` from user wallet |

**Do not ask the user to paste the token contract** if they already gave **`0xb6fB…`** or **`$CTO`** in the same tweet/thread — resolve via this API + linked Bankr wallet.

**Ticker-only tweet (`$CTO`):** call API with each candidate from `get_token_launch_info` / wallet scan, or ask **once** for the `0x…` address if multiple matches.

---

### 1 — Detect hybrid unit holding

1. User wallet (Bankr custodial or EOA).
2. Scan hybrid TMPR `0xD8e0639…`:
   - Alchemy `getNFTsForOwner` (ERC-1155) **or**
   - `balanceOf(wallet, tokenId)` for known `tokenId`.
3. Match launch token if user says “claim CTO fees”:
   - Resolve ERC-20 `0xb6fB…` → find `tokenId` where `positionOf(tokenId).token0` or `token1` matches.
4. Confirm **`isFinalized(tokenId) == true`** on hybrid TMPR.

If user holds **units** → **must** use hybrid claim router. **Stop** if you were about to call Bankr `collectFees` from their wallet.

### 2 — Preflight (optional but recommended)

On **`HybridClaimRouter`**:

```text
canClaimFees(tokenId) → (ready, reason)
```

On hybrid TMPR:

```text
feeBalance(tokenId, ETH_SENTINEL)   # 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
feeBalance(tokenId, token0)
feeBalance(tokenId, token1)
positionOf(tokenId) → poolId, token0, token1, factoryName
```

If vault balances are 0 **and** collector hasn’t pulled recently, claim may still succeed but distribute **0** — say so plainly.

### 3 — Resolve **all** unit holders (required)

`claimFeesForToken` pays **every** holder in one tx. Incomplete holder list under-pays co-owners or reverts.

**Build recipient list:**

1. Seed candidates: user wallet, `positionOf(tokenId).seller`, GroupBuy V6 contributors if known, active share-market sellers for this `tokenId`.
2. `UnitsFinalized` mint recipients (log scan / Alchemy).
3. ERC-1155 `TransferSingle` / `TransferBatch` log scan for `tokenId`.
4. **`HybridClaimRouter.getCurrentHolders(tokenId, candidates[])`** — filter to `balanceOf > 0`.
5. Validate cap table: **exactly 1000 units** assigned across holders (`HYBRID_UNITS_PER_TOKEN = 1000`).

If cap table incomplete → expand scan (Alchemy NFT API for contract `0xD8e0639…`) before submitting. Site uses the same logic — do not submit with a partial list.

**Sort recipients ascending by address** (router expects sorted list).

### 4 — Submit claim tx

```text
HybridClaimRouter.claimFeesForToken(
  tokenId,
  recipients[],   // all current unit holders, sorted
  isBankrVenue      // true when positionOf.factoryName / venue is Bankr
)
```

**Signer:** any wallet with gas (often the user’s Bankr wallet). **Payout:** all unit holders — not only `msg.sender`.

**What the tx does internally:**

1. `BankrSplitFeeCollector.pullFeesToSplit(poolId)` — collector calls `collectFees`, deposits into hybrid TMPR vault for `tokenId`.
2. `tmprContract.distributeFees(tokenId, token, recipients)` for ETH + token0 + token1.

### 5 — Verify & report (mandatory)

Follow **`runtime-contract.md`**: wait mined receipt → read logs.

| Check | Pass |
|-------|------|
| **`ClaimedHybridFees`** events | Note `token`, `amount`, `recipients` count |
| User wallet ERC-20 / ETH balance delta | Pro-rata share = `unitsHeld / 1000` |
| **Do not** cite fee-manager **Collect** with 0/0 as success | That was the wrong path |

**Plain-English success:**

> “Claimed trading fees for **$CTO** (TMPR #12). Your share: **X WETH** + **Y CTO**. **N wallets** paid in one transaction. [BaseScan link]”

**Plain-English zero vault:**

> “Ran the marketplace claim for **$CTO**. The pool vault had **nothing to distribute** right now — fees may still be accruing at the collector or trading volume is low. No fees were moved. [tx link]”

**Never say** “✅ claimed” with **0/0** unless you explicitly state **no fees were available** and you used **`claimFeesForToken`**, not Bankr launch claim.

---

## User phrases → this flow

| User says | Agent does |
|-----------|------------|
| “Claim fees on my CTO unit” | Detect hybrid unit → `claimFeesForToken` |
| “Collect fees for TMPR #12” | tokenId = 12 on `0xD8e0639…` → full holder scan → claim |
| “Claim my 1/1000 share fees” | Same — hybrid unit claim |
| “Claim fees for token `0xb6fB…`” | Resolve tokenId from `positionOf` scan → hybrid if units exist |
| “@bankr claim fees” ( holds Unit NFT ) | **This doc** — not Bankr Doppler claim |

---

## Disambiguation table

| NFT label in wallet | Type | Claim |
|---------------------|------|-------|
| “TMPR #12 · Bankr · $CTO · **Unit**” | ERC-1155 hybrid | **`claimFeesForToken`** |
| “TMPR #12 · Bankr · $CTO” (no “Unit”) | ERC-721 receipt | **`redeemRights`** or fixed-sale rules — not unit claim |
| Legacy `0xCD6634…` receipt | ERC-721 only | Redeem / list / dual list — no 1/1000 units |

---

## Site parity

Website: [tokenmarketplace.shop](https://www.tokenmarketplace.shop) → **My profile** → vault card → **Estimate payout** → **Claim fees**.

Agent should produce the **same on-chain tx** as that button (`claimFeesForToken` on `0x0f5148…`).

---

## QA prompts

```text
Claim fees for my CTO unit in my Bankr wallet
→ hybrid TMPR tokenId for 0xb6fB… → holder scan → claimFeesForToken → report user’s pro-rata payout
```

```text
@bankr collect fees 0xb6fb5ae1eb79aa628aeec8e1dfd6e736cc624ba3
→ if wallet holds ERC-1155 units: hybrid claim router ONLY
→ if wallet is direct beneficiary with no units: Bankr collectFees OK
```

**Fail the run** if the only tx is fee-manager `collectFees` from the user wallet while they hold hybrid **Unit** NFTs.

---

## @bankr tweet execution (public X — same as DM)

**Rule:** Hybrid unit **claim on tweet** uses the **same tx path** as DM when the tweeter’s **X account is linked to a Bankr wallet** and **`bankr.tx.prepare`** is available.

| Step | Action |
|------|--------|
| 0 | **`GET /api/claim/hybrid-status?token=0x…&wallet=linkedWallet`** — never ask for address if `0x…` is already in the tweet |
| 1 | If `phase === ready` and `nextStep.data` present → **`bankr.tx.prepare`** / confirm |
| 2 | If `phase === needs_holder_scan` → expand holder scan, rebuild calldata, then submit |
| 3 | If `phase === vault_empty` → reply plainly: ran marketplace claim, **nothing to distribute** (not “✅ claimed”) |
| 4 | Report **`ClaimedHybridFees`** + user **pro-rata** share + **recipient count** |

**Do not** reply “paste the contract address” when the tweet already includes **`0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3`** or `@bankr claim … 0xb6fb…`.

**Do not** stop at “link the site” if wallet + prepare path exists — execute like **`sell-list-autopilot`** tweet listing.

### Tweet the user can post (copy-paste)

Single tweet — includes token address so Bankr never asks again:

```text
@bankrbot claim hybrid unit fees for all holders on 0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3 — TMP skills v50 — use GET tokenmarketplace.shop/api/claim/hybrid-status then claimFeesForToken
```

Shorter:

```text
@bankrbot claim all CTO fee-right unit fees 0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3 (TMP v50 hybrid claim)
```

**Requires:** X account ↔ Bankr wallet linked (same as tweet listing). If not linked, Bankr can only guide — user connects wallet or uses site **Claim fees**.

### Tweet success reply (plain English)

> “Claimed **$CTO** trading fees for **N** unit holders in one tx. Your **~60%** share: **X WETH** + **Y CTO**. [BaseScan]”

(Serial label **TMPR #12** is fine in the reply — on-chain id comes from the API.)
