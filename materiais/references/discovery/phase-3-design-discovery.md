# Phase 3 Design Discovery

## Purpose

This document records the design decisions made during the Phase 3 design discovery session.

These decisions inform all Phase 3 implementation. They are not final — iteration during Phase 3A playtesting may revise them — but they are the authoritative starting point for execution.

---

## 1. Combat Rhythm

**Decision:** Reading + Explosion with sustained combo.

The ideal player reads the field, positions correctly, and when the opening arrives — executes a sustained combo that destroys the target. Periods of repositioning and reading followed by concentrated burst damage.

This means:
- Basic attack has weight and cadence, not spray-and-pray
- The combo has a natural rhythm the player learns to execute confidently
- The loadout defines what the "explosion" looks like
- Bringing the wrong kit makes the explosion harder to land

---

## 2. Weapon Swap

**REMOVED — 2026-04-12 (Phase 5 Consolidation)**

Weapon swap has been removed from the game design. The loadout is now: Race → 1 weapon (with fixed movability/dash) → 4 spells → 2 potions. There is no second weapon slot and no swap mechanic. This decision was made to simplify the combat identity and remove architectural complexity across all game modes.

---

## 3. Visual Feedback Intensity

**Decision:** High and exuberant. Particles, effects, color explosions on each significant hit.

This contrasts strongly with the dark atmosphere — bright impact effects against dark environments. Reference: Hades, Returnal.

**Hitstop:** To be tested with 0, 3, and 6 frame variants in early Phase 3A builds. Final value decided after playtesting.

---

## 4. Camera

**Decision:** Between classic isometric (45° pitch) and top-down tactical (55-60° pitch). Character small, arena highlighted.

- Arena is the star of the shot, not the character
- Character remains readable (silhouette and animations visible) but is not dominant on screen
- Starting tuning target: pitch ~52-55°, zoom slightly more open than current Phase 2 values
- Two camera configurations will be tested in Phase 3A builds before final decision

Current Phase 2 values for reference: pitch 50, yaw 45, zoom range 14-22, FOV 46.

---

## 5. Setting and Narrative

**Decision:** Lore definition deferred. Will be developed collaboratively in a later session.

**Narrative tone:** Atmospheric. Rich lore exists and can be discovered if desired, but is not forced on the player. Environmental storytelling model (Dark Souls reference). No heavy dialogue or mandatory narrative arcs in the base experience.

---

## 6. Weapon Archetypes

**Decision:** All 6 core archetypes are desirable. Diversity of gameplay expression is a goal.

The 6 target archetypes:

| Archetype | Identity | Range | Playstyle |
| --- | --- | --- | --- |
| The Precision Executor | Deliberate, high-damage hits. Each hit matters. | Medium | Patient, punishing, high-reward |
| The Melee Storm | Rapid hits, constant pressure, damage by accumulation | Close | Aggressive, relentless |
| The Area Devastator | Slow, heavy, explosive AoE. Clears groups. | Close-medium | Setup, positioning, group control |
| The Battle Mage | Arcane projectiles with special effects | Medium | Elemental, combo-oriented |
| The Lethal Evader | Mobility as offense. Dash and reposition are attacks. | Close-medium | High skill floor, high expression |
| The Tactical Controller | Crowd control: slow, stun, knockback. Dictates pace. | Variable | Support, enabler, tactical |

---

## 7. Mobile Control Layout

**Decision (2026-04-08):** MOBA-style mobile layout. All combat buttons reachable with the right thumb.

**Right side:**
- **Center:** Basic Attack button
- **Clockwise around Basic Attack:** Dash → Skill 1 → Skill 2 → Skill 3
- **Above skill buttons (smaller):** Potion 1 / Potion 2

**Left side:** virtual joystick for movement.

**Aiming:** soft-lock on short press (auto-targets nearest enemy), free-aim on hold.

This mirrors familiar mobile MOBA muscle memory (Mobile Legends, Wild Rift). The Dash button sits first clockwise from Basic Attack — close and accessible without leaving the skill cluster.

The Dash button placement confirms that the movement skill is a first-class combat action deserving its own dedicated button, not embedded inside a skill slot.

---

## 8. Character Design Philosophy

**Decision:** The weapon (basic attack) and the movement skill (dash) define the character. Skills are secondary expression within that identity.

This means:
- Each weapon has a distinct basic attack pattern that communicates its archetype immediately
- The dash behavior is also weapon-specific (a melee storm dash is different from a precision executor dash)
- Skills deepen the kit but the core identity is in basic attack + movement

**Skill system:** The loadout allows selection of 4 skills per weapon from the available pool, creating kit variety within the same weapon+dash foundation. This enables build diversity through skill combination within a single weapon identity.

---

## 9. Phase 3 Scope Pivot (2026-04-08)

Phase 3 objective changed from full game buildout (4 sub-phases: Sensação → Identidade → Profundidade → Robustez) to a focused PvP 1v1 arena for combat validation.

