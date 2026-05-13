# Estado Atual — Estudio

- Ultima atualizacao: `2026-05-13`

## rpg-isometrico

- Status: **Ativo — aguardando selecao de prox gate**
- Track ativa: `Track 02 - Canonical Product Foundation` (OPEN)
- Baseline atual: B0 interno — Arena / Survival / Boss jogaveis + frontend campaign-first (Campaign primario, Classic autorado, Campanha Livre pos-Easy, extras secundarios; Arena PvP / Private Duel fora da navegacao publica)
- Meta ativa: F11 campaign-first runtime alignment completo; nenhuma gate de implementacao ativa ate que a Next Gate seja selecionada explicitamente
- Lore: Imortais substitui Heroic/Heroico como nome player-facing; lore detalhado pendente
- Ultima atualizacao do current-status: `2026-04-26`
- Proximo passo: escolher Next Gate antes de expandir conteudo, co-op, PvP, Hard, corrida ou escopo de armas

## rpg-turnos

- Status: **Ativo — execucao linear da Track 02 em andamento**
- Track ativa: `Track 02 - Draxos Lore And Progression Alignment` (ACTIVE_LINEAR_PLAN)
- Baseline atual: slice Godot 4.6.2 jogavel — C1 unico runtime, `limpar_mesa`, `duelo`, `ondas`, `defesa`, `chefe_multiparte`, `quebra_cabeca`, cadeia de encontros no mapa, rewards por encontro uma vez, NPC progressiva, save/load JSON local, HUD/slots/mapa/rewards mais legiveis, estrutura art-ready com `UiTokens`/`AssetIds`, `descarte`, energia/mao com ramp, deck ciclico, regras de batalha completas para o slice, catalogo gerado com 3 classes (Invocador/Arcano/Necromante) com passiva, hero power e starter decks de 20 cartas, `GameSession.selected_class` com save/load retrocompativel e helpers de classe, hero power data-driven em `BattleEngine` (Amplificar + Comandante de Campo para Invocador, Preparar Defesa como fallback), cartas `reforco_aliado` e `amplificacao_campo` jogaveis, `class_select.tscn` integrada ao fluxo Novo jogo, Invocador totalmente jogavel, Arcano totalmente jogavel (Fluxo + Pulso Astral), Necromante totalmente jogavel (Cinzas + Memorial + Ritual das Sombras 3 tiers + enjoo_estendido + on_death), Stage 2 de classes como novo baseline (21 testes de regressao), HUD com exibicao de Fluxo/Cinzas/Memorial, Ritual das Sombras tier buttons funcionais em `battle_root.gd`, visibilidade de debuffs (enjoo_estendido/queimando) nos slots, .tres regeneracao pendente local, validacao pendente local
- Meta ativa: seguir plano linear Codex da Track 02: apresentacao feita, agora campanha/progressao, encounters, conteudo e migracao tecnica
- Ultima atualizacao do current-status: `2026-05-13`
- Proximo passo: executar `P19 - New Content Expansion Cluster` em `Projetos/rpg-turnos/implementation/tracks/track-02-draxos-lore-progression/linear-execution-plan.md`

## draxos-roguelike-cardgame

- Status: **Ativo - Track 01 ordem de combate/HUD/save validada**
- Track ativa: `Track 01 - Playable Run Loop` (P10_COMBAT_ORDER_HUD_SAVE_VALIDATED)
- Baseline atual: checkpoint Godot 4.6.2 com menu principal de 3 saves nomeados, SaveManager local, escolha obrigatoria de classe e nome de jogador na nave, ShipHub Deck/Mapa/Almas como overlays posicionados sem painel Estado da Run, telas Deck e Almas dedicadas, Deck com fallback para starter deck, ESC seguro em Mapa/Deck/Almas, RunMap com proximo encontro selecionado, recompensa de vitoria em modal, cura 5 por 10 almas, Arcano/Invocador/Necromante, 10 mapas lineares, combate `Resolver Combate` em 4 etapas com frente simultanea e sobra sequencial, HUD de batalha estavel com alvos compactos do jogador/inimigo e tokens de passiva/ativa com hover, modais centralizados/scrollaveis, Tempestade Arcana com alvo de area, movimento de criaturas por drag, IA de duelo com deck/mao/mana jogando apos combate, encontros survive/boss mais fortes, balanceamento Arcano aplicado e validacao verde 47/47
- Meta ativa: playtestar rota e pressao de batalha em etapas, substituir arte transparente dos overlays da nave e distribuir recompensas restantes
- Ultima atualizacao do current-status: `2026-05-13`
- Proximo passo: playtest da rota completa com a nova pressao de batalha em etapas, substituir Mapa/Deck/Almas por PNGs com alpha real e definir recompensas restantes

## Kanban rápido

- Backlog: `08_Coordenacao_Agentes/Kanban/Backlog/`
- Doing: `08_Coordenacao_Agentes/Kanban/Doing/`
- Review: `08_Coordenacao_Agentes/Kanban/Review/`
- Done: `08_Coordenacao_Agentes/Kanban/Done/`

## Canon

- Fonte de verdade compartilhada: `canon/`
- Brief rapido: `canon/canon-brief.md`
