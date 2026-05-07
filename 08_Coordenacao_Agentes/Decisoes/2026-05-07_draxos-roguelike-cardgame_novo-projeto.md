# Decisao: Draxos Roguelike Cardgame como novo projeto

## Metadata

- data: `2026-05-07`
- decisor: `Usuario`
- projeto: `draxos-roguelike-cardgame`

## Contexto

O usuario quer explorar uma segunda forma para o jogo Draxos/cardgame, separada do RPG Turnos atual. Esta forma usa o mesmo lore, personagens, classes, narrativa e objetivo geral, mas remove exploracao RPG livre e usa hub/nave, mapa de missao e card battles roguelike.

## Decision

Criar `Projetos/draxos-roguelike-cardgame/` como novo projeto oficial do Estudio, nao como variante de `rpg-turnos`.

O projeto pode reaproveitar base tecnica estreita de `rpg-turnos`, mas suas regras de cartas, deck, mana/recurso, compra, recompensas, run e tabuleiro sao locais.

## Alternatives Considered

- Implementar como modo dentro de `rpg-turnos`.
- Criar somente documentos antes de copiar codigo.
- Reescrever tudo sem aproveitar o scaffold Godot existente.

## Impact

O Estudio passa a ter tres projetos oficiais em `Projetos/`. Agentes devem tratar mecanicas do novo projeto como independentes e registrar qualquer reuso significativo no proprio projeto.

## Review When

Revisar depois que Track 00 entregar o primeiro slice jogavel com ShipHub, RunMap, batalha simplificada e primeiro chefe summoner.