**New Phase 3 objective:** Build a playable 1v1 PvP arena with 2 weapons, real game feel, online play, and cross-platform support.

**What stays from the original plan:**
- All combat feel decisions (rhythm, feedback, camera)
- Visual direction (low-poly 3D stylized, dark and intense)
- Development model (Codex-led implementation, with Claude only as an optional bounded sidecar)
- Weapon archetype diversity as a long-term goal

**What is deferred to future phases:**
- PvE enemies and AI
- Multiple maps / mission variety
- Progression and unlock systems
- Setting, lore, narrative
- Platform-service integration (Steam networking, cloud save, leaderboards, cosmetic ownership)
- Large weapon/skill catalog
- Sound and music (beyond placeholder SFX)

**Networking decision:** Host-authoritative + client-side prediction via Unity Relay. Zero infrastructure cost. Prediction and reconciliation work is directly reusable for dedicated server migration later.

---

## 10. Race Context

Phase 3 introduces the first two weapons, each belonging to a different race from the game's race system:

| Weapon | Race | Race Identity |
| --- | --- | --- |
| Martelo | **Heroic** | Ancient warriors with magical weapons — hammers, bows, swords, spears |
| Rifle de Assalto | **Human** | Military combatants — rifles, snipers, pistols, machine guns; resource: bullets + reload |

These weapons are not designed in isolation — they represent their race's combat philosophy. Future weapons added to the Heroic and Human catalogs should expand on the same identity, not contradict it.

The race framework (ScriptableObject context associating weapons, skills, passives, and potions to a race) should be established in Phase 3 even if populated with placeholder data only.

---

## 11. Crystal Buff System

**Decision (2026-04-08):** Crystal buffs are in scope for Phase 3. Both players compete for the same crystal in the arena.

**Rules:**
- A crystal spawns at a designated location in the arena
- Both players can attack the crystal
- The player who deals the killing blow (last hit) receives the buff
- Crystal types, buff effects, spawn timing, and respawn rules: to be defined during arena implementation

**Design intent:** Creates an objective that breaks defensive play — ignoring the crystal hands the opponent a free buff. Forces engagement.

---

## 12. Weapon Designs

### Weapon 1 — Martelo (Hammer) — Heroic Race

**Identity:** CC and pressure. The Martelo closes distance fast, chains crowd control, and punishes with high-damage combos. Predictable but powerful — opponents must respect every approach.

**Basic Attack — 3-hit combo:**
- Hit 1: Light damage
- Hit 2: Medium damage
- Hit 3: Heavy damage + mini stun (brief, opens combo window)

**Movement Skill — Speed Burst:**
- Hold button: doubles movement speed, consumes a charge (max 5s duration)
- Release button: 2s cooldown before next use
- Colliding with an enemy during the burst: 0.5s mini stun on the enemy (2s cooldown between procs to prevent continuous triggering)
- Identity: aggressive gap-closer that doubles as a CC tool on entry

**Skill 1 — Ground Slam (high cooldown):**
- Player raises the hammer (brief delay — telegraphed)
- Slams into the ground, dealing damage in a cone in front of the character
- Stuns enemy for 2s
- High cooldown
- Identity: the "big punish" — guaranteed damage window after landing

**Skill 2 — Hammer Throw (medium cooldown):**
- Throws the hammer at medium distance: deals damage + slow on impact
- Player loses basic attack while hammer is away
- Cast again to recall the hammer: deals damage + slow again on return
- Hammer auto-returns after 3s if not recalled
- Medium cooldown
- Identity: risk/reward ranged tool — commits the player to vulnerability while creating pressure at range

**Skill 3 — Leap Strike (medium cooldown):**
- Medium-distance leap toward target
- Landing deals damage + slow at the landing zone
- Medium cooldown
- Identity: repositioning, pursuit, and engagement opener from medium range

**Tactical Loop:**
Speed Burst (close gap + mini stun) → Combo 1-2-3 (mini stun on 3rd hit) → Skill 1 (2s stun + burst damage) → Skill 3 (reposition or pursue) → Skill 2 (ranged pressure when at distance, but risk of losing basic attack)

**Balance Notes (to validate in playtest):**
- Three distinct CC sources (burst collision, combo hit 3, Skill 1) — cooldown calibration is critical to avoid full CC lock
- Skill 2 vulnerability window (no basic attack while hammer is away) creates genuine PvP decision making
- Skill 1 telegraph (brief delay) gives opponent a read opportunity — reward for recognizing the animation

---

### Weapon 2 — Rifle de Assalto (Assault Rifle) — Human Race

**Identity:** Tactical combatant. Controls the field with traps and barriers, manages ammo resource, and uses mobility to stay at optimal range. Directly counters the Hammer's aggressive approach.

**Basic Attack — Burst Fire:**
- Fires 3 shots per burst with a small delay between bursts
- Has ammo (30 bullets per magazine)
- When ammo runs out: forced reload (2s reload time)
- Identity: sustained ranged pressure with a vulnerability window when reloading

