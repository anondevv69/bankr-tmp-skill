# Send / gift / airdrop fee-right units (1/1000 shares)

> **After Split into 1000** (or CTO finalize), holders own **ERC-1155 units** on hybrid TMPR `0xD8e0639DfAa1cB2b9f9642EeCbd40b1e5a8b42A7` — same `tokenId` as the receipt sale.
> **Not** 1000 separate ERC-721 NFTs. **Not** a share-market **sale** (use `share-market-list-autopilot.md` to sell for ETH).

**Site UI (EOA wallets):** https://www.tokenmarketplace.shop/profile → **NFTs** tab → **Your fee-rights units** → **Send shares** on the sale card.

---

## What users say (enough)

```text
@bankrbot send 50 units of my $t7 fee rights to 0xABC…
```

```text
Airdrop 10 shares each to these wallets: 0x… 0x… 0x…
```

```text
Batch send 5 units to 0x…, 20 to 0x…, rest split equally to 0x… 0x… 0x…
```

```text
Transfer 1/1000 of my CTO to my other wallet
```

**Means:** move **ERC-1155 units** (1…1000) to one or many addresses — **no ETH payment**, not listing on the share book.

**Clarify once if needed:**

```text
That sends tradeable fee-right units (1/1000 of fees each), not the whole receipt NFT. If you haven’t split yet, say “split into 1000” first.
```

---

## Before you can send units

| State | Can send 1/1000 units? |
|-------|-------------------------|
| User holds **whole TMPR ERC-721** only (not split) | **No** — **transfer whole NFT** (`transferFrom` on receipt) or **Split into 1000** first |
| **`unitsFinalized(tokenId)`** + `balanceOf(user, tokenId) > 0` | **Yes** — send any amount ≤ balance |
| Units listed on **share market** (in escrow) | **No** — **cancel listing** first (`share-market-cancel-autopilot.md`) |

### Wallet balance (always check)

```text
Hybrid TMPR.balanceOf(wallet, hybridTokenId)  →  units held (0–1000)
Hybrid TMPR.unitsFinalized(hybridTokenId)     →  must be true
```

Report clearly: **“You hold 334 / 1000 units on sale #&lt;hybridTokenId&gt;.”**

Resolve **`hybridTokenId`** from ticker via **`GET /api/claim/hybrid-status?token=<launch_0x>&wallet=<linked>`** or **`GET /api/mint/status`** — **never** guess `tokenId=12` from “TMPR #12” (serial ≠ on-chain id). See **`hybrid-id-vocabulary.md`**.

---

## Path A — User on website (MetaMask / Rabby / WalletConnect)

```text
https://www.tokenmarketplace.shop/profile?tab=nfts
```

(`?tab=listed` still works.)

On each **Your fee-rights units** card:

| Button | Action |
|--------|--------|
| **Listings** | Share market page for that sale |
| **Claim fees** | Distribute fees to all unit holders |
| **List shares** | List units for ETH on share market |
| **Send shares** | Gift / airdrop units (this flow) |

### Send shares — two modes

1. **One wallet** — recipient `0x…` + units (1…your balance).
2. **Batch / airdrop** — textarea, one wallet per line:

| Format | Example |
|--------|---------|
| **Per-wallet amount** | `0xABC…, 10` then `0xDEF…, 25` |
| **Equal split** | Paste addresses only (one per line), enable **Split equally** — site divides your **full balance** across all lines (remainder to first wallets) |

**Site limits (match when guiding users):**

| Rule | Value |
|------|--------|
| Max recipients per batch run | **25** (gas / wallet confirmations) |
| Max lines parsed | 80 (UI still caps at 25 per send) |
| Total units per batch | ≤ `balanceOf` (cannot send more than you hold) |
| Sender in recipient list | **Rejected** |
| Tx pattern | **One `safeTransferFrom` per recipient** — user confirms **N times** for N wallets |

After send: show **total units** and **recipient count**; suggest BaseScan **TransferSingle** on `0xD8e0639…`.

**Forbidden:** share market to “gift”; dual list; selling launch ERC-20.

---

## Path B — Bankr agent (on-chain)

Use when user wants you to sign transfers from their **linked Bankr wallet**.

### B0 — Preflight (single or batch)

