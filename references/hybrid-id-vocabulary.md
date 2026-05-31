# Hybrid IDs — what “token”, “serial”, and “tokenId” mean

**Read before any hybrid unit claim, buy, or “how many ERC-1155 do I have?” question.**

Bankr agents confuse these constantly. Users will **not** use correct jargon.

---

## Quick reference (CTO TMPR #12)

| Word user/agent uses | Means | Example value |
|----------------------|-------|---------------|
| **Token / $CTO / launch** | Meme coin ERC-20 | `0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3` |
| **TMPR #12 / serial 12** | **12th hybrid sale** (website label) | API: **`serial=12`** |
| **hybridTokenId / sale id** | On-chain id for that sale | `82162810189150381448686192642592435479296266651479359308798582033011722422011` |
| **Units** | ERC-1155 fee-right shares (1000 total) | **630** = 63% of fees |
| **Wallet** | Who holds units | `0xA20Ae0A2b25dC24FBD33dC4b9811DB5c96761764` |

---

## Forbidden mappings

| Never do this | Why |
|---------------|-----|
| `serial=12` → `claimFeesForToken(**12**, …)` | **12 ≠ hybridTokenId** |
| `serial=12` → `canClaimFees(**12**)` | Checks wrong sale → “not finalized” lie |
| `serial=12` → `balanceOf(wallet, **12**)` | Returns 0; user has units on **821628…** |
| User wallet → `token=` API param | API error / wrong asset |
| Launch ERC-20 balance → “units” | Different contracts |

---

## Correct resolution order

1. User gives **launch `0xb6fB…`** (+ optional **“TMPR #12”** → **`serial=12`**)
2. Bankr injects **linked `wallet=`**
3. **`GET /api/claim/hybrid-status?token=…&serial=…&wallet=…`**
4. Use response **`hybridTokenId`** for all on-chain reads and **`nextStep.data`** for submit

**Never** skip step 3 and guess **`tokenId = serial`**.

---

## API query params (who sets what)

| Param | Set by | Example |
|-------|--------|---------|
| `token=` | User (launch ERC-20) | `0xb6fB…` |
| `serial=` | User label “TMPR #N” | `12` |
| `wallet=` | Bankr (linked) | `0xA20A…` |
| `hybridTokenId=` | Agent fallback if API docs require | `821628…` |

---

## On-chain calls — which id to pass

| Function | `tokenId` argument |
|----------|-------------------|
| `balanceOf(wallet, tokenId)` | **`hybridTokenId`** from API |
| `claimFeesForToken(tokenId, recipients, …)` | **`hybridTokenId`** from API |
| `HybridShareMarketplace.list(…, tokenId, …)` | **`hybridTokenId`** from API |
| `balanceOf(wallet, tokenId)` on share buy | **`hybridTokenId`** from listing / API |
| `canClaimFees(tokenId)` | **`hybridTokenId`** from API — **only after API**, never `serial` |
| `serialOf(tokenId)` | Pass **`hybridTokenId`** → returns **12** for TMPR #12 |

---

## Plain English for users

- **“TMPR #12”** = the **12th** fee-right sale for that token on the site — **not** the number 12 on-chain.
- **“630 units”** = your share of **trading fees** (ERC-1155) — **not** how many CTO coins you hold.
