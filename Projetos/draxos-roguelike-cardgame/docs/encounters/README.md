# Encontros - Indice

- Last Updated: `2026-05-13`
- Status: `10 encontros lineares validados com baseline de combate redesenhada`
- Referencia: `../game-design-document.md`

## Proposito

Este diretorio registra o contrato de encontros do slice. Os nomes, inimigos e numeros ainda sao mockups funcionais; servem para validar modos, recompensas automaticas e escalada da run antes do redesign completo das cartas.

## Ordem Linear Atual

| Mapa | Encounter | Modo | Tier | Almas | Recompensa |
|---|---|---|---|---:|---|
| 1 | `pouso_elemental` | `limpar_mesa` | small | 4 | - |
| 2 | `ondas_iniciais` | `ondas` | medium | 7 | +1 max mana |
| 3 | `duelo_inicial` | `duelo` | medium | 7 | +1 limite de mao |
| 4 | `defesa_posicao_inicial` | `defesa_posicao` | medium | 7 | - |
| 5 | `chefe_invocador` | `chefe_summoner` | boss | 18 | passiva da classe |
| 6 | `sobreviver_turnos_inicial` | `sobreviver_turnos` | medium | 7 | - |
| 7 | `limpeza_elite` | `limpar_mesa` | elite_optional | 11 | habilidade ativa da classe |
| 8 | `ondas_avancadas` | `ondas` | elite_optional | 11 | - |
| 9 | `duelo_elite` | `duelo` | elite_optional | 11 | - |
| 10 | `chefe_summoner_final` | `chefe_summoner` | boss | 18 | - |

## Vocabulario De Tipos

- `limpar_mesa`: vencer limpando a presenca inimiga relevante no tabuleiro.
- `ondas`: vencer todas as ondas sequenciais.
- `duelo`: vencer reduzindo o heroi inimigo a 0.
- `defesa_posicao`: proteger objetivo 0 ATK / 10 HP no slot central aliado por 3 turnos.
- `sobreviver_turnos`: vencer apos 3 turnos com o Comandante vivo.
- `chefe_summoner`: boss com vida propria e summons roteirizados.

## Regras De Combate Relevantes

Todos os modos usam o mesmo combate frontal:

- slot ataca a lane da frente quando ocupada;
- combate resolve em quatro etapas globais: iniciativa frente, iniciativa sobra, combate frente, combate sobra;
- dano de uma mesma etapa e aplicado em lote;
- lane vazia procura o `defensor` inimigo mais proximo antes de mirar heroi ou criatura mais proxima;
- `duelo` e `chefe_summoner` permitem dano direto no heroi inimigo;
- `defesa_posicao` cria um objetivo aliado no slot central;
- `sobreviver_turnos` usa apenas sobrevivencia do Comandante como objetivo.
- `Resolver Combate` executa combate antes da manutencao; manutencao nao executa um combate inimigo separado.

## Proximo Passo

Playtestar a pressao dos inimigos contra os novos decks e redistribuir recompensas dos mapas que hoje ainda nao tem marco fixo.
