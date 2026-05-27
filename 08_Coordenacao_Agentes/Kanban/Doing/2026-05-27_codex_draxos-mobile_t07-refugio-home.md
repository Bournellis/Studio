# DraxosMobile - T07-C Refugio/Home

- Data: `2026-05-27`
- Agente: `Codex`
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/t07-refugio-home`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t07-refugio-home`
- Objetivo: transformar o Refugio em home full screen com altar/ambiente central, hotspots de navegacao e painel de conta limpo.
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

- `Projetos/draxos-mobile/modes/boot/surfaces/hub_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/hub_account_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/boot.gd` somente se precisar de helper pequeno de rota/Refugio
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/current-status.md`
- Este Doing

## Validacao Planejada

- `tools/validate.gd`
- GUT client focado/completo
- `tools/smoke_session_shell.gd`
- `git diff --check`

## Proximo Handoff

Entregar Refugio/Home e painel de conta prontos para T07-D/T07-E integrarem telas internas e batalha fullscreen sem recriar navegacao global.

## Resultado

- Refugio agora abre como home full screen com painel central de altar/ambiente e resumo curto de conta/save/update.
- Hotspots do Refugio roteiam para Batalha, Base, Social, Competicao, Loja e Perfil/Conta pela shell T07-B.
- Login, registro, guest dev, saves, reset, update e perfil ficaram concentrados na rota `account`.
- Battle Lab e Progression Lab seguem dev/editor-gated; Progression Lab aparece no Refugio quando disponivel.
- `boot.gd` preserva os handlers existentes e recebeu apenas render da rota `account`, aliases e limpeza de referencias de input por rota.

## Validacao

- `tools/validate.gd`: passou com `79/79` testes e `894` asserts.
- GUT client completo: passou com `79/79` testes e `894` asserts.
- `tools/smoke_session_shell.gd`: passou com Auth anonimo, guest e `account/state`.
- `git diff --check`: passou.
