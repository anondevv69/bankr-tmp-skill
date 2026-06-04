# Launch Studio autopilot — Bankr users → site x402 (primary)

**User language:** `launch-studio-user-language.md`  
**Payment rails:** **`launch-studio-payment-rails.md`**  
**Companion install:** `install TMP Launch Studio at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-launch-studio`

---

## Default for Bankr chat / X / terminal

**Bankr members deploy by paying site x402 on Launch Studio** with their **linked Bankr wallet**. Same pipeline as the website — one ~$1 USDC payment on Base, executor deploys + mints + splits 1000 units + delivers to that wallet.

| Step | Agent action |
|------|----------------|
| 1 | Resolve linked Bankr wallet (`0x…`) |
| 2 | Map plain English → `tokenName`, `tokenSymbol`, `splitPlan` (`keep_all` or `wallet_list`) |
| 3 | **Open Launch Studio** (deep link below) — user connects **same wallet**, pays **site x402** |
| 4 | Wait ~1–3 min; units land on profile |
| 5 | Reply with token + profile / Bankr launches links |

**Do not** use Bankr x402 cloud (`x402.bankr.bot/…/token-marketplace-launch`) as the default — it is a separate rail and currently ops-blocked. **Do not** call `/concierge/run` yourself unless you implement site x402 signing with the user’s wallet.

---

## Launch Studio deep link (Bankr handoff)

```text
https://www.tokenmarketplace.shop/launch?surface=bankr&wallet={linkedWallet}&name={tokenName}&symbol={tokenSymbol}&split=keep_all
```

| Query | Purpose |
|-------|---------|
| `surface=bankr` | Bankr banner + handoff UX |
| `wallet=0x…` | Hint: connect this Bankr wallet; units deliver here for `keep_all` |
| `name` | Prefill token display name |
| `symbol` | Prefill ticker (no `$`) |
| `split` | `keep_all` or `wallet_list` |

**Open link:** `bankr.openExternal(url)` · paste in chat · terminal app **Launch** tab → **Open Launch Studio**.

---

## Agent steps (same thread)

1. **Resolve** linked Bankr wallet → use as `wallet=` and delivery for `keep_all`.
2. **Confirm** name + ticker + plan only if missing from user message.
3. **Send Launch Studio link** with prefilled query params (see above).
4. **Tell user (plain English):**
   - Connect your **Bankr wallet** on Base (same address as in Bankr).
   - Pay **~$1 USDC** once (site x402 — one signature).
   - Choose **all 1000 units to my wallet** unless they asked for a wallet list.
   - Wait **1–3 minutes** on the page until done.
5. **Optional poll:** if user shares `jobId`, `GET https://www.tokenmarketplace.shop/api/launch/concierge/status/{jobId}` every 15–30s until `completed`.
6. **On success:** reply with `tokenAddress`, profile link, Bankr launches link:
   - `https://www.tokenmarketplace.shop/profile?tab=nfts`
   - `https://bankr.bot/launches/{tokenAddress}`
7. **Offer next TMP actions** (list / transfer / claim).

**Forbidden:** stop after sending link without explaining pay + wait · claim Bankr x402 cloud works when it 502s · double-charge via Bankr x402 + site x402.

---

## Request fields (for API agents with wallet x402 signing)

If the agent can sign **site x402** (not `bankr x402 call` — that only works on `x402.bankr.bot`):

1. `GET https://www.tokenmarketplace.shop/api/launch/concierge/config`
2. `POST https://www.tokenmarketplace.shop/api/launch/concierge/run` with x402 `payment-signature` header

| Field | Required | Values |
|-------|----------|--------|
| `tokenName` | yes | min 2 chars |
| `tokenSymbol` | yes | no `$`, max 12 |
| `splitPlan` | yes | `keep_all` or `wallet_list` |
| `deliveryAddress` | yes for `keep_all` | Bankr wallet receiving 1000 units |
| `walletList` | if `wallet_list` | multiline `0xAddress amount`, **sum = 1000** |

Poll `statusUrl` from 202 response until `completed`.

---

## Intent mapping

| User says | Action |
|-----------|--------|
| Deploy MOON on Token Marketplace, 1000 to my wallet | Link: `name=Moon Token&symbol=MOON&split=keep_all` |
| Launch $RKT, keep all units | `name=Rocket&symbol=RKT&split=keep_all` |
| Airdrop to wallet list | `split=wallet_list` — user fills list on site (or agent pre-parses for API path) |
| Split **existing** $t7 | **NOT this flow** → `fractionalize-autopilot.md` |
| Solana / Pump | `https://www.tokenmarketplace.shop/launch` Solana tab |

---

## Errors

| Case | Reply |
|------|-------|
| User on wrong wallet on site | “Connect the same Bankr wallet (`0x…`) you use in Bankr.” |
| Insufficient USDC on Base | “Need ~$1 USDC on Base in your Bankr wallet for Launch Studio.” |
| Wallet launch limit (429) | “This wallet hit its Launch Studio limit — try another wallet.” |
| User asks to pay in chat only | Explain site x402 on Launch Studio is the supported path; open deep link |

---

## Legacy: Bankr x402 cloud (ops only)

`https://x402.bankr.bot/0x374d91a5674fa7cf86e725093b5848b97e1e13b4/token-marketplace-launch` — separate USDC payment, requires `async-start` secret sync + handler redeploy. **Not the default for members.** See `launch-studio-payment-rails.md`.
