# Necromante

- Last Updated: `2026-05-13`
- Status: `Track 01 redesigned class deck validated`
- Indice: `README.md`

## Identidade

O Necromante transforma morte em recurso. Criaturas pequenas entram, morrem, aplicam efeitos e alimentam Cinzas para rituais.

## Passiva Fixa - Colheita Sombria

Desbloqueio: mapa 5.

Sempre que qualquer criatura morre em campo, aliada ou inimiga, o Necromante gera Cinzas. Cinzas acumulam entre turnos e financiam a habilidade ativa.

Antes do mapa 5, mortes em campo nao geram Cinzas pela passiva.

## Habilidade Ativa - Ritual Das Sombras

Desbloqueio: mapa 7.

**Custo:** 0 mana. Usavel uma vez por turno. Custa Cinzas.

| Escolha | Custo em Cinzas | Efeito |
|---|---:|---|
| Lentidao Sombria | 2 | Uma criatura inimiga nao ataca neste turno. |
| Podridao Astral | 2 | Uma criatura inimiga perde 1/1 permanente. |
| Confusao Sepulcral | 2 | Uma criatura inimiga ataca o proprio lado neste turno, se houver alvo. |
| Reanimar 1/1 | 4 | Reanima a ultima criatura do descarte como 1/1. |
| Reanimar original | 6 | Reanima a ultima criatura do descarte com stats originais. |

Antes do mapa 7, o modal do Necromante nao abre e a habilidade nao pode ser usada.

## Deck Atual

Parametros do slice: mana inicial 2, HP do Comandante 20, mao base 3, deck inicial 12 cartas.

| Carta | Custo | Qty inicial | Stats | Efeito |
|---|---:|---:|---|---|
| Esqueleto | 1 | 3 | 1/1 | `reviver`. |
| Morto vivo | 1 | 3 | 1/1 | Ao morrer: `Enfraquecer 1`. |
| Prender | 1 | 3 | - | Criatura inimiga nao ataca no proximo combate. |
| Zumbi | 2 | 3 | 2/2 | Ao morrer: `Enfraquecer 1`. |

## Pendencias

- Nome final do Ritual, se o nome provisiorio nao ficar.
- Nomes, lore e arte definitivos das cartas.
- Rebalancear geracao de Cinzas e efeitos de morte contra os inimigos atuais depois do playtest.
