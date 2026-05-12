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
- Baseline atual: slice Godot 4.6.2 jogavel — C1 unico runtime, `limpar_mesa`, `duelo`, `ondas`, `defesa`, `chefe_multiparte`, `quebra_cabeca`, cadeia de encontros no mapa, rewards por encontro uma vez, NPC progressiva, save/load JSON local, HUD/slots/mapa/rewards mais legiveis, estrutura art-ready com `UiTokens`/`AssetIds`, `descarte`, energia/mao com ramp, deck ciclico, regras de batalha completas para o slice, catalogo gerado expondo 5 classes autoradas, validacao verde 78/78
- Meta ativa: seguir plano linear Codex da Track 02: classes primeiro, depois apresentacao, campanha/progressao, encounters, conteudo e migracao tecnica
- Ultima atualizacao do current-status: `2026-05-12`
- Proximo passo: executar `P02 - Selected Class Session State` em `Projetos/rpg-turnos/implementation/tracks/track-02-draxos-lore-progression/linear-execution-plan.md`

## draxos-roguelike-cardgame

- Status: **Ativo - Track 01 suporte visual V1 validado**
- Track ativa: `Track 01 - Playable Run Loop` (P05_VISUAL_SUPPORT_V1_VALIDATED)
- Baseline atual: checkpoint Godot 4.6.2 com Arcano/Invocador/Necromante, decks mockup de 15 cartas, encontros `limpar_mesa` e `ondas`, mana/vida/almas/cura em `RunSession`, drag-and-drop para cartas/spells, preview, modal do Ritual do Necromante, VisualAssets manifest/autoload, fundos/rota/tabuleiro/cartas preparados para PNGs opcionais e validacao verde 32/32
- Meta ativa: adicionar PNGs provisorios de AI no contrato VisualAssets e playtestar/tunar o slice de classes/encontros
- Ultima atualizacao do current-status: `2026-05-11`
- Proximo passo: gerar e inserir PNGs provisorios para nave, mapa, tabuleiro, frames e cartas prioritarias; depois playtest/tuning contra `pouso_elemental` e `ondas_iniciais`

## Kanban rápido

- Backlog: `08_Coordenacao_Agentes/Kanban/Backlog/`
- Doing: `08_Coordenacao_Agentes/Kanban/Doing/`
- Review: `08_Coordenacao_Agentes/Kanban/Review/`
- Done: `08_Coordenacao_Agentes/Kanban/Done/`

## Canon

- Fonte de verdade compartilhada: `canon/`
- Brief rapido: `canon/canon-brief.md`
