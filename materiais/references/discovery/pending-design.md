# Pending Design

> Historical discovery note. This file preserves legacy Unity-era planning context and is not the current project source of truth. For current product and implementation authority, read `D:\Estudio\AGENTS.md`, `D:\Estudio\canon\`, and `D:\Estudio\Projetos\rpg-isometrico\implementation\current-status.md` first. Shared canon and current operational status win over anything in this file.

## Purpose of This Document

This document is the single source of truth for everything that is **not yet designed, documented, or planned** in the project. It exists to prevent design gaps from being forgotten and to make it clear what work needs to happen before each phase can enter execution.

This document is a living reference. Update it when a pending item is resolved (remove it or mark as complete) and when new gaps are identified.

**Last updated:** 2026-04-18 (Stage 05 Arena reformulation definition frozen; pending-design updated after canon propagation)

For the macro phase order, see `docs/evolution-roadmap.md`.
For what IS already designed, see the document index at the bottom of this file.

---

## Status Legend

| Symbol | Meaning |
| --- | --- |
| 🔴 | Blocks the next phase from starting |
| 🟡 | Needed before the phase can be executed, but doesn't block earlier phases |
| 🔵 | Intentionally deferred - tracked here so it's not forgotten |
| ✅ | Resolved - kept briefly for reference, then removed |

---

## Phase 3 - 1v1 PvP Arena

**Execution status: CLOSED.** Phase 3 closed 2026-04-11 with positive validation. All deliverables confirmed: PvP arena, loadout flow, crystal contest, client prediction, cross-platform builds.

No open items.

---

## Phase 4 - Enemy AI + Survival Mode

**Execution status: CLOSED.** Phase 4 closed 2026-04-12 with basic validation confirmed. All deliverables confirmed: Enemy AI framework, Troll Grunt + Warrior, Survival Mode (Onda de Trolls), Arena Bot (Play vs Bot), Phase 3 regression clean.

No open items.

---

## Phase 5 - Consolidation

**Design status: Defined. Execution status: CLOSED 2026-04-15 (re-closed after bug-fix pass).**

All 6 stages complete. Three build validation bugs were found after initial Stage 6 delivery and fixed on 2026-04-15. Smoke test passed (static verification). Phase 6 can proceed.

| Item | Status | Notes |
| --- | --- | --- |
| ✅ BUG - PcPlayerIntentAdapter crash in Survival Mode | ✅ | Fixed 2026-04-15. Root cause: `InputSystem_Actions.inputactions` still had "WeaponSwap" action; Stage 6 had renamed it to "Skill4" in C# only. Fix: renamed action and both binding entries in the JSON asset. Skill4 input chain fully verified: asset -> ReflectedGameplayActions -> PlayerIntent.Skill4 -> PlayerCombatController.TryStartSkill(3). |
| ✅ BUG - Versus loadout confirm button never activates | ✅ | Fixed 2026-04-15. Root cause: `RequiredSkillCount` was raised to 4 but weapon content assets only had 3 skills each. `ResolveSelectedSkills` returned 3 skills -> `TryBuildLoadoutData` gated on `selectedSkills.Length >= 4` -> silently blocked. Fix: added `Skill_WarCry` (4th skill, Martelo/Heroic, GUID `ebc457da...`) and `Skill_BulletStorm` (4th skill, AssaultRifle/Human, GUID `df8f1498...`) as proper `SkillDefinitionAsset` ScriptableObjects; updated both weapon `skillPool`, both race `raceSkills`, SkillCatalog, and all 6 BotLoadout assets. |
| ✅ BUG - "Aventura" still present in main menu | ✅ | Fixed 2026-04-15. Root cause: `DrawModeSelection()` in `Phase3PvpFrontEndDebugPresenter` still had the `GUILayout.Button("Aventura")` block. Removed; replaced with a NOTE comment. Main menu now shows: Versus, Solo, Co-op only. |
| Game mode comparative analysis | ✅ | Complete. 7 structural divergences found across Session Manager, Game Loop, HUD, Launch Context, Results, Simulation Context, Loadout. |
| Mode standardization spec | ✅ | Complete. See `docs/game-mode-standard.md` - mandatory architecture for all game modes. |
| Stage 3 standardization refactor | ✅ | Complete 2026-04-12. GameContext unified; static Show() deprecated; ArenaBotSessionManager and ArenaBotSceneBootstrap created; ArenaSceneBootstrap.cs truncation repaired; ConfigureLocalPlayer aligned. |
| Loadout code update | ✅ | Complete 2026-04-12 + bug fix 2026-04-15. Passive system removed; 4th spell slot added; 4th skill content added to all weapon and race assets. |
| Unified build | ✅ | Build compiles; all 3 modes accessible from menu; PC input functional; loadout confirm activates; main menu clean. |
| HUD finalization - Stage 6 input/layout | ✅ | Complete 2026-04-14 + InputSystem_Actions asset fix 2026-04-15. Skill4 binding: Tab (PC) / leftTrigger (Mobile). |
| Mobile control layout for 4 skills | ✅ | Layout code complete. |
| Track B: Art implementation tutorial | 🔵 | Tutorial (Meshy -> Blender -> Mixamo -> Unity) + 1 complete character example (Heroic/Martelo). Parallel - does not block Phase 6. |

---

## Phase 6 - Boss Mode

**Design status: COMPLETE. Execution status: CLOSED 2026-04-16.**

All 7 stages are now implemented in the workspace. Boss Troll AI, BossTrollArena, Boss HUD, Boss results flow, front-end routing, and official Phase 6 Windows/Android build export are in place.

| Item | Status | Notes |
| --- | --- | --- |
| Phase 6 production plan + execution package | ✅ | `docs/archive/phase-6-production-plan.md`, `implementation/phase-6/execution-scripts/` and closure artifacts are all present on disk. |
| Phase 6 integration + validation closure | ✅ | `Invoke-UnityValidation.ps1` clean; Windows and Android test builds produced on 2026-04-16. |
| Boss room "Sala do Troll" - layout design | ✅ | Circular arena, single-door entry (closes on entry), dormant Troll activation, 4 decorative torches. See `enemy-design-discovery.md` Section 2 "Boss Room Design Notes". |
| Boss Mode - results screen design | ✅ | Primary: clear time. Secondary: damage taken. Buttons: Jogar Novamente + Menu Principal. Leaderboard slot reserved (activates Phase 8). See `enemy-design-discovery.md` Section 2 "Boss Mode - Results Screen". |

**Phase 6 CLOSED 2026-04-16.** Note: this thread produced the Windows/Android builds and clean automated validation, but no ARM64 device was attached here for physical APK smoke/performance confirmation.

---

## Phase 7 - Polish & Base Expansion

**Design status: Structured.** This phase is about polishing the current base, reformulating the official content package in a bounded way, and preparing a strong closed playtest. It is not the campaign slice and it is not the Steam platform phase.

Update 2026-04-18: `Stage 03 - HUD Definition` and the `Stage 05 - Arena Reformulation` definition are now resolved at the canon level. The Phase 7 HUD contract is frozen around one shared `Combat Shell` across `Arena`, `Arena Bot`, `Survival`, and `Boss`, and the active `A Forja` direction is now frozen around a larger shared Arena surface with a free crystal center, mixed outer open/closed sections, uniformly tall internal walls, and one-hit destructible crates.

| Item | Status | Notes |
| --- | --- | --- |
| ✅ Phase 7 production plan | ✅ | Stage sequence frozen in `implementation/phase-7/stage-specs/stage-01-operational-foundation.md`. Execution Scripts remain intentionally deferred until each stage has its own implementation conversation. |
| ✅ Closed playtest quality bar | ✅ | Defined in the Stage 01 operational package as explicit pass/fail criteria for menu, Arena 1x1, Arena Bot, Survival, Boss, co-op compatibility, and HUD legibility. |
| ✅ Open-ended light content expansion target | ✅ | Retired. Phase 7 now uses bounded `Content Reformulation` instead of open-ended light expansion. |
| ✅ Content Reformulation definition | ✅ | Stage 02 froze the official Phase 7 package: `Heroic` as the only official race, `Martelo` / `Machado` / `Espada`, `9` shared Heroic spells, and `3` common potions shared across races. `Human / Rifle de Assalto` remains bounded non-official ranged test content. |
| HUD definition | ✅ | Stage 03 froze one shared `Combat Shell` across `Arena`, `Arena Bot`, `Survival`, and `Boss`, including the information hierarchy, per-mode modules, overlay states, desktop/mobile legibility rules, the canonical `4 skills + 2 potions` HUD contract, and the boundary between screen-space HUD and world-space combat feedback. |
| Co-op parity targets | 🟡 | Stage 09 must define the HP / Damage parity pass for creatures and boss encounters after the official Phase 7 content package is locked. |

---

## Phase 8 - Steam Integration

**Design status: Scope defined.** The monetization model changed to buy-once + free demo on Steam. The former PlayFab/live-service backend has been archived. Phase 8 is now a focused Steam integration.

| Item | Status | Notes |
| --- | --- | --- |
| Phase 8 production plan | 🟡 | Needs stage definitions and execution scripts. Scope: Steam Networking (co-op + PvP), Steam Cloud save, Steam Leaderboards, cosmetic shop purchase flow. |
| Cosmetic shop - first skins | 🔵 | Shop structure defined (direct purchase via Steam, cosmetics only). A player-facing first skin set is still undefined. Phase 8 can implement hidden shop plumbing first, but a visible catalog needs at least one skin set. |
| Steam Leaderboard scoping | ✅ | Baseline board names, result boundaries, and first target boards are now defined in `docs/steam-integration.md`. Remaining work is implementation and validation. |

---

## Phase 9 - Roguelite Campaign

**Design status: System complete.** `docs/discovery/campaign-design-discovery.md` defines the full roguelite loop, death rule, upgrade system, shop, and difficulty system. What's missing is stage-level detail and a production plan.

| Item | Status | Notes |
| --- | --- | --- |
| Phase 9 production plan | 🟡 | Needs execution scripts. Depends on Phase 6 (Boss), Phase 7 (Polish & Base Expansion), and Phase 8 (Steam Integration) being complete. |
| Troll Campaign - Stage 1 detailed design | 🟡 | High-level: Exterminate, Grunts only. Missing: map layout, spawn count, spawn positions, wave flow, exact objective trigger. |
| Troll Campaign - Stage 2 detailed design | 🟡 | High-level: Survive, first Warrior. Missing: duration, wave composition per interval, arena layout. |
| Troll Campaign - Stage 3 detailed design | 🟡 | High-level: Destroy objective. Missing: what is being destroyed, map design, enemy pressure during objective. |
| Troll Campaign - Stage 4 detailed design | 🟡 | High-level: Heavy Warrior pressure. Missing: map layout, exact composition, escalation curve. |
| Stage objective types - Destroy and Escort | 🟡 | Objective types defined in campaign doc. Their mechanics (how Destroy works, how Escort works, failure conditions) are not yet designed. |
| Shop - gold pricing and per-enemy drop values | 🟡 | Shop structure defined. Actual gold economy (how much gold per enemy tier, how much each buff costs) needs baseline values for Phase 9 balance. |

---

## Phase 10 - 2v2 Arena

**Design status: None.** This phase has no design document. Everything below is a design gap.

| Item | Status | Notes |
| --- | --- | --- |
| 2v2 Arena - map design | 🔵 | A Forja is 1v1. 2v2 needs a different layout. Size, zone structure, spawn positions for 4 players, crystal placement - all undefined. |
| 2v2 - team balance review | 🔵 | The 1v1 weapon kits are designed as duels. 2v2 introduces team composition. Do skills need adjustments for team play? Not assessed. |
| New weapons for Phase 10 | 🔵 | Heroic: Bow, Sword, or Spear (choose one). Human: Sniper, Desert Eagle, or Machine Gun (choose one). Neither has been designed. A second weapon per race expands the pre-match loadout variety in 2v2. |

---

## Phase 11 - MOBA

**Design status: Flagged as incomplete in GDD.** The GDD states: "needs design refinement before entering production."

| Item | Status | Notes |
| --- | --- | --- |
| MOBA - full design session | 🔵 | Lane design, minion behavior and AI, base upgrade tree, crystal and boss placement on the MOBA map, gold economy, win condition refinement, 3v3 rules - all undefined. This requires a dedicated design session before any production planning can happen. |
| MOBA - map design (1v1) | 🔵 | Single lane, 1 base per team, 2 towers per side. Geometry and dimensions not designed. |
| MOBA - minion AI | 🔵 | Minions are simpler than enemy AI but need their own behavior: march toward enemy base, attack blocking units, die to towers. Distinct from the enemy AI system in Phase 4. |
| MOBA - base upgrade tree | 🔵 | Gold from last-hitting minions upgrades the base. What does the tree look like? What can be upgraded? Not designed. |

---

## Systems Without Design (Any Phase)

These are systems the game requires but that have no design document yet. They are not tied to a specific phase but must be resolved before the game can launch or before certain phases can complete.

| System | Status | Notes |
| --- | --- | --- |
| Sound and music direction | 🔵 | Listed in GDD as a deferred design area. The game's identity is "high and exuberant" combat - audio direction is as important as visual direction for achieving this. No decisions exist. |
| Onboarding and tutorial | 🔵 | The broader onboarding flow - loadout screen guidance, first-match tutorial, control explanation - is not yet designed. Onboarding must ensure Easy difficulty is achievable without prior knowledge (the unlock gate depends on it). |
| Lore and narrative | 🔵 | Intentionally deferred. Setting is "spatial, atemporal, multi-cultural." Atmospheric lore for environmental storytelling. No decisions exist on world names, faction names, story beats, or environmental narrative. Needed before Campaign stage design can include thematic context. |
| Matchmaking | 🔵 | When PvP is eventually released, entry can remain lobby-based (room code / Steam friend invite) with no matchmaking. Matchmaking is a future concern - no design needed until the player base justifies it. |
| Hub world / navigable lobby | 🔵 | evolution-roadmap mentions evolution from a menu to a navigable hub. No design for what this looks like, what it contains, or when it happens. |
| Skin system - first skins | 🔵 | Art pipeline defines the skin structure (character model + weapon + skill VFX). No skins have been designed. The cosmetic shop has nothing to show in a player-facing catalog without them. Needed before Phase 8 shop implementation. |
| Races 3 and 4 - weapon and skill design | 🔵 | Intelligent Aliens and Magic Beings are visual identities only. No weapons, skills, or potions designed. Cannot enter production until at least one weapon per race is fully designed (minimum: 5-6 skills for the weapon). |
| Second campaign | 🔵 | The first campaign is Troll. What is the second? New biome, new enemy type, new boss, new race/weapon unlocks - all undefined. |
| Steam page and launch materials | 🔵 | Needed before any public Steam presence. Store page description, screenshots, capsule art, trailer. Not a design document - but a production gap that must be closed before a future public Steam release, independent of the current internal phase. |

---

## What Is Already Designed and Documented

For clarity, here is the complete list of what IS resolved and has a document.

| Area | Document |
| --- | --- |
| Product vision, pillars, race system overview, monetization model | `docs/product-vision.md` |
| Full game design: modes, weapons, skills, attributes, crystal buffs, arena, progression | `docs/game-design-document.md` |
| Current project architecture | `docs/project-architecture.md` |
| Current implementation workflow | `docs/implementation-roadmap.md` |
| Phase 3 design decisions (camera, weapons, arena, crystal buff values); passives REMOVED | `docs/discovery/phase-3-design-discovery.md` |
| Phase 3 production plan (5 stages, 10 execution scripts) | `docs/archive/phase-3-production-plan.md` |
| Macro phase order (Phases 3-10) | `docs/evolution-roadmap.md` |
| Backend architecture (PlayFab/live-service model - ARCHIVED) | `docs/archive/backend-architecture-freemium.md` |
| Art pipeline (visual identity, tools, race visual vocabulary, VFX, skins) | `docs/guides/art-pipeline.md` |
| Enemy AI framework, Troll Boss design, Survival Mode (Onda de Trolls), Grunt/Warrior attack values, Ruinas da Borda arena layout, Arena Bot | `docs/discovery/enemy-design-discovery.md` |
| Phase 4 production plan (4 stages, 7 execution scripts) | `docs/archive/phase-4-production-plan.md` |
| Campaign roguelite system (death rule, stages, upgrade loop, shop, difficulty) | `docs/discovery/campaign-design-discovery.md` |
| Agent conventions and Codex workflow | `docs/agent-conventions.md` |
| Game mode standard - mandatory architecture for all modes | `docs/game-mode-standard.md` |

---

## How to Use This Document

When starting a new design session: check the 🔴 items first (they block execution), then work through 🟡 items for the next phase in the production order.

When a pending item is resolved: remove it from this document and add the relevant information to the appropriate design document. Do not accumulate resolved items here - this document must stay clean and actionable.

When a new gap is discovered: add it to the appropriate phase section with the correct status symbol and a clear note explaining what is missing.
