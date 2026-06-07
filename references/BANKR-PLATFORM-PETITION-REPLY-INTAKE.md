# Bankr platform — petition reply intake (YES / $TICKER)

> **Audience:** Bankr engineering. Skill + API are ready; tweet replies must route to deposit, not READ-ONLY `useskill`.

---

## User replies (sufficient TRIGGER)

On a **petition thread** (creator tweet or site announcement), users may reply:

```text
@bankrbot yes
yes!
!
$UP
join
```

They do **not** need: `back petition #19 with 100 units`.

---

## Required platform behavior

```
1. Detect reply to petition promo / announcement tweet
2. Resolve petitionId (from thread metadata, URL in parent, or status lookup)
3. GET …/api/petition/status?id={id}
   → agentParticipation.defaultReplyUnits (e.g. 100)
4. GET …/api/petition/prepare-deposit?id={id}&wallet=<linked>&replyText=<raw reply>
   (or units=yes / intent=yes)
5. Quote deposit.totalEth — user confirms micro ETH send
6. bankr.tx.prepare(nextStep) → POST /confirm
7. Reply: units reserved, tx link, remaining until sold out
```

**Hard block:** `useskill` as final step when reply matched YES / $TICKER / !.

---

## API fields (live)

| Endpoint | Field |
|----------|--------|
| `GET /status` | `simpleReplyEnabled`, `defaultReplyUnits`, `acceptedReplyPhrases`, `replyHint` |
| `GET /prepare-deposit` | `replyText`, `intent=yes`, `units=yes` → `unitsResolvedFrom` |

Skill: **`petition-reply-thread.md`** · **`petition-autopilot.md`** § P-back

---

## Not automatic yet

- Reply without **linked Bankr wallet** — must prompt link / DM
- **Creator-paid** free units on reply — not implemented
- Reply detection on X — **Bankr platform** (not TMP twitter-bot alone)
