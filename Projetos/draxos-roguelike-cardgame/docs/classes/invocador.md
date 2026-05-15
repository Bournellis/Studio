# Invocador

- Last Updated: `2026-05-15`
- Status: `Track 01 13-map reward update validated`
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

`iniciativa`, `defensor` e `regeneracao` estao ativos.

## Deck Atual

Parametros do slice: mana inicial 1, HP do Comandante 20, mao base 3, deck inicial 9 cartas custo 1. O mapa 2 adiciona 3 copias de `Guardiao Arcano`.

| Carta | Custo | Qty | Stats | Efeito |
|---|---:|---:|---|---|
| Soldado Arcano | 1 | 3 inicial | 2/2 | Sem keyword. |
| Batedor Arcano | 1 | 3 inicial | 2/1 | `iniciativa`. |
| Promover | 1 | 3 inicial | - | Criatura aliada escolhe +1/+1, `iniciativa` ou `defensor`. |
| Guardiao Arcano | 2 | 3 no mapa 2 | 2/4 | `defensor`. |

## Recompensas A Definir

Invocador possui 6 cartas placeholder no pool de recompensa. Nomes, efeitos, arte e os dois ramos de upgrade de cada carta ficam para sessao de design.
