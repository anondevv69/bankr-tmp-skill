# Bankr install check — answer verbatim

**Canonical TMP skill version:** **59** (VERSION file + SKILL.md frontmatter). **Base only** — no Solana skill in this repo (Bankr cannot run Solana).

**Hybrid claim:** API enforces all-holders rule — `claimFeesForToken` with **full `recipients[]`** or cannot submit. Never manual calldata, never single-recipient.

**Bankr “v23” / “v27” / “v45”** = Bankr internal install counter. **Not** the TMP content version.

## Three mandatory listing files (repo ROOT — each is its own file Bankr can load)

sell-list-autopilot.md

runtime-contract.md

t7-list-failure-regression.md

Copies also exist under references/ for humans; **agents should read the root copies first.**

**Wrong answers:** empty bullet points · references/ · references/ · references/ · no .md extension

## Plain-text answer template (copy when user asks)

TMP skills version 59

Mandatory listing reference files:
sell-list-autopilot.md
runtime-contract.md
t7-list-failure-regression.md

## Reference file count

**23** additional playbooks under references/ (hybrid-claim-autopilot, hybrid-id-vocabulary, share buy, bundle, flows, …).
