# DraxosMobile Hardening Doing: client-shell - Arena Loop UX Client

## Metadata

- data: `2026-06-03`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `client-shell`
- mode_scope: `autobattler`
- branch: `codex/draxos-mobile/arena-loop-ux-client`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-loop-ux-client`

## Objetivo

Simplificar as telas de Preparacao, selecao da Arena, tentativa ativa, loadout travado e escolha de buff sem mudar contrato backend.

## Latest Context

- latest published package: `FIRST_ACCESS_RUNTIME_PUBLISHED_INTERNAL_ALPHA`
- latest Arena loop package: `Track 21 - Arena Loop Unlock And Friction Pass`
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/docs/pve-arena-v1.md`
- `Projetos/draxos-mobile/docs/foundation-responsive-layout-contract.md`

## Escopo

- Incluir:
  - `Projetos/draxos-mobile/modes/boot/surfaces/arena_surface_presenter.gd`
  - `Projetos/draxos-mobile/modes/boot/surfaces/hub_surface_preparation_presenter.gd`
- Fora do escopo:
  - backend, schema, tuning, economia, PVP, conteudo novo;
  - replay/recompensa, exceto leitura de contexto;
  - remote mutation/publicacao.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/surfaces/arena_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/hub_surface_preparation_presenter.gd`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-03_codex_draxos-mobile_arena-loop-ux-client.md`

## Validation Plan

- `git diff --check`
- Godot `validate.gd`
- targeted GUT/client tests after integration
- `tools/smoke_responsive_layout.gd` after integration

## Handoff Point

Handoff para `validation-release` quando as telas client-shell estiverem alteradas e prontas para testes integrados com replay/recompensa.
