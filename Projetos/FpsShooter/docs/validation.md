# FpsShooter Validation

- Last updated: `2026-06-10`
- Status: `VIVO`

## Headless Command

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\FpsShooter -s res://tools/validate.gd
```

When working from a dedicated worktree, run with that worktree path.

## What It Does

- regenerates `res://modes/menu/main_menu.tscn`, `res://modes/arena/arena.tscn` and `res://modes/football/football.tscn` from `tools/bootstrap_scene_generator.gd`;
- checks required project settings, autoloads and resources;
- checks the generated menu, arena and football scenes load;
- runs the GUT suite under `res://tests/unit`;
- prints the manual editor follow-up instead of exporting.

Latest automated baseline:

- GUT `42/42`;
- `355` asserts;
- Track 04A validates menu boot and mode routes, centered menu container hierarchy, generated menu/arena/football scenes, paused football intro panel, football goal safety floors and side walls, football player kick and strong kick, no weapon damage in football, football goal scoring/match end, bot kick handoff, arena pause menu return button and the full previous arena shooter regression suite.

## Manual Smoke

Open `Projetos/FpsShooter/project.godot` in Godot 4.6.2 and press Play.

Expected menu flow:

- Play opens the `FPS Playground` main menu;
- the menu is centered and readable in the first viewport, with the mode buttons grouped in the center panel;
- `Arena Shooter` loads the accepted duel arena;
- `Futebol` loads the first-person football mode;
- `Sair` exits when running from editor/player;
- `Esc` inside a mode opens pause;
- `Menu inicial` returns to the menu from both modes.

Expected Arena Shooter:

- mouse is captured in the arena, or captured after the first click inside the game window;
- `WASD` moves;
- mouse look rotates the camera;
- `Space` jumps;
- left click shoots while mouse is captured;
- right click fires Plasma Bolt while mouse is captured;
- each player shot has muzzle/tracer feedback and a short synthetic shot sound;
- Plasma Bolt is visibly slower than rifle, glows, travels from the muzzle side and has clear impact/miss feedback;
- aiming at the bot and shooting reduces bot health, flashes the bot, shows hitmarker and plays hit feedback;
- hitting the bot pushes it in the shot direction with a small readable lift and short knockback pulse;
- hitting the bot with Plasma Bolt creates stronger but still controlled knockback;
- aiming directly at the bot with RMB reliably causes Plasma Bolt damage/knockback instead of only showing the projectile;
- missing the bot still shows shot/tracer feedback without false hit confirmation;
- missing the bot does not move it or show hit/knockback feedback;
- the map is `Duel Pit V2`, with a central blocker, low/high cover, route markings, side platforms, ramps, high platforms and jump pads, with no active void/fall zones;
- direct first shot from spawn does not immediately damage the bot;
- player can move around the central blocker and read the side routes;
- player can walk onto/down the ramp/platform primitives without getting stuck in ordinary movement;
- bot moves, strafes and repositions instead of only walking straight;
- health and overcharge pickups are visible on elevated platforms;
- health and overcharge pickups are close to, but not directly on, the jump pad landing target;
- player needs a small post-launch commitment to collect the high pickup instead of receiving it automatically;
- route markers make pad approach, landing zones and high objectives readable at a glance;
- high platforms have enough light cover for a short duel, but do not become sealed bunkers;
- jump pads launch the player toward the high platform objectives with visible cyan feedback;
- jump pads can also launch the bot without trapping it in launch loops;
- moving around the lower floor and side routes does not trigger void/fall damage or recovery in the current map;
- walking through Health Shard heals only if damaged and hides it until respawn;
- walking through Overcharge primes the next rifle or plasma shot and updates HUD state;
- the bot can seek health when hurt and contest overcharge when the pickup is available;
- the bot starts a ready tell/shot instead of abandoning pressure for health;
- the bot interrupts a health route when line of sight, range, cooldown and reaction are ready again;
- the bot can make simple jumps toward raised map pieces or low blockers without constant jump spam;
- the bot can route toward high objectives through jump pads without falling into a void-avoidance loop;
- the bot alternates between low route, center pressure and high objective more clearly instead of repeating jump-pad routes immediately;
- the HUD bot flow line helps read bot state, route and line of sight without becoming a heavy debug panel;
- the bot reacts to nearby visible Plasma Bolt pressure with a dodge vector;
- cover can break bot line of sight, preventing normal bot damage through obstacles;
- low cover can hide the body center while the bot still recognizes player camera/head exposure above it;
- tall cover blocks the exposed points and pushes the bot to reposition instead of firing;
- bot normal shots show a short amber tell before damage;
- bot shots can miss without damaging the player;
- receiving bot damage shows red overlay, player health change, knockback and feedback audio;
- received knockback is lighter than player-applied knockback but still readable;
- health values change;
- round victory/defeat gives clear HUD feedback;
- `R` restarts the round;
- `Esc` opens the menu;
- the menu sensitivity slider changes mouse look speed;
- `Retomar` or `Esc` closes the menu and captures mouse again.

Expected Futebol:

- the mode starts paused on `Como Jogar` with hotkeys/basic rules;
- pressing `Comecar` starts the match and captures mouse for gameplay;
- first-person camera/mouse look and `WASD` movement work;
- `Space` jumps;
- LMB kicks the ball when it is in reach;
- RMB performs a stronger kick with more force/lift;
- missing the ball gives a subtle `SEM CONTATO` HUD cue and no weapon damage occurs;
- the bot chases, attacks and defends the ball;
- the ball feels loose/arcade and can be moved by player/bot kicks;
- entering either goal mouth does not drop the player or ball out of the map, including the lateral interior sides of the goal;
- scoring in the opponent goal updates the scoreboard and shows goal feedback;
- match ends at 3 goals with clear win/loss feedback;
- `R` restarts the match;
- `Esc` opens the pause menu and sensitivity still works.
