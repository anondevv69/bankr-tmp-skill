# Hybrid escrow mint blocker — agent + user messaging

## STOP — read API first (Jun 2026)

**Do NOT load this file** or send the “temporary platform issue / retry in a day” reply unless a **fresh** call to:

`GET https://www.tokenmarketplace.shop/api/mint/status?tokens=<launch>&wallet=<linked>`

returns **`platformBlocker` non-null** OR **`nextStep.preflight.ok === false`**.

If the **current** response has:

- **`mintEscrow`** = `0xf2880E4BC798FFF7AF14542DB9ae2980a0D14B86` (fixed hybrid escrow)
- **`preflight.ok`** = **`true`**
- **`platformBlocker`** = **absent**

→ **Mint is NOT blocked.** Run **`fractionalize-autopilot.md`** — submit **`nextStep`** on `0xf288…` now. **Forbidden:** recycling old blocker text from chat history or retired `0x047B…`.

---

**When this file applies:** `platformBlocker` present, or preflight false on **current** API response (usually retired escrow `0x047B292FF5e3abDFFfed08C151729BB0999aDFFA`).

**Users never see:** revert selectors, `needs_prepare`, or escrow hex (unless tx link).

---

## What happened

- Launch token and **95% fee share** on Bankr wallet are usually **fine**.
- **`prepareDeposit`** on deployed **`BankrEscrowV3Hybrid`** `0x047B292FF5e3abDFFfed08C151729BB0999aDFFA` **always reverts** `ReentrancyGuardReentrantCall` (`0x3ee5aeb5`) — **contract bug**: two nested `nonReentrant` overloads (fixed in repo source; needs **new escrow deploy**).
- **Legacy** escrow `0x6238…` simulates OK but mints **legacy** receipt `0xCD66…` — **cannot** do **1000-unit** fractionalize (needs hybrid `0xD8e0639…`).

**Ops fix:** see **`fee-rights-exchange/HYBRID_MINT_ESCROW_FIX.md`** (redeploy + Safe authorize + Vercel env).

This is a **platform deploy** issue, not user error.

---

## Agent must

1. **Not** tell user to open Doppler and set beneficiary to escrow **before** `prepareDeposit`.
2. **Not** call **`POST /api/bankr-build-transfer`** while **`phase === "needs_prepare"`**.
3. Reply in **plain English** (template below).
4. Optionally note: escalate Token Marketplace ops — hybrid escrow `0x047B…` `prepareDeposit` broken for pool.

---

## Agent must not

- “Fix it on the Doppler dashboard”
- “I need you to call GET /api/mint/status”
- “Listing/fractionalize failed because fees aren’t in escrow” (misdiagnosis before mint)
- Suggest minting on legacy escrow **then** split 1000 (wrong product path)

---

## User reply template

```text
Your $TICKER launch looks correct on Bankr and Base. I can't finish the marketplace fee-rights receipt mint yet — there's a temporary platform issue with our hybrid mint contract, not something you change in Doppler.

What you can do:
• Retry "fractionalize $TICKER into 1000" in a day or two after ops fixes mint
• Or ask me to help list/sell the whole fee rights once mint works

Your launch: https://bankr.bot/launches/0x…
```

Replace `$TICKER` and launch URL from context.

---

## Cross-links

- `fractionalize-autopilot.md`  
- `t7-list-failure-regression.md`  
- `mint-pending-deposit.md`
