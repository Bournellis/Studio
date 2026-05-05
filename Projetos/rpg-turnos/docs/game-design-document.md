# RPG Turnos Game Design Document

- Version: `0.5`
- Last Updated: `2026-05-04`
- Status: `C1_LOCKED_AS_CURRENT_CARDGAME_CORE`
- Incorporated Source: `C:/Users/Fabio/Downloads/cardgame_slots_implementacao_codex_v0_1.md`

## 1. Direction

`rpg-turnos` is currently focused on the cardgame combat. RPG progression, lore, dialogue depth, equipment, classes, and campaign systems remain future layers.

C1 is no longer a variant. C1 is the current game:

- fixed slot board
- cards as combat tools
- heroes as mechanical battle identities
- no tactical movement grid
- no automatic confrontation phase
- attacks are actions during the main phase
- modes are encounter rules, not battle variants

The old phase-based duel and A/B alternatives are historical design notes only.

## 2. Turn And Priority

Public turn flow:

1. `manutencao`
2. `compra`
3. `fase_principal`

Cleanup exists only as internal technical resolution after the main phase.

Priority rules:

- the active controller starts the main phase with priority
- normal actions resolve immediately and pass priority
- instant actions resolve immediately and keep priority
- passing priority gives priority to the opponent
- two consecutive passes end the main phase
- there is no stack, response window, counterspell, or "in response" action

Both controllers may play legal cards and attack on either controller's turn if they have priority.

## 3. Resources

MVP defaults:

- player hero: 25 HP
- duel enemy hero: 20 HP
- max energy: starts at 3 on turn 1, increases by 1 each subsequent turn, capped at 8
- energy recharges to current max on the controller's own upkeep
- unspent energy is lost at end of turn (does not carry to next upkeep)
- initial hand: 5 cards
- hand limit: starts at 5 on turn 1, increases by 1 each subsequent turn, capped at 7
- draw phase: draw cards from the top of the deck until hand size equals the current hand limit; if already at or above the limit, draw nothing
- over-limit rule: if hand size exceeds 7 for any reason, the controller must discard cards to the bottom of the deck until hand size is 7
- deck size: 20
- deck command limit: 4 command cards
- armor absorbs hero damage before health and persists until consumed

Deck cycling rules:

- there is no discard pile; all cards that leave play go to the bottom of the deck
- when a spell (`magia`, `magia_de_tabuleiro`) resolves, it goes to the bottom of the owner's deck
- when a permanent is destroyed, it goes to the bottom of its owner's deck
- when a card is discarded from hand (by choice or over-limit), it goes to the bottom of the owner's deck
- the deck never runs out; it cycles indefinitely

End-of-turn discard:

- before a controller ends their turn (just before their second consecutive pass that closes the main phase), the player controller may optionally send any number of cards from their hand to the bottom of their deck
- this happens after all actions are resolved, before the phase-end transition
- the enemy controller skips this step; the AI always retains its full hand

Hero power:

```text
Preparar Defesa
Custo: 1 energia
Velocidade: normal
Uso: uma vez no proprio turno
Efeito: ganha 2 armadura
```

## 4. Board, Cards, And Combat

Board slots define owner, terrain, elevation, accepted card types, and attack routes. There is no size limit system.

### Slot Ownership And Neutral Areas

Each slot belongs to either the player side, the enemy side, or a neutral area. Neutral area slots may exist in some boards and can be occupied by either controller. A controller may play or move a permanent into a neutral slot if it is empty.

### Terrains And Elevation

Terrains:

- `normal`: no special rules
- `cobertura`: reduces incoming `fisico_alcance` damage by 1 (see Damage Types)
- `queimando`: applies the `queimando` status to its occupant on that controller's upkeep

Elevation values:

- `chao`: default ground level; melee attacks operate here
- `alto`: elevated position; melee attacks cannot reach `alto` slots; `alcance` and `voadora` creatures can attack `alto` slots; ranged spells can also target `alto` slots

### Damage Types

All damage has an origin type that determines what defenses apply:

- `fisico_melee`: creature attacks without `alcance`; blocked by intermediate occupants; cannot reach `alto` slots; not reduced by `cobertura`
- `fisico_alcance`: attacks from creatures or structures with the `alcance` keyword; ignores intermediate occupants; can reach `alto` slots; reduced by `cobertura` (terrain and/or keyword, stacking, minimum 0)
- `magico`: damage from spells (`magia` and `magia_de_tabuleiro`); ignores `cobertura`; ranged spells (`ranged: true`) can target any slot including `alto` and ignore intermediate occupants; non-ranged spells target slots reachable via the caster's melee routes

`voadora` creatures without `alcance` deal `fisico_melee` damage; the normal `fisico_melee` restriction on `alto` slots does not apply to them (they are airborne). `voadora` creatures that also have `alcance` deal `fisico_alcance` and are reduced by `cobertura` normally.

### Board Topology And Routes

Attack routes are fully defined by the board in JSON. There is no default route formula. Boards are expected to grow in complexity and be frequently asymmetric.

Example topology for a standard 3x2 board:

```
P1  P2  P3
E1  E2  E3
```