**Movement Skill — Jump + Roll:**
- Jump followed by a roll
- Short/medium distance, low cooldown
- Identity: quick repositioning and evasion — not aggressive like the Hammer burst, but reactive and precise

**Skill 1 — Impact Grenade (medium cooldown):**
- Throws a grenade to medium distance
- AoE damage + medium stun on impact
- Identity: initiator or punisher at medium range

**Skill 2 — Barricade (medium cooldown):**
- Creates a temporary barrier at a target location
- Lasts 8-10 seconds with HP (can be destroyed by dealing enough damage)
- Both hero AND projectiles cannot pass through it
- Identity: field control, route denial, forces opponent to change approach — also blocks the Hammer's Skill 2 (thrown hammer)

**Skill 3 — Land Mine (medium cooldown):**
- Places an invisible mine on the ground at a target location
- Triggers when the enemy moves near it: explosion damage + small stun
- 1 active mine at a time (placing a new one removes the old one)
- Identity: zone denial, punishes predictable approaches, especially the Hammer's Speed Burst

**Tactical Loop:**
Jump+Roll (reposition) → Barricade (block Hammer approach route) → Land Mine (control chokepoint) → Burst Fire (sustained pressure while opponent navigates terrain) → Grenade (punish when opponent is cornered or bunched)

**Hammer vs Rifle Matchup Dynamics:**
- Hammer Speed Burst → Land Mine punishes predictable entry
- Hammer Skill 2 (thrown hammer) → Barricade blocks projectile → interesting counter-counter interaction
- Rifle Reload window → Hammer's biggest opportunity to close distance
- Rifle at distance → safe; Rifle in melee range → vulnerable (no burst damage efficiency)

**Balance Notes (to validate in playtest):**
- Ammo: 30 bullets, 2s reload. Generous enough for flow, creates occasional vulnerability windows
- Barricade: 8-10s with HP. Strong field control but destroyable — Hammer can invest DPS to remove it
- Mine: 1 active at a time. Forces placement choice; mobile Hammer can avoid by changing approach angle

---

## 13. In-Match Progression System

### Structure

**Pre-match loadout:** Choose weapon + 3 skills from that weapon's pool. This defines the strategic identity and ceiling of the kit.

**In-match levels (7 levels, ~1 minute each, ~7 minute match target):**

| Level | Action |
| --- | --- |
| 1 | Activate first skill (player chooses which of the 3) |
| 2 | Activate second skill (player chooses order) |
| 3 | Activate third skill (player chooses order) |
| 4 | Upgrade one skill to Level 2 (player chooses which) |
| 5 | Upgrade one skill to Level 2 (player chooses which) |
| 6 | Upgrade one skill to Level 2 (player chooses which) |
| 7 | Choose the **Ultimate** upgrade for ONE skill only |

Plus: each level also gives a general stats upgrade (values to be defined — damage, HP, movement speed, or a combination).

### Design Intent

The pre-match choice determines WHAT skills are available. The in-match choice determines ORDER and PRIORITY. This creates tactical adaptation:
- A Rifle player can prioritize Barricade at Level 1 if facing an aggressive Hammer player
- A Hammer player can rush Ground Slam early for big stun windows while the Rifle is still building

### Skill Level Definitions Required

Each skill needs 3 tiers:
- **Level 1 (base):** Activated at Levels 1-3, basic version of the skill
- **Level 2 (upgrade):** Activated at Levels 4-6, meaningful improvement
- **Ultimate:** Available at Level 7, chosen for one skill only — transformative change

---

## 14. Phase 3 Scope Summary

| Element | In Phase 3 | Notes |
| --- | --- | --- |
| Weapons | 2 | Martelo (Heroic race) + Rifle de Assalto (Human race) |
| Skills per weapon | 3 | Each with 3 tiers (base, upgrade, ultimate) |
| In-match progression | Yes | 7 levels, ~7 min match |
| Potions | Yes | 1× Healing + 1× Shield per player |
| Crystal buffs | Yes | Both players compete; last hit rewards buff |
| Race framework | Yes | Scaffold only — Heroic + Human as initial context |
| Passives | No | Deferred to future phases |
| Enemies / AI | No | PvP only, no bots |
| Multiple arenas | No | 1 arena only ("A Forja") |
| Account progression | No | No persistent unlocks in Phase 3 |

---

## 15. Skill Level Definitions

### Martelo — Skill Levels

**Skill 1 — Ground Slam**

| Tier | Description |
| --- | --- |
| Lvl 1 (base) | Raise hammer → brief delay → slam in front cone. Medium damage, 2s stun. Cooldown 8s. |
| Lvl 2 (upgrade) | Larger cone + increased damage. |
| Ultimate | Increased damage + increased stun duration. |

**Skill 2 — Hammer Throw**

| Tier | Description |
| --- | --- |
| Lvl 1 (base) | Throw hammer to medium distance: damage + slow on throw. Damage + slow on return (both manual recall AND auto-return after 3s). No basic attack while hammer is away. Medium cooldown. |
| Lvl 2 (upgrade) | Increased damage + increased slow duration. |
| Ultimate | Increased damage + stun on return (instead of slow). |

