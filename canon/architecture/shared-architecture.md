# Shared Architecture

## 1. Purpose

This document defines the engine-neutral software architecture of RPG Isometrico.

It is the canonical reference for:

- shared module boundaries
- gameplay and loadout contracts
- session and authority model
- persistence boundaries
- platform-service seams

Engine-specific implementation details belong in local project docs, not here.

---

## 2. Shared Boundaries

The project uses these architecture boundaries across implementations:

- `Foundation`: identifiers, contracts, snapshots, results, domain-neutral helpers, and shared base data
- `Gameplay`: combat rules, loadout rules, mode rules, enemies, bosses, progression eligibility, and reusable runtime rules
- `Presentation`: HUD, camera, input adaptation, UX flow, combat feedback, and player-facing state presentation
- `Composition`: bootstraps, scene wiring, launch contexts, session assembly, and mode entry seams
- `Online`: networking, persistence, profile sync seams, cloud integrations, and platform-service adapters

Rules:

- `Gameplay` must not depend on UI or vendor SDKs
- `Presentation` must not decide gameplay rules
- `Online` must not own combat or mode logic
- `Composition` may wire systems together, but must not become a generic manager layer

---

## 3. Runtime Model

The game supports multiple modes built on shared combat and loadout foundations:

- Campaign
- Survival
- Boss Mode
- Arena Bot
- future optional co-op campaign
- future or development-only Private Duel

Shared runtime principles:

- fixed isometric camera
- kit/loadout state locked at match or mission start
- mode-specific bootstraps built on shared contracts instead of duplicated rules
- reusable player runtime rules across solo and future online modes whenever behavior is intended to match

---

## 4. Loadout Contract

The canonical player loadout is:

`Race -> 1 Weapon -> 4 Skills -> 2 Potions`

Rules:

- race defines the content pool and identity
- one weapon is equipped per match or mission
- the weapon owns the basic attack and movement skill
- four skills are selected pre-match and activated or upgraded in-match
- two potions are selected pre-match
- passive slots do not exist
- weapon swap does not exist

Classic campaign routes may expose this contract through authored progression, tutorial beats, and permanent unlocks before the full free-selection surface is available. Free campaign replay and extra modes may expose broader unlocked kit selection directly.

Any legacy seam that still mentions passives or a second weapon is historical compatibility, not current canon.

---

## 5. Session And Authority Model

Current shared assumptions:

- solo runs fully local
- PvE progression is locally authoritative
- optional co-op may use host authority without dedicated servers
- Private Duel, if promoted later, is casual direct-invite play and may use host authority under that framing
- platform networking backends must stay behind the `Online` boundary

Out of scope unless shared canon changes:

- dedicated servers as a current requirement
- public matchmaking
- ranked competitive authority guarantees
- host migration
- mid-session reconnect
- server-authoritative PvE progression

---

## 6. Persistence And Data Boundaries

Canonical sources of truth:

- authored content definitions and engine-native resources/assets
- local save files for unlock state, mastery, settings, and saved loadouts
- Steam Cloud as an optional sync layer
- Steam Leaderboards for published result submissions

Rules:

- PvE progression must not depend on an always-online backend
- gameplay must not block waiting for cloud or leaderboard calls
- result submission happens only at natural result boundaries

---

## 7. Cross-Engine Rule

The shared canon defines what the game is.

Each engine-specific project defines how that canon is implemented locally, so long as it preserves:

- the shared boundaries above
- the loadout contract
- the authority model
- the persistence model
- the fixed isometric combat identity

If a local engine convenience conflicts with shared canon, the engine-local design must change or the canon must be explicitly revised.
