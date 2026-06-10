# Track 03A - Vertical Arena And Fall Pressure V1

- Last updated: `2026-06-10`
- Status: `COMPLETE`
- Portfolio marker: `FPS_SHOOTER_TRACK_03A_VERTICAL_ARENA_FALL_PRESSURE_COMPLETE`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--track03a-vertical-arena-fall-pressure-v1`
- Branch: `codex/fpsshooter/track03a-vertical-arena-fall-pressure-v1`

## Goal

Turn the accepted flat duel loop into the first vertical arena loop: the player and bot can use jump pads to reach high platforms, pickups sit on elevated objectives, void/fall zones punish knockback and poor positioning, and the bot understands the vertical arena rules without introducing pathfinding or new weapon systems.

## Delivered

- `Duel Pit V2` replaces `Duel Pit V1` as the active runtime map name.
- Two high platforms were added above the previous side routes.
- Health Shard and Overcharge moved to elevated platform positions so pickups become vertical route objectives.
- Two runtime jump pads launch combatants toward the high platforms with primitive glow/light feedback.
- Two void/fall hazard zones apply damage, feedback and safe recovery back to the spawn side.
- Falling below the world floor also uses the same fall penalty path.
- Player and bot now have explicit jump-pad launch support and clear movement impulse reset hooks for recovery.
- Bot receives jump-pad route data and fall-zone awareness from the arena.
- Bot can route high reposition goals through nearby jump pads and scores elevated reposition points while penalizing fall-zone danger.
- HUD/feedback controller now report jump pad activation and fall penalties.
- Automated tests cover map nodes, reposition markers, bot route awareness, jump-pad launch, void recovery, knockback into void and bot high-goal routing.

## Validation

Command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\FpsShooter--codex--track03a-vertical-arena-fall-pressure-v1\Projetos\FpsShooter --script res://tools/validate.gd
```

Result:

- `tools/validate.gd`: PASS
- GUT: `35/35`
- Asserts: `294`
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
- knockback can push combatants into void/fall zones;
- fall penalty applies damage, feedback and safe recovery;
- bot uses vertical routes without ignoring pressure entirely;
- `Esc` sensitivity menu still resumes correctly.

## Out Of Scope

- No new weapons.
- No ammo, reload, recoil/spread pass or weapon roster.
- No suspended platform puzzle beyond the two high duel platforms.
- No multiplayer, export, Web/mobile or backend.
- No Draxos economy/progression/lore systems.

