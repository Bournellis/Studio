# Product Brief

- Last Updated: `2026-06-03`
- Status: `Track 02 complete-run build ready for user playtest`

## Identity

`draxos-roguelike-cardgame` is a menu-first roguelike cardgame about a Draxos expedition invading an elemental planet.

The game shares lore, characters, classes, narrative direction, and campaign objective territory with other Draxos material in the studio, but it is its own product. Do not treat it as a variant of `rpg-turnos`, `rpg-isometrico`, or `draxos-mobile`.

## Core Promise

The player is a Draxos commander operating from a Draxos ship / ether-plasm base. The ship hub is the main menu and narrative anchor: subordinate NPCs, ship systems, deck inspection, run map, Souls shop, and the Grande Mestre communication surface all lead into run decisions.

From the hub, the player advances through a fixed 29-map complete-run route, improves deck/run state through rewards, relics, Souls purchases, and class unlocks, and pushes toward the final invasion objective.

## What This Is Not

- Not a variant of `rpg-turnos`.
- Not a free RPG exploration game.
- Not a Slay the Spire combat presentation.
- Not the async PVP/base-manager/mobile strategy project.
- Not a tactical RPG board with routes, elevation, terrain, or neutral slots.

## Pillars

- Class-first pre-run identity: the player is always Draxos, while gameplay changes through class.
- Draxos ship hub as the primary menu and narrative frame.
- Fixed 29-map route across Terra, Gelo, Ar, and Fogo.
- Small encounters around 1 minute and major encounters around 4-5 minutes.
- Bosses that summon multiple creatures and escalate board pressure through phase hooks.
- Lane-based board combat with one player facing one enemy commander.
- Compact base hand, draw-on-play, mana/hand/deck growth, and readable dense boards up to 7/7.
- Production reward schedule with upgrades, class reward cards, utility rewards, relic rewards, and expanded Souls shop.
- Multiple encounter goals: clear board, duel, waves, defense position, survive turns, ambush, escort, invasion, and summoner boss.
- Enemy AI/intent visible enough for playtest feedback and tuning.

## Current Checkpoint

The current checkpoint is Track 02 complete-run build:

- 29 fixed maps.
- Three playable classes: Arcano, Invocador, Necromante.
- Save/snapshot version 5.
- 8 reward cards per class with Lvl 2/Lvl 3 upgrades.
- Universal relics and relic reward/shop support.
- Expanded Souls shop: heal, max HP, remove, duplicate, card upgrade, relic, and rerolls where applicable.
- Full Track 02 keyword/status tooltips and implemented keyword engine.
- Terra/Gelo/Ar/Fogo enemy galleries.
- Deterministic hybrid enemy AI and visible enemy intent.
- Encounter modes, board formats, field effects, and boss hooks for maps 8/15/22/29.
- Shared validation/Run Lab telemetry for full-route pacing smoke, with Track 02 golden regression comparison.
- Internal directors/services for enemy AI/intent, reward choices, Souls shop, battle preview data, HUD/objective readouts, combat FX presentation, and catalog source loading.

Current validation baseline on 2026-06-03: GUT 103/103 across 7 modular suites, 1271 asserts, full-route pacing smoke 29/29, 217 estimated turns, 116 estimated HP loss, 0 deaths, 362 Souls earned, 291 Souls spent, 71 Souls left, 38-card final deck, 6 relics, and 21 estimated shop actions. Run Lab golden comparison passes for Arcano, Invocador, and Necromante with seed `20260518`.

## Historical Material

Track 01 / 13-map material is historical unless a document explicitly says it has been adopted by Track 02. It can be used as implementation context, but it is no longer the live product checkpoint.

## Open Product Risk

The build is technically validated and ready for user playtest, but human balance feedback is still pending. Run Lab telemetry is useful for regression and tuning comparisons; it is not a substitute for playtest.
