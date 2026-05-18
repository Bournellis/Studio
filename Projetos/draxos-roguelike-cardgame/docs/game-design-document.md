# Game Design Document

- Last Updated: `2026-05-15`
- Status: `Track 01 P05 playtest tuning pass validated`

## Direction

Este e um roguelike de cartas com lore Draxos e batalha em lanes frontais. O jogador e sempre o Comandante Draxos; a identidade de gameplay vem da `Classe`.

O slice atual tem 3 classes fixas: `arcano`, `invocador` e `necromante`. Cada classe define deck inicial, passiva fixa, habilidade ativa fixa, carta custo 2 de entrada, 2 cartas novas de recompensa e upgrades reais Lvl 2/Lvl 3 para as cartas atuais.

## Core Loop

1. Iniciar no hub da nave Draxos.
2. Escolher uma classe antes da run.
3. Entrar no mapa de missao linear.
4. Resolver o proximo no disponivel, com fase pre-combate para descartar/recomprar cartas da mao inicial.
5. Receber recompensas fixas e, quando houver, escolher 1 recompensa entre as opcoes oferecidas.
6. Retornar a nave para ver estado da run, curar com Almas, comprar 1 upgrade de carta por combate ou continuar.
7. Vencer os 13 encontros ou perder se o Comandante cair.

Nao ha meta-progressao por enquanto. Derrota reinicia a run completa.

## Battle Board

O tabuleiro usa slots alinhados por indice: slot 1 contra slot 1, slot 2 contra slot 2, e assim por diante.

- Cada slot ataca o slot diretamente a frente quando ele estiver ocupado.
- O combate resolve em quatro etapas globais: `Iniciativa - Frente`, `Iniciativa - Sobra`, `Combate - Frente`, `Combate - Sobra`.
- Cada criatura ataca no maximo uma vez por ciclo de combate.
- As etapas de frente sao contabilizadas em lote; criaturas que atacam de frente ainda causam dano mesmo se morrerem naquela etapa.
- As etapas de sobra resolvem 1 a 1 por lane, da esquerda para a direita, alternando jogador e inimigo em cada lane.
- Criaturas mortas antes da sua vez de sobra nao atacam, nao atraem `defensor` e nao bloqueiam dano excedente.
- Se uma lane inimiga estiver vazia, a criatura procura o `defensor` inimigo mais proximo da lane; em empate, usa o primeiro da esquerda.
- Se nao houver `defensor`, a sobra aliada mira o heroi inimigo em `duelo`/`chefe_summoner`; nos demais modos mira a criatura inimiga mais proxima.
- Criaturas inimigas sem alvo frontal nem defensor causam dano direto ao jogador.
- Ataques de sobra nao recebem dano de volta.
- O Comandante sempre pode receber dano direto de inimigos sem defensor.
- O heroi inimigo so recebe dano direto nos modos `duelo` e `chefe_summoner`.
- Invocar uma criatura em slot aliado ocupado exige confirmacao de sacrificio; cancelar nao gasta mana nem carta.
- Arrastar uma criatura aliada para slot adjacente vazio move a criatura; arrastar para slot adjacente ocupado troca as duas criaturas de lugar e consome movimento das duas.

## Keywords E Efeitos

- `iniciativa`: causa dano primeiro na lane; se destruir o alvo frontal, esse alvo nao responde na etapa normal.
- `defensor`: atrai ataques de criaturas inimigas sem alvo na lane a frente.
- `reviver`: a criatura morta volta uma vez no mesmo slot, com stats originais e marcador de reviver.
- `regeneracao X`: cura ate X HP no fim de `Resolver Combate`.
- `carnica X`: quando outra criatura aliada ou inimiga morre enquanto esta criatura sobrevive, ela recebe +X/+X permanente na batalha.
- `suicida X`: quando esta criatura morre, causa X de dano a um alvo inimigo aleatorio valido.
- `enfraquecer X`: criatura alvo recebe `-X/-X`.
- `prender`: criatura alvo pula os proximos combates relevantes.
- `remover keywords`: remove keywords ativas da criatura alvo, incluindo `iniciativa`, `defensor`, `reviver`, `regeneracao` e `carnica`.
- `poder de habilidade`: fontes em campo aumentam valores numericos de spells, habilidades de cartas e ativas de classe, sem alterar custos nem stats base.

