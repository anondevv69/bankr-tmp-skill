# CRITICAL — `0xCD66340…` is the TMPR collection, not a token

**If the user pastes this address (any casing):**

`0xCD66340D93E212bEC6Db1b22476e4f1276380C3e`

## STOP — do not do this

- Do **not** call `GET /public/doppler/token-fees/{address}` with this hex.
- Do **not** call Clanker v4 reward ownership / `tokenRewards` on this address.
- Do **not** say “not a Bankr (Doppler) token” or “unsupported token type on Base.”
- Do **not** try `updateBeneficiary` / transfer fee rights **to** or **from** this contract address.
- Do **not** treat it as the user’s **wallet** or as a **launched meme ERC-20**.

This address is the **ERC-721 TMPR receipt collection** used by Token Marketplace (same for every fee-rights NFT). It is **not** a pool, not a Clanker token, not Doppler’s launched ERC-20.

## What the user usually means

| Situation | Correct help |
|-----------|----------------|
| They hold a **TMPR NFT** and want **fees in their wallet** again | **Redeem:** need **`tokenId`** (from OpenSea URL or profile scan) → `redeemRights(tokenId)` on Bankr / Clanker / Zora escrow from `positionOf(tokenId)`. |
| They paste `0xCD66…` and say “return to my wallet” | **Clarify:** that hex is the **whole collection**, not one NFT. Ask: **OpenSea link**, **TMPR #**, or **ticker** (t7, etc.). |
| They **never** minted TMPR; fees still on Bankr for their **launch** | They need the **launched ERC-20** address or ticker → `get_token_launch_info` / token-fees on **that** token → beneficiary is already their wallet if they never escrowed. **Not** redeem. |
| They want to **send** the NFT “back” to wallet | They may **already** own the NFT; redeem is **burn NFT + restore fee beneficiary**, not an ERC-721 transfer to wallet for fees. |

## Agent reply template (plain English — user-facing)

```text
That address is the shared receipt collection for the whole marketplace — not your specific coin or your wallet.

To get trading fees back in your wallet, either:
• Send me the OpenSea link to your fee receipt NFT for that token, or
• Tell me the token name (like test1 or t7) if you never made a receipt yet and fees are still yours on the launch.

I’ll handle the rest from your Bankr wallet.
```

## OpenSea URL pattern

`https://opensea.io/item/base/0xcd66340d93e212bec6db1b22476e4f1276380c3e/<tokenId>`

Extract `<tokenId>` → `redeemRights(tokenId)` after resolving escrow from `positionOf(tokenId)`.

## Test log (Bankr QA — failed run)

```text
Prompt: return 0xcd6634… to my wallet fees
Agent chose: validate as ERC-20 launch token
Wrong: "not a Bankr doppler token" / "no clanker v4" / "cannot transfer"
Should have said: TMPR collection — ask tokenId or ticker; redeem vs never-minted path
```

Fix: read this file **before** any token-fees / Clanker lookup when user message contains `0xCD6634` or `0xcd6634`.
