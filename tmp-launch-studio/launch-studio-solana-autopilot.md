# Launch Studio — Solana / Pump.fun (site x402)

**Same rail as Base:** site x402 on **`tokenmarketplace.shop`** — not `x402.bankr.bot`.

**Same product as `/launch` Pump tab:** agent fills JSON + signs Solana x402 + **polls until completed** + **3-part reply** (see agent-guide § *After launch*).

**Read with:** **`launch-studio-website-parity.md`** · **`launch-studio-agent-autopilot.md`** · **`launch-studio-async-polling.md`** · **`launch-studio-bankr-mirror-website.md`** · **`launch-studio-completion-reply.md`**

---

## User prompt (enough — example)

```text
Deploy SKT on Token Marketplace — name Solana Keep Test, all 1000 units to my Bankr wallet.
Deploy it on Pump.fun / Solana.
```

Agent maps:

| Field | Value |
|-------|--------|
| Chain | **Solana** |
| `tokenName` | `Solana Keep Test` |
| `tokenSymbol` | `SKT` |
| `splitPlan` | `keep_all` |
| `deliveryAddress` | Linked **Solana pubkey** (base58) — **not** EVM `0x…` |

**One question only if needed:** “Confirm your Solana wallet for delivery?” (use Bankr linked Solana address.)

---

## API

```http
GET https://www.tokenmarketplace.shop/api/launch/concierge/config
```

Check `config.solana.enabled` and `config.solana.x402`.

```http
POST https://www.tokenmarketplace.shop/api/launch/concierge/solana/run
Content-Type: application/json

{
  "tokenName": "Solana Keep Test",
  "tokenSymbol": "SKT",
  "splitPlan": "keep_all",
  "deliveryAddress": "<Solana base58 pubkey>"
}
```

1. POST → **402** → sign **~$1 USDC on Solana** (site x402).  
2. POST with payment header → **202** + `jobId`.  
3. Poll `GET …/status/{jobId}` every **15–30s** (up to **~10 min**).  
4. Reply per **`launch-studio-completion-reply.md`** (Pump, Solscan, `profile?tab=pump`).

**Payment wallet:** Solana wallet that holds **USDC on Solana** (often same as Bankr Solana send wallet).

---

## Wrong routing

| Wrong | Right |
|-------|--------|
| `deliveryAddress`: `0x374d…` (EVM) on Solana launch | Solana **pubkey** |
| `POST /concierge/run` (Base) for Pump request | `POST /concierge/solana/run` |
| “Bankr can’t launch Solana” | Site x402 Solana — same agent flow |
| Deep link without trying site x402 first | Programmatic `/solana/run` + poll |

---

## Fallback deep link (last resort)

```text
https://www.tokenmarketplace.shop/launch?surface=bankr&platform=pump&solWallet={base58}&name=Solana+Keep+Test&symbol=SKT&split=keep_all
```

Only if agent **cannot** sign Solana site x402.
