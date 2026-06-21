# Track 14I - Godot Debugger Cleanup V1

- Status: `MERGED_LOCAL`
- Data: `2026-06-20`
- Branch: `codex/fpsplayground/godot-debugger-cleanup-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--godot-debugger-cleanup-v1`

## Objetivo

Rodar o projeto no Godot, analisar o console/debugger e limpar detalhes seguros antes da proxima track de gameplay.

## Achados

- Runtime do menu principal rodou limpo.
- Runtime direto da arena rodou limpo.
- Editor headless emitia warnings de UID/text-path em cenas do addon GUT.
- Editor headless tambem deixava um `SceneTreeTimer` vivo no shutdown por causa de um delay em `addons/gut/gut_plugin.gd`.

## Implementacao

- `D:\Estudio-worktrees\FpsPlayground--codex--godot-debugger-cleanup-v1\Projetos\FpsPlayground\addons\gut\*.tscn/.tres`: UIDs de recursos atualizados para bater com `.gd.uid` e `.import` rastreados.
- `D:\Estudio-worktrees\FpsPlayground--codex--godot-debugger-cleanup-v1\Projetos\FpsPlayground\addons\gut\gut_plugin.gd`: delay de startup do plugin preservado no editor normal e pulado apenas em headless.

## Validacao

- Editor headless import: PASS sem warnings do GUT e sem `ObjectDB instances leaked`.
- Runtime main menu headless: PASS sem warnings.
- Runtime arena headless: PASS sem warnings.
- `tools/validate.gd -- --profile=quick`: PASS, GUT `67/67`, `599 asserts`.
- `tools/validate.gd`: PASS, GUT `67/67`, `599 asserts`.
- `git diff --check`: PASS.
- `tools/check_doc_drift.ps1`: PASS.

## Guardrail

Sem alteracao de gameplay, movimento, mapa, armas, pickups, bot tuning, jump pad force ou telemetry schema.

## Proximo Passo

Fabio/tester confirmar `Relay Foundry V1` no editor; depois seguir para `Multi-Arena Balance Baseline V1`.

## Handoff

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
