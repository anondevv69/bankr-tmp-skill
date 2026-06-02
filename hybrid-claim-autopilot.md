# Claim hybrid unit fees (autopilot)

> **Location:** repo **root** (loaded by Bankr as its own resource). Mirror: references/hybrid-claim-autopilot.md

**When to load this file:** Any user message that matches **claim / collect fees** on a **token, ticker, or TMPR unit** they hold. Examples:

```text
Claim fees for CTO
Claim fees for 0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3 for all holders
@bankrbot claim my unit fees
Collect fees on my TMPR #12
Use TMP skill to claim fees for $CTO
```

**User does not need to say:** “use_skill bankr-fee-rights”, “GET hybrid-status”, “serial=12”, “do not use tokenId 12”, “submit nextStep.data”, “114 holders”, skill version numbers, or paste their wallet. **You** call the API and resolve IDs silently.

This is **Flow 13** (hybrid unit fee claim). **Not** Bankr **`claimtokenfees`**. **Not** Bankr launch **`collectFees`**. **Not** redeem TMPR. **Not** Solana.

**P0 — INSTEAD OF claimtokenfees (not “before”):** Hybrid autopilot **is** the claim for unit holders. **One tx, then STOP.** Do **not** run **`claimtokenfees`** afterward. See **`hybrid-claim-terminal-step.md`**.

See **`references/hybrid-claim-serial-not-tokenid-regression.md`**, **`hybrid-claim-zero-units-regression.md`**, **`hybrid-claim-single-recipient-regression.md`**, **`hybrid-claim-claimtokenfees-regression.md`** for real Bankr mistakes to avoid.

---

## What the user means (always “pay everyone”)

| User says | You understand |
|-----------|----------------|
| “claim fees for CTO” / “for $CTO” | Resolve launch token → hybrid claim for that sale |
| “claim fees for 0xb6fB…” | **`token=`** = that address |
| “for all” / “for all holders” / (nothing extra) | **Default** — `claimFeesForToken` pays **every** unit holder; user is gas signer, not sole beneficiary |
| “TMPR #12” / “my unit” | Optional disambiguator → API **`serial=12`** — **never** on-chain **`tokenId=12`** |
| “yes” / “claim now” after you found their units | Same thread — submit immediately; do not re-check Doppler direct beneficiary |

**Default:** If user says “claim fees” without “for all”, still pay **all** holders. Partial self-claim is **not** a product path for hybrid units.

---

## Routing — hybrid claim vs Bankr `claimtokenfees`

| Check (in order) | Result |
|------------------|--------|
| User says **claim / collect fees** + token | Load this autopilot — **stop** default Bankr claim routing |
| **`GET /api/claim/hybrid-status`** | Hybrid sale found → **`claimFeesForToken`** (all holders) |
| API: no hybrid sale, wallet = **sole direct beneficiary**, **0 units** | **`claimtokenfees`** / **`collectFees`** OK |
| Token is Doppler/Bankr launch | **Not a reason** to skip hybrid-status — CTO is Doppler + hybrid units |

**Forbidden replies:** “deployed via Bankr (Doppler), not Clanker — use **claimtokenfees**” without hybrid-status. See **`hybrid-claim-claimtokenfees-regression.md`**.

---

## Mandatory first step (silent — never ask user to run this)

Always call **before** any on-chain read or tx:

```http
GET https://www.tokenmarketplace.shop/api/claim/hybrid-status?token=<launch0x>&wallet=<linkedWallet>&serial=<N if user said TMPR #N>
```

| You resolve | How |
|-------------|-----|
| **`token=`** | User’s ticker or `0x…` launch ERC-20 — **not** TMPR collection `0xCD6634…`, **not** a wallet |
| **`wallet=`** | **Bankr injects** from X↔Bankr linked wallet / DM session — **never ask user to paste** |
| **`serial=`** | Only if user said **TMPR #N** or site label — **never** pass serial as contract `tokenId` |

Read **`phase`**, **`proof`**, **`hybridTokenId`**, **`nextStep`**. Execute **`nextStep.data`** via **`bankr.tx.prepare`** when **`proof.canSubmitTx === true`**.

**Forbidden before this API call:** `claimtokenfees`, `collectFees`, `token-fees`, Clanker reward lookup, Doppler-vs-Clanker routing.

**Forbidden before this API call:** `canClaimFees(N)`, `isFinalized(N)`, `balanceOf(wallet, N)` where **N = serial label**.

