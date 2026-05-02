# Game Design Document

## 1. Purpose of This Document

This document is the detailed gameplay-design reference for RPG Isometrico.

Use it to define:

- race and loadout rules
- mode rules
- reference weapon designs
- progression inside matches and runs
- combat stats and buff vocabulary
- arena layout language
- mastery and data rules

For product identity and scope, read `../product/product-vision.md` first.

Operational status does not belong here.

---

## 2. Race System

### Overview

Race is the primary character definition. It determines:

- weapon pool
- skill pool
- potion layer
- visual language
- lore territory

### Race Structure

Each race has:

- a world identity
- a weapon pool
- a skill or spell pool
- a potion layer inside the loadout
- aesthetic and lore hooks

### Placeholder Race Directions

| Race | Identity | Weapon Examples | Resource Direction |
| --- | --- | --- | --- |
| Humans | Military combatants | Assault Rifle, Sniper, Desert Eagle, Machine Gun | Bullets, reload, disciplined ranged tempo |
| Heroic | Mythic warriors with magical weapons | Hammer, Bow, Sword, Spear | Varies by weapon |
| Intelligent Aliens | Advanced technological civilization | Lasers, magnetic weapons, drone summons | To be defined |
| Magic Beings | Arcane power users | Teleportation, magic attacks, mental manipulation | To be defined |

These are product-level design territories, not a declaration of currently implemented content.

### Race and Weapon Relationship

A weapon belongs to a race.

Rules:

- the race defines the broader combat identity
- the weapon defines the basic attack and movement skill
- the skill pool may include weapon-specific and race-wide options

### Race Pool Asymmetry

Races do not need equal content counts.

What matters is:

- meaningful pre-match choice
- viability where the mode demands fairness
- minimum release-ready completeness

Minimum release-ready threshold:

- at least 1 fully implemented weapon
- enough skills to support real selection of 4
- a defined potion pool

### Skins

Skins change visuals only:

- race appearance
- weapon appearance
- skill or movement effects

They must have no mechanical impact.

---

## 3. Loadout Structure

The canonical loadout is:

`Race -> 1 Weapon -> 4 Skills -> 2 Potions`

### Loadout Components

1. **Race**
2. **Weapon**
3. **Skills (4)**
4. **Potions (2)**

### Weapon Model

Every weapon has exactly:

- 1 basic attack pattern
- 1 movement skill tied to the weapon
- 4 skill slots selected pre-match

Rules:

- passive slots do not exist
- weapon swap does not exist
- the movement skill is not one of the 4 selectable skill slots

### Player-Facing Surface

The canonical loadout may be exposed gradually depending on mode or account state.

Examples:

- campaigns offering authored presets
- Classic campaigns unlocking kit pieces through authored progression
- Free campaigns and extra modes exposing broader unlocked options
- early profiles with a narrower selection surface

The project is kit-first rather than loot-first. The full loadout contract remains canonical, but the main Classic campaign may teach and unlock the kit before asking the player to make full buildcraft decisions.

---

## 4. Game Modes

### Product Evolution Order

The design is expected to grow in this order:

| Order | Focus | Notes |
| --- | --- | --- |
| 1 | Local combat validation | Feel, readability, camera, and kit expression |
| 2 | Campaign-first PvE spine | Authored progression, tutorial, lore, and unlock path |
| 3 | Shared-system consolidation | Kit, HUD, frontend, results, runtime contracts |
| 4 | Survival and Boss replay support | Complementary PvE mastery and challenge surfaces |
| 5 | Runtime and menu polish | Stronger baseline before broader services |
| 6 | Steam-facing services | Cloud save, leaderboards, ownership seams, optional invites |
| 7 | Optional co-op | Only if it preserves the solo-first campaign baseline |
| 8 | Private duel experiment | Direct invite, casual/social, no public competitive promise |
| 9 | Broader versus or MOBA | Long-term only if product traction justifies it |

This order is design direction, not active implementation status.

### 4.1 Campaigns

Campaigns are the primary product mode: multi-stage authored PvE adventures for solo play, with co-op optional if it does not compromise the solo-first baseline.

**Structure:**

- 5 authored stages
- Stage 1 is the tutorial mission for the first campaign
- one clear objective per stage
- Stage 5 reserved for the boss encounter
- informational reward presentation between stages
- forced level-up pause at the start of the next stage

**Classic path:**

- main authored route
- primary lore and onboarding surface
- primary source of permanent gameplay unlocks
- may expose the kit gradually instead of requiring full pre-mission loadout choice

**Free path:**

