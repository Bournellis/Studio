# Handoff - JogoDaCopa Track 06D - HUD Broadcast V1

Data: 2026-06-13
Agente: Codex
Branch: `codex/jogodacopa/track06d-hud-broadcast-v1`
Worktree: `D:\Estudio-worktrees\jogodacopa-track06d`
Base: `c894dc0d chore(jogodacopa): add kenney cc0 fonts (serie 06 broadcast prereq)`

## Objetivo

Implementar o scorebug/HUD broadcast v1 usando fontes Kenney locais, preservando os caminhos existentes do HUD e sem tocar menu, asset licenses, autoloads, `football_root.gd`, `project.godot`, `test_bootstrap` ou caminhos do `test_pause_menu.gd`.

## Alteracoes

- `Projetos/JogoDaCopa/presentation/hud/football_hud.gd`: scorebug broadcast com placar, swatches, badge de estado, barras de stamina/SUPER, badge READY e punch visual em gol/countdown.
- Ajuste pre-merge: `FlowLabel` e `ControlLabel` continuam no scorebug e seguem atualizados por `update_snapshot`, mas ficam `visible=false` por padrao; `debug_set_telemetry_visible(bool)` reativa a telemetria apenas em debug.
- `Projetos/JogoDaCopa/tests/unit/test_hud_visual.gd`: cobertura do scorebug limpo, toggle debug de telemetria, estados 3 gols/timer/vale 2/golden goal, SUPER meter, READY e regressao de kickoff countdown integrado.
- `Projetos/JogoDaCopa/tools/capture_track06d_hud_broadcast.gd`: captura 06D especifica com assert de ambiente noturno (`WorldEnvironment`, `ACES`, `BG_SKY`, `ProceduralSkyMaterial` escuro) e gate de luma de ceu `< 90.0`.
- `Projetos/JogoDaCopa/docs/screenshots/track-06d/`: evidencias PNG/JSON do HUD em desktop e Web boot.
- `Projetos/JogoDaCopa/docs/playtest-reports/track-06d-hud-broadcast.md`: relatorio da recaptura, tabela de luma e gates.

## Evidencias

- `docs/screenshots/track-06d/hud-broadcast-kickoff-1920x1080.png`
- `docs/screenshots/track-06d/hud-broadcast-goal-1920x1080.png`
- `docs/screenshots/track-06d/hud-broadcast-super-1920x1080.png`
- `docs/screenshots/track-06d/hud-broadcast-result-1920x1080.png`
- `docs/screenshots/track-06d/hud-broadcast-kickoff-1366x768.png`
- `docs/screenshots/track-06d/hud-broadcast-goal-1366x768.png`
- `docs/screenshots/track-06d/hud-broadcast-super-1366x768.png`
- `docs/screenshots/track-06d/hud-broadcast-result-1366x768.png`
- `docs/screenshots/track-06d/hud-broadcast-kickoff-1280x720.png`
- `docs/screenshots/track-06d/hud-broadcast-goal-1280x720.png`
- `docs/screenshots/track-06d/hud-broadcast-super-1280x720.png`
- `docs/screenshots/track-06d/hud-broadcast-result-1280x720.png`
- `docs/screenshots/track-06d/hud-broadcast-luma.json`
- `docs/screenshots/track-06d/06d-web-kickoff-boot.png`
- `docs/screenshots/track-06d/06d-web-kickoff-boot.json`

## Luma noturna

| Shot | 1920x1080 | 1366x768 | 1280x720 |
|---|---:|---:|---:|
| Kickoff | `58.5` | `60.5` | `59.7` |
| Gol | `61.0` | `61.7` | `61.2` |
| Super | `58.5` | `60.5` | `59.7` |
| Result | `75.1` | `74.9` | `71.7` |

Gate aprovado: todos os valores de ceu ficaram `< 90.0`.

## Validacao

- Godot import headless na worktree: OK.
- Regressao HUD + pause coberta pelo validate full: `test_hud_visual.gd` `3/3` e `test_pause_menu.gd` `2/2`.
- `tools/validate.gd`: OK, `98/98`, `1548` asserts, `[validate] success`.
- Captura `tools/capture_track06d_hud_broadcast.gd`: OK, 12 screenshots noturnos, luma `58.5-75.1`.
- Export Web release: OK.
- Chrome Web boot smoke: OK, stage `event.visible_match_start` visto, `pageErrors=0`, `consoleErrorCount=0`, screenshot `06d-web-kickoff-boot.png` atualizado.
- `git diff --check`: OK.

Avisos conhecidos: warnings de UID/text path do GUT durante import/test/export e aviso ObjectDB no encerramento do export; sem falha de validacao.

## Handoff

Parar pre-merge. Revisar visualmente os screenshots e, se aprovado, Fabio pode mergear a branch via fluxo local/GitHub Desktop.

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin
