# Encontros - Indice

- Last Updated: `2026-05-15`
- Status: `13 encontros lineares validados com tuning inimigo +20% e defesa side-lane`
- Referencia: `../game-design-document.md`

## Proposito

Este diretorio registra o contrato de encontros do slice. Os nomes, inimigos e numeros ainda sao funcionais/provisorios; servem para validar modos, recompensas fixas, upgrades reais, cartas novas e escalada da run antes do tuning fino.

## Ordem Linear Atual

| Mapa | Encounter | Modo | Tier | Almas | Recompensa |
|---|---|---|---|---:|---|
| 1 | `tutorial_primeiro_contato` | `limpar_mesa` | tutorial | 2 | +1 max mana |
| 2 | `tutorial_dois_fronts` | `limpar_mesa` | tutorial | 3 | carta custo 2 da classe |
| 3 | `tutorial_primeira_onda` | `ondas` | tutorial | 4 | upgrade 1 em 3 |
| 4 | `pouso_elemental` | `limpar_mesa` | small | 4 | upgrade 1 em 3 |
| 5 | `ondas_iniciais` | `ondas` | medium | 7 | +1 max mana |
| 6 | `duelo_inicial` | `duelo` | medium | 7 | +1 limite de mao |
| 7 | `defesa_posicao_inicial` | `defesa_posicao` | medium | 7 | carta nova 1 entre 2 |
| 8 | `chefe_invocador` | `chefe_summoner` | boss | 18 | passiva da classe |
| 9 | `sobreviver_turnos_inicial` | `sobreviver_turnos` | medium | 7 | upgrade 1 em 3 |
| 10 | `limpeza_elite` | `limpar_mesa` | elite_optional | 11 | habilidade ativa da classe |
| 11 | `ondas_avancadas` | `ondas` | elite_optional | 11 | carta nova restante |
| 12 | `duelo_elite` | `duelo` | elite_optional | 11 | upgrade 1 em 3 |
| 13 | `chefe_summoner_final` | `chefe_summoner` | boss | 18 | vitoria |

## Vocabulario De Tipos

- `limpar_mesa`: vencer limpando a presenca inimiga relevante no tabuleiro.
- `ondas`: vencer todas as ondas sequenciais.
- `duelo`: vencer reduzindo o heroi inimigo a 0.
- `defesa_posicao`: proteger objetivo 0 ATK / 8 HP no slot central aliado pelos 5 turnos configurados.
- `sobreviver_turnos`: vencer apos os turnos configurados com o Comandante vivo.
- `chefe_summoner`: boss com vida propria e summons roteirizados.

## Regras De Combate Relevantes

Todos os modos usam o mesmo combate frontal:

- slot ataca a lane da frente quando ocupada;
- combate resolve em quatro etapas globais: iniciativa frente, iniciativa sobra, combate frente, combate sobra;
- dano de frente e aplicado em lote;
- dano de sobra resolve por lane, jogador depois inimigo, da esquerda para a direita;
- criatura morta antes da sua sobra nao ataca nem conta como `defensor`;
- lane vazia procura o `defensor` inimigo mais proximo antes de mirar heroi ou criatura mais proxima;
- `duelo` e `chefe_summoner` permitem dano direto no heroi inimigo;
- `defesa_posicao` cria um objetivo aliado no slot central;
- `sobreviver_turnos` usa apenas sobrevivencia do Comandante como objetivo.
- `Resolver Combate` executa combate antes da manutencao; IA de duelo joga cartas novas depois da manutencao para o proximo turno.

## Pressao De Dificuldade

Todos os encontros receberam reforco aproximado de 20% em ATK/HP de cartas inimigas, com arredondamento cuidadoso nos tutoriais para manter a entrada jogavel. A partir do mapa 7 a pressao segue mais alta para acompanhar upgrades, raridades e loja:

- mapa 7 segura 5 turnos com objetivo 8 HP no centro, mas a pressao extra foi deslocada para side lanes;
- mapa 8 tem boss HP maior, mais inimigos iniciais e summons mais fortes;
- mapa 9 exige 5 turnos e comeca com elite;
- mapas 10-13 introduzem mais `elemental_tita`, elite/bruto/agil, boss HP maior e duelos com mais mana/mao.

## Proximo Passo

Playtestar a pressao dos inimigos contra a rota de 13 mapas com upgrades reais, raridades, loja de upgrades, descarte pre-combate e save v4.
