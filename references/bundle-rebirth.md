# Bundle & Rebirth — combine N fee streams, deploy one new Bankr token

> **Agents:** Read **`bundle-rebirth-playbook.md` first** — explain vs execute, TMPR scan before APIs, mint→confirm→bundle, and anti-stuck rules. This file is custody + API reference.

## What it is (plain English)

User has several tokens that each earn **trading fees**. They want one conversation:

> "Burn these 3 marketplace NFTs and merge into **$TEST** — use the fees for the first buy."

**What actually happens (agent runs the full chain — user does not need separate technical steps):**

1. Burn their **fee-receipt NFTs** (TMPRs) — not the launched ERC-20 coins themselves.
2. **Collect** built-up WETH from those fee streams (briefly through the bundle contract, then to **their wallet**).
3. **Turn off** fee rights on the old tokens forever (streams → dead wallet).
4. **Deploy** a new token on Bankr (Doppler on Base) from **their wallet**.
5. **Initial buy** — swap **their** WETH into the new token.

**Token Marketplace does not hold the user's coins.** The bundle contract only routes **who receives pool trading fees** until disband; WETH and the new launch are always **user-signed, user-funded**.

---

## Custody — who pays, whose wallet (mandatory for agents)

| Step | Whose wallet / contract | What is held |
|------|-------------------------|--------------|
| **createBundle** | **User** = bundle owner (`msg.sender`) | User approves TMPRs; contract becomes **fee beneficiary** on pools |
| **claimAll** | Bundle contract (temporary) | Sweeps **trading fees (WETH)** into contract balance |
| **disbandBundle** | **User** (`feesTo` = their address) | All WETH sent to **user**; old fee streams → **dead wallet** `0x000…dEaD` |
| **token-launches/deploy** | **User** (Bankr signs their key) | New Bankr/Doppler token |
| **Initial buy** | **User** | WETH from disband → swap into new token |

| Wrong to say | Say instead |
|--------------|-------------|
| "We hold your tokens" / "platform wallet buys in" | "Your wallet signs everything; fees go to you before the new launch." |
| "We merged the 3 coins into one token" | "We combined **fee rights**, launched a **new** token, and used **your** collected fees for the first buy." |
| "The 3 tokens are destroyed" | "The **3 old fee streams** are off forever; the **coins** still exist on Base." |

---

## One prompt → full orchestration (agent)

Treat as **one user intent**, multiple txs **you** chain. Full step-by-step: **`bundle-rebirth-playbook.md`**.

**Example user message:**

```text
Hey Bankr, burn these 3 token NFTs and merge into $TEST — use the fees from those for the initial buy.
```

**Short checklist:**

1. **TMPR wallet scan** for each token address (before APIs).
2. **Mint** missing receipts (Flow 1) → **wait for confirm**.
3. `POST /api/bundle/prepare` → approve(s) + `createBundle`.
4. `POST /api/bundle/claim` (optional repeat).
5. `POST /api/bundle/disband` — `feesTo` = **user wallet**.
6. `POST https://api.bankr.bot/token-launches/deploy` — user's `X-API-Key`.
7. Swap WETH → new token (initial buy).

**Do not stop after step 3** unless user only asked to bundle.  
**Do not** ask "confirm if you already minted" when user said **start minting / do all steps**.  
**Do not** stop on `token-fees` or fee-manager API errors if TMPRs or `positionOf` can resolve the tokens.

**Contract:** `FeeRightsBundleEscrow` `0x429Af4F73d9a254607890930848Be2E9f50dBb3F` (Base).  
**Env:** `BUNDLE_ESCROW_ADDRESS=0x429Af4F73d9a254607890930848Be2E9f50dBb3F`

---

## APIs (deployed)

| Piece | Status |
|-------|--------|
| `FeeRightsBundleEscrow` | Live `0x429Af4F73d9a254607890930848Be2E9f50dBb3F` |
| `GET /api/mint/status` | Live — **call before mint** (pending deposit / next step) |
| `POST /api/bankr-build-transfer` | Live — Doppler beneficiary → escrow |
| `POST /api/bundle/prepare` | Live |
| `POST /api/bundle/claim` | Live |
| `POST /api/bundle/disband` | Live — `feesTo` = user wallet |
| `POST /token-launches/deploy` (Bankr) | Live |

---

## Agent plain-English templates

**Explain only** (no execution): see playbook explain template.

**Start execute:**
> I'll combine your fee receipts, collect WETH to **your** wallet, turn off fees on those old tokens, launch **$TICKER** on Bankr, and use that WETH for the first buy. You sign each step.

**After complete:**
> Done — WETH is in your wallet, old fee streams are off, and **$TICKER** is live. First buy used the fees you collected.

---

## Contract mechanics (debugging only)

| Function | Who | What |
|----------|-----|------|
| `createBundle(tokenIds[], escrows[])` | User (owner) | Redeem TMPRs; contract = fee beneficiary |
| `claimAll(bundleId)` | Anyone | Fees → contract |
| `disbandBundle(bundleId, feesTo, streamTo)` | Owner only | WETH → `feesTo`; streams → `streamTo` (default dead) |

Max 20 positions per bundle. **Bankr/Doppler** in this version.

---

## Known gaps

- Several user-signed txs, one chat flow.
- **Mint required** before bundle if no TMPR in wallet.
- Clanker/Zora bundle support limited — resolve venue per token.
