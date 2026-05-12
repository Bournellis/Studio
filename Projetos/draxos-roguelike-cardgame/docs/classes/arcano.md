# Arcano

- Last Updated: `2026-05-12`
- Status: `Track 01 linear slice validated`
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

**Efeito:** causa 1 de dano a qualquer alvo valido, amplificado pelo Fluxo atual e por bonus de spell damage.

Antes do mapa 7, a habilidade nao aparece na UI e nao pode ser usada.

## Deck Mockup Atual

Parametros do slice: mana inicial 2, HP do Comandante 20.

| Papel | Custo | Qty inicial | Stats | Efeito |
|---|---:|---:|---|---|
| Construtor de Fluxo | 0 | 3 | - | Aplica Lentidao a uma criatura inimiga. |
| Spell de dano | 1 | 5 | - | Causa 1 de dano a qualquer alvo. |
| Criatura com Iniciativa | 1 | 2 | 0/3 | `iniciativa`. |
| Criatura geradora de entrada | 1 | 1 | 1/2 | Ao entrar: ganhe 1 de mana neste turno. |
| Spell de dano maior | 2 | 2 | - | Causa 2 de dano a qualquer alvo. |
| Criatura geradora continua | 2 | 1 | 1/3 | Enquanto em campo: +1 mana por turno. |
| Criatura amplificadora | 3 | 0 inicial / recompensa mapa 3 | 1/4 | Spells causam +1 dano adicional. |

O deck inicial tem 14 cartas. `arcano_amplificador` entra na run apenas pelo marco automatico do mapa 3.

## Pendencias

- Nome final da habilidade ativa.
- Nomes, lore e arte definitivos das cartas.
- Rebalancear o deck depois que todas as cartas forem refeitas.
