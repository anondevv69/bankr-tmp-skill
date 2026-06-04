# Launch verification — all agents (Bankr, Cursor, MCP, bots)

Use this when testing “does agent deploy work?” or when users report **stuck / fake jobId** launches.

---

## Pass/fail test (any agent)

| # | Check | Pass |
|---|--------|------|
| 1 | `GET https://www.tokenmarketplace.shop/api/launch/concierge/config` | `ok: true`, read `config.agent` |
| 2 | `POST …/solana/run` (or `/run` Base) with site x402 | **HTTP 202** + `jobId` |
| 3 | `GET …/status/{jobId}` immediately | **`ok: true`** (not 404) |
| 4 | Poll until `status === "completed"` | Mint + explorer links in reply |
| 5 | User wallet | USDC spent only after pipeline rules; units on profile |

**Fail pattern (SKT incident):** steps 2–3 skipped; agent says “paid” + old `jobId`; status **404** with `jobExists: false`.

---

## What to do on fail

| Agent type | Fix |
|------------|-----|
| **Bankr** | Reinstall skills v102+; paste status 404 JSON to Bankr; require **`BANKR-LAUNCH-REQUIREMENTS.md`** routing guard. **Bankr product** must sign Solana site x402 (not narrate). |
| **Cursor / local** | Run `fee-rights-exchange/bankr-app/scripts/launch-concierge-solana-x402.mjs` with `SOLANA_SECRET_KEY` |
| **Any** | Browser `/launch?platform=pump&solWallet=…` |

---

## API responses (after site deploy)

**404 status** includes `agent` object: interpretation, `forbiddenReplies`, `requiredNextSteps`.

**202 enqueue** includes `agent.mustVerifyStatus` and `forbiddenIfStatus404`.

Agents that **call the API** get corrected by JSON even if skills are ignored.

---

## Bankr runtime ask (for Bankr team)

1. On deploy intent → **HTTP tool** to site (not prose).  
2. Implement **Solana SVM x402** to `POST …/solana/run` (mirror website).  
3. **Block** replies containing `Job ID:` unless a tool returned **202** in the same session.  
4. On status **404** → refuse “polling” template; surface `agent.requiredNextSteps`.

Spec: **`BANKR-LAUNCH-REQUIREMENTS.md`**.
