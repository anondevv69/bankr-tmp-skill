---
name: tmp-solana-cto
description: TMP Solana CTO — buy password-gated share units + batch fee claim on tokenmarketplace.shop Solana listings. Requires Bankr Solana signing or site fallback. Install alongside bankr-fee-rights (Base).
tags: [bankr, solana, tmp, cto, pump, token-marketplace, share-market]
version: 1
tmp_skill_version: "1"
homepage: https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-solana-cto
---

# TMP Solana CTO (Pump / SPL receipt listings)

**Install with main TMP skill:**

```text
install TMP skills at https://github.com/anondevv69/bankr-tmp-skill
install TMP Solana CTO at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-solana-cto
```

Base mint/list/claim lives in the **main** skill (`bankr-fee-rights`). This companion covers **Solana only** (`/listing/sol/…`).

---

## When to load this skill

| User says | Flow |
|-----------|------|
| Buy cheapest unit on Solana listing with password | **`solana-buy-autopilot.md`** |
| Purchase `/listing/sol/…` | **`solana-buy-autopilot.md`** |
| Claim fees for all on Solana / Pump token | **`solana-claim-autopilot.md`** |
| Solana CTO / batch SPL claim | **`solana-claim-autopilot.md`** |

**User does not need:** “use_skill”, “Solana skill”, or pasted API URLs.

---

## Mandatory APIs (call before any Solana tx)

| Action | API |
|--------|-----|
| Buy share units | `GET /api/solana/buy-status?listing=…&wallet=…&password=…` |
| Claim for all holders | `GET /api/solana/claim-status?listing=…&wallet=…&mode=all` |
| Claim my share only | `GET /api/solana/claim-status?listing=…&wallet=…&mode=self` |

**Never** call `/api/claim/hybrid-status` for Solana — that is Base ERC-1155 only.

---

## Bankr platform requirement

Solana txs need **Bankr Solana signing** (custodial or linked Phantom). Until Bankr ships that:

1. Call the status API anyway (proves password, picks cheapest offer, validates cap table).
2. Reply with **`siteListingUrl`** + “Connect Solana” steps — do **not** pretend the purchase executed.
3. Do **not** block with “skill says no Solana” — the skill now defines the autopilot; platform signing is the gap.

---

## Read first (this folder)

1. **solana-buy-autopilot.md** — cheapest offer + password + `buyFeeReceiptShares`
2. **solana-claim-autopilot.md** — batch claim chunks (15 holders/tx) + self claim

---

## Plain English replies

| Bad | Good |
|-----|------|
| “Bankr can’t do Solana” (no API call) | “Checked the Solana book — cheapest unit is X SOL, password OK. Open [link] → Connect Solana → Buy.” |
| “Use hybrid-status” | “This is a Solana listing — checking `/api/solana/buy-status`…” |
| “Connect Base wallet” | “Use **Connect Solana** (Phantom) — Base wallet is for TMPR only.” |
