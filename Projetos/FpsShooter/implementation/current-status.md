# FpsShooter - Current Status

- Last updated: `2026-06-10`
- Project: `FpsShooter`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first FPS Playground tech probe`
- Active stage: `Track 06A - Avatar Visual Foundation V1`
- Active stage status: `ACTIVE`

## Current Truth

`FpsShooter` is an official implementable Godot project for testing first-person 3D gameplay fundamentals in the studio. The folder name remains `FpsShooter`, while the local product identity now presents as `FPS Playground`.

The project is a tech probe independent from Draxos Roguelike Cardgame, DraxosMobile, RPG Isometrico and RPG Turnos. It may use a light Draxos visual theme, but no other project gameplay system is inherited.

## Current Scope

- PC Windows editor-first.
- `FPS Playground` main menu with selectable modes.
- `Arena Shooter`: traditional FPS baseline in a local 1x1 arena against a bot.
- `Futebol`: first-person 1x1 football mode against a bot, no weapons, match to 3 goals.
- Player movement, mouse look, jump, hitscan shot and combat-readable knockback.
- Secondary `Plasma Bolt` alt-fire on RMB with visible slow projectile, crosshair-aligned damage, stronger knockback and cooldown.
- Runtime pickups: elevated health shard and overcharge.
- Fair bot baseline with vertical-aware line of sight.
- Bot tactical awareness for health pickup, overcharge contest and visible plasma dodge.
- Bot pressure tuning: ready shots interrupt pickup routes and health pickup is a survival/rotation choice instead of the default concern.
- Bot simple jump support for raised reposition goals and low navigation blockers.
- Bot awareness for jump-pad routes and elevated reposition goals.
- `Duel Pit V2` arena layout with protected spawns, low/high cover, side platforms, ramps, high platforms, jump pads, elevated pickups, route/landing markers and high-platform soft cover, without void/fall zones in the current map.
- Void/fall pressure is reserved for future dedicated maps.
- HUD, round state and bidirectional feel/feedback.
- Futebol mode reuses the FPS controller and sensitivity flow, starts with a paused `Como Jogar` / `Comecar` intro panel, turns LMB/RMB into kick/strong kick, uses a loose arcade `RigidBody3D` ball, primitive festive stadium visuals, fully closed goal interiors, simple football bot attack/defend behavior, score HUD and goal feedback.
- No export, Web, mobile, multiplayer or online/backend scope.

## Active Goal

`Track 06A - Avatar Visual Foundation V1` is active. The current objective is to add a procedural runtime avatar foundation to `Futebol`: visible primitive humanoids for player/bot, skin tone selection, country-inspired shirt kits and basic presentation-only animation states.

## Current Gate

Implement Track 06A in a dedicated worktree, keep Arena Shooter behavior preserved and validate that Futebol remains playable while gaining avatar customization/animation.

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

Track 02A Plasma Damage Hotfix V1:

- Plasma Bolt now converges from the offset visual muzzle toward the player's camera/crosshair aim point instead of travelling parallel to the camera ray;
- player projectile collision uses a radius-aware overlap fallback after the centerline raycast, so visible plasma body contact can damage the bot reliably;
- tests now cover both overcharged Plasma Bolt damage/strong knockback and a real `request_alt_fire()` body-edge hit from the offset muzzle;
- validation passes `30/30` GUT tests with `253` asserts.

Track 03A Vertical Arena No Void Hotfix V1:

- arena promoted to `Duel Pit V2` with two high duel platforms above the previous side routes;
- Health Shard and Overcharge moved to elevated platform objectives;
- two runtime jump pads launch player and bot toward the high platforms with primitive glow/light/audio feedback;
- the current `Duel Pit V2` map no longer creates north/south void wells or fall penalty processing;
- player and bot keep explicit jump-pad launch support;
- bot receives jump-pad route data and routes high reposition goals through pads without fall-zone awareness in the current map;
- tests assert that `NorthVoidWell` and `SouthVoidWell` are absent from the active scene;
- void/fall pressure remains a future-map candidate instead of part of the current duel pit baseline;
- validation passes `33/33` GUT tests with `279` asserts.

Track 03B Arena Flow & Route Tuning V1:

- Health Shard moved to `Vector3(-7.6, 3.55, -8.6)` with `10s` respawn;
- Overcharge moved to `Vector3(7.6, 3.55, 8.6)` with `14s` respawn;
- jump pads still land near, not directly on, the elevated pickups, requiring a small post-launch commitment;
- runtime cyan/green/purple route markers now identify pad approach, landing zones and high objectives;
- high platforms gained light cover for short duels without becoming bunkers;
- bot route tuning adds vertical route cooldown, objective route interval, route labels and score/debug helpers;
- ready shot pressure remains above health/overcharge routes, while health/overcharge routes still happen when justified;
- HUD shows a compact bot flow line with state, route, LOS and last pad cue for playtest readability;
- validation passes `36/36` GUT tests with `297` asserts.

Track 04A FPS Playground Menu & Futebol V1:

- project display name is now `FPS Playground` and the main scene is `res://modes/menu/main_menu.tscn`;
- menu offers `Arena Shooter`, `Futebol` and `Sair`;
- `Arena Shooter` remains available and its pause menu can return to the main menu;
- `Futebol` adds a first-person 1x1 football mode with no weapons, LMB kick, RMB strong kick, loose arcade ball physics, simple attack/defend bot, festive primitive stadium, goal posts, score HUD and match to 3 goals;
- shared `FpsFeedbackController` now includes football kick and goal feedback using runtime primitives and synthetic audio;
- validation now generates/checks menu, arena and football scenes;
- validation passes `42/42` GUT tests with `341` asserts.

