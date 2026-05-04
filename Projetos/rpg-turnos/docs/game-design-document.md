# RPG Turnos Game Design Document

- Version: `0.3`
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

Board slots define owner, terrain, elevation, accepted card types, size limits, and attack routes.

Initial terrains:

- `normal`
- `cobertura`: reduces ranged damage by 1
- `alto`: used by boards to expose alternate routes for `alcance`
- `queimando`: deals 1 damage to its occupant on that controller's upkeep

Initial card types:

- `criatura`
- `estrutura`
- `permanente`
- `magia`
- `magia_de_tabuleiro`
- `comando`

Initial creature states:

- `enjoo`: can block but cannot attack
- `pronta`: may attack if a legal target exists
- `exausta`: has attacked or used an exhausting action
- destroyed: removed after action resolution

Attack rules:

- attack is a normal action in `fase_principal`
- the attacker must be ready, not exhausted, not sick unless `rapido`, have attack above 0, and have a legal route target
- creature vs creature damage is simultaneous
- damage on creatures persists
- `limpar_mesa` uses no empty-lane hero fallback for player attacks
- `duelo` allows empty-lane fallback to the enemy hero

Initial keywords:

- `rapido`
- `defensor`
- `atropelar`
- `alcance`

## 5. Battle Modes

Current playable mode:

### `limpar_mesa`

The enemy side has slots, turns, upkeep, attacks, and triggers, but no enemy hero. Victory happens when relevant enemy permanents are gone.

Current test encounter:

```text
Emboscada na Ponte

INIMIGO
[E1: Goblin 2/2] [E2: Bruto 4/5] [E3: Arqueiro 1/3 - Alto]

JOGADOR
[P1: Normal] [P2: Ponte Estreita] [P3: Cobertura]
```

Next official mode:

### `duelo`

The enemy side has an enemy hero, deck, hand, energy, and AI. Victory happens when the enemy hero reaches 0 HP.

Future modes documented but not active:

- `ondas`
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

Previous notes that mention energy starting at 1, a 10-card deck, `Preparar` drawing a card, `Duelo antigo`, or phase variants are historical. They do not describe the active runtime.
