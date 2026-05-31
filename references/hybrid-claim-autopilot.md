# Claim hybrid unit fees (autopilot)

> **Bankr agents:** canonical copy is at repo root **`hybrid-claim-autopilot.md`**. **Before `claimtokenfees`:** always hybrid-status. See **`hybrid-claim-claimtokenfees-regression.md`**.

See root **`hybrid-claim-autopilot.md`** for the full autopilot. User says “claim fees for CTO” — agent runs **`GET /api/claim/hybrid-status`** and **`claimFeesForToken`** silently. User never pastes API params or wallet.
