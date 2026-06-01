# Listing venues — Token Marketplace and OpenSea (both supported)

> **Updated:** June 2026 · OpenSea indexing is working again. Agents may list on **either** venue or **both**.

---

## Default (user does not name a venue)

| Step | Venue |
|------|--------|
| 1 | **[tokenmarketplace.shop](https://www.tokenmarketplace.shop)** — `POST /api/list/dual` → approve + list → verify `listedOnSite` + **shop URL** in reply |
| 2 | **OpenSea** (optional follow-up) — **opensea-marketplace** skills using `openSea` hints from `list/dual` — only after site succeeds **or** if user asked for OpenSea |

**Do not ask:** “Site or OpenSea?” · “Which marketplace?”

---

## User names a venue

| User says | Agent does |
|-----------|------------|
| **on tokenmarketplace** / **on the site** / **on marketplace** (no OpenSea) | **Site only** — shop URL required for success |
| **on OpenSea** / **OpenSea only** | **OpenSea** via opensea skills — use `openSea.itemUrl` from API or collection **tokenmarketplace** |
| **both** / **site and OpenSea** | Site first → then OpenSea |
| **list for 0.01 eth** (no venue) | **Default** row above |

---

## What “listed” means

| Venue | Success check |
|-------|----------------|
| **Site** | `GET /api/list/status` → `listedOnSite: true` + paste **`siteListingUrl`** |
| **OpenSea** | Seaport order live (OpenSea skills confirm) — give **item URL** |
| **Both** | Site URL **and** OpenSea item link when both requested |

**Sell 100% only** — partial sale / share units / group buy are **site-only** (no OpenSea). See **`listing-channels.md`**.

---

## API note

`POST /api/list/dual` returns **`site.steps[]`** and **`openSea`** hints — use **site** calldata always; use **openSea** block when listing on OpenSea.

---

## Cross-links

- **`sell-list-autopilot.md`** — full sell-100% checklist
- **`listing-channels.md`** — product matrix
- **`AGENT-ROUTING-LISTINGS.md`** — routing guard
