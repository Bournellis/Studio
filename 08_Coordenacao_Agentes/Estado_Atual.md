# Estado Atual — Estudio

- Ultima atualizacao: `2026-05-12`

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
- Baseline atual: slice Godot 4.6.2 jogavel — C1 unico runtime, `limpar_mesa`, `duelo`, `ondas`, `defesa`, `chefe_multiparte`, `quebra_cabeca`, cadeia de encontros no mapa, rewards por encontro uma vez, NPC progressiva, save/load JSON local, HUD/slots/mapa/rewards mais legiveis, estrutura art-ready com `UiTokens`/`AssetIds`, `descarte`, energia/mao com ramp, deck ciclico, regras de batalha completas para o slice, catalogo gerado com 3 classes (Invocador/Arcano/Necromante) com passiva, hero power e starter decks de 20 cartas, `GameSession.selected_class` com save/load retrocompativel e helpers de classe, hero power data-driven em `BattleEngine` (Amplificar + Comandante de Campo para Invocador, Preparar Defesa como fallback), cartas `reforco_aliado` e `amplificacao_campo` jogaveis, `class_select.tscn` integrada ao fluxo Novo jogo, Invocador totalmente jogavel end-to-end como primeira classe completa, contador `fluxo` volatil por turno no `BattleEngine`, `test_arcano_fluxo.gd` com 13 testes, Pulso Astral hero power implementado (`_use_hero_power_damage`: 1+fluxo dano magico a qualquer permanente ou heroi inimigo), `battle_root` atualizado para targeting `any_permanent_or_hero` (botoes por slot inimigo + botao heroi no duelo), Arcano totalmente jogavel end-to-end como segunda classe completa, `test_class_arcano.gd` com 12 testes, 4 testes de integracao Arcano em `test_content_and_session.gd` (display_name Pulso Astral, target any_permanent_or_hero, fluxo_bonus flag, passiva fluxo_continuo), validacao pendente P09 local
- Meta ativa: seguir plano linear Codex da Track 02: classes primeiro, depois apresentacao, campanha/progressao, encounters, conteudo e migracao tecnica
- Ultima atualizacao do current-status: `2026-05-12`
- Proximo passo: executar `P10 - Necromante: Cinzas and Memorial de Batalha` em `Projetos/rpg-turnos/implementation/tracks/track-02-draxos-lore-progression/linear-execution-plan.md`

## draxos-roguelike-cardgame

- Status: **Ativo - Track 01 run linear de 10 mapas validada**
- Track ativa: `Track 01 - Playable Run Loop` (P05_LINEAR_10_MAP_SLICE_VALIDATED)
- Baseline atual: checkpoint Godot 4.6.2 com Arcano/Invocador/Necromante, mana inicial 2, decks iniciais sem custo 3, 10 mapas lineares com todos os 6 modos, recompensas automaticas nos mapas 2/3/5/7, combate frontal por lanes, `iniciativa` no lugar de `protecao`/`voadora`, passivas bloqueadas ate mapa 5, ativas bloqueadas ate mapa 7, VisualAssets/ShipHub/RunMap/Battle HUD mantidos, cartas da mao e slots de batalha com badges flutuantes de custo/ATK/HP conforme tipo/estado e validacao verde 44/44
- Meta ativa: playtestar a rota completa de 10 mapas, refazer cartas/inimigos e distribuir recompensas restantes
- Ultima atualizacao do current-status: `2026-05-12`
- Proximo passo: playtest da rota completa e redesign do catalogo de cartas

## Kanban rápido

- Backlog: `08_Coordenacao_Agentes/Kanban/Backlog/`
- Doing: `08_Coordenacao_Agentes/Kanban/Doing/`
- Review: `08_Coordenacao_Agentes/Kanban/Review/`
- Done: `08_Coordenacao_Agentes/Kanban/Done/`

## Canon

- Fonte de verdade compartilhada: `canon/`
- Brief rapido: `canon/canon-brief.md`