**Skill 3 — Leap Strike**

| Tier | Description |
| --- | --- |
| Lvl 1 (base) | Medium-distance leap. Damage + slow at landing zone. Medium cooldown. |
| Lvl 2 (upgrade) | Cooldown reduced. |
| Ultimate | Stun instead of slow at landing. Creates a lingering energy field at the landing zone (3s) that deals continuous light damage to anyone standing in it. |

---

### Rifle de Assalto — Skill Levels

**Skill 1 — Granada de Impacto**

| Tier | Description |
| --- | --- |
| Lvl 1 (base) | Throw grenade to medium distance. AoE damage + medium stun on impact. Medium cooldown. |
| Lvl 2 (upgrade) | Larger explosion radius + increased damage. |
| Ultimate | Double explosion: first wave deals damage + stun, second wave (0.5s later) deals additional damage + strong knockback. |

**Skill 2 — Barricada**

| Tier | Description |
| --- | --- |
| Lvl 1 (base) | Create a temporary barrier with HP. Lasts 8-10s. Blocks both heroes and projectiles. Medium-high cooldown. |
| Lvl 2 (upgrade) | Increased HP + increased duration. |
| Ultimate | The barricade has a mounted machine gun that automatically attacks anyone who comes close to it. |

**Skill 3 — Mina Terrestre**

| Tier | Description |
| --- | --- |
| Lvl 1 (base) | Place 1 invisible mine. Triggers on proximity: damage + small stun. Mine is consumed after triggering. Medium cooldown. |
| Lvl 2 (upgrade) | Increased damage + larger trigger radius. |
| Ultimate | Can have 2 active mines simultaneously. On trigger: creates a heavy slow zone for 3s (in addition to the initial stun), turning the blast zone into a control area. |

---

## 16. Stats Per Level

**Model:** Fixed stats, automatic, applied every level.

| Stat | Per Level | At Max (Lvl 7) |
| --- | --- | --- |
| Damage | +10% | +70% over baseline |
| Max HP | +6% | +42% over baseline |

Values are starting baselines — to be tuned during Phase 3A playtest.

---

## 17. Potions

Each player starts the arena match with:

| Potion | Charges | Effect |
| --- | --- | --- |
| Healing Potion | 1 | Instantly restores a percentage of max HP. Cast animation is visible to the opponent (creates a punishable window). |
| Shield Potion | 1 | Absorbs the next incoming hit (or a fixed amount of damage) for a few seconds. Defensive and predictive — rewards reading the opponent's next move. |

HP restore amount and shield absorption value: to be defined during playtest calibration.

---

## 18. Arena Layout — "A Forja"

Historical note: the layout below documents the original Phase 3 Arena baseline only. Active canon for current work was superseded in Phase 7 Stage 05 by the remodeled `A Forja` direction in `docs/game-design-document.md` and `implementation/phase-7/stage-specs/stage-05-arena-reformulation.md`.

**Format:** Rectangular arena (~30×20 units). Two opposing spawn points (top-left and bottom-right corners), so the direct path between players cuts through the center.

**Zone Structure:**

| Zone | Location | Character | Favors |
| --- | --- | --- | --- |
| Open Zone | Right half | 2-3 low pillars, long sight lines | Rifle |
| Closed Zone | Left half | More obstacles, narrow passages, short sight lines | Martelo |
| Center | Middle | Large indestructible structure blocking direct spawn-to-spawn line of sight | Neutral — forces both players to move before engaging |

**Obstacles:**
- Indestructible pillars and walls defining zone character (fixed throughout the match)
- 2 destructible objects — one per zone half — positioned at tactical points. When destroyed, they open a previously blocked sight line or route. Changes the map as the match progresses.

**Design Intent:**
- Neither player has line of sight at match start — both must move to engage
- The Rifle wants to operate from the Open Zone or use the Barricade to make the Closed Zone safe
- The Martelo wants to force the fight in the Closed Zone using the Speed Burst to close distance through narrow passages
- Destructible objects reward aggressive play (destroying them opens routes) but change the map for both players

**Final geometry details:** To be refined during implementation. The concept is fixed; exact dimensions and obstacle placement are adjusted in the Unity scene.

---

## 19. Design Discovery — Complete (Session 1)

All decisions required for Phase 3 execution are now defined. Summary:

