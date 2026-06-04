# Changelog — TMP skills (bankr-fee-rights)

Canonical version: **`VERSION`** file and `SKILL.md` frontmatter `version:`.

## 92 (current)

- **`launch-studio-async-polling.md`** — mandatory poll after 202; forbid “didn’t submit this turn” / “tell me to retry”.
- **`launch-studio-solana-autopilot.md`** — Pump/Solana site x402; SKT example prompt.
- Updated forbidden replies, completion reply, user language, test prompts **N1/N4**.

## 91

- **`tmp-launch-studio/`** — companion skill: deploy new Bankr token + 1000 fee-right units via x402 (~$1 USDC Base); plain-English user guide + autopilot poll flow; pairs with list/claim/transfer after launch.
- **`ONE-LINE-INTENTS.md`**, **`user-language.md`**, **`normal-talk-only.md`**, **`skill-manifest.json`**, site **`agent.md`**.

## 87

- **`transfer-units-autopilot.md`** — **batch / equal-split airdrop**: ≤25 recipients, `0x…, units` lines, **N `safeTransferFrom`** txs, balance preflight; site **NFTs → Send shares**.
- **`SKILL.md`**, **`ONE-LINE-INTENTS.md`**, **`user-language.md`**, test prompts **L3–L4**.

## 86

- **`transfer-units-autopilot.md`** — gift / airdrop / send ERC-1155 units (1/1000) after split; site **Profile → Listed → Send units**; Bankr `safeTransferFrom` path.
- **`profile-completed-sales.md`** — **Profile → Completed sales** — fixed Sell 100% **You sold** / **You bought** + group sales.
- **`ONE-LINE-INTENTS.md`**, **`user-language.md`**, **`SKILL.md`** routing for flows **L** (transfer) and **M** (history).
- Site: `bankr-app` agent.md updated (Jun 2026).

## 85

