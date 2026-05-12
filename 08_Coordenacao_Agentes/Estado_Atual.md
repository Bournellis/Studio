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

- Status: **Ativo — execucao linear da Track 02 pronta**
- Track ativa: `Track 02 - Draxos Lore And Progression Alignment` (ACTIVE_LINEAR_PLAN)
- Baseline atual: slice Godot 4.6.2 jogavel — C1 unico runtime, `limpar_mesa`, `duelo`, `ondas`, `defesa`, `chefe_multiparte`, `quebra_cabeca`, cadeia de encontros no mapa, rewards por encontro uma vez, NPC progressiva, save/load JSON local, HUD/slots/mapa/rewards mais legiveis, estrutura art-ready com `UiTokens`/`AssetIds`, `descarte`, energia/mao com ramp, deck ciclico, regras de batalha completas para o slice, catalogo gerado com 3 classes (Invocador/Arcano/Necromante) com passiva, hero power e starter decks de 20 cartas, `GameSession.selected_class` com save/load retrocompativel e helpers de classe, validacao verde pendente de confirmacao local
- Meta ativa: seguir plano linear Codex da Track 02: classes primeiro, depois apresentacao, campanha/progressao, encounters, conteudo e migracao tecnica
- Ultima atualizacao do current-status: `2026-05-12`
- Proximo passo: executar `P04 - Invocador Core: Passive and Hero Power` em `Projetos/rpg-turnos/implementation/tracks/track-02-draxos-lore-progression/linear-execution-plan.md`

## draxos-roguelike-cardgame

- Status: **Ativo - Track 01 menu/HUD visual reform validado**
- Track ativa: `Track 01 - Playable Run Loop` (P05_MENU_HUD_REFORM_VALIDATED)
- Baseline atual: checkpoint Godot 4.6.2 com Arcano/Invocador/Necromante, decks mockup de 15 cartas, encontros `limpar_mesa` e `ondas`, mana/vida/almas/cura em `RunSession`, drag-and-drop para cartas/spells, preview, modal do Ritual do Necromante, VisualAssets manifest/autoload, fundos provisorios 16:9, ShipHub com 4 hotspots, RunMap com rota sobre o planeta, Battle HUD cardgame classico com ticker compacto, cards com overlay seguro de frame, screenshots 1280x720/960x540 e validacao verde 32/32
- Meta ativa: adicionar artes prioritarias das cartas, normalizar fundos/frames provisorios e playtestar/tunar o slice de classes/encontros
- Ultima atualizacao do current-status: `2026-05-12`
- Proximo passo: inserir artes prioritarias de cartas e substituir/normalizar frames inseguros; depois playtest/tuning contra `pouso_elemental` e `ondas_iniciais`

## Kanban rápido

- Backlog: `08_Coordenacao_Agentes/Kanban/Backlog/`
- Doing: `08_Coordenacao_Agentes/Kanban/Doing/`
- Review: `08_Coordenacao_Agentes/Kanban/Review/`
- Done: `08_Coordenacao_Agentes/Kanban/Done/`

## Canon

- Fonte de verdade compartilhada: `canon/`
- Brief rapido: `canon/canon-brief.md`
