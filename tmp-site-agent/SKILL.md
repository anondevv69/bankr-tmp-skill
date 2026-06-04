---
name: tmp-site-agent
description: >-
  Token Marketplace site agent guide — golden rules, contract addresses, public APIs,
  shop URL patterns, Launch Studio site x402 (Base + Solana). Install for Bankr before
  any list, buy, claim, launch, or split on tokenmarketplace.shop. Same content as
  https://www.tokenmarketplace.shop/agent.md
tags: [bankr, base, solana, tmp, token-marketplace, agent-guide, apis, launch-studio, x402]
version: 1
tmp_skill_version: "1"
homepage: https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-site-agent
---

# TMP site agent guide (Bankr skill)

**This skill is the Bankr installable copy of the live site guide.**

| For Bankr | For humans / other bots |
|-----------|-------------------------|
| **Install this skill** — content in **`agent-guide.md`** | Browse **https://www.tokenmarketplace.shop/agent.md** |

## Install (Bankr)

```text
install TMP site agent at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-site-agent
install TMP skills at https://github.com/anondevv69/bankr-tmp-skill
install TMP Launch Studio at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-launch-studio
```

## MANDATORY — read before any TMP work

**Load the full guide:** **`agent-guide.md`** in this folder (contracts, APIs, Launch Studio §).

Then use hub autopilot files for step-by-step execution:

| Intent | Hub autopilot (main TMP skill) |
|--------|--------------------------------|
| List / sell | `sell-list-autopilot.md` |
| Buy | `buy-marketplace-autopilot.md` |
| Split existing token | `fractionalize-autopilot.md` |
| Launch new token + 1000 units | `tmp-launch-studio/launch-studio-agent-autopilot.md` |
| Claim fees | `hybrid-claim-autopilot.md` |

**Launch deploy (from agent-guide § Launch Studio):** site x402 on `POST /api/launch/concierge/run` (Base) or `/solana/run` (Solana) → poll → completion reply. **No Launch Studio deep link** when Bankr can sign site x402.

---

*Source of truth for edits: `fee-rights-exchange/bankr-app/public/agent.md` — keep in sync when site guide changes.*
