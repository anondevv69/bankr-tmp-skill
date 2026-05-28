# Stuck mint — pending deposit (Bankr Doppler)

**When:** User or Bankr already called `prepareDeposit` but mint did not finish. Common in bundle & rebirth when the agent re-submits prepare and txs revert with `DepositAlreadyPending`.

**Always call first:**

```http
GET https://www.tokenmarketplace.shop/api/mint/status?tokens=0xTOKEN1,0xTOKEN2&wallet=0xWALLET
```

or `POST /api/mint/status` with `{ "tokens": ["0x…"], "wallet": "0x…" }`.

---

## Phase → what to do (never skip)

| `phase` | Meaning | Next action | Do **not** |
|---------|---------|-------------|------------|
| `ready` | TMPR in user wallet (or user is owner) | `POST /api/bundle/prepare` with `owner` = user | `prepareDeposit` |
| `needs_transfer_tmpr` | TMPR minted on Bankr `0x374D…`, not user wallet | `safeTransferFrom` per mint/status `data` → then bundle | `bundle/prepare` before transfer |
| `needs_transfer` | `prepareDeposit` done; escrow has **0** shares | `POST /api/bankr-build-transfer` then `finalizeDeposit` | `prepareDeposit` again |
| `needs_finalize` | Escrow holds shares | `finalizeDeposit(poolId)` on `0x6238…` | `prepareDeposit` or dashboard “set escrow first” |
| `needs_prepare` | No pending; beneficiary has shares | Full Flow 1: prepare → transfer → finalize | — |
| `not_beneficiary` | Listed beneficiary has 0 shares | Stop for this token; fix wallet / ownership | Blind retries |

**Signer:** Steps after prepare must be sent from **`signerMustBe`** in the API response (often Bankr wallet `0x374D…`), not the user’s personal wallet unless it matches.

---

## kiTTen + t5 example (May 2026)

Both pools had `pendingSeller = 0x374D91a5674Fa7Cf86E725093b5848b97e1e13b4` and `phase = needs_transfer`.

**Wrong:** “Set fee recipient to marketplace escrow on the Doppler dashboard” before finalize.  
**Right:** Bankr runs `build-transfer-beneficiary` (current `0x374D…` → `0x6238…`) then `finalizeDeposit` **from `0x374D…`**.

---

## Plain English for users

> “Step 1 is already done for kiTTen and t5. I’m moving your fee slot to the marketplace escrow and minting the receipts next — no need to change anything on the dashboard.”

---

## Cross-links

- **tmp-bundle-rebirth** skill — `bundle-rebirth-playbook.md` Phase A0 + Phase B  
- `flows-reference.md` — Flow 1  
- **tmp-bundle-rebirth** — `bundle-rebirth.md` APIs
