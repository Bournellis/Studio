# Classes - Indice

- Last Updated: `2026-05-27`
- Status: `Track 02 complete-run baseline`
- Referencia: `../game-design-document.md`

## Decisao Atual

O jogador escolhe uma classe antes de cada run e carrega essa identidade ate a vitoria ou derrota. Nao ha escolha inicial de passiva ou ativa: os marcos da rota liberam o kit fixo de cada classe.

Cada classe tem:

- deck inicial proprio com 9 cartas custo 1, 3 tipos e 3 copias de cada;
- carta custo 2 propria adicionada automaticamente no mapa 2;
- 8 cartas reais de recompensa em pares Terra/Gelo/Ar/Fogo;
- upgrades reais Lvl 2 e Lvl 3 por tipo de carta;
- passiva fixa desbloqueada na rota;
- habilidade ativa fixa desbloqueada ou evoluida na rota.

## As Tres Classes

| Classe | Passiva Fixa | Habilidade Ativa | Mecanica Central |
|---|---|---|---|
| [Arcano](arcano.md) | Fluxo Continuo | dano amplificado por Fluxo e poder de habilidade | Sequenciar cartas para aumentar dano de spells |
| [Invocador](invocador.md) | Comandante de Campo | buff permanente em criatura aliada | Criaturas, buffs, protecao e presenca |
| [Necromante](necromante.md) | Colheita Sombria | Ritual por Cinzas | Morte em campo vira recurso |

## Reward Pools Track 02

| Classe | Terra | Gelo | Ar | Fogo |
|---|---|---|---|---|
| Arcano | Bola de Fogo, Acelerar | Vortice, Sentinela Arcana | Amplificador, Canalizar | Espelho Arcano, Descarga |
| Invocador | Atacar, Golem | Capitao de Campo, Parede de Escudos | Cavaleiro Arcano, Berserker | Arauto, Tita Geminal |
| Necromante | Carniceiro, Diabrete | Revenant, Flagelo | Arauto das Sombras, Colheita das Almas | Lich, Praga |

## Keywords

Track 02 implementa e valida o vocabulario completo usado por cartas e inimigos: `iniciativa`, `defensor`, `reviver`, `regeneracao`, `carnica`, `suicida`, `enfraquecer`, `prender`, `remover_keywords`, `poder_de_habilidade`, `atropelar`, `brutal`, `drenar`, `espinhos`, `escudo`, `resistencia`, `imune`, `crescer`, `furia`, `ecoar`, `veneno`, `congelar`, `profanar`, `entrar`, `proliferar`, `sacrificio`, `inspirar`, `pacto`, `drenar_almas` e `ressurgir`.

## Proximo Passo

As classes estao prontas para playtest humano da rota completa. Ajustes de custo, stats, raridade e cadence devem vir de feedback real ou comparacao no Run Lab.
