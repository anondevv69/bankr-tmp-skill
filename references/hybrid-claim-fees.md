# Hybrid unit fee claim — Bankr agent (mandatory)

**Read this before any “claim fees / collect fees / claim my CTO” request when the user holds a TMPR *Unit* (ERC-1155) or bought shares on the hybrid share market.**

---

## Glossary — what each thing means (read first)

Agents **must** understand these distinctions. Users will **not** use this jargon — translate silently.

### Assets (three different things)

| Term | What it is | Example (CTO) | Used for |
|------|------------|---------------|----------|
| **Launch token / ERC-20 / `token=`** | The meme coin on Base | `0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3` | Identifies **which pool/sale**; API query param **`token=`** |
| **Fee-right units / ERC-1155 units** | Share of **trading fees** (1000 total per sale) | **628 units** = 62.8% of fee stream | **`balanceOf(wallet, hybridTokenId)`** on hybrid TMPR |
| **ERC-20 balance of launch token** | Coins user holds in wallet | **1.86M CTO** tokens | **NOT** fee-right units — **never** use this to infer units |

**Hard rule:** User says “I have ~600 units” → check **ERC-1155 on `0xD8e0639…`**. User holding **millions of CTO ERC-20** does **not** mean they have units (and vice versa).

### Addresses (do not swap)

| Address type | Meaning | CTO example |
|--------------|---------|-------------|
| **`token=` (API) / launch ERC-20** | Meme token contract | `0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3` |
| **`wallet=` (API)** | **Bankr injects** from linked connection — scans ERC-1155 units | Example: `0xA20A…` holds **628 units** |
| **Bankr custodial prefix `0x374d…`** | Often a **Bankr wallet** — valid **`wallet=`**, **never** **`token=`** | `0x374d91a5674fa7cf86e725093b5848b97e1e13b4` is a **wallet**, not the CTO token |
| **Hybrid TMPR collection** | Contract holding all hybrid sales + units | `0xD8e0639DfAa1cB2b9f9642EeCbd40b1e5a8b42A7` |
| **HybridShareMarketplace** | Where users **buy/sell units** | `0x90230B59…` — buy tx ≠ claim tx |

**Hard rule:** Putting a **wallet** in **`token=`** → API error `Bankr token-fees failed`. Swap params correctly.

### Linked wallet — user never pastes wallet

| Who provides `wallet=` | When |
|------------------------|------|
| **Bankr agent** | Always — from **X↔Bankr linked wallet** or DM session wallet |
| **User in tweet/DM** | **Never required** — Bankr scans that wallet for ERC-1155 units |

**Flow:**
1. User tweets `@bankrbot claim CTO unit fees 0xb6fB…` (token only — enough).
2. Bankr resolves **linked wallet** silently (same as tweet listing / sell autopilot).
3. Bankr calls **`GET …/hybrid-status?token=0xb6fB…&wallet=<linked>`** — proves **`unitsHeld`**, **`vaultHasFees`**, **`capTableComplete`**, returns pre-encoded **`claimFeesForToken`** calldata.
4. Bankr submits tx — **`claimFeesForToken` pays ALL unit holders** in one shot. Requester is the **gas signer**, not the sole beneficiary.

**Do not ask** “what’s your wallet?” or “paste wallet address” when X is linked to Bankr. **Do not** use Bankr **`collectFees`** — that only touches the caller’s wallet and returns 0 for unit holders.

**Optional `serial=N`:** disambiguates when user says “TMPR #12” and Doppler pool lookup fails. User still does **not** paste wallet.

### IDs (three different numbers)

| Term | Meaning | CTO example |
|------|---------|-------------|
| **`serial` / “TMPR #12”** | Human label — **12th** hybrid sale on site | UI shows **“TMPR #12 · Unit”** |
| **`hybridTokenId`** | Long on-chain id for ERC-721 + ERC-1155 | `82162810189150381448686192642592435479296266651479359308798582033011722422011` |
| **Small integer `12`** | **NOT** the on-chain id unless proven | **`tokenId=12` on hybrid TMPR is usually wrong** |

