# Send / transfer / airdrop units — autopilot entry

Read **`references/transfer-units-autopilot.md`** (full spec).

**Site:** https://www.tokenmarketplace.shop/profile?tab=nfts → **Send shares** → One wallet or **Batch / airdrop** (≤25 recipients, per-line `0x…, amount` or equal split).

**One line:** gift or **batch airdrop** 1/1000 units → **`balanceOf`** → sum amounts ≤ balance → **`safeTransferFrom` per wallet** (or site UI).
