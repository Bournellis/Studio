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
- `Projetos/JogoDaCopa/tests/unit/test_hud_visual.gd`: cobertura do scorebug, estados 3 gols/timer/vale 2/golden goal, SUPER meter, READY e regressao de kickoff countdown integrado.
- `Projetos/JogoDaCopa/docs/screenshots/track-06d/`: evidencias PNG/JSON do HUD em desktop e Web boot.

## Evidencias

- `docs/screenshots/track-06d/hud-broadcast-1920x1080.png`
- `docs/screenshots/track-06d/hud-broadcast-1280x720.png`
- `docs/screenshots/track-06d/hud-broadcast-960x540.png`
- `docs/screenshots/track-06d/06d-web-kickoff-boot.png`
- `docs/screenshots/track-06d/06d-web-kickoff-boot.json`

## Validacao

- Godot import headless na worktree: OK.
- GUT focado `test_hud_visual.gd` + `test_pause_menu.gd`: OK, suite completa carregada pela config, `98/98`, `1538` asserts.
- `tools/validate.gd`: OK, `98/98`, `1538` asserts, `[validate] success`.
- Export Web release: OK.
- Chrome Web boot smoke: OK, stage `event.visible_match_start` visto, `pageErrors=0`, `consoleErrorCount=0`.
- `git diff --check`: OK.

Avisos conhecidos: warnings de UID/text path do GUT durante import/test/export e aviso ObjectDB no encerramento do export; sem falha de validacao.

## Handoff

Parar pre-merge. Revisar visualmente os screenshots e, se aprovado, Fabio pode mergear a branch via fluxo local/GitHub Desktop.

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin
