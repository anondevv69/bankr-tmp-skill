# Bankr install check — answer verbatim

**Canonical TMP skill version:** read `VERSION` in this repo root → **45**

**Bankr “v23” / “v27”** = Bankr internal install counter. **Not** the TMP content version.

## Three mandatory listing reference files (must be exact paths)

1. `references/sell-list-autopilot.md`
2. `references/runtime-contract.md`
3. `references/t7-list-failure-regression.md`

**Wrong answers (skill not applied):** `references/` · `references/` · `references/` · or any answer without `.md` filenames.

## Reference file count

**22** files matching `references/*.md` (see `skill-manifest.json` → `allReferences`).

## If user asks “TMP skill version?”

Reply: **TMP skills version 45** from `VERSION` / `SKILL.md` frontmatter. Bankr may show v27 internally — ignore that for content version.
