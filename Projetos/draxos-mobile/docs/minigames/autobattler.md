# Autobattler

- Status: `ACTIVE_CORE`
- Mode id: `autobattler`
- Slice id: `pve_arena`
- Descriptor: `data/definitions/modes/autobattler/metadata.json`
- Placeholder: `data/definitions/modes/autobattler/placeholder.json`
- Entry action: `open_arena`
- Route: `arena_selection`

Autobattler is the current Arena PVE loop. It owns locked loadout, the
server-authoritative duel flow, temporary Arena buffs and the existing Arena
reward path.

## Current Scope

- Opens through the existing Arena PVE selection route.
- Uses existing `arena/pve/*` endpoints.
- Keeps current Arena PVE reward and progress behavior unchanged.
- Uses the current one-potion preparation slot; `pocao_vida`, `pocao_foco` and
  `pocao_resguardo` are the approved simple consumables.
- Does not depend on a player-facing Mode Hub; Arena PVE remains the direct surface.
- Preparacao lives inside Arena PVE below `Iniciar Arena PVE`, not as a main Refugio menu entry.

## Freeze For This Scaffold

- No numeric tuning.
- No new enemies, spells, weapons, additional potions or behavior controls.
- No reward formula change.
- No replay or combat presentation expansion.
- No backend or schema mutation.

## Future Gate

Future Autobattler work must wait for explicit package direction. Bosque
Persistent Overlay Shell v1 is the current published Internal Alpha package,
and the next operational step is focused human playtest of that overlay package.
Future bugs return to the normal bugfix flow if they appear.
Arena PVE remains the first product core, but tuning, new enemies, PVP,
economy, content, visual-final work or remote mutations require an explicit
next-package decision.