| Topic | Status | Key Decision |
| --- | --- | --- |
| Combat rhythm | ✅ | Reading + explosion, sustained combo |
| Weapon swap | ❌ REMOVED | Removed in Phase 5 Consolidation — single weapon loadout only |
| Visual feedback | ✅ | High and exuberant; hitstop to test at 0/3/6 frames |
| Camera | ✅ | Pitch ~52-55°, arena highlighted, character small |
| Visual direction | ✅ | Low-poly 3D stylized, dark and intense |
| Race context | ✅ | Martelo = Heroic race; Rifle = Human race; race framework scaffold in Phase 3 |
| Weapon 1 — Martelo | ✅ | 3-hit combo + speed burst; Slam, Throw, Leap with 3 tiers each |
| Weapon 2 — Rifle de Assalto | ✅ | Burst fire + ammo; jump+roll; Grenade, Barricade, Mine with 3 tiers each |
| In-match progression | ✅ | 7 levels ~7 min; unlock→upgrade→ultimate order chosen in-match |
| Stats per level | ✅ | +10% Basic Attack Damage and Spell Damage, +6% HP per level (tunable) |
| Potions | ✅ | 1× Healing + 1× Shield per player |
| Crystal buffs | ✅ | Both players compete; last hit on crystal rewards a buff; in scope for Phase 3 |
| Arena | ✅ | "A Forja" original Phase 3 baseline — open zone + closed zone + center blocker + 2 destructibles (superseded for active work by Phase 7 Stage 05) |
| Base combat stats | ✅ | HP 1000, Movement 5 u/s, damage values defined per weapon — see Section 20 |
| Character attribute system | ✅ | 3 categories: Universal, Conditional, Race/Weapon Based — see Section 21 |
| Passives — Phase 3 | ❌ REMOVED | Passive system removed in Phase 5 Consolidation — see Section 22 |
| Crystal buff types | ✅ | 5 buffs active (Fúria, Poder Arcano, Golpe Certeiro, Aceleração, Velocidade de Ataque); reflect 30% direct + 8% AoE; 1/min — see Section 23 |
| Loadout Flow UX | 🔄 UPDATED | Revised in Phase 5 Consolidation: 4 spells, no passives. See Section 24 (legacy) and Phase 5 HUD spec for current design. |
| Setting/lore | 🔜 | Deferred — magitech, atmospheric narrative |

---

## 20. Base Combat Stats — Phase 3

Starting values for all tunable parameters. All values are baselines for playtest — adjust after Phase 3 Stage 5 iteration.

### Player

| Stat | Value |
| --- | --- |
| Max HP | 1000 |
| Movement Speed | 5 u/s |
| HP Regen (in combat) | 0 HP/s |
| HP Regen (out of combat) | 5 HP/s (after 5s without taking damage) |

### Martelo — Basic Attack (3-hit combo)

| Hit | Damage | Timing |
| --- | --- | --- |
| Hit 1 (light) | 25 | 0.3s |
| Hit 2 (medium) | 38 | 0.4s |
| Hit 3 (heavy + mini stun) | 57 | 0.5s |
| **Full combo total** | **120** | **~1.2s** |

Movement Speed during Speed Burst: **10 u/s** (2× base).

### Rifle de Assalto — Basic Attack (burst fire)

| Parameter | Value |
| --- | --- |
| Damage per shot | 22 |
| Shots per burst | 3 → **66 damage per burst** |
| Interval between bursts | 0.5s |
| Magazine | 30 bullets = 10 bursts |
| Full magazine damage | 660 |
| Time to empty magazine | ~5s sustained fire |
| Forced reload time | 2s |
| Full cycle (fire + reload) | ~7s → ~94 damage/s sustained |

### Skills — Base Damage (Level 1)

| Skill | Base Damage | Notes |
| --- | --- | --- |
| Ground Slam | 160 | Cone, 2s stun |
| Hammer Throw (throw) | 90 | + slow on hit |
| Hammer Throw (return) | 90 | + slow; total 180 if manually recalled |
| Leap Strike | 100 | + slow at landing zone |
| Granada de Impacto | 150 | AoE, medium stun |
| Barricada | 0 | Field control — no direct damage |
| Mina Terrestre | 130 | + small stun on trigger |

All skill damage scales with Spell Damage multiplier (affected by in-match level-up bonus).

### Skill Cooldowns (Level 1)

| Skill | Cooldown |
| --- | --- |
| Ground Slam | 8s |
| Hammer Throw | 6s |
| Leap Strike | 5s |
| Granada de Impacto | 5s |
| Barricada | 8s |
| Mina Terrestre | 6s |

---

## 21. Character Attribute System

### Design Principles

- One damage type only (no physical/magical split)
- Two damage sources: **Basic Attack Damage** and **Spell Damage** — tracked and scaled separately
- Damage formula: `Final Damage = max(0, Raw Damage − Bloqueio de Dano) × (1 − Resistência a Dano%)`
- Block applies first (flat reduction), Resistance applies after (percentage reduction)
- Level-up bonus (+10% per level) applies to both Basic Attack Damage and Spell Damage equally

### Category 1 — Universal Attributes

All characters have these from match start.

| Attribute | Base Value | Unit | Notes |
| --- | --- | --- | --- |
| Max HP | 1000 | points | +6% per in-match level |
| HP Regen (in combat) | 0 | HP/s | Zero while taking damage |
| HP Regen (out of combat) | 5 | HP/s | Activates after 5s without taking damage |
| Basic Attack Damage | 1.0× | multiplier | +10% per in-match level |
| Spell Damage | 1.0× | multiplier | +10% per in-match level |
| Attack Speed | 1.0× | multiplier | Affects combo cadence and burst rate |
| Movement Speed | 5 | u/s | |
| Bloqueio de Dano | 0 | flat points | Subtracted from raw damage before resistance |
| Resistência a Dano | 0% | percentage | Applied after damage block |
| Resistência a Efeitos | 0% | percentage | Reduces duration of all negative effects (CC, slow, etc.) |

