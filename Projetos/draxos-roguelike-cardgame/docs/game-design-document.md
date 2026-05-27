# Game Design Document

- Last Updated: `2026-05-27`
- Status: `Track 02 complete-run baseline`

## Direction

Este e um roguelike de cartas com lore Draxos e batalha em lanes frontais. O jogador e sempre o Comandante Draxos; a identidade de gameplay vem da `Classe`.

O baseline vivo e Track 02: 3 classes, rota fixa de 29 mapas, save/snapshot v5, recompensas de producao, loja de Almas expandida, reliquias universais, keywords/status completos para a track, galerias inimigas Terra/Gelo/Ar/Fogo, AI/intent inimiga, modos/formatos/field effects e boss hooks.

## Core Loop

1. Iniciar no hub da nave Draxos.
2. Escolher uma classe antes da run.
3. Entrar no mapa de missao linear de 29 mapas.
4. Resolver o proximo no disponivel.
5. Jogar batalha em lanes com descarte marcado na fase principal e `Resolver Combate`.
6. Receber recompensas fixas e/ou escolher recompensa quando o mapa declarar.
7. Retornar a nave para ver estado da run, usar Souls shop, abrir deck, comprar/curar/remover/duplicar/reliquia ou continuar.
8. Vencer o mapa 29 ou perder se o Comandante cair.

Nao ha meta-progressao persistente fora da run. Derrota reinicia a run completa.

## Battle Board

O tabuleiro usa slots alinhados por indice: slot 1 contra slot 1, slot 2 contra slot 2, e assim por diante. Track 02 cobre layouts 1/1 ate 7/7.

- Cada slot ataca o slot diretamente a frente quando ele estiver ocupado.
- O combate resolve em quatro etapas globais: `Iniciativa - Frente`, `Iniciativa - Sobra`, `Combate - Frente`, `Combate - Sobra`.
- Cada criatura ataca no maximo uma vez por ciclo de combate.
- As etapas de frente sao contabilizadas em lote; criaturas que atacam de frente ainda causam dano mesmo se morrerem naquela etapa.
- As etapas de sobra resolvem lane por lane, da esquerda para a direita.
- Criaturas mortas antes da sua vez de sobra nao atacam, nao atraem `defensor` e nao bloqueiam dano excedente.
- Se uma lane inimiga estiver vazia, a criatura procura o `defensor` inimigo mais proximo da lane; em empate, usa o primeiro da esquerda.
- Se nao houver `defensor`, a sobra aliada mira o heroi inimigo em `duelo`/`chefe_summoner`; nos demais modos mira a criatura inimiga mais proxima.
- Criaturas inimigas sem alvo frontal nem defensor causam dano direto ao jogador.
- Ataques de sobra nao recebem dano de volta.
- Invocar uma criatura em slot aliado ocupado exige confirmacao de sacrificio; cancelar nao gasta mana nem carta.
- Arrastar uma criatura aliada para slot adjacente vazio move a criatura; arrastar para slot adjacente ocupado troca as duas criaturas de lugar e consome movimento das duas.

## Keywords E Status

Track 02 implementa o vocabulario de keywords/status usado por cartas, inimigos, tooltips e testes:

- `iniciativa`, `defensor`, `reviver`, `regeneracao`, `carnica`, `suicida`, `enfraquecer`, `prender`, `remover keywords`, `poder de habilidade`.
- `atropelar`, `brutal`, `inspirar`, `drenar`, `ecoar`, `veneno`, `congelar`, `escudo`, `resistencia`, `espinhos`, `furia`, `crescer`, `proliferar`, `pacto`, `ressurgir`, `profanar`, `entrar`, `sacrificio`, `drenar almas`, e efeitos equivalentes declarados no catalogo.

Tooltips e badges sao contrato de UX: o jogador precisa entender a keyword/status sem ler o JSON.

## Classes

Ver `classes/README.md` e os docs individuais.

