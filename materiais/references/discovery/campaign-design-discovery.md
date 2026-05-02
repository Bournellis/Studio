# Campaign Design Discovery

> Historical discovery note. This file preserves legacy campaign exploration and old phase assumptions. It is not the current campaign implementation plan. For current authority, read `D:\Estudio\canon\design\game-design-document.md`, `D:\Estudio\canon\design\progression-design.md`, and `D:\Estudio\Projetos\rpg-isometrico\implementation\current-status.md` first. Shared canon and current operational status win over anything in this file.

## Purpose of This Document

This document records the design decisions for the Roguelite Campaign mode. It covers the campaign structure, the stage system, the death rule, the upgrade loop between stages, the shop, and the difficulty system.

This document is the design reference for Phase 9 (Roguelite Campaign slice) execution. Phase 9 depends on Phase 6 (Boss Mode), Phase 7 (Polish & Base Expansion), and Phase 8 (Steam Integration) being complete.

For the macro phase plan, see `docs/evolution-roadmap.md`.
For game mode rules, loadout, and attribute system, see `docs/game-design-document.md`.
For boss and enemy designs, see `docs/discovery/enemy-design-discovery.md`.

---

## 1. Campaign Philosophy

The Campaign is the game's flagship PvE experience. It is longer and more layered than Survival or Boss Mode, and it is the primary content unlock gate — completing it at Easy difficulty is what grants access to the new races, weapons, skills, and potions introduced by that adventure.

Two design principles govern all Campaign decisions:

**Principle 1 — Runs must matter.**
Death resets the entire run. There are no checkpoints within a campaign. A player who dies on Stage 4 returns to Stage 1 with nothing — no accumulated buffs, no gold, no skill upgrades from that run. This is non-negotiable. The weight of each stage, each upgrade decision, and each fight comes from this rule.

**Principle 2 — The run is short enough that reset is fair.**
The tension of death-resets-all is only meaningful if the campaign is short enough that the loss is painful but not discouraging. A run should target 20–25 minutes on Easy and 30–40 minutes on Hard. This is achievable on mobile in a single sitting. Losing 25 minutes to a mistake is a real consequence — losing an hour would be unreasonable.

These two principles are complementary: the campaign is hard enough to matter and short enough that retrying is a genuine choice, not a burden.

---

## 2. Stage Structure

### Stage Count and Duration

All difficulty levels have the **same number of stages**. The difficulty comes from enemy strength, speed, and damage — not from the number of stages.

**Total stages per campaign: 5**

| Stage | Type | Target Duration (Easy) | Target Duration (Hard) | Notes |
| --- | --- | --- | --- | --- |
| Stage 1 | Combat + Objective | ~4–5 min | ~6–7 min | Introductory — single enemy type, low complexity |
| Stage 2 | Combat + Objective | ~4–5 min | ~6–7 min | First multi-enemy encounters |
| Stage 3 | Combat + Objective | ~5–6 min | ~7–8 min | Mid-campaign pressure peak |
| Stage 4 | Combat + Objective | ~5–6 min | ~7–8 min | Final preparation before boss |
| Stage 5 | Boss Encounter | ~4–5 min | ~6–8 min | Campaign boss — full boss encounter |

**Total target:**
- Easy: ~20–25 minutes
- Normal: ~25–30 minutes
- Hard: ~30–40 minutes

The longer Hard durations come from enemies with higher HP (longer fights), more aggressive damage patterns (forcing more defensive play and slower aggression), and harder boss phases.

### Stage Objectives

Each stage has a clear, bounded victory condition. The player knows exactly what to do. No stage should be ambiguous about what constitutes completion.

Planned objective types (first campaign — Troll Campaign):

| Objective Type | Description |
| --- | --- |
| Exterminate | Kill all enemies in the stage. Standard. |
| Survive | Survive a fixed duration against continuous enemy pressure. Timer shown. |
| Destroy | Destroy a specific target (structure, altar, object) while defending against enemy waves. |
| Escort | Move an objective across the map; enemies attempt to block or intercept. |
| Boss | Kill the campaign boss. Stage 5 only. |

