# JogoDaCopa Bot Contract

The active bot is the `Futebol 1x1` football bot.

- Alternates attack and defend based on ball position, score pressure and kickoff ownership.
- Approaches behind the ball relative to the opponent goal before attacking.
- Holds a defensive kickoff posture when the player owns kickoff.
- Can kick the ball through the football root request flow; current routing goes through the kick/SUPER controller facade.
- Uses the same football arcade vocabulary as the player where adopted locally: dash, flip, stun recovery, boost pads and SUPER.
- Reads boost pad targets from the football arcade field controller instead of using FPS pickup routes.
- Uses main-menu difficulty presets (`easy`, `normal`, `hard`) to tune speed, cadence, hesitation and kick accuracy without exposing debug-only controls.
- Should remain readable and fair for a fast arcade minigame.
- Does not use shooter weapons, line-of-sight combat or FPS arena route-control behavior.

Arena duel bot behavior lives in `../FpsPlayground`.
