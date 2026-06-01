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
- Appears as a public CTA in the Mode Hub.

## Freeze For This Scaffold

- No numeric tuning.
- No new enemies, spells, weapons, potions or behavior controls.
- No reward formula change.
- No replay or combat presentation expansion.
- No backend or schema mutation.

## Future Gate

Future Autobattler work must wait for explicit package direction. The immediate
product next step remains human playtest of the published Arena PVE sequence
before tuning or expansion.
