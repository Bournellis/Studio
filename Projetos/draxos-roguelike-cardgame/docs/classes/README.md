# Classes - Indice

- Last Updated: `2026-05-13`
- Status: `Track 01 redesigned class decks validated`
- Referencia: `../game-design-document.md`

## Decisao Atual

O jogador escolhe uma classe antes de cada run e carrega essa identidade ate o fim da expedicao ou ate a derrota.

Cada classe tem:

- deck inicial proprio com 12 cartas, 4 tipos e 3 copias de cada, com mana inicial 2;
- passiva fixa desbloqueada automaticamente no mapa 5;
- habilidade ativa fixa desbloqueada automaticamente no mapa 7;
- habilidade ativa usavel uma vez por turno quando desbloqueada.

Nao ha escolha de passiva ou habilidade no inicio da run. Recompensas dos mapas 5 e 7 apenas liberam o kit fixo da classe.

## As Tres Classes

| Classe | Passiva Fixa | Habilidade Ativa | Mecanica Central |
|---|---|---|---|
| [Arcano](arcano.md) | Fluxo Continuo, liberado no mapa 5 | 1 mana: dano amplificado por Fluxo, liberada no mapa 7 | Sequenciar cartas para aumentar dano de spells |
| [Invocador](invocador.md) | Comandante de Campo, liberado no mapa 5 | 1 mana: +2/+0 permanente em criatura aliada, aumentado por poder de habilidade, liberada no mapa 7 | Criaturas e buffs permanentes |
| [Necromante](necromante.md) | Colheita Sombria, liberada no mapa 5 | Ritual por Cinzas, liberado no mapa 7 | Morte em campo vira recurso |

## Keywords

Keywords ativas no slice:

- `iniciativa`: causa dano primeiro na lane; se matar, nao recebe retorno.
- `defensor`: atrai ataques de criaturas inimigas sem alvo na lane a frente.
- `reviver`: volta uma vez ao morrer por dano/efeito, com marcador de reviver.
- `regeneracao`: recupera HP no inicio do turno do jogador.

Keywords removidas:

- `protecao`
- `voadora`

Cartas que tinham `protecao` ou `voadora` foram migradas para `iniciativa`.

## Estado Dos Decks

Os decks iniciais foram redesenhados para 12 cartas por classe:

- Arcano: `Choque`, `Fagulha Arcana`, `Barreira Arcana`, `Tempestade Arcana`.
- Invocador: `Soldado Arcano`, `Batedor Arcano`, `Promover`, `Guardiao Arcano`.
- Necromante: `Esqueleto`, `Morto vivo`, `Prender`, `Zumbi`.

No mapa 3, a run recebe `+1 limite de cartas na mao`.
