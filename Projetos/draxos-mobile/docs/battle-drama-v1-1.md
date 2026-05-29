# DraxosMobile - Battle Drama v1.1

- Data: `2026-05-29`
- Status: `PUBLICADO_INTERNAL_ALPHA`
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

## Publication

- Release root: `internal-alpha/v0-battle-drama-v1-1-20260529`
- Verified public preview: `https://7261c476.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Versioned Web asset root: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-drama-v1-1-20260529/web`
- Web `GODOT_CONFIG.fileSizes.index.pck`: `4230188`, matching remote `index.pck` `Content-Length`.
- Android APK: `31637525` bytes, SHA256 `30c7b8c90af00221de57e63d2434c80a774ebfe888e8cc6c6119228a23c1f50d`.
- PC ZIP: `40103282` bytes, SHA256 `921795a9a3d3ffa96a41e77d39cfb1b3bee0773d42deed87bdf34d8506b8c93c`.
- Cloudflare stable domain was redeployed, but public unauthenticated reads still hit Cloudflare Access; use the verified preview or an authenticated Access session for Web review.
- Edge release manifest override was blocked because `SUPABASE_ACCESS_TOKEN` was not available in the local release environment.

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
