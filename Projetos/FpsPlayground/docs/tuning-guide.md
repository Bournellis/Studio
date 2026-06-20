# FpsPlayground Tuning Guide

Tune from evidence, not from one isolated duel.

## Current Rule

The current player movement feel is approved and should stay unchanged unless Fabio explicitly starts a movement track.

## Tuning Order

1. Collect multi-arena telemetry and readout evidence.
2. Confirm whether the issue repeats across more than one session.
3. Choose the smallest target: weapon role, pickup value, buff timing, bot decision or arena route.
4. Add or update a guardrail test before changing values.
5. Playtest the changed feel before broadening the track.

## Default Priority

1. Weapon roles: rifle, direct Plasma, Plasma Blast and overcharge contribution.
2. Pickup and buff route value.
3. Bot shot pressure, route choice and aim fairness.
4. Arena cover, item placement, jump pad approach and high-route readability.
5. Player movement and mouse sensitivity only in a dedicated movement track.

## Guardrails

- Do not tune all arenas from one arena's data.
- Do not buff Plasma Blast until direct Plasma and rifle roles are still readable.
- Do not increase bot aim pressure if route decisions are the actual weakness.
- Do not increase pickup strength when the problem is route placement.
- Do not use buffs to bypass map movement.
- Do not tune football values here. `JogoDaCopa` owns football possession, ball physics and TPS camera tuning.
