# FpsPlayground - Track 02 Bot Tactical Movement V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/fpsplayground/track02-bot-tactical-movement-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track02-bot-tactical-movement-v1`
- Projeto: `Projetos/FpsPlayground`

## Objetivo

Executar em uma tacada a Track 02 para melhorar a qualidade do bot, com commits separados por estagio.

Foco: bot mais dificil por movimento, contexto tatico arena-agnostico, rotas melhores, anti-repeat/stuck recovery e fairness preservada.

## Arquivos previstos

- `Projetos/FpsPlayground/gameplay/bot/*`
- `Projetos/FpsPlayground/modes/arena/arena_root.gd`
- `Projetos/FpsPlayground/docs/*`
- `Projetos/FpsPlayground/implementation/current-status.md`
- `Projetos/FpsPlayground/implementation/tracks/track-02-bot-tactical-movement-v1/current-status.md`
- `Projetos/FpsPlayground/tests/unit/*`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`

## Base lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/FpsPlayground/AGENTS.md`
- `Projetos/FpsPlayground/implementation/current-status.md`
- `Projetos/FpsPlayground/docs/documentation-index.md`
- `Projetos/FpsPlayground/docs/bot-contract.md`

## Plano de validacao

- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`
- `git diff --check`
- `git status --short`

## Proximo handoff

Mover para Review/Done apos validacao automatizada e registrar smoke humano de bot movement em `docs/validation.md`.

## Resultado

- Track 02 implementada em uma tacada com commits separados.
- `tools/validate.gd`: PASS, GUT `18/18`, `135` asserts.
- `git diff --check`: PASS.
- `tools/check_doc_drift.ps1`: PASS.
- Handoff: Fabio executar smoke humano de bot movement em `Projetos/FpsPlayground/docs/validation.md`.
- PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