## Classes

Ver `classes/README.md` e os docs individuais.

- **Arcano:** Fluxo aumenta dano de spells quando a passiva esta desbloqueada.
- **Invocador:** a primeira criatura invocada a cada turno concede +2/+1 permanente para a aliada com maior ATK.
- **Necromante:** Cinzas por mortes em campo; Ritual das Sombras tem dano direto por `Raio das Cinzas`.

Arcano e Invocador desbloqueiam passiva no mapa 8 e ativa no mapa 10. Necromante desbloqueia passiva + Ritual nivel 1 no mapa 8 e recebe Ritual nivel 2 no mapa 10.

## Battle Economy

- Mao inicial com limite base de 3 cartas.
- Antes do primeiro turno de cada combate, o jogador pode marcar cartas da mao com botao direito; ao iniciar o combate, as marcadas sao descartadas e a mao recompra ate o limite.
- Jogar uma carta puxa 1 carta quando possivel.
- Cartas jogadas vao para o descarte.
- Quando o deck esvazia, o descarte e embaralhado de volta.
- Mana inicial de todas as classes: `1`.
- Deck inicial de cada classe tem 9 cartas: 3 tipos custo 1, 3 copias cada.
- Mapa 1 concede +1 mana maxima, levando a run para 2 manas.
- Mapa 2 adiciona automaticamente 3 copias da carta custo 2 atual da classe: `arcano_tempestade`, `invocador_guardiao` ou `necro_zumbi`.
- Mapa 5 concede +1 mana maxima.
- Mapa 6 concede +1 limite de mao.
- O catalogo antigo de cartas do jogador foi removido; cartas inimigas permanecem.
- O ciclo de batalha e: jogadas do jogador, `Resolver Combate`, quatro etapas visuais de combate, escolhas pendentes, regeneracao de fim de combate, manutencao/script, escolhas pendentes, jogadas novas da IA de duelo para o proximo turno, retorno automatico ao jogador.
- Escolhas automaticas geradas por mortes, como `Enfraquecer`, ficam adiadas ate as etapas visuais de combate terminarem. Cartas jogadas manualmente e `Promover` continuam resolvendo imediatamente.
- Menus de Necromante, escolhas pendentes e recompensa de vitoria usam painel translucido com alpha alvo `0.72`.
- Save version atual: `4`. Saves v3 ou anteriores aparecem como antigos/invalidos, podem ser deletados e podem ser sobrescritos por novo jogo.

## Reward System

Existem dois tipos de recompensa:

- **Recompensas fixas:** aplicadas automaticamente no fim do mapa.
- **Recompensas escolhiveis:** o jogador escolhe 1 opcao no modal de vitoria.

Upgrade de carta e carta nova nunca aparecem misturados na mesma recompensa. Quando uma recompensa e de upgrade, as opcoes sao upgrades. Quando e carta nova, as opcoes sao cartas novas. Cada opcao rola raridade de forma estavel: `70% comum`, `25% rara`, `5% ultra rara`.

### Upgrades Por Nivel

Cada tipo de carta pode receber ate 2 upgrades durante a campanha:

- base = Lvl 1;
- primeiro upgrade = Lvl 2;
- segundo upgrade = Lvl 3.

`RunSession.card_upgrade_counts` e a fonte de verdade. O deck da run continua armazenando o ID base da carta; Battle e Deck convertem para a variante efetiva `_lvl2` ou `_lvl3` quando a batalha/tela e aberta. Opcoes de upgrade sao sorteadas de forma estavel pelo seed da run e pelo ID da recompensa entre os tipos elegiveis existentes no deck.

Os mapas 3, 4, 9 e 12 oferecem upgrade. O mapa 6 nao oferece mais upgrade. Upgrades raros adicionam +1 copia da carta ao deck alem do upgrade; upgrades ultra raros adicionam +2 copias.

### Cartas Novas

Cada classe tem 2 cartas novas reais no pool de recompensa atual:

- Arcano: `Bola de Fogo` e `Acelerar`.
- Invocador: `Atacar` e `Golem`.
- Necromante: `Carniceiro` e `Diabrete`.

