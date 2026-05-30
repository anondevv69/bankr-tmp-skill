# Regression: claimFeesForToken with recipients=[requester only] (May 2026)

**On-chain evidence:** [0xd8662d5d…](https://basescan.org/tx/0xd8662d5d7f816041f80dc432e87d15cd9f8b674266ae41f8d14b1742d9b352f1)

- **`ClaimedHybridFees`** events: **`recipients: 1`**
- Calldata: `recipients = [0xA20Ae0A2…]` only
- Requester held **630 / 1000** units (~63%)
- ~**37%** of pulled fees **stranded** in hybrid TMPR vault (other holders never paid)

**Trigger:** User says “claim for all holders” / “yes claim now” after Bankr confirmed **630 ERC-1155 units**.

---

## Failed behavior (do not repeat)

| Bot did | Why wrong |
|---------|-----------|
| Built `claimFeesForToken(tokenId, [msg.sender], true)` | **Only pays listed addresses** — co-holders get nothing |
| Said “claim for all holders” but submitted **1 recipient** | Misleading; on-chain proof contradicts reply |
| Did not call **`GET /api/claim/hybrid-status`** before submit | API returns full `recipients[]` + **`proof.canSubmitTx`** |
| Manually assembled calldata | **Forbidden** — use **`nextStep.data`** only when **`recipientCount >= 2`** (unless requester holds all 1000 units) |

---

## Correct behavior

1. **`GET /api/claim/hybrid-status?token=0xb6fB…&wallet=<linked>&serial=12`**
2. Wait until **`proof.canSubmitTx === true`** and **`nextStep.recipientCount >= 2`** (when **`unitsHeld < 1000`**)
3. Submit **`nextStep.data`** unchanged via **`bankr.tx.prepare`**
4. Verify receipt: **`ClaimedHybridFees`** **`recipients` ≥ 2** (for partial unit holders like 630/1000)
5. Reply: “Paid **N wallets** in one tx. Your share: …”

**If `phase === needs_holder_scan` or `submitForbidden`:** do **not** submit. Expand holder scan or use site **Claim fees** — never fall back to `[requester]`.

---

## Preflight decode (agent)

Before sign, decode `claimFeesForToken` arg 2 (`address[] recipients`):

- **630 units held** → **recipients.length must be ≥ 2**
- **1000 units held** → **recipients.length may be 1** (sole owner)

**Fail the run** if `recipients.length === 1` and requester **`unitsHeld < 1000`**.

---

## Cross-links

- `hybrid-claim-fees.md` — full flow  
- `hybrid-claim-zero-units-regression.md` — “0 units” without ERC-1155 scan
