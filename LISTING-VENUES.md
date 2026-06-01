# Listing venues — default dual list (site + OpenSea)

> **Default:** `list t7 for 0.01 eth` → **dual listing** = Token Marketplace **and** OpenSea (when possible).  
> **Exceptions:** password-protected, max-per-wallet, share units, or user names one venue only.

---

## Default — dual list (no venue in message)

When user says **sell / list [ticker] for X ETH** and does **not** say “site only”, “OpenSea only”, “with password”, or “max per wallet”:

| Step | Action |
|------|--------|
| 1 | **Site** — `POST /api/list/dual` → execute `site.steps[]` → verify `listedOnSite` + reply with **full shop URL** |
| 2 | **OpenSea** — **opensea-marketplace** skills using `openSea` from same API response — **same conversation**, do not stop after site only |

**Do not ask:** “Site or OpenSea?” · “Want dual list?” — **assume dual** unless an exception below applies.

**Success reply includes:** shop URL **and** OpenSea item link (when Seaport step completes).

---

## Exceptions — site only (no OpenSea)

| User intent | Why site only |
|-------------|----------------|
| **Password protected** / “list with password” / gated listing | Password gate is **site** (`accessKeyHash` on `FeeRightsFixedSale`) — OpenSea listing stays **public**; do **not** dual-list password sales on OpenSea |
| **max per wallet** / **one per wallet** / **wallet limited** | **Share market** (`HybridShareMarketplace`) — ERC-1155 units, not whole TMPR; **no** OpenSea |
| **List shares** / **1/1000** / **units at 0 ETH** | Share order book — site only |
| **Partial sale** / **keep X% sell Y%** | GroupBuyEscrowV2 — site only |
| **on tokenmarketplace only** / **site only** / **not OpenSea** | User override — site only |
| **OpenSea only** | User override — OpenSea only (still mint + `list/dual` for calldata if needed, or OS skills only) |

If user says **“list with password”** → site only, ask for password in **DM** on public tweets.

---

## User names a venue explicitly

| User says | Agent does |
|-----------|------------|
| **on tokenmarketplace** / **on the site** only | Site only — shop URL |
| **on OpenSea** / **OpenSea only** | OpenSea via opensea skills |
| **both** / **dual** / **site and OpenSea** | Same as default dual |
| **list for 0.01 eth** (nothing else) | **Default dual** (top of this file) |

---

## Decision tree (agents)

```
list/sell 100% for X ETH?
  ├─ password / gated / max per wallet / shares / partial% → SITE ONLY (right autopilot file)
  ├─ user said "site only" or "OpenSea only" → that venue
  └─ else → DUAL: site steps + OpenSea skills (default)
```

---

## What “listed” means

| Mode | Success |
|------|---------|
| **Dual (default)** | `listedOnSite: true` + shop URL + OpenSea item URL |
| **Site only** | `listedOnSite: true` + shop URL |
| **OpenSea only** | Seaport order confirmed + item URL |

---

## API

`POST /api/list/dual` returns **`site.steps[]`** + **`openSea`** — use **both** for default dual. Field `"password"` in body → **site only**, skip OpenSea step.

---

## Cross-links

- **`sell-list-autopilot.md`** — sell 100% checklist  
- **`share-market-list-autopilot.md`** — units / maxPerWallet (site only)  
- **`AGENT-ROUTING-LISTINGS.md`** — routing guard