### Category 2 — Conditional Attributes

Base 0 for all characters. Granted only by passives, skills, potions, or Crystal Buffs.

| Attribute | Base | Notes |
| --- | --- | --- |
| Shield | 0 | Absorbs damage before HP; blocks effects like lifesteal |
| Lifesteal | 0% | Applies to Basic Attack Damage; blocked by target's active Shield |
| Critical Chance | 0% | Applies to both Basic Attack and Spell damage |
| Critical Damage | 175% | Fixed multiplier when a critical hit occurs |
| CDR (Cooldown Reduction) | 0% | Cap: 40% maximum |
| AoE Size | 1.0× | Scales area of effect of skills |

### Category 3 — Race/Weapon Based Attributes

Specific to the equipped weapon. Modifiable by passives and skill upgrades.

| Attribute | Weapon | Base Value | Notes |
| --- | --- | --- | --- |
| Reload Speed | Rifle de Assalto | 1.0× (2s) | Tactical Reload raises to 1.67× (2s → 1.2s) |
| Magazine Size | Rifle de Assalto | 30 bullets | |
| Projectile Speed | Rifle de Assalto | weapon default | Affects effective range of shots |
| Speed Burst Duration | Martelo | 5s max | Maximum duration with burst active |
| Combo Window | Martelo | per animation | Time window to chain the next combo hit |

---

## 22. Passive Designs — REMOVED (Phase 5 Consolidation, 2026-04-12)

**The passive system has been removed from the game design.**

The loadout no longer includes passive slots. The 6 passives designed in this section (Momentum, Iron Will, Heavy Blow for Heroic; Tactical Reload, Precision, Field Kit for Human) are archived here for reference but are not active in any current or future phase.

**Why removed:** Passives added complexity to the loadout screen and code architecture without contributing to the core combat identity. The decision to go with a cleaner structure (Race → 1 weapon + movability → 4 spells → 2 potions) eliminates this layer entirely.

**Code impact:** Any `PassiveSystem`, passive slot in loadout, or passive ScriptableObject referenced in Phase 3 code must be removed in Phase 5 Stage 2 (Code Update).

*The 6 passive values below are preserved for historical reference only — they have no active use.*

| Passive | Race | Effect (archived) |
| --- | --- | --- |
| Momentum | Heroic | +25% Movement Speed for 3s after Speed Burst ends |
| Iron Will | Heroic | +15% Max HP |
| Heavy Blow | Heroic | +30% damage to stunned targets |
| Tactical Reload | Human | Reload time: 2s → 1.2s |
| Precision | Human | First shot of each burst: +40% damage |
| Field Kit | Human | Out-of-combat regen: 5 HP/s → 15 HP/s |

---

## 23. Crystal Buff Types — Phase 3

### Crystal Mechanics

| Parameter | Value |
| --- | --- |
| Crystal HP | 600 |
| Reflect — direct to attacker | 30% of damage dealt |
| Reflect — AoE around crystal | 8% of damage dealt (radius ~2 units; does not affect the direct attacker) |
| Reflect stacking | Does not stack — single active reflect instance regardless of how many players attack |
| Spawn timing | 1 crystal per minute, starting at minute 1 |
| Spawn position | Central neutral zone of the arena |
| Respawn | Next crystal spawns 60s after the previous one is destroyed |
| Last-hit rule | The player who deals the killing blow receives the buff |
| Buff duration | Permanent until end of match |

**Reflect cost reference (killing a 600 HP crystal with basic attacks only):**
- Rifle de Assalto: ~9 bursts × 30% of 66 = ~178 HP taken in reflect (~17.8% of base HP)
- Martelo: ~5 full combos × 30% of 120 = ~180 HP taken in reflect (~18% of base HP)

Contesting a crystal is a real commitment. A player at low HP risks dying to reflect before landing the last hit.

---

### Phase 3 Active Buff Pool

5 buffs in the active pool for Phase 3. Each crystal spawn selects randomly from this pool. The same buff type can appear multiple times across a match — stacking is intentional.

---

**Fúria**
*+8% Basic Attack Damage (permanent)*

| Stacks | Basic Attack Bonus | Martelo combo total | Rifle burst total |
| --- | --- | --- | --- |
| 1 | +8% | 120 → 130 | 66 → 71 |
| 3 | +24% | 120 → 149 | 66 → 82 |
| 5 | +40% | 120 → 168 | 66 → 92 |

Rewards sustained basic attack pressure. Scales well with Martelo's combo rhythm and Rifle's sustained fire.

---

**Poder Arcano**
*+8% Spell Damage (permanent)*

