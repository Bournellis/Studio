# T05-E - Asset Pipeline Notes

- Date: `2026-05-27`
- Branch: `codex/draxos-mobile/t05-asset-pipeline`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t05-asset-pipeline`
- Status: `READY_FOR_INTEGRATION`

## Scope

Prepare DraxosMobile to accept real art later without importing final assets in
Track 05.

This package intentionally does not replace the procedural battle visuals,
native Godot UI placeholders or any gameplay behavior.

## Delivered Foundation

- `assets/README.md` defines folder, naming, format, target-size, Godot import,
  fallback and id-stability conventions.
- `core/asset_ids.gd` keeps all current paths stable and adds category helpers
  for `ui`, `portraits`, `battle_characters`, `battle_icons` and `battle_fx`.
- `tests/client/test_content_foundation.gd` should verify registered ids,
  categories, stable paths and the missing-art fallback contract.

## Stable Current Paths

| Category | Id | Path |
|---|---|---|
| `ui` | `ui_logo` | `res://assets/ui/ui_logo.png` |
| `ui` | `boot_background` | `res://assets/ui/boot_background.png` |
| `ui` | `icon_guest` | `res://assets/ui/icon_guest.png` |
| `ui` | `icon_battle` | `res://assets/ui/icon_battle.png` |
| `ui` | `icon_result` | `res://assets/ui/icon_result.png` |
| `ui` | `placeholder_card` | `res://assets/ui/placeholder_card.png` |
| `portraits` | `portrait_draxos_mage` | `res://assets/portraits/portrait_draxos_mage.png` |
| `portraits` | `portrait_training_bot` | `res://assets/portraits/portrait_training_bot.png` |
| `battle_characters` | `battle_character_player` | `res://assets/battle/characters/player_draxos.png` |
| `battle_characters` | `battle_character_opponent` | `res://assets/battle/characters/opponent_placeholder.png` |
| `battle_icons` | `battle_icon_event` | `res://assets/battle/icons/event.png` |
| `battle_icons` | `battle_icon_weapon` | `res://assets/battle/icons/weapon.png` |
| `battle_icons` | `battle_icon_spell` | `res://assets/battle/icons/spell.png` |
| `battle_icons` | `battle_icon_status` | `res://assets/battle/icons/status.png` |
| `battle_icons` | `battle_icon_buff` | `res://assets/battle/icons/buff.png` |
| `battle_icons` | `battle_icon_damage` | `res://assets/battle/icons/damage.png` |
| `battle_icons` | `battle_icon_summon` | `res://assets/battle/icons/summon.png` |
| `battle_icons` | `battle_icon_pet` | `res://assets/battle/icons/familiar.png` |
| `battle_icons` | `battle_icon_heal` | `res://assets/battle/icons/heal.png` |
| `battle_icons` | `battle_icon_reward` | `res://assets/battle/icons/reward.png` |
| `battle_icons` | `battle_icon_result` | `res://assets/battle/icons/result.png` |
| `battle_fx` | `battle_fx_hit` | `res://assets/battle/fx/hit.png` |
| `battle_fx` | `battle_fx_spell` | `res://assets/battle/fx/spell.png` |
| `battle_fx` | `battle_fx_buff` | `res://assets/battle/fx/buff.png` |

## Handoff Notes

- Real art work should start by choosing a small asset package and adding files
  at the stable paths above.
- Any future path rename should be treated as a migration, not a cleanup.
- Keep fallback behavior mandatory for headless validation, debug builds and
  partially imported art packages.
- T05-H should integrate this package after checking for parallel changes to
  `core/asset_ids.gd` or `tests/client/test_content_foundation.gd`.

## Validation

- Pass: `tools/validate.gd`.
- Pass: GUT client.
- Pass: `tools/smoke_exports.gd`.
- Pass: `git diff --check`.
