# DraxosMobile - T07-D App Screens

- Data: `2026-05-27`
- Agente: `Codex`
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/t07-app-screens`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t07-app-screens`
- Objetivo: adaptar Base, Social, Competicao e Loja para telas internas abertas a partir do Refugio, com Voltar, portrait/landscape, scroll confortavel e sem lista de abas.
- Status: `COMPLETE_VALIDATED`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/implementation-plan.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/surfaces/base_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/social_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/competition_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/shop_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/boot.gd` (somente ajustes pequenos comuns, se necessario)
- `Projetos/draxos-mobile/tests/client/`
- `Projetos/draxos-mobile/implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/`

## Validacao Planejada

- `tools/smoke_foundation_surfaces.gd`
- `tools/validate.gd`
- GUT client
- `git diff --check`

## Proximo Handoff

Entregar surfaces internas T07-D prontas para integracao com Refugio/Home e validacao PC/Web da Track 07.

## Resultado

- Base, Social, Competicao e Loja continuam com presenters render-only, agora em telas internas responsivas.
- `boot.gd` recebeu helper comum de layout de paineis: portrait/narrow em uma coluna, landscape/wide em duas colunas.
- As surfaces preservam rotas oficiais, Voltar, `TouchScrollContainer`, acoes existentes e mensagens de contrato.
- Nao houve alteracao de endpoint, schema, economia, ranking, contratos HTTP, battle files ou `hub_surface_presenter.gd`.

## Validacao

- `tools/smoke_foundation_surfaces.gd`: passou.
- `tools/validate.gd`: passou com `79/79` testes e `897` asserts.
- GUT client completo: passou com `79/79` testes e `897` asserts.
- `git diff --check`: passou.