**Hard rule:** User says “TMPR #12” → API/query param **`serial=12`**, then read **`hybridTokenId`** from API or `positionOf` scan. **Never** pass `12` as `claimFeesForToken` tokenId without verification.

### User tweet phrases (what they mean — agent interprets)

| User says | Agent understands |
|-----------|-------------------|
| “claim CTO fee-right unit fees `0xb6fB…`” | **`token=0xb6fB…`** → hybrid claim for that sale |
| “TMP hybrid claim” / “TMP v53” | Load **`hybrid-claim-fees.md`**; use **`claimFeesForToken`**, not **`collectFees`** |
| “628 units” / “~600 units” | Confirm via linked wallet **`unitsHeld`** from API — user does not paste units |
| “$CTO” only | Ticker ambiguous — prefer **`0xb6fB…`** from thread; else one clarifying question |
| “paste contract address” (agent ask) | **Wrong** if user already gave **`0xb6fB…`** |
| “paste wallet address” (agent ask) | **Wrong** when X↔Bankr linked — use linked wallet silently |

### Transactions (buy vs claim)

| Tx type | What happened | What to look for on BaseScan |
|---------|---------------|------------------------------|
| **Share buy** | User **acquired units** | `HybridShareMarketplace`, **TransferSingle** ERC-1155, `quantity` e.g. **628** |
| **Hybrid fee claim** | Pull fees + **pay all unit holders** | **`HybridClaimRouter`**, events **`ClaimedHybridFees`** |
| **Bankr launch claim (WRONG for units)** | `collectFees` from user wallet | Fee manager **`Collect`** with **0/0** — **not** a successful unit claim |

