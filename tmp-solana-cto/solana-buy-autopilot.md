# Solana share buy (autopilot)

> **Location:** `tmp-solana-cto/` companion skill. Mirror: `references/solana-buy-autopilot.md`

**When to load:** User asks to buy on a Solana listing, purchase cheapest unit, or gives `/listing/sol/…` URL + optional password.

Examples:

```text
Buy the cheapest unit on https://www.tokenmarketplace.shop/listing/sol/FuSpfs… with password CTO
@bankrbot purchase 1 share on that Solana CTO listing password CTO
```

**Not Base.** Not `/api/claim/hybrid-status`. Not `bankr.tx.prepare`.

---

## Mandatory first step: `GET /api/solana/buy-status`

```http
GET https://www.tokenmarketplace.shop/api/solana/buy-status?listing=FuSpfsCRGRvRcJqMQwG8SyWw8yKuANZspQp6cQBRNJPN&wallet=<linked_solana>&password=CTO&quantity=1
```

Or pass full URL as `listing=` or `url=`.

Read **`phase`**, **`cheapestOffer`**, **`proof.canSubmitTx`**, **`nextStep`**.

| `phase` | Meaning | Agent next |
|---------|---------|------------|
| `ready` | Password OK (if required), offer exists | Submit `buyFeeReceiptShares` when Bankr Solana signing available |
| `needs_password` | Listing is password-gated | Ask user for password (DM preferred on X — do not echo password in public reply) |
| `wrong_password` | Hash mismatch | Passwords are **case-sensitive** (UTF-8 exact). Retry with correct casing; do not submit tx |
| `no_offers` | Empty share book | Link `siteListingUrl`; no buy possible |
| `claim_before_trading` | Unclaimed Pump fees in vault | Run **claim autopilot** first or tell user to claim on site |
| `insufficient_buyer_sol` | Linked wallet low on SOL | State `spendEstimate.shortfallLamports` in plain English |
| `quantity_exceeds_offer` | Ask exceeds listing qty | Lower quantity or pick another offer |
| `treasury_blocked` | Platform fee recipient under rent | Ops issue — link site; retry later |

---

## Execution when Bankr Solana signing exists

When **`proof.canSubmitTx: true`**:

1. Use **`nextStep.sdkMethod`**: `TakeoverListingsSDK.buyFeeReceiptShares`
2. Args from API: `listing`, `shareListing`, `seller`, `quantity`, `accessKeyBytes`
3. Signer = linked **Solana** wallet (`nextStep.accountsPartial.buyer`)
4. Verify tx on Solana explorer; reply with signature + units bought

**Until Solana signing ships:** execute steps 1–4 on the **website** only:

1. Open **`siteListingUrl`**
2. **Connect Solana** (not Connect Base)
3. Enter password if `cheapestOffer.passwordProtected`
4. Buy **`cheapestOffer`** quantity

---

## Agent must not

- Refuse without calling `/api/solana/buy-status`
- Use EVM/Base tools (`bankr.tx.prepare`, wagmi, HybridClaimRouter)
- Use `/api/claim/hybrid-status` for Solana URLs
- Echo user passwords in public tweet replies

---

## Twitter / short-turn fallback

If turn limit hits after status call:

> “Cheapest unit is {price} SOL on [siteListingUrl]. Password checks out — Connect Solana and tap Buy, or reply in DM to finish.”

Never: “Bankr agents cannot execute Solana purchases” **without** calling buy-status first.

---

## CTO example (May 2026)

```http
GET …/api/solana/buy-status?listing=FuSpfsCRGRvRcJqMQwG8SyWw8yKuANZspQp6cQBRNJPN&password=CTO&quantity=1
```

Expect `phase: ready`, `proof.passwordValid: true`, `siteListingUrl`. (`password=cto` lowercase → `wrong_password`; on-chain hash is **`CTO`**.)
