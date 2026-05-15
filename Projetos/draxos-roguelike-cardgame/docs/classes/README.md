# Classes - Indice

- Last Updated: `2026-05-15`
- Status: `Track 01 13-map reward update validated`
- Referencia: `../game-design-document.md`

## Decisao Atual

O jogador escolhe uma classe antes de cada run e carrega essa identidade ate o fim da expedicao ou ate a derrota.

Cada classe tem:

- deck inicial proprio com 9 cartas custo 1, 3 tipos e 3 copias de cada, com mana inicial 1;
- carta custo 2 propria adicionada automaticamente no mapa 2;
- pool placeholder de 6 cartas de recompensa custo 1-3;
- passiva fixa desbloqueada automaticamente no mapa 8;
- habilidade ativa fixa desbloqueada automaticamente no mapa 10;
- habilidade ativa usavel uma vez por turno quando desbloqueada.

Nao ha escolha de passiva ou habilidade no inicio da run. Recompensas dos mapas 8 e 10 apenas liberam o kit fixo da classe.

## As Tres Classes

| Classe | Passiva Fixa | Habilidade Ativa | Mecanica Central |
|---|---|---|---|
| [Arcano](arcano.md) | Fluxo Continuo, liberado no mapa 8 | 1 mana: dano amplificado por Fluxo, liberada no mapa 10 | Sequenciar cartas para aumentar dano de spells |
| [Invocador](invocador.md) | Comandante de Campo, liberado no mapa 8 | 1 mana: +2/+0 permanente em criatura aliada, aumentado por poder de habilidade, liberada no mapa 10 | Criaturas e buffs permanentes |
| [Necromante](necromante.md) | Colheita Sombria, liberada no mapa 8 | Ritual por Cinzas, nivel 1 no mapa 8 e nivel 2 no mapa 10 | Morte em campo vira recurso |

## Keywords

Keywords ativas no slice:

- `iniciativa`: ataca nas etapas de iniciativa; se destruir o alvo antes da etapa normal, esse alvo nao responde.
- `defensor`: atrai ataques de criaturas inimigas sem alvo na lane a frente.
- `reviver`: volta uma vez ao morrer por dano/efeito, com marcador de reviver.
- `regeneracao`: recupera HP no inicio do turno do jogador.

Keywords removidas:

- `protecao`
- `voadora`

Cartas que tinham `protecao` ou `voadora` foram migradas para `iniciativa`.

## Estado Dos Decks

Os decks iniciais foram redesenhados para 9 cartas por classe, com a carta custo 2 entrando automaticamente no mapa 2:

- Arcano inicial: `Choque`, `Fagulha Arcana`, `Barreira Arcana`; mapa 2 adiciona `Tempestade Arcana`.
- Invocador inicial: `Soldado Arcano`, `Batedor Arcano`, `Promover`; mapa 2 adiciona `Guardiao Arcano`.
- Necromante inicial: `Esqueleto`, `Morto vivo`, `Prender`; mapa 2 adiciona `Zumbi`.

No mapa 6, a run recebe `+1 limite de cartas na mao`.
