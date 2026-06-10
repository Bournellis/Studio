# JogoDaCopa Tuning Guide

Tune in this order:

1. Ball mass, air damping, ground-roll drag, friction, bounce and wall/ceiling rebound.
2. Field/goal size, goal roof closure, glass-wall height and roof height.
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

Current Track 01C visual baseline:

- Goals are roofed glass boxes and scoring is height-aware.
- Glass walls and ceiling have visible frames, posts and roof ribs for boundary readability.
- Stadium atmosphere is built from runtime primitive stands, crowd color blocks, country-inspired banners, decorative scoreboards and light rigs.

Do not tune FPS weapons, arena pickups or shooter bot behavior here. `FpsPlayground` owns those systems.
