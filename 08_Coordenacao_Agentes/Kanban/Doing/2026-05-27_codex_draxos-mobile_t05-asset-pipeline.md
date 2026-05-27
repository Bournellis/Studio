# T05-E - DraxosMobile Asset Pipeline

- Data: `2026-05-27`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/t05-asset-pipeline`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t05-asset-pipeline`
- Status: `READY_FOR_INTEGRATION`

## Objetivo

Preparar a fundacao de pipeline para assets reais no DraxosMobile sem importar arte final, sem trocar visual procedural e sem mudar comportamento de jogo.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/implementation-plan.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/agent-prompts.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/assets/README.md`
- `Projetos/draxos-mobile/core/asset_ids.gd`
- `Projetos/draxos-mobile/tests/client/test_content_foundation.gd`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/asset-pipeline-notes.md`
- Este registro Doing.

## Validacao Planejada

- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t05-asset-pipeline\Projetos\draxos-mobile -s res://tools/validate.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t05-asset-pipeline\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t05-asset-pipeline\Projetos\draxos-mobile -s res://tools/smoke_exports.gd`
- `git diff --check`

## Proximo Handoff

Entregar branch com convencoes documentadas, ids/path estaveis testados e fallback para arte ausente validado para integracao T05-H.

## Resultado

- `assets/README.md` criou o contrato de pastas, nomes, formatos, import policy Godot, fallback e estabilidade de ids.
- `core/asset_ids.gd` ganhou categorias sem mudar paths existentes.
- GUT cobre ids, categorias, paths estaveis e fallback de arte ausente.
- Validado com `tools/validate.gd`, GUT client, `tools/smoke_exports.gd` e `git diff --check`.
