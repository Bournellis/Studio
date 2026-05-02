# Enemy Design Discovery

> Historical discovery note. This file preserves legacy enemy, boss, and PvE exploration from older phase planning. It is not the current implementation plan. For current authority, read `D:\Estudio\canon\design\game-design-document.md`, `D:\Estudio\canon\design\progression-design.md`, and `D:\Estudio\Projetos\rpg-isometrico\implementation\current-status.md` first. Shared canon and current operational status win over anything in this file.

## Purpose of This Document

This document records design decisions for the enemy systems, boss encounters, and PvE modes of the game. It is the design reference for Phase 4 (Enemy AI + Survival Mode) and Phase 6 (Boss Mode) execution.

It covers:
- Enemy AI architecture and behavior framework
- Enemy archetypes and categories
- Boss Troll — full boss design
- Survival Mode — "Onda de Trolls" design

For game mode rules and production order, see `docs/game-design-document.md`.
For the macro phase plan, see `docs/evolution-roadmap.md`.

---

## 1. Enemy AI Architecture

### Design Principle

Enemy AI in this game is not about creating intelligent opponents — it is about creating **readable threats**. Every enemy must communicate its intent through animation and behavior clearly enough that the player can react, adapt, and feel skilled for surviving.

The combat philosophy of the game is "reading + explosion." Enemies must create situations that reward reading. An enemy whose attacks cannot be anticipated creates frustration. An enemy whose attacks are always obvious creates boredom. The goal is telegraphed but dangerous.

### Behavior State Machine

All enemies share a common state machine framework. Specific enemies implement this framework differently.

```
[Idle / Patrol]
     ↓ (player in detection range)
[Aggro — target acquired]
     ↓
[Navigate toward player]
     ↓ (in attack range)
[Attack — select behavior]
     ↓ (after attack)
[Recovery — return to navigate or select next attack]
     ↓ (player dead or out of range)
[Return to Idle]

[At any point] → [Stunned] → [Resume previous state]
[At any point] → [Dead] → [Death sequence + loot/drop]
```

### Enemy Categories

| Category | Role | HP | Attack Count | Regeneration | Examples |
| --- | --- | --- | --- | --- | --- |
| Fodder | Wave pressure — die in 2-4 hits | Low | 1 | No | Troll Grunt |
| Elite | Tactical threat — requires attention | Medium-High | 2 | No | Troll Warrior |
| Boss | Central encounter — the entire challenge | Very High | 3+ with phases | Yes (Boss Troll) | Boss Troll |

### AI Behavior Principles per Category

**Fodder:** Simple state machine. Navigate toward player, execute single attack when in range, short recovery, attack again. Low HP ensures the player can clear them without excessive focus. Danger comes from quantity, not individual complexity.

**Elite:** Two distinct attacks. Will alternate based on distance or health state. May have a single telegraphed heavy attack that requires evasion. Not a threat alone — dangerous when combined with fodder or other elites.

**Boss:** Full phase system. Attack selection based on player distance, HP thresholds, and internal timers. Regeneration as baseline pressure mechanic. Each phase changes attack priority and frequency. See Section 2 for Boss Troll full design.

### Animation Events and Gameplay Sync

Enemy attacks are driven by animation events — the same system used for player weapons. Key frames:

| Event | Description |
| --- | --- |
| `AttackWindup` | Visual telegraph begins — player has this window to react |
| `AttackActive` | Hitbox active — damage window |
| `AttackRecovery` | Attack ends — enemy vulnerable window |
| `StaggerBegin` / `StaggerEnd` | Enemy staggers from player damage (if applicable) |
| `PhaseTransition` | Boss-only — signals phase change, may trigger invulnerability window and animation |

The duration of `AttackWindup` is the most important design parameter for readability. Too short and the player cannot react. Too long and the attack becomes trivially avoidable.

### Regeneration System

Regeneration is a boss-exclusive mechanic. It is implemented as a passive heal-per-second that runs continuously unless explicitly disabled by a phase state or a player mechanic.

