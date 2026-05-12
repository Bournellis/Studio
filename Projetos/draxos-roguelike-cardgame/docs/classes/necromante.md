# Necromante

- Last Updated: `2026-05-12`
- Status: `Track 01 linear slice validated`
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

## Deck Mockup Atual

Parametros do slice: mana inicial 2, HP do Comandante 20. O deck inicial ja nao tem cartas custo 3.

| Papel | Custo | Qty inicial | Stats | Efeito |
|---|---:|---:|---|---|
| Criatura sacrificial zero | 0 | 2 | 1/1 | Ao morrer: gera 2 Cinzas quando a passiva esta ativa. |
| Criatura sacrificial A | 1 | 3 | 2/1 | Ao morrer: causa 1 de dano. |
| Criatura sacrificial B | 1 | 3 | 1/2 | Ao morrer: aplica Lentidao. |
| Spell Lentidao | 1 | 2 | - | Uma criatura inimiga nao ataca neste turno. |
| Spell Podridao | 1 | 2 | - | Uma criatura inimiga perde 1/1 permanente. |
| Criatura alvo de reanimacao | 2 | 2 | 3/3 | Alvo para reanimacao. |
| Spell Confusao | 2 | 1 | - | Aplica Confusao. |

## Pendencias

- Nome final do Ritual, se o nome provisiorio nao ficar.
- Nomes, lore e arte definitivos das cartas.
- Rebalancear geracao de Cinzas depois que todas as cartas forem refeitas.
