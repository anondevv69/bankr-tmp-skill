# Launch Studio — Bankr must mirror the website (mandatory)

The **Launch Studio UI** and Bankr must run the **same client flow**. The site code is the reference: `runConciergeLaunch.ts` → `pollConciergeJobUntilDone`.

---

## What the website does (you must copy this)

```text
1. POST /api/launch/concierge/run + site x402 sign     (~5–30s — user approves USDC once)
2. Response 202 { jobId, statusUrl }                   (immediate)
3. Poll GET …/status/{jobId} every 4s                  (1–3 min Base · up to 10 min Solana)
4. When status === completed → Done screen + all links
```

**x402 is fast.** The **1–3 minute lull** is deploy + mint + split + deliver on the **site executor** — normal. The UI keeps polling in the same page until done.

**Bankr failure mode:** pay or claim to pay → say “processing… I’ll poll” → **end turn without polling**. User waits forever. **That is not x402 being slow — Bankr stopped.**

---

## Bankr mandatory loop (same as website)

| Step | Action | Do not stop here |
|------|--------|------------------|
| 1 | `POST …/concierge/run` (or `/solana/run`) with site x402 | |
| 2 | Save **`jobId`** from **202** | |
| 3 | `GET …/status/{jobId}` every **15–30s** (site uses 4s) | |
| 4 | While `queued` or `running` → short update: “Still launching — jobId …” | **Keep polling** |
| 5 | `completed` → **`launch-studio-completion-reply.md`** | |
| 6 | `failed` → show `error` from JSON | |

**Timeout:** poll up to **8 min** (Base) / **10 min** (Solana) before saying failed.

**Minimum polls before giving up:** **12** (≈3 min at 15s) for Base.

---

## Forbidden stall pattern

| Bankr says | Problem |
|------------|---------|
| “Processing payment… I’ll poll automatically” then **silence** | No poll loop ran |
| “This typically takes 1–3 minutes” then **new topic / end turn** | Website would still be polling |
| “No further action needed on your part” without **token + tx links** | Job may still be running or done unseen |

**If you cannot poll in one turn:** return **`jobId` + statusUrl** and on the **next user message** (or “still going?”) poll immediately — **do not ask user to pay again**.

---

## Timing expectations (tell user honestly)

| Phase | Duration |
|-------|----------|
| x402 USDC sign | seconds |
| 202 + job queued | immediate |
| `running` pipeline | **1–3 min** Base (wallet_list airdrop may be longer) |
| Solana Pump | up to **~10 min** |

A **2–3 min** wait with status `running` is **success path**, not a stall.

---

## Self-check

- [ ] Same flow as `runConciergeLaunch.ts` (x402 POST → 202 → poll until done)?  
- [ ] Polled at least **3 minutes** or until terminal status?  
- [ ] Reply includes **jobId** even while running?  
- [ ] Never asked user to retry pay without checking status first?
