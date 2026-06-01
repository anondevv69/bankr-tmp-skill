# Linked wallet vs custodial TMPR owner (Bankr)

When the user's **linked wallet** differs from the wallet that **holds the TMPR**, listing fails unless you use the correct **`seller`** for `POST /api/list/dual`.

---

## Rule

| Field | Use |
|-------|-----|
| `wallet` in `GET /api/mint/status` | User's **linked** Bankr wallet (for phase / beneficiary checks) |
| `seller` in `POST /api/list/dual` | On-chain **`ownerOf(tmprTokenId)`** — whoever will sign `approve` + `list` |

If `phase === "needs_transfer_tmpr"`: run `safeTransferFrom` to user wallet **first**, then list with `seller` = user.

If `phase === "ready"` and TMPR is still on Bankr custodial (`0x374D…`): list with `seller` = custodial owner **or** transfer to user first.

---

## t7 example (May 2026)

| | Address |
|--|---------|
| User linked wallet | `0xa20ae0a2b25dc24fbd33dc4b9811db5c96761764` |
| TMPR owner (custodial) | `0x374D91a5674Fa7Cf86E725093b5848b97e1e13b4` |
| TMPR tokenId | `102827652914408433121415002298223515805764633656416579128953185902816790019438` |

**Wrong:** `list/dual` with `seller=0xa20ae0a2…` → API error (TMPR owned by custodial wallet).

**Right:** `seller=0x374D91a5…` and Bankr signs approve+list, **or** transfer TMPR to user then `seller=0xa20ae0a2…`.

---

## API error text (after fix)

> TMPR #… is owned by 0x374D… on 0xCD6634…, not seller 0xa20a…. Transfer the TMPR to the seller wallet first, or pass seller=0x374D… if that wallet will sign approve+list.

Agent must **not** call this "execution reverted" or "scanner block".

---

## Cross-links

- `t7-wrong-token-935e-trap.md`
- `sell-list-autopilot.md`
- `custodial-approve-block-retry.md` — separate issue on approve step
