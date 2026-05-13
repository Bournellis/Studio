# Arcano

- Last Updated: `2026-05-13`
- Status: `Track 01 redesigned class deck validated`
- Indice: `README.md`

## Identidade

O Arcano vence atraves de spells amplificadas. Cartas jogadas no turno constroem Fluxo, e Fluxo aumenta dano direto de spells e da habilidade ativa quando a passiva esta desbloqueada.

## Passiva Fixa - Fluxo Continuo

Desbloqueio: mapa 5.

Cada carta jogada pelo jogador no turno gera 1 ponto de Fluxo. Cada ponto de Fluxo adiciona +1 de dano a fontes de dano direto do jogador no mesmo turno: spells e habilidade ativa. Fluxo nao aumenta ATK de criaturas e reseta no inicio do proximo turno do jogador.

Antes do mapa 5, Fluxo nao e gerado e nao modifica dano.

## Habilidade Ativa

Desbloqueio: mapa 7.

**Custo:** 1 mana. Usavel uma vez por turno.

**Efeito:** causa 1 de dano a qualquer alvo valido, amplificado pelo Fluxo atual e por poder de habilidade.

Antes do mapa 7, a habilidade nao aparece na UI e nao pode ser usada.

## Deck Atual

Parametros do slice: mana inicial 2, HP do Comandante 20, mao base 3, deck inicial 12 cartas.

| Carta | Custo | Qty inicial | Stats | Efeito |
|---|---:|---:|---|---|
| Choque | 1 | 3 | - | Causa 1 de dano a criatura ou heroi inimigo valido. |
| Fagulha Arcana | 1 | 3 | 1/1 | Enquanto em campo: +1 poder de habilidade. |
| Barreira Arcana | 2 | 3 | 0/5 | Enquanto em campo: +1 poder de habilidade. |
| Tempestade Arcana | 2 | 3 | - | Causa 3 pontos de dano distribuidos aleatoriamente entre alvos inimigos validos. |

## Pendencias

- Nome final da habilidade ativa.
- Nomes, lore e arte definitivos das cartas.
- Rebalancear o deck contra os inimigos atuais depois do playtest.
