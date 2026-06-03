# DraxosMobile Hardening Doing: client-shell - Arena Replay Reward UX

## Metadata

- data: `2026-06-03`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `client-shell`
- mode_scope: `autobattler`
- branch: `codex/draxos-mobile/arena-replay-reward-ux`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-replay-reward-ux`

## Objetivo

Reforcar a leitura de combate, recompensa e proximo passo no replay/resumo da Arena PVE sem alterar `battle_log_v1` ou rewards backend.

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
  - `Projetos/draxos-mobile/modes/boot/surfaces/battle_replay_presenter.gd`
- Fora do escopo:
  - backend, schema, tuning, economia, PVP, conteudo novo;
  - telas de selecao/tentativa/buff/loadout;
  - remote mutation/publicacao.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/surfaces/battle_replay_presenter.gd`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-03_codex_draxos-mobile_arena-replay-reward-ux.md`

## Validation Plan

- `git diff --check`
- targeted GUT/client replay tests after integration
- `tools/smoke_responsive_layout.gd` after integration

## Handoff Point

Handoff para `validation-release` quando o replay/resumo da Arena preservar os contratos e estiver pronto para captura visual integrada.
