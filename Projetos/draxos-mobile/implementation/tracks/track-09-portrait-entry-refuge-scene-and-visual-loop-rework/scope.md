# Track 09 - Portrait Entry, Refugio Scene And Visual Loop Rework

## Objective

Correct the post-Track 07 presentation model by separating the operational app entry from the playable Refugio scene, and move the whole client to a portrait-first loop for the next implementation phase.

The app must open in `entry`, where the player handles account/login, save selection/reset and dev labs. After that, `refuge` becomes the playable home: a vertical altar scene with resources and visual hotspots for Battle, Base management, Social, Competition, Shop and Profile.

## In Scope

- Route contract update:
  - `entry` is the root route.
  - `refuge` is the playable home scene.
  - `base_management` contains the old Base management content.
  - legacy aliases stay safe during migration.
- Fixed portrait orientation:
  - Android exports use portrait.
  - PC/Web use a vertical frame inside larger windows.
  - Battle running and battle summary are portrait fullscreen.
- Entry screen:
  - Login/create account controls.
  - Normal/Lab save selection before entering the Refugio.
  - Secondary reset/sync/update actions.
  - Dev labs visible only when enabled.
- Refugio scene:
  - Altar-focused scene.
  - Resources/status top bar.
  - Hotspots for Battle, Base, Social, Competition, Shop and Profile.
  - Internal screens retain Back navigation.
- Validation:
  - Update presentation and foundation smokes to portrait-first expectations.

## Out Of Scope

- Backend endpoints, schema and migrations.
- Tuning economy, power, rewards, bots, shop or combat.
- Final art import.
- Publication, secrets, payments, iOS and mobile browser as primary target.
- Text-editing `.tscn` files.

## Acceptance Criteria

- The app starts on `entry`, not Refugio/Base.
- `Entrar no Refugio` opens the playable `refuge` scene only after a valid local/remote state.
- `refuge` is an immersive scene with altar and hotspots, not a global tab/list shell.
- Base/Social/Competition/Shop still use existing actions and data contracts.
- Battle running and summary render fullscreen portrait.
- Legacy routes remain safe during migration.
- `assets/referenciaimagens/` remains moodboard/reference only.
