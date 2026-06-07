# Petition — reply-to-tweet backing (Bankr on X)

When a creator launches a petition via **@bankrbot**, they can tie it to their **X thread** so repliers know how many units to request.

---

## Creator tweet (example)

> @bankrbot create a petition for $UP on Base. Name goupplease. Max 100 units/wallet.  
> Replies to this tweet get **100 units** via Bankr.

**On create**, Bankr should pass:

```json
{
  "chain": "base",
  "tokenName": "goupplease",
  "tokenSymbol": "UP",
  "maxUnitsPerWallet": 100,
  "promoTweetUrl": "https://x.com/rayblancoeth/status/…",
  "bankrReplyUnitsPerBacker": 100,
  "starterWallet": "0x…"
}
```

Site sets `bankrReplyThreadEnabled: true` when both `promoTweetUrl` and `bankrReplyUnitsPerBacker` are present.

---

## Replier (reply to creator's tweet)

> @bankrbot back petition #19 with 100 units

Or if petition has `bankrReplyUnitsPerBacker: 100`:

> @bankrbot back this petition

Bankr reads `GET /api/petition/status?id=19` → `agentParticipation.replyHint` → **`prepare-deposit` → `bankr.tx.prepare` → `confirm`**.

**Repliers still pay** `(units × 0.00001 ETH) + optional launch buy` unless creator explicitly funds them (not automated yet).

---

## Announcement tweet (site bot)

When `POST /api/petition/create` succeeds, the marketplace bot posts to **X / Telegram / Farcaster** (if webhooks configured):

- Token name + `$TICKER`
- Chain
- Max units/wallet
- Link: `https://www.tokenmarketplace.shop/petition?id=`

Replay missed alert (ops): `POST /api/petition/notify` with `{ "id": "19" }` and `LISTING_PUBLISH_SECRET`.

---

## Status

| Piece | Live? |
|-------|-------|
| Create + deposit APIs | ✅ |
| Social announce on create | ✅ (needs Railway `/webhook/petition` + Vercel env) |
| Reply metadata on petition | ✅ |
| Bankr auto-detect reply thread | ⚠️ Bankr platform — route reply → prepare-deposit |
| Creator-paid free units on reply | ❌ planned |

Full deposit flow: **`petition-autopilot.md`** · **`petition-useskill-regression.md`**
