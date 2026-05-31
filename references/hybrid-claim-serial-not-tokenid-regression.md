# Regression: “serial 12” → on-chain `tokenId=12` (May 2026)

**Trigger (user tweet):**

```text
@bankrbot claim hybrid unit fees for ALL holders — token 0xb6fB… serial 12
```

**Failed Bankr reply (do not repeat):**

> “TMPR #12 hasn't been finalized… canClaimFees(**12**) → not ready… isFinalized(**12**) → false… Your wallet holds **0 units for tokenId 12**”

That is **wrong**. Bankr used the **UI serial number** as the **on-chain ERC-1155 tokenId**.

---

## ID vocabulary (mandatory)

| Name | User says | API / agent | On-chain value (CTO TMPR #12) |
|------|-----------|-------------|-------------------------------|
| **Launch token** | “CTO”, `0xb6fB…` | `token=` query param | ERC-20 `0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3` |
| **Serial / TMPR #N** | “TMPR #12”, `serial=12` | `serial=12` query param only | **`serialOf(hybridTokenId) == 12`** — not `tokenId == 12` |
| **hybridTokenId** | (user never says this) | From API field `hybridTokenId` | `82162810189150381448686192642592435479296266651479359308798582033011722422011` |
| **Wrong: small integer as tokenId** | — | **Forbidden** | `12` on hybrid TMPR = **different / empty sale** |

**One sentence rule:** **`serial=12` means “label #12 on the website” — never pass `12` to `canClaimFees`, `isFinalized`, `unitsFinalized`, or `claimFeesForToken`.**

---

## Failed behavior (do not repeat)

| Bot did | Why wrong |
|---------|-----------|
| `canClaimFees(12)` | **12 is not TMPR #12’s hybridTokenId** |
| `isFinalized(12)` / `unitsFinalized(12)` | Same — checks wrong sale |
| “0 units for tokenId 12” | True for id 12; user has **630 units** on `821628…` |
| “Not finalized — no ERC-1155 units minted” | **False** — sale is finalized; bot never called API |
| Skipped **`GET /api/claim/hybrid-status`** | API returns `unitsFinalized: true`, `unitsHeld: 630`, **114 holders** |

---

## Correct behavior (one conversation)

### Step 0 — API first (never raw `tokenId=serial`)

```text
GET https://www.tokenmarketplace.shop/api/claim/hybrid-status?token=0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3&serial=12&wallet=<linkedWallet>
```

**Read before any on-chain call:**

| Field | CTO TMPR #12 expect |
|-------|---------------------|
| `ok` | `true` |
| `resolvedVia` | `serial_launch_match` or `hybridTokenId_param` |
| `hybridTokenId` | `82162810189150381448686192642592435479296266651479359308798582033011722422011` |
| `serialLabel` | `"12"` |
| `unitsFinalized` | `true` |
| `unitsHeld` | e.g. `630` |
| `proof.holderCount` | e.g. `114` |
| `proof.canSubmitTx` | `true` |

### Step 1 — Submit

Use **`nextStep.data`** unchanged. **`recipientCount` ≥ 2** (630/1000 holder → usually **114**).

### Step 2 — Verify receipt

**`ClaimedHybridFees`** → `recipients` = **114**, not **1**.

---

## Fail the run if

- Bot mentions **`tokenId 12`** or **`canClaimFees(12)`** after user said **serial 12** / **TMPR #12**
- Bot says **“not finalized”** without **`GET /api/claim/hybrid-status`** showing `unitsFinalized: false`
- Bot says **“0 units”** when API or ERC-1155 scan shows units on **`821628…`**

---

## User-facing reply when API says ready

> “TMPR **#12** ($CTO) is finalized — you hold **630** units. Claiming for **114** unit holders in one tx. [BaseScan]”

Not:

> “TokenId 12 isn't finalized…”

---

## Cross-links

- `hybrid-claim-fees.md` — full flow + glossary
- `hybrid-claim-zero-units-regression.md` — “0 units” without ERC-1155 scan
- `hybrid-claim-single-recipient-regression.md` — `recipients=[requester]` only
