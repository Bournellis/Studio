# RPG Turnos - Modo Chefe Multiparte

- Data: `2026-05-06`
- Agente: `codex`
- Projeto: `Projetos/rpg-turnos`
- Status: `done`

## Objetivo

Implementar o proximo modo oficial pequeno: `chefe_multiparte`.

## Escopo

- especificar regra minima local para `chefe_multiparte`
- adicionar encontro JSON com `boss_part_slots`
- vencer ao destruir todas as partes do chefe
- nao exigir limpeza de todos os slots inimigos
- derrota se o heroi do jogador chegar a 0 HP
- expor progresso das partes na UI de batalha
- tornar o encontro acessivel no mapa linear
- adicionar testes GUT focados

## Fora de Escopo

- transformacao visual do chefe
- fases com troca de deck/IA entre partes
- novas cartas
- novos assets

## Resultado

- `chefe_multiparte` implementado em `BattleEngine`
- `colosso_fragmentado` adicionado ao catalogo e ao mapa linear
- HUD de batalha exibe `Partes X/Y`
- vitoria acontece quando todas as partes marcadas caem, mesmo com suporte inimigo vivo
- validacao verde: 73/73 testes
