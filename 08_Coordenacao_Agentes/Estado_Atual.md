# Estado Atual - Estudio

- Ultima atualizacao: `2026-05-18`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Prioridade do Estudio

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Conceitos P1 em incubacao: `Projetos/_conceitos/mobile-universe/`
- Projetos pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## draxos-roguelike-cardgame

- Status: **P0_IMPLEMENTACAO - ativo**
- Fase: `Implementacao`
- Track ativa: `Track 02 - Complete Run Evolution` (T02-P07_COMPLETE)
- Baseline atual: Track 01 validada em Godot 4.6.2 com ShipHub, 3 saves v5, escolha de classe, deck/mapa/almas, run linear de 13 mapas, starter decks custo 1, recompensas fixas/escolhiveis, upgrades reais Lvl 2/Lvl 3, raridade 70/25/5, descarte pre-combate, 8 cartas reais de recompensa por classe, galerias inimigas Terra/Gelo/Ar/Fogo, Diabrete/Suicida no Necromante, alvo de mesa aliada, batalha por lanes, sacrificio, movimento, IA hibrida por perfis Terra/Gelo/Ar/Fogo, painel de intencao inimiga, intent de chefe e validacao verde 89/89. Track 02 agora tem contrato de dados/runtime, agenda de recompensas de 29 mapas, caps de mana/mao, progressao fixa de HP, reliquias universais iniciais, loja expandida de Almas, carta restante, escolha utilitaria, reroll, vocabulario/tooltips canonicos de keywords/status, engine completo de keywords, validacao de conteudo de cartas e validacao de AI/intent; rota 29 jogavel ainda pendente.
- Meta ativa: executar os prompts lineares da Track 02 com handoff por thread, continuando por `T02-P08`.
- Trabalho permitido: codigo, validacao, playtest e documentacao local.
- Proximo passo: iniciar `T02-P08 - Route, Encounter Modes, Board Formats, Field Effects, Boss Phases`.

## Mobile Universe

- Status: **P1_CONCEITO - incubacao**
- Fase: `Conceito`
- Local: `Projetos/_conceitos/mobile-universe/`
- Baseline atual: GDD completo definido. Projeto mobile multi-partes, mago intergalatico maligno cartoon gore, com modos implementados ao longo do tempo e sem decisao de lancamento/temporadas/apps. Primeiro slice: Character Autobattler PVP simples + Base Manager + amigos + guilda, com infraestrutura seria de conta, persistencia, Arena Mobile Assincrona estilo Hero Wars, matchmaking e base social. Base/cidade em tela com botoes animados, nao grid de construcao; o plano de progressao complexo do PVP vira a primeira versao da economia/base. PVP: duelo simples contra jogador de poder semelhante, apresentacao sidescroller estilo Mortal Kombat classico, finalizacoes brutais inicialmente cosmeticas e desbloqueaveis; vitoria concede Almas, derrota nao perde recursos mas nao concede recompensa; batalhas infinitas com recompensa decrescente por janela de tempo ate zerar, sem bloquear novas batalhas. Upgrades iniciais: 1 arma, 3 spells e 2 passivas com level up simples; futuro pode ter mais armas/spells/passivas, pocoes, pets, itens, outros recursos e arvore mais elaborada. Amigos/guilda inicialmente dao uma "maozinha" leve na evolucao. PVE posterior: batalha automatica com ultimate/spells, conexao alta com Base Manager e primeiro arco narrativo de ascensao/rebeliao. Futuros PVP Cardgame Roguelike, Hero Defense e Open World RPG tem progressao propria e recebem beneficios leves de Level Global/base. Substitui RPGMobile e BattleMobile.
- Trabalho permitido: conceito, pitch, design e referencias.
- Restricao operacional: nao criar codigo, cenas, assets de implementacao ou projeto Godot sem pedido explicito.
- Proximo passo: definir curva de reducao de Almas e janela de tempo para recuperar recompensas PVP.

## rpg-isometrico

- Status: **PAUSADO_INDEFINIDO**
- Fase: `Pausado`
- Baseline preservada: B0 interno com Arena / Survival / Boss jogaveis e frontend campaign-first.
- Ultima atualizacao do current-status: `2026-04-26`
- Trabalho permitido: consulta historica e leitura de contexto quando o usuario pedir explicitamente.
- Restricao operacional: nao implementar, expandir gates, selecionar Next Gate ou alterar escopo sem pedido explicito.
- Proximo passo: nenhum enquanto estiver pausado.

## rpg-turnos

- Status: **PAUSADO_INDEFINIDO**
- Fase: `Pausado`
- Baseline preservada: slice Godot 4.6.2 jogavel com runtime C1, modos de batalha, 3 classes, 13 encontros, ranks de operacao e save/load JSON v2.
- Ultima atualizacao do current-status: `2026-05-13`
- Trabalho permitido: consulta historica e leitura de contexto quando o usuario pedir explicitamente.
- Restricao operacional: nao implementar, selecionar proxima track/gate, regenerar `.tres` ou alterar escopo sem pedido explicito.
- Proximo passo: nenhum enquanto estiver pausado.

## Kanban rapido

- Backlog: `08_Coordenacao_Agentes/Kanban/Backlog/`
- Doing: `08_Coordenacao_Agentes/Kanban/Doing/`
- Review: `08_Coordenacao_Agentes/Kanban/Review/`
- Done: `08_Coordenacao_Agentes/Kanban/Done/`

## Canon

- Fonte de verdade compartilhada: `canon/`
- Brief rapido: `canon/canon-brief.md`
