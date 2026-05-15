# Invocador

- Last Updated: `2026-05-15`
- Status: `Track 01 real upgrades and reward cards validated`
- Indice: `README.md`

## Identidade

O Invocador domina a mesa com criaturas e buffs permanentes. O plano e estabelecer presenca cedo, crescer uma criatura central e converter lanes frontais em dano.

## Passiva Fixa - Comandante de Campo

Desbloqueio: mapa 8.

A primeira vez que o jogador invoca uma criatura a cada turno, a criatura aliada com maior ATK em campo ganha +2/+1 permanente durante a batalha. No slice atual o engine escolhe automaticamente a aliada de maior ATK.

Antes do mapa 8, invocar criaturas nao dispara esse buff.

## Habilidade Ativa

Desbloqueio: mapa 10.

**Custo:** 1 mana. Usavel uma vez por turno.

**Efeito:** uma criatura aliada escolhida ganha +2/+0 permanente, aumentado por poder de habilidade.

Antes do mapa 10, a habilidade nao aparece na UI e nao pode ser usada.

## Keywords

As antigas funcoes de `protecao` e `voadora` foram removidas.

`iniciativa`, `defensor` e `regeneracao` estao ativos. Regeneracao cura no fim de `Resolver Combate`.

## Deck Atual

Parametros do slice: mana inicial 1, HP do Comandante 20, mao base 3, deck inicial 9 cartas custo 1. O mapa 2 adiciona 3 copias de `Guardiao Arcano`.

| Carta | Custo | Qty | Stats | Efeito |
|---|---:|---:|---|---|
| Soldado Arcano | 1 | 3 inicial | 2/2 | Sem keyword. |
| Batedor Arcano | 1 | 3 inicial | 2/1 | `iniciativa`. |
| Promover | 1 | 3 inicial | - | Criatura aliada escolhe +1/+1, `iniciativa` ou `defensor`. |
| Guardiao Arcano | 2 | 3 no mapa 2 | 2/4 | `defensor`. |

## Upgrades

| Carta | Lvl 2 | Lvl 3 |
|---|---|---|
| Soldado Arcano | Vira 3/4. | Vira 4/5 com Regeneracao 2. |
| Batedor Arcano | Vira 3/2 com `iniciativa`. | Vira 6/2 com `iniciativa`. |
| Promover | Escolhe 2 opcoes entre +1/+1, `iniciativa` e `defensor`. | Aplica +1/+1, `iniciativa` e `defensor`. |
| Guardiao Arcano | Vira 3/6 com `defensor`. | Vira 4/8 com `defensor` e Regeneracao 3. |
| Atacar | Todas as aliadas recebem +2/+2 temporario. | Todas as aliadas recebem +4/+4 temporario. |
| Golem | Vira 5/7 com `defensor` e Regeneracao 2. | Vira 6/10 com `defensor` e Regeneracao 4. |

## Cartas Novas

| Carta | Custo | Tipo | Lvl 1 |
|---|---:|---|---|
| Atacar | 2 | Magia | Todas as criaturas aliadas recebem +1/+1 ate o final do turno. |
| Golem | 3 | Criatura | 4/5 com `defensor`. |

O mapa 7 oferece `Atacar` e `Golem`; o mapa 11 oferece a carta que nao foi escolhida.
