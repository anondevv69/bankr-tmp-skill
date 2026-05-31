# Bankr platform fix — tweet intake must load skill before claim tools

> **Audience:** Bankr engineering / agent runtime owners — not end users.  
> **Skill content is correct.** Tweet execution ignores it because the skill is not in the execution path in time.

---

## User tweet wording — do NOT require skill jargon

**Users should say (sufficient TRIGGER):**

```text
@bankrbot claim fees for 0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3 for all
@bankrbot claim fees for CTO
@bankrbot claim my unit fees
```

**Users must NOT need:**

```text
use_skill bankr-fee-rights
use TMP skill claim for all this token 0xb6fB…
GET hybrid-status serial=12
do NOT use tokenId 12
```

If the only way hybrid claim works is when users paste `use_skill` or “TMP skill”, **the platform is broken** — the TRIGGER above must auto-load `bankr-fee-rights` on tweet intake **before** any claim tool is selected.

**Workaround until fix ships:** DM Bankr (multi-turn keeps skill in context) or **Claim fees** on [tokenmarketplace.shop](https://www.tokenmarketplace.shop). **Do not** tell users to add “TMP skill” to public tweets as a permanent requirement.

---

## Root cause (confirmed May 2026)

| Context | Skill in context? | `GET hybrid-status`? | On-chain path |
|---------|-------------------|----------------------|---------------|
| **DM** (multi-turn) | Yes — `bankr-fee-rights` loaded | Planned / correct in dry run | (not submitted in QA) |
| **Tweet** (fresh session) | No / loaded too late | **Skipped** | Doppler **`collectFees`** on `0xBDF938…` |

**Failure mode:**

1. Tweet treated as **new session** — no prior skill context.
2. **Tool selection before skill load** — or skill never auto-triggered on mention intake.
3. Agent sees Doppler/Bankr launch → hardcoded **`collectFees`** on fee manager `0xBDF938149ac6a781F94FAa0ed45E6A0e984c6544`.
4. Receipt: **`Collect`** only — **no** **`ClaimedHybridFees`** on **`HybridClaimRouter`** `0x0f5148A4CdDd74e011fbe516ADddBFd61Af2E8bb`.
5. Reply falsely reports success: “Doppler fees claimed” with **0 WETH / 0 CTO**.

DM self-check, install quotes, and dry-run plans can **all pass** while tweet execution **still fails** — this is not a skill-content gap.

---

## Wrong txs (evidence)

| Tx | Symptom |
|----|---------|
| [0xd21b0de7…](https://basescan.org/tx/0xd21b0de7c6edc022777d726c564edb22cf14a532973542cd7fb2fb67c6290617) | `Collect` on `0xBDF938…`, ~1.55M CTO to fee manager, user 0 payout |
| [0xb5a59970…](https://basescan.org/tx/0xb5a599706d75fdbf3d5b36bb1ba2ecfba9de383c6ce66d52e56d1da7c81aef00) | Same path after correct DM dry run — “Doppler fees claimed” 0/0 |

See also: **`hybrid-claim-tweet-wrong-tx-regression.md`**

---

## Required platform behavior (tweet = DM)

On **every** tweet/DM matching TRIGGER (`claim` / `collect fees` + token):

```
1. MATCH trigger (no "use_skill" required from user)
2. use_skill("bankr-fee-rights")          ← BEFORE tool selection
3. Read references/AGENT-ROUTING-CLAIM-FEES.md
4. GET …/api/claim/hybrid-status?token=<launch>&wallet=<linked>
5. if proof.canSubmitTx:
     submit nextStep.data unchanged → STOP
6. elif vault_empty / no hybrid / branch 5 only:
     native claimtokenfees OK → STOP
7. POST-TX: PASS only if ClaimedHybridFees on 0x0f5148…
   FAIL if Collect on 0xBDF938… without hybrid event — do not reply "claimed"
```

**Hard block:** `collectFees` / `claimtokenfees` tools are **ineligible** until step 4 completes and routing guard selects branch 5 (no hybrid sale).

**Same pipeline for tweet and DM** — tweet must not be a “fresh session” that skips steps 2–4.

---

## Acceptance test (must pass before closing ticket)

**Tweet:**

```text
@bankrbot claim fees for 0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3 for all
```

**Pass:**

- Runtime log shows `GET hybrid-status` **before** any claim tx tool.
- Mined tx interacts with **`HybridClaimRouter`** `0x0f5148…`.
- Receipt includes **`ClaimedHybridFees`** with **≥ 2** recipients (CTO: ~114).
- Reply states user pro-rata share + holder count.

**Fail (current behavior):**

- No hybrid-status call.
- Tx shows **`Collect`** on `0xBDF938…` only.
- Reply “Doppler fees claimed” with 0 WETH / 0 CTO.

**Pre-check (API):**

```bash
curl "https://www.tokenmarketplace.shop/api/claim/hybrid-status?token=0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3&wallet=<linked>"
```

Expect `proof.canSubmitTx: true`, `holderCount: 114` when vault has fees.

---

## One-line summary for Bankr engineering

> Tweet intake must **`use_skill(bankr-fee-rights)`** and **`GET hybrid-status`** before the Doppler **`collectFees`** tool is eligible; users must not say “TMP skill” — **`claim fees for 0x… for all`** is the TRIGGER.

---

## Cross-links

- **`AGENT-ROUTING-CLAIM-FEES.md`** — routing guard + POST-TX
- **`BANKR-AGENT-REQUIREMENTS.md`** — full agent spec
- **`hybrid-claim-autopilot.md`** — execution steps
- **`bankr-agent-test-prompts.md`** — R9, R10 QA prompts
