# DraxosMobile - PVE Arena Initial Direction

- Status: `VIVO`
- Data: `2026-05-31`
- Decisao: `PVE_ARENA_INITIAL_DIRECTION_APPROVED`
- Escopo: direcao de produto e tuning para o early game depois da Foundation Final Polish.

## Decisao Central

DraxosMobile deve comecar como uma Arena PVE de duelos assincronos, nao como PVP-first e nao como campanha PVE tradicional.

O primeiro jogo real e: o jogador entra no Refugio, prepara o Draxos, trava o loadout, vence uma lista curta de inimigos PVE, acumula buffs temporarios da tentativa, recebe recompensas, melhora base/build e volta para uma arena mais dificil.

PVP continua no plano, mas entra depois como modo secundario/competitivo. Enquanto nao houver playerbase suficiente, bots podem existir como fallback ou simulacao controlada de matchmaking, mas nao devem ser a fundacao escondida do produto.

## Por Que Mudar

O plano PVP-first resolvia aparentemente o problema de assets, mas criava outro problema maior: falta de jogadores reais para popular batalhas, ranking e matchmaking no lancamento.

Bots em PVP podem ajudar testes e preencher fallback, mas se o jogo precisa deles para existir no dia 1, o core real ainda nao e PVP. O core inicial deve ser uma experiencia que funciona sozinha, e a Arena PVE resolve isso sem exigir campanha, mapa, cutscenes ou elenco visual grande.

## O Que A Arena PVE E

- Uma escada de duelos PVE.
- Inspiracao estrutural: listas de oponentes em Mortal Kombat, com listas maiores e inimigos mais fortes conforme dificuldade/progresso.
- Batalha automatica, server-authoritative e apresentada por replay/log.
- Sem cooldown de combate.
- Sem sobrevivencia de vida entre lutas.
- Sem campanha PVE com producao pesada de assets.

## Fluxo Base

1. Jogador entra no Refugio.
2. Escolhe Arena PVE e dificuldade.
3. Trava loadout antes de entrar: Instrumento Ritual, spells, Doutrina, Familiar, Pocao e outros slots aprovados.
4. Entra no duelo.
5. Vence ou perde o duelo.
6. Ao vencer, ve o proximo inimigo.
7. Escolhe 1 de 3 buffs temporarios de arena.
8. Ajusta comportamento para o proximo duelo, sem trocar loadout.
9. Repete ate completar a arena, perder ou abandonar.
10. Recebe recompensa conforme progresso, dificuldade, tamanho da lista, primeira vitoria, recorde e limites de economia.
11. Usa recursos para evoluir base/build e tentar dificuldade/lista maior.

## Tutorial E Tamanho Das Arenas

- O tutorial deve ser uma arena de 1 luta.
- As primeiras arenas reais devem comecar com 3 lutas.
- Depois de algumas dificuldades, deve abrir a arena de 4 lutas, depois comprimentos maiores.
- Todas as arenas continuam escalando dificuldade. Uma arena curta de 3 lutas deve continuar relevante em dificuldades altas para jogadores avancados que querem sessao curta.
- O numero maximo de lutas por arena deve ser claro antes da implementacao. A decisao exata fica registrada em `docs/design-pending.md` ate ser fechada.

## Dificuldade

A dificuldade escala dois eixos:

- **Dificuldade numerica/mecanica**: poder, level, comportamento e especializacao dos inimigos.
- **Comprimento da lista**: quantidade de duelos consecutivos ate completar a arena.

Esses eixos se combinam, mas nao se substituem. O jogador pode escolher arena curta em dificuldade alta ou arena longa em dificuldade apropriada ao seu poder, desde que os desbloqueios permitam.

## Regras De Duelo

- A vida reseta para 100% no inicio de cada duelo.
- O desafio e "consigo vencer este duelo?", nao "consigo sobreviver carregando dano da luta anterior?".
- Derrota encerra a tentativa da arena ou aplica a regra de falha definida para aquele pacote.
- Nao ha cooldown para tentar batalhas.
- Controle economico vem de limites e qualidade de recompensa, nao de impedir o jogador de jogar.

## Loadout E Preparacao

O loadout e travado antes da entrada na arena:

- Instrumento Ritual.
- Spells equipadas.
- Doutrina.
- Familiar.
- Pocao.
- Outros slots aprovados futuramente.

