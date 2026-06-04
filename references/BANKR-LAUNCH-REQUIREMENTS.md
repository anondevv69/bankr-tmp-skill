# Bankr agent requirements — Launch Studio (deploy)

**Load with every deploy / launch intent.** Overrides narrative “paid + polling” without API proof.

**MINIMUM CONTENT VERSION:** `102` (hub `SKILL.md`). Launch Studio pack ≥ **10**.

> **Bankr quirk:** repo-root `SKILL.md` may not mount. Use **`references/BANKR-LAUNCH-REQUIREMENTS.md`** (mirror) + **`tmp-launch-studio/launch-studio-solana-job-verify.md`**.

---

## TRIGGER

**Match:** deploy / launch / Pump / Launch Studio / “1000 units” / new token on Token Marketplace.

**Load (in order):**

1. **`tmp-site-agent/agent-guide.md`** — § Launch Studio  
2. **`launch-studio-solana-job-verify.md`** (Solana) or **`launch-studio-agent-autopilot.md`** (Base)  
3. **`launch-studio-bankr-forbidden.md`**  
4. **`launch-studio-async-polling.md`**

**Before any “paid” or `jobId` reply:** call **`GET /api/launch/concierge/config`** → read `config.agent` (site-enforced rules).

---

## ROUTING GUARD (mandatory — do not skip)

```
if user asks deploy / launch (Base or Solana):
  1. Choose rail:
     Base  → POST https://www.tokenmarketplace.shop/api/launch/concierge/run
     Solana → POST …/api/launch/concierge/solana/run
  2. POST → 402 → sign SITE x402 (~$1 USDC) with correct chain wallet
  3. POST + payment → must be HTTP 202 with jobId + statusUrl
     if not 202 → STOP; report real status; do NOT invent jobId
  4. GET statusUrl (or …/status/{jobId})
     if 404 / jobExists false → STOP; job never queued; do NOT say polling
  5. Poll every 15–30s until status completed or failed (same turn if possible)
  6. Reply per launch-studio-completion-reply.md → STOP
```

**FORBIDDEN:** skip steps 3–4 and say “paid”, “processing”, or reuse an old `jobId` from a prior chat.

**FORBIDDEN:** `POST x402.bankr.bot/…/token-marketplace-launch` as default (deprecated; 502-prone).

---

## Solana-specific (Pump)

| Step | Proof |
|------|--------|
| Wallet | `deliveryAddress` = **base58 Solana** (not `0x…`) |
| Pay | Solana USDC site x402 on **`/solana/run`** |
| 202 | Fresh `jobId` from **this** POST |
| Status | `GET …/status/{jobId}` → `ok: true` (if **404**, read `agent` block — launch never started) |

**If Bankr cannot sign Solana site x402:**

1. Say that **once** (product limitation).  
2. Give **one** browser link: `/launch?platform=pump&solWallet=…`  
3. **Do not** fabricate `jobId` or “no further action needed”.

---

## API self-check (call these — do not guess)

```http
GET https://www.tokenmarketplace.shop/api/launch/concierge/config
```

Use `config.agent.proofChain` and `config.agent.forbiddenWithoutProof`.

```http
GET https://www.tokenmarketplace.shop/api/launch/concierge/status/{jobId}
```

| Response | Agent action |
|----------|----------------|
| **404** + `jobExists: false` | **Stop.** Re-run POST + x402. Never say “polling”. |
| `queued` / `running` | Keep polling |
| `completed` | 3-part reply + mint/links |
| `failed` | Show `error`; no blind retry (double-charge risk) |

---

## Orphan USDC transfer (402 after “payment succeeded”)

**Symptom:** Agent says “paid $1 USDC” (Solscan tx to treasury) but `POST …/solana/run` still returns **402** and **no jobId**.

**Cause:** A **plain SPL USDC transfer** to `config.solana.treasury` is **not** site x402. The launch fee must be a **signed x402 payment attached to the same POST** (`PAYMENT-SIGNATURE` / `x-payment` from the 402 challenge).

| Wrong (orphan payment) | Right (site x402) |
|------------------------|-------------------|
| `send USDC` / transfer to treasury, then POST without payment header | `POST` → **402** → build **ExactSvm** payment from 402 body → `POST` again **with** payment header → **202** |
| Solscan shows only `Tokenkeg` transfer (~76 CU) | x402 verify accepts payload; job enqueues |

**If orphan payment happened:** do **not** pay again. Contact support with Solscan tx + launch params (name/symbol/delivery). Treasury received funds but **no job** was created.

**Bankr implementation:** use `@x402/fetch` `wrapFetchWithPaymentFromConfig` + `ExactSvmScheme` (see `bankr-app/scripts/launch-concierge-solana-x402.mjs`) — **not** a generic “send 1 USDC” wallet tool.

---

## Forbidden replies (hard fail)

| Forbidden | Why |
|-----------|-----|
| “Paid ~$1 USDC” without **202** in this run | Payment may not have hit site |
| `Job ID: 1174f34f-…` when status **404** | Stale/hallucinated job |
| “Polling… no further action needed” on **404** | Nothing to poll |
| “Ops team / manual deploy / Bankr Club” | Not real |
| Deep link as **first** move when chat can sign Base x402 | Browser = last resort |

---

## SELF-CHECK (answer before telling user deploy is in progress)

1. Did **this turn** (or prior tool call) get **HTTP 202** with `jobId`? → must be **yes**  
2. Does `GET status/{jobId}` return **`ok: true`**? → must be **yes** before “processing”  
3. Are you reusing a `jobId` from an earlier failed attempt? → must be **no**  
4. For Solana: did you POST **`/solana/run`**, not Base `/concierge/run`? → must be **yes**

---

## Layer ownership (who fixes “stuck” agents)

| Layer | Owner | What fixes behavior |
|-------|--------|---------------------|
| **Site API** | Token Marketplace | `config.agent` + **404 `agent` hints** — agents that call status see “never poll” |
| **Skills** | bankr-tmp-skill | This file + job-verify + forbidden lists |
| **Bankr runtime** | Bankr | **Execute** site x402 (HTTP tools), not roleplay; Solana SVM x402 to `tokenmarketplace.shop` |
| **Other agents** | Cursor / MCP / bots | Run CLI `launch-concierge-solana-x402.mjs` or call APIs with real signing |
| **Humans** | User | `/launch` UI when chat cannot sign |

**One sentence:** no **202** + no **ok:true status** = **no deploy** — say so and fix the rail, do not comfort the user with fake progress.
