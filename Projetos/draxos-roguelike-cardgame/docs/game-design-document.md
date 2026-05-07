# Game Design Document

- Last Updated: `2026-05-07`
- Status: `bootstrap design`

## Direction

Este é um roguelike de cartas com lore Draxos e uma apresentação de batalha em tabuleiro simples.

O combate deve parecer dois lados se enfrentando através de uma mesa. O tabuleiro define quantas criaturas ou permanentes cabem em cada lado por encontro.

O jogador é sempre um Comandante Draxos. A identidade de gameplay é selecionada através da `Classe`, não da raça. O primeiro release tem 3 classes, cada uma com deck inicial próprio, passiva inicial, spell de classe e possível perfil de mana. Ver `classes/README.md` e os docs individuais de classe.

## Core Loop

1. Iniciar no hub da nave Draxos.
2. Escolher uma classe antes da run.
3. Entrar no mapa de missão.
4. Escolher o próximo nó disponível.
5. Resolver encontro, evento, descanso, upgrade, recompensa ou boss.
6. Retornar à nave após batalhas para gastar almas ou continuar a rota de campanha.
7. Continuar até a run ser vencida ou o Comandante ser derrotado.

Não há meta-progressão por enquanto. Derrota reinicia a run completa.

## Battle Board

O contrato de tabuleiro inicial é intencionalmente simples:

- `player_slots_count`
- `enemy_slots_count`

Batalhas iniciais começam com cerca de 3 slots de jogador, deck pequeno e mana baixo. Conforme a campanha avança, tabuleiros, tamanho de deck, escala de inimigos e orçamento de mana crescem até que lutas tardias suportem cartas grandes e longas sequências.

Sem contrato ativo para: rotas, terreno, elevação, slots neutros ou grid de movimento tático. Esses sistemas do RPG Turnos permanecem apenas como dívida técnica no engine forkado temporário.

## Classes

O jogo tem 3 classes. Cada uma define o estilo de combate do Comandante para aquela run.

Ver `classes/README.md` para o índice e `classes/arcano.md`, `classes/invocador.md`, `classes/necromante.md` para os docs individuais.

Resumo de filosofia:

- **Arcano**: spells de dano, combos de spells, ciclagem rápida de cartas.
- **Invocador**: controle de mesa, melhoria de criaturas, criaturas gigantes no late-game.
- **Necromante**: controle por volume de criaturas pequenas, ciclo de mortes para ganhos, disrupção de criaturas inimigas.

## Spell de Classe

Cada classe tem acesso a uma spell exclusiva usável **uma vez por turno**.

- O custo de mana da spell é TBD por classe.
- A spell pode ser melhorada durante a run através de recompensas específicas.
- A spell de classe é parte da identidade de combate — não é uma habilidade passiva.

Detalhes por classe estão nos docs individuais de classe, marcados como TBD pending sessão de design dedicada.

## Passiva Inicial de Classe

Cada classe começa a run com uma **habilidade passiva própria** que faz parte da sua mecânica central. A passiva inicial é permanente desde o início e molda como o deck inicial deve ser jogado.

- Não é uma recompensa — o jogador não escolhe. Ela vem com a classe.
- Diferentemente das passivas de boss, não é selecionada entre opções.

Detalhes por classe estão nos docs individuais de classe, marcados como TBD.

## Encounter Types

Vocabulário inicial de tipos de encontro:

- `limpar_mesa`: vencer limpando a presença inimiga relevante no tabuleiro.
- `duelo`: vencer derrotando um personagem oponente.
- `ondas`: lutar contra ondas sequenciais de criaturas.
- `defesa_posicao`: proteger uma posição ou objeto.
- `sobreviver_turnos`: sobreviver um número configurado de turnos.
- `chefe_summoner`: derrotar um boss que invoca múltiplas criaturas.

Vocabulário inicial de diretores inimigos:

