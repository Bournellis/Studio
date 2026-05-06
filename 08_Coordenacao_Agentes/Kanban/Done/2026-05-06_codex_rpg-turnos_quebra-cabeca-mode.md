# RPG Turnos - Modo Quebra Cabeca

- Data: `2026-05-06`
- Agente: `codex`
- Projeto: `Projetos/rpg-turnos`
- Status: `done`

## Objetivo

Implementar o ultimo modo oficial pequeno pendente: `quebra_cabeca`.

## Escopo

- especificar regra minima local para `quebra_cabeca`
- adicionar encontro JSON com `puzzle_target_slots` e `puzzle_turn_limit`
- vencer ao limpar os alvos do puzzle
- perder se o limite de turnos do jogador acabar sem resolver o puzzle
- nao exigir limpeza de todos os slots inimigos
- expor progresso do puzzle na UI de batalha
- tornar o encontro acessivel no mapa linear
- adicionar testes GUT focados

## Fora de Escopo

- puzzles narrativos fora da batalha
- novas cartas
- novos assets
- editor visual de puzzles

## Resultado

- `quebra_cabeca` implementado em `BattleEngine`
- `enigma_da_ponte` adicionado ao catalogo e ao mapa linear
- HUD de batalha exibe `Alvos X/Y | Turnos A/B`
- vitoria acontece quando os alvos marcados caem, mesmo com suporte inimigo vivo
- derrota acontece quando o limite de turnos do jogador expira sem resolver o puzzle
- validacao verde: 77/77 testes
