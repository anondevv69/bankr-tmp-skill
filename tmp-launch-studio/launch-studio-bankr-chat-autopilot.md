# Launch Studio — Bankr chat (same as any agent)

**Step 0:** Read **`tmp-site-agent/agent-guide.md`** (§ Launch Studio). Install: `install TMP site agent at …/tmp-site-agent`.

**Bankr Base — read first:** **`launch-studio-bankr-base-x402-rails.md`** (Option A vs Option B).

**Option A (default in chat):** sign **site** x402 to `tokenmarketplace.shop`.  
**Option B:** only if Bankr **already** charged `x402.bankr.bot` — then Bankr server calls **`async-start`**, not `/concierge/run`.

Use **`launch-studio-agent-autopilot.md`** for step-by-step (Option A):

```http
POST https://www.tokenmarketplace.shop/api/launch/concierge/run
```

Pay **~$1 USDC on Base** via **site x402** → poll `statusUrl` → **`launch-studio-completion-reply.md`**.

---

## Bankr chat steps

| Step | Action |
|------|--------|
| 1 | Linked **Bankr EVM wallet** → `deliveryAddress` |
| 2 | Map prompt → `tokenName`, `tokenSymbol`, `splitPlan` |
| 3 | **Site x402** on `/api/launch/concierge/run` (NOT `x402.bankr.bot`) |
| 4 | User confirms **~$1 USDC once** in Bankr chat |
| 5 | Poll `GET …/status/{jobId}` until `completed` |
| 6 | Full deployment receipt with links |

**Solana (Pump):** `POST …/api/launch/concierge/solana/run` + Solana site x402.

---

## Forbidden

| Do not | Why |
|--------|-----|
| `POST x402.bankr.bot/…/token-marketplace-launch` | **Deprecated** separate rail — 502-prone; not the site x402 you built |
| Launch Studio deep link (default path) | Browser handoff when Bankr can sign site x402 |
| “Ops team manual deploy” / Bankr Club gate | Not real — fix flow or report x402 error |
| `/concierge/run` **after** any Bankr-cloud pay | Double rail |

---

## If x402 fails

1. Report the **HTTP status** and error from **`tokenmarketplace.shop`** (not bankr.bot).  
2. Check **~$1 USDC on Base** on linked wallet.  
3. **Do not** switch to `x402.bankr.bot` without user consent (second treasury).  
4. Browser `/launch` = **last resort only**.

Full spec: **`launch-studio-agent-autopilot.md`**
