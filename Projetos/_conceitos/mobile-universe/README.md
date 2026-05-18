# DraxosMobile

Status: `P1_CONCEITO`

DraxosMobile e um projeto mobile multi-partes em incubacao conceitual. Substitui os conceitos anteriores RPGMobile e BattleMobile. Nao confundir com Draxos Roguelike Cardgame (projeto Steam separado).

## Direcao Atual

Projeto mobile multi-partes com modos implementados ao longo do tempo, todos parte de um unico ecossistema com conta, personagem, base e progressao conectadas. Ainda nao existe decisao de lancamento, formato de temporadas, expansoes ou separacao por apps.

O jogador e um Draxos — mago intergalactico malvado — que cresce em poder. Raca: Draxos. Nome do personagem: definido pelo jogador. Estilo cartoon gore. Sem classes — todos os jogadores tem acesso a todas as armas, spells, passivas e pets.

O primeiro slice sera um produto mobile com infraestrutura seria: conta, persistencia, Base Manager como Altar/Santuario pessoal com botoes animados, Character Autobattler PVP assincrono, matchmaking por poder semelhante, lista de amigos e guilda.

Sistema de combate: 7 tipos de dano (Magico, Fogo, Gelo, Veneno, Choque, Morte, Sangramento), resistencias globais e por tipo, barreiras Magica e Elemental, status effects (Lento, Congelado, Stun, Silenciado, Desarmado) e DoTs por tipo de dano.

Arma do primeiro slice: Varinha Magica com dano Magico — 3 ataques normais + 4o raio com 3x dano. Progressao de 0 a 3 slots de spell, 1 slot de passiva (escolha entre 5), 1 slot de pet (escolha entre 7).

Modos futuros: Character Autobattler PVE com narrativa de ascensao hierarquica, PVP Cardgame Roguelike, Hero Defense e Open World RPG.

## Trabalho Permitido

- Conceito
- Pitch
- Design
- Referencias

## Restricao Operacional

Nao criar codigo, cenas, assets de implementacao ou projeto Godot sem pedido explicito do usuario.

## Documentos

| Documento | Conteudo |
|---|---|
| `gdd.md` | Game Design Document completo — sistema de combate, personagem, modos, progressao, recursos e plano de producao |
| `pendencias.md` | Lista priorizada de decisoes abertas para resolver antes de producao |

## Proximo Passo

Resolver P02 — Numeros e Formulas: valores base de stats, curvas de crescimento, custos de upgrade e formulas de combate para viabilizar prototipagem.
