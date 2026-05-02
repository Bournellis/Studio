# Progression Design

## 1. Purpose of This Document

This document defines how the player enters the game, how the first campaign teaches the kit, how gameplay content is permanently unlocked, and how the local menu exposes the campaign-first product surface over time.

It does not replace `game-design-document.md` for combat rules or `../../materiais/references/discovery/campaign-design-discovery.md` for broader campaign exploration.

---

## 2. First Contact - Direct Menu

The first boot goes directly to the main menu.

There is no mandatory pre-menu tutorial anymore.

The tutorial now lives inside the first campaign as its opening mission.

---

## 3. Initial Menu State

The public menu is organized into two groups:

- `Campanha`
- `Extras`

Initial product-facing account state:

| Group | Content | Available | Notes |
| --- | --- | --- | --- |
| Campanha | Campanha do Troll | Yes | Opens through Mission 1 / Tutorial |
| Extras | Survival | No | Unlocks after Mission 1 |
| Extras | Boss | No | Unlocks after Campaign completion |
| Extras | Arena Bot | Yes | Local kit-training surface |

Only `Campanha do Troll` and `Arena Bot` are playable at the start of the product flow.

Implementation note:

- `Private Duel / Arena PvP` remains experimental or development-only and is not part of normal public navigation
- a future gate must deliberately promote, prototype, or remove that internal surface

---

## 4. Campaign Structure

### 4.1 Classic Structure

The first campaign is a fixed authored `Classic - Easy` run built from `5` distinct maps:

1. Mission 1 - Tutorial
2. Map 2
3. Map 3
4. Map 4
5. Map 5 - Boss

Rules:

- the player must always start from map 1
- there is no map selection
- maps must be completed in order
- death resets the run back to map 1
- returning to menu or closing the game suspends the run instead of failing it

### 4.2 Mission 1 - Tutorial

Mission 1 is the first authored tutorial surface for the campaign.

At the start of the mission the player has only:

- movement
- basic attack

`Spell 1` and `Potion 1 (Health)` start blocked inside the run.

The tutorial beats are:

1. a monster group arrives
2. the game pauses
3. the first spell button is highlighted
4. the player presses it
5. the game resumes
6. later, when HP falls to the trigger threshold, the game pauses again
7. the health potion button is highlighted
8. the player presses it
9. the game resumes

Unlock rule:

- `Spell 1` becomes a permanent account unlock at the exact moment of its tutorial beat
- `Potion 1 (Health)` becomes a permanent account unlock at the exact moment of its tutorial beat

Replay rule:

- on later attempts, Mission 1 starts with both already available and skips those tutorial pauses

### 4.3 Between Maps

Clearing a map grants:

- `+1` campaign level
- `+1` pending skill point for the next map
- any permanent unlock reward tied to that map

Flow between maps:

1. show an informational reward overlay
2. load the next map automatically
3. pause before the player can move
4. spend the pending skill point
5. release control

The reward overlay is informational only. It does not contain shop flow or choice surfaces in this first contract.

### 4.4 Campaign Leveling

The player starts the campaign at `Level 1`.

Each cleared map grants one additional level.

Campaign levels:

- improve base stats according to the current GDD values
- grant one skill point

Skill-point rule:

- the point is spent at the start of the next map
- the point may go into any still-locked spell

### 4.5 Unlock Cadence for the First Campaign

The first campaign currently follows this authored unlock cadence:

| Map | Start State | Unlock Reward |
| --- | --- | --- |
| Mission 1 / Tutorial | Basic attack only | `Spell 1` and `Potion 1` during the mission; `Survival` on completion |
| Map 2 | Tutorial rewards already available | next spell becomes available when the next skill point is spent |
| Map 3 | additional spell chosen through level-up | next spell becomes available when the next skill point is spent |
| Map 4 | additional spell chosen through level-up | `Potion 2 (Barrier)` on completion |
| Map 5 / Boss | campaign boss encounter | `Boss Mode` on completion |

`Potion 2 (Barrier)` becomes immediately usable in other supported modes once permanently unlocked.

---

## 5. Campaign Modes

Campaigns may support `Classic` and `Free`, but they do not have equal product responsibility.

### 5.1 Classic

Classic follows the authored campaign path.

Rules:

- the starting route is fixed
- the onboarding beats are authored
- the run order is fixed
- permanent rewards come from `Classic - Easy`
- Classic is the main lore, onboarding, and permanent-progression path

### 5.2 Free

Free Mode is the replay/buildcraft surface that can use broader unlocked loadouts after Classic completion.

It is not the primary progression surface for permanent gameplay unlocks.

Rules:

- Free should not replace Classic as the first-player path
- Free may expose the full `Race -> 1 Weapon -> 4 Skills -> 2 Potions` contract more directly
- Free may use the same authored campaign assets with less authored onboarding
- Free rewards should stay secondary unless a future canon update explicitly promotes them

---

## 6. Difficulty Levels

Campaigns continue to support four difficulty levels:

| Difficulty | Unlock Content | Other Rewards |
| --- | --- | --- |
| Easy | Yes - gameplay unlocks | - |
| Normal | No | mastery, score, or completion recognition |
| Hard | No | mastery, score, or completion recognition |
| Impossible | No | mastery, score, or cosmetic recognition **[TBD]** |

Rule:

- only `Classic - Easy` unlocks gameplay content

---

## 7. Permanent Unlock Rules

Permanent gameplay unlocks come from `Classic - Easy` campaign progress.

| Content Type | Unlock Condition |
| --- | --- |
| Spell 1 | Mission 1 tutorial beat |
| Potion 1 (Health) | Mission 1 tutorial beat |
| Survival | Completing Mission 1 |
| Additional campaign spells | Become spendable as campaign levels grant points |
| Potion 2 (Barrier) | Completing Map 4 |
| Boss Mode | Completing Map 5 |

Cross-mode rule:

- permanent unlocks belong to the account
- other modes may still require in-run level progression before all unlocked spells can be activated

---

## 8. Mode Unlock Sequence

The intended first-player journey is:

1. boot directly into the menu
2. enter `Campanha do Troll`
3. finish Mission 1 and learn `Spell 1` and `Potion 1`
4. return to the menu with `Survival` now unlocked
5. continue the campaign maps in sequence
6. unlock `Potion 2` during the campaign
7. defeat the campaign boss
8. return to the menu with `Boss Mode` unlocked

`Arena Bot` stays available from the start as a free local combat surface.

Private Duel / `Arena PvP` is not part of the account progression path. It remains experimental or development-only until a later product decision promotes it as a casual direct-invite mode.

## 9. Extra Mode Lore Framing

The campaign is the main lore surface.

Extra modes may use light diegetic framing, for example:

- training grounds
- trials
- simulations
- challenge arenas

They should not require separate narrative arcs before the campaign identity is clear.

---

## 10. Suspended Runs

For the current solo-first contract:

- one suspended run may exist per campaign route
- one suspended run may exist for Survival
- one suspended run may exist for Boss
- Arena Bot does not use suspended runs

If a suspended run exists and the player selects that mode again, the menu should offer:

- `Continuar`
- `Abandonar`

Co-op is optional for Release 1 and must not compromise the solo-first campaign baseline. Co-op rules for suspended runs remain **[TBD]**.

---

## 11. Rule for Using This Document

Use this document when the question is about:

- first-launch flow
- tutorial placement
- permanent unlock sequencing
- menu-level mode availability
- campaign progression as a product journey

If implementation diverges from these rules, update this document explicitly instead of letting the runtime drift silently.
