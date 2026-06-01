# Fractionalize / split into 1000 — full autopilot (mint + split)

> **Users never paste API URLs, escrow addresses, or “phase needs_prepare”.**  
> They say one plain sentence. **You** run this file silently.

**Also load:** `split-1000-autopilot.md` (V6 split steps after mint) · `mint-pending-deposit.md` (phase table) · `hybrid-escrow-mint-blocker.md` (when mint API reports platform blocker)

---

## What users say (enough — no technical version)

```text
@bankrbot fractionalize my $dntfbuy fee rights into 1000 shares — keep all units in my wallet
```

```text
@bankrbot split $t7 into 1000
```

```text
I just deployed $XXX — split into 1000 and keep them all
```

```text
@bankrbot make 1000 nfts for my token
```

**You interpret:** **1000 fee-right units** (ERC-1155 on hybrid `0xD8e0639…`), **not** 1000 ERC-721 receipts · **not** `list/dual` sell-100%.

**Clarify once if they say “1000 nfts”:**

```text
Splitting into 1000 tradeable fee-right units (1/1000 of trading fees each), not 1000 separate receipt NFTs. Starting now.
```

Then **execute** — do not wait for confirmation unless mint will take multiple signatures and they have no ETH.

---

## Mandatory agent sequence (one conversation)

### Step 0 — Resolve token

- Ticker (`$dntfbuy`) or launch `0x972f…` → **`get_token_launch_info`** / Bankr token-fees.
- **Never** use `0x935e…` ($TMP marketplace token) for user launches.

### Step 1 — Mint status (silent, every time — ignore prior chat)

```http
GET https://www.tokenmarketplace.shop/api/mint/status?tokens=<launch_0x>&wallet=<linked_bankr_wallet>
```

Example (dntfbuy): `?tokens=0x972f66770a4Bc44Afd91d004F290354864ff3ba3`

Read **`phase`**, **`signerMustBe`**, **`nextStep`**, **`platformBlocker`**, **`nextStep.preflight.ok`**, **`mintEscrow`**.

**If `mintEscrow` is `0xf2880E4BC798FFF7AF14542DB9ae2980a0D14B86` and `preflight.ok === true` and no `platformBlocker`:** mint is **live** — execute **`prepareDeposit`** immediately. **Do not** say “platform issue / retry later” (that was only for broken `0x047B…`).

| `phase` | You do (same thread) |
|---------|----------------------|
| `needs_prepare` | Submit **`nextStep.data`** to **`nextStep.to`** from **`signerMustBe`** — only if **`nextStep.preflight.ok`** OR you submitted and got a mined success receipt |
| `needs_transfer` | **`POST /api/bankr-build-transfer`** per `nextStep.post` → then **`finalizeDeposit`** |
| `needs_finalize` | **`finalizeDeposit`** from **`signerMustBe`** |
| `ready` | Skip to Step 2 (split) |
| `platformBlocker` present | **`hybrid-escrow-mint-blocker.md`** — plain English to user; **no** Doppler dashboard |

**Loop:** Re-fetch mint/status after each mined tx until **`phase === "ready"`**.

---

## Autopilot rule — never stop after one tx (critical)

After **`prepareDeposit`** mines, the user must **not** say “okay”, “please continue”, or “what’s next?” — **you** continue in the **same turn** (or immediate next assistant message) without waiting.

| After this mines | You do next (same conversation) | Forbidden |
|------------------|----------------------------------|---------|
| `prepareDeposit` success | `GET /api/mint/status` → expect **`needs_transfer`** → run **`POST /api/bankr-build-transfer`** from `nextStep.post` → then **`finalizeDeposit`** | “I’ll continue with beneficiary transfer now” then **stop** · ask user to confirm · Doppler dashboard |
| `bankr-build-transfer` / beneficiary moved | Re-fetch mint/status → **`needs_finalize`** → **`finalizeDeposit`** | Stop for user “okay” |
| `finalizeDeposit` success | Re-fetch → **`phase: ready`** → **Step 2 split** (V6) | “Mint done, tell me when you want to split” |

**Status messages are OK** (“Beneficiary transfer submitted…”) only if the **next tx is already in flight** in the same turn. Never end the turn with only a plan.

**If user says “okay” / “please continue”:** treat as resume signal — `GET /api/mint/status` and execute **current** `nextStep` (do not re-explain or restart prepareDeposit unless phase says `needs_prepare` again).

**PrepareDeposit already done (dntfbuy example):** tx `0x7889889892c585cd2be1aff33f9642c18911f12c9fd1bec1ae3d83ab8db79ef7` → skip prepare → beneficiary transfer → finalize → split 1000.

### Step 2 — Split into 1000 (V6, keep all)

1. **GroupBuyEscrowV6** `0x56bd948671955D0Ed82a88f136779cB76f551e0C`: approve hybrid TMPR → `createPartialSale` (private self-split) → `contribute` → `finalize`. If custodial **`approve`** blocked → **`split-custodial-approve-block.md`** (do not stop at “wait hours”).
2. User receives **1000 units** on hybrid collection.
3. **`GET /api/claim/hybrid-status?token=<launch>&wallet=<linked>`** — confirm **`unitsHeld`** ≈ 1000.

Details: **`split-1000-autopilot.md`** · **`TOKEN-SETUP-COMPLETE-GUIDE.md`** Flow C.

### Step 3 — Reply (plain English)

```text
Done — $dntfbuy fee rights are split into 1000 units in your wallet. You can list units on https://www.tokenmarketplace.shop from your profile.
[tx links]
```

---

## FORBIDDEN — never say this to users

| Forbidden | Why |
|-----------|-----|
| “Update fee recipient on the **Doppler dashboard** to escrow `0x047B…`” | Wrong order; **`t7-list-failure-regression.md`** |
| “Call **GET /api/mint/status** and paste the result” | User should not run APIs — **you** do |
| “Hybrid escrow **0x047B** reverted — you need platform insight” | Say: “marketplace mint is temporarily blocked; your launch is fine” |
| “Simulation failed — do it manually on Doppler” | Retry mint/status phases; escalate ops if **`platformBlocker`** |
| Skip mint and run split | Split requires **`phase: ready`** |
| `POST /api/list/dual` | That is sell-100%, not fractionalize |
| Stop after failed `prepareDeposit` without re-fetching mint/status | May already be `needs_transfer` |
| End turn after `prepareDeposit` waiting for user “okay please” | **Autopilot rule** — continue beneficiary + finalize + split |
| “I’ll continue with beneficiary transfer now” with no tx | Must submit transfer in same turn |

---

## If `platformBlocker` on mint/status (e.g. dntfbuy / hybrid escrow)

**User-facing (example):**

```text
Your $dntfbuy launch is set up correctly. Token Marketplace can't complete the fee-rights NFT mint right now because of a platform escrow issue (not something you fix in Doppler). I've flagged this for ops. Retry fractionalize tomorrow, or ask me to list/sell the whole receipt once mint works.
```

**You:** Do **not** send them to Doppler. See **`hybrid-escrow-mint-blocker.md`**.

---

## After deploy (compound intent)

User does **not** need a second message. **Deploy + fractionalize** in one thread:

1. Mint (Step 1) until `ready`
2. Split (Step 2)

---

## Cross-links

- `ONE-LINE-INTENTS.md` — Flow C  
- `runtime-contract.md` — one conversation, no handoff  
- `t7-list-failure-regression.md` — Doppler / simulation failures  
- `MARKETPLACE-UI-TO-BANKR-MAPPING.md` — Split 1000 row
