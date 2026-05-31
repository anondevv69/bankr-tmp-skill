# Regression: “List t7 for 0.01” — Bankr bot handoff (May 2026)

> **Location:** repo **root** (Bankr resource). Mirror: references/t7-list-failure-regression.md


**Trigger phrases (user says only):**

- “List `0x9021f7edd729f39b6f6637d5ae3a7185634c3ba3` for 0.01 eth”
- “Can you try again and list it for 0.01 ETH?”
- “List the rights to this token for 0.01 eth”
- “@bankrbot using the tmp skill can you list my token $t7 for sale for 0.01 eth?”

**Agent must run `sell-list-autopilot.md` end-to-end.** User does **not** need to mention skill version or paste API URLs.

---

## Failed behavior (do not repeat)

| Bot said | Why wrong |
|----------|-----------|
| **“prepareDeposit is already active… manually update the fee recipient on Doppler to escrow… once updated let me know and I will call finalizeDeposit”** (@Rayblancoeth, May 2026) | **Forbidden.** `prepareDeposit` active = **`needs_transfer`** or **`needs_finalize`** — call **`POST /api/bankr-build-transfer`**, then **`finalizeDeposit`**, then **`POST /api/list/dual`** in **same** conversation. **Never** Doppler dashboard handoff. |
| “Listing failed — fee rights aren’t in escrow yet” | Mint incomplete — **finish mint**, don’t call it a listing failure |
| “Transfer fee recipient to escrow” then stop | Use **`POST /api/bankr-build-transfer`** + **`finalizeDeposit`** in same turn |
| “Update Doppler beneficiary to `0x6238…` manually” | **Never** point beneficiary at escrow **before** `prepareDeposit` |
| “You still hold 95% on Doppler” → give up | Normal **before** mint; run mint/status phases |
| “Simulation failed” → manual Doppler | Retry with correct **phase**, **signerMustBe**, **feeManager** |
| **“Minting’s stuck… fee rights ready in escrow, but `finalizeDeposit` reverted. Update fee recipient on Doppler, then say finalize t7 listing”** (May 2026, @Rayblancoeth) | **Forbidden.** Escrow holding shares is **expected** before finalize. Call **`GET /api/mint/status`** — if `needs_finalize`, run **`finalizeDeposit` from `signerMustBe`** (often Bankr `0x374D…`); if `needs_transfer`, run **`POST /api/bankr-build-transfer`** then finalize. **Never** send user to Doppler dashboard. Then **`POST /api/list/dual`** in the **same** conversation. |
| **“I hit my step limit… try breaking it into smaller steps”** | **Forbidden.** The skill is already the step breakdown. In constrained Twitter mode, call `mint/status`; execute the current `nextStep` if possible; otherwise report the exact `phase` + next signer/tx. |
| **“Your t7 fee rights haven’t been converted into an NFT yet”** without `mint/status` evidence | **Forbidden.** It may be true, but only say it after reading `phase`. Use the API phrase: `needs_prepare`, `needs_transfer`, `needs_finalize`, or `ready`. |

---

## Correct behavior (one conversation)

1. `GET /api/mint/status?tokens=0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3&wallet=<seller>`
2. Execute all `nextStep` until `phase: "ready"`
3. `POST /api/list/dual` `{ tokenId, priceEth: "0.01", seller }`
4. Run `site.steps[]` + OpenSea
5. **`GET /api/list/status?tokenId=`** — **`listedOnSite: true`** before “listed” reply
6. Reply: BaseScan txs + **full `siteListingUrl`** + marketplace links

If **mint/status API** returns 5xx, retry API once; then use on-chain reads + same phase table in `mint-pending-deposit.md` — still **no** Doppler dashboard handoff.

---

## User-facing reply (example)

> “Listing t7 at 0.01 ETH — finishing mint on Base, then dual listing on Token Marketplace and OpenSea. [tx links as they confirm]”

Not:

> “Go to Doppler and set fee recipient to escrow…”

---

## Cross-links

- `sell-list-autopilot.md` — full checklist  
- `mint-pending-deposit.md` — phase table  
- `runtime-contract.md` — no stop after prepare  
- `bankr-agent-test-prompts.md` — R1, R1b
