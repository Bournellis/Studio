# FpsPlayground - Godot Debugger Cleanup V1

- Data: `2026-06-20`
- Agente: `Codex`
- Branch: `codex/fpsplayground/godot-debugger-cleanup-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--godot-debugger-cleanup-v1`
- Projeto: `Projetos/FpsPlayground`
- Status: `CONCLUIDO - MERGE_LOCAL`

## Objetivo

Rodar o projeto no Godot, analisar o console/debugger e limpar detalhes seguros antes da proxima track de gameplay.

## Resultado

- Runtime do menu principal rodou sem warnings.
- Runtime direto da arena rodou sem warnings.
- Warnings de UID/text-path do GUT foram removidos alinhando UIDs das cenas aos `.uid` e `.import` rastreados.
- Leak de `SceneTreeTimer` em editor headless foi removido pulando o delay do plugin GUT somente em headless.
- Nenhuma mudanca de gameplay, movimento, mapa, armas, pickups, bot tuning, jump pad force ou telemetry schema.

## Validacao

- Editor headless import: PASS sem warnings do GUT e sem `ObjectDB instances leaked`.
- Runtime main menu headless: PASS sem warnings.
- Runtime arena headless: PASS sem warnings.
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd -- --profile=quick`: PASS, GUT `67/67`, `599 asserts`.
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`: PASS, GUT `67/67`, `599 asserts`.
- `git diff --check`: PASS.
- `D:\Estudio\tools\check_doc_drift.ps1`: PASS.

## Proximo Passo

Fabio/tester confirmar `Relay Foundry V1` no editor; depois seguir para `Multi-Arena Balance Baseline V1`.

## Handoff

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
