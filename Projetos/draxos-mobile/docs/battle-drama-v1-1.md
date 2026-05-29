# DraxosMobile - Battle Drama v1.1

- Data: `2026-05-29`
- Status: `VALIDADO_LOCAL`
- Tipo: client-only visual/readability pass

## Objetivo

Battle Drama v1.1 is the follow-up to Battle Presentation v1 after Web review showed the published battle was technically updated but still read like a mock/debug arena.

The package makes the running battle visibly different in the Web app without changing backend, Supabase schema, APIs, simulator, rewards, ranking, economy, weapons, spells or `battle_log_v1`.

## Changes

- The duel stage uses stronger side lighting, clash focus, softer floor guides and less empty marker noise.
- Procedural combatants have a larger robed silhouette, staff, aura, improved barrier read and stronger flash feedback.
- The current-lance callout is wider and more legible, with the event name and player-facing effect on the first line.
- Empty status/cooldown rows no longer render dash icons that look like debug placeholders.
- Familiar and summon markers are slightly larger and keep tooltip/readout behavior.
- The compact readout now speaks in battle language: life, pressure, effects, waits and allies.
- Publication policy is updated: once a user-approved visible package needs human testing, Internal Alpha publication is the default completion step after validation.

## Non-Goals

- No new battle controls beyond existing skip.
- No realtime, timeline scrub, pause, speed control or replay archive changes.
- No asset-finalization pass.
- No backend, schema, Edge Function, Supabase migration or manifest contract changes.
- No balance, economy, content tuning, weapon or spell design changes.

## Validation Target

- GUT/client for battle stage and visual presenter behavior.
- `tools/smoke_responsive_layout.gd`.
- `validate_foundation.ps1 -Profile Client`.
- `git diff --check`.
- Internal Alpha export/package/upload/deploy after local validation.
- Published Web verification against versioned asset root and remote `index.pck`/`index.wasm` sizes.