Implementation: `RegenerationRate` (HP/s) defined per boss ScriptableObject. Applied every tick in the boss's `Update` if the boss is alive and the phase allows it.

Regeneration design intent: it creates a **sustained damage requirement**. A player who plays too defensively — dodging everything but dealing minimal damage — will find the boss slowly recovering toward full HP. This punishes passive play and rewards aggressive, skilled offense.

---

## 2. Boss Troll — Full Design

### Overview

**Name:** O Troll (The Troll)
**Race / World:** Ancient creature — precedes the organized races. Lives in the deep ruins beneath Heroic territory.
**Visual identity:** Enormous, primitive, brutally physical. Stone-gray skin, mossy overgrowth on shoulders and back. No weapons — uses bare hands and the earth itself. Must read clearly at isometric distance — large silhouette, hunched posture, distinctive when compared to humanoid player characters.
**Boss Mode target duration:** 3–5 minutes

### Core Design Philosophy

The Troll has three distinct attack identities:

- **One attack the player can always see coming** — rewards patience and positioning
- **One attack the player must stay mobile to avoid** — punishes stationary play
- **One attack that punishes the player for being careless** — the comeback mechanic

Combined with constant HP regeneration, this creates a rhythm: the player must stay aggressive to overcome regen, but must stay mobile to avoid the zone attack, and must respect the stun attack to not lose their entire advantage window. All three tensions coexist throughout the fight.

---

### Stats (Baseline — to be tuned during Phase 6 playtesting)

| Stat | Value | Notes |
| --- | --- | --- |
| Max HP | 8000 | Much higher than PvP characters — sustained fight |
| HP Regeneration | 15 HP/s (Phase 1), 25 HP/s (Phase 2), 0 (Phase 3) | Regen stops in final phase |
| Movement Speed | 2.5 u/s | Slow — compensated by reach and attack range |
| Damage Resistência | 10% | Light mitigation baseline |

---

### Attacks

#### Attack 1 — Grande Martelada (The Predictable Heavy)

**Identity:** The Troll rears back, raising both fists high above its head. A long, unmistakable windup. Then brings both fists down in a concentrated slam. Devastating damage if it connects — but the windup is the longest telegraph of any boss attack in the game.

| Parameter | Value |
| --- | --- |
| Windup duration | 1.4s |
| Active hitbox | 0.2s |
| Recovery (vulnerable window) | 1.0s |
| Damage | 350 (approx 35% of player base HP) |
| Hitbox shape | Narrow cone directly in front of the Troll |
| Range | 3 units forward |

**Player read:** The animation is unmistakable. Dodge sideways or backward during the windup. The long recovery window is the primary moment to deal heavy damage — this is the "explosion" in the reading + explosion rhythm.

**Weapon interaction:**
- *Martelo:* Speed Burst sideways to dodge, then immediately punish the recovery window with the 3-hit combo + Ground Slam if available
- *Rifle:* Jump+Roll backward or sideways, then burst fire during the full recovery window

---

#### Attack 2 — Tremor Rastejante (The Zone Attack)

**Identity:** The Troll slams one fist into the ground. Cracks spread outward from the impact point in an expanding ring pattern — each crack is a damage zone that persists for 2-3 seconds. The player standing still will take continuous tick damage. The crack pattern is procedurally seeded (not perfectly predictable per cast), making this the "less predictable" attack.

| Parameter | Value |
| --- | --- |
| Windup duration | 0.6s (shorter — less obvious than Attack 1) |
| Active zone duration | 2.5s |
| Tick damage | 40 HP/s (while standing in zone) |
| Hitbox shape | Expanding ring cracks, 6–8 units radius |
| Total potential damage (full exposure) | ~100 HP over 2.5s |

**Player read:** The windup is shorter and the cracks spread dynamically — the player cannot stand still and wait. They must continuously reposition to stay out of the cracks. This attack rewards spatial awareness over reaction time.

**Weapon interaction:**
- *Martelo:* Speed Burst is excellent for escaping the expanding cracks quickly. However, using Speed Burst here means it's not available for closing gap on Attack 1 punishes — resource tension
- *Rifle:* Jump+Roll allows quick micro-repositioning. From outside the zone, the player can continue burst fire without interrupting their DPS