1. Resolve **`hybridTokenId`** + **`balanceOf(sender, hybridTokenId)`**.
2. Parse recipients (see **Batch parsing** below).
3. **`sum(amounts) ≤ balance`**; each amount ≥ 1; **≤ 25 recipients** per agent session (same as site).
4. Tell user: **“Sending X units to N wallets — N wallet confirmations.”**

### B1 — Single transfer

```solidity
// hybrid TMPR 0xD8e0639…
safeTransferFrom(from, to, hybridTokenId, amount, "0x")
```

- **`from`** = linked wallet (must hold `amount`).
- **`to`** = recipient (not zero, not `from`).
- **`amount`** = whole units (1…1000), not wei.

Sign via Bankr **`prepare:transaction`** on Base (8453). **Do not** use raw `/wallet/submit` calldata.

### B2 — Batch airdrop (many recipients)

**Default (same as site):** loop **`safeTransferFrom`** — one tx per recipient.

```text
Transfer 1 of 8 — confirm in wallet…
Transfer 2 of 8 — confirm in wallet…
```

**Parsing user lists:**

| User intent | Agent logic |
|-------------|-------------|
| “10 each to 0xA, 0xB, 0xC” | amounts `[10,10,10]` — verify `30 ≤ balance` |
| “Split my 334 units equally across these 5 wallets” | `334 / 5` base + remainder to first wallets (same as site) |
| “Airdrop to:” + pasted addresses | Ask for **per-wallet amount** OR confirm **equal split of full balance** |
| Mixed lines `0x…, 5` | Sum all amounts; fail if `sum > balance` |

**Hard limits:**

| Limit | Value |
|-------|--------|
| Recipients per session | **25** — if more, do first 25 then offer second batch or site UI |
| Minimum per recipient | **1** unit |
| Duplicate addresses | Merge amounts or reject — do not double-send |

**Optional (advanced):** single tx **`safeBatchTransferFrom(from, to, [id,id,…], [amt,amt,…], "0x")`** with same `id` repeated — only if user explicitly wants one confirmation and wallet supports it. Site uses per-recipient txs; prefer that for consistency.

### B3 — Custodial scanner block

If Bankr blocks `safeTransferFrom`:

1. Retry up to **3×**.
2. Offer **transfer whole hybrid TMPR (ERC-721)** to user’s external EOA via `transferFrom`, then **profile → NFTs → Send shares** (Path A).
3. **`custodial-approve-block-retry.md`** / **`split-custodial-approve-block.md`**.

---

## Path C — Transfer whole receipt NFT (before split)

User says **“transfer my NFT”** but **has not** finalized units:

```solidity
transferFrom(owner, to, hybridTokenId)   // ERC-721 on 0xD8e0639…
```

**Effect:** recipient owns **100%** until they split. **Not** a 1/1000 unit transfer.

---

## Batch parsing reference (agents + site)

**Per-line (amount required unless equal split):**

```text
0x742d35Cc6634C0532925a3b8D3C9c4e3D2e7560, 10
0x8ba1f109daf85041ec7b19ea97704da2e61000000, 25
```

**Equal split (addresses only, one per line):**

```text
0x742d35Cc6634C0532925a3b8D3C9c4e3D2e7560
0x8ba1f109daf85041ec7b19ea97704da2e61000000
```

Requires **`balance ≥ number of addresses`** (at least 1 unit each).

---

## NOT this flow

| User words | Wrong action | Right action |
|------------|--------------|--------------|
| Send / airdrop units | `POST /api/list/dual` | `safeTransferFrom` (loop for batch) |
| Airdrop for ETH | Share market `list` | Gift transfer (this file) |
| Send 1/1000 | Fixed sale `buy` | Unit transfer or share **buy** |
| Mint 1000 NFTs | 1000× `mint` | **Split into 1000** |

---

## After transfer

- Recipient **`balanceOf`** increases; sender decreases.
- **Fee claims** follow **current unit holders** — `hybrid-claim-autopilot.md`.
- **No** listing/sale X alert. Optional BaseScan **TransferSingle**.

---

## Related

- **Split first:** `fractionalize-autopilot.md` · `split-1000-autopilot.md`
- **Sell for ETH:** `share-market-list-autopilot.md`
- **Sale history:** `profile-completed-sales.md` · `/profile?tab=completed`
- **Plain language:** `user-language.md` · `normal-talk-only.md`
