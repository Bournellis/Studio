# Track 02A - Combat Loop Expansion V1

- Last updated: `2026-06-09`
- Status: `COMPLETE`
- Project: `FpsShooter`
- Portfolio marker: `FPS_SHOOTER_TRACK_02A_PLASMA_DAMAGE_HOTFIX_COMPLETE`

## Goal

Expand the accepted rifle/bot/map/knockback baseline into a first tactical duel loop without adding ammo, reload, weapon inventory, multiplayer, export, jump pads, suspended platforms or void/fall rules.

## Delivered

- RMB `Plasma Bolt` alt-fire:
  - visible slow projectile;
  - cooldown separate from rifle;
  - stronger controlled knockback than rifle;
  - primitive glow/light mesh and synthetic shot/impact/miss feedback.
- Overcharge pickup:
  - primes the next rifle or plasma shot;
  - boosts damage and knockback modestly;
  - HUD exposes ready state.
- Health Shard pickup:
  - heals damaged combatants;
  - stays unavailable until respawn timer completes.
- HUD combat loop readability:
  - plasma cooldown state;
  - player overcharge state;
  - health/overcharge pickup availability and respawn timers;
  - pickup event messages.
- Bot tactical awareness:
  - receives arena-owned pickup state;
  - seeks health when hurt;
  - contests overcharge when appropriate;
  - receives nearest player plasma threat and blends in a dodge vector.
- Arena authority:
  - projectile collision is resolved by arena raycast;
  - pickup consumption/respawn is owned by arena;
  - damage, knockback and feedback stay centralized.

## Bot Pressure Jump Hotfix V1

- Ready normal shots now take priority over pickup routing.
- Health Shard is treated as survival/rotation when shot pressure is unavailable or health is critical.
- Existing health routes are interrupted when line of sight, range, cooldown and reaction allow a windup.
- Bot simple jump supports raised reposition goals and low blockers with a short cooldown.

## Plasma Damage Hotfix V1

- Plasma Bolt now converges from the offset visual muzzle to the player's camera/crosshair aim point.
- Player projectile collision now checks a radius-aware overlap fallback after the centerline raycast, making visible plasma contact reliable.
- Automated coverage includes overcharged Plasma Bolt hit/strong knockback plus a real `request_alt_fire()` body-edge hit from the offset muzzle.

## Validation

Automated:

- `tools/validate.gd`: PASS.
- GUT: `30/30`.
- Asserts: `253`.
- Coverage includes RMB input, Plasma Bolt spawn/hit/knockback, offset-muzzle crosshair hits, pickup heal/overcharge, bot pickup priority, bot ready-shot-over-health pressure, bot pickup-route interruption, bot jump toward raised reposition goals, bot plasma dodge awareness and all prior Track 01D combat/map/bot contracts.

Manual smoke:

- Open `Projetos/FpsShooter/project.godot` in Godot 4.6.2 and press Play.
- Confirm rifle remains readable and unchanged as baseline.
- Fire RMB Plasma Bolt and confirm visible travel, cooldown, impact/miss and stronger knockback.
- Aim RMB directly at the bot and confirm Plasma Bolt reliably causes damage/knockback, not only visual travel.
- Pick up Health Shard while damaged and confirm heal/respawn readability.
- Pick up Overcharge and confirm the next rifle/plasma shot is empowered.
- Observe bot seeking health when hurt, contesting overcharge and dodging nearby plasma.
- Confirm the bot does not abandon a ready shot just to run toward health.
- Confirm the bot can make simple jumps toward raised map pieces without constant jump spam.
- Confirm `Esc` sensitivity menu and `R` restart still work.

## Out Of Scope

- ammo/reload;
- recoil/spread tuning;
- weapon inventory;
- additional projectile variants;
- jump pads;
- suspended platforms;
- void/fall;
- multiplayer/export/backend;
- Draxos economy, progression or lore systems.