- replay/buildcraft route after Classic progression
- can use broader unlocked kits
- not the primary source of permanent gameplay unlocks

**Death rule:**

- death resets the run
- accumulated temporary buffs and gold are lost
- co-op may allow surviving players to save the stage and revive allies later
- returning to menu or closing the game suspends the solo run instead of counting as failure

**Upgrade loop:**

- each cleared stage grants a level
- levels grant stats plus one skill point
- the skill point is spent at the start of the next stage
- the point may be invested into any still-locked spell

**Target durations:**

- Easy: ~20-25 minutes
- Normal: ~25-30 minutes
- Hard: ~30-40 minutes

Full campaign discovery remains in `../../materiais/references/discovery/campaign-design-discovery.md`.

### 4.2 PvE Extra Modes

Short standalone PvE challenges complement the campaign.

Current design territories:

- **Survival**: hold out against sustained enemy pressure
- **Boss Mode**: defeat a single scripted boss in a short encounter
- future mini-games to be defined later

These modes are replay, mastery, and pass-time surfaces. They may have light diegetic framing such as training, trials, or challenges, but the campaign remains the main lore and progression surface.

### 4.3 Arena Bot

Arena Bot is a local combat test and replay surface, not the product's main competitive promise.

**Core loop:**

1. configure an unlocked kit where the mode exposes free selection
2. spawn into the arena
3. fight a bot in real time
4. grow through in-match progression where enabled
5. lose on first death where the mode rules call for it

Arena Bot remains useful for camera, controls, timing, and combat readability.

### 4.4 Private Duel

Private Duel is a future or development-only social mode for direct invitation between players who already know each other.

**Format:** 1v1 direct invite

**Core loop:**

1. configure loadout
2. spawn into the arena
3. fight in real time
4. grow through in-match progression
5. lose on first death

**Map elements:**

- permanent walls and tactical blockers
- destructible elements where the arena language allows them
- neutral crystal spawns that reward last-hit control

**Match target:** 1-8 minutes

Rules:

- no public matchmaking requirement
- no ranked ladder requirement
- no dedicated server requirement in the current plan
- no server-authoritative competitive promise
- host authority is acceptable only for casual/social framing unless a later product gate changes the online model

### 4.5 MOBA PvP

**Format:** 1v1, 2v2, future 3v3

**Core loop:**

1. each side defends a base
2. minions push a single lane
3. players earn XP from proximity
4. players earn Gold from last hits
5. Gold upgrades the base, not personal items
6. crystal buffs and boss objectives add map pressure
7. victory comes from destroying the enemy base

**Target duration:** 7-15 minutes

This mode needs dedicated design work and clear product traction before production.

---

## 5. Reference Weapon Designs

These designs are early combat-validation references. They are canonical combat vocabulary, not a declaration of current shipped content.

### 5.1 Martelo (Hammer) — Heroic

**Combat identity:** close-range pressure, crowd control, commitment windows

#### Basic Attack — 3-Hit Combo

| Hit | Damage | Effect |
| --- | --- | --- |
| Hit 1 | Light | — |
| Hit 2 | Medium | — |
| Hit 3 | Heavy | Brief mini stun |

#### Movement Skill — Speed Burst

- hold to gain strong movement speed
- release to enter cooldown
- collision with an enemy can mini stun on entry
- functions as aggressive gap-close and pressure tool

#### Skill 1 — Ground Slam

| Tier | Description |
| --- | --- |
| Base | Telegraph then slam a cone for damage plus stun |
| Upgrade | Larger cone and more damage |
| Ultimate | More damage and longer stun |

#### Skill 2 — Hammer Throw

| Tier | Description |
| --- | --- |
| Base | Throw hammer forward, then recall it for a second hit; basic attack disabled while away |
| Upgrade | More damage and stronger slow |
| Ultimate | Return hit stuns instead of slowing |

#### Skill 3 — Leap Strike

| Tier | Description |
| --- | --- |
| Base | Leap to a target area for damage plus slow |
| Upgrade | Lower cooldown |
| Ultimate | Landing stun plus lingering damage field |

#### Tactical Loop

Burst entry -> combo pressure -> Slam punish -> Leap reposition -> Throw for risky ranged pressure

### 5.2 Rifle de Assalto (Assault Rifle) — Human

**Combat identity:** tactical field control, ranged pressure, reload windows

#### Basic Attack — Burst Fire

- 3 shots per burst
- magazine-based ammo
- forced reload on empty

#### Movement Skill — Jump + Roll

- short or medium evasive reposition
- low cooldown
- emphasizes reactive spacing rather than direct entry

