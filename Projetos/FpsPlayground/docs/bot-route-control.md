# Bot Route Control

Track 05 changes the bot from a combat-first state machine into a route-control bot with a combat overlay.

## Design Reference

Arena duel play is not only aim. Strong duel movement is built around:

- controlling major items;
- arriving at important positions before the fight;
- taking health when low instead of forcing bad fights;
- taking damage/stack advantages when healthy;
- using high ground and varied routes to reduce the opponent's options;
- shooting during movement without letting every shot cancel the route.

For this project, the practical rule is:

```text
Movement objective chooses where the bot goes.
Combat overlay chooses whether the bot shoots while going there.
Strafe and cover are local corrections, not the main plan.
```

## Movement Objective

The bot should keep one movement objective active until it arrives, becomes invalid or times out.

Objective examples:

- health pickup when health is low or moderately damaged and nearby;
- overcharge pickup when health is high enough to fight from advantage;
- jump pad route when a high route, item or pressure point requires vertical movement;
- pressure/flank/retreat route when no major item route is more important.

## Combat Overlay

The bot should still shoot a visible target whenever the shot is legal and readable.

Combat overlay must not automatically replace movement with strafe. A bot can fire while:

- moving toward health;
- moving toward overcharge;
- approaching a jump pad;
- recovering from landing;
- pressuring a route.

## Jump Pad Commitment

A jump pad route has three stages:

1. Approach: move to the pad.
2. Flight: preserve the landing route while airborne.
3. Landing recovery: complete the landing zone before returning to strafe/cover.

During flight, the bot should not apply generic strafe or distance-management movement. Its air control should point toward the jump pad target/landing.

## Long Jump Pad Reliability

Long jump pad routes must be reliable on the first attempt, not only after a failed landing realigns the bot. The route contract is:

- the actor position at trigger time contributes to the launch direction;
- horizontal launch speed is derived from route distance and landing height, with clamps to avoid exaggerated launches;
- the bot locks its final approach to the pad entry instead of cutting across the pad edge;
- first-attempt validation covers approach, trigger, flight and landing, not only the post-launch commitment state.

## Item Bias

- High health: prefer overcharge/damage boost and high-ground pressure.
- Low health: prefer health and retreat/reset routes.
- Critical health: health route can override most other movement objectives.
- Full overcharge: do not seek another overcharge.

## Acceptance

- Bot can shoot while following a route.
- Bot does not cancel a health or overcharge route just because it has line of sight.
- Bot completes the long jump pad route before returning to strafe.
- Bot completes `Relay Foundry V1` long jump pad routes on the first attempt from a natural approach.
- Bot uses strafe/cover less as default behavior and more as local fight correction.