| Stacks | Spell Bonus | Ground Slam (160) | Granada (150) |
| --- | --- | --- | --- |
| 1 | +8% | 160 → 173 | 150 → 162 |
| 3 | +24% | 160 → 198 | 150 → 186 |
| 5 | +40% | 160 → 224 | 150 → 210 |

Rewards correct skill rotation. Higher value for players who land skill combos consistently.

---

**Golpe Certeiro**
*+4% Critical Chance (permanent)*

| Stacks | Crit Chance | Expected extra damage per 10 hits |
| --- | --- | --- |
| 1 | 4% | ~3% average damage increase |
| 3 | 12% | ~9% average damage increase |
| 5 | 20% | ~15% average damage increase |
| 7 | 28% | ~21% average damage increase |

Base Critical Chance is 0% — every stack is a real gain. Crit Damage multiplier: 175%. Applies to both Basic Attack and Spell hits. Becomes a genuine threat at 4+ stacks.

---

**Aceleração**
*+0.4 u/s Movement Speed (permanent)*

| Stacks | Movement Speed | vs base (5 u/s) |
| --- | --- | --- |
| 1 | 5.4 u/s | +8% |
| 3 | 6.2 u/s | +24% |
| 5 | 7.0 u/s | +40% |

Affects both combat and crystal contest positioning. At 3+ stacks, the difference in footspeed is perceptible and affects chase/kite dynamics directly.

---

**Velocidade de Ataque**
*+6% Attack Speed (permanent)*

| Stacks | Attack Speed | Effect |
| --- | --- | --- |
| 1 | 1.06× | Barely perceptible |
| 3 | 1.18× | Combo window slightly faster; burst cadence tightened |
| 5 | 1.30× | Meaningful DPS increase through cadence alone |

Subtle at low stacks, impactful at high stacks. Synergizes directly with Fúria (more attacks per second + more damage per attack).

---

### Deferred Buff Pool (future phases)

The following buff types are designed but not in scope for Phase 3. They will be added to the pool in a future phase as the combat system matures.

| Buff | Effect | Category |
| --- | --- | --- |
| Vigor | +80 Max HP | Defensive |
| Armadura de Batalha | +15 Bloqueio de Dano | Defensive |
| Tenacidade | +10% Resistência a Efeitos | Defensive |
| Vampirismo | +4% Lifesteal (Basic Attack) | Special |
| Escudo Persistente | +100 Shield (recharges on next crystal kill) | Special |

---

### Design Intent

Crystal Buffs are the only snowball mechanic in the 1v1 arena. A player who wins more crystals gains compounding advantages — but never a single decisive one. A player down 3 crystals is at a disadvantage, not out of the fight.

The reflect mechanic ensures that the crystal is never a free objective. Contesting it while trading blows with the opponent requires health management and timing. The player who creates space to contest crystals safely is rewarded beyond just the buff — they've also forced the opponent into a reactive position.

---

## 24. Loadout Flow UX

### Revised Flow (5 screens total)

```
Mode Select  →  Sub-mode + Format  →  Loadout Screen  →  Room  →  Pre-match Lobby  →  Match
  (Screen 1)       (Screen 2)           (Screen 3)      (Screen 4)    (Screen 5)
```

---

### Screen 1 — Mode Selection

- 3 large cards: Versus (active), Solo (locked), Coop (locked)
- Locked cards show padlock icon and greyed overlay
- Tap Versus → Screen 2
- No Back button (entry point); Home button returns to main menu

---

### Screen 2 — Sub-mode + Format (unified)

Two sections on a single screen:

**Top section — Mode:**
Horizontal cards: Arena (active), MOBA (locked). Tap to select.

**Bottom section — Format:**
Horizontal cards: 1v1 (active), 2v2 (locked). Visible from the start; requires mode selection before becoming interactive.

Confirm button at the bottom → Loadout Screen.

---

### Screen 3 — Loadout Screen

Single scrollable screen containing all kit decisions. A fixed summary strip at the top and a fixed Confirm button at the bottom persist through the scroll.

**Layout (updated — Phase 5 Consolidation):**
```
┌──────────────────────────────┐  ← fixed (does not scroll)
│ ← [Race][Wpn][①②③④][💊🛡️]  │  loadout summary strip
├──────────────────────────────┤
│  RACE panel                  │
│  WEAPON panel                │
│  SKILLS panel (pick 4)       │  ← scrollable panels
│  POTIONS panel               │
├──────────────────────────────┤  ← fixed (does not scroll)
│   [CONFIRM — 2/4 skills ▸]  │
└──────────────────────────────┘
```

*Passives panel removed. Skills counter updated to 4/4.*

**Summary strip (fixed top):**
Horizontal icon row: `[Race] → [Weapon] → [Skill 1][Skill 2][Skill 3][Skill 4] → [Potion 1][Potion 2]`

*Note: Passives removed in Phase 5 Consolidation. Layout updated to 4 spell slots, no passive slots.*
- Empty slots show as grey circles
- Filled as player selects
- Tapping any filled icon scrolls to the corresponding panel

