# Bankr platform fix — tweet intake must load skill before list tools

> **Audience:** Bankr engineering / agent runtime owners — not end users.  
> **Skill content is correct** (`sell-list-autopilot.md`). Tweet execution may skip it — same class of bug as hybrid claim intake.

---

## User tweet wording — sufficient TRIGGER

**Users should say (no skill jargon):**

```text
@bankrbot list 0x9021… for 0.01 eth
@bankrbot can you list t7 for sale for 0.01 ETH?
@bankrbot sell this token's fee rights for 0.01 on the marketplace
```

**Users must NOT need:**

```text
use_skill bankr-fee-rights
use TMP skill to list
GET /api/mint/status
prepareDeposit then finalize
```

---

## Required platform behavior (tweet = DM)

On **every** tweet/DM matching list/sell TRIGGER (token + price in ETH):

```
1. MATCH trigger (list / sell / list for X eth + token or ticker)
2. use_skill("bankr-fee-rights")          ← BEFORE tool selection
3. Read sell-list-autopilot.md (repo root)
4. GET …/api/mint/status?tokens=<launch>&wallet=<linked>
5. Execute each nextStep until phase === "ready":
     needs_prepare → prepareDeposit
     needs_transfer → POST /api/bankr-build-transfer → finalizeDeposit
     needs_finalize → finalizeDeposit (signerMustBe)
6. POST …/api/list/dual { tokenId, priceEth, seller }
7. Execute site.steps[] (approve → list on FeeRightsFixedSale)
8. GET …/api/list/status?tokenId= — verify active
9. Reply on X with FULL siteListingUrl + tx hash
```

**Hard block:** Do not say “not in escrow” or “update Doppler beneficiary” before step 4 completes.

**Order bug to prevent:** Never tell user to set Doppler beneficiary to escrow **before** `prepareDeposit`.

---

## What the skill already knows (each step)

| Step | On-chain / API | User-facing (plain English) |
|------|----------------|----------------------------|
| 1 | `GET /api/mint/status` | “Checking your fee rights status…” |
| 2 | `prepareDeposit` | “Step 1 — registering deposit with escrow” |
| 3 | Beneficiary → escrow (`bankr-build-transfer`) | “Moving fee stream to escrow (Bankr wallet signs)” |
| 4 | `finalizeDeposit` | “Minting your TMPR receipt NFT” |
| 5 | `POST /api/list/dual` + approve + list | “Listing on Token Marketplace at 0.01 ETH” |
| 6 | Verify list/status | “Live: [full shop URL]” |

Signer often = Bankr custodial wallet (`signerMustBe` from API) — agent executes via Bankr tx tools, not “go to website.”

---

## Acceptance test

**Tweet:**

```text
@bankrbot list 0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3 for 0.01 eth
```

**Pass:**

- Runtime log shows `GET /api/mint/status` **before** any list tx.
- Mint phases complete OR agent reports exact `phase` + next signer.
- Mined list tx on `FeeRightsFixedSale` / dual list path.
- Reply includes `https://www.tokenmarketplace.shop/listing/sale/…` or `siteListingUrl`.

**Fail:**

- “Listing failed — not in escrow” without mint/status.
- “Update fee recipient on Doppler dashboard first.”
- OpenSea-only list with no site URL.

**Pre-check:**

```bash
curl "https://www.tokenmarketplace.shop/api/mint/status?tokens=0x9021…&wallet=<linked>"
```

---

## Cross-links

- **`sell-list-autopilot.md`** — full autopilot
- **`t7-list-failure-regression.md`** — forbidden replies
- **`BANKR-PLATFORM-TWEET-INTAKE.md`** — claim-fees tweet fix (parallel spec)
- **`AGENT-ROUTING-LISTINGS.md`** — default venue = site

---

## One-line summary

> Tweet “list X for 0.01 eth” must auto-load `bankr-fee-rights`, call `GET /api/mint/status`, and run the full mint→dual-list pipeline — same as DM — without users saying “TMP skill”.
