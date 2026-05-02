# Canon Brief

This file is the token-efficient entry point for bounded work across the Godot-first workspace.

It summarizes the shared canon, but it does not replace the full read order in `README.md` and `D:\Estudio\AGENTS.md`.

## Shared Snapshot

Current project map:

- `Projetos/rpg-isometrico/`: campaign-first isometric action RPG governed by the established product, design, progression, roadmap, and platform canon.
- `Projetos/rpg-turnos/`: provisional turn-based RPG with independent mechanics, shared lore context, and local project docs as the source of truth for its early design.

Treat RPG Isometrico as:

- a campaign-first isometric action game
- race-first in character identity
- driven by kit mastery, not loot gear
- built around authored PvE campaign progression
- built for a buy-once Steam-first release
- locally authoritative for PvE progression

## RPG Isometrico Core Gameplay Contract

- loadout is `Race -> 1 Weapon -> 4 Skills -> 2 Potions`
- Classic campaign may teach and unlock that kit gradually
- Free campaign replay and extra modes may expose broader unlocked loadout selection
- passive system is permanently removed
- weapon swap is permanently removed
- camera is fixed isometric and non-rotating
- PvP is not a launch pillar; private duel is future or development-only direct-invite play
- no public matchmaking, ranked PvP, or dedicated server requirement exists in the current plan
- co-op is optional for Release 1 only if it preserves the solo-first campaign baseline
- Steam (PC) is the primary platform
- mobile is a future expansion, not the active primary target

## RPG Turnos Initial Contract

Treat RPG Turnos as:

- a new clean Godot project
- mechanically independent from RPG Isometrico
- allowed to share the same broader studio lore
- an RPG with free map exploration, NPC conversations, route choice, items, stats, level, and progression
- a turn-based RPG, not a real-time action RPG
- undecided between 2D, 3D, or hybrid presentation
- built from visual-agnostic systems before final camera and rendering decisions

Do not apply RPG Isometrico's action loadout, real-time combat assumptions, or mode roadmap to RPG Turnos unless RPG Turnos local docs explicitly adopt them.

## Current Transition Direction

- shared canon lives in `D:\Estudio\canon`
- active operational status lives in `D:\Estudio\Projetos\rpg-isometrico\implementation\current-status.md`
- RPG Turnos operational status lives in `D:\Estudio\Projetos\rpg-turnos\implementation\current-status.md`
- active work is organized under `D:\Estudio\Projetos\rpg-isometrico\implementation\tracks\`
- RPG Turnos work will be organized under `D:\Estudio\Projetos\rpg-turnos\implementation\tracks\`
- historical validation and cutover records live under `D:\Estudio\Projetos\rpg-isometrico\implementation\phase-g1` through `phase-g4` and `D:\Estudio\migration\`

## Shared Architecture Snapshot

Keep these boundaries clean:

- `Foundation`: shared contracts and cross-cutting base data
- `Gameplay`: reusable gameplay rules and runtime behavior
- `Presentation`: player-facing UI, camera, and feedback
- `Composition`: scene wiring, launch bootstrap, and mode assembly
- `Online`: networking, persistence, sync, and platform-service seams

Do not leak engine or vendor SDK concerns into `Gameplay`.

## Shared Mode Standard Snapshot

Every playable mode should have a clear equivalent of:

- launch context
- bootstrap
- session manager
- game loop
- simulation context
- HUD presenter
- results presenter

## When To Escalate

Use the full read order when the task may:

- change product identity
- change the loadout model
- change progression
- change shared architecture boundaries
- change platform or online assumptions
- redefine a mode's structure beyond a local engine detail

If the task is purely operational, switch from this brief into the Godot implementation hub after reading it.
