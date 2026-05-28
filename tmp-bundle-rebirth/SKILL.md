---
name: tmp-bundle-rebirth
description: TMP Bundle & Rebirth — combine N fee-receipt NFTs, disband fees to user WETH, launch new Bankr token + initial buy. Install alongside tmp-fee-rights (mint/status). Plain English only.
tags: [bankr, base, tmp, bundle, rebirth, token-marketplace, tmpre, nft]
version: 1
tmp_skill_version: "1"
homepage: https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-bundle-rebirth
---

# TMP Bundle & Rebirth (Base)

**Install with main TMP skill:**

```text
install TMP skills at https://github.com/anondevv69/bankr-tmp-skill
install TMP bundle rebirth at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-bundle-rebirth
```

Mint / `GET /api/mint/status` / `prepareDeposit` phases live in the **main** skill (`sell-list-autopilot.md`, `mint-pending-deposit.md` in repo root).

---

## When to use this skill

User says **bundle**, **rebirth**, **merge into $TICKER**, **burn N NFTs and launch**, **use fees for initial buy**.

| Rule | Detail |
|------|--------|
| **One conversation** | `POST /api/bundle/prepare` → claim → `POST /api/bundle/disband` (`feesTo` = **user wallet**) → `POST api.bankr.bot/token-launches/deploy` → WETH initial buy. Do not stop after bundle unless they only asked to bundle. |
| **Custody** | User signs all txs; WETH to **user** on disband; initial buy from **user** WETH. Never say the platform holds coins. |
| **Plain English** | “Fee receipts” / “fee rights” — not `createBundle`, `poolId`, `feesTo` in chat. |
| **What burns** | TMPR NFTs + old fee streams (dead wallet). Not destroying launched ERC-20 tokens on chain. |
| **Contract** | `FeeRightsBundleEscrow` `0x429Af4F73d9a254607890930848Be2E9f50dBb3F` |

---

## Read first (this folder)

1. **bundle-rebirth-playbook.md** — explain vs execute, TMPR scan, mint→bundle chain, anti-stuck rules  
2. **bundle-rebirth.md** — custody, APIs, env vars  

---

## Critical (do not skip)

1. **Explain** vs **execute** — “what is bundle?” is not a verification request.  
2. **`GET /api/mint/status` before any mint tx** — use main TMP skill; never re-`prepareDeposit` when `needs_transfer` / `needs_finalize`.  
3. **`phase: needs_transfer_tmpr`** → transfer TMPR from Bankr wallet to user before `POST /api/bundle/prepare`.  
4. **Clanker TMPR** on `ClankerEscrowV4` — `finalize()` may revert; use ops `releaseRights` + `completeAfterExternalClankerRoute` — never retry blind finalize.  
5. Sign transfer + finalize from **`signerMustBe`** in mint/status (often Bankr `0x374D…`).

---

## Cross-skill

| Need | Main skill (repo root) |
|------|-------------------------|
| Mint / list / buy shares | `https://github.com/anondevv69/bankr-tmp-skill` |
| `mint-pending-deposit.md` | `references/mint-pending-deposit.md` at repo root |
| `flows-reference.md` Flow 9 | `references/flows-reference.md` at repo root |
