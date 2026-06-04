# Launch Studio autopilot — Bankr users → site x402 (primary)

**User language:** `launch-studio-user-language.md`  
**Payment rails:** **`launch-studio-payment-rails.md`**  
**Companion install:** `install TMP Launch Studio at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-launch-studio`

---

## Default for Bankr chat / X / terminal

**Bankr members deploy by paying site x402 on Launch Studio** — same model on **Base** and **Solana**:

| Chain | Wallet on site | Payment | Delivers |
|-------|----------------|---------|----------|
| **Base (Bankr token)** | Linked **Bankr EVM wallet** (`0x…`) | ~$1 USDC on Base (site x402) | 1000 hybrid TMPR units |
| **Solana (Pump.fun)** | **Solana pubkey** (Phantom / Solflare — same address Bankr uses for Solana sends) | ~$1 USDC on Solana (site x402) | 1000 SPL units |

Bankr can **send SOL/USDC on Solana** in chat, but Launch Studio still needs the user to **open the site**, connect that Solana wallet, and sign the x402 payment (one approval).

| Step | Agent action |
|------|----------------|
| 1 | Resolve linked Bankr wallet (`0x…`) |
| 2 | Map plain English → `tokenName`, `tokenSymbol`, `splitPlan` (`keep_all` or `wallet_list`) |
| 3 | **Open Launch Studio** (deep link below) — user connects **same wallet**, pays **site x402** |
| 4 | Wait ~1–3 min; units land on profile |
| 5 | Reply with token + profile / Bankr launches links |

**Do not** use Bankr x402 cloud (`x402.bankr.bot/…/token-marketplace-launch`) as the default — it is a separate rail and currently ops-blocked. **Do not** call `/concierge/run` yourself unless you implement site x402 signing with the user’s wallet.

---

## Launch Studio deep links (Bankr handoff)

**Base (Bankr deploy):**

```text
https://www.tokenmarketplace.shop/launch?surface=bankr&platform=bankr&wallet={linkedWallet}&name={tokenName}&symbol={tokenSymbol}&split=keep_all
```

**Solana (Pump.fun):**

```text
https://www.tokenmarketplace.shop/launch?surface=bankr&platform=pump&solWallet={solanaPubkey}&name={tokenName}&symbol={tokenSymbol}&split=keep_all
```

| Query | Purpose |
|-------|---------|
| `surface=bankr` | Bankr banner + handoff UX |
| `platform=bankr` \| `pump` | Base Bankr vs Solana Pump (also `chain=base` \| `solana`) |
| `wallet=0x…` | Base: connect this Bankr wallet; units deliver here for `keep_all` |
| `solWallet=` | Solana: connect this pubkey; SPL units deliver here for `keep_all` |
| `name` | Prefill token display name |
| `symbol` | Prefill ticker (no `$`) |
| `split` | `keep_all` or `wallet_list` |

**Open link:** `bankr.openExternal(url)` · paste in chat · terminal **Launch** tab → Base or Solana button.

---

## Agent steps (same thread)

### Base (Bankr token)

1. **Resolve** linked Bankr **EVM** wallet → `wallet=` query param.
2. **Send Base Launch Studio link** (table above).
3. **Tell user:** connect **Bankr wallet** on Base · pay ~$1 USDC (site x402) · keep all 1000 units · wait 1–3 min.
4. **Success links:** `profile?tab=nfts` · `bankr.bot/launches/{token}`

### Solana (Pump.fun)

1. **Resolve** user’s **Solana pubkey** (ask if not known — same wallet Bankr uses for Solana sends, or their Phantom address).
2. **Send Solana Launch Studio link** with `platform=pump&solWallet=…`.
3. **Tell user:** connect **same Solana wallet** on site · pay ~$1 **USDC on Solana** (site x402) · keep all 1000 SPL units · wait up to ~10 min.
4. **Success links:** `profile?tab=pump` · pump.fun coin link from job `result.links.token`

### Both

5. **Optional poll:** `GET …/api/launch/concierge/status/{jobId}` if user shares `jobId`.
6. **Offer next TMP actions** (list / transfer / claim — chain-appropriate skills).

**Forbidden:** stop after sending link without explaining pay + wait · claim Bankr x402 cloud works when it 502s · double-charge via Bankr x402 + site x402.

---

## Request fields (API agents with wallet x402 signing)

**Base:** `POST …/api/launch/concierge/run` · `deliveryAddress` = `0x…`

**Solana:** `POST …/api/launch/concierge/solana/run` · `deliveryAddress` = base58 pubkey

| Field | Required | Values |
|-------|----------|--------|
| `tokenName` | yes | min 2 chars |
| `tokenSymbol` | yes | no `$`, max 12 |
| `splitPlan` | yes | `keep_all` or `wallet_list` |
| `deliveryAddress` | yes for `keep_all` | EVM or Solana wallet receiving 1000 units |
| `walletList` | if `wallet_list` | multiline address + amount, **sum = 1000** |

Poll `statusUrl` from 202 until `completed`.

---

## Intent mapping

| User says | Action |
|-----------|--------|
| Deploy MOON on Token Marketplace, 1000 to my wallet | Base link: `platform=bankr&wallet=0x…` |
| Launch on **Solana** / **Pump.fun** | Solana link: `platform=pump&solWallet=…` |
| Launch $RKT on Pump, keep all units | `platform=pump&name=Rocket&symbol=RKT&split=keep_all` |
| Airdrop to wallet list | `split=wallet_list` — user fills list on site |
| Split **existing** $t7 | **NOT this flow** → `fractionalize-autopilot.md` |

---

## Errors

| Case | Reply |
|------|-------|
| User on wrong wallet on site | “Connect the same wallet you use in Bankr (Base `0x…` or Solana pubkey).” |
| Insufficient USDC on Base | “Need ~$1 USDC on Base in your Bankr wallet.” |
| Insufficient USDC on Solana | “Need ~$1 USDC on Solana in the wallet you connect on Launch Studio.” |
| Wallet launch limit (429) | “This wallet hit its Launch Studio limit — try another wallet.” |
| User asks to pay in chat only | Explain site x402 on Launch Studio is the supported path; open deep link |

---

## Legacy: Bankr x402 cloud (ops only)

`https://x402.bankr.bot/0x374d91a5674fa7cf86e725093b5848b97e1e13b4/token-marketplace-launch` — separate USDC payment, requires `async-start` secret sync + handler redeploy. **Not the default for members.** See `launch-studio-payment-rails.md`.
