# Arena Shooter Future Roadmap

- Status: Track 13 future planning baseline.
- Scope: near-term growth plan for `FpsPlayground` Arena Shooter.
- Rule: this document does not change gameplay; it defines safe expansion order.

## Current Foundation

The approved baseline is a PC Windows editor-first 1x1 arena lab with:

- three selectable arenas;
- preserved player movement feel;
- route-first bot movement;
- rifle, Plasma Bolt, Plasma Blast and overcharge;
- health and overcharge pickups;
- repeatable first-to-3 duel flow;
- local telemetry and readout tooling.

## Expansion Principles

- Add one major gameplay idea per track.
- Use telemetry/readout before balance changes.
- Preserve movement feel unless a dedicated movement track is approved.
- Preserve jump pad force unless a reproduced issue targets jump pads.
- Keep bot difficulty based on route quality, timing and pressure, not unfair aim.
- Keep new content compatible with multiple arenas instead of hardcoding one map.
- Prefer prototype-readable primitives over final art until gameplay proves itself.

## Map Direction

Future arenas should explore different duel rhythms:

- compact pressure arena with frequent line-of-sight breaks;
- wider timing arena with longer item rotations;
- vertical control arena with multiple high-route commitments;
- risk/reward arena with exposed power routes and safer reset routes.

Every new arena must define:

- one readable ground loop;
- spawn safety and fast re-engagement;
- health and overcharge as different route decisions;
- jump pad entry, landing and recovery space when vertical routes exist;
- pressure, flank, cover, retreat and objective tactical roles;
- telemetry expectations for route diversity, pickup value and jump pad success.

## Weapon Direction

Current weapon roles:

- Rifle: precision, finishing and sustained pressure.
- Direct Plasma: higher-commitment impact shot.
- Plasma Blast: near-miss and cover pressure.
- Overcharge: temporary advantage, not automatic round win.

Future weapons should not be added until Track 15 defines the arsenal contract. Candidate roles:

- close pressure weapon with range limits;
- delayed area-denial projectile;
- utility shot that changes positioning without raw DPS dominance;
- high-risk burst tool with clear cooldown/readability.

Avoid adding:

- ammo economy before role clarity;
- reload complexity before the duel loop needs it;
- weapon wheel UI before there are enough proven roles;
- self-damage or rocket-jump behavior unless a dedicated movement-combat track is approved.

## Buff And Pickup Direction

Current pickup roles:

- Health: reset and recovery route.
- Overcharge: advantage route when healthy enough to contest.

Future buffs should create movement decisions first and stat changes second. Candidate categories:

- temporary damage advantage;
- temporary defense/stack advantage;
- temporary mobility route access without changing base movement feel;
- visibility/reveal utility for tactical pressure;
- cooldown/resource utility for weapon experiments.

Avoid buffs that:

- remove the need to rotate through the map;
- decide a duel without readable counterplay;
- invalidate health routing;
- stack into unclear telemetry.

## Bot Direction

The bot should grow after map/combat baselines are clearer.

Future bot improvements:

- choose weapon pressure based on range and route objective;
- value pickups from arena timing instead of only immediate proximity;
- react to player control of major items;
- use different route families per arena without map-specific conditionals;
- expose clearer telemetry for decision reasons.

Non-goals:

- instant aim upgrades;
- combat state that cancels every movement objective;
- hardcoded behavior for one arena id.

## Telemetry Direction

Telemetry should become the default proof layer for future tracks.

Track-level readouts should answer:

- Which arena was played?
- Which weapon or source dealt meaningful damage?
- Did pickups change route decisions?
- Did the bot rotate routes?
- Did jump pad triggers and landings stay healthy?
- Did the change preserve the approved movement feel?

Do not treat one session as balance truth. Use repeated signals across arenas before changing core values.

## Recommended Sequence

1. `Track 14 - Multi-Arena Balance Baseline V1`
2. `Track 15 - Arsenal And Buff Contracts V1`
3. `Track 16 - Combat Tuning V1`
4. `Track 17 - Arena Production Rules V1`
5. `Track 18 - Bot Duel Intelligence V2`

## Explicitly Out Of Scope

- Football/TPS.
- Draxos progression, economy or backend systems.
- Multiplayer, matchmaking or remote analytics.
- Web/mobile/export publication.
- Final art direction.
