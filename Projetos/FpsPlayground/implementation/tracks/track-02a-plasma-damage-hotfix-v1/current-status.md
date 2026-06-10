# Track 02A - Plasma Damage Hotfix V1

- Last updated: `2026-06-09`
- Status: `COMPLETE`
- Project: `FpsShooter`
- Portfolio marker: `FPS_SHOOTER_TRACK_02A_PLASMA_DAMAGE_HOTFIX_COMPLETE`

## Goal

Fix the observed editor issue where RMB Plasma Bolt fired and showed presentation feedback, but did not reliably damage the bot when the player aimed directly at it.

## Delivered

- Plasma Bolt now resolves its gameplay direction by converging from the offset visual muzzle to the player's camera/crosshair aim point.
- The projectile no longer travels as a parallel offset line that can visually pass through or near the bot without matching the intended crosshair target.
- Player projectile collision keeps the centerline raycast and adds a radius-aware overlap fallback at the projectile body position.
- Overcharged Plasma Bolt still keeps stronger damage/knockback and uses the same corrected aim/collision path.
- Tests cover:
  - overcharged Plasma Bolt damage and strong knockback;
  - real `request_alt_fire()` from the player signal path;
  - body-edge/crosshair hit from an offset muzzle;
  - no regression to existing rifle, pickup, bot, knockback and map contracts.

## Validation

Automated:

- `tools/validate.gd`: PASS.
- GUT: `30/30`.
- Asserts: `253`.
- `git diff --check`: pending final merge validation.

Manual smoke:

- Open `Projetos/FpsShooter/project.godot` in Godot 4.6.2 and press Play.
- Aim RMB directly at the bot and confirm Plasma Bolt reliably causes damage and stronger knockback.
- Confirm the projectile still starts from the offset muzzle position and does not occupy the full screen.
- Confirm misses still show visual feedback without false hitmarker.
- Confirm rifle, pickups, overcharge, bot pressure/jump behavior, `Esc` menu and `R` restart still work.

## Out Of Scope

- new weapons;
- reload/ammo;
- new projectile variants;
- map redesign;
- jump pads, suspended platforms or void/fall rules;
- bot AI expansion beyond preserving existing behavior.
