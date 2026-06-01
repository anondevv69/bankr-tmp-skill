# Regression: Bankr uses `0x935e…` (TMP platform token) instead of launch token (t7)

> **Location:** repo **root** mirror: `t7-wrong-token-935e-trap.md`

**Trigger:** User says **list $t7**, **list t7 for 0.01**, or any sell/list for a **Bankr launch ticker**.

---

## STOP — do not use these as the launch token

| Address | What it is | Never use for mint/status |
|---------|------------|---------------------------|
| `0x935e13a28849095db45e63040f109c34b757aba3` | TokenMarketplace **$TMP** ERC-20 | ❌ Not t7 |
| `0xCD66340D93E212bEC6Db1b22476e4f1276380C3e` | TMPR **collection** (all receipts) | ❌ Not t7 |
| `0x9a3C31fe809Fe17605ECa1b4FEf5598051404673` | Newer TMPR collection default | ❌ Not t7 launch |

**Correct t7 launch (Bankr Doppler ERC-20):**

`0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3`

---

## Failed behavior (May 2026 — do not repeat)

| Bot said | Why wrong |
|----------|-----------|
| Token `0x935e…aba3` (TokenMarketplace) | That is **$TMP**, not the user's t7 launch |
| `phase: needs_prepare` | t7 was already **`ready`** with TMPR minted |
| "Prepare deposit reverting" | Wrong path — should **list**, not re-mint |
| "Dual-list on ** and **OpenSea" | Broken template; never skip shop URL |

---

## Correct behavior

1. Resolve launch from **ticker** → `get_token_launch_info` / user paste → **`0x9021…3ba3`** for t7.
2. `GET /api/mint/status?tokens=0x9021F7eDd729F39b6F6637d5AE3A7185634C3ba3&wallet=<linked>`
3. Read **`phase`**, **`tmprTokenId`**, **`escrowMismatch`** (informational when `ready`).
4. If TMPR is on Bankr custodial wallet, pass **`seller`** = TMPR owner (`0x374D…` or `nextStep.tmprOwner`), not only the user's linked wallet unless they already hold the NFT.
5. `POST /api/list/dual` with **`tokenId`** = `tmprTokenId` from mint/status (decimal string).
6. Execute `site.steps[]` from the wallet that **owns** the TMPR.

---

## Agent reply when user only says "$t7"

```text
Checking t7 launch token 0x9021…3ba3 (not $TMP 0x935e…). Reading mint/status now.
```

---

## Cross-links

- `tmpr-collection-address-trap.md` — `0xCD66…` collection trap
- `t7-list-failure-regression.md` — Doppler handoff / prepareDeposit mistakes
- `linked-wallet.md` — custodial TMPR owner vs user linked wallet
- `sell-list-autopilot.md` — full list flow
