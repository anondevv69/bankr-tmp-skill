# TMP skill install verification (Bankr agent)

**Read this after** `install TMP skills at https://github.com/anondevv69/bankr-tmp-skill`.

---

## Canonical version (not Bankr’s internal counter)

| Source | Expected |
|--------|----------|
| `SKILL.md` frontmatter `version:` | **49** |
| Root `VERSION` file | **49** |
| Root `BANKR-INSTALL-CHECK.md` | Lists three mandatory `.md` paths |
| `skill-manifest.json` → `skillVersion` | **49** |
| `references/` file count | **22** (includes this file) |

**If Bankr says “updated to v27” (or any number ≠ 49):** that may be Bankr’s **internal** bundle counter. **Trust `VERSION` / `SKILL.md` / `BANKR-INSTALL-CHECK.md`.**

**If the agent answers mandatory files as `references/` × 3 with no `.md` names:** skill text was **not** read — reinstall from `main` and read `BANKR-INSTALL-CHECK.md` before listing flows.

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

> TMP skills **v49** from github.com/anondevv69/bankr-tmp-skill — 20 reference files; mandatory listing files at repo root: sell-list-autopilot.md, runtime-contract.md, t7-list-failure-regression.md.

---

## Cross-links

- `../skill-manifest.json` — machine-readable manifest  
- `bankr-agent-test-prompts.md` — R1, R1b, I1  
- `SKILL.md` — Listing policy (read first)
