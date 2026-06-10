# JogoDaCopa - Asset Licenses

- Last updated: `2026-06-10`
- Scope: assets introduced or approved for `Track 02 Quality Upgrade V1`.

## Track 02C - Ball & Character Assets V1

### In-Repo Authored Assets

| Asset | Path | Author | License | Notes |
|---|---|---|---|---|
| Procedural football panel shader | `assets/football/football_ball_panels.gdshader` | Codex for JogoDaCopa | `CC0-1.0` | Loaded by `FootballBall3D`; gives the ball a football-panel visual without binary texture/model dependency. |
| Copa low-poly avatar rig profile | `gameplay/avatar/player_avatar_3d.gd` runtime `CopaAssetSkeleton`, `AssetAnimationPlayer`, `AssetAnimationTree` | Codex for JogoDaCopa | `CC0-1.0` | Internal authored rig/animation layer preserving `apply_appearance`, `set_move_state`, `play_kick` and `play_celebrate`. |

### Asset Import Spike

- `2026-06-10`: Godot headless loaded `res://assets/football/football_ball_panels.gdshader` successfully before committing Track 02C changes.
- Result: `[asset-spike] Track02C loaded football_ball_panels.gdshader code_chars=859`.

### Approved External CC0 Sources For Future Replacement

These sources were checked during Track 02C but no external binary asset was committed in this pass.

| Source | URL | License Evidence | Notes |
|---|---|---|---|
| Kenney Animated Characters 3 | `https://kenney-assets.itch.io/animated-characters-3` | Page lists `CC0 1.0 Universal`, rigged model, human skins, idle/jump/running animations. | Itch download requires its purchase/download flow; not committed. |
| Quaternius Universal Base Characters | `https://quaternius.com/packs/universalbasecharacters.html` | Page lists `CC0`, glTF/FBX formats, humanoid rig and Godot compatibility. | Candidate for a later binary asset replacement if desired. |

## License Rule

- No official FIFA/Copa logos are included.
- Any future external asset must be `CC0` or `CC-BY` and must be listed here before use.
