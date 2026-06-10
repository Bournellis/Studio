# JogoDaCopa Tuning Guide

Tune in this order:

1. Ball mass, air damping, ground-roll drag, friction, bounce and wall/ceiling rebound.
2. Field/goal size, glass-wall height and roof height.
3. Player movement speed, turn feel, jump and boost stamina.
4. Kick force, lift and tight kick assist radius.
5. Third-person camera distance, height and subtle ball focus.
6. Bot approach offset, kick cadence and defend/attack switching.
7. HUD and intro readability.

Do not reintroduce possession lock or automatic dribble steering unless a future track explicitly chooses that direction.

Current Track 01B baseline:

- Ball uses low air damping plus extra horizontal drag only while rolling near the floor.
- Goal half width is `4.32m`.
- Goal frame height is `3.45m`.
- LMB kick force is `20.5`.
- RMB strong kick force is `29.0` with high lift for pop shots.

Do not tune FPS weapons, arena pickups or shooter bot behavior here. `FpsPlayground` owns those systems.
