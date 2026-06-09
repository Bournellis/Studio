# FpsShooter - Current Status

- Last updated: `2026-06-09`
- Project: `FpsShooter`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first FPS 3D tech probe`
- Active stage: `Track 02A - Bot Pressure Jump Hotfix V1`
- Active stage status: `COMPLETE`

## Current Truth

`FpsShooter` is an official implementable Godot project for testing first-person 3D shooter fundamentals in the studio.

The project is a tech probe independent from Draxos Roguelike Cardgame, DraxosMobile, RPG Isometrico and RPG Turnos. It may use a light Draxos visual theme, but no other project gameplay system is inherited.

## Current Scope

- PC Windows editor-first.
- Traditional FPS baseline.
- Local 1x1 arena against a bot.
- Player movement, mouse look, jump, hitscan shot and combat-readable knockback.
- Secondary `Plasma Bolt` alt-fire on RMB with visible slow projectile, stronger knockback and cooldown.
- Runtime pickups: health shard and overcharge.
- Fair bot baseline with vertical-aware line of sight.
- Bot tactical awareness for health pickup, overcharge contest and visible plasma dodge.
- Bot pressure tuning: ready shots interrupt pickup routes and health pickup is a survival/rotation choice instead of the default concern.
- Bot simple jump support for raised reposition goals and low navigation blockers.
- `Duel Pit V1` arena layout with protected spawns, low/high cover, side platforms and ramps.
- HUD, round state and bidirectional feel/feedback.
- No export, Web, mobile, multiplayer or online/backend scope.

## Active Goal

`Track 02A - Bot Pressure Jump Hotfix V1` is complete. The expanded duel loop remains the accepted baseline, now with the bot preserving shot pressure over pickup routes and gaining first simple jump behavior for the current ramps/platform setup.

## Current Gate

Closed for the Track 02A hotfix. Run the 5-minute editor smoke focused on rifle vs Plasma Bolt choice, pickup readability, overcharge clarity, bot shot pressure before health routes, bot jump readability and whether the expanded loop feels fair.

## Validation Snapshot

Expected command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Manual smoke lives in `docs/validation.md`.

Latest editor-input fix:

- editor import no longer reports `INT_AS_ENUM_WITHOUT_CAST` in `app_bootstrap.gd`;
- editor import no longer reports `SHADOWED_VARIABLE_BASE_CLASS` in `arena_root.gd`;
- HUD controls are mouse-pass-through so FPS look is not swallowed by UI;
- player mouse look is handled through `_input`.

Latest shoot/menu fix:

- default mouse sensitivity lowered to `0.0018`;
- player shooting can be requested directly from input events and still respects cooldown;
- combatant collider now matches the visible capsule body so eye-height hitscan can damage the bot;
- `Esc` opens a pause menu with a sensitivity slider and `Retomar` button.

Bootstrap closeout:

- editor warning `SHADOWED_VARIABLE_BASE_CLASS` in `arena_hud.gd` fixed by avoiding a `CanvasLayer` method name collision;
- headless validation passes the FpsShooter GUT suite;
- first playable editor baseline is accepted as complete for Track 00.

Track 01A Feel/Feedback V1:

- player rifle remains simple hitscan with no ammo, reload, spread or projectile variants;
- player shot feedback now includes muzzle flash, tracer, hit/miss states, hit impact and synthetic audio;
- HUD now has a control-based crosshair, health bars, hit/kill states, damage overlay and round-end feedback;
- bot normal shots use a short `0.18s` tell before damage while `force_fire()` remains immediate for tests;
- player movement defaults are tuned for a lighter agile arena feel: FOV `86`, move speed `7.8`, jump `5.6`, air control `0.72`;
- validation passed `10/10` GUT tests with `94` asserts before Track 01B.

Track 01B Bot Duelista V1:

- bot behavior now uses explicit states: `idle`, `engage`, `strafe`, `reposition`, `windup`, `cooldown` and `dead`;
- normal bot shots require line of sight, use a short tell and are resolved by arena raycast;
- deterministic aim error can produce real misses without damaging the player;
- bot moves with strafe and simple map-derived reposition points, without `NavigationAgent3D`;
- bot visual color shifts by state and bot miss feedback uses a lighter amber tracer/audio;
- `force_fire()` remains immediate for tests;
- validation passed `16/16` GUT tests with `127` asserts before the vertical-awareness upgrade.

Track 01B Vertical Awareness Upgrade:

- bot line-of-sight now scans multiple target exposure points instead of only the body center;
- player camera/shot origin and head/upper-body points are checked first, so low cover can hide the torso while still leaving a valid visible target;
- bot windup and deterministic aim now use the visible target point, making height relevant to tell/readability and shot resolution;
- tall blockers still cancel normal windup and push the bot into reposition;
- validation passes `17/17` GUT tests with `132` asserts.

Track 01C Arena Layout V1:

- arena expanded into `Duel Pit V1`, replacing the bootstrap rectangle with a 1x1 duel map;
- protected diagonal spawns block first-frame direct shots;
- central high blocker, spawn covers and high covers define safe breaks in line of sight;
- low covers preserve head/camera exposure tests for the vertical-aware bot;
- side platforms and ramp primitives add first controlled height changes without jump pads, suspended platforms or void/fall rules;
- route markers are visual-only primitives;
- bot reposition points are rebuilt around the map and exposed through debug helpers;
- validation passes `19/19` GUT tests with `186` asserts.

Track 01D Knockback Movement Combat V1:

- combatant knockback now stores explicit impulse/debug data, clamps stacked horizontal/vertical force and decays more slowly while airborne than while grounded;
- player hits apply a clearer horizontal push plus controlled lift, preserving the hitscan rifle while making knockback readable on ramps/platforms;
- bot hits apply a smaller controlled lift and use the same combatant impulse contract;
- feedback controller adds a short knockback pulse/thump effect without overwriting hit/miss/damage event semantics;
- misses do not create false knockback or hit confirmation;
- validation passes `20/20` GUT tests with `203` asserts.

Track 02A Combat Loop Expansion V1:

- RMB `Plasma Bolt` adds a slow visible projectile with cooldown, primitive glow, hit/miss feedback and stronger controlled knockback than rifle;
- overcharge can empower the next rifle or plasma shot with boosted damage/knockback;
- runtime Health Shard and Overcharge pickups respawn on timers and are represented by primitive meshes/lights only;
- HUD now shows plasma cooldown, player overcharge and pickup availability/respawn without turning into a debug panel;
- bot awareness now receives pickup state and projectile threat data from the arena, seeks health when hurt, contests overcharge when appropriate and dodges nearby visible plasma;
- arena remains authority for projectile collision, pickup consumption, damage, knockback and feedback;
- validation passes `26/26` GUT tests with `239` asserts.

Track 02A Bot Pressure Jump Hotfix V1:

- bot now starts a ready normal shot before considering health or overcharge routes;
- bot can still seek Health Shard when hurt, but only as survival/rotation while shot pressure is unavailable or health is critical;
- bot interrupts an active health route as soon as line of sight, cooldown and reaction allow a windup;
- bot simple jump uses a cooldown and ground-contact probe to reach raised reposition goals or clear low blockers;
- validation passes `29/29` GUT tests with `249` asserts.

## Read Next

1. `AGENTS.md`
2. `docs/work-plan.md`
3. `docs/reuse-map.md`
4. `docs/validation.md`
5. `implementation/tracks/track-01-arena-1x1-v1/current-status.md`
6. `implementation/tracks/track-01a-feel-feedback-v1/current-status.md`
7. `implementation/tracks/track-01b-bot-duelist-v1/current-status.md`
8. `implementation/tracks/track-01c-arena-layout-v1/current-status.md`
9. `implementation/tracks/track-01d-knockback-movement-combat-v1/current-status.md`
10. `implementation/tracks/track-02a-combat-loop-expansion-v1/current-status.md`
11. `implementation/tracks/track-02a-bot-pressure-jump-hotfix-v1/current-status.md`
