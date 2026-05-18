# Necromante

- Last Updated: `2026-05-15`
- Status: `Track 01 P05 playtest tuning pass validated`
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
| Diabrete | Vira 4/1 com Suicida 2. | Vira 6/1 com Suicida 4. |

## Cartas Novas

| Carta | Custo | Tipo | Lvl 1 |
|---|---:|---|---|
| Carniceiro | 2 | Criatura | 2/2 com Carnica 1. |
| Diabrete | 1 | Criatura | 2/1 com Suicida 1. |

`Suicida X` causa X de dano a um alvo inimigo aleatorio valido quando a criatura morre. `Punir` saiu do pool ativo do Necromante. O mapa 7 oferece `Carniceiro` e `Diabrete`; o mapa 11 oferece a carta que nao foi escolhida.

## Cartas em Proposta (nao implementadas)

> As cartas abaixo sao sugestoes de design nao definitivas. Nenhuma esta no engine.
> Detalhes completos (custos, stats, upgrades, quando aparecem na run) em:
> `../design-proposals/sessao-b-cartas-novas.md`

| Carta | Elemento | Custo | Tipo | Ideia central |
|---|---|---:|---|---|
| Revenant | Gelo | 2 | Criatura 2/4 | Ressurgir: ao morrer, retorna uma vez com 1/2 sem keywords. |
| Flagelo | Gelo | 1 | Criatura 1/2 | Entrar e ao morrer: aplica Veneno 1 em criatura inimiga aleatória. |
| Arauto das Sombras | Ar | 2 | Criatura 1/3 | Entrar: reanima última aliada morta na batalha com 1/1. |
| Colheita das Almas | Ar | 0 | Magia | 2 Cinzas + 1 por cada morte na batalha atual. |
| Lich | Fogo | 3 | Criatura 3/5 | Imune a controles. Crescer +1 ATK por turno. |
| Praga | Fogo | 2 | Magia | Veneno 1 em todas criaturas inimigas em campo. Acumula. |
