# Track 02A - Bot Pressure Jump Hotfix V1

- Last updated: `2026-06-09`
- Status: `COMPLETE`
- Project: `FpsShooter`
- Portfolio marker: `FPS_SHOOTER_TRACK_02A_BOT_PRESSURE_JUMP_HOTFIX_COMPLETE`

## Goal

Close the first Track 02A smoke issue: the bot was overvaluing Health Shard routes and could not jump, which reduced duel pressure and made early vertical map pieces less useful.

## Delivered

- Ready normal shots now take priority over Health Shard and Overcharge pickup routes.
- Health Shard remains useful, but as survival/rotation when the bot is hurt, under cooldown/reaction lockout, out of pressure range or critically low.
- Active health routes are interrupted as soon as the bot has line of sight, range, cooldown and reaction ready for windup.
- Overcharge contest remains situational and does not steal clear shot windows.
- Bot has simple jump behavior with cooldown for raised reposition goals and low navigation blockers.
- Jump uses a short ground-contact probe so it works reliably after floor contact timing changes without allowing free midair spam.

## Validation

Automated:

- `tools/validate.gd`: PASS.
- GUT: `29/29`.
- Asserts: `249`.
- Coverage adds ready-shot-over-health priority, interruption of health route when the shot becomes ready and jump toward a raised reposition goal.

Manual smoke:

- Open `Projetos/FpsShooter/project.godot` in Godot 4.6.2 and press Play.
- Damage the bot and confirm it still uses Health Shard only when it cannot immediately pressure with a valid shot.
- Stay exposed and confirm the bot starts tell/shot instead of running away to health.
- Watch the bot on ramps/platform approaches and confirm it can make simple jumps without constant jump spam.

## Out Of Scope

- `NavigationAgent3D`;
- jump pads;
- suspended platforms;
- void/fall;
- arena redesign;
- broad bot difficulty tuning;
- new weapons, ammo/reload or recoil/spread.
