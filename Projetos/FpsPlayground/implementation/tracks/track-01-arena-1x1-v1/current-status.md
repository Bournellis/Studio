# Track 01 - Arena 1x1 V1

- Status: `ACTIVE`
- Last updated: `2026-06-09`

## Goal

Make the first editor-playable 1x1 FPS arena loop against a basic bot.

## Entry Readiness

Track 00 is complete. `Track 01A - Feel/Feedback V1`, `Track 01B - Bot Duelista V1`, `Track 01C - Arena Layout V1` and `Track 01D - Knockback Movement Combat V1` are complete and can be used as the baseline for the rest of Track 01.

## Completed Slice

`Track 01A - Feel/Feedback V1` delivered the agile feel pass: player shot feedback, hit/miss distinction, damage overlay, health bars, bot tell, synthetic audio, combatant damage flash and movement defaults tuned for editor duel playtests.

`Track 01B - Bot Duelista V1` delivered the fair bot pass: explicit bot states, line-of-sight gated normal shots, deterministic aim error, arena-side hit/miss raycast resolution, strafe/reposition movement, bot miss feedback and automated coverage for duel behavior.

`Track 01C - Arena Layout V1` delivered `Duel Pit V1`: protected spawns, a central blocker, low/high cover, side platforms, ramps, visual route marks and bot reposition points tied to the new map.

`Track 01D - Knockback Movement Combat V1` delivered readable hit/received knockback: horizontal force, controlled lift, stacked impulse clamps, air/ground decay differences, debug helpers and primitive knockback feedback on real hits.

## Planned Acceptance

- player movement and mouse look feel usable;
- player shot damages bot;
- bot strafes/repositions and shoots with line of sight;
- knockback is visible, directional and useful enough to evaluate;
- HUD communicates health and round state;
- `R` restarts the round;
- manual editor smoke is documented.

## Remaining Track 01 Directions

- later weapon/projectile variants after the hitscan feel remains stable.
- first hazard/verticality expansion when movement-combat feel is accepted.

## Deferred

- advanced bot behavior beyond fair duel testing;
- special projectiles;
- jump pads;
- suspended platforms;
- void/fall rules;
- export/build packaging.
