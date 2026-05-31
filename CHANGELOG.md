# Changelog — TMP skills (bankr-fee-rights)

Canonical version: **`VERSION`** file and `SKILL.md` frontmatter `version:`.

## 60 (current)

- **`hybrid-claim-terminal-step.md`:** fix step-4 bug — hybrid claim ENDS at one tx; **INSTEAD OF** claimtokenfees, never "before then after".
- Skill description changed from "runs BEFORE claimtokenfees" → "ENDS at claimFeesForToken — never after".
- Regression doc: explicit fail for "autopilot then claimtokenfees" plan.

## 59

- **Hybrid claim mandate:** API-enforced rule — every claim uses `nextStep.data` unchanged, distributes to ALL holders, must pass `proof.canSubmitTx` and `recipientCount >= 2` checks.
- **`hybrid-claim-autopilot.md`**: mandatory behavior section; cannot proceed if `canSubmitTx` is false.
- **Fail conditions:** explicitly forbid manual calldata builds, single-recipient txs, follow-ups without state re-check.

## 58

- **`hybrid-claim-claimtokenfees-regression.md`:** Bankr replied “Doppler not Clanker → use claimtokenfees” for CTO claim tweet — wrong; hybrid-status first.
- **`hybrid-claim-autopilot.md`:** routing table — hybrid claim before any Bankr native claim tool.
- **`SKILL.md` § Claim policy:** forbid Doppler-vs-Clanker handoff without API.

## 57

- **`hybrid-claim-autopilot.md`** (repo root): claim fees = natural language only — “claim fees for CTO”; agent runs hybrid-status + all holders silently.
- **`SKILL.md` § Claim policy** mirrors sell-list autopilot — users never paste API params, use_skill, serial=, or tokenId rules.
- Removed technical tweet checklists from **`hybrid-claim-fees.md`**; updated FLOW 13, dm-intents, user-language, test prompts.

## 56

- **`hybrid-id-vocabulary.md`:** canonical glossary — `serial`, `hybridTokenId`, `tokenId`, units, wallet vs launch token.
- **`hybrid-claim-serial-not-tokenid-regression.md`:** forbid `canClaimFees(12)` / `isFinalized(12)` when user said TMPR #12; API first.
- **`SKILL.md`**, **`dm-intents.md`**, **`user-language.md`**, **`BANKR-INSTALL-CHECK.md`**, **`README.md`** — v56 alignment.

## 55

- **`hybrid-claim-single-recipient-regression.md`:** tx 0xd866… paid 1 wallet only — forbid `recipients=[requester]` when unitsHeld < 1000.
- API `nextStep.data` only when full cap table; decode recipientCount before sign.

## 54

- **`hybrid-claim-zero-units-regression.md`:** claim tweet must scan ERC-1155 before “0 units”; same thread “yes claim now” rule.
- CTO May 2026: Bankr found 630 units on erc1155 check but denied on claim — documented fail pattern.

## 53

- **Linked wallet:** user never pastes wallet — Bankr injects from X↔Bankr connection.
- **`hybrid-status` API:** `proof` + `agentInstructions` — claim pays all holders; `canSubmitTx` gate.
- Tweet templates: token only (optional serial).

## 52

- **`hybrid-claim-fees.md` § Glossary:** explicit definitions — `token=` vs `wallet=`, ERC-20 vs units, serial vs `hybridTokenId`, buy tx vs claim tx, tweet phrase meanings. CTO worked example addresses.
- Fix: “TMPR #12” → **`serial=12`**, not on-chain id `12`.

## 51

- **`GET /api/claim/hybrid-status`** on tokenmarketplace.shop — resolves hybrid tokenId, units, vault, claim calldata for agents.
- **Tweet hybrid claim (Path L):** execute from public @bankr when X↔Bankr wallet linked; do not re-ask for address if `0x…` in tweet.
- **`hybrid-claim-fees.md`:** tweet copy-paste prompts + status API step 0.

## 50

- **`references/hybrid-claim-fees.md`** — mandatory playbook for ERC-1155 **Unit** fee claims via **`HybridClaimRouter.claimFeesForToken`**.
- **P0 regression:** forbid Bankr fee-manager **`collectFees`** from user wallet when user holds hybrid units (CTO / TMPR #12 May 2026).
- **`SKILL.md`**, **`user-language.md`**, **`dm-intents.md`** (Path K), **`flows-reference.md`** (FLOW 13), **`bankr-agent-test-prompts.md`** updated.
- Group buy claim step in **`SKILL.md`**: hybrid V6 → claim router; legacy V2–V5 → split distribute.

## 49

- **P0 listing autopilot:** `user-language.md` — dual list via `POST /api/list/dual` (removed OpenSea-only / “agents do not list on site” contradictions).
- **`dm-intents.md` Path J:** tweet sell-100% = same autopilot as DM when wallet + tx tools available.
- **`runtime-contract.md` §7b:** step-limit / interrupted-run rules; resume with `continue … list`.
- **`bankr-agent-test-prompts.md`:** R7 (tweet list), R8 (resume), I1 expects v49.
- **`SKILL.md`:** Twitter short-turn + “never break into smaller steps” for listings.

## 48

- **Removed `tmp-solana-cto/`** — Solana does not work on Bankr; CTO / Pump / batch claim → website + Solana wallet only.
- Main skill notes Solana is out of scope; companion skills = **tmp-bundle-rebirth** + OpenSea only.

## 47

- **Monorepo:** separate Bankr skills `tmp-bundle-rebirth/` and `tmp-solana-cto/`; main Base skill stays at **repo root** (install URL unchanged).
- Bundle playbooks moved out of `references/` into `tmp-bundle-rebirth/references/`.
- *(Solana companion removed in v48.)*

## 46

- **Move listing autopilot to repo root:** `sell-list-autopilot.md`, `runtime-contract.md`, `t7-list-failure-regression.md` — Bankr often only exposes `references/` as a folder label (empty `references/` × 3 answers).
- **`MANDATORY-LISTING-FILES.txt`** + plain-text install answer in `SKILL.md` (no backticks in bullets).
- **`mandatory_listing_files`** in SKILL frontmatter + shorter `description` for Bankr loader.

## 45

- Document Rayblancoeth t7 list regression: “finalizeDeposit reverted → fix Doppler” (forbidden).
- Reinforce: `needs_finalize` / `bankr-build-transfer` from mint/status — no dashboard handoff.
- Add **`BANKR-INSTALL-CHECK.md`** at repo root — exact `.md` paths for install Q&A (fixes `references/` × 3 wrong answers).
- **`SKILL.md`** install-check block at top for agents that only read main file.

## 44

- **Listing autopilot default:** natural language “list for X ETH” → `sell-list-autopilot.md` + `runtime-contract.md` (no skill name / API URLs from user).
- **`t7-list-failure-regression.md`:** block Doppler-handoff and “not in escrow” after prepare-only.
- **`skill-install-verification.md` + `skill-manifest.json`:** agents verify v44 vs Bankr internal install counter.
- **22** reference files under `references/` (added `skill-install-verification.md`).
- **`VERSION`**, **`skill-manifest.json`**, **`CHANGELOG.md`** at repo root for install audits.

## 43

- Sell/list autopilot reference; mint/status before dual list.

## Earlier

- Runtime contract, share-market buy, password-gated buy, reply-drop planning, bundle & rebirth playbooks.
