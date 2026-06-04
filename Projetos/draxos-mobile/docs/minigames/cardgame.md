# Cardgame

- Status: `PLANNED_DISABLED`
- Mode id: `cardgame`
- Slice id: `tbd`
- Descriptor: `data/definitions/modes/cardgame/metadata.json`
- Placeholder: `data/definitions/modes/cardgame/placeholder.json`
- Decision pack: `docs/minigames/cardgame-decision-pack.md`
- Player-facing entry: hidden
- Internal disabled action: `mode_disabled:cardgame`
- Route: none

Cardgame is a future planned/disabled DraxosMobile mode identity. It can share broad lore
with other Draxos projects, but it does not inherit mechanics, pacing, rewards
or deck rules from `draxos-roguelike-cardgame`.

## Current Scope

- Hidden from the player-facing menu until a playable package is approved.
- No playable scene.
- No session start.
- No reward bridge.
- No card, deck or combat rules.

## Freeze For This Scaffold

- No card gameplay.
- No deckbuilding.
- No rewards.
- No imports from the Steam roguelike cardgame.
- No backend or schema mutation.

## Future Gate

Cardgame needs its own design contract, ruleset, telemetry, validation and
explicit package decision before any playable work starts.

## Decision Pack V1

`docs/minigames/cardgame-decision-pack.md` is the current decision pack. It
keeps the mode planned/disabled and hidden from the player while making the non-inheritance rule explicit:
DraxosMobile Cardgame does not import mechanics, pacing, deck rules, rewards or
run structure from `draxos-roguelike-cardgame`.
