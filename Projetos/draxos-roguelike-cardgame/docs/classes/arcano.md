# Arcano

- Last Updated: `2026-05-15`
- Status: `Track 01 real upgrades and reward cards validated`
- Indice: `README.md`

## Identidade

O Arcano vence atraves de spells amplificadas. Cartas jogadas no turno constroem Fluxo, e Fluxo aumenta dano direto de spells e da habilidade ativa quando a passiva esta desbloqueada.

## Passiva Fixa - Fluxo Continuo

Desbloqueio: mapa 8.

Cada carta jogada pelo jogador no turno gera 1 ponto de Fluxo. Cada ponto de Fluxo adiciona +1 de dano a fontes de dano direto do jogador no mesmo turno: spells e habilidade ativa. Fluxo nao aumenta ATK de criaturas e reseta no inicio do proximo turno do jogador.

Antes do mapa 8, Fluxo nao e gerado e nao modifica dano.

## Habilidade Ativa

Desbloqueio: mapa 10.

**Custo:** 1 mana. Usavel uma vez por turno.

**Efeito:** causa 1 de dano a qualquer alvo valido, amplificado pelo Fluxo atual e por poder de habilidade.

Antes do mapa 10, a habilidade nao aparece na UI e nao pode ser usada.

## Deck Atual

Parametros do slice: mana inicial 1, HP do Comandante 20, mao base 3, deck inicial 9 cartas custo 1. O mapa 2 adiciona 3 copias de `Tempestade Arcana`.

| Carta | Custo | Qty | Stats | Efeito |
|---|---:|---:|---|---|
| Choque | 1 | 3 inicial | - | Causa 2 de dano a criatura ou heroi inimigo valido. |
| Fagulha Arcana | 1 | 3 inicial | 1/2 | Enquanto em campo: +1 poder de habilidade. |
| Barreira Arcana | 1 | 3 inicial | 1/3 | `defensor`. Enquanto em campo: +1 poder de habilidade. |
| Tempestade Arcana | 2 | 3 no mapa 2 | - | Causa 4 pontos de dano distribuidos aleatoriamente entre alvos inimigos validos. |

## Upgrades

| Carta | Lvl 2 | Lvl 3 |
|---|---|---|
| Choque | +1 dano, total 3. | Custa 0. |
| Fagulha Arcana | Vira 2/4 e mantem +1 poder de habilidade. | Mantem 2/4 e aumenta aura para +4 poder de habilidade. |
| Barreira Arcana | Vira 1/6 e mantem `defensor` +1 poder de habilidade. | Mantem 1/6 e aumenta aura para +4 poder de habilidade. |
| Tempestade Arcana | Causa 6 dano aleatorio. | Custa 1 e causa 6 dano aleatorio. |
| Bola de Fogo | Causa 2 dano no alvo e 2 nos adjacentes. | Causa 6 dano no alvo principal e 2 nos adjacentes. |
| Acelerar | +1 mana e +1 poder de habilidade temporario. | +2 mana e +1 poder de habilidade temporario. |

## Cartas Novas

| Carta | Custo | Tipo | Lvl 1 |
|---|---:|---|---|
| Bola de Fogo | 2 | Magia | Causa 1 dano no alvo e 1 dano em cada slot adjacente. Poder de habilidade e Fluxo amplificam todos os alvos. |
| Acelerar | 0 | Magia | Ganha +1 mana ate o final do turno. |

O mapa 7 oferece `Bola de Fogo` e `Acelerar`; o mapa 11 oferece a carta que nao foi escolhida.
