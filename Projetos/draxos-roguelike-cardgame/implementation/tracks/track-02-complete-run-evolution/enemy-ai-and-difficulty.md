# Track 02 Enemy AI And Difficulty

- Last Updated: `2026-05-18`
- Status: `APPROVED_FOR_IMPLEMENTATION_PLANNING`

## Difficulty Policy

Do not apply another global `+20%` enemy stat pass.

Track 02 already increases player power through:

- max mana 6;
- max hand size 5;
- max HP rewards;
- universal relics;
- more cards;
- more upgrades;
- a larger shop;
- card removal and duplication.

Track 02 also increases enemy pressure through:

- all keywords;
- improved AI;
- elemental board effects;
- new encounter modes;
- boss phases;
- enemy intent and special behaviors.

Difficulty should be tuned by element identity, encounter objective, board state, and AI profile instead of blanket stat inflation.

## Element Profiles

### Terra

Purpose: teach durability and basic keyword pressure.

Behavior:

- plays defensively;
- stabilizes lanes;
- protects growing or resistant threats;
- uses Defensor, Espinhos, Resistencia, Crescer, and Atropelar in readable ways.

Stat target:

- moderate HP;
- low to moderate ATK;
- few burst patterns.

### Gelo

Purpose: introduce control and attrition.

Behavior:

- freezes or delays the highest-value threat;
- uses Veneno to pressure long fights;
- disrupts movement and death-trigger plans;
- slows the player's strongest lane rather than only racing HP.

Stat target:

- moderate stats;
- lower burst than Fogo;
- enough HP to make control matter.

### Ar

Purpose: test speed, position, flanks, and intent readability.

Behavior:

- attacks quickly;
- shifts lanes;
- pressures empty lanes;
- favors Iniciativa, Ecoar, Frenesi/mobile behavior, Atropelar, and Brutal.

Stat target:

- lower HP;
- higher ATK and initiative pressure;
- fragile but dangerous.

### Fogo

Purpose: final-block chaos and explosive trades.

Behavior:

- accepts trades;
- creates death cascades;
- uses Brutal, Furia, Ressurgir, Veneno, Espinhos, and on-death effects;
- pressures slow boards without relying only on boss HP.

Stat target:

- high threat;
- mixed HP;
- many threats should be removable but costly.

## AI Model

Use hybrid AI.

Common encounters:

- archetype-driven scoring;
- deterministic enough for intent UI to be trustworthy;
- small randomness allowed only inside tied or low-impact choices.

Bosses:

- scripted phases;
- special behavior by turn, HP threshold, or board state;
- explicit intent panel for current phase and next major trigger.

AI should consider:

- current encounter objective;
- enemy win condition;
- player objective units;
- high-value player threats;
- open lanes;
- Defensor coverage;
- Espinhos and other retaliation risks;
- whether to protect a boss-phase piece;
- whether to trade, stall, burst, or set up a future turn.

## Enemy Intent Panel

The intent panel must show what matters next.

Common encounter intent:

- likely lane pressure;
- likely target priority;
- incoming field effect;
- expected summon/reinforcement when applicable.

Boss intent:

- current phase;
- next scripted trigger;
- next special action;
- HP threshold warnings when known;
- field effect changes.

Rules:

- Intent must be readable without spoiling every random outcome.
- Keywords and field effects shown in intent must have tooltips.
- The panel should explain objective pressure, not only damage.

## Tuning Checks

Each element should be evaluated with:

- average turns per map;
- player HP loss;
- player deaths;
- cards played per combat;
- enemy board clear rate;
- reward and shop usage before/after the element;
- whether the intent panel made deaths feel understandable.

Early target:

- Terra should be forgiving.
- Gelo should create attrition without hard-locking Necromante.
- Ar should feel dangerous but fair if the player reads intent.
- Fogo should be able to kill careless players, but not require perfect relic/card luck.