#### Skill 1 — Impact Grenade

| Tier | Description |
| --- | --- |
| Base | AoE damage plus stun |
| Upgrade | Larger radius and more damage |
| Ultimate | Double explosion with delayed follow-up knockback |

#### Skill 2 — Barricade

| Tier | Description |
| --- | --- |
| Base | Temporary HP-based barrier that blocks bodies and projectiles |
| Upgrade | More HP and duration |
| Ultimate | Barricade mounts an automatic gun |

#### Skill 3 — Land Mine

| Tier | Description |
| --- | --- |
| Base | Hidden mine triggers on proximity for damage plus small stun |
| Upgrade | More damage and larger trigger radius |
| Ultimate | Supports two active mines and a lingering slow zone |

#### Tactical Loop

Reposition -> block path with barricade -> trap a route -> apply burst fire pressure -> punish with grenade

#### Matchup Intent

The hammer-rifle matchup expresses:

- melee entry versus ranged setup
- reload vulnerability versus burst-in pressure
- terrain control versus direct engage

---

## 6. In-Match Progression System

### Structure

**Free-selection sessions:** choose 1 weapon, 4 skills, and 2 potions within the race contract.

**Classic campaign sessions:** the same kit contract may be exposed through authored starting states, tutorial beats, campaign level-ups, and permanent unlocks.

**In-match progression:** 7 levels over roughly a short match cadence.

| Level | Player Action |
| --- | --- |
| 1 | Activate first selected skill |
| 2 | Activate second selected skill |
| 3 | Activate third selected skill |
| 4 | Activate fourth selected skill |
| 5 | Upgrade one skill to Level 2 |
| 6 | Upgrade one skill to Level 2 |
| 7 | Choose one Ultimate upgrade |

### Stats Per Level

| Stat | Per Level | At Max |
| --- | --- | --- |
| Damage | +10% | +70% over baseline |
| Max HP | +6% | +42% over baseline |

These are baseline tuning values and should remain subject to playtesting.

### Design Intent

Kit choice or authored campaign progression defines **what** can be used.

In-match choice defines **when** and **in which priority order** the kit comes online.

---

## 7. Character Attribute System

### Design Principles

- one damage type, no physical or magical split
- separate scaling for Basic Attack Damage and Spell Damage
- flat block applies before percentage resistance
- in-match level bonuses scale both attack and spell output

### Universal Attributes

| Attribute | Baseline |
| --- | --- |
| Max HP | 1000 |
| Basic Attack Damage | 1.0x |
| Spell Damage | 1.0x |
| Attack Speed | 1.0x |
| Movement Speed | 5 u/s |
| Damage Block | 0 |
| Damage Resistance | 0% |
| Effect Resistance | 0% |

### Conditional Attributes

Granted by skills, potions, or buffs:

- Shield
- Lifesteal
- Critical Chance
- Critical Damage
- Cooldown Reduction
- AoE Size

### Weapon-Specific Attributes

Examples:

- reload speed
- magazine size
- projectile speed
- movement-skill duration
- combo window timing

Legacy combat-validation discovery values remain in `../../materiais/references/discovery/phase-3-design-discovery.md`.

---

## 8. Potions

Each player equips `2` potions per free-selection session.

Classic campaign routes may introduce or equip potions through authored progression before the full potion-selection surface is available.

The exact shared potion pool is an implementation-owned content decision until canon explicitly promotes a stable package.

Base archetypes already validated in design vocabulary include:

| Archetype | Intent |
| --- | --- |
| Heal | recover HP and create a readable punishable timing window |
| Barrier | absorb an incoming hit or short burst |
| Movement Speed | create pursuit, disengage, or reposition windows |

Numerical tuning stays subject to playtesting.

---

## 9. Crystal Buff System

Crystals may appear in arena-like modes and reward permanent in-session buffs through last-hit control.

They are not a Release 1 campaign requirement.

### Crystal Object Mechanics

| Parameter | Value |
| --- | --- |
| Crystal HP | 600 |
| Reflect to attacker | 30% of dealt damage |
| Reflect AoE | 8% in a small radius |
| Last-hit rule | killing blow gets the buff |
| Buff duration | lasts until match end |

### Arena Behavior

- one crystal appears on a timed cadence
- crystal fights happen in the neutral center
- stacking buffs creates a compounding advantage

### Canonical Buff Vocabulary

| Buff | Effect | Category |
| --- | --- | --- |
| Furia | +8% Basic Attack Damage | Offensive |
| Poder Arcano | +8% Spell Damage | Offensive |
| Golpe Certeiro | +4% Critical Chance | Offensive |
| Aceleracao | +0.4 u/s Movement Speed | Utility |
| Velocidade de Ataque | +6% Attack Speed | Utility |

