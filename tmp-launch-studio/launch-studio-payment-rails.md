# Launch Studio — payment rails

**Same pipeline after payment** (deploy → mint → split → 1000 units). **Different payment entry points.**

---

## Rule for all agents (2026-06)

| Agent capability | **Default** | Doc |
|------------------|-------------|-----|
| **Can sign site x402** (wallet, CLI, MCP) | **Site x402** → `/concierge/run` or `/solana/run` | **`launch-studio-agent-autopilot.md`** Path 1 |
| **Bankr chat / `bankr x402 call` only** | **Bankr x402 cloud** (Base) | **`launch-studio-bankr-chat-autopilot.md`** |
| **Cannot sign any x402** | Browser `/launch` (last resort) | Path 4 in agent autopilot |

**Forbidden for capable agents:**

- Sending Launch Studio deep links when the agent can pay x402 programmatically.
- Telling users to “open the site and connect wallet” when Path 1 or 3 is available.
- Calling **`/concierge/run` after Bankr x402 cloud pay** (double rail).
- Saying one payment covers both Bankr x402 cloud and site x402.

---

## Primary — Site x402 (any agent with wallet · Rail B)

| | |
|--|--|
| **API** | `POST /api/launch/concierge/run` (Base) · `POST …/solana/run` (Solana) |
| **CLI** | `node bankr-app/scripts/launch-concierge-x402.mjs` (Base) |
| **Who pays** | Payer wallet (~$1 USDC) — agent signs EIP-3009 / Solana x402 |
| **USDC to** | Site treasury |
| **Settlement** | After pipeline success |
| **Browser needed?** | **No** |

```text
Any agent + wallet ──► POST /concierge/run (x402 sign) ──► poll status ──► 1000 units
```

---

## Bankr x402 cloud (Bankr-native · Rail A · Base only)

| | |
|--|--|
| **Entry** | `POST x402.bankr.bot/{wallet}/token-marketplace-launch` |
| **Who pays** | Bankr custodial wallet in chat |
| **Site hook** | `async-start` + secret |
| **502 fix** | Sync `LAUNCH_CONCIERGE_INTERNAL_SECRET` Vercel ↔ `bankr x402 env set` |

Use when agent has Bankr x402 tools but **not** site URL signing. If agent has **both**, prefer **site x402** (Rail B) when Bankr cloud returns 502.

---

## Browser (Rail C — last resort)

Only when agent **cannot** sign x402. Deep link to `/launch`.

---

## Plain English

**Good (any capable agent):**

> I’ll pay **~$1 USDC** and launch **$BKT** — all **1000 units** to your wallet. No need to open the website; I’ll send links when it’s done.

**Bad:**

> Open Launch Studio and connect your wallet (when agent can sign x402)
