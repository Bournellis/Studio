# Track 09 Implementation Plan

## Summary

Track 09 corrects the presentation loop after Track 07. The first screen is no longer the Refugio. The app now has an operational `entry` screen first, and only then opens the playable `refuge` scene.

The whole client is portrait-first for now, including the autobattler.

## Tracks

| Track | Status | Work |
|---|---|---|
| T09-A Coordination / Visual Direction | `DONE` | Open Track 09 docs and record Entry vs Refugio decision. |
| T09-B Route / Orientation Foundation | `DONE` | Root `entry`, playable `refuge`, legacy aliases and portrait contract. |
| T09-C Entry Page | `DONE` | Login/create account, save/lab choice, reset/update/sync and dev labs. |
| T09-D Refugio Scene | `DONE` | Altar scene, resources/status and hotspots. |
| T09-E Internal Menus | `DONE` | Base/Social/Competition/Shop open from Refugio with Back. |
| T09-F Battle Portrait | `DONE` | Battle running and summary portrait fullscreen. |
| T09-G Visual Reference / Asset Slots | `DONE` | Visual direction and reference policy without runtime asset import. |
| T09-H Validation | `DONE` | Smokes/tests updated for portrait-first loop. |
| T09-I Integration | `DONE` | Integrated in `codex/draxos-mobile/t09-integration`. |

## Route Contract

- `entry`: root route, no Back.
- `refuge`: playable Refugio scene.
- `base_management`: management details for the current Base/Refugio systems.
- `account`, `social`, `competition`, `shop`, `battle_entry`, `battle_running`, `battle_summary`, `progression_lab`, `battle_lab`: retained as internal routes.

Legacy aliases:

- `hub`, `home`, `refuge_home`, `entrada`, `login` -> `entry`
- `refugio`, `refuge` -> `refuge`
- `base` -> `base_management`
- `battle` -> `battle_entry`
- `monetization` -> `shop`

## Portrait Contract

- Every route prefers portrait.
- `battle_running` and `battle_summary` remain fullscreen gameplay routes, but no longer prefer landscape.
- Android export orientation is portrait.
- PC/Web use the vertical frame and remain usable in larger windows.

## Validation Matrix

Quick validation:

- `tools/validate.gd`
- `tools/smoke_mobile_presentation.gd`
- `git diff --check`

Full validation:

- GUT client complete
- `tools/smoke_session_shell.gd`
- `tools/smoke_runtime_config.gd`
- `tools/smoke_foundation_hardening.gd`
- `tools/smoke_foundation_surfaces.gd`
- `tools/smoke_battle_replay.gd`
- `tools/smoke_exports.gd`

Remote/backend validation remains unchanged from Track 08 and is not expanded by this track.
