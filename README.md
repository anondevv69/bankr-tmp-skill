# TMP skills monorepo (Bankr)

[BankrBot/skills](https://github.com/BankrBot/skills)-style layout: **one folder = one installable skill**, plus **focused repos** for listing and split.

**Site:** https://www.tokenmarketplace.shop · **Agent guide (read first):** https://www.tokenmarketplace.shop/agent.md · **`references/read-site-agent-md.md`**

---

## Install (pick what you need)

### 1. Main hub — buy, claim, APIs, full site (recommended)

```text
install TMP skills at https://github.com/anondevv69/bankr-tmp-skill
```

**Buy flows:** fixed sale · 1/1000 shares · CTO participate · Solana · OpenSea TMP → **`buy-marketplace-autopilot.md`**

Also: hybrid claim · redeem · grants · loans · mint/status.

### 2. Listing only

```text
install TMP listing at https://github.com/anondevv69/TMP-Skill-Listing
```

Dual list (site + OpenSea) · password · CTO/partial list · list share units · mint-before-list.

Repo: [TMP-Skill-Listing](https://github.com/anondevv69/TMP-Skill-Listing)

### 3. Split 1000 only

```text
install TMP split 1000 at https://github.com/anondevv69/TMP-Skill-Split-1000
```

Fractionalize fee rights → 1000 ERC-1155 units (V6 self-split).

Repo: [TMP-Skill-Split-1000](https://github.com/anondevv69/TMP-Skill-Split-1000)

### 4. Launch Studio (deploy + 1000 units)

```text
install TMP Launch Studio at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-launch-studio
```

New Bankr token on Base via x402 (~$1 USDC): deploy → mint → split → deliver or airdrop. **Solana:** https://www.tokenmarketplace.shop/launch

### 5. Solana CTO (buy + claim on Solana listings)

```text
install TMP Solana CTO at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-solana-cto
```

### 6. OpenSea (official)

```text
install opensea skills at https://github.com/BankrBot/skills
```

Used with dual list and for buying TMPR on OpenSea.

### 7. Bundle & Rebirth (optional)

```text
install TMP bundle rebirth at https://github.com/anondevv69/bankr-tmp-skill/tree/main/tmp-bundle-rebirth
```

---

## Layout

```text
bankr-tmp-skill/                    ← hub (this repo)
├── SKILL.md
├── buy-marketplace-autopilot.md    ← all purchase paths
├── sell-list-autopilot.md          ← also in TMP-Skill-Listing
├── fractionalize-autopilot.md      ← also in TMP-Skill-Split-1000
├── hybrid-claim-autopilot.md
├── references/
├── tmp-solana-cto/
├── tmp-launch-studio/
└── tmp-bundle-rebirth/

TMP-Skill-Listing/                  ← separate repo
TMP-Skill-Split-1000/               ← separate repo
```

---

## Version

Main skill: **`VERSION`** file (currently **88**). Re-run install in Bankr after `git pull`.

## Related

- [anondevv69/bankrtokennft](https://github.com/anondevv69/bankrtokennft) — contracts + bankr-app
- [BankrBot/skills](https://github.com/BankrBot/skills) — official Bankr skills