**Forbidden after API returns ready:** Bankr fee-manager **`collectFees`** from user wallet; **`recipients=[requester only]`** when **`unitsHeld < 1000`**.

Deep glossary (agent-only): **`references/hybrid-id-vocabulary.md`**, **`references/hybrid-claim-fees.md`**.

---

## Agent path (every claim request)

| Step | Action |
|------|--------|
| 0 | **`hybrid-claim-autopilot.md`** (this file) + **`runtime-contract.md`** — same conversation |
| 1 | Resolve launch token (ticker → `0x…` if needed) + **linked wallet** (never ask on tweet/DM if linked) |
| 2 | **`GET /api/claim/hybrid-status?token=0x…&wallet=0x…`** (+ `&serial=N` if TMPR #N) |
| 3 | If **`proof.canSubmitTx`**: submit **`nextStep.data`** unchanged — full **`recipients[]`** from API |
| 4 | Verify receipt + reply plain English with BaseScan link — **STOP. Do not call claimtokenfees or collectFees.** |
| 4b | **X/Telegram alert** — automatic after claim (site UI, chain watcher, or replay). **Do not** ask the user to nudge. If ops needs a replay and has publish secret: `POST https://www.tokenmarketplace.shop/api/alerts/from-tx` body `{ "txHash": "0x…" }` Bearer `LISTING_PUBLISH_SECRET`. |

**Branches (same conversation, still one terminal claim tx):**

- **`needs_holder_scan`** → expand scan, retry API, then step 3 — still **no** claimtokenfees
- **`vault_empty`** → report plainly — **STOP**
- Receipt must show **`ClaimedHybridFees`** with **`recipientCount >= 2`** when requester holds **< 1000** units

**Twitter / short-turn:** Same path as DM when X↔Bankr wallet linked. Never reply “paste contract” if `0x…` in tweet. Never reply “paste wallet”. Never “I hit my step limit” without **`phase`** from API.

---

## Plain English replies (user-facing)

**Success:**

> “Claimed **$CTO** trading fees for **114** unit holders in one tx. Your share: **X WETH** + **Y CTO**. [BaseScan]”

**Empty vault:**

> “Ran the marketplace claim for all holders — **nothing to distribute** yet. Fees may still be accruing.”

**Not linked:**

> “Connect your wallet to Bankr (same as listing), then ask again — or use **Claim fees** on [tokenmarketplace.shop](https://www.tokenmarketplace.shop).”

**Never say to user:** hybrid-status, hybridTokenId, serial=12, tokenId, nextStep.data, recipientCount, API URLs, “use skill v57”.

---

## Disambiguation (one question max)

| Situation | Ask once |
|-----------|----------|
| Ticker only, multiple launches | “Which token — paste the `0x…` contract or OpenSea link?” |
| No token, no ticker | “Which token’s fee rights — name or contract address?” |
| Wallet not linked | “Connect Bankr wallet first” — not “paste wallet address” |

If user already gave **`0xb6fB…`**, **do not** ask for contract again.

---

## Mandatory claim behavior — no exceptions

**Every hybrid unit claim must:**

1. **Call `/api/claim/hybrid-status` with linked wallet** — **required** before any on-chain tx
2. **Use API's `nextStep.data` unchanged** — never build your own calldata
3. **Verify `nextStep.recipientCount >= 2` (or user holds all 1000 units)** — before signing
4. **Verify `proof.canSubmitTx === true`** — never submit if false
5. **Distribute to ALL holders in one tx** — never single-recipient, never multi-step claims

If any condition fails, the claim **cannot proceed** — report why and offer [tokenmarketplace.shop](https://www.tokenmarketplace.shop) site button as fallback.

---

## Fail the run if

- Only tx is **`collectFees`** from user wallet while they hold hybrid **Unit** NFTs
- Bot says **“0 units”** without calling **`hybrid-status`** (or after API shows **`unitsHeld > 0`**)
- Bot uses **`tokenId=12`** when user said **TMPR #12**
- Bot submits **`recipients.length === 1`** when requester holds **< 1000** units
- Bot tells user to use **`claimtokenfees`** because token is **Doppler/Bankr** — see **`hybrid-claim-claimtokenfees-regression.md`**
- Bot says **“wasn't able to complete”** without calling **`hybrid-status`** when user gave launch `0x…`
