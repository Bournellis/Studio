# Track 09E - Football Match Presentation Controller V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/football-match-presentation-controller-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--football-match-presentation-controller-v1`
- Status: `LOCAL_VALIDADO`

## Objetivo

Continuar a reducao do `FootballRoot` com uma extracao estreita da apresentacao de partida: snapshots de HUD, refresh HUD/scoreboard, snapshot de resultado, formatacao de estatisticas finais e codigos de uniforme, preservando gameplay, input, fisica, bot, scoring, assets e comportamento publico.

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/modes/football/football_root.gd`
- `Projetos/JogoDaCopa/modes/football/football_match_presentation_controller.gd`
- Testes focados em `Projetos/JogoDaCopa/tests/`, somente se a migracao exigir ajuste de contrato.
- Documentacao local da track, status do projeto e coordenacao.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/documentation-index.md`
- `Projetos/JogoDaCopa/docs/architecture-overview.md`
- `Projetos/JogoDaCopa/docs/work-plan.md`
- `Projetos/JogoDaCopa/implementation/tracks/track-09d-football-match-flow-controller-v1/current-status.md`

## Plano De Validacao

- Import Godot headless da worktree nova.
- `tools/validate.gd`.
- Web export release.
- `tools/validate.gd` com build Web presente/gzip gate.
- Chrome boot local com screenshot/evidencia em `docs/playtest-reports/track-09e-data/`.
- `tools/check_doc_drift.ps1`.
- `git diff --check`.

## Handoff Esperado

Track local validada, dois commits logicos quando possivel, merge local em `main`, e fechamento com `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.

## Resultado

- Novo helper: `Projetos/JogoDaCopa/modes/football/football_match_presentation_controller.gd`.
- `FootballRoot` medido nesta base: `1472 -> 1362` linhas.
- Escopo preservado: sem mudanca de gameplay, input, bot, fisica, scoring ou assets.
- Import headless PASS.
- `tools/validate.gd` PASS: `104` testes, `1826` asserts, `53` fontes.
- Web export release PASS.
- Validate com build Web presente PASS: gzip `30.59 MiB / 50.00 MiB`.
- Web boot Chrome local PASS: `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Evidencia: `Projetos/JogoDaCopa/docs/playtest-reports/track-09e-data/09e-local-web-boot.json` e `.png`.