Not every objective type is used in every campaign. The first campaign (Troll) prioritizes Exterminate and Survive, with Stage 5 as a Boss encounter. Variety increases in later campaigns.

---

## 3. Death Rule

**Death = full campaign reset.**

If the player dies at any point during any stage, the run ends. All progress within the run — accumulated skill upgrades, buff purchases, gold, and stat increases — is lost. The player returns to the campaign entry screen and can start a new run.

**Co-op exception:** In co-op, if one player dies, the other player(s) have a window to complete the current stage. If they succeed, the dead player is revived at the start of the next stage. If all players die simultaneously, the run ends for everyone.

### Why This Rule Is Appropriate at This Campaign Length

At 20–25 minutes on Easy, the maximum loss on death is approximately 25 minutes. This is the threshold at which death is genuinely painful but not demotivating. Players will replay the campaign with a clearer understanding of what went wrong — which is the core emotion roguelites are designed to produce.

This rule also makes the upgrade decisions meaningful. Every buff purchased, every skill point spent, builds toward a specific run. Losing that build forces a new strategic approach on the next attempt, which is the source of roguelite replayability.

---

## 4. Between-Stage Upgrade Loop

After completing each of Stages 1–4, the player enters an upgrade screen before the next stage begins. There is **no upgrade screen after Stage 5** (the boss) — completing the boss ends the campaign.

The upgrade screen has two components that happen simultaneously:

### Component 1 — Level Up

The player gains one level upon completing a stage. Leveling up grants:

- **Automatic stat increase:** applied immediately, no choice required
- **1 Skill Point:** the player manually allocates this point to advance one of their 3 skills

**Stat increase per level (Campaign baseline — tunable during Phase 9 playtesting):**

| Stat | Per Level | At Max (Level 4, all stages complete) |
| --- | --- | --- |
| Damage | +12% | +48% over baseline |
| Max HP | +8% | +32% over baseline |

Values are calibrated to a 4-level progression across 5 stages. They differ from the PvP system (7 levels, different rates) because the Campaign has fewer total levels but longer absolute fights.

**Skill Point system:**

The player's 3 skills each have 3 tiers: Base, Level 2, and Ultimate. Each tier requires 1 skill point to advance. Maximum investment per skill: 2 points (Base → Level 2 → Ultimate).

A player receives 4 skill points across a full run (one per stage completion, stages 1–4). This means they can:

| Strategy | Distribution | Result |
| --- | --- | --- |
| Specialize | 2 points in Skill A, 2 in Skill B | Two fully maxed skills; Skill C stays at Base |
| Balanced | 2 points in Skill A, 1 in Skill B, 1 in Skill C | One maxed skill; two at Level 2 |
| Distribute | 1 point in each skill + 1 extra anywhere | No Ultimate unlocked; all skills at Level 2 or better |

The choice between specializing into one skill's Ultimate vs. spreading across all three is the primary strategic decision of the upgrade loop.

**Skill tier availability:**
All 3 skills are active from the start of Stage 1 at Base tier. There is no "unlock" phase — the Campaign starts with the full kit, unlike PvP where skills are unlocked level by level. This is consistent with the Campaign being a longer, co-op-compatible format where players should not be mechanically handicapped in early stages.

---

### Component 2 — The Shop

After the level-up, the shop opens. The player can spend gold earned during the completed stage.

**Gold acquisition:** Enemies drop gold on death. The amount scales with enemy tier. Bosses in stages (mini-bosses, if any) drop larger amounts.

**Shop structure:** The shop always presents **3 randomly selected items** from the current available pool. The player buys 0, 1, 2, or all 3 items depending on available gold. Items not purchased are discarded — the next shop visit has a fresh set of 3 items.

This randomization is the primary source of run variability in the shop layer. A run where the shop consistently offers Fúria (damage) plays differently than a run where it offers Aceleração (speed) and Velocidade de Ataque (attack speed).

---

## 5. The Shop — Buff System

