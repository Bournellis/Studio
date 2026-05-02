# Evolution Roadmap

## 1. Purpose of This Document

This document defines the intended order and principles of product growth for RPG Isometrico.

It exists to:

- describe how the game should expand over time
- protect the architecture from short-sighted decisions
- separate product evolution from engine-local execution logs
- explain what should generally come before what

This is not a status report and not a local implementation board.

---

## 2. Evolution Order

The product should generally evolve in this order:

1. validate tight isometric combat locally
2. build the campaign-first PvE spine around authored progression, lore, and unlocks
3. consolidate shared systems such as kit flow, HUD shell, results flow, and mode contracts
4. support complementary PvE replay surfaces such as Survival and Boss
5. strengthen menu flow, readability, stability, and local persistence around the validated base
6. open Steam-facing services only after the local baseline is strong enough
7. add co-op only if it preserves the solo-first campaign baseline
8. add private duel by direct invite as a casual/social or experimental surface
9. consider broader PvP or MOBA depth only if product traction justifies it

This order is directional and product-level. It must not be mistaken for a currently active phase list.

---

## 3. Roadmap Principles

### Expand in Layers, Not Restarts

The project should grow by extending proven systems, not by repeatedly discarding foundations.

### Prefer Stronger Baselines Over More Surface Area

If there is a conflict between opening new systems and strengthening the current base, prefer the stronger base first.

### Separate Product Direction from Operational Status

Track names, active workstreams, and implementation handoffs belong in local implementation docs, not in canon.

### Add Services After Core Play Holds Up

Steam-facing services, cloud sync, and broader platform seams should come after the local runtime is trustworthy enough to carry them cleanly.

### Preserve Identity While Expanding

Every evolution step must preserve:

- race identity
- meaningful kit expression
- readable combat
- consequence in failure
- progression through permanent unlocks

---

## 4. Expansion Priorities

### Runtime First

Shared combat, mode flow, results flow, and readable presentation are the first layer of long-term value.

### Platform Services Second

Networking, cloud save, leaderboards, and ownership confirmation should sit on top of clean gameplay and presentation seams.

### Campaign First, Extras Afterward

Campaign depth is the product spine. Survival, Boss, Arena Bot, and Free campaign replay should support the campaign-led product rather than compete with it.

Co-op, private duel, broader PvP, and MOBA structures should build on a strong campaign-first base rather than trying to justify it retroactively.

---

## 5. Conditional Growth

Some investments should happen only if the product proves they are worth the cost:

- dedicated servers
- public matchmaking at scale
- ranked competitive support
- deep social systems
- broader procedural content systems
- much larger service complexity

These should follow clear product value, not speculative anticipation.

---

## 6. Relationship to Release Planning

`release-horizons.md` describes how the released product is expected to grow outward over time.

This document explains the order in which the product should normally become capable of supporting that future.

If release planning changes, update `release-horizons.md`.

If product-evolution ordering changes, update this file.
