# Decisao: Split Do FpsShooter Em FpsPlayground E JogoDaCopa

## Metadata

- data: `2026-06-10`
- decisor: `Usuario`
- projeto: `estudio`
- prioridade_portfolio: `P2_IMPLEMENTACAO`

## Contexto

O antigo `Projetos/FpsShooter` (FPS Playground) acumulou duas direcoes incompativeis: o laboratorio FPS (Arena Shooter) e o ramo de futebol que nasceu como experimento e foi aceito como direcao propria.

## Decision

Separar em dois projetos oficiais independentes: `Projetos/FpsPlayground/` (somente o laboratorio FPS) e `Projetos/JogoDaCopa/` (futebol/minigames de copa). Cada um com `AGENTS.md`, `current-status`, plano e `validate.gd` proprios. O diretorio residual `FpsShooter/` foi removido em 2026-06-10 apos o split.

## Alternatives Considered

- Manter um projeto unico com dois modos: rejeitado; escopos e restricoes operacionais divergem (armas vs futebol).
- Apagar o ramo FPS: rejeitado; o laboratorio preserva aprendizados de feel/bot.

## Impact

Roteamento de agentes sem ambiguidade; restricoes operacionais especificas por projeto; `FpsShooter` vira nome legado roteado para `FpsPlayground`.

## Review When

Se um dos projetos for arquivado ou se houver fusao de mecanicas aprovada por documento local.
