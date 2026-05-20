# DraxosMobile - Economia E Simulador De Seasons

- Ultima atualizacao: `2026-05-20`
- Status: baseline calibravel para T00-P09
- Fonte de verdade numerica: `../../tools/economy_simulator/economy_model.v1.json`
- Gerador: `../../tools/economy_simulator/generate.ts`
- Saidas geradas: `generated/`

Este documento organiza como a economia do DraxosMobile deve ser trabalhada daqui em diante. Ele nao fecha balanceamento final; ele define a estrutura de raciocinio, os recursos, os perfis e o simulador que permitem calibrar a Season 1 e preparar seasons futuras.

---

## Regras De Season

- Season 1 dura 120 dias.
- Cada season tem 2 Battle Passes de 60 dias.
- Season 1 usa cap 40 por padrao.
- O simulador permite testar cap inicial 40, 50 ou 60.
- Caps futuros sao editaveis por season; nao ha regra fixa de crescimento ainda.
- Todos os sistemas compartilham o cap atual: level global, arma, spells, pet, passivas e construcoes.
- Nenhum level reseta entre seasons.
- Resetam por season: Battle Pass, ranking/eventos de arena, missoes sazonais e ofertas temporarias.
- Catch-up futuro usa multiplicador suave de XP/recursos para jogadores abaixo do cap anterior.

## Matriz De Recursos

| Recurso | Funcao | Entradas | Saidas | Persistencia |
|---|---|---|---|---|
| XP | Level global, unlocks e ritmo da season | Batalhas, missoes, Battle Pass, catch-up | Nao e gasto | Permanente |
| Almas | Upgrade de arma e spells | Batalhas, base, missoes, Battle Pass, pacotes limitados | Varinha, spells e unlocks magicos | Permanente |
| Energia | Gargalo da base | Nucleo, batalhas, missoes, Battle Pass, Diamante | Construcoes, fila e aceleracao | Permanente |
| Sangue | Progressao de pet | Pocos, batalhas, missoes, Battle Pass | Pets | Permanente |
| Cristais | Progressao de passivas | Minas, missoes, Battle Pass | Passivas | Permanente |
| Ossos | Qualidade/crafting da varinha | Ossario, batalha, quests, Battle Pass | Qualidade da varinha | Permanente |
| Diamante | Premium, tempo e conforto | Compra, passe premium, recompensas raras | Aceleracao, fila, pacotes limitados | Permanente |
| Tempo/Fila | Controle de ritmo | Espera, fila gratis, segunda fila | Construcoes e aceleracao | Permanente |
| Poder | Matchmaking e leitura de forca | Derivado de level/build/upgrades | Nao e gasto | Recalculado |
| Arena | Ranking competitivo | PvP sazonal | Perdas/decay se existir | Sazonal |
| Maestria | Progressao permanente por uso | Dano causado | Nao e gasto | Permanente |

Regra de ownership: cada recurso deve ter um papel claro. XP libera, Almas fortalecem magia, Energia move a base, Sangue move pet, Cristais movem passivas, Ossos movem qualidade da varinha e Diamante compra tempo/conforto.

## Perfis Do Simulador

| Perfil | Objetivo de leitura |
|---|---|
| Free casual | Mede progresso de rotina leve, sem obrigar cap |
| Free ativo | Referencia principal: 20 batalhas/dia, 1 check-in obrigatorio/dia, cap perto do dia 105 |
| Compra eficiente | Free ativo + segunda fila + Battle Pass Premium |
| Premium completo | Compra passes e pacotes eficientes limitados |
| Whale/acelerador | Testa aceleracao extrema sem ultrapassar o cap |
| Catch-up newcomer | Testa jogador que entra atrasado com multiplicador suave |

O simulador mede atividade por acoes por dia e estima minutos a partir dessas acoes. A meta e manter o free ativo em torno de 30-45 minutos/dia.

## Monetizacao

Monetizacao deve vender tempo, conforto, amplitude e previsibilidade. Nao deve vender spell, pet, passiva ou poder exclusivo.

Permitido para modelagem inicial:

- segunda fila de construcao;
- Battle Pass Premium;
- aceleracao de filas;
- pacotes limitados de recursos;
- recompensas raras de Diamante;
- conveniencias e cosmeticos.

Nao permitido como baseline:

- conteudo de combate exclusivo de pagamento;
- poder acima do cap;
- bypass permanente de matchmaking;
- recurso infinito sem limite de season/cap.

## Como Ler O Simulador

1. Ajuste cap e duracao em `Season Inputs`.
2. Compare perfis no `Dashboard`.
3. Use `Resource Matrix` para entender ownership de recursos.
4. Use `Sources` e `Sinks` para ver entradas e custos.
5. Use `Daily Simulation` para acompanhar nivel, XP e recursos por dia.
6. Use `Premium Stress` para avaliar o impacto de pagamento forte.
7. Use `Catch-up` para verificar se jogadores novos aproximam sem pular a jornada.
8. Use `Checks` antes de promover qualquer numero para contrato de implementacao.

## Criterios Iniciais

- Free ativo deve chegar ao cap perto do dia 105.
- Free ativo nao deve precisar de mais de 1 check-in obrigatorio por dia.
- Free casual nao precisa chegar ao cap.
- Compra eficiente deve melhorar conforto e velocidade, mas nao liberar poder exclusivo.
- Whale/acelerador nao pode ultrapassar cap.
- Catch-up newcomer deve aproximar do cap antigo sem receber level diretamente.

## Arquivos Gerados

O gerador produz:

- `generated/season_economy_summary.json`
- `generated/season_economy_daily.csv`
- `generated/season_economy_profiles.csv`
- `generated/season_economy_checks.csv`
- `generated/draxos_mobile_economy_simulator.xlsx`

As saidas sao artefatos de leitura. A fonte de verdade editavel fica no JSON versionado em `tools/economy_simulator/`.
