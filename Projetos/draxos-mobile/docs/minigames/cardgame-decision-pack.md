# Cardgame Decision Pack V1

- Status: `DECISION_PACK`
- Mode id: `cardgame`
- Current slice: `tbd`
- Descriptor: `data/definitions/modes/cardgame/metadata.json`
- Placeholder: `data/definitions/modes/cardgame/placeholder.json`
- Pending design id: `DMOB-D070`

This pack records the staging decision for DraxosMobile Cardgame under the
Foundation Hardening V2 baseline. It does not approve playable work.

## Decision Summary

Cardgame remains staged/disabled. It is hidden from player-facing navigation. It may share broad Draxos lore, but it does
not inherit mechanics, pacing, rewards, deck rules, lane rules or run structure
from `draxos-roguelike-cardgame`.

## Locked For Now

- `status` stays `planned_disabled`.
- `release_channel` stays `staged`.
- `public_cta` stays `false`.
- No player-facing entry is exposed; `entry.action_id=mode_disabled:cardgame` remains internal/technical only.
- `ruleset.status` stays `draft`.
- `ownership.reward_bridge` stays `none`.

## Not Approved

- No runtime gameplay change.
- No backend mutation.
- No cards, decks, relics, lanes, mana, draw rules or rewards.
- No mechanical inheritance from the Steam roguelike cardgame.
- No shared economy promise.
- No public CTA change.

## Decision Questions Before Implementation

1. Is the first mobile Cardgame slice solo PVE, async PVP, puzzle/challenge or
   roguelite-adjacent?
2. Does it use the same Draxos mage account identity or a mode-local collection?
3. Are cards permanent account unlocks, temporary run tools or authored puzzle
   pieces?
4. What is the shortest mobile-friendly session shape?
5. What data model keeps deck/card content independent from other Draxos
   projects?
6. Which rewards, if any, can safely use Reward Bridge V1?
7. How does this mode avoid confusing the live Autobattler/Arena loop?

## Required Evidence For A Future Package

- Dedicated Cardgame design contract.
- Explicit reuse map that states what is lore-only and what is not inherited.
- Descriptor/ruleset/registry update after approval.
- Server-authoritative reward plan if shared rewards exist.
- Local validation and ModePlatform checks.
- Human approval recorded in Doing/Handoff.
