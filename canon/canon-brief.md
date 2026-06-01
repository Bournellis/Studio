# Canon Brief

This file is the token-efficient entry point for bounded work across the Godot-first workspace.

It summarizes the shared canon, but it does not replace the full read order in `README.md` and `D:\Estudio\AGENTS.md`.

## Shared Snapshot

Current project map:

- `Projetos/draxos-roguelike-cardgame/`: P0 implementation project, menu-first Draxos roguelike cardgame for Steam/PC, governed by its local docs.
- `Projetos/draxos-mobile/`: P2 implementation project, mobile/PC/browser Draxos PVE Arena-first async autobattler with Refugio/Base, later PVP/social, Supabase backend, and server-authoritative progression.
- `Projetos/_conceitos/mobile-universe/`: read-only design archive promoted into `Projetos/draxos-mobile/` on 2026-05-18.
- `Projetos/rpg-isometrico/`: paused campaign-first isometric action RPG, preserved for historical/contextual consultation.
- `Projetos/rpg-turnos/`: paused provisional turn-based RPG-cardgame, preserved for historical/contextual consultation.

Shared lore snapshot:

- the universe is a distant future where humanity has left the Solar System and spread across the galaxy
- Earth is post-nuclear-apocalypse and humans are split into factions
- other celestial/intergalactic beings are part of the main continuity
- Draxos are arcane intergalactic beings of unclear origin who use astral energy for power, conquest, travel, and infrastructure
- Draxos commonly dominate and enslave beings they consider inferior
- Draxos bases may resemble spacecraft but are plasmated from ether, not built as conventional technology
- Imortais is the player-facing name replacing the old `Heroic` / `Heroico` placeholder; detailed lore is pending
- RPG Isometrico currently uses Imortais as the safe label for the direct-combat baseline while its detailed campaign lore remains TBD
- RPG Turnos initially covers a Draxos mission that can succeed: invasion of an elemental planet, enslavement of elementals, and extraction of a powerful volcano crystal

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

## DraxosMobile Initial Contract

Treat DraxosMobile as:

- an implementation project, not a concept archive
- a multi-platform mobile-first product targeting Android native app, PC executable, and PC browser in the first slice
- a shared-account ecosystem around one Draxos mage, Refugio/Base management, PVE Arena-first async autobattler progression, later PVP/social systems, and shared account progression
- server-authoritative: Godot never simulates battle results or mutates resources directly
- uses a conservative local reuse map for Godot tooling and content infrastructure; gameplay from other projects is not inherited
- backed by Supabase Auth, Postgres, Edge Functions, and eventually Realtime
- scoped for Track 00 as MVP technical foundation first, then first slice systems

Local long-term product authority lives in `Projetos/draxos-mobile/docs/product-vision.md`. Use that document for DraxosMobile pillars, anti-pillars, monetization limits, platform boundaries, live ops direction and future-not-promised items until specific parts are promoted into shared canon. The current operational baseline is Foundation Hardening V2, published as Internal Alpha at `internal-alpha/v0-foundation-hardening-v2-hotfix1-20260601-f8ff795` with preview `https://4315dd54.draxos-mobile-internal-alpha.pages.dev`; Hardening Platform V1 remains the previous mode-platform baseline, and Track 21 remains preserved Arena PVE/Autobattler context, not the platform baseline.

Do not import rules from Draxos Roguelike Cardgame, RPG Turnos, or RPG Isometrico unless DraxosMobile local docs explicitly adopt them in `Projetos/draxos-mobile/docs/reuse-map.md` and the affected local contract.

## RPG Turnos Initial Contract

Treat RPG Turnos as:

- a new clean Godot project
- mechanically independent from RPG Isometrico
- allowed to share the same broader studio lore
- an RPG with free map exploration, NPC conversations, route choice, items, stats, level, and progression
- a turn-based RPG-cardgame, not a real-time action RPG
- a combat system built around fixed board slots, cards, hero abilities, encounter objectives, and confrontation lanes
- initially focused on a Draxos novice mage assigned to a respected strike team after that team lost a soldier
- narratively centered on missions from an ether-plasm Draxos base into an elemental planet rich in astral energy
- undecided between 2D, 3D, or hybrid presentation
- built from visual-agnostic systems before final camera and rendering decisions

Do not apply RPG Isometrico's action loadout, real-time combat assumptions, or mode roadmap to RPG Turnos unless RPG Turnos local docs explicitly adopt them.

Treat existing RPG Turnos mechanical IDs as stable placeholders unless a dedicated migration explicitly renames them.

## Current Transition Direction

- shared canon lives in `D:\Estudio\canon`
- portfolio source of truth lives in `D:\Estudio\08_Coordenacao_Agentes\Prioridades_Estudio.md`
- Draxos Roguelike Cardgame operational status lives in `D:\Estudio\Projetos\draxos-roguelike-cardgame\implementation\current-status.md`
- DraxosMobile operational status lives in `D:\Estudio\Projetos\draxos-mobile\implementation\current-status.md`
- DraxosMobile current platform baseline is `FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA`: release root `internal-alpha/v0-foundation-hardening-v2-hotfix1-20260601-f8ff795`, preview `https://4315dd54.draxos-mobile-internal-alpha.pages.dev`.
- DraxosMobile new work should branch from updated `master` after the Foundation Hardening V2 integration and follow `D:\Estudio\Projetos\draxos-mobile\docs\multi-agent-workflow.md`; Hardening Platform V1 is preserved as the previous mode-platform baseline. Track 21, Track 20 and Remote Lab Runner are preserved Arena/Autobattler/Lab contexts, while Track 13 release safety and Track 14 agent ops remain compatibility baselines.
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
