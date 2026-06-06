# Agent Quick Reference — One-line routing + response template lookups

**Use this when you need to:** instantly route a user phrase → find which API/skill → know what response format to use.

---

## User phrase → Action → API → Response file

| **User says** | **Action** | **First API** | **Response template file** |
|---|---|---|---|
| **Deploy X on Bankr / pumpfun** | Launch new token + 1000 units | `POST /api/launch/concierge/run` or `/solana/run` | `launch-studio-completion-reply.md` |
| **Create petition for $TEST** | 24h pre-sale → community launch | `GET /config` → `GET /prepare-deposit` → **`bankr.tx.prepare`** → `POST /confirm` | `petition-autopilot.md` |
| **Share link / participate / get N units** | Back existing petition from URL | `GET /status?url=` → `GET /prepare-deposit?url=` → **`bankr.tx.prepare`** → `POST /confirm` | `petition-autopilot.md` § P-back |
| **Buy N units in petition** | Pre-order + optional launch buy | `GET /prepare-deposit` → **`bankr.tx.prepare`** → `POST /confirm` | `petition-autopilot.md` |
| **Cancel empty duplicate petition** | Creator closes zero-sale petition | `POST /api/petition/cancel` | `petition-autopilot.md` § P-cancel |
| **Explain petition / how it works** | Read-only | Explain template in `petition-useskill-regression.md` | same |
| **Refund petition units** | While open/expired | `POST /api/petition/refund` | `petition-autopilot.md` |
| **List X on site only** (no venue) | List 100% site-only | Same | `sell-list-autopilot.md` |
| **Buy listing/sale/27** | Buy whole fee-rights TMPR | `GET /api/list/buy-status?listingId=27` | `buy-fixed-sale-autopilot.md` |
| **Buy cheapest share of X** | Buy 1/1000 unit | `GET /api/share/list-status?hybridTokenId=` | `share-market-buy.md` |
| **List 100 units at 0.0001 ETH** | List shares on market | `GET /api/claim/hybrid-status` → on-chain `list` | `share-market-list-autopilot.md` |
| **Redeem / get rights back** | Burn TMPR, restore beneficiary | `GET /api/mint/status` (escrow check) → `redeemRights(tokenId)` | `redeem-rights-playbook.md` |
| **Claim fees for X** | Distribute to all unit holders | `GET /api/claim/hybrid-status` → `claimFeesForToken` | `hybrid-claim-autopilot.md` |
| **Send / gift / airdrop units** | Transfer ERC-1155 units to recipient(s) | `GET /api/claim/hybrid-status` → `safeTransferFrom` | `transfer-units-autopilot.md` |
| **Sell for 0.01 SOL** | List on Solana CTO / share market | `GET /api/solana/claim-status` or SDKv1 | `tmp-solana-cto/solana-claim-autopilot.md` |
| **Fractionalize / split into 1000** | Post-deploy finalize | `GET /api/mint/status` → finalize on escrow | `fractionalize-autopilot.md` |

---

## Response templates by action (what agent must always reply)

### ✅ LAUNCH deployed

```text
🚀 Deployed $SYMBOL successfully!

**Deployment:**
• Token: $SYMBOL
• Contract: [LINK]
• 1000 units → [WALLET]
• Receipt (TMPR): #[SERIAL]

**Transactions:**
• [Deploy](BASESCAN_LINK)
• [Mint receipt](BASESCAN_LINK)
• [Split](BASESCAN_LINK)
• [Deliver](BASESCAN_LINK)

**Your units:** https://www.tokenmarketplace.shop/profile?tab=nfts

**What next?**
• List for 0.01 ETH
• List units on share market
• Send / gift units
• Claim fees later
```

### ✅ Listed fee rights

```text
✅ Listed $SYMBOL for 0.01 ETH

**Listing:**
• Price: 0.01 ETH
• Seller: [WALLET]
• TMPR: #[SERIAL]

**Transaction:** [LINK]

**Shop:** https://www.tokenmarketplace.shop/listing/sale/[ID]
**OpenSea:** https://opensea.io/assets/base/[COLL]/[ID]

**What next?**
• Cancel / update price
• List units instead
• Send to another wallet
```

### ✅ Bought fee rights

```text
✅ Bought $SYMBOL for 0.01 ETH

**Purchase:**
• Price: 0.01 ETH
• Buyer: [WALLET]

**Transaction:** [LINK]

**Your receipt:** On your wallet (serial #[N])

**What next?**
• List for higher price
• Split into 1000 units
• Send to another wallet
• Claim fees when accrue
```

### ✅ Bought shares

