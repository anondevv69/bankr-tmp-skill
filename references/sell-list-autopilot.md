# Sell / list fee rights for X ETH (autopilot)

> **Bankr agents:** canonical copy is at repo root **`sell-list-autopilot.md`** (same content). Bankr often indexes `references/` as one folder and cannot see individual `.md` names — read the **root** file.


**When to load this file:** Any user message that matches **list / sell fee rights / sell 100%** with a **price in ETH** and optional **ticker or launch token `0x…`**. Examples:

```text
Can you list the rights to 0x9021f7edd729f39b6f6637d5ae3a7185634c3ba3 for 0.01 eth?
List my t7 for 0.01
@bankrbot sell this token's fees for 0.01 ETH
```

**User does not need to say:** “use tmp skill”, “v43”, “sell-list-autopilot”, or paste `GET /api/mint/status` URLs. **You** call those APIs.

This is **Flow 2** (sell 100%, dual list). **Not** share-market buy. **Not** partial sale (`sellerKeepsBps`).

**Do not reply** with "listing failed because fee rights aren't in escrow" and stop. That usually means **mint is incomplete** — finish mint, then list in the **same conversation**.

See **`t7-list-failure-regression.md`** for real Bankr bot mistakes to avoid.

### Twitter / short-turn fallback (prevents step-limit replies)

If running inside a tweet, DM, or any environment that may hit a step limit:

1. Still call **`GET /api/mint/status` first**. Never guess “not converted into an NFT yet.”
2. Execute the current **`nextStep`** if tools/signatures are available.
3. If the turn limit blocks completion, reply with the **exact `phase`**, the **exact next transaction/signing wallet**, and the marketplace link/state. Do **not** say “I hit my step limit.”
4. If the user only said **“on the marketplace”**, prioritize **Token Marketplace listing first**. OpenSea is a follow-up, not a reason to fail the marketplace listing.

Bad fallback:

> “I hit my step limit. Your fee rights haven’t been converted into an NFT yet.”

Good fallback:

> “I checked t7 status: `needs_transfer`. Next signature is from your Bankr wallet to move fees to escrow, then I can finalize the TMPR and list it on Token Marketplace at 0.01 ETH.”

---

## Mandatory first step: `GET /api/mint/status`

Always call before any mint or list tx for that token:

```http
GET https://www.tokenmarketplace.shop/api/mint/status?tokens=0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3&wallet=0x374D91a5674Fa7Cf86E725093b5848b97e1e13b4
```

Or `POST /api/mint/status` with `{ "tokens": ["0x…"], "wallet": "0x…" }`.

Read **`phase`** and execute **`nextStep`** from the JSON. Do **not** improvise dashboard steps.

| `phase` | What it means | Agent does next (same conversation) |
|---------|----------------|-------------------------------------|
| `ready` | TMPR exists in wallet | Skip mint → `POST /api/list/dual` → site steps → OpenSea |
| `needs_prepare` | No pending deposit | `prepareDeposit` from `nextStep` → then re-fetch status |
| `needs_transfer` | Prepare done; escrow needs shares | **`POST /api/bankr-build-transfer`** (body from `nextStep.post`) → wait receipt → **`finalizeDeposit`** from `nextStep.then` — **do not ask user to do this manually** |
| `needs_finalize` | Escrow holds shares | **`finalizeDeposit(poolId)`** from `nextStep` — signer = **`signerMustBe`** |
| `needs_transfer_tmpr` | TMPR on Bankr wallet | `safeTransferFrom` per `nextStep` → then list/bundle as directed |
| `not_beneficiary` | Wallet has no fee-manager shares | Explain they are not the on-chain beneficiary; fix wallet or token |

After mint reaches **`ready`**, immediately continue to list (runtime contract §3).

---

## Order of operations (never invert)

1. **`prepareDeposit`** — seller still holds fee-manager shares.
2. **Beneficiary → escrow** (`bankr-build-transfer` or Bankr transfer API).
3. **`finalizeDeposit`** — mints TMPR.
4. **`POST /api/list/dual`** + execute `site.steps[]` + OpenSea.

**Never** tell user to move Doppler beneficiary to escrow **before** `prepareDeposit`. That causes `getShares = 0` and prepare fails.

**Never** confuse:
- **Escrow allowlist** (`allowedFeeManager` on `0x6238…`) — usually already true for Bankr `0xBDF938…`.
- **Approve fee manager** — not required for `prepareDeposit`.
- **List** (`FeeRightsFixedSale 0xe2A1…`) — only after TMPR exists.

---

## User-facing language (good vs bad)

| Bad (stops user) | Good (autopilot) |
|------------------|------------------|
| "Listing failed — fee rights aren't in escrow yet" | "Finishing mint for t7, then listing at 0.01 ETH in this flow." |
| "Approve fee manager, then transfer recipient to escrow" | "Step 1 of 3 done — moving fees to escrow and minting your receipt now." |
| "Check your wallet activity to confirm the transfer" | "Confirming on Base… [tx link]. Next: list on marketplace + OpenSea." |
| "I can't list until you do X on Doppler dashboard" | Use **`/api/bankr-build-transfer`** unless API returns an error requiring manual Bankr/Doppler action |
| "`finalizeDeposit` reverted — update fee recipient on Doppler first" | **`GET /api/mint/status`** → `needs_finalize`: **`finalizeDeposit` from `signerMustBe`**; `needs_transfer`: **bankr-build-transfer** then finalize — **no** Doppler dashboard |

---

## Signer rules

- Steps after **`prepareDeposit`** often must be sent from **`signerMustBe`** in mint/status (frequently Bankr custodial `0x374D…`), not the user's EOA unless it matches `pendingSeller`.
- If user's wallet is not `signerMustBe`, say plainly: "Next signatures come from your Bankr wallet" — still **execute** via Bankr tx tools, do not hand off to website only.

---

## Full autopilot checklist (t7 @ 0.01 example)

1. Resolve `0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3` = **t7** (`get_token_launch_info` / token-fees).
2. `GET /api/mint/status` for token + seller wallet.
3. Run all `nextStep` actions until `phase === "ready"` and TMPR `tokenId` known.
4. `POST /api/list/dual` `{ tokenId, priceEth: "0.01", seller }`.
5. Execute every `site.steps[]` tx; wait mined receipts.
6. OpenSea listing via opensea skills.
7. `GET /api/list/status?tokenId=` — confirm active.
8. Reply with marketplace + OpenSea links and tx hashes.

---

## QA prompts

```text
List 0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3 for sale at 0.01 eth
```

```text
List my t7 fee rights for 0.01 ETH on marketplace and OpenSea
```

**Pass:** mint/status → complete pending mint steps → dual list → verification links.  
**Fail:** "listing failed" with no mint/status; manual Doppler instructions; stops after transfer without listing.

---

## Cross-links

- `mint-pending-deposit.md` — phase table detail  
- `runtime-contract.md` — no pause between mint and list  
- `flows-reference.md` — Flow 1 + Flow 2  
- `SKILL.md` — dual list API
