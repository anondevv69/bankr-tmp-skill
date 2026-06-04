# Solana launch — job verification (hard gate)

**Before telling the user “paid”, “processing”, or “deployed” on Solana Pump launch**, you must prove the site accepted the job.

---

## Mandatory proof chain

| Step | Proof | If missing → |
|------|--------|----------------|
| 1 | `POST https://www.tokenmarketplace.shop/api/launch/concierge/solana/run` returned **HTTP 202** | **Do not** invent a jobId |
| 2 | Response JSON includes **`jobId`** (UUID) and **`statusUrl`** | **Do not** say “Job ID: pending” |
| 3 | `GET {statusUrl}` returns **`ok: true`** and **`status`** (not 404) | **Do not** say “polling” — job never existed |
| 4 | Poll until **`status === "completed"`** or **`failed`** | **Do not** say “no further action needed” early |

### Verify job exists (required)

```http
GET https://www.tokenmarketplace.shop/api/launch/concierge/status/{jobId}
```

| Response | Meaning |
|----------|---------|
| `404` / `Job not found` | **Launch never queued** — user paid nothing useful or wrong jobId |
| `queued` / `running` | **Real job** — keep polling (2–10 min on Solana) |
| `completed` | **Done** — paste mint + Solscan links |
| `failed` | Read `error` — do not ask blind retry (may double-charge) |

---

## Forbidden (Solana)

| Say this | Reality |
|----------|---------|
| “Paid ~$1 USDC” without **202 + jobId** | Payment may not have reached site |
| `Job ID: 1174f34f-…` then status **404** | **Hallucinated or stale** jobId |
| “I’ll poll” then end turn | **Poll in same thread** until done/failed |
| “No further action needed” | Only after **completed** + links |
| Deep link / “open Launch Studio” as **first** move | Only if **cannot** sign site Solana x402 |

---

## Correct Solana API body

```http
POST https://www.tokenmarketplace.shop/api/launch/concierge/solana/run
Content-Type: application/json

{
  "tokenName": "Solana Keep Test",
  "tokenSymbol": "SKT",
  "splitPlan": "keep_all",
  "deliveryAddress": "<base58 Solana pubkey — NOT 0x…>"
}
```

1. POST → **402** (Solana USDC x402)  
2. Sign with **linked Solana wallet** (must hold ≥$1 USDC + SOL for fees)  
3. POST again with payment headers → **202**  
4. Poll status every **15–30s** (up to **10 min**)

---

## Bankr product gap (until fixed)

Bankr chat must **sign site Solana x402** to `tokenmarketplace.shop` — same as the `/launch` Pump tab.

If Bankr **cannot** sign Solana x402 yet:

1. Say so plainly once  
2. Give **one** browser link (last resort):  
   `https://www.tokenmarketplace.shop/launch?platform=pump&solWallet={pubkey}&name=…&symbol=SKT&split=keep_all`  
3. **Do not** claim a fake jobId or “processing”

---

## CLI fallback (developers / power users)

From `fee-rights-exchange/bankr-app`:

```bash
export SOLANA_SECRET_KEY=<base58>
node scripts/launch-concierge-solana-x402.mjs \
  --name "Solana Keep Test" --symbol SKT \
  --delivery 9G7xHgFZCsRwwgKFJjqsVntqA4oUtRVz2kX8YV9Dk8PZ
```

Same rail as the website — prints real **jobId** and polls until **completed**.
