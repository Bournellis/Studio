# Track 01 Linear Execution Plan

- Last Updated: `2026-05-13`
- Status: `P11_SACRIFICE_MOVEMENT_NECRO_TUNING_VALIDATED`
- Execution Owner: `Codex`
- Scope: `First coherent playable run loop after Track 00 checkpoint`
- Validation Command: `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/validate.gd`

## Purpose

Turn the Track 00 placeholder checkpoint into a playable loop that starts a run, chooses a class, travels through map nodes, resolves battles, and returns to the ship with visible run state.

## Execution Rules

- Use the class and encounter docs as the active source for the first mechanical slice.
- Keep balance numbers provisional until playtest confirms them.
- Prefer small visible loop improvements backed by GUT tests.
- Run validation after code, scene, data, generated resource, or test changes.
- Update `../../current-status.md`, this track, and the studio snapshot when observable status changes.

## Current Execution Cursor

Next prompt: `Playtest the sacrifice/movement/Cinzas tuning pass, replace alpha-debt overlay art, and assign remaining rewards`.

## Linear Prompt Sequence

| Prompt | Status | Goal | Validation |
|---|---|---|---|
| P01 | complete | Add a class placeholder selection and explicit run start state before entering the map. | Green 24/24 |
| P02 | complete | Return from battle to ShipHub/RunMap with visible completed-node and commander health state. | Green 27/27 |
| P03 | complete | Add placeholder post-combat reward choice that changes the current run immediately. | Green 29/29 |
| P04 | complete | Replace placeholders with first mechanical class slice, including souls and paid healing. | Green 21/21 |
| P05 | in progress | Playtest and tune class decks, target UX, rewards, visuals, menus, saves, and encounter pressure. | Sacrifice/movement/Cinzas/tuning green 58/58 |

### P05 Current Slice

- 10 mainline maps are active and linear.
- All 6 encounter modes are represented.
- Mana initial is 2 for every class.
- Starter decks have 12 cards: 4 card types, 3 copies each.
- Base hand limit is 3; map 3 grants +1 max hand size.
- Passives unlock on map 5; class actives unlock on map 7.
- Combat resolves through `Resolver Combate`, then maintenance/script without a separate enemy combat turn.
- Combat uses four visible stages: `Iniciativa - Frente`, `Iniciativa - Sobra`, `Combate - Frente`, and `Combate - Sobra`.
- Front stages resolve simultaneous damage; overflow stages resolve sequentially by lane, player then enemy, left to right.
- Combat supports front-lane attacks, overflow attacks, direct lane damage, `iniciativa`, `defensor`, `reviver`, `enfraquecer`, `prender`, `promover`, and dynamic `poder de habilidade`.
- `protecao` and `voadora` are removed from the active rules contract.
- Main menu, 3 named save slots, forced class-pick and player-name modals, positioned ShipHub Deck/Mapa/Almas overlays, Deck/Almas scenes, Deck starter fallback, RunMap next-node selection, autosave outside battle, ESC-safe secondary screens, and victory reward modal are active.
- ShipHub no longer shows run-state outside Deck.
- Battle choice modals are centered and scrollable.
- `Tempestade Arcana` uses enemy-board area targeting.
- Allied creatures can be moved by drag to an adjacent empty allied slot once per turn, or swapped with an adjacent occupied allied slot if both creatures still have movement.
- Duel enemies use real hand/deck/discard/mana AI and play new cards after combat/maintenance for the next player turn.
- Survive objectives can end early when the enemy board is cleared; defense objectives require holding the objective through the configured turns.
- Survive and boss encounters have stronger starting boards for current tuning.
- Dense battle layouts keep HUD and board inside the viewport by keeping player/enemy hero targets fixed, embedding stable class ability tokens in the hand band, compacting duel/boss cards, and overlaying area-target UI.
- Enemy-board area targeting is now a large table behind enemy cards/slots rather than a small strip above them.
- Summoning a creature into an occupied allied slot now opens a floating sacrifice confirmation; cancelling preserves mana, hand, and board state.
- Necromante unlocks passiva + active level 1 on map 5 and upgrades to active level 2 on map 7; old Lentidao/Confusao/Reanimar original choices are removed.
- Defense map 4 is now a real hold objective with wave pressure and no early victory for clearing the board; Survive map 6 has a light enemy buff while preserving clear-board victory.

## P01 - Run Start And Class Placeholder

Goal: make the pre-run identity explicit without designing final classes yet.

Expected work:

- Add 3 placeholder class options.
- Store selected class id in `RunSession`.
- Start a run from ShipHub before entering RunMap.
- Keep class mechanics as TODO placeholders, not final gameplay.

Exit criteria:

- Player can choose a placeholder class before the run.
- RunSession records selected class and active run state.
- ShipHub can enter RunMap only through the explicit placeholder run flow.

### P02 - Battle Return And Visible Run State

Goal: make battle completion feel connected to the run instead of only mutating hidden state.

Expected work:

- Return from Battle to the appropriate map/hub surface after victory.
- Show completed nodes and selected class in the map/hub status areas.
- Keep commander health visible as placeholder run state.
- Do not implement final rewards yet.

Exit criteria:

- Victory state is visible outside Battle.
- Player can continue the map flow after a completed battle.
- RunSession remains the single source of placeholder run state.

### P03 - Placeholder Post-Combat Reward

Goal: prove that post-combat rewards can change the current run immediately without defining the final reward economy yet.

Expected work:

- Add a placeholder reward-pending state after victory.
- Present a simple reward choice surface after combat or on return.
- Apply at least one immediate run change.
- Keep soul payouts and final reward tables for later prompts/design.

Exit criteria:

- A completed battle can create a pending reward.
- Player can choose a placeholder reward.
- RunSession records the applied change.

### P04 - Soul Currency And Paid Healing Placeholder

Goal: make souls visible as ship currency without implementing final soul formulas or economy tuning.

Expected work:

- Add a placeholder soul total to `RunSession`.
- Award placeholder souls from completed encounter reward bands.
- Show souls in ShipHub.
- Add paid healing placeholder in ShipHub.

Exit criteria:

- Souls are visible as run/ship currency.
- Completed encounters can add souls through the current encounter baseline.
- Player can spend souls to heal through a placeholder ShipHub action.
