# Invocador

- Last Updated: `2026-05-13`
- Status: `Track 01 redesigned class deck validated`
- Indice: `README.md`

## Identidade

O Invocador domina a mesa com criaturas e buffs permanentes. O plano e estabelecer uma criatura relevante, acumular buffs nela e usar lanes frontais para converter presenca de campo em dano.

## Passiva Fixa - Comandante de Campo

Desbloqueio: mapa 5.

Sempre que o jogador invoca uma criatura, a criatura aliada com maior ATK em campo ganha +1/+0 permanente durante a batalha. No slice atual o engine escolhe automaticamente a aliada de maior ATK.

Antes do mapa 5, invocar criaturas nao dispara esse buff.

## Habilidade Ativa

Desbloqueio: mapa 7.

**Custo:** 1 mana. Usavel uma vez por turno.

**Efeito:** uma criatura aliada escolhida ganha +2/+0 permanente, aumentado por poder de habilidade.

Antes do mapa 7, a habilidade nao aparece na UI e nao pode ser usada.

## Keywords

As antigas funcoes de `protecao` e `voadora` foram removidas.

`iniciativa`, `defensor` e `regeneracao` estao ativos.

## Deck Atual

Parametros do slice: mana inicial 2, HP do Comandante 20, mao base 3, deck inicial 12 cartas.

| Carta | Custo | Qty inicial | Stats | Efeito |
|---|---:|---:|---|---|
| Soldado Arcano | 1 | 3 | 2/2 | Sem keyword. |
| Batedor Arcano | 1 | 3 | 2/1 | `iniciativa`. |
| Promover | 1 | 3 | - | Criatura aliada escolhe +1/+1, `iniciativa` ou `defensor`. |
| Guardiao Arcano | 2 | 3 | 2/4 | `defensor`. |

## Pendencias

- Nome final da habilidade ativa.
- Nomes, lore e arte definitivos das cartas.
- Rebalancear buffs e stats contra os inimigos atuais depois do playtest.
