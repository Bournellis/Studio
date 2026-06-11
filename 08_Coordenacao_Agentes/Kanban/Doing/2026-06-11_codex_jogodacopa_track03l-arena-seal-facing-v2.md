# Track 03L - Arena Seal & Character Facing V2

- Data: `2026-06-11`
- Agente: `Codex`
- Branch: `codex/jogodacopa/track03l-arena-seal-facing-v2`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03l-arena-seal-facing-v2`
- Projeto: `Projetos/JogoDaCopa`
- Status: `DOING`

## Objetivo

Executar a Track 03L V2, substituindo a 03L anterior nao executada, com escopo fechado:

- remover o rodape/rampas de canto e laterais da arena;
- fechar o vao perimetral superior com vidro ate o teto;
- fechar o caixote acima dos gols com painel frontal colidivel;
- ativar CCD na bola sem alterar feel fisico;
- adicionar teste permanente de estanqueidade e tunneling;
- fazer o avatar visual do player mirar a direcao de movimento mantendo yaw logico/mira/chute pela camera;
- preservar o comportamento atual do bot.

## Arquivos Previstos

- `Projetos/JogoDaCopa/gameplay/football/`
- `Projetos/JogoDaCopa/modes/football/`
- `Projetos/JogoDaCopa/gameplay/avatar/`
- `Projetos/JogoDaCopa/tests/`
- `Projetos/JogoDaCopa/tools/validate.gd`
- `Projetos/JogoDaCopa/docs/code-review-track03k-pose-restore-v2.md`
- `Projetos/JogoDaCopa/docs/screenshots/track-03l-arena/`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/implementation/tracks/track-03l-arena-seal-facing-v2/`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Kanban/Done/`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/code-review-track03k-pose-restore-v2.md`

## Plano De Validacao

- Provar falha pre-fix do teste de estanqueidade/tunneling contra a baseline 03K e registrar no doc da track.
- Rodar testes GUT adicionados/alterados para arena e facing.
- Rodar `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`.
- Capturar screenshots da arena em `docs/screenshots/track-03l-arena/`.
- Rodar `git diff --check`, `git status --short` e `tools/check_doc_drift.ps1`.

## Handoff

Proximo handoff esperado: track completa com validate PASS, screenshots para Fabio, doc da track com causa raiz/progresso, `Estado_Atual.md` atualizado para playtest de confirmacao geral, branch mergeada em `main`, worktree removida e status limpo.
