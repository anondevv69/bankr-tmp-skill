# Regression: “use claimtokenfees” for Doppler/Bankr token (May 2026)

**Trigger (user tweet — natural language, correct):**

```text
@bankrbot claim fees for 0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3 for all
```

**Failed Bankr plan (do not repeat):**

> 1. Run claim autopilot first  
> 2. **Execute claimtokenfees after autopilot completes**

Step 2 is **forbidden** for hybrid unit holders. Autopilot **is** the claim — submit **`nextStep.data`** once, then **STOP**.

**Failed Bankr reply (do not repeat):**

> “Token … was deployed via **Bankr (Doppler)**, not Clanker. Use the **`claimtokenfees`** tool instead to claim fees for this token.”

That is **wrong** when the user holds **hybrid ERC-1155 units** (TMPR #12 · Unit) or the token has a **finalized hybrid share sale** on Token Marketplace.

---

## Why Bankr’s default routing fails

| Bankr assumes | Reality for CTO / hybrid sales |
|---------------|-------------------------------|
| Doppler launch → caller is **direct fee beneficiary** | User bought **units** — fees go through **`BankrSplitFeeCollector` vault** |
| **`claimtokenfees`** / **`collectFees`** pays **caller only** | **`claimFeesForToken`** pays **all** unit holders pro-rata |
| “Not Clanker” = use Bankr claim tool | **Irrelevant** — hybrid claim is **Token Marketplace**, not Clanker vs Bankr launch claim |
| No TMP skill / no hybrid-status | Skill **`hybrid-claim-autopilot.md`** runs **before** any Bankr native claim tool |

**Unit holders are never Doppler direct beneficiaries** — even though the launch token was deployed via Bankr/Doppler.

---

## Mandatory override (TMP skill loaded)

**On every “claim fees / collect fees” message:**

1. Load **`hybrid-claim-autopilot.md`** — **same priority as sell-list autopilot for list requests**.
2. **`GET /api/claim/hybrid-status?token=0x…&wallet=<linked>`** — **before** `claimtokenfees`, `collectFees`, `token-fees`, or Clanker reward lookup.
3. If API returns **`ok: true`** with hybrid sale data → submit **`nextStep.data`** → **DONE (no claimtokenfees)**
4. **Only if** hybrid-status says **no hybrid sale** / wallet is **sole direct beneficiary with zero units** → Bankr **`claimtokenfees`** is correct — **separate path, not step after hybrid**

**Never** tell user to switch tools based on “Doppler vs Clanker” without step 2.

---

## Correct behavior (CTO example)

```http
GET …/hybrid-status?token=0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3&wallet=<linked>&serial=12
```

| Field | Expected |
|-------|----------|
| `ok` | `true` |
| `unitsFinalized` | `true` |
| `unitsHeld` | e.g. `630` |
| `proof.holderCount` | e.g. `114` |
| `proof.canSubmitTx` | `true` |
| `nextStep.data` | Pre-encoded **`claimFeesForToken`** |

Submit tx → reply plain English with holder count + user share.

---

## Fail the run if

- Bot mentions **`claimtokenfees`** after user asked to claim fees for a token with a **hybrid sale**
- Bot says **“Doppler not Clanker”** or **“use claimtokenfees instead”** without **`GET /api/claim/hybrid-status`**
- Bot gives up with **“wasn't able to complete”** when API returns **`canSubmitTx: true`**

---

## User-facing reply (success)

> “Claimed **$CTO** trading fees for **114** unit holders. Your share: **X WETH** + **Y CTO**. [BaseScan]”

Not:

> “Use claimtokenfees — this is a Doppler token.”

---

## When `claimtokenfees` IS correct

| User situation | Path |
|----------------|------|
| **Sole** fee beneficiary on Doppler — **no** hybrid units, **no** TMPR in escrow | Bankr **`claimtokenfees`** / **`collectFees`** |
| **100% ERC-721 TMPR** still in escrow | **`redeemRights`** first — not claim |
| **Hybrid ERC-1155 units** | **`hybrid-claim-autopilot.md`** — **never** `claimtokenfees` |

---

## Cross-links

- **`hybrid-claim-autopilot.md`** — natural language claim flow
- **`hybrid-claim-zero-units-regression.md`** — “not a direct beneficiary”
- **`hybrid-claim-single-recipient-regression.md`** — single-recipient tx