Entre duelos, o jogador pode ajustar comportamento, mas nao trocar o loadout. Exemplos de comportamento:

- usar Pocao mais cedo ou mais tarde;
- postura mais agressiva ou defensiva;
- preferir uso de spell quando possivel;
- conservar mana;
- usar habilidade assim que disponivel.

Comportamento avancado, thresholds customizados, prioridades por inimigo e contra-escolha automatica continuam bloqueados ate pacote explicito.

## Buffs Temporarios

Buffs da Arena PVE sao temporarios da tentativa atual.

Regra inicial:

- 1 escolha entre 3 opcoes apos cada vitoria, antes do proximo duelo.
- Buffs devem ser apenas stats no primeiro pacote.
- Cada buff individual deve ter peso leve.
- O peso percebido vem do acumulo ao longo da arena, nao de um buff isolado dominante.
- Buffs nao viram progresso permanente.
- Buffs nao devem criar regras complexas de roguelike no primeiro pacote.

Exemplos de familias permitidas no inicio:

- Vida maxima.
- Potencia Ritual.
- Guarda.
- Mana maxima.
- Regen de mana.
- Celeridade Ritual.
- Vontade.
- Controle Ritual.

## Inimigos PVE

Inimigos PVE devem ser data-driven e reutilizar apresentacao existente sempre que possivel.

O valor inicial esta em arquetipos mecanicos, nao em assets unicos. Exemplos:

- duelista basico;
- defensor com Guarda/barreira;
- agressor de burst;
- controlador mental;
- pressao de DoT;
- invocador;
- familiar handler;
- finalizador de dificuldade.

Cada inimigo deve ter papel didatico e tuning claro: ensinar ou testar uma parte do sistema sem exigir campanha.

## Recompensas

Nao usar cooldown de combate.

Usar limites de recompensa:

- primeira vitoria contra inimigo/dificuldade;
- conclusao da arena;
- melhor progresso/recorde;
- bonus diario/semanal;
- recompensa reduzida ou limitada para repeticao;
- caps economicos por fonte quando necessario.

A recompensa principal do early game deve apoiar o ciclo:

`Arena PVE -> recompensa -> upgrade/base/build -> arena mais dificil`

PVP e Arena competitiva podem ter limites proprios de recompensa quando forem reintroduzidos, mas nao devem controlar o core inicial.

## PVP Depois

PVP permanece planejado, mas nao e o primeiro core.

Regras para o retorno do PVP:

- entra depois que o jogador entende Arena PVE, loadout, poder e progressao;
- usa o mesmo modelo server-authoritative de batalha/log/replay;
- bots podem ser fallback transparente ou oponente controlado do sistema, nao fingimento de playerbase;
- ranking e recompensas PVP devem ser limitados e auditaveis;
- bots nao entram em leaderboard publica como jogadores reais.

## Impacto Em Tuning

O tuning inicial deve considerar em conjunto:

- leveling;
- upgrades;
- recompensas;
- poder de batalha;
- dificuldade por inimigo;
- tamanho da arena;
- buffs temporarios acumulados;
- recompensas por repeticao;
- momento de introducao do PVP.

Battle Lab e Progression Lab continuam importantes, mas precisam de uma nova rodada orientada a Arena PVE. As runs atuais de PVP/bots sao evidencia historica e tecnica, nao prova final do novo early game.

## Fora De Escopo

- Campanha PVE com mapa, cutscenes ou producao pesada de assets.
- Cooldown de combate.
- Sobrevivencia de HP entre duelos.
- Buffs complexos de roguelike.
- Troca de loadout entre duelos.
- PVP como core inicial.
- Novas armas, spells, pocoes, economia final ou comportamento avancado sem pacote explicito.

## Decisoes Pendentes Antes De Implementar

- Limite maximo inicial de lutas por arena.
- Quantas dificuldades liberam arena de 4, 5 e comprimentos seguintes.
- Lista inicial de inimigos e arquetipos por dificuldade.
- Valores exatos dos buffs temporarios de stat.
- Formula de recompensa por dificuldade, comprimento e repeticao.
- Como Progression Lab representara milestones de Arena PVE.
- Como Battle Lab simulara sequencias de arena, e nao apenas duelos isolados.
