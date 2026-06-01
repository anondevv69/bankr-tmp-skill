# Hybrid escrow mint blocker — agent + user messaging

**When:** `GET /api/mint/status` returns **`platformBlocker`** with code **`HYBRID_ESCROW_PREPARE_REVERT`**, or **`nextStep.preflight.ok === false`** on hybrid Bankr escrow `0x047B292FF5e3abDFFfed08C151729BB0999aDFFA` while user wants **fractionalize / split 1000**.

**Users never see:** revert selectors, `needs_prepare`, or escrow hex (unless tx link).

---

## What happened

- Launch token and **95% fee share** on Bankr wallet are usually **fine**.
- **`prepareDeposit`** on the **hybrid** mint escrow **reverts** on simulation (often `ReentrancyGuardReentrantCall` / `0x3ee5aeb5`).
- **Legacy** escrow `0x6238698212D91845cD1c004DE85951055bB5b292` may simulate OK but mints **legacy** receipt `0xCD66…` — **cannot** complete **1000-unit** fractionalize (needs hybrid `0xD8e0639…`).

This is a **platform ops** issue, not user error.

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