- `prefilled_board`: criaturas inimigas começam no tabuleiro e atacam até serem eliminadas.
- `waves`: criaturas inimigas aparecem em ondas roteirizadas.
- `scripted_boss`: um boss executa padrões roteirizados de invocação ou pressão.
- `player_like`: um personagem oponente com vida, comportamento de deck e presença similar ao jogador.

A cadeia final de encontros e as definições de inimigos requerem uma sessão dedicada de design de mapa/inimigos.

## Battle Economy

- Mão inicial com 5 cartas.
- Jogar uma carta puxa 1 carta, mantendo a mão estável quando possível.
- Cartas jogadas vão para o descarte.
- Quando o deck esvazia, o descarte é embaralhado de volta.
- Mana não aumenta durante um encontro.
- Mana pode aumentar entre encontros através de recompensas de run, marcos principais ou compras com almas (ver seção Run Rewards).
- Outros recursos podem existir, mas são específicos de classe.
- Criaturas do jogador atacam automaticamente no fim do turno.
- Durante o turno inimigo, criaturas do jogador apenas recebem dano.
- Todas as classes podem substituir uma criatura invocando num slot amigo ocupado, sacrificando a anterior. Cartas ou classes específicas podem se beneficiar do sacrifício.

## Run Rewards

Recompensas de run alteram a run atual imediatamente. Nenhuma recompensa persiste após o fim da run.

### Tipos de Recompensa

| Tipo | Efeito |
|---|---|
| Nova carta | Adiciona uma carta ao deck atual da run. |
| Buff de carta | Melhora permanentemente uma carta existente no deck desta run. |
| Buff de spell de classe | Melhora a spell de classe do Comandante para o restante da run. |
| Almas extras | Adiciona almas ao total atual (ver Soul Economy). |
| +1 mana | Aumenta o mana máximo do Comandante em 1 para o restante da run. |

O aumento de mana é a recompensa de maior impacto — escala o poder do jogador significativamente de early para late game.

### Soul Reward Bands

Recompensas de almas por tipo de encontro:

- `small`: 4–6
- `medium`: 7–10
- `elite_optional`: 11–16
- `boss`: 18–25

### Post-Boss Passive

Após derrotar um boss, o jogador escolhe **1 em 3 habilidades passivas** para o Comandante. Cada passiva é um buff significativo que afeta o restante da campanha.

- As opções são sempre 3 e a escolha é permanente para a run.
- Passivas de boss são distintas da passiva inicial de classe.
- O catálogo de passivas de boss requer uma sessão dedicada de design.

Encontros opcionais (elite) oferecem risco e recompensa: podem gerar mais almas e upgrades, mas podem deixar o Comandante ferido ou morto.

## Soul Economy

Almas são a moeda da nave — acumuladas durante a run e gastas no ShipHub.

### Fontes de Almas

- Recompensas de encontro (bands acima).
- Recompensas de run do tipo "almas extras".

### Usos de Almas

| Uso | Custo em Almas |
|---|---|
| Cura paga | TBD |
| Buff de carta | TBD |
| +1 mana | TBD |

Os custos exatos requerem uma sessão de balanceamento dedicada. A cura é difícil por design — o Comandante não deve recuperar vida facilmente.

## Mission Map

O mapa representa a navegação da nave e a execução da missão no planeta elemental. Suporta uma sequência principal onde completar um nó desbloqueia o próximo, além de sidequests que podem abrir a partir do progresso principal sem bloquear a rota principal.

## Pending Rule Decisions

Decisões intencionalmente não herdadas do `rpg-turnos` e pendentes de sessão de design local:

- tamanho exato do deck
- mecânicas finais de cada classe (passiva, spell, deck)
- passivas de boss (catálogo completo)
- custos exatos de almas no ShipHub
- cadeia exata do mapa e roster de encontros
- scripts de inimigos
- regras de upgrade e remoção de cartas
- vocabulário de debuffs disponíveis para o Necromante
