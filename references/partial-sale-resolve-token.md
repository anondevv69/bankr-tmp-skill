# Partial sale — resolve launch token when `token-fees` is empty

**User pattern:** “Sell 5% of `0x7942…` / **test1** for **0.005 ETH**”

**Correct flow:** **Partial sale** on **GroupBuyEscrowV2** — **not** `POST /api/list/dual` (sell 100% only).

**Prerequisite:** Seller must hold a **TMPR** for that launch’s fee position (mint first if not).

---

## Do not confuse balances

| Check | Meaning |
|-------|---------|
| User holds **ERC-20** balance of `test1` | They own **tokens**, not necessarily **fee rights** |
| `getShares(poolId, wallet) > 0` on fee manager | They can **mint TMPR** / are fee beneficiary |
| User holds **TMPR** | They can **`createPartialListing`** (after `approve` V2) |

**Never say** “you hold the token” as proof of fee rights. Say: “I need fee **shares** or your **TMPR**.”

---

## Resolution order (before asking user for Uniswap pool)

User gave **launch ERC-20** `0x794220dDcd649aeE829c74f00b39FE554D1A6b75` and/or ticker **test1**:

1. **`GET /public/doppler/token-fees/{tokenAddress}`**  
   - If **`poolId` + share** → Bankr Doppler → fee manager **`0xBDF938149ac6a781F94FAa0ed45E6A0e984c6544`**, escrow **`0x6238698212D91845cD1c004DE85951055bB5b292`**.

2. If **404 / not found** → **`GET /public/doppler/creator-fees/{userWallet}?days=90`**  
   - Find row where launched token = `0x7942…` (case-insensitive). Read **`poolId`**, token0/token1 from row.

3. **`get_token_launch_info`** for ticker **test1** / symbol from contract `symbol()`.

4. **TMPR scan (fast path for partial):**  
   - `balanceOf(user)` on TMPR `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e`  
   - For each owned `tokenId`, `positionOf(tokenId)` — if **`token0` or `token1`** equals launch `0x7942…` → **skip mint** → go to partial listing with that **tokenId**.

5. **Clanker:** authenticated `get-clanker-by-address` (or site `/api/clanker-get-token`) → `pool_address`, factory → **ClankerEscrowV4** mint path; partial finalize on mainnet needs redeployed escrow with `routeFeesTo` (see `all-escrow-options.md`).

6. **Only if 1–5 fail:** ask **one** question:  
   - “Do you already have a **Token Marketplace TMPR** for test1?” (OpenSea link / tokenId)  
   - OR “Was this launched on **Bankr** or **Clanker**?” + wallet that receives trading fees today.

**Do not** ask for “Uniswap v3 pool address” if user gave a **Bankr-style launch token** — resolve **`poolId`** via APIs above or Doppler/Bankr launch URL.
**Do not** stop just because `token-fees` is empty or a fee-manager query returns an error. That often means the launch is **unindexed** or the wrong data source is being used. Continue with creator-fees, TMPR scan, or launch info first.

---

## Partial listing args (once TMPR `tokenId` known)

| Field | Sell 5% for 0.005 ETH |
|-------|------------------------|
| `GroupBuyEscrowV2` | `0x869D11606B94de1206669C55f8628749bCBBFfD4` |
| `sellerKeepsBps` | **9500** (keep 95%, sell 5%) |
| `priceWei` | **5000000000000000** (0.005 × 1e18) |
| `venueType` | **1** (Bankr) |
| `rightsEscrow` | `0x6238698212D91845cD1c004DE85951055bB5b292` |
| Pre-tx | `approve(V2, tokenId)` on TMPR |

**Site:** https://www.tokenmarketplace.shop → **Group buy** → **Partial sale**.

---

## Real Bankr failure (QA)

```text
User: sell 5% of 0x794220… test1 for 0.005 eth
Bankr: correct — partial + TMPR first
Bankr: token-fees missing → asked TMPR? clanker? uniswap pool?
```

**Better:** run steps 2–4 silently; distinguish ERC-20 balance vs `getShares`; if no fee data, say test1 is **not indexed** on Bankr Doppler API yet or the token is not in the expected fee manager, and ask for the **TMPR tokenId** or a launch link before giving up.

**test1 (`0x794220…`) note:** `token-fees` returns **not found** — treat as **unindexed** until creator-fees or on-chain `getShares` proves otherwise.

---

## What the user should say (normal talk)

```text
Sell 5% of test1 for 0.005 eth. Keep the rest for me.
```

**Agent (internal):** `sellerKeepsBps=9500`, `priceWei=5e15`, GroupBuyEscrowV2, scan TMPR / creator-fees — see **`normal-talk-only.md`**. Do not echo bps or contract names to the user.
