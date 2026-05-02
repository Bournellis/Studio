# Product Vision

## 1. Purpose of This Document

This document defines the product vision of the game.

Its purpose is to align:

- creative direction
- conceptual scope
- gameplay identity
- progression philosophy
- product-level priorities

This document does not define:

- active implementation status
- engine-local execution plans
- operational ownership by track or phase
- runtime snapshots from any specific engine project

Operational truth belongs in the local implementation workspace, not here.

---

## 2. Overview

RPG Isometrico is a campaign-first isometric action game centered on:

- race-based character identity
- kit identity through race, weapon, skills, and potions
- authored PvE campaign progression
- readable, responsive combat
- persistent progression through fixed unlocks

The core fantasy is:

- enter an authored PvE campaign with a clear combat identity
- learn and expand a race/weapon kit through play
- execute combat with precision, timing, and adaptation
- use permanent unlocks in replay paths and complementary modes

The game is not built around procedural loot, random gear tiers, or chaotic itemization.

Its identity is based on:

- **race identity**
- **kit mastery**
- **campaign-led progression**
- **execution mastery**
- **persistent unlock-driven progression**

---

## 3. Setting

The setting is spatial, atemporal, and multi-cultural. It blends futuristic, contemporary, and ancient aesthetics, with each race expressing a different philosophy of combat and world-building.

Technology and magic coexist. A race may lean toward advanced technology, military craft, mythic weaponry, or arcane power, but every race must still read clearly inside the same combat language.

Visual direction:

- low-poly stylized 3D
- dark, intense atmosphere
- toon-influenced shading with rim light
- bright impact effects against darker environments

Lore is primarily presented and evolved through campaigns. Complementary modes may use light diegetic framing such as training, trials, or challenges, but they do not carry the main narrative burden.

Players who want lore should be able to discover it, but the game should never force heavy exposition before the combat fantasy is clear.

---

## 4. Race System

Race is the primary character definition.

Each race should define:

- a world identity
- a weapon pool
- a skill or spell pool
- a potion layer inside the loadout
- a lore and aesthetic language

Placeholder race directions:

- **Humans**: military identity, bullets, reloads, tactical ranged control
- **Heroic**: mythic weapons with magical properties, melee pressure, direct combat expression
- **Intelligent Aliens**: advanced technology, lasers, magnetism, drones, engineered battlefield control
- **Magic Beings**: teleportation, arcane attacks, mental manipulation, magical mobility

These race directions are canonical as identity territory, but not as a declaration of fully authored content.

### Race Growth Rule

Races do not need equal numbers of weapons or skills.

Content asymmetry is acceptable. What must stay viable is:

- meaningful kit expression
- mode viability where applicable
- a minimum viable threshold before a race is considered release-ready

That minimum threshold is:

- at least 1 fully implemented weapon
- enough skills to support genuine pre-match selection of 4
- a defined potion pool

---

## 5. Loadout Structure

The canonical loadout is:

`Race -> 1 Weapon -> 4 Skills -> 2 Potions`

Rules:

1. **Race** defines identity and content pool.
2. **Weapon** defines the basic attack and the movement skill.
3. **Skills** are selected pre-match from the weapon's or race's pool.
4. **Potions** are selected pre-match from the available potion pool.

Additional rules:

- passive slots do not exist
- weapon swap does not exist
- the movement skill is tied to the weapon and is not a selectable skill slot
- skins are cosmetic only

The full loadout is the long-term kit contract and the default surface for free replay, buildcraft, and complementary challenge modes.

The main Classic campaign may expose this contract gradually through authored onboarding, fixed starting states, level-up beats, and permanent unlocks. A new player does not need to face the full selection surface before the first mission.

---

## 6. Game Modes

The project is campaign-first and may contain multiple modes that share:

- the same combat identity
- the same kit contract where the mode exposes free selection
- the same race-first character logic
- the same fixed isometric camera language

Mode hierarchy:

