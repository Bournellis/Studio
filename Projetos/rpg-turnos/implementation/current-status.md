# Current Status

- Last Updated: `2026-05-07`
- Active Project Name: `rpg-turnos`
- Active Surface: `cardgame-first C1 battle modes`
- Active Track: `Track 02 - Draxos Lore And Progression Alignment`
- Active Track Status: `ACTIVE_LINEAR_PLAN`
- Current Operational Baseline: `playable Godot 4.6.2 slice with menu, local JSON save/load, 2D exploration placeholder, C1 as the sole runtime combat model, official limpar_mesa/duelo/ondas/defesa/chefe_multiparte/quebra_cabeca encounter modes, linear world encounter chain, one-time encounter rewards, NPC progressive rewards, public descarte phase, energy/hand ramp, cyclic bottom-of-deck card flow, damage types, coverage, voadora, dual burning, fallback slots, creature movement, neutral slots in engine, clearer HUD/slots/map/reward feedback, art-ready placeholders with UiTokens and AssetIds, data-driven boards/encounters, automatic enemy priority, generated scenes, JSON-driven catalog, and green validation`
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

- Latest known validation: `2026-05-07`, `77/77` GUT tests passing through `tools/validate.gd`.
- For documentation-only changes, do not run Godot validation unless explicitly requested.

## Records

- Detailed foundation runtime record: `tracks/track-01-foundation-first-prototype/foundation-runtime-record.md`
- Active track snapshot: `tracks/track-02-draxos-lore-progression/current-status.md`
- Linear execution plan: `tracks/track-02-draxos-lore-progression/linear-execution-plan.md`
- Historical combat experiments: `../docs/cardgame-core-experiments.md`
- Cross-agent decisions: `../../../08_Coordenacao_Agentes/Decisoes/`

## Next

Execute `P01 - Catalog class resource plumbing` from `tracks/track-02-draxos-lore-progression/linear-execution-plan.md`.