**CTO reference buy tx:** [0x27ccf819…](https://basescan.org/tx/0x27ccf819214f2829858a1cb22decfd5c17aea7f7a79cfcc98dc495e856510180) — buyer `0xA20A…` received **628 units**; this is **not** claiming fees.

### Claim methods

| Method | When | Pays |
|--------|------|------|
| **`HybridClaimRouter.claimFeesForToken(tokenId, recipients, true)`** | Hybrid unit fee claim | **All** unit holders pro-rata |
| **Bankr `collectFees(poolId)` from user wallet** | Sole direct beneficiary (no units) | Caller only — **wrong for unit holders** |

---

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

### 0 — Status API (mandatory — proves claim + builds all-holder tx)

**Before any hybrid claim**, Bankr calls (linked wallet injected silently):

```text
GET https://www.tokenmarketplace.shop/api/claim/hybrid-status?token=0x…&wallet=<linkedWallet>&serial=12
```

| Response field | Use |
|----------------|-----|
| `proof.claimPaysAllHolders` | **true** — this tx pays everyone, not only requester |
| `proof.canSubmitTx` | **true** → submit `nextStep.data` |
| `proof.requesterHasUnits` | Confirms linked wallet holds units |
| `proof.holderCount` | How many wallets receive payout |
| `hybridTokenId` | On-chain id for `claimFeesForToken` (NOT the UI serial “#12”) |
| `unitsHeld` / `userSharePct` | Requester’s share from linked wallet scan |
| `phase` | `ready` \| `vault_empty` \| `no_units_in_wallet` \| `needs_holder_scan` \| `not_finalized` |
| `nextStep.data` | Pre-encoded **`claimFeesForToken(all holders)`** when indexer complete |
| `nextStep.agentMustNot` | Never Bankr `collectFees` from user wallet |

**Never ask the user for their wallet** on tweet/DM when X↔Bankr is linked — use the same linked wallet as sell/list autopilot.

**ERC-20 ≠ units:** **`1.86M CTO`** is the meme token. Fee-right **units** are **ERC-1155** on hybrid TMPR — scan linked wallet, not ERC-20 balance.

**Doppler `token-fees` may return empty** — Bankr passes **linked `wallet=`** + optional **`serial=`**; API scans on-chain.

---

### 1 — Detect hybrid unit holding

1. **Linked wallet** (Bankr custodial or EOA from X/DM session — not user-pasted).
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

### 4 — Submit claim tx (all holders — mandatory)

**Only submit when `GET /api/claim/hybrid-status` returns `proof.canSubmitTx === true`.**

Use **`nextStep.data` exactly** — **never** build calldata with `recipients: [linkedWallet]` when **`unitsHeld < 1000`**.

Before sign, verify **`nextStep.recipientCount >= 2`** (unless requester holds all 1000 units). See **`hybrid-claim-single-recipient-regression.md`**.

```text
HybridClaimRouter.claimFeesForToken(
  tokenId,
  recipients[],   // ALL current unit holders — sorted — from API only
  isBankrVenue
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
| “Collect fees for TMPR #12” | **`serial=12`** → resolve **`hybridTokenId`** via API — **not** on-chain id `12` |
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

**Fail the run** if bot says **“0 hybrid units”** on a claim request but **would find units** when user asks “how many erc1155?” — see **`hybrid-claim-zero-units-regression.md`**.

---

## Same thread: user confirmed units → claim immediately

If Bankr already replied **“you hold N ERC-1155 units… want me to run the claim now?”** and user says **yes** / **claim now**:

| Do | Don't |
|----|-------|
| Use **`hybridTokenId`** from that reply | Re-run Doppler “direct beneficiary” check |
| **`claimFeesForToken(all holders)`** | **`collectFees`** from user wallet |
| Report **N holders paid** + user's **pro-rata** share | Say “0 units” again |

User reply (copy-paste):

```text
@bankrbot yes — run the hybrid claim now for all TMPR #12 holders
```

## @bankr tweet execution (public X — same as DM)

**Rule:** Hybrid unit **claim on tweet** uses the **same tx path** as DM when the tweeter’s **X account is linked to a Bankr wallet** and **`bankr.tx.prepare`** is available.

| Step | Action |
|------|--------|
| 0 | Resolve **linked wallet** from X↔Bankr — **`GET /api/claim/hybrid-status?token=0x…&wallet=<linked>`** — never ask user to paste wallet |
| 1 | Read **`proof.claimPaysAllHolders`** + **`proof.canSubmitTx`** — if ready, **`bankr.tx.prepare`** `nextStep.data` |
| 2 | If `phase === needs_holder_scan` → expand holder scan, rebuild calldata, then submit |
| 3 | If `phase === vault_empty` → reply plainly: ran marketplace claim for **all holders**, **nothing to distribute** |
| 4 | Report **`ClaimedHybridFees`** + user **pro-rata** share + **`proof.holderCount`** (everyone paid) |

**Do not** reply “paste the contract address” when the tweet already includes **`0xb6fB…`**.

**Do not** reply “paste your wallet” when X↔Bankr is linked — scan linked wallet like sell/list autopilot.

**Do not** stop at “link the site” if linked wallet + prepare path exists.

### Tweet the user can post (copy-paste)

**This is all you need** (X linked to Bankr):

```text
@bankrbot claim all CTO fee-right unit fees for all holders 0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3
```

With serial if you say “TMPR #12”:

```text
@bankrbot claim hybrid unit fees for all holders — token 0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3 serial 12
```

**Do not paste your wallet** — Bankr reads it from your linked account. The tx pays **every** unit holder, not just you.

**Requires:** X account ↔ Bankr wallet linked (same as tweet listing). If not linked, Bankr can only guide — user connects wallet or uses site **Claim fees**.

### Tweet success reply (plain English)

> “Claimed **$CTO** trading fees for **N** unit holders in one tx. Your **~60%** share: **X WETH** + **Y CTO**. [BaseScan]”

(Serial label **TMPR #12** is fine in the reply — on-chain id comes from the API.)
