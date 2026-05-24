# TMP skills (Bankr + Token Marketplace)

Agent skill pack for **Token Marketplace** fee rights on **Base** — mint TMPR, dual-list on [tokenmarketplace.shop](https://www.tokenmarketplace.shop) and OpenSea, group buy, partial sale, grants, loans, redeem, bundle & rebirth.

**Install in Bankr** ([from GitHub](https://docs.bankr.bot/skills/in-bankr/from-github/)):

```text
install TMP skills at https://github.com/anondevv69/bankr-tmp-skills
```

This repository root **is** the skill folder (`SKILL.md` at root). Bankr loads it directly — no nested path.

## Contents

| Path | Purpose |
|------|---------|
| `SKILL.md` | Main skill — flows, contracts, dual-list API, verification |
| `references/flows-reference.md` | All products (agent + user language) |
| `references/user-language.md` | Phrase → flow routing |
| `references/all-escrow-options.md` | Decision table + mainnet addresses |
| `references/bankr-agent-test-prompts.md` | QA prompts for Bankr agent testing |
| `references/dm-intents.md` | DM / intent shortcuts |

## Related repos

| Repo | What |
|------|------|
| [anondevv69/bankrtokennft](https://github.com/anondevv69/bankrtokennft) | Contracts, `bankr-app`, apps, ops docs |
| [BankrBot/skills](https://github.com/BankrBot/skills) | OpenSea skills (install alongside TMP skills) |

## Updating

After editing this repo, re-run the install line in Bankr so agents refresh the skill.
