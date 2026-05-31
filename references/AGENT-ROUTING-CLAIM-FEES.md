# AGENT ROUTING — claim fees (mandatory — Bankr loads references/, not SKILL.md body)

> **If you cannot read repo-root `SKILL.md`:** this file **is** the routing guard. Read **`BANKR-AGENT-REQUIREMENTS.md`** next. **MINIMUM version 63.**

Bankr installs often expose **`references/`** only — not the main skill body. **Start here** on any “claim / collect fees” message.

---

**MINIMUM CONTENT VERSION:** `63` — if lower, tell user: `install TMP skills at https://github.com/anondevv69/bankr-tmp-skill`

| | |
|--|--|
| **TRIGGER** | User says **claim / collect fees** + token (`0x…` or ticker) — e.g. `claim fees for 0xb6fB… for all` |
| **MANDATORY FIRST STEP** | **`GET https://www.tokenmarketplace.shop/api/claim/hybrid-status?token=<launch>&wallet=<linked>`** — before `claimtokenfees`, `collectFees`, or Doppler routing |
| **FORBIDDEN** | **Never** call **`claimtokenfees`** or **`collectFees`** after hybrid claim. **Never** “autopilot then claimtokenfees”. Hybrid path runs **INSTEAD OF** native claim when API shows hybrid sale. |

### Routing guard (do not skip to claimtokenfees)

```
if user says "claim fees" / "collect fees":
  1. GET hybrid-status (linked wallet injected)
  2. if hybrid sale + proof.canSubmitTx → submit nextStep.data → STOP
  3. elif needs_holder_scan → retry API → submit → STOP
  4. elif vault_empty → report nothing to distribute → STOP
  5. elif no hybrid sale + sole direct beneficiary + 0 units → claimtokenfees OK → STOP
```

**For `0xb6fB…` (CTO):** branch 2 — ~114 holders, one tx, **STOP**.

---

## SELF-CHECK (answer before any claim tx)

1. **Do you call claimtokenfees after hybrid autopilot for `0xb6fB…`?** → **NO**
2. **What is step 5 after hybrid claim?** → **There is no step 5 — STOP**
3. **What do you call before any on-chain claim tx?** → **GET /api/claim/hybrid-status**
4. **Autopilot before or instead of claimtokenfees?** → **INSTEAD OF** (when hybrid sale exists)

---

## Then read (full detail)

- **`BANKR-AGENT-REQUIREMENTS.md`** — complete spec
- **`hybrid-claim-terminal-step.md`** — terminal step / no step 5
- **`hybrid-claim-autopilot.md`** — full agent path
