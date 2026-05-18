# Mobile Universe

Status: `P1_CONCEITO`

Mobile Universe e um projeto mobile multi-partes em incubacao conceitual. Substitui os conceitos anteriores RPGMobile e BattleMobile.

## Direcao Atual

Projeto mobile multi-partes com modos implementados ao longo do tempo, todos parte de um unico ecossistema com conta, personagem, base e progressao conectadas. Ainda nao existe decisao de lancamento, formato de temporadas, expansoes ou separacao por apps. O jogador e um mago intergalatico maligno que cresce em poder. Estilo cartoon gore.

O primeiro slice sera um produto mobile com infraestrutura seria: conta, persistencia, Base Manager em formato de cidade/tela com botoes animados, Character Autobattler PVP assincrono no estilo Arena Mobile, matchmaking por poder semelhante, lista de amigos e guilda.

No PVP, o jogador entra em um duelo simples contra outro jogador de poder semelhante. A apresentacao da batalha segue leitura de sidescroller classico, inspirada em Mortal Kombat. Ao vencer, o jogador assiste a uma finalizacao brutal escolhida entre as finalizacoes desbloqueadas.

Economia inicial do primeiro slice: vencer PVP concede Almas. Perder PVP nao remove recursos, mas tambem nao concede recompensa. O jogador pode batalhar indefinidamente, mas as recompensas reduzem conforme ele repete batalhas dentro de uma janela de tempo; em algum ponto, a recompensa chega a zero, mas ainda e possivel batalhar. Os upgrades iniciais sao 1 arma, 3 spells e 2 passivas, todos com level up simples. Amigos e guilda comecam como uma "maozinha" leve para evolucao.

Inicialmente existe apenas um mago principal jogavel. A variedade inicial vem da arma, das spells, das passivas e das skins do mago. Itens, pocoes, pets e arvores mais elaboradas podem entrar no futuro. Classes de mago podem ser exploradas no futuro, mas ainda nao tem regra definida e nao fazem parte do escopo inicial.

O primeiro arco narrativo pertence ao Character Autobattler PVE posterior: batalha automatica com ultimate/spells acionaveis, ascensao do mago dentro de uma sociedade magica hierarquica, do inicio da carreira ate uma posicao equivalente a general, antes da rebeliao contra o mestre supremo e da aventura solo pelo espaco.

Modos futuros incluem PVP Cardgame Roguelike, Hero Defense com o mesmo mago em defesa contra hordas/tower defense, e Open World RPG. PVP/PVE Autobattler tem conexao alta com a base. PVP Cardgame Roguelike, Hero Defense e Open World RPG tem progressao propria com pequenos beneficios de Level Global e de uma base bem evoluida.

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
| `gdd.md` | Game Design Document completo — modos, progressao, fluxo de recursos, conexao entre modos e plano conceitual de producao |
| `pendencias.md` | Lista priorizada de decisoes abertas para resolver antes de producao |

## Proximo Passo

Definir a curva de reducao de Almas e a janela de tempo para recuperar recompensas PVP.