---

#### Attack 3 — Rugido Atordoante (The Stun Attack)

**Identity:** The Troll lets out a massive roar, shockwave expanding in all directions around it. Any player within range is stunned for 2 seconds. The Troll then immediately follows with a single medium-damage blow while the player cannot act.

| Parameter | Value |
| --- | --- |
| Windup duration | 0.5s |
| Roar shockwave radius | 5 units (centered on Troll) |
| Stun duration on hit | 2.0s |
| Follow-up strike damage | 200 HP |
| Total combined damage (if caught fully) | ~200 HP + follow-up |
| Cooldown | 15s |

**Player read:** The windup is the shortest of the three — 0.5s. The key indicator is the Troll lowering its head and opening its mouth before the roar. The player must be at >5 units distance when the roar releases. This attack punishes players who stay too close for too long. Getting caught in the stun while already low HP is effectively a death sentence.

**Weapon interaction:**
- *Martelo:* The Speed Burst collision stun only works when the player is moving toward the Troll — this attack punishes exactly that approach. Players must learn to toggle off Speed Burst before closing to avoid triggering a roar response
- *Rifle:* Jump+Roll out of radius is possible if the player reacts in time. The Rifle's natural operating distance (medium-range) makes this attack less threatening if the player maintains discipline about staying at distance

---

### Phase System

#### Phase 1 — The Troll Awakes (100% → 65% HP)

The Troll moves and attacks at baseline speed. All three attacks available. HP regeneration active at 15 HP/s.

Attack priority:
1. **Tremor Rastejante** — preferred at medium range (4–8 units)
2. **Grande Martelada** — preferred when player is close (0–3 units)
3. **Rugido Atordoante** — triggered if player has been within 3 units for more than 3 consecutive seconds (punishes camping melee)

Player goal: Learn the attack patterns. Overcome the 15 HP/s regen by dealing >15 HP/s average damage across the phase.

---

#### Phase 2 — Blood and Fury (65% → 30% HP)

Triggered at 65% HP. A brief phase transition animation (the Troll roars, slams both fists on the ground — 2s invulnerability window during transition). Then:

- Regen increases to 25 HP/s — the pressure increases significantly
- Movement speed increases to 3.5 u/s
- **Tremor Rastejante** crack count increases (8–10 cracks instead of 6–8)
- **Rugido Atordoante** radius increases to 6 units

Player goal: Increase DPS to overcome 25 HP/s regen. The fight becomes more physically demanding — more repositioning required for Attack 2, larger danger zone for Attack 3.

---

#### Phase 3 — The Last Stand (30% → 0%)

Triggered at 30% HP. Phase transition: the Troll's regeneration is exhausted. It stops regenerating entirely and enters a desperate, erratic phase.

- **Regen: 0** — the end is reachable, but the Troll is most dangerous here
- Movement speed: 4.5 u/s
- Attack cooldowns reduced by 30%
- **Grande Martelada** now has a shorter windup (1.1s instead of 1.4s) — the most forgiving attack becomes less forgiving
- **Rugido Atordoante** cooldown reduced to 10s

Design intent: The last 30% is the most dangerous stretch. The player has invested 3–4 minutes into the fight and is likely managing HP carefully. The Troll fights back hardest when closest to death. This creates a memorable ending — the final 30% should feel like a genuine test.

---

### Boss Room Design Notes — FINALIZED 2026-04-15

The Boss Troll room should reinforce the fight's mechanics:

- **Open center space** — enough room for the player to reposition freely during Tremor Rastejante
- **No pillars blocking vision** — the Troll's telegraphs must be visible from any angle the player might be standing
- **Dark atmosphere with accent lighting** — the Troll should be clearly silhouetted against the floor, especially during Phase 3
- **Stone rubble on edges** — decorative debris (unreachable), reinforces the "ancient ruin" setting

**Shape:** Circular arena. Reinforces 360° awareness and the radial pattern of Tremor Rastejante. No corners to corner-camp.

