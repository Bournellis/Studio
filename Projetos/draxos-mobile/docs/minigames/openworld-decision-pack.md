# Openworld Decision Pack V1

- Status: `DECISION_PACK`
- Mode id: `openworld`
- Current slice: `forest`
- Descriptor: `data/definitions/modes/openworld/metadata.json`
- Placeholder: `data/definitions/modes/openworld/placeholder.json`
- Pending design id: `DMOB-D071`

This pack records the current decision boundary for Openworld after the Bosque
playtest approval, technical hardening, Offline-First Checkpoint v1 release,
Bosque Persistence Rebase v1, Bosque Bootstrap Authority v1 and Bosque
Diegetic Launcher Foundation v1. The launcher foundation was implemented as a
local hardening step and later published by DMOB-D077 as the current Internal
Alpha package. It remains a narrow menu-entry layer for existing player-facing
menus and does not expand Openworld gameplay.

## Decision Summary

Openworld Bosque remains the only approved Openworld slice. The approved
technical official state is `mode_registry.status=active` on release channel
`internal_alpha`, using `openworld_forest_ruleset_v1`.

The current Internal Alpha publication is not approval for broader Openworld
expansion. Published package evidence is recorded as release evidence, not as
permission for new content.

No Openworld expansion is approved by this pack.

Bosque Offline-First Checkpoint v1 was explicitly approved and published as a
remote Internal Alpha mutation window: migration
`202606060001_openworld_bosque_checkpoint_v1.sql`, release root
`internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22`,
preview evidence `https://fa84e109.draxos-mobile-internal-alpha.pages.dev`.

Runtime/QoL exception approved on 2026-06-01: the Bosque runtime may migrate
from a drawn `Control` world to a `Control` wrapper plus internal `Node2D`
foundation for movement feel, free joystick, PC/Web input, collision, map
borders and visual depth. This exception is local client QoL/foundation work;
it does not approve new content, economy, backend or Reward Bridge changes.

Technical hardening exception approved on 2026-06-02: the Bosque may add remote
snapshot resume, revision-gated events, session event audit, shared ruleset
definitions and server-snapshot reward authority for the existing `forest`
slice only.

Authority exception approved on 2026-06-06: the Bosque active runtime is
client-owned for movement, collection, pocket, chest, craft, guidance and
position. The server owns session/ruleset, accepted checkpoints, completion,
reward, caps, ledger and audit. Same-session remote snapshots must not transform
the world during active player control.

Human playtest confirmation on 2026-06-06: the first Bosque Offline-First
Checkpoint v1 checks reported that the update felt successful and the visible
Bosque flow was healthy. This confirms the authority policy as the current
Openworld working rule. It does not approve new content expansion by itself.

Durable Bosque progress exception approved on 2026-06-06: `Bau`,
`Mochila/Bolso`, backpack capacity upgrades and crafted structures are durable
per save. Nodes collected, active collection, position and pending checkpoint
remain visit state. Reward remains server-authoritative through accepted
checkpoint, caps and ledger.

Station craft exception approved on 2026-06-06: `Fogueira Estavel I` is a
durable Bosque structure and the first approved Openworld station. It may create
global account consumables only through `POST /crafting/station-craft`, after an
accepted Bosque checkpoint, while consuming materials from durable `Bau` and
global `po_osso`. This exception approves only the three simple potion recipes
listed in `docs/behavior-potion-crafting-v1.md`.

Persistence rebase exception approved on 2026-06-08: Openworld/Bosque abandons
`full spawn reset per visit` as the primary persistence model. Durable progress
is server-authoritative through idempotent checkpoint operations with ACK +
retry. Nodes use per-item cooldown persisted in `node_state.next_spawn_at`.
Local caches may support preview and retry, but cannot declare progress saved
before the server ACK.

Feel/spawn authority exception approved on 2026-06-08: Openworld/Bosque keeps
server-authoritative durable progress, but active player feel is protected from
same-session ACK/resync rollback. Collection progress is sticky while the
player remains inside the cancel radius, movement alone does not restart the
bar, pending collect ops hide their node locally until ACK/failure, v2 respawn
uses `node_state.next_spawn_at` plus `server_time` offset instead of legacy
`collected_nodes`, and menu busy state is scoped so unrelated server requests
do not freeze navigation or independent actions.

Diegetic launcher exception approved on 2026-06-09: the Bosque may act as a
local diegetic launcher for existing player-facing menus. V1 is limited to a
versioned local catalog, procedural non-blocking landmarks, one proximity
prompt, tap/click interaction, shell action routing and return-to-Bosque stack
behavior. Approved V1 entries are Arena PVE, Refugio/Base, Loja, Social and
Perfil. Towerdefense, Cardgame and dev tools remain outside the catalog.

## Openworld Working Policy

The current Openworld policy is:

- player feel and active control are protected over microaction precision;
- the Bosque visit is client-owned for movement and visual preview during play;
- server authority is reserved for session validity, ruleset identity, durable
  Bosque progress, node cooldown, station crafts that create global account
  items, caps, accepted checkpoint, completion, reward, ledger and audit;
- `Bau`, `Mochila/Bolso`, upgrades, crafted structures, guidance and
  `node_state` persist per save;
- position and active collection are visit state;
- checkpoint operations with ACK are the normal integrated path;
- pending operations may have local preview, but ACK/resync cannot rebootstrap
  the active same-session world or restart collection;
- node respawn visuals use server-time-adjusted `node_state`; legacy
  `collected_nodes` is compatibility only when `node_state` is absent;
- menu/server busy state is scoped by action domain instead of freezing every
  independent action globally;
