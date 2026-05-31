# Share market list autopilot — natural language only

> **Users never say:** `HybridShareMarketplace`, `accessKeyHash`, `maxPerWallet`, `hybridTokenId`, `setApprovalForAll`, or `use_skill`.  
> **You** resolve IDs, build calldata, submit txs, verify receipts.

**Full spec:** **`share-market-list.md`**

---

## TRIGGER

Match any of:

- **list / sell** + **share(s) / unit(s) / 1/1000**
- **list on hybrid share marketplace**
- **0 ETH / free / $0** + **password** + **units**
- **max N per wallet** + list shares
- ticker ($CTO) or launch **`0xb6fB…`** + list units

**Load:** `bankr-fee-rights` → this file + **`share-market-list.md`**.

**MANDATORY FIRST STEP:** **`GET …/api/claim/hybrid-status?token=<launch>&wallet=<linked>`** → use **`hybridTokenId`**, confirm **`unitsHeld > 0`**.

---

## Routing guard

```
if user wants to list 1/1000 shares / ERC-1155 units:
  1. GET hybrid-status (linked wallet)
  2. parse quantity, price (0 OK), maxPerWallet (0 = no cap), password (DM if public tweet)
  3. setApprovalForAll(marketplace) if needed
  4. list(...) — 6-arg if password else 5-arg/4-arg
  5. verify ShareListed + accessKeyHash if gated → reply → STOP

elif user wants sell 100% TMPR:
  → sell-list-autopilot.md + POST /api/list/dual — NOT this file

elif user wants partial sale / group buy:
  → GroupBuyEscrow — NOT share market
```

**FORBIDDEN:** `POST /api/list/dual` for ERC-1155 unit listings · `tokenId = serial` · public 5-arg `list` when user asked for password.

---

## Default interpretations

| User says | You assume (unless they correct) |
|-----------|----------------------------------|
| “List my units at 0 with password” | **One listing** for **all units they name** (or ask qty once) |
| “Each at 0 with password” (ambiguous) | **One listing**, qty = all held or stated N — **not** 630 separate txs unless they say “630 separate listings” |
| “1 per wallet” / “one each” | `maxPerWallet = 1` |
| No price mentioned | Ask **one** question: “What price per share in ETH? (0 is OK)” |
| Password on public tweet | Ask them to **DM password** — do not request password in public thread |

---

## Execution steps (autopilot)

1. **Resolve** launch token / ticker → **`hybridTokenId`** via hybrid-status.
2. **Clamp** `quantity` ≤ `unitsHeld`.
3. **Price:** `pricePerUnitWei = parseEther(userEth)` — **`"0"` → 0n** is valid.
4. **maxPerWallet:** user number, or **0**; for giveaways **`1`** when user wants one unit per buyer.
5. **Password:** build hash per **`share-market-list.md`** § accessKeyHash.
6. **Approve** marketplace on hybrid TMPR if needed (tx 1).
7. **List** on `0x90230B…` (tx 2).
8. **Verify** receipt → link order book → plain English reply → **STOP**.

There is **no** step 9. Do not hand off to “use the website” if wallet + contract tools work.

---

## Example — CTO 630 units, 0 ETH, password (user intent from tweet)

**User:** “List my CTO units at 0 ETH with password — buyers need password to claim.”

**Agent (internal):**

```http
GET …/hybrid-status?token=0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3&wallet=0xA20A…
→ hybridTokenId = 82162810189150381448686192642592435479296266651479359308798582033011722422011
→ unitsHeld = 630
```

```text
list(
  0xD8e0639DfAa1cB2b9f9642EeCbd40b1e5a8b42A7,
  821628…22011,
  630,
  0,
  0,              # or 1 if "one per wallet"
  accessKeyHash
)
```

**Reply:** “Listed **630** shares of **$CTO** for **free** (0 ETH) on the marketplace order book. Buyers need the password you set. [link]”

---

## When tools are missing (honest reply)

If Bankr cannot bind contract-write tools:

> “I have the listing steps for password-protected **0 ETH** share listings, but I can’t submit the on-chain txs from this session. Use **List shares** on [tokenmarketplace.shop](https://www.tokenmarketplace.shop) on your CTO vault page — set price **0**, optional password, and max per wallet. Or retry in DM with **Using the tmp skill** after tools load.”

Do **not** claim listing is impossible — the site and on-chain path both work.

---

## Cross-links

- **`share-market-list.md`**
- **`share-market-buy.md`**
- **`BANKR-PLATFORM-TWEET-INTAKE.md`**