1. **Campaigns** are the primary product experience and the main lore/progression surface.
2. **Survival, Boss, and Arena Bot** are complementary replay, mastery, and combat-test surfaces.
3. **Private Duel** is a future or development-only social duel surface, not a public competitive pillar.
4. Broader PvP and MOBA structures are long-term possibilities only if the product proves they are worth the cost.

### Platform

Steam on PC is the primary release platform.

Mobile is a planned future expansion after the PC version is validated with real players. Platform differences may affect input, performance posture, and service integration, but they must not redefine the game's core identity.

### Product Evolution Order

The product is expected to evolve in this order:

1. validate readable isometric combat locally
2. build a campaign-first PvE product spine
3. consolidate shared kit, HUD, results, and runtime contracts
4. deepen campaign, survival, and boss replay value
5. polish menu flow, readability, stability, and local persistence
6. add Steam-facing services only when the local baseline is strong
7. add co-op if it does not compromise the solo-first campaign
8. add private duel by direct invite as an experimental or later social surface
9. consider broader PvP or MOBA depth only if product traction justifies it

This order is directional, not a statement of active implementation status.

### Campaigns

Campaigns are the primary product mode: authored multi-stage PvE adventures for solo play, with co-op optional when it can preserve the solo-first baseline.

They should combine:

- short authored stages
- lore and world progression
- between-stage upgrades
- meaningful death consequences
- permanent unlock rewards tied to completion

Campaign structure:

- **Classic** is the main authored path and the primary source of permanent gameplay unlocks.
- **Free** is a replay/buildcraft path that can use broader unlocked kits after Classic progression.

### PvE Extra Modes

Short standalone PvE challenges include:

- Survival
- Boss Mode
- future mini-games to be defined

These modes are pass-time, mastery, and replay surfaces built from the same combat and asset base. They should be easy to enter, readable in session goals, and compatible with the campaign-led progression model.

### Arena Bot

Arena Bot is a local combat test and replay surface.

Arena Bot priorities:

- fast sessions
- tactical positioning
- readable skill timing
- kit experimentation after unlocks
- low-stakes practice outside the campaign

### Private Duel

Private Duel is a future or development-only direct-invite mode for two players who already know each other.

Rules:

- no public matchmaking requirement
- no ranked ladder requirement
- no server-authoritative competitive promise
- no dedicated server requirement in the current product plan

Private Duel may use the same arena combat language, but it must be framed as casual/social unless a future product decision funds stronger online authority and competitive support.

### MOBA PvP

Lane-based PvP with bases, towers, minions, crystal buffs, and boss objectives is a long-term possibility, not a near-term release promise.

MOBA requires dedicated design and production work before it can be promoted.

---

## 7. Gameplay Identity

Combat must be:

- responsive
- readable
- tactical
- positioning-driven
- suitable for short sessions
- consistent across platforms at the rules level

The camera is always:

- fixed
- isometric
- non-rotating

Every important action needs immediate readability:

- basic attack
- movement skill
- skill cast
- potion use
- damage taken
- death
- imminent danger

---

## 8. Control Model

The product must respect real platform differences without fragmenting the identity of the game.

### Mobile

Mobile follows a combat layout inspired by mobile action-arena conventions:

- left thumb: virtual joystick
- right thumb: basic attack, movement skill, 4 skills, and 2 potions
- short press: soft-lock behavior where appropriate
- hold or drag: free aim where appropriate

### PC

PC uses:

- WASD movement
- mouse aim
- keyboard shortcuts for combat actions

### Shared Rule

The same combat logic should apply across platforms. Only the input adaptation changes.

When Arena, Arena Bot, Survival, and Boss coexist as active surfaces, they should share one `Combat Shell` HUD family. World-space combat feedback remains adjacent presentation, not part of the shell itself.

---

## 9. Progression

Progression is local and built around permanent unlocks earned through gameplay.

There are two distinct layers:

- **content unlocks**
- **mastery tracking**

### Content Unlocks

Playable content is unlocked through play, especially by completing authored campaign content that introduces new races, weapons, skills, and potions.

The game must not depend on procedural loot rarity or a grind-based gear economy.

