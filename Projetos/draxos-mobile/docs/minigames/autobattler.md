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

Future Autobattler work must wait for the Arena proof gate recorded in
`../arena-pve-product-proof.md` and the operational state in
`../../implementation/current-status.md`.

The active product question is whether Arena PVE is understandable and
recoverable enough for a human tester without agent explanation. Until that
verdict exits `ARENA_CORE_NEEDS_UX_FIX` / `ARENA_CORE_NOT_PROVEN`, Autobattler
work is limited to UX/readability/recovery fixes for the Arena path and normal
bugfixes.

Arena PVE remains the first product core, but numeric tuning, new enemies, PVP,
economy, content expansion, visual-final work, broad Openworld work or remote
mutations require an explicit next-package decision.
