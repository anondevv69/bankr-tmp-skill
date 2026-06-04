# Bankr Agent Install & Setup Guide

**After installing these skills, your Bankr agent will:** Deploy, sell, buy, redeem, claim, and transfer token fee rights — **same as a human on the website, but fully automated in chat.**

---

## What to install

### Core: Token Marketplace site agent guide

```text
install TMP site agent at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-site-agent
```

**What:** Base autopilots + Solana guide + routing docs  
**Provides:** `agent.md` + `agent-guide.md` + flow specs

---

### Launch: Deploy new tokens (Base + Solana)

```text
install TMP Launch Studio at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-launch-studio
```

**What:** Deploy with site x402 + poll + 3-part reply  
**Files:**
- `launch-studio-agent-autopilot.md` — Base deploy (Bankr)
- `launch-studio-solana-autopilot.md` — Solana deploy (Pump.fun)
- `launch-studio-completion-reply.md` — Response template (3-part)
- `launch-studio-async-polling.md` — Mandatory poll loop
- `launch-studio-bankr-mirror-website.md` — Human ↔ agent parity
- **`BANKR-LAUNCH-REQUIREMENTS.md`** — Routing guard (no fake jobId / no poll on 404)
- **`AGENT-LAUNCH-VERIFICATION.md`** — Pass/fail test for deploy in chat

---

### All operations: Sell, buy, claim, send, redeem

```text
install TMP skills at https://github.com/anondevv69/bankr-tmp-skill
```

**What:** All post-launch flows + error handling  
**Key files:**
- `sell-list-autopilot.md` — List fee rights for ETH (dual default)
- `buy-fixed-sale-autopilot.md` — Buy whole TMPR
- `share-market-buy.md` — Buy 1/1000 units
- `share-market-list-autopilot.md` — List units on market
- `hybrid-claim-autopilot.md` — Claim fees for all holders
- `redeem-rights-playbook.md` — Burn TMPR, get beneficiary back
- `transfer-units-autopilot.md` — Send / gift / airdrop units
- `fractionalize-autopilot.md` — Split into 1000 units

---

### Parity & validation (for setup / debugging)

```text
Read these repo files (installed locally):
- AGENT-PARITY-AUDIT.md — Full flow mappings + response templates
- AGENT-QUICK-REFERENCE.md — One-line routing lookup
- AGENT-VALIDATION-CHECKLIST.md — End-to-end test checklist
```

---

## How Bankr agent works (one message = full flow)

### User → Bankr → Action → Website APIs → Bankr replies

**Example: Deploy**

```text
USER: Deploy MyToken on tokenmarketplace via Bankr, split 600 to me and 400 to 0x20Fd…

BANKR:
1. Parse intent → name="MyToken", symbol="MYTKN", split=[me:600, 0x20Fd:400]
2. GET config → read x402 price (~$1 USDC), treasury, facilitator
3. Build JSON body (same as website form)
4. Sign USDC with Bankr custodial wallet
5. POST to site x402 → 402 (requires payment) → sign again → 202 + jobId
6. Poll every 15–30s until status === "completed"
7. Extract result: token address, receipt serial, all tx hashes
8. Reply (3-part):
   - Part 1: Deployment info (token, units, wallet, receipt)
   - Part 2: All transaction links (Deploy, Mint, Split, Deliver)
   - Part 3: Next-step offers + full shop URL
```

**Example: Sell**

```text
USER: List MyToken for 0.01 ETH

BANKR:
1. GET mint/status → check if fee rights ready
2. POST list/dual → get calldata for site + OpenSea
3. Sign approve + list on chain (seller pays Base gas)
4. Verify listing live: GET list/status
5. Load opensea-marketplace skill → complete Seaport leg (same turn)
6. Reply with shop URL + OpenSea URL + next steps
```

---

## Required: Bankr custodial wallet setup

For **launch** (x402) and **optional** for other flows:

- [ ] **Bankr owns custody of**:
  - User's **Base USDC** (for ~$1 x402 per deploy)
  - User's **Solana USDC** (for Pump deploys)
  - User's **Base wallet** (for approve/list/buy ETH txs — optional; user can also sign)

- [ ] **Bankr must NOT require**:
  - Browser window
  - "Open Launch Studio" links
  - "Connect wallet on the site"
  - Any human interaction

---

## Skills load order (Bankr integration)

When user says any action, Bankr routing loads:

```
User message
  ↓
BANKR ROUTING (built-in)
  ├→ Deploy / launch? → tmp-launch-studio/launch-studio-agent-autopilot.md
  ├→ Sell / list? → sell-list-autopilot.md
  ├→ Buy whole? → buy-fixed-sale-autopilot.md
  ├→ Buy shares? → share-market-buy.md
  ├→ Claim fees? → hybrid-claim-autopilot.md
  ├→ Redeem? → redeem-rights-playbook.md
  ├→ Send units? → transfer-units-autopilot.md
  ├→ Solana? → tmp-solana-cto/* files
  └→ Unknown? → agent.md (site guide)
  ↓
API CALLS (to tokenmarketplace.shop or on-chain)
  ↓
SIGN TRANSACTIONS (Bankr custodial or user wallet)
  ↓
VERIFY & REPLY (formatted 3-part for launch, standard for others)
```

---

## Validation: Did it work?

### After install, test each flow

