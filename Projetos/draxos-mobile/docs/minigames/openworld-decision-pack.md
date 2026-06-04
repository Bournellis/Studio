# Openworld Decision Pack V1

- Status: `DECISION_PACK`
- Mode id: `openworld`
- Current slice: `forest`
- Descriptor: `data/definitions/modes/openworld/metadata.json`
- Placeholder: `data/definitions/modes/openworld/placeholder.json`
- Pending design id: `DMOB-D071`

This pack records the current decision boundary for Openworld after the Bosque
playtest approval and technical hardening. It does not expand gameplay.

## Decision Summary

Openworld Bosque remains the only approved Openworld slice. The approved
technical official state is `mode_registry.status=active` on release channel
`internal_alpha`, using `openworld_forest_ruleset_v1`.

This is not a public release and does not authorize manifest rotation,
remote upload, remote migration or broader Openworld expansion.

No Openworld expansion is approved by this pack.

No backend mutation is approved remotely by this pack; the migration remains a
local implementation artifact until an explicit remote mutation window exists.

Runtime/QoL exception approved on 2026-06-01: the Bosque runtime may migrate
from a drawn `Control` world to a `Control` wrapper plus internal `Node2D`
foundation for movement feel, free joystick, PC/Web input, collision, map
borders and visual depth. This exception is local client QoL/foundation work;
it does not approve new content, economy, backend or Reward Bridge changes.

Technical hardening exception approved on 2026-06-02: the Bosque may add remote
snapshot resume, revision-gated events, session event audit, shared ruleset
definitions and server-snapshot reward authority for the existing `forest`
slice only.

## Locked For Now

- The mode identity is `openworld`, not `rpgsuave`.
- The current slice is `forest`.
- The current public entry is `open_mode_shell:openworld`.
- The current screen is `res://modes/openworld/openworld_forest_screen.gd`.
- The current ruleset is `openworld_forest_ruleset_v1`; v0 is historical only.
- Resume authority is server snapshot, with stale writes rejected.
- Offline/no-auth play remains preview-only and never creates reward.
- Future Openworld slices must start from descriptor/schema changes and a live
  design contract before runtime work.

## Runtime QoL Allowed

- `OpenworldForestScreen` remains the official `Control` screen.
- Internal `SubViewport`/`Node2D` world is allowed for the existing `forest`
  slice.
- WASD/setas, free joystick, local blockers, border walls, resource pass-through
  and depth ordering are allowed as foundation QoL.
- Server snapshot is the reward authority for collection, pocket, chest and
  craft once integrated. `OpenworldForestModel` remains preview/local runtime
  authority only.

## Not Approved

- No runtime gameplay change beyond the explicit `forest` QoL controls/collision
  exception above.
- No remote backend mutation in this package until separately approved.
- No new map.
- No enemies or combat.
- No broader RPG campaign scope.
- No new reward source or economy tuning.
- No Basebuilder ownership changes.
- No new public release/publication from this QoL package without separate
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

Two future candidates are recorded for review only. They are not approved work:

- `DMOB-D072` - Menu no mundo: a small house/altar, Bosque surroundings, small
  town or diegetic entrances for existing menu functions. The question is
  whether navigable space improves routine clarity, not whether the project
  should build a city.
- `DMOB-D073` - Conflito minimo: a later small-risk package with monsters, a few
  NPCs and simple tasks. This requires evidence from Bosque and a separate
  decision about risk, rewards, account/save boundaries and separation from
  Arena PVE.

Neither candidate authorizes combat, NPCs, quests, city, map expansion,
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