Track 04A Football First Fixes:

- main menu layout now uses deterministic centered anchors/offsets instead of drifting from the center preset;
- Futebol now starts paused on a `Como Jogar` panel with hotkeys/basic rules and a `Comecar` button before mouse capture/gameplay;
- north/south goals now include collision floor extensions so entering the goal mouth no longer drops out of the map;
- tests cover centered menu offsets, intro panel visibility/start contract and goal safety floors;
- validation passes `42/42` GUT tests with `351` asserts.

Track 04A Menu/Goal Fix V2:

- main menu now uses `MenuCenter/MenuPanel/MenuMargin/MenuBox`, so the whole menu block is centered by container layout instead of manual offsets;
- Futebol intro and pause panels now use full-rect center containers, avoiding manual center positions;
- football goals now have side wall collision bodies on both internal sides, closing the remaining lateral gaps between the front wall and backstop;
- `Comecar` text is ASCII-normalized in the intro button to avoid encoding drift in docs/tools;
- tests cover the new centered menu hierarchy, intro center path and four goal side wall nodes;
- validation passes `42/42` GUT tests with `355` asserts.

Track 05 Foundation Hardening & Refactor V1:

- complete as a large sequential documentation, hardening and refactor track;
- added documentation index, architecture overview, mode contract, bot contract, tuning guide, validation profiles, publication readiness and audit docs;
- validation now supports `full`, `quick`, `structure` and `--list-profiles`;
- shared runtime primitive creation lives in `modes/shared/runtime_primitive_factory.gd`;
- arena and football static layout construction now live in dedicated builders under `modes/arena/` and `modes/football/`;
- arena combat math and football match rules now live under `gameplay/arena/` and `gameplay/football/`;
- bot aim/visibility helper logic now lives under `gameplay/bot/`;
- tests are split into broad integration regression plus focused helper coverage;
- final validation passes `51/51` GUT tests with `386` asserts;
- gameplay changes remained out of scope except for behavior-preserving refactor fixes.

## Read Next

1. `AGENTS.md`
2. `docs/documentation-index.md`
3. `docs/architecture-overview.md`
4. `docs/work-plan.md`
5. `docs/reuse-map.md`
6. `docs/validation.md`
7. `implementation/tracks/track-05-foundation-hardening-refactor-v1/current-status.md`
8. `implementation/tracks/track-01-arena-1x1-v1/current-status.md`
9. `implementation/tracks/track-01a-feel-feedback-v1/current-status.md`
10. `implementation/tracks/track-01b-bot-duelist-v1/current-status.md`
11. `implementation/tracks/track-01c-arena-layout-v1/current-status.md`
12. `implementation/tracks/track-01d-knockback-movement-combat-v1/current-status.md`
13. `implementation/tracks/track-02a-combat-loop-expansion-v1/current-status.md`
14. `implementation/tracks/track-02a-bot-pressure-jump-hotfix-v1/current-status.md`
15. `implementation/tracks/track-02a-plasma-damage-hotfix-v1/current-status.md`
16. `implementation/tracks/track-03a-vertical-arena-fall-pressure-v1/current-status.md`
17. `implementation/tracks/track-03b-arena-flow-route-tuning-v1/current-status.md`
18. `implementation/tracks/track-04a-fps-playground-football-v1/current-status.md`
19. `implementation/tracks/track-05-foundation-hardening-refactor-v1/current-status.md`
20. `implementation/tracks/track-06a-avatar-visual-foundation-v1/current-status.md`
