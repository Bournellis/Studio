# Game Design Document

- Last Updated: `2026-05-15`
- Status: `Track 01 13-map early-game reward update validated`

## Direction

Este e um roguelike de cartas com lore Draxos e batalha em lanes frontais. O jogador e sempre o Comandante Draxos; a identidade de gameplay vem da `Classe`.

O slice atual tem 3 classes fixas: `arcano`, `invocador` e `necromante`. Cada classe define deck inicial, passiva fixa, habilidade ativa fixa, carta custo 2 de entrada e pool placeholder de cartas futuras.

## Core Loop

1. Iniciar no hub da nave Draxos.
2. Escolher uma classe antes da run.
3. Entrar no mapa de missao linear.
4. Resolver o proximo no disponivel.
5. Receber recompensas fixas e, quando houver, escolher 1 recompensa entre 3 opcoes.
6. Retornar a nave para ver estado da run, curar com Almas ou continuar.
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
- `enfraquecer X`: criatura alvo recebe `-X/-X`.
- `prender`: criatura alvo pula os proximos combates relevantes.
- `poder de habilidade`: fontes em campo aumentam valores numericos de spells, habilidades de cartas e ativas de classe, sem alterar custos nem stats base.

## Classes

Ver `classes/README.md` e os docs individuais.

- **Arcano:** Fluxo aumenta dano de spells quando a passiva esta desbloqueada.
- **Invocador:** a primeira criatura invocada a cada turno concede +2/+1 permanente para a aliada com maior ATK.
- **Necromante:** Cinzas por mortes em campo; Ritual das Sombras tem dano direto por `Raio das Cinzas`.

Arcano e Invocador desbloqueiam passiva no mapa 8 e ativa no mapa 10. Necromante desbloqueia passiva + Ritual nivel 1 no mapa 8 e recebe Ritual nivel 2 no mapa 10.

## Battle Economy

- Mao inicial com limite base de 3 cartas.
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
- O ciclo de batalha e: jogadas do jogador, `Resolver Combate`, quatro etapas visuais de combate, escolhas pendentes, manutencao/script, escolhas pendentes, jogadas novas da IA de duelo para o proximo turno, retorno automatico ao jogador.

## Reward System

Existem dois tipos de recompensa:

- **Recompensas fixas:** aplicadas automaticamente no fim do mapa.
- **Recompensas escolhiveis:** o jogador escolhe 1 entre 3 opcoes no modal de vitoria.

Upgrade de carta e carta nova nunca aparecem misturados na mesma recompensa. Quando uma recompensa e de upgrade, as 3 opcoes sao upgrades. Quando e carta nova, as 3 opcoes sao cartas novas.

### Upgrades Placeholder

Cada carta pode receber ate 2 upgrades durante a campanha. O primeiro upgrade representa a escolha de um entre dois ramos futuros. O segundo upgrade e uma opcao unica, pois aplica o ramo restante. Os efeitos finais dos ramos estao **A definir em sessao de design**; o sistema atual registra o upgrade sem alterar mecanica da carta.

### Cartas Novas Placeholder

Cada classe possui um pool placeholder de 6 cartas de recompensa, com custos 1-3. Quando o jogador escolhe uma carta nova, 3 copias entram no deck da run. Nomes, efeitos, arte e balanceamento finais dessas cartas estao **A definir em sessao de design**.

## Linear Mission Map

Track 01 usa 13 encontros lineares, sem sidequests por enquanto.

| Mapa | No | Modo | Slots | Mana esperada | Recompensa |
|---|---|---|---|---:|---|
| 1 | `n01_tutorial_primeiro_contato` | `limpar_mesa` | 1/1 | 1 | +1 mana maxima |
| 2 | `n02_tutorial_dois_fronts` | `limpar_mesa` | 2/2 | 2 | 3 copias da carta custo 2 da classe |
| 3 | `n03_tutorial_primeira_onda` | `ondas` | 2/2 | 2 | upgrade de carta, escolha 1 em 3 |
| 4 | `n04_pouso_elemental` | `limpar_mesa` | 3/3 | 2 | upgrade de carta, escolha 1 em 3 |
| 5 | `n05_ondas_iniciais` | `ondas` | 3/3 | 2 | +1 mana maxima |
| 6 | `n06_duelo_inicial` | `duelo` | 3/3 | 3 | +1 limite de mao e upgrade de carta, escolha 1 em 3 |
| 7 | `n07_defesa_posicao` | `defesa_posicao` | 3/3 | 3 | carta nova, escolha 1 em 3 |
| 8 | `n08_chefe_invocador` | `chefe_summoner` | 5/5 | 3 | desbloqueia passiva; Necromante tambem recebe Ritual I |
| 9 | `n09_sobreviver_turnos` | `sobreviver_turnos` | 4/4 | 3 | upgrade de carta, escolha 1 em 3 |
| 10 | `n10_limpeza_elite` | `limpar_mesa` | 4/4 | 3 | desbloqueia ativa; Necromante recebe Ritual II |
| 11 | `n11_ondas_avancadas` | `ondas` | 4/4 | 3 | carta nova, escolha 1 em 3 |
| 12 | `n12_duelo_elite` | `duelo` | 4/4 | 3 | upgrade de carta, escolha 1 em 3 |
| 13 | `n13_chefe_final` | `chefe_summoner` | 5/5 | 3 | vitoria da run |

Todo mapa concede Almas alem das recompensas acima.

## Pending Design

- Definir nomes, efeitos, artes e balanceamento das 6-8 cartas de recompensa por classe.
- Definir os dois ramos de upgrade de cada carta.
- Playtestar a curva 1 mana -> 2 manas -> 3 manas.
- Ajustar almas, cura e loja depois que cartas novas/upgrades finais existirem.
