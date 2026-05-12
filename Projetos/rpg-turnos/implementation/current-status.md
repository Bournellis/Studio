# Current Status

- Last Updated: `2026-05-12` (P07)
- Active Project Name: `rpg-turnos`
- Active Surface: `cardgame-first C1 battle modes`
- Active Track: `Track 02 - Draxos Lore And Progression Alignment`
- Active Track Status: `ACTIVE_LINEAR_PLAN`
- Current Operational Baseline: `playable Godot 4.6.2 slice with menu, local JSON save/load, 2D exploration placeholder, C1 as the sole runtime combat model, official limpar_mesa/duelo/ondas/defesa/chefe_multiparte/quebra_cabeca encounter modes, linear world encounter chain, one-time encounter rewards, NPC progressive rewards, public descarte phase, energy/hand ramp, cyclic bottom-of-deck card flow, damage types, coverage, voadora, dual burning, fallback slots, creature movement, neutral slots in engine, clearer HUD/slots/map/reward feedback, art-ready placeholders with UiTokens and AssetIds, data-driven boards/encounters, automatic enemy priority, generated scenes, JSON-driven catalog, 3 classes (Invocador/Arcano/Necromante) with passiva data and 20-card placeholder starter decks in generated resources, GameSession.selected_class with save/load compatibility and class deck helpers, data-driven hero power dispatch in BattleEngine (Amplificar hero power and Comandante de Campo passive for Invocador, Preparar Defesa as no-class fallback), reforco_aliado and amplificacao_campo cards playable, class selection screen (class_select.tscn) integrated into Novo jogo flow with Invocador fully selectable end-to-end, GameSession.get_battle_config() passes class_id to BattleEngine, 23 new tests across test_class_invocador.gd and test_content_and_session.gd, battle_root hero power button reads display_name from catalog with per-slot targeting for any_own_creature classes (Amplificar shows slot buttons), class select Portuguese label fix, battle feedback hint de-coupled from Preparar Defesa name, Invocador is first complete playable class, volatile fluxo counter in BattleEngine (increments per magia/magia_de_tabuleiro resolved by Arcano player, resets at player upkeep, adds +fluxo to magic spell damage), test_arcano_fluxo.gd with 11 tests, and validation pending P04-P07 local run`
- Active Goal: `linear Codex execution of class integration, then presentation, campaign alignment, progression, encounter pressure, content expansion, and technical ID migration`
- Active Combat Direction: `C1 - main game, not a variant`
- Preserved Combat Ideas: `A/B priority variants and the phase-based duel are historical only in docs/cardgame-core-experiments.md`
- Active Work Mode: `08_Coordenacao_Agentes Kanban / Decisoes / Handoffs is active for cross-agent coordination`

## Read Next

- `../AGENTS.md`
- `../../../canon/canon-brief.md`
- `../../../canon/lore/shared-lore.md` when lore context matters
- `../../../canon/lore/draxos-invasion.md` when Draxos campaign direction matters
- `tracks/track-02-draxos-lore-progression/current-status.md`
- `tracks/track-02-draxos-lore-progression/implementation-plan.md` when planning or implementing the next lore/progression pass
- `tracks/track-02-draxos-lore-progression/linear-execution-plan.md` for the prompt-by-prompt execution order
- `tracks/track-01-foundation-first-prototype/current-status.md` for the completed runtime baseline
- `../docs/lore-campaign.md` and `../docs/lore-content-migration.md` when migrating placeholder runtime names
- touched files

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd
```

- Latest known validation: `2026-05-12`, `78/78` GUT tests passing through `tools/validate.gd`. P04–P07 validat