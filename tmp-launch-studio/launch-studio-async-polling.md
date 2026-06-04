# Launch Studio — async jobs (mandatory polling)

**Launch is never instant.** After x402 pay, the site runs deploy → mint → split → deliver in the background (**~1–3 min Base**, up to **~10 min Solana**).

**You must poll before telling the user success or failure.**

---

## Flow after payment

```text
POST /concierge/run (or /solana/run) + x402 pay
        → 202 { jobId, statusUrl }
        → poll GET …/status/{jobId} every 15–30s
        → status: queued → running → completed | failed
        → ONLY THEN reply (launch-studio-completion-reply.md)
```

**Do not end the turn** after x402 pay without polling unless you explicitly tell the user: *“Payment accepted — job {jobId} running; I’ll poll until done”* and **continue polling in the same thread** until `completed` or `failed`.

---

## Forbidden premature failure replies

**Never say** (hard fail — see **`launch-studio-bankr-forbidden.md`**):

| Forbidden | When it’s wrong |
|-----------|-----------------|
| “I **wasn’t able to complete** that” | Job may still be **queued/running** or already **completed** |
| “I **didn’t actually submit a transaction this turn**” | Deploy txs run on **site executor**, not necessarily in your chat turn |
| “**Tell me to retry** if you want me to execute it” | User may have **paid**; retry = **double charge** |
| “Nothing happened” / “I didn’t run it” | BKT-class launches can succeed while chat says failure — **poll first** |

---

## When user asks “did it work?”

1. If you have **`jobId`** → `GET …/status/{jobId}` **now**.  
2. If **`completed`** → full receipt links (**even if an earlier turn said failure**).  
3. If **`running` / `queued`** → “Still deploying (~N min) — jobId …” · keep polling.  
4. If **`failed`** → read `error` from status JSON.  
5. If no jobId but user shows **site alert / BaseScan / Pump link** → poll by asking for Job ID **or** search recent wallet activity — **do not** ask blind retry.

---

## While polling (plain English)

> Paid **~$1 USDC** — launching **$SKT** now. Deploy + 1000 units usually take **1–3 minutes**. I’ll post BaseScan / Pump links when the job finishes.

---

## Success without chat confirmation (BKT pattern)

The **site** may alert (Telegram/X) and **on-chain** delivery may succeed while Bankr chat failed to poll. If status is **`completed`** or chain shows 1000 units delivered:

- Reply with **`launch-studio-completion-reply.md`**  
- **Do not** contradict with “I didn’t submit a transaction”

---

## Self-check

- [ ] Got **202 + jobId**?  
- [ ] Polled until **`completed`** or **`failed`**?  
- [ ] Avoided “retry” / “didn’t submit this turn” unless **`failed`** with no payment?