**Entry:** Single door — closes behind the player on entry. No exit until the boss is dead. Creates maximum tension. The door close is a non-return trigger.

**Boss activation:** The Troll starts dormant (crouched/still at the center). When the player crosses the aggro radius, the Troll performs a wake-up animation (stands up + roar) before the first attack. This gives the player ~1–2 seconds to position.

**Props:** Four torches mounted on the circular wall, one per quadrant. Visual accent lighting only — not interactive, not destructible. Their purpose is silhouette contrast: the Troll reads clearly against the lit floor. No interactive or destructible props in the arena.

---

### Visual Direction

| Element | Notes |
| --- | --- |
| Scale | 2.5–3× player character height |
| Silhouette | Hunched, wide shoulders, thick legs — unmistakably non-human at isometric distance |
| Hit reaction | Full-body flinch on heavy player hits — communicates player effectiveness |
| Phase 2 transition | Redness to eyes, cracked earth at feet, brief ground slam |
| Phase 3 transition | Blood/wounds visible (if stylized art allows), dramatically faster movement |
| Death | Slow collapse, ground crack, stone-break particle effect |

---

### Boss Mode — Results Screen — FINALIZED 2026-04-15

Displayed after the Troll is defeated (or after player death).

**Primary metric:** Clear time (MM:SS). This is the Steam Leaderboard submission value. Drives speedrun replayability.

**Secondary metric:** Damage taken (total HP lost during the fight). Indicator of defensive efficiency.

**Layout (simple):**
- Large clear time display (center/top)
- Damage taken below it
- Two buttons at the bottom: **Jogar Novamente** | **Menu Principal**

**Leaderboard field:** Reserve a "Leaderboard Position" slot in the UI (grayed out / "—" placeholder until Steam integration in Phase 8). The data contract exists from Phase 6; Phase 8 activates the submission and display.

**No rating/grade system** — clear time is self-explanatory. No S/A/B/C.

**Death state:** If the player dies, show a "Defeat" screen with the same layout (time elapsed, damage taken) and same two buttons. No additional penalty.

---

## 3. Survival Mode — "Onda de Trolls"

### Overview

**Mode name:** Onda de Trolls (Wave of Trolls)
**Format:** Solo or Co-op. Players defend a position against continuous Troll waves approaching from all directions.
**Target duration:** Quick session: ~5 minutes. Extended session: 10–15 minutes (pass-time / survival).

### Connection to the Boss Troll

Survival Mode uses the same Troll enemy family as the Boss Mode, but in weakened, fodder-scale versions. This is intentional:

- Players who have survived Onda de Trolls before their first Boss attempt will recognize the enemy — they know Attack 1 behavior, the roar audio, the silhouette
- The boss fight then feels like a genuinely dangerous version of a familiar enemy
- Art cost is reduced — same base mesh, scaled down and simplified for the fodder variants

### Troll Enemy Variants in Survival Mode

| Variant | HP | Damage | Attack | Notes |
| --- | --- | --- | --- | --- |
| Troll Grunt | 300 | 80 | Grande Martelada (simplified) | No windup flair — just runs and slams. Dies in 3–4 player attacks |
| Troll Warrior | 700 | 120 | Grande Martelada + Rugido Atordoante (reduced stun: 0.8s) | Slower to spawn. Requires more attention. No Tremor attack |

Troll Warriors start appearing from Wave 4 onward. Before that, all spawns are Grunts.

No regeneration on Survival variants — they are pressure through numbers, not through sustain.

---

### Troll Grunt — Detailed Attack Values

**Movement:** 3.5 u/s. Aggressive approach — the Grunt closes distance quickly. Its danger is its speed and numbers, not its attack complexity.

**Attack trigger range:** ≤ 1.8 units from player.

#### Grande Martelada (Grunt — Simplified)

| Parameter | Value |
| --- | --- |
| Windup duration | 0.8s |
| Active hitbox | 0.2s |
| Recovery (vulnerable) | 0.6s |
| Post-recovery cooldown | 1.0s |
| Full attack cycle | ~2.6s |
| Damage | 80 |
| Hitbox shape | Small frontal cone |
| Hitbox range | 1.5 units |