The Campaign shop sells **combat buffs** using the same vocabulary as the Crystal Buff system in PvP modes. This is intentional — a player who understands crystal buffs from Arena or MOBA immediately understands what they are buying in the Campaign shop.

### Campaign Buff Pool (First Campaign)

These buffs mirror the Phase 3 PvP crystal buff pool. Values may differ from PvP for balance reasons — PvP buffs stack up to 7 times in a ~7-minute match; Campaign buffs stack up to 4 times across a ~20-minute run.

| Buff | Effect (per purchase) | Max stacks | Max total |
| --- | --- | --- | --- |
| Fúria | +8% Basic Attack Damage | 4 | +32% Basic Attack Damage |
| Poder Arcano | +8% Spell Damage | 4 | +32% Spell Damage |
| Golpe Certeiro | +4% Critical Chance | 4 | +16% Critical Chance |
| Aceleração | +0.4 u/s Movement Speed | 4 | +1.6 u/s Movement Speed |
| Velocidade de Ataque | +6% Attack Speed | 4 | +24% Attack Speed |

Buffs purchased in the shop are **permanent for the run** and are lost entirely on death (consistent with the full-reset death rule).

**Gold pricing (baseline — tunable):** Each buff costs a flat amount of gold. The price should be calibrated so that a well-played stage provides enough gold for 1–2 purchases per shop visit, with careful play occasionally allowing 3.

### Future Shop Expansion

Additional shop items may be added in later campaigns and content packages:

- **Potion restock** — refill potion charges at a moderate gold cost
- **Temporary skill boost** — a temporary upgrade to an active skill, valid only for the current run (replaces the former "passive" concept — removed from the game)
- **Extra skill point** — purchase an additional skill point to advance a third tier

These items are deferred from the first campaign to keep the initial system lean. The buff shop is the core — expansions add depth without changing the foundation.

---

## 6. Difficulty System

All difficulty levels use the same 5-stage structure and the same upgrade loop. Difficulty is expressed entirely through enemy parameters.

| Parameter | Easy | Normal | Hard |
| --- | --- | --- | --- |
| Enemy HP | 0.7× baseline | 1.0× baseline | 1.4× baseline |
| Enemy Damage | 0.7× baseline | 1.0× baseline | 1.4× baseline |
| Enemy Speed | 0.85× baseline | 1.0× baseline | 1.15× baseline |
| Enemy count per wave | –20% | Baseline | +20% |
| Gold drop per enemy | +20% | Baseline | Baseline |
| Boss HP | 0.6× baseline | 1.0× baseline | 1.5× baseline |

Easy mode gives more gold per enemy (to compensate for shorter fights producing less total gold) and reduces enemy count, making waves manageable for players still learning the campaign.

**The Unlock Gate:**
Completing the campaign at Easy difficulty is the unlock gate for the content package associated with that campaign. This design intent is that any player who has genuinely engaged with the game's combat system should be able to complete Easy mode with effort and knowledge. Easy should be challenging, not trivial — but it must be achievable.

---

## 7. Campaign — "Troll Campaign" (First Campaign)

The first campaign is centered around the Troll as the primary enemy faction. All stages use Troll-family enemies (Grunt and Warrior variants — see `docs/discovery/enemy-design-discovery.md`) leading up to the Boss Troll as the Stage 5 encounter.

**Visual theme:** Ancient ruins of the Heroic world. Stone corridors, collapsed columns, dimly lit chambers. Consistent with the Heroic race visual vocabulary — dark fantasy, stone, ancient.

**Stage progression:**

| Stage | Objective Type | Enemy Composition | Notes |
| --- | --- | --- | --- |
| Stage 1 | Exterminate | Troll Grunts only | Introductory — learn the enemy |
| Stage 2 | Survive | Grunts + first Warrior | Timed survival; first Warrior encounter |
| Stage 3 | Destroy | Mixed Grunts and Warriors | Protect target while eliminating enemies |
| Stage 4 | Exterminate | Heavy Warriors + elite variants | Final preparation — highest non-boss pressure |
| Stage 5 | Boss | Boss Troll (full design: `docs/discovery/enemy-design-discovery.md` Section 2) | Campaign climax |

