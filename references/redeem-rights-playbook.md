# Redeem (`redeemRights`) — agent playbook

## Hard rules

1. **`msg.sender` must equal `ownerOf(tokenId)`** on TMPR `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e`.  
   - Wrong wallet → `UnauthorizedCaller(address)` (`0xd86ad9cf`).  
   - **Do not** call `setApprovalForAll(escrow, true)` for redeem — **not required**. Escrow burns via `authorizedEscrow`; holder only calls `redeemRights`.

2. **Collection address ≠ tokenId.** User saying “burn `0xcd6634…`” still needs the **uint256 tokenId** (OpenSea URL or serial #20 → resolve `tokenId`).

3. **Escrow:** Bankr TMPR → **`BankrEscrowV3`** `0x6238698212D91845cD1c004DE85951055bB5b292`.  
   - **Verified** on BaseScan (do not tell users to “verify escrow” as a blocker).  
   - Clanker → `0x3546A98C09fc5a3E162d510DB331C4dcEdB6EADa`; Zora → `0x7A7540B048a8CC96837E83604B32559CCe911D9F` (or legacy `0xe1E1BD80723C4061fb84F2C0a022F4Cea4816D66` for older TMPRs).

4. **Before tx:** `eth_call redeemRights(tokenId)` **from `ownerOf` address**. If success, submit **from that same address** only.

5. **After success:** TMPR burned; `getShares(poolId, userWallet) > 0` on fee manager; verify `get_token_launch_info` / Doppler `feeRecipient`.

## Pre-flight checks (Base `eth_call`)

```text
owner = TMPR.ownerOf(tokenId)
pos = TMPR.positionOf(tokenId)   # feeManager, poolId, seller, factoryName
escrow.isEscrowed(pos.poolId)    # must be true
escrow.originalOwner(poolId) == pos.seller
fm.getShares(poolId, escrow) > 0
```

If `isEscrowed` is **false** but NFT still exists → **broken state**; escalate ops (do not loop redeem).

## Common revert reasons

| Revert | Cause | Fix |
|--------|--------|-----|
| `UnauthorizedCaller` | Tx not from NFT owner | Use Bankr wallet that holds TMPR (`ownerOf`) |
| `RightsNotEscrowed` | Pool already settled/redeemed | Check `isEscrowed`; NFT may be stale |
| `InvalidReceiptPosition` | Position metadata ≠ escrow state | Ops / wrong escrow contract |
| `TransferVerificationFailed` | `updateBeneficiary` did not move shares | Fee manager / pool issue; trace on BaseScan |

## Partial sale (95% on escrow)

`getShares(poolId, escrow) == 0.95e18` is normal after **partial listing finalize** (seller kept 5%). Holder of TMPR can still **`redeemRights`** — moves escrowed slice to holder wallet.

## Security scanners

If Bankr blocks `setApprovalForAll(escrow)` — **ignore for redeem**; that path is wrong. Submit **`redeemRights(tokenId)`** only, from **NFT owner** wallet.

## Real failure log (QA)

```text
User: Burn the NFT 0xcd6634… and get my rights back
Bankr: redeem reverted; tried setApprovalForAll; “escrow unverified”
tokenId: 48377155880238308705550034476083964778932907704334934787124089488714520594345  (#20)
ownerOf: 0x374D91a5674Fa7Cf86E725093b5848b97e1e13b4
On-chain: redeemRights from owner estimates ~212k gas (success); from seller reverts UnauthorizedCaller
```

**Correct agent steps:** resolve tokenId → `ownerOf` → `redeemRights` on `0x6238…` **from owner** → verify fee recipient.

## Manual (user)

https://www.tokenmarketplace.shop → profile / holdings → **Redeem** on the TMPR, **or** wallet:

`BankrEscrowV3.redeemRights(48377155880238308705550034476083964778932907704334934787124089488714520594345)`

Signer must be `0x374D91a5674Fa7Cf86E725093b5848b97e1e13b4` (current owner on-chain — confirm live `ownerOf` before signing).
