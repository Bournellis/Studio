# Game Design Document

- Last Updated: `2026-05-13`
- Status: `Track 01 redesigned battle/card baseline validated`

## Direction

Este e um roguelike de cartas com lore Draxos e apresentacao de batalha em lanes frontais. O jogador e sempre o Comandante Draxos; a identidade de gameplay vem da `Classe`.

O slice atual tem 3 classes fixas: `arcano`, `invocador` e `necromante`. A classe define deck inicial, passiva fixa e habilidade ativa fixa, mas a passiva so desbloqueia no mapa 5 e a ativa so aparece/funciona a partir do mapa 7.

## Core Loop

1. Iniciar no hub da nave Draxos.
2. Escolher uma classe antes da run.
3. Entrar no mapa de missao linear.
4. Resolver o proximo no disponivel.
5. Receber recompensas automaticas do no.
6. Retornar a nave para ver estado da run, curar com Almas ou continuar.
7. Vencer os 10 encontros ou perder se o Comandante cair.

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
- `regeneracao` continua funcionando no inicio do turno do jogador.
- Nao existe enjoo: criaturas entram aptas para o proximo combate disponivel.

### Iniciativa

`iniciativa` substitui as antigas keywords `protecao` e `voadora`.

- Criaturas com `iniciativa` atacam nas etapas de iniciativa e nao atacam de novo nas etapas normais.
- Se a etapa de iniciativa destruir o alvo frontal, esse alvo nao responde na etapa normal.
- Se ambas tem `iniciativa`, ambas causam dano na mesma etapa de iniciativa e nao atacam de novo.

### Novas Keywords E Efeitos

- `defensor`: atrai ataques de criaturas inimigas sem alvo na lane a frente.
- `reviver`: a criatura morta volta uma vez no mesmo slot, com stats originais e marcador de reviver; se morrer com marcador, vai ao descarte.
- `enfraquecer X`: criatura alvo recebe `-X/-X`.
- `prender`: criatura alvo pula os proximos combates relevantes.
- `poder de habilidade`: fontes em campo aumentam valores numericos de spells, habilidades de cartas e ativas de classe, sem alterar custos nem stats base.

## Classes

Ver `classes/README.md` e os docs individuais.

- **Arcano:** Fluxo aumenta dano de spells quando a passiva esta desbloqueada.
- **Invocador:** buffs permanentes e crescimento de criaturas quando a passiva esta desbloqueada.
- **Necromante:** Cinzas por mortes em campo quando a passiva esta desbloqueada.

Habilidades ativas sao fixas por classe, uma vez por turno, e ficam ocultas/bloqueadas ate o mapa 7.

## Encounter Types

Modos presentes no contrato do slice:

- `limpar_mesa`: vencer limpando a presenca inimiga relevante no tabuleiro.
- `ondas`: vencer todas as ondas sequenciais.
- `duelo`: vencer reduzindo o heroi inimigo a 0.
- `defesa_posicao`: proteger um objetivo 0 ATK / 10 HP no slot central aliado por 3 turnos.
- `sobreviver_turnos`: sobreviver 3 turnos com o Comandante vivo.
- `chefe_summoner`: derrotar um boss com vida propria e summons roteirizados.

## Battle Economy

- Mao inicial com limite base de 3 cartas.
- Jogar uma carta puxa 1 carta quando possivel.
- Cartas jogadas vao para o descarte.
- Quando o deck esvazia, o descarte e embaralhado de volta.
- Mana inicial de todas as classes: `2`.
- Deck inicial de cada classe tem 12 cartas: 4 tipos, 3 copias cada.
- O catalogo antigo de cartas do jogador foi removido; cartas inimigas permanecem.
- No mapa 3, a run recebe `+1 limite de cartas na mao`.
- O ciclo de batalha e: jogadas do jogador, `Resolver Combate`, quatro etapas visuais de combate, escolhas pendentes, manutencao/script, escolhas pendentes, jogadas novas da IA de duelo para o proximo turno, retorno automatico ao jogador.

## Linear Mission Map

Track 01 usa 10 encontros lineares, sem sidequests por enquanto.

| Mapa | No | Modo | Tier | Almas | Recompensa automatica |
|---|---|---|---|---:|---|
| 1 | `n01_pouso_elemental` | `limpar_mesa` | small | 4 | - |
| 2 | `n02_ondas_iniciais` | `ondas` | medium | 7 | +1 max mana |
| 3 | `n03_duelo_inicial` | `duelo` | medium | 7 | +1 limite de mao |
| 4 | `n04_defesa_posicao` | `defesa_posicao` | medium | 7 | - |
| 5 | `n05_chefe_invocador` | `chefe_summoner` | boss | 18 | desbloqueia passiva |
| 6 | `n06_sobreviver_turnos` | `sobreviver_turnos` | medium | 7 | - |
| 7 | `n07_limpeza_elite` | `limpar_mesa` | elite_optional | 11 | desbloqueia ativa |
| 8 | `n08_ondas_avancadas` | `ondas` | elite_optional | 11 | - |
| 9 | `n09_duelo_elite` | `duelo` | elite_optional | 11 | - |
| 10 | `n10_chefe_final` | `chefe_summoner` | boss | 18 | - |

Todo mapa concede Almas usando o minimo da banda do tier.

## Pending Design

- Nomes finais de cartas, passivas e habilidades.
- Recompensas dos mapas ainda sem marco fixo.
- Upgrades, remocao de cartas e lojas.
- Balanceamento de inimigos contra os novos decks e mecanicas.
