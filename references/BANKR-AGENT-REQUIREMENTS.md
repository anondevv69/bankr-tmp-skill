# Bankr agent requirements — hybrid unit fee claim

> **Bankr agents:** full copy (same as repo root **`BANKR-AGENT-REQUIREMENTS.md`**). Bankr often only indexes `references/` — **this file is complete.**

**Load with skill install.** Canonical spec for routing — overrides default “Doppler → claimtokenfees” behavior.

**MINIMUM CONTENT VERSION:** `62` (`VERSION` file must match `SKILL.md` frontmatter). If lower → tell user to reinstall from GitHub.

---

## User input (sufficient)

```text
claim fees for 0xb6fB5AE1eb79AA628aeEC8E1dFD6e736CC624ba3 for all
claim fees for CTO
claim my unit fees
```

User must **not** need: `use_skill`, `hybrid-status`, `serial=`, wallet, skill version, “don’t use tokenId 12”.

---

## TRIGGER

**Match:** `claim` / `collect fees` + optional token (`0x…` or ticker) + optional “for all”.

**Load:** `bankr-fee-rights` → **`hybrid-claim-terminal-step.md`** + **`hybrid-claim-autopilot.md`** (this folder).

**Before any claim tool:** skill body must load — skill overrides native routing.

---

## ROUTING GUARD (mandatory — do not skip)

```
if user says "claim fees" / "collect fees":
  1. GET /api/claim/hybrid-status?token=<launch>&wallet=<linked>
  2. if ok + hybrid sale + proof.canSubmitTx:
       submit nextStep.data unchanged → verify ClaimedHybridFees → STOP
  3. elif needs_holder_scan:
       retry API / indexer → submit → STOP (still no claimtokenfees)
  4. elif vault_empty:
       report "nothing to distribute" → STOP
  5. elif no hybrid sale + sole direct beneficiary + 0 units:
       ONLY THEN → claimtokenfees / collectFees → STOP
  else:
       do not submit → site Claim fees fallback
```

**For `0xb6fB…` (CTO):** branch 2 — ~114 holders, one tx, **STOP**.

**FORBIDDEN:** skip step 1 and go to `claimtokenfees` because token is Doppler/Bankr launch.

---

## Required sequence (4 steps + verify, then STOP)

| Step | Action |
|------|--------|
| 1 | Resolve launch token + **linked wallet** (inject — never ask on tweet if linked) |
| 2 | **`GET …/api/claim/hybrid-status?token=…&wallet=…`** |
| 3 | If **`proof.canSubmitTx`** → **`bankr.tx.prepare(nextStep.data)`** unchanged |
| 4 | Verify **`ClaimedHybridFees`** → plain English reply → **STOP** |

**There is no step 5.** **Never** `claimtokenfees` or `collectFees` after a successful hybrid claim.

---

## Hard rules (fail the run)

1. **Never** `claimtokenfees` / `collectFees` when API shows hybrid sale or user holds ERC-1155 units.
2. **Never** “autopilot **then** claimtokenfees” — hybrid path **INSTEAD OF** native claim, not **BEFORE** it.
3. **Never** manual calldata — **`nextStep.data`** only.
4. **Never** `recipients.length === 1` when requester holds **< 1000** units.
5. **Never** `tokenId = serial` (TMPR #12 ≠ on-chain `12`).
6. **Never** “Doppler vs Clanker” routing without hybrid-status.
7. **Never** ask wallet/contract if already in tweet + X↔Bankr linked.

---

## Pre-submit gates

Submit only when:

- `proof.canSubmitTx === true`
- `nextStep.recipientCount >= 2` (unless requester holds all 1000 units)
- Calldata = `nextStep.data` unmodified

---

## Success reply

> “Claimed **$CTO** trading fees for **N** unit holders in one tx. Your share: **X WETH** + **Y CTO**. [BaseScan]”

Do not expose API jargon to user.

---

## Forbidden replies

- “Doppler not Clanker — use claimtokenfees”
- “Autopilot first, then claimtokenfees”
- “TokenId 12 not finalized” (without hybrid-status)
- “0 units” (without hybrid-status)
- “Wasn’t able to complete” (when `canSubmitTx: true`)

---

## SELF-CHECK (answer before any claim tx)

1. Do you call **claimtokenfees after** hybrid autopilot for `0xb6fB…`? → **NO**
2. What is step 5 after hybrid claim? → **There is no step 5 / STOP**
3. What do you call before any on-chain claim tx? → **GET /api/claim/hybrid-status**
4. Does hybrid autopilot run **before** or **instead of** claimtokenfees? → **INSTEAD OF** (when hybrid sale exists)

---

## Layer ownership

| Layer | Owner | Requirement |
|-------|-------|-------------|
| Skill docs | This repo | Rules in SKILL.md top + references/ full copies |
| Bankr runtime | Bankr | Load skill **before** native `claimtokenfees` on “claim fees” |
| Tool priority | Bankr | hybrid-status + `nextStep.data` **replaces** claimtokenfees for hybrid tokens |

**One sentence:** hybrid-status → one `claimFeesForToken` for all holders → **stop**.
