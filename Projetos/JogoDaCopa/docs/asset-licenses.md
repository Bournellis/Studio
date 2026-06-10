# JogoDaCopa - Asset Licenses

- Last updated: `2026-06-10`
- Scope: assets introduced or approved for `Track 02 Quality Upgrade V1`.

## Track 02C - Ball & Character Assets V1

### In-Repo Authored Assets

| Asset | Path | Author | License | Notes |
|---|---|---|---|---|
| Procedural football panel shader | `assets/football/football_ball_panels.gdshader` | Codex for JogoDaCopa | `CC0-1.0` | Loaded by `FootballBall3D`; gives the ball a football-panel visual without binary texture/model dependency. |
| Procedural avatar proxy and persistent VFX emitters | `gameplay/avatar/player_avatar_3d.gd` runtime box/sphere meshes and `GPUParticles3D` emitters | Codex for JogoDaCopa | `CC0-1.0` | Track 02H removed the decorative unskinned `CopaAssetSkeleton`/`AnimationTree`; real character asset integration is deferred to 02C-bis after manual CC0 download. |

### Asset Import Spike

- `2026-06-10`: Godot headless loaded `res://assets/football/football_ball_panels.gdshader` successfully before committing Track 02C changes.
- Result: `[asset-spike] Track02C loaded football_ball_panels.gdshader code_chars=859`.

### Approved External CC0 Sources For Future Replacement

These sources were checked during Track 02C but no external binary asset was committed in this pass.

| Source | URL | License Evidence | Notes |
|---|---|---|---|
| Kenney Animated Characters 3 | `https://kenney-assets.itch.io/animated-characters-3` | Page lists `CC0 1.0 Universal`, rigged model, human skins, idle/jump/running animations. | Itch download requires its purchase/download flow; not committed. |
| Quaternius Universal Base Characters | `https://quaternius.com/packs/universalbasecharacters.html` | Page lists `CC0`, glTF/FBX formats, humanoid rig and Godot compatibility. | Candidate for a later binary asset replacement if desired. |

## Track 02G - Product Identity V1

### In-Repo Authored Assets

| Asset | Path | Author | License | Notes |
|---|---|---|---|---|
| Copa Arena Futebol icon | `assets/branding/copa_arena_icon.svg` | Codex for JogoDaCopa | `CC0-1.0` | Generic football/arena mark; no official logos or federation marks. |
| Copa Arena Futebol splash | `assets/branding/copa_arena_splash.png` | Codex for JogoDaCopa | `CC0-1.0` | Generated in-repo from authored vector-style composition for Godot boot splash PNG requirement. |

## License Rule

- No official FIFA/Copa logos are included.
- Any future external asset must be `CC0` or `CC-BY` and must be listed here before use.
