# Track 03A - Vertical Arena No Void V1

- Last updated: `2026-06-10`
- Status: `COMPLETE`
- Portfolio marker: `FPS_SHOOTER_TRACK_03A_VERTICAL_ARENA_NO_VOID_COMPLETE`
- Original worktree: `D:\Estudio-worktrees\FpsShooter--codex--track03a-vertical-arena-fall-pressure-v1`
- Original branch: `codex/fpsshooter/track03a-vertical-arena-fall-pressure-v1`
- No-void hotfix worktree: `D:\Estudio-worktrees\FpsShooter--codex--remove-void-from-duel-pit-v2`
- No-void hotfix branch: `codex/fpsshooter/remove-void-from-duel-pit-v2`

## Goal

Turn the accepted flat duel loop into the first vertical arena loop: the player and bot can use jump pads to reach high platforms, pickups sit on elevated objectives, and the bot understands the vertical arena rules without introducing pathfinding or new weapon systems. The current accepted `Duel Pit V2` map does not use void/fall zones; those are reserved for future dedicated maps.

## Delivered

- `Duel Pit V2` replaces `Duel Pit V1` as the active runtime map name.
- Two high platforms were added above the previous side routes.
- Health Shard and Overcharge moved to elevated platform positions so pickups become vertical route objectives.
- Two runtime jump pads launch combatants toward the high platforms with primitive glow/light feedback.
- The active map no longer creates north/south void wells or fall-penalty processing.
- Player and bot now have explicit jump-pad launch support.
- Bot receives jump-pad route data from the arena.
- Bot can route high reposition goals through nearby jump pads and scores elevated reposition points without fall-zone awareness.
- HUD/feedback controller report jump pad activation; void/fall presentation hooks are inactive in this map.
- Automated tests cover map nodes, reposition markers, bot route awareness, jump-pad launch, absent void wells and bot high-goal routing.

## Validation

Command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\FpsShooter--codex--remove-void-from-duel-pit-v2\Projetos\FpsShooter --script res://tools/validate.gd
```

Result:

- `tools/validate.gd`: PASS
- GUT: `33/33`
- Asserts: `279`
- Note: the first run required a one-time headless editor import for GUT class registration in the new worktree. The passing validation still prints known GUT addon UID/text-path warnings during headless execution, not project script warnings.

Additional check:

- `git diff --check`: PASS

## Manual Smoke

Open `Projetos/FpsShooter/project.godot` in Godot 4.6.2 and press Play.

Focus:

- move, mouse look, jump, rifle, Plasma Bolt and restart still work;
- map label reads `Duel Pit V2`;
- jump pads visibly launch player and bot toward high platforms;
- high pickups are reachable and readable;
- lower-floor movement and side routes do not trigger void/fall penalty in the current map;
- bot uses vertical routes without ignoring pressure entirely;
- `Esc` sensitivity menu still resumes correctly.

## Out Of Scope

- No new weapons.
- No ammo, reload, recoil/spread pass or weapon roster.
- No void/fall zones in the current map.
- No suspended platform puzzle beyond the two high duel platforms.
- No multiplayer, export, Web/mobile or backend.
- No Draxos economy/progression/lore systems.
