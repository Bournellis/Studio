# Towerdefense Decision Pack V1

- Status: `DECISION_PACK`
- Mode id: `towerdefense`
- Current slice: `tbd`
- Descriptor: `data/definitions/modes/towerdefense/metadata.json`
- Placeholder: `data/definitions/modes/towerdefense/placeholder.json`
- Pending design id: `DMOB-D069`

This pack records the staging decision for Towerdefense after Hardening Platform
V1. It does not approve playable work.

## Decision Summary

Towerdefense remains staged/disabled. The current concept can be discussed as a
static central mage or tower surviving hordes with spells, pets and upgrades,
but it has no live gameplay contract yet.

## Locked For Now

- `status` stays `planned_disabled`.
- `release_channel` stays `staged`.
- `public_cta` stays `false`.
- `entry.action_id` stays `mode_disabled:towerdefense`.
- `ruleset.status` stays `draft`.
- `ownership.reward_bridge` stays `none`.

## Not Approved

- No runtime gameplay change.
- No backend mutation.
- No waves, enemies, tower upgrades or tuning.
- No reward bridge.
- No new economy source or sink.
- No shared Basebuilder mutation.

## Decision Questions Before Implementation

1. Is the player protecting a tower, a Draxos mage, a ritual core or a base
   structure?
2. Are spells active player choices, loadout effects or automatic tower actions?
3. Do familiars/pets become defenders, summons, passive modifiers or stay out of
   the first slice?
4. Does the mode use timed survival, wave clears or fixed encounter scripts?
5. What is the session length target for mobile portrait play?
6. Which rewards, if any, are safe enough for Reward Bridge V1?
7. Which failure state is readable without adding a heavy combat presentation
   package?

## Required Evidence For A Future Package

- Live design contract replacing this decision pack.
- Descriptor/ruleset/registry update with the mode becoming launchable only
  after approval.
- Disable/rollback and analytics plan.
- Local mode tests before any client runtime route is exposed.
- Server-authoritative reward plan if the mode emits shared resources.
- Human approval recorded in Doing/Handoff.
