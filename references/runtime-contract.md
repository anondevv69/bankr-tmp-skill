# TMP Runtime Contract (Bankr execution spec)

This file defines the non-negotiable runtime behavior for TMP skills.

Goal: when user says **"sell this token rights for 0.01"**, the agent should complete the full flow end-to-end (or fail with an explicit blocker), not stop halfway.

---

## 1) Scope

Applies to:
- mint + list 100% fee rights
- share-market buy/list (including password-gated)
- any flow with multiple dependent transactions

Non-goal:
- replacing product logic in `flows-reference.md` and feature playbooks

---

## 2) Hard guarantees

For every state-changing action:
1. **Submit tx**
2. **Wait for mined receipt**
3. **Verify post-state on-chain/API**
4. **Only then** report success

Never report success based on:
- simulation only
- tx submission only
- unsigned prepared calldata only

Never report failure if:
- there is already a mined success tx proving completion

---

## 3) Sell rights @ fixed price (autopilot contract)

User example: "sell this token rights for 0.01"

The runtime must do all of this in one conversation:

1. Resolve token -> launch metadata (`get_token_launch_info` or `token-fees`).
2. Confirm user has fee rights eligible to mint/list.
3. If TMPR missing: run mint sequence fully:
   - `prepareDeposit`
   - beneficiary transfer to escrow
   - `finalizeDeposit`
4. After each mint tx, wait for receipt + verify expected state transition.
5. Derive `tokenId`.
6. Call `POST /api/list/dual` with `{ tokenId, priceEth, seller }`.
7. Execute all returned `site.steps[]` via wallet tx flow.
8. Wait for receipts for each step.
9. Verify listing status via `GET /api/list/status?tokenId=`.
10. Return final user message with:
   - success state
   - tokenmarketplace listing link
   - OpenSea status (if applicable)
   - tx hashes (or compact refs)

Do not pause after mint saying "next do list". The runtime must continue unless a real blocker occurs.

---

## 4) Password-gated share buys (critical)

Required sequence:
1. Resolve tokenId + cheapest/selected listing.
2. Read `accessKeyHash(listingId)`.
3. If gated:
   - call `POST /api/listings/access-authorize`
   - execute 4-arg `buy(listingId, qty, authDeadline, signature)`
4. Wait for mined receipt.
5. Verify `balanceOf` delta or `TransferSingle` to buyer.

Rules:
- Simulation is optional preflight, not source of truth.
- BaseScan/receipt success beats earlier simulation revert.
- For free listings (`pricePerUnitWei == 0`), `msg.value` must be exactly 0.
- Do not tell user "buy manually" when success tx already exists.

---

## 5) Contract/source of truth hierarchy

When sources disagree, trust in this order:
1. Mined on-chain receipt + post-state read
2. Direct contract reads
3. Product API responses (`/api/list/status`, launch metadata)
4. Simulation results
5. Assumptions

---

## 6) Required integration capabilities

Runtime must have:
- Bankr tx execution (`bankr.tx.prepare` / `confirmTransaction`)
- token metadata resolver (`get_token_launch_info` and/or `token-fees`)
- listing APIs:
  - `POST /api/list/dual`
  - `GET /api/list/status`
  - `POST /api/listings/access-authorize` (for gated share buys)
- chain receipt waiting
- post-state reads (`balanceOf`, listing active/status reads)

If any are missing, agent must explicitly say:
- which capability is unavailable
- which step is blocked
- exact next action needed

---

## 7) Failure handling contract

Before declaring failure, agent must run these checks:
1. Did any submitted tx already mine successfully?
2. Did target state already change (ownership/listing active/balance)?
3. Is this a stale retry error (e.g. `ListingInactive` after fill)?
4. For gated flows, is auth ticket expired and refreshable?

Only after these checks can agent return a failure.

---

## 7b) Step limit and interrupted runs

Applies to **tweet**, **DM**, and **Ask Bankr** when the user asked to **sell/list 100% for X ETH** (or equivalent).

**Forbidden replies:**
- “I hit my step limit” / “try breaking it into smaller steps”
- “Your fee rights haven’t been converted to an NFT yet” **without** `GET /api/mint/status` → `phase`
- “Go update fee recipient on Doppler” when `phase` is `needs_transfer` or `needs_finalize` (use **`POST /api/bankr-build-transfer`** + **`finalizeDeposit`** per `nextStep`)

**When the turn ends before listing is live:**
1. Report **`phase`** from mint/status (e.g. `needs_transfer`, `needs_finalize`, `ready`).
2. State **who signs next** (`signerMustBe`) and **what API/tx** is next (`bankr-build-transfer`, `finalizeDeposit`, `list/dual`).
3. If one more tx was in progress, include BaseScan hash when mined.
4. **Continue in the same thread** (DM or tweet reply): user says “continue t7 list 0.01” → resume from current `phase`, do not restart with a Create NFT tutorial.

**Tweet / X:** Same autopilot as DM for clear sell-100% intent. Guidance-only is allowed only after a **real** blocker (no wallet, no signing capability, API error with no retry path) — not because the channel is public.

**Priority:** If user said **“on the marketplace”** only, finish **Token Marketplace** (`list/dual` + site steps) before treating OpenSea as required for success.

---

## 8) User response minimums

Every completed flow response must include:
- what action completed
- canonical link (tokenmarketplace share/listing URL)
- whether action is now live on-chain/site

For mint/create-NFT flows, response must also include:
- TMPR `tokenId`
- direct item link (OpenSea token page or canonical profile item route)
- explicit ownership confirmation source (`ownerOf(tokenId)` / receipt-backed proof)
- profile/indexer fallback note when UI is delayed

For errors:
- clear blocker
- what was already completed
- exact next step (single action)

---

## 9) QA acceptance criteria

A sell/list flow passes only if:
- no manual handoff occurs mid-flow
- all dependent txs are mined
- listing is verified active by status endpoint
- returned message includes listing URL

A mint/create flow passes only if:
- mint/finalize tx is mined
- owner is confirmed on-chain
- user gets a direct token link even if profile index is behind
- agent does not imply "mint failed" solely because profile page has not updated yet

A share buy flow passes only if:
- receipt mined
- holder balance increased or transfer event confirms
- no false "failed" message after successful tx

---

## 10) Canonical incident pattern (must handle)

Real-world pattern to prevent:
- User requests password buy on share page.
- First simulation reverts.
- A later tx actually succeeds on-chain.
- Agent still replies “failed / do it manually.”

Required handling:
1. If any tx hash exists, check receipt first.
2. If receipt is success, verify ownership delta and report success.
3. Mark later `ListingInactive` as expected if listing was filled by that success tx.
4. Never emit “I didn’t submit a tx” if a tx hash exists for this run.

Example reference tx:
- [Base tx `0x65d05ab67e1f7d07ed5e793c8aa33248fab8cb563d64400a0df2eddff4d92d7c`](https://basescan.org/tx/0x65d05ab67e1f7d07ed5e793c8aa33248fab8cb563d64400a0df2eddff4d92d7c)

