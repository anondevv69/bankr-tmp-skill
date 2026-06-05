# Agent Documentation Index

**Use this file to navigate all agent docs.** Each row links to a doc, its purpose, and when to load it.

---

## Core agent documentation (START HERE)

| File | Purpose | Size | When to use | Key takeaway |
|---|---|---|---|---|
| **AGENT-PARITY-AUDIT.md** | Complete mapping of all 10 flows (human ↔ agent) with algorithms, APIs, response templates, error handling | 1500 lines | **Debugging** a specific flow; **designing** agent routing; **writing** new response template | Every action has a required reply format; errors need user-friendly text, not jargon |
| **AGENT-QUICK-REFERENCE.md** | One-line lookup: user phrase → API → response template | 400 lines | **Agent needing instant answer** — "What API? What reply format?" | Agents should scan this when unsure of next step |
| **AGENT-VALIDATION-CHECKLIST.md** | End-to-end test checklist (happy + error paths) + mandatory guardrails | 800 lines | **Before deploying** agent update; **QA testing** new features; **post-incident** validation | Every flow has guards; breaking them (e.g., "ask site or OpenSea?") is a bug |
| **BANKR-AGENT-INSTALL.md** | Setup guide: what to install, how Bankr agent works, tests, common issues | 400 lines | **First-time Bankr integration**; **troubleshooting** setup; **validating** install block | Bankr must load all skills; agent must poll launches; response format is non-negotiable |
| **AUDIT-SUMMARY.md** | This audit's scope, findings, new docs created, next steps | 300 lines | **Quick overview**; **sign-off** + status; **post-audit** reference | Audit is complete; all gaps documented; ready for production |

---

## Autopilot skills (loaded by agent routing)

| Skill file | Loads when user says | Action | API(s) | Reference doc |
|---|---|---|---|---|
| **tmp-launch-studio/launch-studio-agent-autopilot.md** | "Deploy X on Bankr / Pump" | Deploy + x402 + poll | `POST /api/launch/concierge/run` or `/solana/run` → poll | AGENT-PARITY-AUDIT § Launch |
| **tmp-launch-studio/launch-studio-solana-autopilot.md** | "Deploy X via pumpfun" | Same (Solana variant) | Same + Solana keys | AGENT-PARITY-AUDIT § Launch |
| **references/petition-autopilot.md** | "Create petition for $TEST" / back pre-sale | Create + deposit + confirm + poll | `GET/POST /api/petition/*` | agent-guide § Petitions |
| **sell-list-autopilot.md** | "Sell X for 0.01 ETH" | List 100% (dual default) | `GET /api/mint/status` + `POST /api/list/dual` | AGENT-PARITY-AUDIT § Sell |
| **buy-fixed-sale-autopilot.md** | "Buy listing [URL]" | Buy whole TMPR | `GET /api/list/buy-status` | AGENT-PARITY-AUDIT § Buy |
| **share-market-buy.md** | "Buy cheapest share of $X" | Buy 1/1000 unit | `GET /api/share/list-status` | AGENT-PARITY-AUDIT § Buy shares |
| **share-market-list-autopilot.md** | "List 100 units at 0.0001 ETH" | List units on market | `GET /api/claim/hybrid-status` + on-chain `list` | AGENT-PARITY-AUDIT § List shares |
| **redeem-rights-playbook.md** | "Redeem / get rights back" | Burn TMPR | `redeemRights(tokenId)` on escrow | AGENT-PARITY-AUDIT § Redeem |
| **hybrid-claim-autopilot.md** | "Claim fees for $X" | Claim for all holders | `GET /api/claim/hybrid-status` + `claimFeesForToken` | AGENT-PARITY-AUDIT § Claim |
| **transfer-units-autopilot.md** | "Send 50 units to 0x…" | Transfer ERC-1155 | `safeTransferFrom` | AGENT-PARITY-AUDIT § Send |
| **fractionalize-autopilot.md** | "Split $X into 1000" | Finalize split | finalize on escrow | AGENT-PARITY-AUDIT § Fractionalize |

