# Launch Studio — plain language (user-facing)

**Read with:** `normal-talk-only.md` (main TMP hub). Users never say x402, `splitPlan`, or `walletList`.

---

## What Launch Studio is (tell users in one sentence)

> **Launch Studio** deploys your token on Token Marketplace, creates the fee-rights NFT, splits it into **1000 units**, and sends them to your wallet or your airdrop list — **one payment**, we sign the on-chain steps.

This is **not** the same as splitting a token you **already** launched elsewhere. If they say “split my **existing** $t7 into 1000”, use **`fractionalize-autopilot.md`** instead.

---

## Vocabulary

| User / UI says | Meaning |
|----------------|---------|
| **Launch Studio** / **launch on Token Marketplace** | New deploy + mint + 1000-way split + delivery |
| **1000 units** / **1000 shares** / **1000 fee-right pieces** | ERC-1155 units on hybrid TMPR (max 1000 per launch) |
| **Keep all** / **all to my wallet** | All 1000 units → one wallet (`keep_all`) |
| **Airdrop list** / **split to friends** | Custom amounts per address, must total **1000** (`wallet_list`) |
| **One payment on Bankr** / **pay in chat** / **agent deploy it** | Agent pays **~$1 USDC via x402** (site API or Bankr x402) — **no Launch Studio browser step** |
| **Launch on the website** | **Last resort** when agent cannot sign x402 |
| **Deployer** | Wallet shown in token description — on site/x402 this is the **payer**, not editable |

**Not the same:**

- **Launch new MOON** ≠ **fractionalize existing t7** — different flows.
- **1000 launch units** ≠ **buying 1 share** on someone else’s listing — latter is share market buy.
- **Launch Studio** ≠ **Bundle & Rebirth** — rebirth burns **existing** fee NFTs and merges streams.

---

## Valid user messages (route without jargon)

- “Deploy **MOON** on Token Marketplace and give me all 1000 units.”
- “Launch **Moon Token** / **$MOON** — keep everything in my Bankr wallet.”
- “Launch on Token Marketplace and airdrop **100** to `0xabc…`, **400** to `0xdef…`, **500** to `0x123…`.”
- “Launch **Rocket** on **Pump.fun** / **Solana** — 1000 units to my wallet.”
- “Deploy on Token Marketplace **Solana** with name **MOON** / **$MOON**.”
- “I want a new Bankr token with fee rights split — one USDC payment.”

**Compound is fine:** name + ticker + keep-all or wallet list in one message.

---

## What you may ask (at most one question)

| OK | Not OK |
|----|--------|
| “What should the token be called, and what ticker?” | “What is splitPlan?” |
| “All 1000 to your connected wallet, or split across addresses?” | “Paste walletList in API format” |
| “Those amounts need to add to 1000 — you have 950, add 50 somewhere?” | “Confirm x402 endpoint URL” |
| “Base launch via Bankr, or Solana on the website?” (only if they said Solana/Pump) | “Which marketplace?” |

Default: **linked Bankr wallet** receives units for **keep_all**. Default chain for Bankr chat: **Base** via x402.

---

## Success reply (mandatory — match website Done screen)

**Read:** **`launch-studio-completion-reply.md`** — full templates with BaseScan, OpenSea, Doppler, Bankr launches, Solscan, tx log.

After **`status: completed`**, reply with **all links** (not a one-liner). Minimum for **Base**:

```text
Done — Moon Token ($MOON) is live.

Token: 0x… 
1000 units → 0x374d91…

• BaseScan: https://basescan.org/address/0x…
• OpenSea: https://opensea.io/assets/base/…
• Doppler: https://app.doppler.lol/tokens/base/0x…
• Bankr: https://bankr.bot/launches/0x…
• Profile: https://www.tokenmarketplace.shop/profile?tab=nfts

Job ID: …
```

**Solana:** Pump.fun + shop listing + `profile?tab=pump` + Solscan tx links (see completion doc).

Tell users before pay: *“When Done appears, paste the Job ID back in chat for your full receipt.”*

---

## Solana (website only for now)

If user wants **Pump.fun / Solana** launch:

> Solana Launch Studio is on the site — open the **Solana / Pump.fun** link from chat (`platform=pump`), connect your **Solana wallet** (same one Bankr uses for Solana sends), pay **~$1 USDC on Solana** via site x402, keep-all or wallet list. Units show on **profile → Pump**.

Do **not** say “Bankr can’t launch” without pointing to the site.

---

## Pair with other TMP skills (suggest naturally)

After a successful launch, users often want:

| They say | TMP skill path |
|----------|----------------|
| “List MOON for 0.01 eth” | Main hub · `sell-list-autopilot.md` |
| “Send 50 units to my cofounder” | `transfer-units-autopilot.md` |
| “Claim fees for MOON” | `hybrid-claim-autopilot.md` |

One line in the success message is enough — do not require reinstalling skills.
