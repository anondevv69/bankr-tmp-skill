# Regression: “0 hybrid units” on claim — then finds 630 on ERC-1155 check (May 2026)

**Trigger (user / @TokenMkp tweet):**

```text
@bankrbot claim all CTO fee-right unit fees for 0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3
```

Follow-up that **proves** units exist:

```text
can you please check how many erc1155 i have?
```

**Agent must NOT treat these as different products.** Same wallet, same collection — claim intent must run the **same ERC-1155 scan** before any “0 units” reply.

---

## Failed behavior (do not repeat)

| Bot said | Why wrong |
|----------|-----------|
| “your wallet doesn't hold any hybrid fee-right units” | **Never said this without** scanning hybrid TMPR `0xD8e0639…` ERC-1155 on the **linked wallet** |
| “direct beneficiary status: not a fee recipient” | Wrong path — **unit holders are not Doppler direct beneficiaries** |
| “current fee recipient: GroupBuyEscrow V6 `0x56bd…`” | **Misleading** — GBE finalized the split; **fee claims for units** go via **`BankrSplitFeeCollector` + `HybridClaimRouter.claimFeesForToken`**, not GBE |
| “did you buy shares on the hybrid marketplace?” after user already claimed units | User **does** hold units — bot used **launch-claim** logic instead of **hybrid unit** logic |
| Suggests “redeem legacy ERC-721 TMPR first” | User holds **ERC-1155 units** (TMPR #12 · Unit), not a legacy receipt |

---

## Correct behavior (one conversation)

**Order matters — always:**

1. Resolve **linked Bankr wallet** (never ask user to paste it on tweet).
2. **Scan hybrid TMPR** `0xD8e0639DfAa1cB2b9f9642EeCbd40b1e5a8b42A7` for ERC-1155 — same as answering “how many erc1155 do I have?”
   - Alchemy `getNFTsForOwner` **or**
   - `GET /api/claim/hybrid-status?token=0xb6fB…&wallet=<linked>&serial=12`
3. If **`unitsHeld > 0`** (e.g. **630**) → **must** use **`HybridClaimRouter.claimFeesForToken`** — pays **all** holders in one tx.
4. Read **`proof.claimPaysAllHolders`** + submit **`nextStep.data`** via **`bankr.tx.prepare`** when `proof.canSubmitTx`.
5. **Forbidden:** Bankr fee-manager **`collectFees`** from user wallet for unit holders.

**If step 2 finds units but step 4 API fails:** use **`hybridTokenId`** from the scan (e.g. `82162810189150381448686192642592435479296266651479359308798582033011722422011`) and build holder list — do **not** revert to “0 units”.

---

## User-facing reply (after scan finds units)

> “You hold **630 units** (~63%) of **TMPR #12 · $CTO**. Running the marketplace claim for **all unit holders** now — one transaction pays everyone proportionally. [BaseScan link]”

Not:

> “You don't hold any hybrid units… check if you bought shares…”

---

## When user already confirmed units in the same thread

If the bot just said “you hold 630 ERC-1155 units… want me to run the claim now?” and user says **yes**:

- **Execute immediately** — do not re-run Doppler beneficiary checks.
- Use known **`hybridTokenId`** from the prior message.
- **`claimFeesForToken(all holders)`** — not **`collectFees`**.

---

## Cross-links

- `hybrid-claim-fees.md` — full claim flow + glossary  
- `share-market-buy.md` — how units are acquired  
- `t7-list-failure-regression.md` — same pattern (wrong path → handoff instead of skill)
