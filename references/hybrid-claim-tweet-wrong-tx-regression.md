# Regression: self-check passes but tweet runs collectFees (May 2026)

**Trigger tweet:**

```text
@bankrbot claim fees for 0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3 for all
```

**Bankr DM/self-check:** correctly answers **NO** to claimtokenfees after hybrid autopilot.

**Bankr tweet execution (WRONG):**

> claimed fees … **0.000000 WETH / 0.000000 CTO**  
> tx: [0xd21b0de7…](https://basescan.org/tx/0xd21b0de7c6edc022777d726c564edb22cf14a532973542cd7fb2fb67c6290617)

---

## What the tx actually did

| Field | Value |
|-------|--------|
| Signer | `0xA20Ae0A2b25dC24FBD33dC4b9811DB5c96761764` (user) |
| Path | Bankr fee manager **`0xBDF938…`** — **`Collect`** event |
| **NOT called** | **`HybridClaimRouter`** `0x0f5148A4CdDd74e011fbe516ADddBFd61Af2E8bb` |
| **Missing event** | **`ClaimedHybridFees`** with ~114 recipients |
| User-facing result | 0 WETH / 0 CTO — unit holder got nothing |

This is **`collectFees` / claimtokenfees`** (direct beneficiary path), **not** hybrid **`claimFeesForToken`** for all holders.

**Answering SELF-CHECK correctly in chat does not count as success.** The mined tx must match the skill path.

---

## Correct tx fingerprint (PASS)

After submit, receipt **must** include:

| Check | Expected |
|-------|----------|
| **To** (inner call) | **`HybridClaimRouter`** `0x0f5148…` |
| **Event** | **`ClaimedHybridFees`** |
| **Recipients** | **≥ 2** (CTO: ~114) |
| **NOT** | Sole **`Collect`** on `0xBDF938…` from user wallet with 0 payout |

If receipt shows **`Collect`** on fee manager only → **fail the run** — do not reply “claimed fees”.

---

## Correct execution (what should have happened)

1. **`GET /api/claim/hybrid-status?token=0xb6fB…&wallet=0xA20A…`**
2. **`proof.canSubmitTx === true`** → submit **`nextStep.data`**
3. Receipt: **`ClaimedHybridFees`** → report user **pro-rata** share + holder count

---

## Fail the run if

- Self-check says NO but tx is **`Collect`** on `0xBDF938…` without **`HybridClaimRouter`**
- Reply “0 WETH / 0 CTO claimed” for hybrid unit holder when vault had fees
- Tweet path skips **`GET hybrid-status`** while DM path answers skill questions correctly

---

## User-facing reply after wrong tx

> “That tx used the wrong claim path (direct fee-manager collect, not marketplace hybrid claim for all holders). Retrying with the Token Marketplace claim for all unit holders — or use **Claim fees** on [tokenmarketplace.shop](https://www.tokenmarketplace.shop).”

Do **not** say “no accumulated fees” when **`Collect`** pulled tokens but user received 0 — fees need **`claimFeesForToken`** distribution.

---

## Cross-links

- **`AGENT-ROUTING-CLAIM-FEES.md`** — POST-TX verification
- **`hybrid-claim-claimtokenfees-regression.md`**
- **`hybrid-claim-single-recipient-regression.md`**
