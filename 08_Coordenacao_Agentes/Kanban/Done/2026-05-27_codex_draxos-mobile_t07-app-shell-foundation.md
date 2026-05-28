# DraxosMobile - T07-B App Shell/Foundation

- Data: `2026-05-27`
- Agente: `Codex`
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/t07-app-shell-foundation`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t07-app-shell-foundation`
- Objetivo: criar a fundacao de apresentacao mobile para rotas, back stack, orientacao e scroll/touch.
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

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/boot.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/`
- `Projetos/draxos-mobile/tests/client/`
- `Projetos/draxos-mobile/implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/`

## Validacao Planejada

- `tools/validate.gd`
- GUT client
- `git diff --check`

## Proximo Handoff

Liberar T07-C, T07-D e T07-E para trabalhar em paralelo sobre a fundacao de rotas/layout.

## Resultado

- Shell sem nav global tipo abas.
- Rotas oficiais e aliases de compatibilidade instalados.
- Back stack com `refuge_home` como root.
- Helper Android para landscape em `battle_running`.
- Scroll/touch foundation com alvo de scrollbar maior e botoes pass-through.

## Validacao

- `tools/validate.gd`: passou com `77/77` testes e `865` asserts.
- GUT completo: passou com `77/77` testes e `865` asserts.
- `git diff --check`: passou.