The Grunt's attack has no visual windup flair — just a short pause followed by the slam. It does not telegraph as clearly as the Boss version. The player must respect the attack trigger range rather than reading a specific animation. This is intentional: the Grunt is readable by pattern (it always attacks when close) not by animation.

---

### Troll Warrior — Detailed Attack Values

**Movement:** 2.5 u/s. Slower than the Grunt — the Warrior compensates with higher HP, higher damage, and the stun attack.

**Attack selection logic:**
- Grande Martelada: preferred when player is ≤ 2.5 units
- Rugido Atordoante: triggered when player has been within 3 units for ≥ 2 consecutive seconds, OR when Warrior HP < 350 (escalation mechanic)

#### Grande Martelada (Warrior)

| Parameter | Value |
| --- | --- |
| Windup duration | 1.0s |
| Active hitbox | 0.25s |
| Recovery (vulnerable) | 0.8s |
| Post-recovery cooldown | 1.5s |
| Full attack cycle | ~3.55s |
| Damage | 120 |
| Hitbox shape | Medium frontal cone |
| Hitbox range | 2.2 units |

The Warrior's Martelada has a clearer visual than the Grunt's — it raises its arm higher and the windup is longer. Players who have practiced on Grunts will recognize the pattern.

#### Rugido Atordoante (Warrior — Reduced)

| Parameter | Value |
| --- | --- |
| Windup duration | 0.6s |
| Visual cue | Head lowers + mouth opens before the roar |
| Shockwave radius | 3 units (centered on Warrior) |
| Stun duration on hit | 0.8s |
| Follow-up strike damage | 50 HP |
| Cooldown after use | 12s |

The Warrior's Rugido is a smaller, less dangerous version of the Boss's version. The 3-unit radius is tight enough that a mobile player can avoid it, but a player focused on fighting other Grunts nearby may not notice the Warrior's windup in time.

---

### Survival Mode Arena — "Ruínas da Borda"

**Layout:** Square arena, **40×40 units**. Significantly larger than A Forja (30×20) to support 360° defense and multiple simultaneous enemy approaches.

**Spawn points:** 8 points, one at each compass point on the edge of the arena (N, NE, E, SE, S, SW, W, NW). Each spawn point is 3–4 units outside the playable area border. Enemies path inward via NavMesh upon spawning. Spawn assignment per wave is randomized from the active spawn point pool — the player cannot predict direction.

**Center:** Open plaza with 4 stone column ruins (each approx 1.5×1.5 units footprint). Columns are not blocking to NavMesh — enemies path around them fluidly. They break sightlines and give the player brief cover, but do not create hiding corners.

**Perimeter:** No walls — the arena boundary is implied by the environment (rubble, cliff edges, darkness). The player cannot leave the arena boundary (invisible colliders at edge).

**Lighting:** Dark exterior. Four torch sources (one per quadrant, mounted on column ruins). Same tonal family as A Forja — dark atmosphere with punctual accent lighting. The Troll silhouette must read clearly against the lit floor.

**NavMesh:** Baked over the full 40×40 playable area, minus the column footprints. No dynamic obstacles — the NavMesh is static.

**Name:** Ruínas da Borda (Edge Ruins) — thematically reinforces that threats come from all edges.

---

### Wave Structure

Each wave has a spawn count and composition. Between waves, there is a short rest window (5–8 seconds) where no enemies are active — this is the player's recovery window.

| Wave | Grunts | Warriors | Rest Window | Notes |
| --- | --- | --- | --- | --- |
| Wave 1 | 3 | 0 | 8s | Tutorial wave — spaced spawns |
| Wave 2 | 5 | 0 | 7s | First time multiple Trolls attack simultaneously |
| Wave 3 | 7 | 0 | 6s | Player should be starting to feel pressure |
| Wave 4 | 6 | 1 | 7s | First Warrior — significant threat escalation |
| Wave 5 | 8 | 1 | 6s | |
| Wave 6 | 8 | 2 | 5s | |
| Wave 7 | 10 | 2 | 5s | Quick session ends here (target ~5 min) |
| Wave 8+ | +2 Grunts per wave | +1 Warrior every 2 waves | 4s | Extended session loop |

