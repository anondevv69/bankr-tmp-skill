# TMP skill install verification (Bankr agent)

**Read this after** `install TMP skills at https://github.com/anondevv69/bankr-tmp-skill`.

---

## Canonical version (not Bankr’s internal counter)

| Source | Expected |
|--------|----------|
| `SKILL.md` frontmatter `version:` | **44** |
| Root `VERSION` file | **44** |
| `skill-manifest.json` → `skillVersion` | **44** |
| `references/` file count | **22** (includes this file) |

**If Bankr says “updated to v25” (or any number ≠ 44):** that may be Bankr’s **internal** bundle counter. **Trust `SKILL.md` / `VERSION` / `skill-manifest.json` for TMP skill content version.** If `sell-list-autopilot.md` is missing or listing still handoffs to Doppler, **re-run install** from GitHub `main`.

---

## Mandatory files for list / sell 100% autopilot

These **must** be loaded for “list for 0.01 eth” requests:

1. **`sell-list-autopilot.md`** — `GET /api/mint/status` → every `nextStep` until `ready` → `POST /api/list/dual` → site steps → OpenSea  
2. **`runtime-contract.md`** — mined receipt + post-state verify; no stop after prepare  
3. **`t7-list-failure-regression.md`** — no “not in escrow” / Doppler dashboard handoff  

---

## Self-check (agent)

Before executing a list request, confirm you will:

- [ ] Call **`GET /api/mint/status`** (or POST) for launch token + seller wallet  
- [ ] Run **all** `nextStep` until **`phase === "ready"`**  
- [ ] **`POST /api/list/dual`** then execute **`site.steps[]`** + OpenSea  
- [ ] Reply with **BaseScan + marketplace + OpenSea links** only after mined receipts  
- [ ] **Not** tell user to set Doppler beneficiary to escrow **before** `prepareDeposit`  

---

## User verification prompt (optional)

If user asks whether TMP skills are current:

> TMP skills **v44** from github.com/anondevv69/bankr-tmp-skill — 22 reference files including sell-list-autopilot, runtime-contract, and t7-list-failure-regression.

---

## Cross-links

- `../skill-manifest.json` — machine-readable manifest  
- `bankr-agent-test-prompts.md` — R1, R1b, I1  
- `SKILL.md` — Listing policy (read first)
