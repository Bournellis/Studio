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

## DraxosMobile

- Status: **P2_IMPLEMENTACAO - bootstrap**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Design do primeiro slice completo — combate (7 tipos de dano, DoTs, anti-stall), personagem (varinha, 3 spells, passiva, pet), base manager (6 estruturas, economia de Energia), social (amigos, guilda com bonus passivos, chat), infraestrutura (Godot 4.x, Supabase, batalha 100% servidor, Android + PC + PC browser). Season de 4 meses, 2 Battle Passes. Godot project ainda nao inicializado.
- Trabalho permitido: codigo, design, documentacao local, configuracao de infraestrutura.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo.
- Proximo passo: iniciar Track 00 — inicializar Godot project e configurar Supabase.

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