**Quick session win condition:** Survive Wave 7.
**Extended session:** Endless — score is measured by waves survived.

---

### Spawn Design

Trolls do not spawn from a single direction. They emerge from all edges of the arena, forcing the player to manage 360° awareness. Spawn points are randomized per wave within the edge zones — the player cannot camp one side and ignore the rest.

**Spawn stagger:** Trolls in the same wave do not all spawn simultaneously. They spawn with a 0.5–1s stagger between each enemy. This gives the player a brief window to prioritize targets as the wave arrives rather than being instantly overwhelmed.

---

### Leaderboard Metrics

| Metric | Notes |
| --- | --- |
| Longest survival time | Primary leaderboard metric — measured in seconds |
| Waves completed | Secondary metric displayed alongside survival time |
| Damage dealt | Informational — not leaderboard-ranked |

Leaderboards are scoped by difficulty level. Quick session (Wave 7 target) and extended session (endless) have separate leaderboard entries.

---

### Difficulty Levels

| Level | HP modifier (enemies) | Damage modifier | Spawn stagger | Rest window |
| --- | --- | --- | --- | --- |
| Easy | 0.7× | 0.7× | 1.0s | +2s per wave |
| Normal | 1.0× | 1.0× | 0.75s | Standard |
| Hard | 1.3× | 1.3× | 0.5s | −1s per wave |

The lowest difficulty (Easy) is the unlock gate for content associated with this mode. The design responsibility is to ensure Easy is accessible to any player who has engaged genuinely with the combat system.

---

## 4. Arena Bot AI — Play vs Bot

### Overview

The Arena Bot is a local AI controller that drives a full player character in the 1v1 Arena. It is not a networked opponent — it runs entirely on the same device as the player. Its purpose is to provide a solo entry point to the Arena: training, casual play, and offline practice without requiring a second player or network connectivity.

The Arena Bot shares the same base framework as the PvE enemy AI (Section 1 state machine, animation events, attack recovery windows), but its current canonical target is intentionally simple. Unlike Troll enemies — which only manage their own simple attack patterns — the Arena Bot must drive a full player combat kit, but only to the extent required to create a basic fight-to-the-death training opponent.

**Design principle:** The bot should be basic, readable, and honest. It does not need to "think", counter the player, or simulate a high-level duelist. It only needs to pursue, reach valid range, attack, use skills when available, and keep fighting until death.

---

### Arena Bot State Machine

The current canonical bot loop is intentionally small:

```
[Acquire Target]
     ↓
[Approach or Hold Valid Range]
     ↓ (basic attack range reached)
[Basic Attack]
     ↓ (skill ready AND target valid)
[Use Skill]
     ↓
[Return to Approach or Hold Valid Range]
```

Rules:
- melee bot behavior means closing distance until it can attack or cast
- ranged bot behavior means moving until it has valid attack or skill range, then holding or adjusting that range
- the bot keeps running this loop until the match ends
- no advanced interruption logic is required beyond respecting existing recovery / cooldown constraints

---

### Loadout Definition

The Arena Bot uses **predefined valid loadouts**, not random ones. Random loadouts create inconsistent training value and make integration harder when the official content package changes.

Loadout selection logic:
- the bot uses a legal race / weapon / spell set from the currently official content pool
- a small curated set of bot loadouts is sufficient
- loadouts should be updated when the official weapon or spell catalog changes significantly

**Rule:** Bot loadouts are living integration assets, not set-and-forget content.

---

### Attack and Skill Behavior

**Basic attack:** The bot enters valid attack range and executes the weapon's basic attack sequence. It should respect the weapon's natural cadence and existing recovery windows instead of artificially spamming.

**Skills:** Skills are used whenever:
- a target exists
- the target is in valid range for that skill
- the skill cooldown allows usage