- **`buy-marketplace-autopilot.md`** — all buy paths: fixed sale, shares, CTO contribute, Solana, OpenSea TMP.
- **Skill hub** — companion repos [TMP-Skill-Listing](https://github.com/anondevv69/TMP-Skill-Listing) and [TMP-Skill-Split-1000](https://github.com/anondevv69/TMP-Skill-Split-1000); main repo = full site + APIs.

## 84

- **`hybrid-claim-autopilot.md`** — step 4b: X/Telegram fires automatically after claim; ops replay via `POST /api/alerts/from-tx` with tx hash.

## 83

- **`split-custodial-approve-block.md`** — after mint `ready`, if custodial blocks `approve` to GroupBuyEscrowV6: 3× retry, then transfer hybrid TMPR to user EOA + site “Split into 1000”; user bypass may still fail.
- **`split-1000-autopilot.md`** — `createPartialSale` self-split (matches site wizard); links custodial doc.

## 82

- **`fractionalize-autopilot.md`**, **`runtime-contract.md`** — no pause after `prepareDeposit`; same-turn mint loop through finalize.

## 80

- **`fractionalize-autopilot.md`**, **`hybrid-escrow-mint-blocker.md`** — users say plain “fractionalize into 1000”; agent runs mint/status + split silently; **forbidden** Doppler dashboard / “paste API” handoffs.
- **`split-1000-autopilot.md`** — post-mint V6 steps only; points to fractionalize autopilot.
- **`t7-list-failure-regression.md`** — extended to fractionalize / deploy+split.
- Site API: **`mint/status`** returns **`platformBlocker`** when hybrid escrow `prepareDeposit` reverts.

## 79

- **`buy-fixed-sale-autopilot.md`**, **`buy-url-routing-regression.md`** — `/listing/sale/{id}` → **`GET /api/list/buy-status`** → `buy` on **`FeeRightsFixedSale` `0xe2A1…`**; forbid share `list-status` / **`0x9023…`** for same numeric id.
- **`ONE-LINE-INTENTS.md`** Flow F, **`AGENT-ROUTING-LISTINGS.md`**, **`runtime-contract.md`**, test prompts **B1–B3**.
- Site API: **`GET /api/list/buy-status`** (fee-rights-exchange `bankr-app`).

## 72

- **`share-market-cancel-autopilot.md`** — @bankrbot cancel/delist ERC-1155 share listings via **`GET /api/share/list-status`** + **`HybridShareMarketplace.cancel`**.
- Site API: **`GET /api/share/list-status`** returns active seller listings + cancel calldata (`nextStep.data`).
- **`AGENT-ROUTING-LISTINGS.md`**, **`SKILL.md`**, **`user-language.md`** — cancel share routing (not FeeRightsFixedSale).

## 71

- **`share-market-list-autopilot.md`:** cancel path (`HybridShareMarketplace.cancel`), mandatory shop URL in @bankrbot replies, **`POST /api/listings/notify`** for Bankr lists (or chain watcher on bot).
- Site/bot: **ShareListed chain watcher** + dedupe so @TokenMkp / Telegram fire when Bankr skips site notify.

## 70

- **UNAMBIGUOUS INTENT** block at top of **`SKILL.md`**: “list for X ETH” → **always** tokenmarketplace.shop — never ask venue, never OpenSea-only, never Doppler handoff.
- **t7 regression guardrails** moved into main **`Common agent mistakes`** table with **NEVER** labels (before success-path docs).
- **`sell-list-autopilot.md`:** one-conversation rule + mandatory **`GET /api/list/status`** checkpoint (`listedOnSite: true`) before “listed” reply.
- **`t7-list-failure-regression.md`:** documents @Rayblancoeth May 2026 failure (prepareDeposit active → manual Doppler — forbidden).
- **`AGENT-ROUTING-LISTINGS.md`**, **`BANKR-PLATFORM-TWEET-LIST-INTAKE.md`:** v70 minimum + same guardrails.

## 69
- **Restored `tmp-solana-cto/`** companion — Solana buy + batch claim autopilot (`solana-buy-autopilot.md`, `solana-claim-autopilot.md`).
- Site APIs: **`GET /api/solana/buy-status`**, **`GET /api/solana/claim-status`** (password verify, cheapest offer, cap table, batch chunks).
- **`BANKR-PLATFORM-TWEET-LIST-INTAKE.md`:** tweet “list X for 0.01 eth” must auto-load skill + `GET /api/mint/status` before list tools (parallel to claim tweet fix).

## 68

- **X reply rule:** after successful list on @bankrbot tweet, reply **must** include full `https://www.tokenmarketplace.shop/...` listing URL.
- **`AGENT-ROUTING-LISTINGS.md`**, sell-list-autopilot, share-market-list-autopilot, runtime-contract updated.
- Site API: `GET /api/list/status` returns **`siteListingUrl`** for fixed-sale listings.

## 67

- **`AGENT-ROUTING-LISTINGS.md`:** all list/sell/for-sale/password intents **default to tokenmarketplace.shop** — never OpenSea-only or "site or OpenSea?"
- Updated listing-channels, sell-list-autopilot, user-language, normal-talk-only, SKILL.md routing block.

## 66

- **`share-market-list.md`** + **`share-market-list-autopilot.md`:** list ERC-1155 units — **0 ETH**, password, `maxPerWallet`; no dual-list API.
- Routing updates in SKILL.md, user-language, listing-channels, bankr-agent-test-prompts (L1, L2).

## 65

- **`BANKR-PLATFORM-TWEET-INTAKE.md`:** Bankr engineering spec — tweet must auto-load skill before claim tools; users must not say “use TMP skill”.
- Documents DM vs tweet context split; cites wrong txs 0xd21b0de7… and 0xb5a59970…

## 64

- **`hybrid-claim-tweet-wrong-tx-regression.md`:** self-check NO but tweet ran Collect on 0xBDF938 (tx 0xd21b0de7…) — POST-TX verification required.
- **`AGENT-ROUTING-CLAIM-FEES.md`:** must see ClaimedHybridFees + HybridClaimRouter 0x0f5148, not Collect-only.

## 63

- **`references/AGENT-ROUTING-CLAIM-FEES.md`:** SKILL.md routing guard duplicated for Bankr installs that only mount `references/` (not repo root).
- Document Bankr quirk: SKILL.md body often missing from agent context.

## 62

- **`BANKR-AGENT-REQUIREMENTS.md`:** full hybrid claim spec for Bankr routing owners.
- **`SKILL.md` top:** AGENT ROUTING block (TRIGGER, MANDATORY FIRST STEP, FORBIDDEN, routing guard) — loads before default claimtokenfees.
- **`SKILL.md` bottom:** SELF-CHECK questions before any claim tx.
- **MINIMUM version gate:** 62 in VERSION + frontmatter.

## 61

- **Full claim docs in `references/`** — Bankr only loaded 5-line stubs; now mirrors root autopilot + terminal-step.
- **VERSION sync** — install check requires VERSION = SKILL frontmatter; stale 56 vs v60 header explained.
- Fix duplicate section in `hybrid-claim-autopilot.md`.

## 60

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
