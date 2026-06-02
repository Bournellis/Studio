# DraxosMobile Hardening Doing: client-shell - Arena loop simplification

## Metadata

- data: `2026-06-02`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `client-shell`
- mode_scope: `autobattler`
- branch: `codex/draxos-mobile/arena-loop-simplification`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-loop-simplification`

## Objetivo

Simplificar o loop visual e textual da Arena PVE/autobattler, preservando todas as funcoes existentes: Refugio -> Preparacao/loadout -> Arena -> duelo -> buff/comportamento -> resumo/recompensa -> continuar.

## Latest Context

- latest Arena loop package: `Track 21 - Arena Loop Unlock And Friction Pass`
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/foundation-responsive-layout-contract.md`
- `Projetos/draxos-mobile/docs/foundation-loop-audit.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/docs/pve-arena-v1.md`
- `Projetos/draxos-mobile/docs/behavior-potion-crafting-v1.md`
- `Projetos/draxos-mobile/implementation/tracks/track-21-arena-loop-unlock-friction/README.md`

## Escopo

- Incluir:
  - simplificacao client-only de copy, hierarquia e paineis da Arena PVE;
  - atalhos visuais para loadout travado, comportamento simples, buffs e recompensa aplicada;
  - capturas locais das telas do loop quando a aplicacao/smokes estiverem executaveis;
  - testes/smokes locais focados no client shell.
- Fora do escopo:
  - backend, schema, migrations ou endpoints;
  - publicacao remota, upload, deploy ou mutation;
  - tuning numerico, economia, recompensas, PVP, novas armas, novas spells, novas pocoes ou conteudo novo;
  - worktrees de outros agentes.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/surfaces/arena_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/hub_surface_refuge_scene_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/hub_surface_preparation_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/battle_replay_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/base_surface_presenter.gd`
- `Projetos/draxos-mobile/tests/client/*`
- `Projetos/draxos-mobile/tools/*` somente se necessario para evidencias locais/screenshot smoke.

## Validation Plan

- `git diff --check`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`

## Handoff Point

Handoff para Fabio apos patch local, screenshots e validacao client. Qualquer publicacao Internal Alpha, tuning de Arena ou mudanca de backend deve virar pacote proprio com aprovacao explicita.

## Resultado

- patch local entregue em `Projetos/draxos-mobile` com simplificacao client-only das telas do loop Arena PVE/autobattler.
- screenshots geradas em `Projetos/draxos-mobile/build/track15_mobile_ux_checkpoint`.
- validacao concluida: `git diff --check`, Godot import headless, GUT client 175/175, `smoke_responsive_layout.gd` e `validate_foundation.ps1 -Profile ClientQuick`.
- handoff registrado em `08_Coordenacao_Agentes/Handoffs/2026-06-02_codex_draxos-mobile_arena-loop-simplification.md`.
