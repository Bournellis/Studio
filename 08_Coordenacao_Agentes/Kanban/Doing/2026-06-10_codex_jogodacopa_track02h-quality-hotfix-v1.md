# Tarefa: JogoDaCopa - Track 02H Quality Hotfix V1

## Metadata

- id: `2026-06-10_jogodacopa-track02h-quality-hotfix-v1`
- owner: `Codex`
- status: `Doing`
- projeto: `JogoDaCopa`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/jogodacopa/track02h-quality-hotfix-v1`
- worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track02h-quality-hotfix-v1`

## Execution Registration

- Base docs read: `08_Coordenacao_Agentes/Prioridades_Estudio.md`, `AGENTS.md`, `Projetos/README.md`, `08_Coordenacao_Agentes/Estado_Atual.md`, `Projetos/JogoDaCopa/AGENTS.md`, `Projetos/JogoDaCopa/implementation/current-status.md`, `Projetos/JogoDaCopa/docs/quality-upgrade-plan.md`, `Projetos/JogoDaCopa/docs/code-review-track02-series-v1.md`, completed Track 02 card.
- Intended files: `Projetos/JogoDaCopa/modes/football/football_root.gd`, `Projetos/JogoDaCopa/presentation/hud/football_hud.gd`, `Projetos/JogoDaCopa/presentation/feedback/fps_feedback_controller.gd`, `Projetos/JogoDaCopa/gameplay/avatar/player_avatar_3d.gd`, `Projetos/JogoDaCopa/gameplay/football/football_ball.gd`, `Projetos/JogoDaCopa/modes/menu/main_menu_root.gd`, `Projetos/JogoDaCopa/tests/`, `Projetos/JogoDaCopa/docs/`, `Projetos/JogoDaCopa/implementation/`, `08_Coordenacao_Agentes/Estado_Atual.md`, this card.
- Validation plan: run `Projetos/JogoDaCopa/tools/validate.gd`, `git diff --check` and `git status --short` before merge/handoff.
- Next handoff point: after hotfix validation and merge back to `main`; if blocked, document exact failing issue here.

## Goal

Corrigir as ressalvas tecnicas da revisao da Track 02 antes do playtest humano principal, preservando fisica da bola, forcas de chute, boost do player e regras de gol.

## Technical Scope

- M1: stadium scoreboards use `_get_kit_code()` for selected player/bot kits instead of fixed `BRA/FRA`.
- M2: off-screen ball indicator classifies relative direction in player/camera local basis instead of world axes.
- M3: boost trail and skid dust use persistent `GPUParticles3D` emitters on the player, toggled on/off.
- M5: expose bot difficulty selection (`easy`, `normal`, `hard`) in the main menu with non-debug API and HUD visibility.
- H1 mitigation: remove decorative Track 02C avatar rig/dead animation processing and related debug hooks/tests; defer real skinned character to future 02C-bis after Fabio downloads CC0 pack manually.
- Cheap optional fixes if safe: L2 ball trail hysteresis and L4 cached stadium scoreboard labels.

## Out of Scope

- Do not alter ball physics, kick forces, player boost tuning or goal rules.
- Do not add external downloaded character/audio assets.
- Do not implement 02C-bis character integration or 02D-bis audio integration in this track.
- Do not touch FPS, Web/mobile, multiplayer, backend or economy scope.

## Expected Files

- `Projetos/JogoDaCopa/modes/football/football_root.gd`
- `Projetos/JogoDaCopa/presentation/hud/football_hud.gd`
- `Projetos/JogoDaCopa/presentation/feedback/fps_feedback_controller.gd`
- `Projetos/JogoDaCopa/gameplay/avatar/player_avatar_3d.gd`
- `Projetos/JogoDaCopa/gameplay/football/football_ball.gd`
- `Projetos/JogoDaCopa/modes/menu/main_menu_root.gd`
- `Projetos/JogoDaCopa/tests/`
- `Projetos/JogoDaCopa/docs/quality-upgrade-plan.md`
- `Projetos/JogoDaCopa/implementation/tracks/track-02h-quality-hotfix-v1/current-status.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/work-plan.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`

## Acceptance Criteria

- [ ] M1, M2, M3, M5 and H1 mitigation implemented.
- [ ] Optional L2/L4 applied only if low risk.
- [ ] GUT coverage added/updated for M1, M2 and M5.
- [ ] `Projetos/JogoDaCopa/tools/validate.gd` PASS.
- [ ] Status docs updated with next step: human editor playtest plus Fabio decision on 02C-bis character and 02D-bis audio assets.
- [ ] Card moved to Done after merge with validation record.

## Handoff Needed

`No`

## Notes

- Review source: `Projetos/JogoDaCopa/docs/code-review-track02-series-v1.md`.
- The real animated character remains dependent on Fabio manually downloading a CC0 pack; this hotfix removes dead decorative rig work until that asset path exists.
