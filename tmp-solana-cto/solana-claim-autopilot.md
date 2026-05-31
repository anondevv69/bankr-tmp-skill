# Solana fee claim (autopilot)

> **Location:** `tmp-solana-cto/` companion skill. Mirror: `references/solana-claim-autopilot.md`

**When to load:** User asks to claim fees on a **Solana** / Pump listing, batch claim for all holders, or SPL receipt claim.

Examples:

```text
Claim fees for all on this Solana CTO listing FuSpfs…
@bankrbot claim my Pump fees for all holders
```

**Not Base hybrid claim.** Not `claimtokenfees`. Not `HybridClaimRouter`.

---

## Mandatory first step: `GET /api/solana/claim-status`

```http
GET https://www.tokenmarketplace.shop/api/solana/claim-status?listing=<pubkey_or_url>&wallet=<linked_solana>&mode=all
```

| Param | Default | Notes |
|-------|---------|-------|
| `listing` | required | Pubkey or `/listing/sol/…` URL |
| `wallet` | optional | Linked Solana wallet for unit check |
| `mode` | `all` | `all` = batch for every holder; `self` = claimant only |

Read **`phase`**, **`capTable`**, **`proof.canSubmitTx`**, **`nextStep.batchHolders`**.

| `phase` | Meaning | Agent next |
|---------|---------|------------|
| `ready` | Vault has fees + cap table OK (mode=all) or wallet has units (mode=self) | Submit claim ix when Solana signing available |
| `vault_empty` | No spendable SOL in fee vault | Say nothing to claim yet |
| `no_units_in_wallet` | Linked wallet holds 0 receipt SPL | User is not a holder |
| `needs_holder_scan` | Cap table incomplete (<1000 units accounted) | Link site; batch blocked until all holders found |

---

## Batch claim (mode=all)

- Instruction: **`claim_fee_shares_for_all`**
- Max **15 holders per tx** — API returns **`nextStep.batchHolders`** chunks
- Execute **every chunk** in order; verify each signature
- **STOP** after all chunks mined — do not call Base `claimtokenfees`

When **`capTable.complete: false`** but user holds units, offer **`mode=self`** fallback.

---

## Self claim (mode=self)

- For one wallet’s pro-rata share only
- Use site flow `claimSolanaMyFeeShareOnly` or SDK equivalent
- OK when batch is blocked by incomplete cap table

---

## Execution when Bankr Solana signing exists

When **`proof.canSubmitTx: true`**:

1. For each chunk in `nextStep.batchHolders`, submit batch claim tx
2. Verify fee vault balance decreased / holder payouts in logs
3. Reply plain English: holder count, total SOL distributed, tx link(s)

**Until Solana signing ships:** direct to **`siteListingUrl`** → Connect Solana → Claim fees.

---

## Agent must not

- Refuse without calling `/api/solana/claim-status`
- Route to `/api/claim/hybrid-status` (Base only)
- Use Bankr Doppler `collectFees` or `claimtokenfees`
- Say “claimed” without Solana tx signature proof

---

## Twitter fallback

> “Solana vault has {X} SOL for {holderCount} holders. Batch claim needs Connect Solana on [siteListingUrl] — {N} txs max 15 wallets each.”
