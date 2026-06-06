# Basebuilder

- Status: `ACTIVE_CORE`
- Mode id: `basebuilder`
- Slice id: `refugio`
- Descriptor: `data/definitions/modes/basebuilder/metadata.json`
- Placeholder: `data/definitions/modes/basebuilder/placeholder.json`
- Entry action: `show_base`
- Route: `refuge`

Basebuilder is the current Refugio/Base surface. It owns structures, base
resources, base upgrade feedback and the Ossario/Base resource loop already
present in the Internal Alpha shell.

## Current Scope

- Opens through the existing Refugio/Base route.
- Uses existing Base endpoints and current account/save authority.
- Keeps current resource and structure behavior unchanged.
- Keeps `Triturar Ossos` as the Base/Ossario contribution to potion crafting.
- Does not craft potions directly; potion preparation happens at the Bosque
  Fogueira station.
- Does not depend on a player-facing Mode Hub; Refugio/Base remains the direct surface.

## Freeze For This Scaffold

- No new structures.
- No resource tuning.
- No new rewards.
- No schema or backend mutation.
- No new playable slice.

## Future Gate

Future Basebuilder work must replace the non-playable placeholder with a live
package decision, updated design contract, registry/ruleset changes and focused
validation before any new gameplay, reward or backend mutation is added.