The bot does not need:
- telegraph-reading logic
- opponent-specific counters
- mind games
- difficulty-tier hesitation logic
- evasive tactical reactions

Potion intelligence is not required for the current Phase 7 target behavior.

---

### Local-Only Constraints

The Arena Bot runs entirely locally. It does not:
- Submit results to any leaderboard (Play vs Bot matches are excluded from ranked boards)
- Open a service-owned online session or tracked run record
- Contribute to any progression or mastery counters

The bot match result is shown on a local results screen (win/loss, match duration, damage dealt/received) but has no persistent effect on the account. This is intentional — the bot is a practice tool, not a competitive mode.

---

### Phase 4 Design Note

The Arena Bot is a Phase 4 deliverable because it depends on the same underlying AI infrastructure built for PvE enemies. The behavior state machine, animation event integration, and ScriptableObject-based configuration are shared. The Arena Bot is a specialization of this framework, not a separate system. Phase 7 keeps the bot intentionally basic instead of growing it into a tactical PvP simulator.

---

## 5. Enemy AI — Phase 4 Implementation Scope

### What Phase 4 Must Deliver

Phase 4 is responsible for the enemy AI foundation that all future PvE modes build upon, and the Arena Bot as a local Play vs Bot feature. The scope is:

- Enemy behavior state machine (Idle → Aggro → Navigate → Attack → Recover → Stunned → Dead)
- Troll Grunt implementation (simple state machine — navigate + single attack)
- Troll Warrior implementation (two-attack state machine with range-based selection)
- Onda de Trolls wave system (wave manager, spawn controller, rest window logic)
- Survival Mode complete game loop (start → wave progression → death → results screen)
- Leaderboard submission events (survival time, wave count) — Phase 8 integrates Steam submission, but the events should be defined now
- **Arena Bot AI controller** (basic acquire-target / chase-or-hold-range / attack / skill loop with no advanced tactical layer)
- **BotLoadout ScriptableObjects** for curated valid loadouts from the official content pool
- **Play vs Bot match flow** in the Arena (local match, no session tracking, local results screen)

### What Phase 4 Does NOT Deliver

- Boss Troll (Phase 6)
- Steam leaderboard submission integration (Phase 8)
- Advanced Arena Bot AI features such as difficulty tiers, evasion logic, or mind-game behavior
- Co-op parity and validation for Survival Mode (co-op is architecturally supported from Phase 1, but the explicit compatibility + parity pass is a Phase 7 scope item)
- Ranked or tracked Play vs Bot results (bot matches are local-only and excluded from all leaderboards and account progression)

### Design Note for Phase 4 Execution

The enemy behavior system must use the same Simulation Layer principle as the player combat system. The simulation does not know whether it is running in solo or co-op. Enemy AI inputs (movement direction, attack decisions) go through the same simulation path as player inputs. This ensures co-op correctness is architectural, not bolted on.

---

## 6. Boss Troll — Phase 6 Implementation Scope

### What Phase 6 Must Deliver

- Boss Troll full implementation (all 3 attacks, all 3 phases, regeneration system)
- Phase transition logic (HP thresholds, transition animations, invulnerability windows)
- Boss room scene ("Sala do Troll" — to be designed during Phase 6 scene authoring)
- Boss Mode game loop (enter room → fight → death or victory → results screen)
- Boss Mode leaderboard events (clear time, damage taken) — events defined here, Steam submission in Phase 8

### Balance Expectation

All numeric values in Section 2 are starting baselines. The actual balance will be determined during Phase 6 playtesting. The design intent (readable attacks, regen pressure, phase escalation) is fixed. Numbers are tunable.

---

## 7. Rule for Using This Document

This document is the design reference for Phase 4 and Phase 6 execution.

For the macro phase plan, see `docs/evolution-roadmap.md`.
For game mode rules, loadout structure, and attribute system, see `docs/game-design-document.md`.
For visual production guidelines, see `docs/guides/art-pipeline.md`.

If enemy designs change during playtesting, update this document explicitly.
