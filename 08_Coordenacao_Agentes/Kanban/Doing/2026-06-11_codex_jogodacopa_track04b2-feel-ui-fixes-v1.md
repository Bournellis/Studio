# Track 04B2 - Feel & UI Fixes V1

- Data: 2026-06-11
- Agente: Codex
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/jogodacopa/track04b2-feel-ui-fixes-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04b2-feel-ui-fixes-v1`
- Base: `main` em `8d4bcaa` (`docs(jogodacopa): preserve claude release planning notes`)
- Status: DOING

## Objetivo

Implementar a Track 04B2 conforme especificacao de Fabio: dash sem teleporte, pulo vertical puro sem input direcional, result panel clicavel, e tela inicial sem fundo preto.

## Escopo Permitido

- `Projetos/JogoDaCopa/gameplay/player/fps_player_controller.gd`
- `Projetos/JogoDaCopa/gameplay/football/football_bot.gd` somente para paridade de dash/pulo
- `Projetos/JogoDaCopa/modes/football/football_root.gd`
- `Projetos/JogoDaCopa/modes/menu/main_menu_root.gd`
- `Projetos/JogoDaCopa/presentation/hud/football_hud.gd`
- `Projetos/JogoDaCopa/presentation/camera/**`
- `Projetos/JogoDaCopa/tests/unit/test_bootstrap.gd`
- Documentacao propria da track

Fora de escopo: `gameplay/avatar/**`, shaders de avatar, merge em `main`, publicacao remota.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`

## Plano De Validacao

- `git diff --check`
- Validacao Godot headless: `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`
- Testes novos/ajustados para dash com curva, pulo vertical puro, clique real nos paineis e luminancia do menu.
- Evidencias visuais: dash em 4 frames, pulo parado vs em movimento, result panel com cursor, menu em 1080p e 720p.

## Proximo Handoff

Fechar na branch com `validate PASS`, doc de track/playtest-report e handoff para review de Claude marcado como `WORKTREE_VERIFIED`, sem merge em main.
