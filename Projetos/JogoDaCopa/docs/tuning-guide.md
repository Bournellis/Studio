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

Historical Track 01B tuning baseline:

- Ball uses low air damping plus extra horizontal drag only while rolling near the floor.
- Goal half width is `4.32m`.
- Goal frame height is `3.45m`.
- LMB kick force is `20.5`.
- RMB strong kick force is `29.0` with high lift for pop shots.

Historical Track 01C visual baseline:

- Goals are roofed glass boxes and scoring is height-aware.
- Glass walls and ceiling have visible frames, posts and roof ribs for boundary readability.
- Stadium atmosphere is built from runtime primitive stands, crowd color blocks, country-inspired banners, decorative scoreboards and light rigs.

Current post-09N tuning posture:

- Treat `Super Campeao v1.2.1+5c6520ba` as the approved public feel baseline.
- Do not change gameplay tuning during `FootballRoot` reduction tracks unless Fabio explicitly opens a tuning track.
- For any future tuning track, record before/after constants and run `tools/validate.gd`, Web export, first-minute smoke and playtest-focused human review.
- Keep the remote 5-minute `js_heap_growth` stability gate mandatory before publication when a track changes runtime behavior or Web-sensitive orchestration.
- Keep human retest mandatory after public publication before promoting a build as product-approved.

Do not tune FPS weapons, arena pickups or shooter bot behavior here. `FpsPlayground` owns those systems.