O mapa 7 oferece as 2 cartas novas da classe. O mapa 11 oferece a carta restante. Cartas novas comuns adicionam 3 copias ao deck, raras adicionam 4 copias e ultra raras adicionam 5 copias. As cartas novas tambem possuem Lvl 2 e Lvl 3.

### Loja De Almas

A tela de Almas oferece cura e 3 opcoes de upgrade de cartas presentes no deck da run que ainda estejam abaixo do Lvl 3. Cada upgrade custa 20 Almas, a compra e limitada a 1 upgrade por combate, e as ofertas atualizam depois de cada vitoria usando o deck pos-recompensa.

## Linear Mission Map

Track 01 usa 13 encontros lineares, sem sidequests por enquanto.

| Mapa | No | Modo | Slots | Mana esperada | Recompensa |
|---|---|---|---|---:|---|
| 1 | `n01_tutorial_primeiro_contato` | `limpar_mesa` | 1/1 | 1 | +1 mana maxima |
| 2 | `n02_tutorial_dois_fronts` | `limpar_mesa` | 2/2 | 2 | 3 copias da carta custo 2 da classe |
| 3 | `n03_tutorial_primeira_onda` | `ondas` | 2/2 | 2 | upgrade de carta, escolha 1 em 3 |
| 4 | `n04_pouso_elemental` | `limpar_mesa` | 3/3 | 2 | upgrade de carta, escolha 1 em 3 |
| 5 | `n05_ondas_iniciais` | `ondas` | 3/3 | 2 | +1 mana maxima |
| 6 | `n06_duelo_inicial` | `duelo` | 3/3 | 3 | +1 limite de mao |
| 7 | `n07_defesa_posicao` | `defesa_posicao` | 3/3 | 3 | carta nova, escolha 1 entre 2 |
| 8 | `n08_chefe_invocador` | `chefe_summoner` | 5/5 | 3 | desbloqueia passiva; Necromante tambem recebe Ritual I |
| 9 | `n09_sobreviver_turnos` | `sobreviver_turnos` | 4/4 | 3 | upgrade de carta, escolha 1 em 3 |
| 10 | `n10_limpeza_elite` | `limpar_mesa` | 4/4 | 3 | desbloqueia ativa; Necromante recebe Ritual II |
| 11 | `n11_ondas_avancadas` | `ondas` | 4/4 | 3 | carta nova restante |
| 12 | `n12_duelo_elite` | `duelo` | 4/4 | 3 | upgrade de carta, escolha 1 em 3 |
| 13 | `n13_chefe_final` | `chefe_summoner` | 5/5 | 3 | vitoria da run |

Todo mapa concede Almas alem das recompensas acima.

## Pending Design

- Playtestar a curva 1 mana -> 2 manas -> 3 manas com descarte pre-combate, loja de upgrades, raridades e inimigos +20%.
- Ajustar dificuldade dos mapas 1-13 apos playtest do novo tuning.
- Ajustar custo de Almas, cura e loja depois que a curva de upgrades/cartas novas estabilizar.

## Propostas de Design (nao implementadas)

Os documentos abaixo registram sessoes de design criativo. Nao sao canon nem
estao no engine. Cada item requer validacao em playtest e decisao de produto
antes de qualquer implementacao.

- `docs/design-proposals/sessao-a-keywords.md` — 20 keywords propostas (Atropelar,
  Escudo, Espinhos, Resistencia, Crescer, Brutal, Drenar, Ecoar, Furia, Congelar,
  Veneno, Inspirar, Pacto, Ressurgir, Entrar, e outras). Inclui priorizacao e
  custo estimado de implementacao.

- `docs/design-proposals/sessao-b-cartas-novas.md` — 6 cartas novas propostas
  por classe (18 cartas total), distribuidas em 4 elementos ao longo de uma rota
  de 29 mapas. Inclui upgrades Lvl 2/Lvl 3, estrutura de recompensas e notas
  de rebalanceamento das cartas existentes.

- `docs/design-proposals/rota-29-mapas.md` — proposta de expansao da rota atual
  de 13 mapas para 29 mapas divididos em 4 elementos (Terra 1-8, Gelo 9-15,
  Ar 16-22, Fogo 23-29). Inclui novos tipos de encontro (Emboscada, Escolta,
  Invasao), 6 formatos de tabuleiro, ~18 efeitos de campo e galeria completa
  de criaturas inimigas por elemento.
