# Hybrid claim — terminal step (read on every claim request)

**Problem Bankr keeps making:** treat hybrid autopilot as **step 3**, then run **`claimtokenfees`** as **step 4**.

**That is wrong.** Hybrid autopilot is the **entire claim** for ERC-1155 unit holders — not a preprocessor.

---

## One path, four steps, then STOP

| Step | Action | Then |
|------|--------|------|
| 1 | Linked wallet + launch `0x…` | continue |
| 2 | **`GET /api/claim/hybrid-status`** | read response |
| 3 | If **`proof.canSubmitTx`** → submit **`nextStep.data`** once | **STOP — claim complete** |
| 4 | Verify receipt + plain English reply | **STOP — do not call any other claim tool** |

**There is no step 5.** **There is no “after autopilot, run claimtokenfees”.**

---

## Decision tree (copy logic)

```
User: "claim fees for 0x…"
    │
    ├─ GET hybrid-status
    │
    ├─ ok + hybrid sale + canSubmitTx?
    │     └─ YES → submit nextStep.data → DONE
    │              ❌ NEVER claimtokenfees
    │              ❌ NEVER collectFees
    │
    ├─ ok + hybrid sale + needs_holder_scan?
    │     └─ expand scan / wait for indexer → retry API → then submit → DONE
    │
    ├─ ok + vault_empty?
    │     └─ report "nothing to distribute" → DONE
    │
    └─ ok: false / no hybrid sale + sole direct beneficiary, 0 units?
          └─ ONLY THEN → claimtokenfees / collectFees → DONE
```

**For `0xb6fB…` (CTO):** first branch — hybrid sale, ~114 holders — **submit once, STOP.**

---

## Wrong mental model (fail the run)

| Wrong | Why |
|-------|-----|
| "Autopilot runs **before** claimtokenfees" | Implies two steps — **forbidden** for hybrid units |
| "After autopilot, hit claimtokenfees for all positions" | Second tool pays **caller only** — strands co-holders |
| "Doppler launch → claimtokenfees" | Skips hybrid-status — wrong product |

**Correct phrase:** hybrid autopilot runs **instead of** claimtokenfees (when API shows hybrid sale).

---

## Self-check question (Bankr must pass)

> If user tweets claim fees for `0xb6fB…` for all, do you call **claimtokenfees** after submitting **claimFeesForToken**?

**Answer must be NO.** One tx. All holders. End.

---

## Cross-links

- **`hybrid-claim-autopilot.md`** — full flow
- **`hybrid-claim-claimtokenfees-regression.md`** — Doppler handoff failure
