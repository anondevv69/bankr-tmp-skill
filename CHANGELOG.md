# Changelog — TMP skills (bankr-fee-rights)

Canonical version: **`VERSION`** file and `SKILL.md` frontmatter `version:`.

## 50 (current)

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
