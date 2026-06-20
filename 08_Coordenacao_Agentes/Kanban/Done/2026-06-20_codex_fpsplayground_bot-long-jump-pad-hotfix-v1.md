# FpsPlayground - Bot Long Jump Pad Hotfix V1

- Data: `2026-06-20`
- Agente: `Codex`
- Branch: `codex/fpsplayground/bot-long-jump-pad-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--bot-long-jump-pad-hotfix-v1`
- Projeto: `Projetos/FpsPlayground`
- Status: `CONCLUIDO - MERGE_LOCAL`

## Objetivo

Restaurar a confiabilidade do bot no long jump pad de `Relay Foundry V1` sem alterar o feel aprovado do player.

## Resultado

- Bot agora usa calculo route-aware somente para jump pad launch de `actor_id == &"bot"`.
- Player continua usando a forca fixa aprovada de jump pad.
- Testes voltaram a cobrir velocidade por rota e pouso do bot no primeiro uso do long jump pad.
- Documentacao local e snapshots de coordenacao foram atualizados para Track 14H.

## Validacao

- `git diff --check`: PASS
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd -- --profile=quick`: PASS, GUT `67/67`, `599 asserts`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`: PASS, GUT `67/67`, `599 asserts`
- `D:\Estudio\tools\check_doc_drift.ps1`: PASS

## Proximo Passo

Fabio/tester confirmar o bot em `Relay Foundry V1`; depois seguir para `Multi-Arena Balance Baseline V1`.

## Handoff

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