**Scroll behavior:**
- Completed panels compress to a summary chip as the player scrolls down
- On completing a panel, the screen auto-scrolls smoothly to the next incomplete panel
- Player can interrupt the auto-scroll at any time without losing state

---

#### Race Panel

Horizontal scroll of race cards (~120×160px each).

Each card shows: race art, name, tagline ("Ancient warriors" / "Military combatants"). Locked future races show dark overlay + padlock.

- **Tap:** selects race — colored border appears
- **Hold (500ms):** opens race detail modal (full identity, available weapons, skill preview). Dismiss by tapping outside or "X"
- **Changing race:** sweep animation clears skill slots; toast appears for 2s: *"Loadout reset for new race"*; weapon panel updates to new race pool

---

#### Weapon Panel

Horizontal scroll of weapon cards. Phase 3: 1 weapon per race (auto-selected on race pick).

Each card shows: weapon art, name, Basic Attack tag, Movement Skill tag.

- **Tap on selected card:** opens weapon detail modal (full Basic Attack and Movement Skill description). Dismiss by tapping outside
- **Future (multiple weapons per race):** tap selects weapon; weapon change resets skill slots

---

#### Skills Panel

4 cards from the weapon/race pool. Counter: **"0/4"** in panel header.

Each card (~100×120px): skill icon, name, brief description (5–8 words), ⓘ button in top-right corner.

- **Tap card:** selects skill — highlighted border + numbered order badge (①②③④). Tap again to deselect
- **Tap ⓘ:** opens skill detail modal (bottom sheet slide-up):

```
┌──────────────────────────────┐
│  Skill Name              [X] │
├──────────────────────────────┤
│  Lvl 1  ─────────────────── │
│  Description + values        │
│  Cooldown: Xs                │
├──────────────────────────────┤
│  Lvl 2  ─────────────────── │
│  Improvement description     │
├──────────────────────────────┤
│  ✦ Ultimate ──────────────── │
│  Transformative description  │
├──────────────────────────────┤
│         [SELECT SKILL]       │
└──────────────────────────────┘
```

"Select Skill" button inside modal also selects and closes the modal. Counter turns green at ✓ 4/4.

---

#### Potions Panel (informational)

2 fixed cards — Healing Potion and Shield Potion. Visually distinct (softer border, no selectable state).
Shows: name, effect, charge count (1×). Tap opens a brief tooltip with full description. No selection required.

---

### Confirm Button (fixed bottom)

| State | Visual | Label |
| --- | --- | --- |
| Race not selected | Disabled grey | "Select a race" |
| Skills incomplete | Disabled grey | "Select 4 skills (X/4)" |
| Loadout complete | Race accent color, soft pulse | "CONFIRM  ▶" |

Tapping a disabled Confirm: button shake animation + the topmost incomplete panel flashes briefly with a red outline to guide the player's attention.

---

### Screen 4 — Room Screen

**Two options: Create Room / Join Room**

**Create Room flow:**
- Generates a 6-digit code displayed prominently
- Waiting state: "Waiting for opponent…" with loading indicator
- Cancel returns to Loadout Screen

**Join Room flow:**
- 6-digit input field
- Join button disabled until all 6 digits entered
- Error on invalid code: "Room not found. Check the code and try again."
- Cancel returns to Loadout Screen

When both players are in the room → automatic transition to Pre-match Lobby.

---

### Screen 5 — Pre-match Lobby

- Left side: local player's full loadout (Race, Weapon, Skills, Potions)
- Right side: opponent's full loadout (fully visible — no hidden information in Phase 3)
- Ready button per player
- Opponent state: "Waiting…" → "Ready ✓" when confirmed
- When both Ready: countdown 3… 2… 1… → arena transition
- Disconnect during lobby: "Opponent disconnected." message + button to return to Room Screen
- Back is disabled once inside the lobby — loadout is locked

---

### Navigation Rules

| Situation | Behavior |
| --- | --- |
| Back on any loadout panel | Preserves all selections made so far |
| Changing race | Resets weapon and skills; toast notification |
| Changing weapon (future) | Resets skills only |
| Confirm while incomplete | Shake animation + incomplete panel flashes |
| Disconnect in lobby | Returns to Room Screen with error message |
| Both races equal (Heroic vs Heroic) | Allowed |

---

## Status

Session date: 2026-04-08 (updated)
Status: **Design discovery complete — Frente 1 closed.** All pending design decisions for Phase 3 execution are now recorded.

| Topic | Status |
| --- | --- |
| Base combat stats | ✅ |
| Character attribute system | ✅ |
| Passives with values (6 total) | ❌ REMOVED — see Section 22 |
| Crystal Buff types and mechanics | ✅ |
| Loadout Flow UX (5 screens + mobile detail) | 🔄 UPDATED — 4 spells, no passives |

Next step: Author Stage 2 stage-spec (`implementation/phase-3/stage-specs/stage-02-combat-redesign-and-game-feel.md`) and execution scripts, then resume Codex execution from Stage 1.
