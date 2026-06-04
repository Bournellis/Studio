# Track 02 Reward System

- Last Updated: `2026-05-18`
- Status: `APPROVED_FOR_IMPLEMENTATION_PLANNING`

## Goals

The Track 02 reward system must support a 29-map complete run without turning every reward into another card.

It should create visible long-run growth through cards, upgrades, relics, Souls, max HP, max mana, max hand size, removal, duplication, and shop decisions.

## Global Rules

- Every map grants Souls.
- Every map has one main reward category.
- Reward rarity remains:
  - common: `70%`
  - rare: `25%`
  - ultra rare: `5%`
- New-card rewards keep the historical Track 01 copy rule:
  - common: add 3 copies;
  - rare: add 4 copies;
  - ultra rare: add 5 copies.
- Card upgrades remain type-based: upgrading a base card affects all copies through the effective Lvl 2/Lvl 3 variant.
- The first Track 02 balance target is max mana `6` and max hand size `5`.
- HP starts at `20`; fixed map rewards raise it to `30`; shop and relics can raise it further.
- Card removal exists both as a map reward and as a shop purchase.
- Card duplication exists both as a map reward and as a shop purchase.
- Permanent player slot count is not a reward in Track 02. Slots are encounter/board properties.

## Main Reward Schedule

| Map | Main reward category | Notes |
|---:|---|---|
| 1 | +1 max mana | Raises mana from 1 to 2. |
| 2 | Class cost-2 card | Adds the existing class core card. |
| 3 | Card upgrade choice | Seeded upgrade choice. |
| 4 | Common relic | First universal relic. |
| 5 | +1 max mana | Raises mana from 2 to 3. |
| 6 | +1 max hand size | Raises hand size from 3 to 4. |
| 7 | Terra new-card choice | Existing Terra pair choice. |
| 8 | Class passive + boss relic | Unlocks class passive; grants boss relic. |
| 9 | Card upgrade choice | Seeded upgrade choice. |
| 10 | Class active + +5 max HP | Unlocks class active; HP max 20 to 25. |
| 11 | Terra remaining card | Grants the unpicked Terra card. |
| 12 | Card upgrade choice | Seeded upgrade choice. |
| 13 | Gelo new-card choice | First Gelo pair choice. |
| 14 | Gelo remaining card | Grants the unpicked Gelo card. |
| 15 | +5 max HP + boss relic | HP max 25 to 30; grants boss relic. |
| 16 | +1 max mana | Raises mana from 3 to 4. |
| 17 | Ar new-card choice | First Ar pair choice. |
| 18 | Card upgrade choice | Seeded upgrade choice. |
| 19 | +1 max mana | Raises mana from 4 to 5. |
| 20 | Ar remaining card | Grants the unpicked Ar card. |
| 21 | Relic choice | Standard relic choice. |
| 22 | +1 max hand size | Raises hand size from 4 to 5. |
| 23 | +1 max mana | Raises mana from 5 to 6. |
| 24 | Fogo new-card choice | First Fogo pair choice. |
| 25 | Card upgrade choice | Seeded upgrade choice. |
| 26 | Fogo remaining card | Grants the unpicked Fogo card. |
| 27 | Utility choice | Remove card, duplicate card, or upgrade card. |
| 28 | Rare/ultra relic | Late-run power spike. |
| 29 | Victory | End of complete run. |

## Souls Shop Defaults

The shop is available between maps and refreshes after victories.

Initial prices:

| Shop action | Default price |
|---|---:|
| Heal +5 HP | 10 Souls |
| Remove card | 15 Souls |
| Duplicate card | 20 Souls |
| Upgrade card | 20 Souls |
| Buy common card | 12 Souls |
| Buy rare card | 18 Souls |
| Buy ultra rare card | 25 Souls |
| Buy common relic | 30 Souls |
| Buy rare relic | 45 Souls |
| Buy ultra rare relic | 70 Souls |
| Reroll shop/reward | 8 Souls, +4 per reroll during the run |
| +3 max HP purchase 1 | 18 Souls |
| +3 max HP purchase 2 | 28 Souls |

Shop constraints:

- Max HP purchase is limited to 2 purchases per run.
- Reroll can target shop inventory or current reward; implementation should expose which surface is being rerolled.
- Shop inventory should clearly show current Souls, card counts, card upgrade level, relic ownership, and resulting state.
- The shop should help recovery and deck shaping, but prices must prevent buying everything.

## Reward Screen Requirements

- Show reward category and rarity before selection.
- Show exact mechanical effect.
- For cards, show copy count from rarity.
- For upgrades, show current level and target level.
- For removal/duplication, show deck count impact.
- For max stat rewards, show before and after values.
- For relics, show full relic text and keyword tooltips.
- For utility choices, show all offered branches in a single modal.

## Balance Targets

- Successful run usually collects 5-6 relics, with more possible through shop.
- Expected final deck size should land around 30-38 cards for a player who takes most cards and uses some removals.
- Strong deck-shaping play should be able to keep the final deck smaller than the default growth path.
- Max mana 6 is a power spike for Fogo, not an early-game baseline.
- Max hand size stays 5 for the first Track 02 test to preserve readability.
