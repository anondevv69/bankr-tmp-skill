# Send / gift / airdrop Solana SPL receipt units

**Site UI (Phantom):** https://www.tokenmarketplace.shop → Profile → **NFTs** (Solana section) or listing page → **Send units**.

Same idea as Base **Send shares** — gift SPL fee-receipt units (0 decimals, 1 token = 1 unit). **Not** a share-book sale.

---

## Limits (match site)

| Rule | Value |
|------|--------|
| Max recipients per batch | **25** |
| Wallets per Phantom tx | **Up to 25 in one tx** when simulation passes; else ~10 per tx |
| Total units | ≤ SPL balance; cancel share listings if units are in escrow |

**Formats:** one address + amount, or textarea `base58, units` per line, or **equal split** across pasted addresses.

---

## Bankr agent

**No custodial Solana send today.** Bankr cannot sign SPL transfers for the user.

1. Confirm listing + holder balance on site (user connects Phantom).
2. Reply: open profile **NFTs** or listing → **Send units** → **Batch / airdrop** → paste wallets → confirm (1–3 Phantom txs for ≤25 wallets).

Do **not** promise `@bankrbot` will execute SPL gifts on-chain until Bankr ships Solana signing.

---

## Not supported

- Scraping X/Farcaster comments for wallets (see main skill `transfer-units-autopilot.md` for Base wallet lists only).
- >25 recipients in one UI run — run again or export CSV in chunks.