These values remain tuning baselines.

---

## 10. Arena Design — A Forja

`A Forja` is the canonical arena identity for the primary duel surface.

### Spatial Language

- larger rectangle than the earliest blocked-center prototype
- fully open center for crystal contest
- mixed outer open and closed sections
- outer pathing choices that add angles without losing readability

### Environment Vocabulary

- border walls
- tall internal walls
- selected destructible crates that open routes cleanly

### Design Intent

- the center belongs to direct contest
- outer sections create positional bias without overwhelming the duel
- readability matters more than decorative complexity

Final geometry details remain implementation-owned as long as the shared layout rules are preserved.

---

## 11. Combat Philosophy

### Rhythm

Combat should alternate between:

- reading and positioning
- decisive burst windows
- recovery and reset

### Feedback

Feedback should be bright, high-contrast, and impact-heavy relative to the environment.

### Hitstop

Hitstop remains a tuning tool to be validated through playtesting rather than fixed by canon in advance.

### Camera

The target camera is between classic isometric and top-down tactical:

- readable character silhouettes
- arena-first composition
- enough zoom to read positioning and movement skills

Exact values should be tuned through playtesting.

---

## 12. Control Model

### Mobile

- left side: movement joystick
- right side: basic attack, movement skill, 4 skills, 2 potions
- short press for soft-lock where appropriate
- hold or drag for free aim where appropriate

### PC

- movement on WASD
- aim on mouse position
- skill activation on keyboard shortcuts

### Shared Rule

The same combat logic should apply on both platforms.

When Arena, Arena Bot, Survival, and Boss coexist, they should share one `Combat Shell` HUD family. Floating combat text remains adjacent world-space feedback instead of part of the shell itself.

---

## 13. Visual Direction

- low-poly stylized 3D
- dark, intense atmosphere
- toon-influenced shading with rim light
- bright particles and impact flashes against darker environments

### Asset Pipeline Direction

Preferred pipeline:

1. concept or AI-assisted generation where appropriate
2. Blender cleanup
3. animation retargeting or authoring
4. engine import and validation

The pipeline should remain engine-agnostic at canon level.

---

## 14. Progression and Monetization

### Free Demo

The demo should be a real playable slice, not a timer-limited tease.

### Full Game

The full game is a one-time purchase.

### Difficulty Levels

PvE content may offer multiple difficulty levels.

Easy is the intended entry point for unlock progression.

### Content Unlock Gate

Completing authored PvE content at the intended entry difficulty can unlock the content introduced by that adventure.

### Versus Mode Access

If private duel ships later, players who own the game should not pay extra to access that duel mode.

### Cosmetic Shop

If cosmetics are sold, they must remain purely visual.

---

## 15. Data, Leaderboards, and Mastery

### Local Authority for PvE

PvE progression and run data are locally authoritative.

Save data lives locally and may sync through Steam Cloud, but gameplay must never block on service calls.

### Leaderboards

Steam Leaderboards are the canonical leaderboard surface for published builds.

Example metrics:

| Mode | Primary Metric |
| --- | --- |
| Survival | longest survival time |
| Boss | fastest clear time |
| Campaign | fastest full clear |

Private Duel has no canonical leaderboard requirement in the current plan.

### Mastery System

Mastery is informational only.

Tracked areas may include:

- race playtime and match count
- weapon damage and usage count
- skill damage and cast count

---

## 16. Long-Term Design Areas

These areas remain open for dedicated future design:

- final race lore and catalog depth
- broader weapon catalogs per race
- complete skill catalogs
- full MOBA ruleset
- private duel networking and authority details
- co-op campaign recovery rules
- campaign mission variants and upgrade depth
- survival scaling depth
- boss roster expansion
- tutorial and onboarding
- narrative delivery model
- sound and music direction

---

## 17. Steam Integration Reference

Steam-facing implementation details live in `../platform/steam-platform.md`.

That document governs:

- networking expectations for release builds
- cloud save boundaries
- leaderboard submission seams
- cosmetic ownership confirmation seams
- local-first persistence even when Steam services are active

Development or internal-test networking should remain behind engine-local operational docs, not inside canon.

---

## 18. Rule for Using This Document

Use this document when the question is about:

- exact loadout rules
- mode rules
- reference weapon behavior
- arena design language
- buff vocabulary
- mastery and data rules

If implementation or discovery notes conflict with this document, update canon explicitly rather than allowing silent drift.
