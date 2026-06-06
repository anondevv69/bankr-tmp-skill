# Petition — useskill regression (Bankr must execute deposits)

**Symptom:** User asks to **get units** / **back with launch buy** → Bankr returns `READ-ONLY — useskill` and **no ETH is sent**.

**Confirmed failure (Jun 2026):** Create petition #17 succeeded via API, then “Get me 100 units + 0.05 ETH launch buy” → agent read skill only.

---

## Explain vs execute (mandatory split)

| User intent | `useskill` OK? | Must also run |
|-------------|----------------|---------------|
| “Explain petition” / “how does petition work” | ✅ **Yes** — prose only | Nothing on-chain |
| “Create petition for $KNICKS” | ✅ After create API | `POST /api/petition/create` — **no tx yet** |
| “Get me 100 units” / “back with 0.05 ETH launch buy” | ❌ **Never as final step** | `GET /prepare-deposit` → **`bankr.tx.prepare`** → `POST /confirm` |
| Share link + “participate with N units” | ❌ | Flow **P** — same as above |

**Rule:** If the user names **units** and/or **launch buy ETH**, the turn is **not complete** until a **deposit tx hash** exists.

---

## ROUTING GUARD (copy into agent runtime)

```
if user mentions petition + (units OR launch buy OR "get me" OR "back" OR "participate"):
  if user only asks explain/how-it-works:
    reply with explain template → STOP (no tx)
  else:
    1. resolve petition id (from URL, "#17", or latest create in thread)
    2. GET /api/petition/prepare-deposit?id=&wallet=<linked>&units=&launchBuyWei=
    3. quote deposit.totalEth to user
    4. bankr.tx.prepare(nextStep)  — REQUIRED; useskill does NOT substitute
    5. POST /api/petition/confirm { signature: txHash, ... }
    6. reply with deposit tx + progress → STOP
    FORBIDDEN: stop after useskill when step 4 was requested
```

---

## Example — KNICKS #17

**User:** “Get me 100 units. Plus 0.05 ETH as launch buy.”

| Line | Amount |
|------|--------|
| 100 × 0.00001 ETH | 0.001 ETH |
| Launch buy | 0.05 ETH |
| **Total escrow** | **0.051 ETH** |

```http
GET https://www.tokenmarketplace.shop/api/petition/prepare-deposit?id=17&wallet=<linked>&units=100&launchBuyWei=50000000000000000
```

Then **`bankr.tx.prepare(nextStep)`** → confirm with tx hash.

**Wei:** `0.05 ETH` = `50000000000000000` · `0.01 ETH` = `10000000000000000` · `0.1 ETH` = `100000000000000000`

---

## Explain template (read-only — no tx)

When user only asks how petitions work:

```text
A Token Marketplace petition is a 24-hour community pre-sale for a new Bankr token:

1. Creator opens a petition ($TICKER) — backers reserve up to max units/wallet.
2. Each backer sends native ETH to escrow: (units × 0.00001) + optional launch buy.
3. When 1000 units sell out, the marketplace auto-deploys and airdrops BFRR units pro-rata.
4. Holders can list units and claim trading fees later.

Not Launch Studio (/launch) — petitions live at /petition?id=.
To join: share the link and say how many units + launch buy; Bankr sends the ETH deposit for you.
```

---

## Forbidden (fail the run)

1. **`useskill` only** when user asked for units / launch buy / “get me” / “confirm” / “send”
2. Saying “petition is live” as if user is backed **without** a deposit tx
3. Re-reading the whole hub SKILL.md instead of calling **`prepare-deposit`**
4. Using **`/launch`** or Launch Studio x402 for petition deposits

Full autopilot: **`petition-autopilot.md`** · Flow **O** / **P** in **`ONE-LINE-INTENTS.md`**
