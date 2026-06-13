# Handoff - JogoDaCopa Track 06A - Match Start Fixes V1

- Data: `2026-06-13`
- Agente: Codex
- Branch: `codex/jogodacopa/track06a-match-start-fixes-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track06a`
- Status: `STOP PRE-MERGE` para review visual/feel da Claude e aprovacao de Fabio.

## Escopo Entregue

- Countdown inicial corrigido com teste vermelho previo.
- Facing inicial e pos-gol corrigido para player e bot olharem para o oponente.
- Hints do HUD removidos da partida e migrados para `FootballHud.CONTROL_HINTS`.
- Crosshair visual removido do HUD sem alterar mira funcional, kick assist, chute, fisica da bola, movimento ou camera.
- Evidencia desktop e Web local gerada.

## Causa Raiz Do Countdown

O teste vermelho mediu `2` disparos no kickoff inicial e `1` no kickoff pos-gol. A duplicacao vinha do boot/warmup: `_ready_sync()` e `_ready_web_async()` chamavam `_restart_play(false)` com `intro_open == false`, disparando countdown antes do botao `Comecar`; depois `_start_match()` disparava outro countdown. O fix adiciona `start_countdown` em `_restart_play()` e usa `_restart_play(false, false)` nos caminhos de boot/warmup.

## Arquivos Para Review

- `Projetos/JogoDaCopa/modes/football/football_root.gd`
- `Projetos/JogoDaCopa/gameplay/avatar/player_avatar_3d.gd`
- `Projetos/JogoDaCopa/presentation/hud/football_hud.gd`
- `Projetos/JogoDaCopa/tests/unit/test_track06a_match_start.gd`
- `Projetos/JogoDaCopa/tools/capture_track06a_match_start.gd`
- `Projetos/JogoDaCopa/docs/series-06-broadcast-polish-plan.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-06a-match-start-fixes.md`
- `Projetos/JogoDaCopa/docs/screenshots/track-06a/`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-06a-data/`

## Evidencia

- Relatorio: `Projetos/JogoDaCopa/docs/playtest-reports/track-06a-match-start-fixes.md`
- Desktop screenshots: `Projetos/JogoDaCopa/docs/screenshots/track-06a/`
- Web boot screenshot/JSON: `Projetos/JogoDaCopa/docs/playtest-reports/track-06a-data/06a-web-boot.*`

Checks finais:

- `tools/validate.gd`: PASS, `91` testes / `1298` asserts, source integrity `37`.
- Export Web release com `GODOT_THREADS_ENABLED=false`: PASS.
- Chrome boot local: PASS, `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`.
- Captura desktop real: PASS, luma `kickoff=46.6`, `hud=46.6`, `goal=64.9`, limite `<90`.

## Ponto De Handoff

A branch esta pronta para review pre-merge. Nao mover Kanban para Done, nao atualizar `Estado_Atual.md`/`implementation/current-status.md` e nao mergear ate aprovacao visual de Claude + Fabio.

Linha de status: `PASS - 91 testes / 1298 asserts - export Web PASS - web boot local PASS - captura desktop PASS`.

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin

