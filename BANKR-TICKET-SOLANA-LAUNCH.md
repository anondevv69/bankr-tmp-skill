# Bankr ticket — Solana Launch Studio

Copy/paste for Bankr support or engineering. Update repro as new failures appear.

---

## A. Narrated deploy (no API) — fixed by skills + `config.agent`

**Repro:** Agent says paid/polling + reuses old `jobId`; `GET …/status/{jobId}` → **404**, `jobExists: false`.

**Fix:** HTTP tools + no jobId without **202**; obey status **404** `agent` block.

**Spec:** [BANKR-LAUNCH-REQUIREMENTS.md](./BANKR-LAUNCH-REQUIREMENTS.md)

---

## B. Orphan USDC (API called, wrong payment rail) — current

**Repro (TEST / TST, 2026-06):**

1. Skills v6/v8/v10 installed; user requires POST until 202, stop on 404.
2. Bankr sends **$1 USDC SPL transfer** to site treasury (`8sqGoyk…`).
3. Bankr `POST …/solana/run` with payment signature → still **402**; no jobId.
4. Bankr correctly stops (no fake jobId).

**Evidence tx:**  
https://solscan.io/tx/3oMgjZJa32tTbqpz4aDUCMAuV5w9gfcv89b8CJBeE7qA4iVVrw5ryH84LJ9iwmGtfcBofMmSxhqApYNbKsDLdchv  

- Payer: `9G7xHgFZCsRwwgKFJjqsVntqA4oUtRVz2kX8YV9Dk8PZ` (5 → 4 USDC)  
- Recipient ATA owner: `8sqGoykSVw1fYq4hp5U9shniueJsbmUFjxsMHMriKX8b` (treasury +1 USDC)  
- Simple token transfer — **not** x402-bound to `POST /api/launch/concierge/solana/run`

**Required product fix:**

- Do **not** use generic “send USDC” for launch fee.
- Use **site x402 on the POST**: `POST` → 402 → `ExactSvmScheme` sign → `POST` + `PAYMENT-SIGNATURE` → **202**.
- Reference impl: `fee-rights-exchange/bankr-app/scripts/launch-concierge-solana-x402.mjs` (`wrapFetchWithPaymentFromConfig`).

**User impact:** $1 at treasury, launch not queued — support refund or manual fulfill; **no blind retry**.

---

## Endpoints

| | URL |
|---|-----|
| Config + rules | `GET https://www.tokenmarketplace.shop/api/launch/concierge/config` → `config.agent` |
| Solana launch | `POST https://www.tokenmarketplace.shop/api/launch/concierge/solana/run` |
| Status | `GET https://www.tokenmarketplace.shop/api/launch/concierge/status/{jobId}` |

---

## Pass criteria (Bankr QA)

1. `POST …/solana/run` → **202** + **new** `jobId` in same session.  
2. `GET status` → `ok: true` immediately.  
3. Poll → `completed` + mint + Solscan in reply.  
4. No “paid” without 202; no jobId on 404; no orphan USDC-only transfer.