- **Arcano:** spells e poder de habilidade; ganha passiva/ativa pela rota.
- **Invocador:** buffa e protege mesa; ganha passiva/ativa pela rota.
- **Necromante:** usa Cinzas, morte, enfraquecimento e reanimacao; Ritual evolui pela rota.

Cada classe tem deck inicial de 9 cartas, cartas custo 2 de entrada, 8 reward cards de Track 02 e upgrades Lvl 2/Lvl 3.

## Battle Economy

- Mao inicial com limite base de 3 cartas.
- Antes de `Resolver Combate`, o jogador pode marcar cartas da mao para descarte; as marcadas sao descartadas e a mao recompra ate o limite apos a resolucao.
- Jogar uma carta puxa 1 carta quando possivel.
- Cartas jogadas vao para o descarte.
- Quando o deck esvazia, o descarte e embaralhado de volta.
- Mana inicial de todas as classes: `1`.
- Mana, limite de mao, HP, deck e reliquias crescem por recompensas e loja.
- Save/snapshot atual: `5`. Saves antigos devem ser tratados como stale/invalidos, mas deletaveis/sobrescritiveis quando o fluxo permitir.

## Reward System

Track 02 usa agenda de recompensas declarada no JSON:

- Recompensas fixas: mana, mao, HP, classe/passiva/ativa e outros marcos.
- Recompensas escolhiveis: upgrades, cartas novas, utilidade, reliquias e variantes declaradas.
- Upgrades por nivel: base = Lvl 1, primeiro upgrade = Lvl 2, segundo upgrade = Lvl 3.
- `RunSession.card_upgrade_counts` e a fonte de verdade; o deck guarda ID base e Battle/Deck convertem para `_lvl2`/`_lvl3`.
- Cartas novas e upgrades usam seed da run para estabilidade.
- A loja de Almas oferece acoes expandidas, incluindo cura, HP maximo, upgrade, remocao, duplicacao e reliquia, com custos/limites declarados no contrato.

## Linear Mission Map

Track 02 usa 29 mapas lineares divididos em 4 blocos elementais:

- Terra: mapas 1-8.
- Gelo: mapas 9-15.
- Ar: mapas 16-22.
- Fogo: mapas 23-29.

Os modos vivos incluem `limpar_mesa`, `ondas`, `duelo`, `defesa_posicao`, `sobreviver_turnos`, `emboscada`, `escolta`, `invasao` e `chefe_summoner`.

Os formatos vivos incluem `padrao`, `assimetrico`, `nucleo_central`, `flanco`, `frente_retaguarda` e `abismo`.

Field effects e boss hooks sao parte do contrato de encontro. Chefes nos mapas 8, 15, 22 e 29 usam summons/hook phases declarados no JSON.

## Enemy AI E Intent

Inimigos usam perfis deterministas por elemento (`terra`, `gelo`, `ar`, `fogo`) para decidir lanes, spells, pressao, controle e trocas. A UI expõe intent para o jogador e para playtest.

O objetivo do intent nao e ser uma IA final perfeita; e tornar previsivel o bastante para debug, tuning e feedback humano.

## Validation Baseline

Baseline em 2026-05-27:

- GUT: 94/94.
- Test scripts: 6 modular suites, 1136 asserts.
- Full-route pacing smoke: 29/29 mapas.
- Telemetria: 217 turnos estimados, 116 HP loss estimado, 0 mortes, 362 Souls earned, 291 Souls spent, 71 Souls left, deck final de 38 cartas, 6 reliquias, 21 acoes de loja.

## Historical Material

Track 01 / 13 mapas e save v3/v4 sao material historico. Use apenas como referencia de evolucao ou comparacao, nao como estado atual.

## Pending Design

- Playtest humano completo da rota 29 mapas.
- Ajuste de dificuldade, shop economy, reliquias e pacing apos feedback.
- Run Lab serve para regressao e comparacao de tuning, nao como substituto de playtest.