---

## Bankr install & reference

| File | Purpose | When to load |
|---|---|---|
| **BANKR-AGENT-INSTALL.md** | Setup guide + install block (copy-paste) + common issues | Bankr integration |
| **tmp-site-agent/agent-guide.md** | Site agent guide (canonical source) | Bankr agent initialization |
| **agent.md** (tokenmarketplace.shop) | Live agent guide (synced from repo) | Reference for what's deployed |

---

## Response templates quick lookup

| Action | Response file | Template location |
|---|---|---|
| **Deploy** (Base or Solana) | AGENT-PARITY-AUDIT.md | § 1. LAUNCH → Agent response template |
| **Sell** (100% fixed sale) | AGENT-PARITY-AUDIT.md | § 2. SELL → Agent response template |
| **Buy whole** | AGENT-PARITY-AUDIT.md | § 3. BUY → Agent response template |
| **Buy shares** | AGENT-PARITY-AUDIT.md | § 4. BUY SHARES → Agent response template |
| **List shares** | AGENT-PARITY-AUDIT.md | § 5. LIST SHARES → Agent response template |
| **Redeem** | AGENT-PARITY-AUDIT.md | § 6. REDEEM → Agent response template |
| **Claim fees** | AGENT-PARITY-AUDIT.md | § 7. CLAIM → Agent response template |
| **Send units** | AGENT-PARITY-AUDIT.md | § 8. SEND → Agent response template |
| **Solana sell** | AGENT-PARITY-AUDIT.md | § 9. SELL ON SOLANA → Agent response template |
| **Quick snippets** | AGENT-QUICK-REFERENCE.md | Response templates by action (condensed) |

---

## Error lookup

| Error scenario | Where to find fix | How to respond |
|---|---|---|
| `phase !== "ready"` (mint incomplete) | AGENT-PARITY-AUDIT.md § 2. Errors or AGENT-VALIDATION-CHECKLIST.md | "Fee rights not ready yet — finishing mint steps in this conversation" |
| `canBuy: false` | AGENT-PARITY-AUDIT.md § 3. Errors | "Listing inactive / sold / cancelled. Try [shop](URL)" |
| `WrongPayment` | AGENT-PARITY-AUDIT.md § 3. Errors | "Exact ETH required: [AMOUNT]. Retry." |
| `approve` blocked by Bankr | AGENT-PARITY-AUDIT.md § 2. Errors | "🔒 Contract safety check. Retry — if persists, use [browser UI]" |
| Agent says "paid" without jobId | AGENT-VALIDATION-CHECKLIST.md § Mandatory guardrails | ❌ Bug — agent must wait for 202 + jobId |
| Agent asks "site or OpenSea?" | AGENT-VALIDATION-CHECKLIST.md § Mandatory guardrails | ❌ Bug — default is dual; don't ask unless user said one venue |
| Full error table | AGENT-QUICK-REFERENCE.md | "Errors agent must handle" |

---

## Guardrails (things agent must NEVER do)

| Guardrail | Location | Why |
|---|---|---|
| **Never ask "all 1000 units?"** | AGENT-VALIDATION-CHECKLIST.md | Default is keep_all; don't ask |
| **Never ask "site or OpenSea?"** | AGENT-VALIDATION-CHECKLIST.md | Default is dual; don't ask unless user specified |
| **Never ask "claim for everyone?"** | AGENT-VALIDATION-CHECKLIST.md | Hybrid claims always pay all holders |
| **Never say "paid" without jobId** | AGENT-VALIDATION-CHECKLIST.md | No claim before 202 + jobId or explicit confirmation |
| **Never route `claim` to Bankr `claimtokenfees`** | AGENT-VALIDATION-CHECKLIST.md | Different product; hybrid claim is specific |
| **Never say "I hit step limit" while polling** | AGENT-VALIDATION-CHECKLIST.md | Complete the poll first |
| **Never use jargon in replies** | AGENT-PARITY-AUDIT.md § Response checklist | Users don't see: poolId, redeemRights, sellerKeepsBps |

