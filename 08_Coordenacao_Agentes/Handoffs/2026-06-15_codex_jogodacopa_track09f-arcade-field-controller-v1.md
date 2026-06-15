# Track 09F - Football Arcade Field Controller V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/football-arcade-field-controller-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--football-arcade-field-controller-v1`
- Status: `LOCAL_VALIDADO`

## Objetivo

Continuar a reducao do `FootballRoot` com uma extracao estreita dos sistemas de campo arcade: coleta/reset/update de boost pads e jump pads, preservando gameplay, input, bot, fisica, scoring, assets, tuning e comportamento publico.

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/modes/football/football_root.gd`
- `Projetos/JogoDaCopa/modes/football/football_arcade_field_controller.gd`
- Testes focados em `Projetos/JogoDaCopa/tests/`, somente se a migracao exigir ajuste de contrato.
- Documentacao local da track, status do projeto e coordenacao.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/modes/football/football_root.gd` na faixa dos boost/jump pads.

## Plano De Validacao

- Import Godot headless da worktree nova.
- `tools/validate.gd`.
- Web export release.
- `tools/validate.gd` com build Web presente/gzip gate.
- Chrome boot local com screenshot/evidencia em `docs/playtest-reports/track-09f-data/`.
- `tools/check_doc_drift.ps1`.
- `git diff --check`.

## Handoff Esperado

Track local validada, dois commits logicos quando possivel, merge local em `main`, e fechamento com `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.

## Resultado

- Novo helper: `Projetos/JogoDaCopa/modes/football/football_arcade_field_controller.gd`.
- `FootballRoot` medido nesta base: `1362 -> 1295` linhas.
- Escopo preservado: sem mudanca de gameplay, input, bot, fisica, scoring, tuning ou assets.
- Import headless PASS.
- `tools/validate.gd` PASS: `104` testes, `1826` asserts, `54` fontes.
- Web export release PASS.
- Validate com build Web presente PASS: gzip `30.59 MiB / 50.00 MiB`.
- Web boot Chrome local PASS: `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Evidencia: `Projetos/JogoDaCopa/docs/playtest-reports/track-09f-data/09f-local-web-boot.json` e `.png`.