- Bosque may expose existing player-facing menus as diegetic launcher landmarks,
  but only through app-shell actions and route history;
- event micro-mutators are compatibility only for old packages;
- `station-craft` is not a microaction sync path; it is a deliberate
  server-authoritative bridge for global consumables;
- snapshots can initialize or recover a visit before control, but cannot roll
  back the active same-session world;
- conflicts are handled as explicit recovery outside active control.
- local durable cache is visual/retry only and never beats the server after
  online login.

Future agents must not reintroduce revision-gated microaction sync as the normal
Openworld loop without a new decision pack update and user-approved package.
This includes movement heartbeats, collect start/cancel/complete, deposit and
craft events as the main path for the new client.

## Locked For Now

- The mode identity is `openworld`, not `rpgsuave`.
- The current slice is `forest`.
- The current public entry is `open_mode_shell:openworld`.
- The current screen is `res://modes/openworld/openworld_forest_screen.gd`.
- The current ruleset is `openworld_forest_ruleset_v1`; v0 is historical only.
- Resume authority is stable bootstrap/recovery before control; active runtime
  uses local preview plus checkpoint operation confirmation.
- Durable Bosque progress is per-save: `Bau`, `Mochila/Bolso`, capacity upgrades
  crafted structures, guidance and `node_state` survive exit, completion,
  expiry and new entry.
- Nodes do not reset only because a visit changed; each node follows
  `next_spawn_at` cooldown.
- Movement inside the collection cancel radius does not restart collection.
- Same-session ACK/resync may confirm durable progress, but cannot blink nodes,
  restart active collection or block unrelated menu actions.
- Diegetic launcher V1 is locked to local catalog
  `data/definitions/openworld/forest_launcher_v1.json`.
- Approved launcher entries are `arena_pve_gate`, `refugio_workbench`,
  `shop_stall`, `social_totem` and `profile_shrine`.
- Launcher actions are `open_arena`, `show_base`, `show_shop`, `show_social`
  and `show_account`; the Bosque must emit shell action requests, not call
  Boot/Supabase/backend directly.
- `Fogueira Estavel I` is the only approved Openworld station in V1.
- Approved station recipes are `craft_pocao_vida`, `craft_pocao_foco` and
  `craft_pocao_resguardo`.
- Offline/no-auth play remains preview-only and never creates reward.
- Future Openworld slices must start from descriptor/schema changes and a live
  design contract before runtime work.

## Runtime QoL Allowed

- `OpenworldForestScreen` remains the official `Control` screen.
- Internal `SubViewport`/`Node2D` world is allowed for the existing `forest`
  slice.
- WASD/setas, free joystick, local blockers, border walls, resource pass-through
  and depth ordering are allowed as foundation QoL.
- Checkpoint validation is the persistence and reward authority for collection,
  pocket, chest and craft once integrated. `OpenworldForestModel` and the
  checkpoint bridge are runtime authority during the visit; durable progress,
  completion/reward and ledger remain server-authoritative.
- Procedural non-blocking landmarks, one nearest prompt and tap/click launcher
  interaction are allowed for the five V1 menu entries.

## Not Approved

- No runtime gameplay change beyond the explicit `forest` QoL controls/collision
  exception above.
- No backend mutation beyond checkpoint/durable progress and the approved
  Fogueira station craft bridge without separate approval.
- No new map.
- No enemies or combat.
- No broader RPG campaign scope.
- No new reward source or economy tuning.
- No embedded menu implementation inside the Bosque.
- No Towerdefense, Cardgame or dev-tool launcher entries in V1.
- No Basebuilder ownership changes.
- No conversion of persistent Bosque storage into global account inventory
  beyond the approved Fogueira potion recipes without a separate Reward Bridge
  decision.
- No further public release/publication from this QoL package without separate
  approval.

## Decision Questions Before Expansion

1. What is the map model: single instanced area, connected zones or continuous
   world?
2. What is the risk model: timed run, stamina, hazards, enemies, extraction or
   pure exploration?
3. Does Openworld progression stay local to the mode or feed shared account/save
   progression?
4. Which resources can leave Openworld through Reward Bridge, and what caps
   prevent farming loops?
5. Where is the boundary between Openworld collection/crafting and Basebuilder
   structures/crafting?
6. Which telemetry events prove the slice is useful before adding combat?
7. How does disable/rollback preserve already-started sessions?

`DMOB-D071` remains open for any continuous-world expansion. The Bosque approval
resolves only the existing slice's readiness as an active Internal Alpha mode.

## Future Candidate Packages

Two future candidates are recorded for review context:

- `DMOB-D072` - Menu no mundo: resolved on 2026-06-09 as
  `Bosque Diegetic Launcher Foundation v1`, limited to diegetic entrances for
  existing menu functions. This does not approve a small town, city, NPCs,
  quests, economy, reward source or broad Openworld expansion.
- `DMOB-D073` - Conflito minimo: a later small-risk package with monsters, a few
  NPCs and simple tasks. This requires evidence from Bosque and a separate
  decision about risk, rewards, account/save boundaries and separation from
  Arena PVE.

No future candidate authorizes combat, NPCs, quests, city, map expansion,
economy, reward source, PVP/social expansion, remote publication or runtime work
without its own Doing/Handoff and validation plan.

## Required Evidence For A Future Package

- Updated `docs/minigames/openworld.md`.
- Updated descriptor and placeholder, validated by
  `tools/validate_mode_definitions.ps1`.
- Ruleset/registry/rate policy update.
- Reward Bridge review if any shared resource leaves the mode.
- Mode session disable/rollback coverage.
- Mobile portrait smoke and ModePlatform validation.
- Human approval recorded in Doing/Handoff.
