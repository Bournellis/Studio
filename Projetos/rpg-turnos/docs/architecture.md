# RPG Turnos Architecture

- Last Updated: `2026-05-05`
- Active Surface: `C1 cardgame battle modes`

## Goal

Keep cardgame rules independent from presentation so the project can still choose final 2D, 3D, or hybrid visuals later.

UI nodes may show state, route hints, buttons, and feedback animations. They must not own combat rules.

## Runtime Layers

### `core/`

Session state, selected deck, active encounter, pre-combat snapshot, local JSON save/load, UI tokens, asset IDs, and battle result handoff.

### `battle/`

The visual-agnostic C1 rules engine:

- `controladores`
- `modo_batalha`
- `tabuleiro`
- `turno`
- `manutencao`
- `compra`
- `fase_principal`
- `prioridade_de`
- action validation and resolution
- attack routes
- damage, armor, death, victory, and defeat
- visual event emission for presentation

### `data/`

Authored JSON definitions and generated Godot resources:

- hero definitions
- card definitions
- starter deck
- boards
- encounters

The authored source remains `data/definitions/slice_catalog.json`; generated `.tres` resources are rebuilt by validation.

### `modes/`

Scene composition and flow:

- boot
- exploration placeholder
- deck setup
- battle
- result

Battle entry now starts the active encounter directly. There is no runtime variant selector.

The boot menu exposes `Continuar` when `user://rpg_turnos_save.json` exists. `Novo jogo` starts a fresh session and writes the save.

Screens expose named art placeholders and resolve optional art through `AssetIds`; missing art keeps the no-asset placeholder presentation.

### `ui/`

Reusable controls for cards, slots, deck setup, battle hand, hero target zones, and player-facing feedback.

## Current Contracts

`BattleEngine.start_battle(catalog, deck_ids, config)` starts a C1 battle. `config.encontro` or `config.encounter_id` selects an encounter; the default is `emboscada_na_ponte`.

Important state keys:

- `controladores`
- `active_player_id`
- `priority_owner_id`
- `current_phase`
- `modo_batalha`
- `player_slots`
- `enemy_slots`
- `eventos_visuais`
- `outcome`

Important modes:

- `limpar_mesa`
- `duelo`

Important phases:

- `manutencao`
- `compra`
- `fase_principal`
- `descarte`
- `encerrada`

## Data Rules

Cards use Portuguese gameplay IDs and types:

- `criatura`
- `estrutura`
- `permanente`
- `magia`
- `magia_de_tabuleiro`
- `comando`

Boards define slots and routes. Encounters define mode, board, starting enemy slots, and future AI/script data.

The active deck rule is exactly 20 unlocked cards with at most 4 command cards.

Current implementation matches the GDD foundation resource model: energy/hand ramp, cyclic bottom-of-deck flow, and public `descarte` phase are implemented. Treat `implementation/current-status.md` as the operational split between implemented runtime and accepted pending design.

## Validation

Run:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd
```

Validation generates content, repairs/generated scenes, checks the first-slice contract, and runs GUT.