```text
✅ Bought 1 share of $SYMBOL

**Purchase:**
• Shares: 1/1000
• Price: 0.00001 ETH
• Your holdings: now [QTY]

**Transaction:** [LINK]

**Holdings:** https://www.tokenmarketplace.shop/profile?tab=nfts

**What next?**
• Buy more shares
• List these for sale
• Send to another wallet
```

### ✅ Listed shares

```text
✅ Listed 100 units of $SYMBOL

**Listing:**
• Units: 100 / 1000
• Price: 0.0001 ETH each
• Total value: 0.01 ETH
• Max per wallet: Unlimited

**Transaction:** [LINK]

**Share market:** https://www.tokenmarketplace.shop/listing/shares/t/[ID]

**What next?**
• Update price
• Add / cancel units
• Monitor sales
```

### ✅ Redeemed fee rights

```text
✅ Redeemed fee rights for $SYMBOL

**Redemption:**
• TMPR: Burned (#[SERIAL])
• Fee beneficiary: Restored to your wallet
• Token: $SYMBOL

**Transaction:** [LINK]

**You now:**
• Receive all trading fees directly
• Can claim via Doppler or marketplace
• Can re-list if you want to sell

**Fee status:** https://app.doppler.lol/tokens/base/[TOKEN_ADDR]
```

### ✅ Claimed fees

```text
✅ Claimed fees for $SYMBOL — all holders paid

**Claim:**
• Total holders: 114
• Fee pool: 0.456 ETH
• Distributed: pro-rata to all 1000 units

**Transaction:** [LINK]

**What next?**
• View your share on profile
• Claim again (new fees may accrue)
```

### ✅ Sent units

```text
✅ Sent 50 units of $SYMBOL to [RECIPIENT]

**Transfer:**
• Units: 50 / 1000
• From: [SENDER]
• To: [RECIPIENT]

**Transaction:** [LINK]

**What next?**
• Send more units
• List remaining units
• Batch airdrop
```

---

## Errors agent must handle

| **Error** | **Agent reply** |
|---|---|
| `phase !== "ready"` on mint | ⚠️ Fee rights not ready yet — finishing mint steps in this conversation |
| `canBuy: false` | ❌ Listing inactive / sold / cancelled. Try [shop](https://www.tokenmarketplace.shop/) |
| `WrongPayment` | ❌ Exact ETH required: [AMOUNT]. Retry with correct value. |
| `passwordProtected: true` | 🔐 Listing is password-gated. Provide password to unlock. |
| `MaxPerWalletExceeded` | ❌ This listing caps per wallet — lower qty or use another wallet |
| `UnauthorizedCaller` (redeem) | ❌ You don't own this TMPR. Sign from the wallet on OpenSea. |
| `RightsNotEscrowed` (redeem) | ❌ Fee rights already redeemed. Check [Doppler](https://app.doppler.lol/) if you're already fee recipient. |
| `approve` blocked by Bankr | 🔒 Contract safety check. Retry — if persists, use [browser UI](https://www.tokenmarketplace.shop) |
| No active listings | ❌ No one is selling [QTY] shares right now. Try [creating a group buy](https://www.tokenmarketplace.shop) |
| Job failed (launch) | ❌ Pipeline failed. Reason: [ERROR]. Contact support with Job ID [JOBID]. |

---

## Guardrails (do not break these)

✅ **Always:**
- Include full shop URLs (not bare txs)
- Offer next steps (1–4 options)
- List all transaction links
- Use plain English (no jargon)
- Poll after x402 (launch only)

❌ **Never:**
- Say "paid" without `202 + jobId` (launch)
- Ask "site or OpenSea?" (default dual, except user said one venue)
- Ask "all 1000 units?" (default keep_all)
- Route `claim` to Bankr `claimtokenfees` (different product)
- Say "I hit step limit" while polling (complete the poll first)

---

## Navigation

**For each action, load the corresponding autopilot skill:**

| If user says | Load file |
|---|---|
| **Deploy** | `launch-studio-agent-autopilot.md` + `launch-studio-solana-autopilot.md` |
| **Sell / list** | `sell-list-autopilot.md` + `LISTING-VENUES.md` |
| **Buy whole** | `buy-fixed-sale-autopilot.md` |
| **Buy shares** | `share-market-buy.md` |
| **List shares** | `share-market-list-autopilot.md` |
| **Redeem** | `redeem-rights-playbook.md` |
| **Claim** | `hybrid-claim-autopilot.md` |
| **Send** | `transfer-units-autopilot.md` |
| **Solana** | `tmp-solana-cto/*` |

**Master routing:** This file + linked autopilots → agent knows intent → finds API → executes → knows response format.