### Early Account And Mode Access

A new account may expose only a narrower part of the loadout contract at first.

Examples:

- only 1 race and 1 weapon unlocked
- potions temporarily fixed by mode
- extra modes exposing only currently unlocked content
- Classic campaigns offering authored kit progression
- Free campaigns and extra modes exposing broader unlocked kits

### Mastery Tracking

Mastery exists to reflect investment, not to gate access.

Tracked areas may include:

- race usage
- weapon usage
- skill usage
- mode-specific results

---

## 10. Monetization Model

The game uses:

- a free demo
- a one-time purchase for the full game
- cosmetic-only monetization where broader service layers justify it

Rules:

- no subscriptions
- no season passes
- no gameplay power sold for money
- no premium currency layer between player and cosmetic purchase

### Free Demo

The free demo should feel like a complete first taste of the game, not a timer-limited teaser.

### Full Game

Buying the game grants access to the existing full-game content and future gameplay expansions included in the product model.

### Cosmetic Shop

If a cosmetic shop exists, it must remain visual-only and preserve gameplay fairness.

---

## 11. Risk and Failure

Matches and runs must carry real consequence.

Failure principles:

- Boss and duel-style modes: one life where the mode rules call for it
- Campaigns: death ends the run unless co-op recovery rules save it
- the run must matter enough for victory and defeat to feel meaningful

---

## 12. Product Pillars

### Race Identity

Choosing a race is choosing a combat philosophy, not just a look.

### Tactical Clarity

Players should quickly understand:

- what their kit does
- why a play succeeded
- why a play failed
- what they might change next time

### Kit Commitment

Kit choices and campaign unlocks must matter, but the Classic campaign may teach them through authored progression before exposing freer buildcraft.

### Responsive Combat

Movement, attack, skills, and potions must communicate control and impact.

### Short Matches With Consequence

Sessions should fit short windows without losing stakes.

### Progression Through Unlocks

Player growth comes from expanding permanent possibilities, not from random gear escalation.

### Campaign-Led Mode Compatibility

Different modes must still feel like they belong to the same game, but the campaign is the product spine and the main lore/progression surface.

---

## 13. Conceptual Scope

This project is:

- a campaign-first isometric action game
- race-first in character identity
- kit-driven in combat mastery
- PvE-first, with optional co-op and future private-duel potential
- progression-led through fixed unlocks
- Steam-first in release posture

This project is not:

- a loot-centric ARPG
- a rigid fixed-role class game
- an open-world RPG
- a product that depends on large-scale matchmaking at launch
- a product that depends on ranked PvP or dedicated servers for Release 1
- a pay-to-win economy

---

## 14. Development Posture

The product should be implemented incrementally.

Preferred posture:

- validate core combat first
- anchor the commercial product around a strong campaign-first PvE baseline
- extend into complementary local modes without letting them redefine the product
- consolidate shared runtime contracts
- strengthen UX and presentation
- add platform-service seams only after the local baseline is strong enough
- open co-op, private duel, or broader PvP only through explicit future gates

Operational status, active tracks, and implementation history do not belong in this document.

Everything implemented should still respect the full long-term vision, even when only a subset of modes or content is active in the current build.

---

## 15. Direction of Product Evolution

Acceptable future directions include:

- expanding the race roster
- expanding weapon and skill catalogs
- deeper campaign content
- co-op campaign support if it preserves the solo-first baseline
- private duel by direct invite
- broader versus support only if product traction justifies it
- a richer navigable hub or frontend shell
- broader cosmetic offerings

These expansions must preserve:

- race identity
- readable kits
- responsive combat
- real risk
- progression through unlocks

---

## 16. Rule for Using This Document

Use this document when the question is about:

- product identity
- design intent at a high level
- progression philosophy
- monetization philosophy
- mode compatibility
- long-term direction

For detailed rule definitions, weapon designs, arena design, combat stats, and mastery specifics, read `../design/game-design-document.md`.

If a technical or operational decision conflicts with this vision, reconsider the implementation or explicitly revise canon.