Full guardrails: AGENT-VALIDATION-CHECKLIST.md § Mandatory guardrails

---

## Validation & QA

| Scenario | Checklist to use | What it covers |
|---|---|---|
| **Testing a new deploy flow** | AGENT-VALIDATION-CHECKLIST.md § ✅ Launch | Base + Solana, x402, polling, reply format |
| **Testing a sell flow** | AGENT-VALIDATION-CHECKLIST.md § ✅ Sell | Mint ready, dual list, site only, OpenSea |
| **Testing any buy flow** | AGENT-VALIDATION-CHECKLIST.md § ✅ Buy / Buy shares | Both fixed sale + share market separately |
| **After API change** | AGENT-VALIDATION-CHECKLIST.md § Post-update checklist | 10-item verification (schema, response, links, etc.) |
| **After agent failure** | AGENT-QUICK-REFERENCE.md § Errors or AUDIT-SUMMARY.md | Find error code → user-friendly response |

---

## File relationships (who references whom)

```
BANKR-AGENT-INSTALL.md (start here)
  ├→ references AGENT-PARITY-AUDIT.md (routing + templates)
  ├→ references AGENT-QUICK-REFERENCE.md (instant lookup)
  ├→ references AGENT-VALIDATION-CHECKLIST.md (tests)
  ├→ links to tmp-launch-studio/launch-studio-agent-autopilot.md
  ├→ links to sell-list-autopilot.md
  └→ links to all other autopilots

AGENT-PARITY-AUDIT.md (comprehensive)
  ├→ 10 complete flow sections
  ├→ response templates for each
  ├→ error handling for each
  └→ summary table at end

AGENT-QUICK-REFERENCE.md (fast lookup)
  ├→ one-line routing table
  ├→ response snippets (not full)
  └→ quick error table

AGENT-VALIDATION-CHECKLIST.md (QA)
  ├→ 10 flow sections
  ├→ happy path + error path for each
  └→ mandatory guardrails list

AUDIT-SUMMARY.md (status)
  ├→ what was audited
  ├→ findings ✅/⚠️
  ├→ new docs created
  └→ next steps
```

---

## Quick start (pick your role)

### I'm integrating Bankr agent
→ Load: **BANKR-AGENT-INSTALL.md** → copy install block → test one flow

### I'm debugging agent behavior
→ Load: **AGENT-QUICK-REFERENCE.md** (instant lookup) or **AGENT-PARITY-AUDIT.md** (full details)

### I'm QA testing a flow
→ Load: **AGENT-VALIDATION-CHECKLIST.md** § [flow name] → follow step-by-step

### I'm adding a new feature
→ Load: **AGENT-PARITY-AUDIT.md** (template structure) → write new section → add to checklist

### I'm validating post-update
→ Load: **AGENT-VALIDATION-CHECKLIST.md** § Post-update checklist → 10-item verification

### I need one-sentence answer
→ Load: **AGENT-QUICK-REFERENCE.md** → find user phrase → see API + template

---

## All docs are in

```
/Volumes/X9 Pro 1/repos/BankrSale/bankr-tmp-skill/
```

Files (alphabetical):
- AGENT-PARITY-AUDIT.md ← START HERE for comprehensive reference
- AGENT-QUICK-REFERENCE.md ← START HERE for instant lookups
- AGENT-VALIDATION-CHECKLIST.md ← START HERE for testing
- AUDIT-SUMMARY.md ← START HERE for status / overview
- BANKR-AGENT-INSTALL.md ← START HERE for setup
- [existing autopilot files] ← loaded by agent routing

---

**Agent documentation is complete. All flows mapped. All templates defined. Ready for production.**