**Why the Troll Campaign is the first:**

It introduces the game's enemy system on a single enemy type, giving the player time to learn the Troll's behavior patterns across 4 stages before the full boss version appears. This is the same pedagogical logic used in the Survival Mode — familiarity with the enemy makes the boss encounter more dramatic and meaningful, not easier.

---

## 8. Replayability

A 20-25 minute campaign with full death-reset creates natural replayability without requiring an explicit "New Game+" system. The sources of variability between runs are:

**Build variability:** The shop presents random buff combinations each run. A damage-heavy run (Fúria stacked) plays mechanically different from a speed-heavy run (Aceleração + Velocidade de Ataque stacked). With 5 buffs in the pool and 3 shown per shop, no two runs have the same shop sequence.

**Skill point decisions:** With 4 points and a 3-skill kit, the distribution choice is different every run depending on how the player reads their current performance. A player who keeps dying to the boss's stun attack might double down on mobility (Skill 3 maxed for its dash synergy) on the next run.

**Difficulty progression:** Easy, Normal, and Hard are genuinely different experiences. Hard mode is not just "same campaign with more HP" — the additional enemy damage and speed change which enemies are threats, which shop buffs matter most, and how much risk the player can take on Stage 4.

---

## 9. Connection to Account Progression

The Campaign is the center of the content unlock system. Each adventure includes:

- One campaign
- Related mini-games sharing the same art, maps, and enemy set
- New playable content: races, weapons, skills, potions

Completing the campaign at Easy difficulty unlocks all new playable content associated with that adventure. This ensures that unlocks reflect genuine engagement with the game — owning the game alone does not unlock everything.

The first adventure (Troll Campaign) is included in the free demo. The full game purchase grants access to all existing and future adventures.

The leaderboard for the Campaign tracks **fastest full clear per difficulty level** via Steam Leaderboards. A player who has completed Easy may attempt Normal and Hard for leaderboard competition and personal challenge. Each difficulty has its own leaderboard.

---

## 10. Phase 9 Implementation Scope

### What Phase 9 Must Deliver

- Full campaign game loop: loadout → stage 1 → upgrade screen → stage 2 → ... → stage 5 (boss) → victory screen
- Death handling: loss screen, run summary (stages reached, damage dealt, time survived), return to campaign entry
- Upgrade screen: level-up stat display + skill point allocation UI + shop with buff purchases
- Gold system: enemy drop events, gold counter, shop transaction logic
- Stage objectives: Exterminate and Survive objective types (minimum for first campaign)
- All 5 Troll Campaign stages authored in Unity
- Boss Troll as Stage 5 (depends on Phase 6 deliverable — Boss Troll must be complete)
- Difficulty scaling: modifier application to enemy HP, damage, speed, count
- Co-op run handling: dead player tracking, revival on stage completion
- Content unlock: local flag set on Easy completion, unlocking associated races/weapons/skills/potions
- Steam Leaderboard submission on campaign completion (depends on Phase 8 Steam integration)

### What Phase 9 Does NOT Deliver

- Additional objective types (Destroy, Escort) — deferred to second campaign
- Second campaign content (new enemy types, new biome, new boss)
- Meta-progression between runs (currently not designed — if added later, it enters as a new design session)

### Dependencies

Phase 9 requires Phase 6 (Boss Troll), Phase 7 (Polish & Base Expansion), and Phase 8 (Steam Integration — leaderboard submission) to be complete before execution begins.

---

## 11. Rule for Using This Document

This document is the design reference for Campaign and Roguelite system decisions.

For the macro phase plan, see `docs/evolution-roadmap.md`.
For enemy and boss designs, see `docs/discovery/enemy-design-discovery.md`.
For game mode rules, loadout, and attribute system, see `docs/game-design-document.md`.

If campaign designs change during Phase 9 planning or playtesting, update this document explicitly.
