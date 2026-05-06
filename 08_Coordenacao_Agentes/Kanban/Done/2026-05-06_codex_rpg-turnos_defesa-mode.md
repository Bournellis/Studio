# RPG Turnos - Modo Defesa

- Data: `2026-05-06`
- Agente: `codex`
- Projeto: `Projetos/rpg-turnos`
- Status: `done`

## Objetivo

Implementar o proximo modo oficial pequeno: `defesa`.

## Escopo

- especificar regra minima local para `defesa`
- adicionar encontro JSON usando `mode: "defesa"`
- vencer por sobreviver ao numero definido de turnos inimigos
- derrota se o heroi do jogador chegar a 0 HP
- nao vencer automaticamente ao limpar a mesa inimiga
- expor progresso da defesa na UI de batalha
- tornar o encontro acessivel no mapa linear
- adicionar testes GUT focados

## Fora de Escopo

- sistema de estruturas/objetivos aliados separados do heroi
- novos assets
- novas cartas
- IA especial alem da pressao de mesa atual

## Resultado

- `defesa` implementado em `BattleEngine`
- `defesa_do_portao` adicionado ao catalogo e ao mapa linear
- HUD de batalha exibe `Defesa X/Y`
- limpar a mesa inimiga nao vence automaticamente no modo
- validacao verde: 69/69 testes
