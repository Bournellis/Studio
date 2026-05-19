# DraxosMobile

Status: `ARQUIVO_DESIGN` — promovido para `Projetos/draxos-mobile/` em 2026-05-18. Somente leitura e referencia de design.

DraxosMobile e um projeto mobile multi-partes. Substitui os conceitos anteriores RPGMobile e BattleMobile. Nao confundir com Draxos Roguelike Cardgame (projeto Steam separado).

**Projeto ativo:** `Projetos/draxos-mobile/`

## Direcao Atual

Projeto mobile multi-partes com modos implementados ao longo do tempo, todos parte de um unico ecossistema com conta, personagem, base e progressao conectadas. Ainda nao existe decisao de lancamento, formato de temporadas, expansoes ou separacao por apps.

O jogador e um Draxos — mago intergalactico malvado — que cresce em poder. Raca: Draxos. Nome do personagem: definido pelo jogador. Estilo cartoon gore. Sem classes — todos os jogadores tem acesso a todas as armas, spells, passivas e pets.

O primeiro slice sera um produto mobile com infraestrutura seria: conta, persistencia, Base Manager como Altar/Santuario pessoal com botoes animados, Character Autobattler PVP assincrono, matchmaking por poder semelhante, lista de amigos e guilda.

Sistema de combate: 7 tipos de dano (Magico, Fogo, Gelo, Veneno, Choque, Morte, Sangramento), resistencias globais e por tipo, barreiras Magica e Elemental, status effects (Lento, Congelado, Stun, Silenciado, Desarmado) e DoTs por tipo de dano.

Arma do primeiro slice: Varinha Magica com dano Magico — 3 ataques normais + 4o raio com 3x dano. Progressao de 0 a 3 slots de spell, 1 slot de passiva (escolha entre 5), 1 slot de pet (escolha entre 7).

Modos futuros: Character Autobattler PVE com narrativa de ascensao hierarquica, PVP Cardgame Roguelike, Hero Defense e Open World RPG.

## Trabalho Permitido

Leitura e referencia de design apenas. Nao criar codigo, cenas, assets ou projeto Godot a partir daqui.

## Documentos

| Documento | Conteudo |
|---|---|
| `gdd.md` | Game Design Document completo — sistema de combate, personagem, modos, progressao, recursos e plano de producao |
| `pendencias.md` | Registro historico das decisoes de design — P01 e P06 resolvidos, P13 (transicao) resolvido em 2026-05-18 |
