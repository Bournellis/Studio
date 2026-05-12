# Classes - Indice

- Last Updated: `2026-05-12`
- Status: `Track 01 linear slice validated`
- Referencia: `../game-design-document.md`

## Decisao Atual

O jogador escolhe uma classe antes de cada run e carrega essa identidade ate o fim da expedicao ou ate a derrota.

Cada classe tem:

- deck inicial proprio, com mana inicial 2;
- cartas custo 3 removidas do deck inicial;
- passiva fixa desbloqueada automaticamente no mapa 5;
- habilidade ativa fixa desbloqueada automaticamente no mapa 7;
- habilidade ativa usavel uma vez por turno quando desbloqueada.

Nao ha escolha de passiva ou habilidade no inicio da run. Recompensas dos mapas 5 e 7 apenas liberam o kit fixo da classe.

## As Tres Classes

| Classe | Passiva Fixa | Habilidade Ativa | Mecanica Central |
|---|---|---|---|
| [Arcano](arcano.md) | Fluxo Continuo, liberado no mapa 5 | 1 mana: dano amplificado por Fluxo, liberada no mapa 7 | Sequenciar cartas para aumentar dano de spells |
| [Invocador](invocador.md) | Comandante de Campo, liberado no mapa 5 | 1 mana: +2/+0 permanente em criatura aliada, liberada no mapa 7 | Criaturas e buffs permanentes |
| [Necromante](necromante.md) | Colheita Sombria, liberada no mapa 5 | Ritual por Cinzas, liberado no mapa 7 | Morte em campo vira recurso |

## Keywords

Keywords ativas no slice:

- `iniciativa`: causa dano primeiro na lane; se matar, nao recebe retorno.
- `regeneracao`: recupera HP no inicio do turno do jogador.

Keywords removidas:

- `protecao`
- `voadora`

Cartas que tinham `protecao` ou `voadora` foram migradas para `iniciativa`.

## Estado Dos Decks

Os decks sao mockups de teste e serao refeitos depois. A mudanca importante para Track 01 e que custo 3 sai dos decks iniciais sem reposicao:

- Arcano perde `arcano_amplificador`.
- Invocador perde `invocador_colosso`.
- Necromante permanece sem custo 3 no inicial.

No mapa 3, a run recebe uma copia de `arcano_amplificador` e uma copia de `invocador_colosso`.
