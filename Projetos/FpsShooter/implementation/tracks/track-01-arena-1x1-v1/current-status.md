# Track 01 - Arena 1x1 V1

- Status: `ACTIVE`
- Last updated: `2026-06-09`

## Goal

Make the first editor-playable 1x1 FPS arena loop against a basic bot.

## Entry Readiness

Track 00 is complete. `Track 01A - Feel/Feedback V1` and `Track 01B - Bot Duelista V1` are complete and can be used as the baseline for the rest of Track 01.

## Completed Slice

`Track 01A - Feel/Feedback V1` delivered the agile feel pass: player shot feedback, hit/miss distinction, damage overlay, health bars, bot tell, synthetic audio, combatant damage flash and movement defaults tuned for editor duel playtests.

`Track 01B - Bot Duelista V1` delivered the fair bot pass: explicit bot states, line-of-sight gated normal shots, deterministic aim error, arena-side hit/miss raycast resolution, strafe/reposition movement, bot miss feedback and automated coverage for duel behavior.

## Planned Acceptance

- player movement and mouse look feel usable;
- player shot damages bot;
- bot strafes/repositions and shoots with line of sight;
- basic knockback is visible enough to evaluate;
- HUD communicates health and round state;
- `R` restarts the round;
- manual editor smoke is documented.

## Remaining Track 01 Directions

- simple arena layout pass with clearer cover, spawns and sightlines;
- knockback and movement-combat pass;
- later weapon/projectile variants after the hitscan feel remains stable.

## Deferred

- advanced bot behavior beyond fair duel testing;
- special projectiles;
- jump pads;
- suspended platforms;
- void/fall rules;
- export/build packaging.
