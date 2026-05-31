# TMP skills monorepo (Bankr)

[BankrBot/skills](https://github.com/BankrBot/skills)-style layout: **one folder = one installable skill**, same GitHub repo.

**Scope:** Base (chain 8453) only. Solana CTO / Pump claims are **not** available in Bankr — use [tokenmarketplace.shop](https://www.tokenmarketplace.shop) with a Solana wallet.

## Install (pick what you need)

### 1. Main — Base marketplace (mint, list, buy, partial, group, grant, loan)

**Repo root** = this skill (backward compatible):

```text
install TMP skills at https://github.com/anondevv69/bankr-tmp-skill
```

Covers: create NFT · list/sell 100% · buy 1/1000 share · **claim hybrid unit fees** · partial · group buy · grants · loans · redeem.

Root files: `SKILL.md`, `sell-list-autopilot.md`, `runtime-contract.md`, `t7-list-failure-regression.md`, `references/`.

### 2. Bundle & Rebirth (optional)

```text
install TMP bundle rebirth at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-bundle-rebirth
```

Use with main skill for mint/status. Folder: [tmp-bundle-rebirth/](tmp-bundle-rebirth/).

### 3. OpenSea (official)

```text
install opensea skills at https://github.com/BankrBot/skills
```

Dual list step for Base listings.

---

## Layout

```text
bankr-tmp-skill/
├── SKILL.md                 ← tmp-fee-rights (main, repo root)
├── sell-list-autopilot.md
├── runtime-contract.md
├── references/              ← Base playbooks (20 files)
├── tmp-bundle-rebirth/
│   ├── SKILL.md
│   └── references/
└── README.md                ← this file
```

## Version

Main skill: **56** (`VERSION` at repo root). Hybrid claims: read **`references/hybrid-id-vocabulary.md`** — **`serial=12` ≠ `tokenId=12`**. Bundle rebirth companion: **1**.

## Related

- [anondevv69/bankrtokennft](https://github.com/anondevv69/bankrtokennft) — contracts + bankr-app
- [BankrBot/skills](https://github.com/BankrBot/skills) — official Bankr skills

## Updating

Re-run the install line(s) in Bankr after `git pull`.
