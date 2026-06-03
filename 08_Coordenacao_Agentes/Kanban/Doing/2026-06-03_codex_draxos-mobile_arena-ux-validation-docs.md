# DraxosMobile Hardening Doing: validation-release - Arena UX Validation Docs

## Metadata

- data: `2026-06-03`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `validation-release`
- mode_scope: `autobattler`
- branch: `codex/draxos-mobile/arena-ux-validation-docs`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-ux-validation-docs`

## Objetivo

Integrar as lanes de UX client-only da Arena PVE, atualizar testes/docs minimos e validar o pacote sem publicacao remota.

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
  - integracao das branches `arena-loop-ux-client` e `arena-replay-reward-ux`;
  - testes client/GUT;
  - docs vivos minimos se houver drift operacional;
  - capturas locais do loop Arena.
- Fora do escopo:
  - backend, schema, tuning, economia, PVP, conteudo novo;
  - upload/deploy/manifest/publicacao remota.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-03_codex_draxos-mobile_arena-ux-validation-docs.md`
- `08_Coordenacao_Agentes/Handoffs/2026-06-03_codex_draxos-mobile_arena-ux-validation-docs.md`

## Validation Plan

- `git diff --check`
- Godot `validate.gd`
- GUT `tests/client`
- `tools/smoke_responsive_layout.gd`
- `validate_foundation.ps1 -Profile ClientQuick`
- `tools/capture_track15_mobile_ux.gd`

## Handoff Point

Handoff final quando integracao, validacao local e screenshots estiverem concluidos, com worktree limpo ou mudancas restantes listadas.
