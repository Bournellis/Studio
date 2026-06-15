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
- Handoff previsto: mover para Review/Done apos validacao automatica, documentacao fechada e pendencia de push declarada para Fabio.

## Escopo

- Extrair dados de layout para catalogo arena-agnostico.
- Preservar `Duel Pit V2` como baseline selecionavel.
- Adicionar `Relay Foundry V1` com geometria, rotas, pontos taticos, pickups e jump pads proprios.
- Garantir que o bot receba contexto tatico da arena ativa.
- Adicionar testes para duas arenas e para a selecao de layout.

## Fora De Escopo

- Nova arma.
- Tuning numerico agressivo de aim/dano.
- Multiplayer/backend/export/Web/mobile.
- Mudanca de identidade visual final.
