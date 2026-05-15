# Necromante

- Last Updated: `2026-05-15`
- Status: `Track 01 real upgrades and reward cards validated`
- Indice: `README.md`

## Identidade

O Necromante transforma morte em recurso. Criaturas pequenas entram, morrem, aplicam efeitos e alimentam Cinzas para rituais.

## Passiva Fixa - Colheita Sombria

Desbloqueio: mapa 8.

Sempre que qualquer criatura morre em campo, aliada ou inimiga, o Necromante gera Cinzas. Cinzas acumulam entre turnos e financiam a habilidade ativa.

Antes do mapa 8, mortes em campo nao geram Cinzas pela passiva.

## Habilidade Ativa - Ritual Das Sombras

Desbloqueio: mapa 8 junto da passiva, no nivel 1. O mapa 10 aplica o upgrade para o nivel 2.

**Custo:** 0 mana. Usavel uma vez por turno. Custa Cinzas.

| Escolha | Custo em Cinzas | Nivel | Efeito |
|---|---:|---:|---|
| Podridao Astral | 2 | 1+ | Uma criatura inimiga perde 1/1 permanente. |
| Furia das Cinzas | 2 | 1+ | Uma criatura aliada ganha +2 ATK ate o final do turno. |
| Raio das Cinzas | 2 | 1+ | Causa 2 de dano diretamente ao heroi inimigo em duelo/chefe. |
| Reanimar 1/1 | 4 | 2 | Reanima a ultima criatura do descarte como 1/1. |
| Podridao Profunda | 4 | 2 | Uma criatura inimiga perde 2/2 permanente. |
| Furia das Cinzas Maior | 4 | 2 | Uma criatura aliada ganha +4 ATK ate o final do turno. |
| Raio das Cinzas Maior | 4 | 2 | Causa 4 de dano diretamente ao heroi inimigo em duelo/chefe. |

Antes do mapa 8, o modal do Necromante nao abre e a habilidade nao pode ser usada. No nivel 1, apenas as opcoes de 2 Cinzas estao disponiveis. No nivel 2, as opcoes de 2 e 4 Cinzas ficam disponiveis.

Escolhas automaticas geradas por morte, como `Enfraquecer`, so abrem depois que as etapas visuais do `Resolver Combate` terminam, para nao cobrir o desenvolvimento da batalha.

## Deck Atual

Parametros do slice: mana inicial 1, HP do Comandante 20, mao base 3, deck inicial 9 cartas custo 1. O mapa 2 adiciona 3 copias de `Zumbi`.

| Carta | Custo | Qty | Stats | Efeito |
|---|---:|---:|---|---|
| Esqueleto | 1 | 3 inicial | 1/1 | `reviver`. |
| Morto vivo | 1 | 3 inicial | 1/1 | Ao morrer: `Enfraquecer 1`. |
| Prender | 1 | 3 inicial | - | Criatura inimiga nao ataca no proximo combate. |
| Zumbi | 2 | 3 no mapa 2 | 2/2 | Ao morrer: `Enfraquecer 1`. |

## Upgrades

| Carta | Lvl 2 | Lvl 3 |
|---|---|---|
| Esqueleto | Vira 2/2 com `reviver`. | Vira 4/4 com `reviver`. |
| Morto vivo | Ao morrer aplica Enfraquecer 2. | Vira 2/2 e ao morrer aplica Enfraquecer 3. |
| Prender | Tambem aplica Enfraquecer 1. | Tambem remove keywords da criatura alvo. |
| Zumbi | Vira 3/3 e ao morrer aplica Enfraquecer 2. | Vira 4/4 e ao morrer aplica Enfraquecer 4. |
| Carniceiro | Vira 4/4 com Carnica 1. | Mantem 4/4 e sobe para Carnica 2. |
| Punir | Aplica -2/-2, ou -5/-5 se o alvo estiver preso. | Custa 0 e mantem o efeito Lvl 2. |

## Cartas Novas

| Carta | Custo | Tipo | Lvl 1 |
|---|---:|---|---|
| Carniceiro | 3 | Criatura | 2/2 com Carnica 1. |
| Punir | 1 | Magia | A criatura alvo recebe -1/-1 permanente; se estiver presa, recebe -3/-3. |

`Punir` considera preso qualquer alvo com o estado de `Prender`/lentidao ativo e nao consome esse estado. O mapa 7 oferece `Carniceiro` e `Punir`; o mapa 11 oferece a carta que nao foi escolhida.
