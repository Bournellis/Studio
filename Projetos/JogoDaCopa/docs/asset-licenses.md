# JogoDaCopa - Asset Licenses

- Last updated: `2026-06-10`
- Scope: assets introduced or approved for `Track 02 Quality Upgrade V1`, including 02C-bis and 02D-bis real asset replacements.

## Track 02C - Ball & Character Assets V1

### In-Repo Authored Assets

| Asset | Path | Author | License | Notes |
|---|---|---|---|---|
| Procedural football panel shader | `assets/football/football_ball_panels.gdshader` | Codex for JogoDaCopa | `CC0-1.0` | Loaded by `FootballBall3D`; gives the ball a football-panel visual without binary texture/model dependency. |
| Runtime avatar tint, toon outline and persistent VFX wiring | `gameplay/avatar/player_avatar_3d.gd` | Codex for JogoDaCopa | `CC0-1.0` | Runtime code applies kit/skin colors to real models and generates authored kick animation in code. |

### Asset Import Spike

- `2026-06-10`: Godot headless loaded `res://assets/football/football_ball_panels.gdshader` successfully before committing Track 02C changes.
- Result: `[asset-spike] Track02C loaded football_ball_panels.gdshader code_chars=859`.

## Track 02C-bis - Real Character V1

| Asset Pack | Path | Author / Source | License | Evidence | Runtime Use |
|---|---|---|---|---|---|
| Universal Base Characters Kit - standard free version | `assets/characters/quaternius_ubc/base/` and `assets/characters/quaternius_ubc/hair/` | Quaternius | `CC0 1.0 Universal` | `assets/characters/quaternius_ubc/License_Standard.txt` | Player male and bot female humanoid models. |
| Universal Animation Library | `assets/characters/quaternius_ubc/animations/` | Quaternius | `CC0 1.0 Universal` | `assets/characters/quaternius_ubc/animations/License.txt` | 45 animation clips copied into the runtime `AnimationPlayer`. |
| Kenney Animated Characters 3 fallback subset | `assets/characters/kenney_animated/` | Kenney | `CC0 1.0 Universal` | Pack source metadata from manual download; no local license text shipped in this subset. | Registered fallback only; not used by runtime in 02C-bis. |

## Track 02D-bis - Real Audio V1

| Asset Pack | Path | Author / Source | License | Runtime Use |
|---|---|---|---|---|
| Kenney SFX subset | `assets/audio/kenney_sfx/` | Kenney | `CC0 1.0 Universal` | Kick, bounce, glass, menu click/back/confirmation, countdown ticks. |
| Kenney Music Jingles subset | `assets/audio/kenney_jingles/` | Kenney | `CC0 1.0 Universal` | Goal, win and loss jingles. |
| Stadium ambience and crowd clips | `assets/audio/stadium_pixabay/` | Pixabay contributors listed below | `Pixabay Content License` | Stadium ambience loop and goal crowd accent. |

### Pixabay Clip Registry

| File | Contributor | Source ID | Runtime Use |
|---|---|---|---|
| `freesound_community-soccer-stadium-10-6709.mp3` | `freesound_community` | `6709` | Stadium ambience loop. |
| `freesound_community-soccer-stadium-game-fcsp-vs-buchum-25743.mp3` | `freesound_community` | `25743` | Registered stadium alternate. |
| `mrmark81-stadium-roar-concert-471943.mp3` | `mrmark81` | `471943` | Registered crowd alternate. |
| `u_xg7ssi08yr-crowd-cheering-379666.mp3` | `u_xg7ssi08yr` | `379666` | Goal crowd accent. |
| `vishiv-crowd-cheering-in-stadium-435357.mp3` | `vishiv` | `435357` | Registered crowd alternate. |

## Track 02G - Product Identity V1

### In-Repo Authored Assets

| Asset | Path | Author | License | Notes |
|---|---|---|---|---|
| Copa Arena Futebol icon | `assets/branding/copa_arena_icon.svg` | Codex for JogoDaCopa | `CC0-1.0` | Generic football/arena mark; no official logos or federation marks. |
| Copa Arena Futebol splash | `assets/branding/copa_arena_splash.png` | Codex for JogoDaCopa | `CC0-1.0` | Generated in-repo from authored vector-style composition for Godot boot splash PNG requirement. |

## License Rule

- No official FIFA/Copa logos are included.
- Decision Fabio/Codex `2026-06-10`: external assets allowed only when they are `CC0`, `CC-BY` with attribution registered, or `Pixabay Content License`, always listed in this file before use.
