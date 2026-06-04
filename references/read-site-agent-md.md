# MANDATORY — read live Token Marketplace agent guide

**Before any Token Marketplace work** (list, buy, claim, launch, split, transfer, Solana CTO):

## Step 0 — fetch the canonical guide

```http
GET https://www.tokenmarketplace.shop/agent.md
```

**Read the full document.** It is the live source of truth for:

- Golden rules and intent → API routing
- Canonical contract addresses (Base + Solana)
- Public HTTP APIs and shop URL patterns
- **Launch Studio** — Path A (Base site x402), Path A2 (Solana), polling, completion reply

**Do not** rely on memory, old chat copies, or skill snippets alone. Always **GET this URL** at the start of a TMP session or when the user mentions Token Marketplace, Pump.fun launch, or fee rights on the shop.

---

## How this pairs with TMP skills

| Source | Role |
|--------|------|
| **`https://www.tokenmarketplace.shop/agent.md`** | Contracts, endpoints, rails, URL patterns — **read first** |
| **This repo** (`SKILL.md`, autopilot `*.md`) | Step-by-step execution, forbidden replies, polling, completion format |

If agent.md and a skill file disagree on **Launch Studio**, follow agent.md **§ Launch Studio** (site x402 on `/concierge/run` or `/solana/run` + poll). Deep links are **last resort** only when the agent cannot sign x402.

---

## Launch deploy (Bankr chat)

From agent.md **Launch Studio**:

1. `GET /api/launch/concierge/config`
2. `POST /api/launch/concierge/run` (Base) or `/solana/run` (Pump) + **site x402** (~$1 USDC)
3. Poll `GET /api/launch/concierge/status/{jobId}` until `completed`
4. Reply per **`launch-studio-completion-reply.md`** (token + all txs + offer to list)

Then load **`tmp-launch-studio/launch-studio-agent-autopilot.md`** (Base) or **`launch-studio-solana-autopilot.md`** (Solana) for field mapping and forbidden replies.

---

## Install reminder (for Bankr)

```text
Read https://www.tokenmarketplace.shop/agent.md
install TMP skills at https://github.com/anondevv69/bankr-tmp-skill
install TMP Launch Studio at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-launch-studio
```
