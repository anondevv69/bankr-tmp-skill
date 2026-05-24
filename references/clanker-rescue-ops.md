# Clanker Legacy Escrow Rescue — Ops Playbook

Some listings use an old ClankerEscrowV4 deployment (`0x3546A98C09fc5a3E162d510DB331C4dcEdB6EADa`) that lacks the `routeFeesTo` function. When these listings are **fully funded**, `finalize()` always reverts. The two-step rescue is:

1. **Seller** (via UI): clicks "Step 1 — Create fee split" → creates a 0xSplits contract → UI shows the split address and enters "awaiting ops" state.
2. **Platform ops**: calls `releaseRights` on ClankerEscrowV4 with the split address → this burns the TMPR and routes fees to the split.
3. **Seller** (via UI): clicks "Complete sale" → calls `completeAfterExternalClankerRoute(listingId, splitAddr)` → marks listing finalized + pays seller.

---

## Contracts

| Contract | Address |
|---|---|
| GroupBuyEscrow (GBE) | `0x869D11606B94de1206669C55f8628749bCBBFfD4` |
| ClankerEscrowV4 (legacy) | `0x3546A98C09fc5a3E162d510DB331C4dcEdB6EADa` |
| TMPR Collection | `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e` |
| 0xSplits PushSplitFactory | `0x80f1B766817D04870f115fEBbcCADF8DBF75E017` |

---

## Live Funded Listings Awaiting Rescue (as of May 2026)

All TMPRs are currently owned by GBE (`0x869D…`). Splits have been created; the missing step is `releaseRights`.

### Listing #1 — TMPR #47601941… (Partial sale, 5% sold)

- **Seller**: `0xbFF8c6C34f1EFacF6844350dE907Cca6F07C76b8`
- **Contributor**: `0x9e981B5F7563E3D37d6bC09f6208547bd51038cf` (paid 0.005 ETH for 5%)
- **TMPR tokenId**: `47601941977880563014925812544141001751967682057589907382585286957946594741498`
- **Split address**: `0x987600BF422DaAd35D0Dfb371CFF61aCf57572c09` ← use this with `releaseRights`
- **`sellerKeepsBps`**: 9500

### Listing #2 — TMPR #101852217… (Group buy, 100% sold)

- **Seller**: `0x9e981B5F7563E3D37d6bC09f6208547bd51038cf`
- **Contributor**: `0xbFF8c6C34f1EFacF6844350dE907Cca6F07C76b8` (paid 0.0005 ETH, 100%)
- **TMPR tokenId**: `101852217748207614459152602299262829433430965686871353240207219104103413671987`
- **Split address**: `0xabe278941bdd298957afabff377b139d89e7f060` ← use this with `releaseRights`
- **`sellerKeepsBps`**: 0

### Listing #3 — TMPR #109413451… (Partial sale, 5% sold)

- **Seller**: `0xbFF8c6C34f1EFacF6844350dE907Cca6F07C76b8`
- **Contributor**: `0x9e981B5F7563E3D37d6bC09f6208547bd51038cf` (paid 0.00005 ETH for 5%)
- **TMPR tokenId**: `109413451023983481657860533586315995075429797667226074792988851009337296041439`
- **Split address**: `0xe0fcb3f6dd24845174d25b17c93c96e6bc68e20a` ← use this with `releaseRights`
- **`sellerKeepsBps`**: 9500

---

## Ops Step: `releaseRights` call

You need to know the **locker address** for each Clanker token and the **rewardIndex** (usually 0). Call `releaseRights` on `ClankerEscrowV4`:

```
cast send 0x3546A98C09fc5a3E162d510DB331C4dcEdB6EADa \
  "releaseRights(address locker, address token, uint256 rewardIndex, address newRecipient)" \
  <LOCKER_ADDR> \
  <CLANKER_TOKEN_ADDR> \
  0 \
  <SPLIT_ADDR> \
  --rpc-url https://mainnet.base.org \
  --private-key $OPS_KEY
```

After each `releaseRights`:
- The TMPR is burned (`ownerOf` reverts)
- Fees are routed to the split

Then the **seller** clicks "Complete sale" in the UI (or you can call `completeAfterExternalClankerRoute(listingId, splitAddr)` directly from the ops wallet).

---

## How the UI works now (after this fix)

1. Seller sees "Step 1 — Create fee split" button.
2. After clicking: one wallet tx, then UI shows "Fee split created. Platform is routing fees. Click Complete sale when ready." + split address.
3. Split address is stored in `localStorage` so seller can close and return.
4. On return / refresh: localStorage restores state to "awaiting ops" with the correct split address.
5. If localStorage is empty (first open), the app scans recent factory logs to find an existing GBE-created split.
6. "Complete sale" button checks if TMPR is burned. If not: "Platform is still routing fees. Try again in a minute." If yes: calls `completeAfterExternalClankerRoute` + waits for confirmed receipt.

---

## Why `completeAfterExternalClankerRoute` was failing before

The old `handleAutoRescue` sent two transactions in sequence:
1. `createSplit` → ✅ succeeded
2. `completeAfterExternalClankerRoute` → ❌ ALWAYS reverts with `ReceiptStillExists`

This was because the TMPR still existed (ops hadn't called `releaseRights` yet). The tx was submitted and **silently failed on-chain** while the UI incorrectly showed "Sale completed." The fix splits this into the two-phase flow described above and explicitly checks TMPR burn status before attempting completion.
