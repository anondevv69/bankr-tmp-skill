# Send / gift / airdrop fee-right units (1/1000 shares)

> **After Split into 1000** (or CTO finalize), holders own **ERC-1155 units** on hybrid TMPR `0xD8e0639DfAa1cB2b9f9642EeCbd40b1e5a8b42A7` — same `tokenId` as the receipt sale.
> **Not** 1000 separate ERC-721 NFTs. **Not** a share-market **sale** (use `share-market-list-autopilot.md` to sell for ETH).

**Site UI (EOA wallets):** https://www.tokenmarketplace.shop/profile → **Listed** → **Your fee-rights units** → **Send units (gift / airdrop)**.

---

## What users say (enough)

```text
@bankrbot send 50 units of my $t7 fee rights to 0xABC…
```

```text
Airdrop 10 shares each to these wallets: 0x… 0x… 0x…
```

```text
Transfer 1/1000 of my CTO to my other wallet
```

```text
Gift 100 fee-right units to 0x…
```

**Means:** move **ERC-1155 units** (1…1000) to another address — **no ETH payment**, not listing on the share book.

**Clarify once if needed:**

```text
That sends tradeable fee-right units (1/1000 of fees each), not the whole receipt NFT. If you haven’t split yet, say “split into 1000” first.
```

---

## Before you can send units

| State | Can send 1/1000 units? |
|-------|-------------------------|
| User holds **whole TMPR ERC-721** only (not split) | **No** — only **transfer whole NFT** (`transferFrom` on receipt) or **Split into 1000** first |
| **`unitsFinalized(tokenId)`** + `balanceOf(user, tokenId) > 0` | **Yes** — send any amount ≤ balance |
| Units listed on **share market** (in escrow) | **No** — **cancel listing** first (`share-market-cancel-autopilot.md`) |

Check balance:

```text
Hybrid TMPR.balanceOf(wallet, hybridTokenId)  →  units (0–1000)
Hybrid TMPR.unitsFinalized(hybridTokenId)       →  must be true
```

Resolve **`hybridTokenId`** from ticker via **`GET /api/claim/hybrid-status?token=<launch_0x>`** or **`GET /api/mint/status`** — **never** guess `tokenId=12` from “TMPR #12” (serial ≠ on-chain id). See **`hybrid-id-vocabulary.md`**.

---

## Path A — User on website (MetaMask / Rabby / WalletConnect)

Direct them with **full URL**:

```text
https://www.tokenmarketplace.shop/profile?tab=listed
```

Steps:

1. Connect the wallet that **holds the units**.
2. Open **Your fee-rights units (ERC-1155)** on the **Listed** tab.
3. **Send units (gift / airdrop)** on the sale card:
   - **One wallet:** recipient `0x…` + amount (1…balance).
   - **Batch / airdrop:** one line per wallet — `0xAddress, units` — or paste addresses only and check **Split equally**.
4. Confirm **`safeTransferFrom`** on hybrid TMPR (gas only).

**Forbidden:** telling them to use share market to “gift” (that’s a sale).

---

## Path B — Bankr agent (on-chain)

Use when user wants you to sign transfers from their **linked Bankr wallet** (custodial or EOA).

### B1 — Single transfer

```solidity
// hybrid TMPR 0xD8e0639…
safeTransferFrom(from, to, hybridTokenId, amount, "0x")
```

- **`from`** = linked wallet (must hold `amount`).
- **`to`** = recipient (not zero address).
- **`amount`** = whole units (1…1000), not wei.

Sign via Bankr **`prepare:transaction`** on Base (8453). **Do not** use raw `/wallet/submit` calldata.

### B2 — Batch airdrop (many recipients)

Prefer **one `safeTransferFrom` per recipient** (site batch UI does the same; max ~25 per session for gas).

Optional on-chain batch:

```solidity
safeBatchTransferFrom(from, to, [id,id,…], [amt,amt,…], "0x")
```

Same `id` repeated = one sale’s units to one wallet in one tx.

### B3 — Custodial scanner block

If Bankr blocks `safeTransferFrom`:

1. Retry up to **3×**.
2. Offer **transfer whole hybrid TMPR (ERC-721)** to user’s external EOA via `transferFrom`, then user sends units from **profile → Send units** (Path A).
3. See **`custodial-approve-block-retry.md`** / **`split-custodial-approve-block.md`** (same class of scanner issues).

---

## Path C — Transfer whole receipt NFT (before split)

User says **“transfer my NFT”** / **“send the fee rights NFT”** but **has not** finalized units:

```solidity
// ERC-721 on hybrid collection (same contract 0xD8e0639…)
transferFrom(owner, to, hybridTokenId)
// or safeTransferFrom(owner, to, hybridTokenId)
```

**Effect:** recipient owns **100%** of fee stream via the receipt (until they split). **Not** a 1/1000 unit transfer.

---

## NOT this flow

| User words | Wrong action | Right action |
|------------|--------------|--------------|
| Send units | `POST /api/list/dual` | `safeTransferFrom` on hybrid TMPR |
| Airdrop shares for ETH | Share market `list` | Gift transfer (this file) |
| Send 1/1000 | Fixed sale `buy` | Unit transfer or share **buy** |
| Mint 1000 NFTs | 1000× `mint` | **Split into 1000** (`fractionalize-autopilot.md`) |

---

## After transfer

- Recipient **`balanceOf`** increases; sender decreases.
- **Fee claims** follow **current unit holders** — new holder gets their % on next **`claimFeesForToken`** (`hybrid-claim-autopilot.md`).
- **No** X/Telegram listing alert (not a sale). Optional: user verifies on BaseScan → TMPR contract → **TransferSingle** events.

---

## Related

- **Split first:** `fractionalize-autopilot.md` · `split-1000-autopilot.md`
- **Sell units for ETH:** `share-market-list-autopilot.md` · `share-market-buy.md`
- **Past buys/sells (Sell 100%):** `profile-completed-sales.md`
- **Plain language:** `user-language.md` · `normal-talk-only.md`
