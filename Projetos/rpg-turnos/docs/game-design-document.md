# RPG Turnos Game Design Document

- Version: `0.4`
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
- max energy: 3
- energy recharges to max on the controller's own upkeep
- unspent energy remains until the controller's next upkeep
- initial hand: 4
- draw: 1 on own draw phase after the initial hand
- hand limit: 8
- deck size: 20
- deck command limit: 4 command cards
- armor absorbs hero damage before health and persists until consumed

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
- `cobertura`: reduces incoming ranged damage by 1
- `queimando`: deals 1 damage to its occupant on that controller's upkeep

Elevation values:

- `chao`: default ground level; all melee attacks operate here
- `alto`: elevated position; melee attacks cannot reach `alto` slots; `alcance` and `voadora` creatures can attack `alto` slots

### Board Topology And Routes

Attack routes are fully defined by the board in JSON. There is no default route formula. Boards are expected to grow in complexity and be frequently asymmetric.

Example topology for a standard 3x2 board:

```
P1  P2  P3
E1  E2  E3
```

In this layout P2/E2 (center) would typically have routes to three opposite slots; P1/E1 and P3/E3 (corners) would have routes to two. The board definition controls this explicitly.

Route blocking rules:

- a melee attacker can only hit the first occupied slot along its route; if an intermediate slot is occupied, that occupant must be attacked first
- if the route target is empty, the attack continues to the fallback defined by the encounter mode (`hero` or `none`)
- a disconnected slot (no route from the attacker) is not a legal melee target
- `alcance` creatures and spells can target any slot listed in their routes, ignoring intermediate occupants; they can also target slots with no melee route if those slots appear in `ranged_targets` defined by the board
- `voadora` creatures follow the same targeting rules as `alcance` for slot reachability

### Card Types

- `criatura`: occupies a slot; has states; can move once per turn; can attack
- `estrutura`: occupies a slot; has states; cannot move; can attack if ATK > 0; otherwise behaves identically to `criatura`
- `permanente`: generic type for any card that occupies a slot without fitting the criatura or estrutura definition; specific rules written on the card
- `magia`: instant or normal speed spell; does not occupy a slot; resolves and goes to discard
- `magia_de_tabuleiro`: spell that affects all slots globally, or all slots on one side (player or enemy); does not occupy a slot; specific scope written on the card
- `comando`: special card counted against the 4-command-card deck limit; rules written on the card

### Creature And Structure States

- `enjoo`: cannot attack; can block an attacker targeting its slot
- `pronta`: may attack if a legal