**Deploy (Base):**
```text
Deploy TestToken on Bankr — all 1000 to my wallet
```
- [ ] Agent doesn't ask for browser
- [ ] Agent posts x402 (USDC payment)
- [ ] Agent polls (don't see "processing" then stops)
- [ ] Reply has: token contract link + all tx links + profile URL + next steps

**Deploy (Solana):**
```text
Deploy SolToken via pumpfun — all 1000 to my Solana wallet
```
- [ ] Same x402 + poll (may take longer, 10 min OK)
- [ ] Reply has: Pump.fun link + Solscan txs + profile?tab=pump

**List:**
```text
List TestToken for 0.01 ETH
```
- [ ] Agent doesn't ask "site or OpenSea?"
- [ ] Both legs execute (same turn)
- [ ] Reply has: shop URL + OpenSea URL + tx links

**Buy:**
```text
Buy [SHOP_URL]
```
- [ ] Agent reads URL, finds listing
- [ ] Agent buys with exact ETH
- [ ] Reply has: price, seller, tx link

**Buy shares:**
```text
Buy 1 share of TestToken at best price
```
- [ ] Agent finds share market
- [ ] Agent buys cheapest offer
- [ ] Reply has: token, qty, price, holdings link

**Claim:**
```text
Claim fees for TestToken
```
- [ ] Agent claims for **all holders** (not just user)
- [ ] Reply explains: "distributed pro-rata to 1000 units"

**Redeem:**
```text
Redeem TestToken
```
- [ ] Agent finds TMPR in user's wallet
- [ ] Agent burns it
- [ ] Reply confirms: "Fee beneficiary restored to your wallet"

**Send:**
```text
Send 50 units of TestToken to 0x…
```
- [ ] Agent transfers ERC-1155 units
- [ ] Reply confirms recipient balance

---

## Common issues & fixes

| Issue | Check | Fix |
|---|---|---|
| Agent asks "site or OpenSea?" | sell-list-autopilot.md default | Default is **dual**; don't ask unless user said one venue |
| Agent says "approved" but not listed | Mint not ready | Check `phase === "ready"` before list; finish mint steps first |
| "Job still processing" then stops | No polling | Agent **must poll** `status/{jobId}` every 15–30s until `completed` |
| Approve blocked by Bankr | Custodial signer safety | Retry; if persists, may be new contract — wait for GoPlus reputation |
| No Solana x402 signature | Bankr product gap | Fall back to browser Launch Studio link + explain |
| Share market list fails | Not split yet | User must split/finalize first; check `unitsFinalized` |
| Claim says "no fees yet" | Trading hasn't happened | Normal; fees accrue only after trades. Claim again later. |
| Redeem fails "not owner" | Wrong wallet | Must sign from `ownerOf(tokenId)` on OpenSea; not seller or custodial escrow |

---

## Response format (agents must follow)

Every action reply:

1. **Status** — ✅ Success emoji + action verb ("Deployed", "Listed", "Bought")
2. **Info summary** — Token name, symbol, price (if applicable), wallet, qty
3. **Transaction links** — All explorer URLs (BaseScan / Solscan), not bare hashes
4. **Shop/profile links** — Full `https://www.tokenmarketplace.shop/…` URLs
5. **Next steps** — 1–4 plain-English offers ("List for 0.01 ETH", "Send to another wallet", "Claim fees")

❌ **Never reply with:**
- One-liner ("It's live!") — must be 3-part
- Bare tx hashes (need clickable links)
- Jargon (`redeemRights`, `poolId`, `sellerKeepsBps`)
- "Tell me to retry" during polling — complete the full flow first
- "Open the site" unless agent truly can't sign x402

---

## Bankr install block (copy-paste for your bot)

```text
install TMP site agent at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-site-agent
install TMP Launch Studio at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-launch-studio
install TMP skills at https://github.com/anondevv69/bankr-tmp-skill
```

Then load parity docs for reference:
- Routing: `AGENT-PARITY-AUDIT.md`
- Quick lookup: `AGENT-QUICK-REFERENCE.md`
- Validation: `AGENT-VALIDATION-CHECKLIST.md`

---

## Support docs (if agent needs to escalate)

| Situation | Doc to read |
|---|---|
| **Agent confused about which API** | `AGENT-QUICK-REFERENCE.md` (one-line routing) |
| **Agent needs response template** | `AGENT-PARITY-AUDIT.md` (all templates) |
| **Agent failed a flow** | `AGENT-VALIDATION-CHECKLIST.md` (step-by-step guards) |
| **Website and agent don't match** | `AGENT-PARITY-AUDIT.md` (human ↔ agent parity section) |
| **Bankr custody wallet setup** | This file (Bankr custodial wallet setup section) |
| **Solana gaps** | `agent.md` § **Solana support** or escalate to ops |

---

## After launch: Keep parity alive

**Every time you update:**

1. **API change** → update matching autopilot file + `AGENT-PARITY-AUDIT.md` response template
2. **New error** → add to `AGENT-VALIDATION-CHECKLIST.md` error section
3. **UI feature added** → add user phrase to `agent.md` + autopilot routing table
4. **Bankr signer blocked** → document in `CUSTODIAL_APPROVE_BLOCK_FIX.md` + reference in autopilot

**Sync to production:**
- Merge all files to `fee-rights-exchange/bankr-app/public/agent.md`
- Deploy to `tokenmarketplace.shop` (so live agent.md is current)
- Verify Bankr fetches latest (check Bankr install block dates)

