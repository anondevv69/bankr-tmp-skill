# Launch Studio autopilot

**Any agent (default):** **`launch-studio-agent-autopilot.md`** — site x402 API or CLI, poll, full receipt. **No browser.**  
**Bankr chat only (x402.cloud):** **`launch-studio-bankr-chat-autopilot.md`** — when agent has `bankr x402 call` but not site signing.

**User language:** `launch-studio-user-language.md`  
**Payment rails:** **`launch-studio-payment-rails.md`**  
**Completion reply:** **`launch-studio-completion-reply.md`**

---

## Quick reference

| Agent type | Base deploy | Solana deploy |
|------------|-------------|---------------|
| Cursor / MCP / bot with wallet | `POST /concierge/run` + x402 · or `node scripts/launch-concierge-x402.mjs` | `POST /concierge/solana/run` + Solana x402 |
| Bankr chat | Path 1 if site x402 signing · else Path 3 `x402.bankr.bot` | Site x402 (Path 1 Solana) or deep link fallback |
| No signing | Path 4 `/launch` deep link only | Path 4 |

See **`launch-studio-agent-autopilot.md`** for full steps.

---

## Deep links (Path 4 — last resort)

**Base:** `/launch?surface=bankr&platform=bankr&wallet=0x…&name=…&symbol=…&split=keep_all`  
**Solana:** `/launch?surface=bankr&platform=pump&solWallet=…&name=…&symbol=…&split=keep_all`

Use only when the agent cannot sign x402 programmatically.

---

## Errors

| Case | Action |
|------|--------|
| 402 on `/concierge/run` | Expected first POST — sign and retry with payment header |
| x402 **502** (Bankr cloud) | Secret sync · or switch to site x402 Path 1 |
| Insufficient USDC | Need ~$1 USDC on correct chain in payer wallet |
| 429 | Wallet launch limit — try another wallet |