In this layout P2/E2 (center) would typically have routes to three opposite slots; P1/E1 and P3/E3 (corners) would have routes to two. The board definition controls this explicitly.

Route blocking rules:

- a melee attacker can only hit the first occupied non-`voadora` slot along its route; `voadora` creatures are transparent to melee routing
- if the route contains only `voadora` creatures or is empty, the attack continues to the fallback defined by the encounter mode (`hero` or `none`)
- a disconnected slot (no route from the attacker) is not a legal melee target
- `alcance` creatures deal `fisico_alcance` damage and target any slot in their routes, ignoring intermediate occupants; they also target slots in `ranged_targets` defined by the board
- `voadora` creatures follow the same targeting rules as `alcance` for slot reachability
- ranged spells (`ranged: true`) target any slot ignoring intermediate occupants

### Route Fields: fallback_slots And neutral_routes

Route definitions in JSON support two additional fields beyond `targets`:

**`fallback_slots`** (optional, ordered list): slots to try as melee targets before the mode's final fallback. Used to model double defensive lines. When the primary `targets` list is fully exhausted (no occupant found), the engine tries each slot in `fallback_slots` in order, using the same non-`voadora` occupant rule. Only if all `fallback_slots` are also empty does the mode's `fallback` (`hero` or `none`) apply.

Example (P1 lane in `muralha_desfiladeiro`):
```json
"0": {
  "targets": [{"owner": "inimigo", "slot": 0}],
  "fallback_slots": [{"owner": "inimigo", "slot": 3}],
  "fallback": "hero"
}
```

In this case, a melee attack from P1 hits E1 if occupied; if E1 is empty, hits EB1 if occupied; only if both are empty does the mode fallback (`hero`) apply.

**`neutral_routes`** (per neutral slot, keyed by neutral slot index): defines the attack routes for permanents placed in neutral slots. Each entry has two target lists depending on which controller owns the permanent:

- `player_targets`: slots the player's permanent in this neutral slot can attack (ordered; first non-`voadora` occupant applies)
- `enemy_targets`: slots the enemy's permanent in this neutral slot can attack
- `fallback`: mode fallback if all targets are empty

Example (N1 in `cruzamento_neutro`):
```json
"neutral_routes": {
  "0": {
    "player_targets": [{"owner": "inimigo", "slot": 0}, {"owner": "inimigo", "slot": 1}],
    "enemy_targets": [{"owner": "jogador", "slot": 0}, {"owner": "jogador", "slot": 1}],
    "fallback": "hero"
  }
}
```

### Reference Board Layouts

#### `cruzamento_neutro` — Neutral Zone With Alto And Queimando

```
P1(chao)   P2(alto)   P3(chao,cobertura)
              N1(chao)                     ← neutral slot
E1(chao)   E2(chao)   E3(chao,queimando)
```

Mechanics exercised: neutral zone contested by both controllers, `alto` elevation (P2 is a high-ground archer perch only reachable by `alcance`/`voadora`/spells), `queimando` terrain on E3, lateral asymmetric routes, `ranged_targets` on P2 covering all enemy slots plus N1.

#### `muralha_desfiladeiro` — Double Defensive Line With Tower

```
P1(chao,cob)   P2(chao)   P3(chao,cob)
E1(chao)       E2(chao)   E3(chao)        ← front enemy line
EB1(chao)      EB2(chao)                  ← back enemy line
               ET(alto)                   ← tower (alto)
```

Mechanics exercised: `fallback_slots` connecting front to back row (P1→E1→EB1, P2→E1/E2/E3→EB1/EB2, P3→E3→EB2), `alto` tower (ET) only reachable by `alcance`/`voadora`/spells via `ranged_targets`, double `cobertura` on player flanks, asymmetric depth.

### Card Types

- `criatura`: occupies a slot; has states; can move once per turn; can attack
- `estrutura`: occupies a slot; has states; cannot move; can attack if ATK > 0; otherwise behaves identically to `criatura`
- `permanente`: generic type for any card that occupies a slot without fitting the `criatura` or `estrutura` definition; specific rules written on the card
- `magia`: instant or normal speed spell; does not occupy a slot; resolves and goes to discard
- `magia_de_tabuleiro`: spell that affects all slots globally, or all slots on one side (player or enemy); does not occupy a slot; specific scope written on the card
- `comando`: special card counted against the 4-command-card deck limit; rules written on the card

### Creature And Structure States

- `enjoo`: cannot attack; is a valid occupant and can receive damage normally
- `pronta`: may attack if a legal route target exists
- `exausta`: has attacked or used an exhausting action this turn
- `queimando`: takes 1 damage on the carrier controller's upkeep; can be on a slot (affects any occupant, creature escapes by moving) or on a creature (follows it when it moves)
- destroyed: removed from the slot after damage resolution

### Movement

A `criatura` (not `estrutura`) may spend priority once per turn as a normal action to move to any empty slot in its own controller's area or in a neutral area. Movement does not exhaust the creature; it may still attack on the same turn after receiving priority back.

### Attack Rules

