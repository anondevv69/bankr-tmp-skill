# TMP skills (Bankr + Token Marketplace)

**Skill version: 45** · [`VERSION`](VERSION) · [`BANKR-INSTALL-CHECK.md`](BANKR-INSTALL-CHECK.md) · [`skill-manifest.json`](skill-manifest.json)

Agent skill pack for **Token Marketplace** fee rights on **Base** — mint TMPR, dual-list on [tokenmarketplace.shop](https://www.tokenmarketplace.shop) and OpenSea, group buy, partial sale, grants, loans, redeem, bundle & rebirth, plus reply-drop planning for hybrid fee-right campaigns.

**Install in Bankr** ([from GitHub](https://docs.bankr.bot/skills/in-bankr/from-github/)):

```text
install TMP skills at https://github.com/anondevv69/bankr-tmp-skill
```

This repository root **is** the skill folder (`SKILL.md` at root). Bankr loads it directly — no nested path.

## After install — confirm v44

Bankr may reply with an **internal** counter (e.g. “updated to v25”). **TMP content version is 44** — check:

| Check | Expected |
|-------|----------|
| `SKILL.md` → `version:` | `45` |
| Root `VERSION` | `45` |
| `BANKR-INSTALL-CHECK.md` | Three mandatory `.md` paths |
| `skill-manifest.json` → `skillVersion` | `45` |
| Reference files | **22** in `references/` |

Agents: read **`references/skill-install-verification.md`** after install.

**List / sell 100% autopilot (mandatory):**

| File | Role |
|------|------|
| `references/sell-list-autopilot.md` | `GET /api/mint/status` → all `nextStep` until `ready` → `POST /api/list/dual` → site + OpenSea |
| `references/runtime-contract.md` | Mined receipt + verify before success reply |
| `references/t7-list-failure-regression.md` | No Doppler handoff / “not in escrow” after prepare-only |

## All reference files (22)

`all-escrow-options.md` · `bankr-agent-test-prompts.md` · `bundle-rebirth-playbook.md` · `bundle-rebirth.md` · `clanker-rescue-ops.md` · `dm-intents.md` · `flows-reference.md` · `listing-channels.md` · `loan-no-forward-sale.md` · `mint-pending-deposit.md` · `normal-talk-only.md` · `partial-sale-resolve-token.md` · `product-rules.md` · `redeem-rights-playbook.md` · `reply-drop.md` · `runtime-contract.md` · `sell-list-autopilot.md` · `share-market-buy.md` · `skill-install-verification.md` · `t7-list-failure-regression.md` · `tmpr-collection-address-trap.md` · `user-language.md`

## Other core docs

| Path | Purpose |
|------|---------|
| `SKILL.md` | Main skill — listing policy, contracts, dual-list API |
| `references/flows-reference.md` | All products (agent + user language) |
| `references/user-language.md` | Phrase → flow routing |
| `references/share-market-buy.md` | Buy 1/1000 shares, password-gated buy |

## Related repos

| Repo | What |
|------|------|
| [anondevv69/bankrtokennft](https://github.com/anondevv69/bankrtokennft) | Contracts, `bankr-app`, apps, ops docs |
| [BankrBot/skills](https://github.com/BankrBot/skills) | OpenSea skills (install alongside TMP skills) |

## Updating

After this repo changes, re-run the install line in Bankr so agents refresh from `main`. Prefer branch **`main`** at latest commit (see GitHub commit history).
