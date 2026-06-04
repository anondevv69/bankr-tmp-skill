# MANDATORY — Token Marketplace site agent guide (Bankr)

Bankr agents **learn from installed skills**, not from “fetch this URL at runtime.” The site guide must be **installed as a skill pack**.

## Step 0 — install site agent skill

```text
install TMP site agent at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-site-agent
```

**Read:** **`tmp-site-agent/agent-guide.md`** (full contracts, APIs, Launch Studio §).

Live mirror for humans and other bots: **https://www.tokenmarketplace.shop/agent.md**

---

## How this pairs with TMP skills

| Source | Role |
|--------|------|
| **`tmp-site-agent/agent-guide.md`** | **Bankr:** install skill → read this file first |
| **`https://www.tokenmarketplace.shop/agent.md`** | Humans, Cursor, bots that can fetch URLs |
| **Hub autopilot `*.md`** | Step-by-step execution, forbidden replies, polling |

When editing the guide, update **`fee-rights-exchange/bankr-app/public/agent.md`** then run:

```bash
bankr-tmp-skill/scripts/sync-site-agent-guide.sh
```

---

## Full Bankr install stack

```text
install TMP site agent at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-site-agent
install TMP skills at https://github.com/anondevv69/bankr-tmp-skill
install TMP Launch Studio at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-launch-studio
```

Launch deploy: agent-guide § Launch Studio → **`launch-studio-agent-autopilot.md`** (Base) or **`launch-studio-solana-autopilot.md`** (Solana).
