# FpsPlayground - Track 03 Arena Tactical Context Proof V1

- Agente: Codex
- Branch: `codex/fpsplayground/track03-arena-tactical-context-proof-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track03-arena-tactical-context-proof-v1`
- Projeto: `Projetos/FpsPlayground/`
- Base: Track 02 bot tactical movement aprovada por Fabio em 2026-06-15.
- Objetivo: provar que o bot usa contexto tatico de arena em mais de um layout, com uma nova arena jogavel e selecao no menu.
- Arquivos pretendidos: docs/status, catalogo de arenas, builders de arena, `arena_root.gd`, menu, testes GUT e validacao.
- Docs lidos: `Prioridades_Estudio.md`, `Estado_Atual.md`, `AGENTS.md`, `implementation/current-status.md`, `docs/work-plan.md`, `docs/bot-tactical-context.md`, `docs/validation.md`.
- Plano de validacao: `tools/validate.gd`; smoke manual em `Duel Pit V2` e `Relay Foundry V1`; checar bot, pickups, jump pads, restart e retorno ao menu nas duas arenas.
- Status: `DONE`
- Validacao automatica: `tools/validate.gd` PASS `20/20`, `175 asserts`; warnings GUT UID/text-path conhecidos.
- Handoff original: Fabio/tester executar smoke humano em `Duel Pit V2` e `Relay Foundry V1`.
- Sincronizacao remota: resolvida por baseline posterior; nenhuma acao viva neste card.

## Escopo

- Extrair dados de layout para catalogo arena-agnostico.
- Preservar `Duel Pit V2` como baseline selecionavel.
- Adicionar `Relay Foundry V1` com geometria, rotas, pontos taticos, pickups e jump pads proprios.
- Garantir que o bot receba contexto tatico da arena ativa.
- Adicionar testes para duas arenas e para a selecao de layout.

## Entregue

- Catalogo `ArenaLayoutCatalog`.
- Builder `ArenaRelayFoundryLayoutBuilder`.
- Selecao de arena no menu.
- Testes de catalogo, menu e runtime multi-arena.

## Fora De Escopo

- Nova arma.
- Tuning numerico agressivo de aim/dano.
- Multiplayer/backend/export/Web/mobile.
- Mudanca de identidade visual final.

## Fechamento

- Fechado em micro-track documental de 2026-06-20.
- Track incorporada ao baseline aprovado posterior de `FpsPlayground`.