- attack is a normal action in `fase_principal`
- the attacker must be `pronta`, have ATK > 0, and have a legal route target
- `rapido` creatures enter as `pronta` and may attack the turn they enter as soon as they receive priority back
- `defensor` creatures do not attack; other attackers with alternative legal targets may choose to attack elsewhere
- every attack requires the player to choose a target when more than one legal target exists
- creature vs creature damage is simultaneous; both deal their full ATK before either is destroyed
- damage on permanents persists between turns
- `atropelar`: excess damage carries to the next occupied non-`voadora` slot in the route; if no such slot, hits the enemy hero; if no hero or fallback, excess is lost; excess inherits the original damage type (melee excess cannot hit `voadora`)
- `voadora` creatures cannot be targeted by `fisico_melee`; they are transparent to melee routing; they can be targeted by `fisico_alcance`, other `voadora`, and `magico` damage normally
- `limpar_mesa` uses no empty-slot hero fallback for player attacks
- `duelo` allows empty-slot fallback to the enemy hero

### Keywords

- `rapido`: enters as `pronta`; may attack the turn it enters after priority returns
- `defensor`: does not attack; other attackers may choose different legal targets
- `atropelar`: excess damage carries to the next slot or enemy hero (see Attack Rules)
- `alcance`: deals `fisico_alcance` damage; ignores intermediate occupants; can reach `ranged_targets` and `alto` slots
- `cobertura`: reduces incoming `fisico_alcance` damage by 1; stacks with terrain `cobertura`
- `voadora`: enters as `pronta`; can attack `alto` slots and any slot in its routes; cannot be targeted by `fisico_melee`; transparent to melee routing; deals `fisico_melee` damage (elevation restriction does not apply); if also has `alcance`, deals `fisico_alcance` instead

## 5. Battle Modes

Current playable mode:

### `limpar_mesa`

The enemy side has slots, turns, upkeep, attacks, and triggers, but no enemy hero. Victory happens when relevant enemy permanents are gone. Player attacks have no hero fallback on empty routes.

Current test encounter:

```text
Emboscada na Ponte

INIMIGO
[E1: Goblin 2/2 - Normal] [E2: Bruto 4/5 - Normal] [E3: Arqueiro 1/3 - Alto]

JOGADOR
[P1: Normal] [P2: Normal] [P3: Cobertura]
```

Next official mode:

### `duelo`

The enemy side has an enemy hero, deck, hand, energy, and AI. Victory happens when the enemy hero reaches 0 HP.

Enemy hero:

```text
Poder: Golpe Direto
Custo: 0 energia
Velocidade: normal
Uso: uma vez no proprio turno
Efeito: causa 1 de dano (magico) no heroi do jogador
```

Enemy AI (deterministic, aggressive priority):

1. Use hero power if available, targeting the player hero.
2. Play the highest-cost card the AI can afford, prioritizing criaturas and estruturas.
3. Attack with each ready permanent: prioritize the enemy slot with the highest ATK; if the route is empty in `duelo` mode, fall back to the player hero.
4. Pass priority when no legal actions remain.

Enemy deck: defined per encounter in JSON (`duelista_bandido` uses a custom deck).

### `ondas`

The enemy side has no hero. The encounter is divided into sequential waves. The next wave spawns at the start of the enemy's turn after all current enemy permanents have been removed.

Wave rules:

- Hero HP persists across all waves without resetting.
- The deck state (hand, deck order, positions of cards) persists across waves.
- The energy ramp continues from where it was; there is no energy reset between waves.
- The board is cleared of enemy permanents only; player permanents remain in their slots.
- Victory when all waves have been cleared.
- Defeat when the player hero reaches 0 HP at any point.

The JSON encounter definition uses a `"waves"` array instead of `"starting_enemy_slots"`:

```json
"waves": [
  {"wave_number": 1, "starting_enemy_slots": [...]},
  {"wave_number": 2, "starting_enemy_slots": [...]}
]
```

Future modes documented but not active:

- `defesa`
- `chefe_multiparte`
- `quebra_cabeca`

## 6. Runtime Commitments

The runtime should remain data-driven:

- cards in JSON
- boards in JSON
- encounters in JSON
- generated Godot resources from authored JSON
- battle rules visual-agnostic
- UI presents state and feedback, but does not own rules

The current UI must support:

- one official encounter entry button
- no variant selector
- automatic enemy decisions
- pause whenever priority returns to the player
- simple no-asset feedback for attack, damage, summon, armor, buff, and destruction
- resilient layout at `960x540`, `1100x619`, and `1280x720`

## 7. Current MVP Card Set

The starter deck has 20 cards:

- 3x Escudeiro
- 3x Guarda da Vila
- 3x Lobo Faminto
- 2x Soldado de Linha
- 2x Arqueira de Penhasco
- 1x Bruto Mercenario
- 1x Javali de Guerra
- 2x Barricada
- 1x Balista
- 2x Raio Curto

The current reward card is `Golpe Preciso`.

## 8. Historical Notes

Previous notes that mention energy starting at 1, a 10-card deck, `Preparar` drawing a card, `Duelo antigo`, phase variants, a fixed hand limit of 8, or a draw of 1 per turn are historical. They do not describe the active runtime.
