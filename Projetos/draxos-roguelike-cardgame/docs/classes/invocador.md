# Invocador

- Last Updated: `2026-05-12`
- Status: `Track 01 linear slice validated`
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

**Efeito:** uma criatura aliada escolhida ganha +2/+0 permanente.

Antes do mapa 7, a habilidade nao aparece na UI e nao pode ser usada.

## Keywords

As antigas funcoes de `protecao` e `voadora` foram removidas. As criaturas que usavam essas keywords agora usam `iniciativa`.

`regeneracao` continua ativa.

## Deck Mockup Atual

Parametros do slice: mana inicial 2, HP do Comandante 20.

| Papel | Custo | Qty inicial | Stats | Efeito |
|---|---:|---:|---|---|
| Criatura com Iniciativa A | 1 | 3 | 1/4 | `iniciativa`. |
| Criatura com Iniciativa B | 1 | 2 | 3/2 | `iniciativa`. |
| Buff permanente unico | 1 | 4 | - | Criatura aliada ganha +1/+1 permanente. |
| Buff temporario unico | 1 | 2 | - | Criatura aliada ganha +3/+0 ate o fim do turno. |
| Criatura Regeneracao | 2 | 2 | 2/3 | `regeneracao`. |
| Buff permanente area | 2 | 1 | - | Todas as criaturas aliadas ganham +1/+1 permanente. |
| Colosso | 3 | 0 inicial / recompensa mapa 3 | 5/5 | Sem habilidade. |

O deck inicial tem 14 cartas. `invocador_colosso` entra na run apenas pelo marco automatico do mapa 3.

## Pendencias

- Nome final da habilidade ativa.
- Nomes, lore e arte definitivos das cartas.
- Rebalancear buffs e stats depois que todas as cartas forem refeitas.
