# Track 06A - Avatar Visual Foundation V1

- Last updated: `2026-06-10`
- Status: `COMPLETE`
- Target status marker: `FPS_PLAYGROUND_TRACK_06A_AVATAR_VISUAL_FOUNDATION_COMPLETE`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--track06a-avatar-visual-foundation-v1`
- Branch: `codex/fpsshooter/track06a-avatar-visual-foundation-v1`

## Goal

Create the first visual avatar foundation for `FPS Playground`, focused on the `Futebol` mode: procedural humanoid characters, selectable skin tone and country-inspired shirt kit, and basic animation states that help the 1x1 football match read as a character duel instead of only capsules and a ball.

## Confirmed Direction

- First-person football remains the active mode for this track.
- Player and bot are visible as primitive low-poly humanoids.
- The player can select skin tone and shirt/country kit before starting the match.
- Visual theme is festive World Cup-inspired, without official logos, crests, sponsors or licensed shirt replicas.
- No imported final assets in this track.
- No persistence, export, multiplayer or backend.

## Planned Deliverables

- `docs/avatar-visual-contract.md`.
- Runtime avatar appearance catalog and data object.
- Procedural `PlayerAvatar3D` with primitive body parts and unique materials.
- Basic procedural animation states: idle, move, jump, fall, kick, strong kick, celebrate and hit.
- Futebol integration for player and bot avatars.
- Intro panel controls for skin tone and kit selection.
- Automated tests for catalog, avatar construction, material updates, mode integration and key animation events.

## Delivered

- Added `gameplay/avatar/avatar_appearance.gd`.
- Added `gameplay/avatar/avatar_catalog.gd`.
- Added `gameplay/avatar/player_avatar_3d.gd`.
- Integrated local first-person player avatar and visible bot avatar into `Futebol`.
- Added paused-intro controls for skin tone and country-inspired shirt kit selection.
- Added Brazil, Argentina, France, Japan, Portugal and Germany-inspired kit colors.
- Added light, tan, brown and dark skin tone options.
- Added procedural states for idle, move, jump, fall, kick, strong kick, celebrate and hit.
- Added automated unit/integration coverage for avatar catalog, runtime parts, material updates, Futebol scene integration, selection cycling and football event animation.

## Validation Plan

- `tools/validate.gd -- --profile=structure` after documentation and resource registration.
- `tools/validate.gd -- --profile=quick` after code integration.
- final `tools/validate.gd -- --profile=full`.
- `git diff --check` before each commit.

## Acceptance

- Futebol scene still boots paused with `Como Jogar` and `Comecar`: done.
- Player and bot avatars exist in the runtime scene: done.
- Player avatar does not block first-person camera visibility by hiding local head/neck: done.
- Selection controls change skin tone and kit while the intro is open: done.
- Kicks and goals produce visible avatar animation state changes: done.
- All visuals are generated at runtime from primitive meshes/materials: done.
- Existing Arena Shooter behavior remains preserved by the full regression suite: done.

## Validation Snapshot

- `tools/validate.gd -- --profile=quick`: passed with `57/57` tests and `444` asserts during implementation.
- `tools/validate.gd -- --profile=full`: passed with `57/57` tests and `444` asserts before merge closeout.
