# Track 09P - Football Session UI Controller V1

- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/jogodacopa/track09p-session-ui-controller-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09p-session-ui-controller-v1`
- Base: `main` em `42a3cf9d`
- Responsavel: Codex
- Inicio: `2026-06-19`

## Objetivo

Reduzir `FootballRoot` com uma fatia fria e conservadora, extraindo a orquestracao de sessao/UI para `football_session_ui_controller.gd`, sem mudar gameplay, fisica, bot, bola, chute/SUPER, scoring, HUD visual, assets ou tuning.

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/modes/football/football_root.gd`
- `Projetos/JogoDaCopa/modes/football/football_session_ui_controller.gd`
- `Projetos/JogoDaCopa/docs/architecture-overview.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/work-plan.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09p-session-ui-controller.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Kanban/Done/2026-06-19_codex_jogodacopa_track09p-session-ui-controller-v1.md`

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/documentation-index.md`
- `Projetos/JogoDaCopa/docs/architecture-overview.md`
- `Projetos/JogoDaCopa/docs/work-plan.md`

## Validacao Planejada

1. Import headless editor na worktree nova.
2. `tools/validate.gd`.
3. Export release Web.
4. `node --check tools/track04f_chrome_probe.mjs`.
5. Smoke Web local 90s com evidencia em `docs/playtest-reports/track-09p-data/`.
6. `git diff --check`.
7. `D:\Estudio\tools\check_doc_drift.ps1`.

## Resultado

- Criado `modes/football/football_session_ui_controller.gd`.
- `FootballRoot` manteve wrappers finos para `_input`, `_get_escape_target`, `_start_match`, `_set_intro_open`, `_set_menu_open`, `_return_to_main_menu`, `_return_to_main_menu_async` e `_capture_mouse_if_playing`.
- Reducao medida: `FootballRoot` `1051 -> 974` linhas.
- Gameplay, fisica, bot, bola, chute/SUPER, scoring, HUD visual, assets e tuning preservados.

## Validacao Executada

- Import headless editor: PASS.
- `tools/validate.gd`: PASS, `104/104` testes, `1826` asserts, `59` fontes.
- Web export release: PASS.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- `tools/validate.gd` pos-export: PASS, gzip `30.60 MiB / 50.00 MiB`, `104/104` testes, `1826` asserts.
- Chrome Web smoke 90s: PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`, `js_heap_growth -1.26%`.

## Handoff

Fechar com commit local, merge em `main`, worktree limpa e `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
