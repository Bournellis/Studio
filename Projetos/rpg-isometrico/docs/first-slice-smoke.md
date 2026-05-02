# First Slice Smoke (Historical)

This document preserves an earlier validation pass and is no longer the active smoke gate.

Use `g4-shared-mode-foundation-smoke.md` for the accepted local multi-mode baseline.

## Frontend

- open `res://modes/frontend/frontend.tscn`
- confirm the PT-BR frontend loads cleanly
- confirm the action row stays visible at normal desktop window sizes
- confirm the player can assemble the canonical loadout manually
- confirm the frontend does not auto-apply the saved loadout on boot
- confirm `Usar salvo` restores the last saved selection when present
- confirm `Montar conjunto` fills the valid baseline immediately

## Arena

- start the arena from the frontend
- confirm the fight does not start abruptly and shows a readable pre-match countdown
- confirm the camera stays fixed in orientation while still following the player through the arena
- confirm the camera now feels more zoomed out and shows materially more of the arena without hurting input reading
- confirm the larger arena footprint is immediately noticeable compared to the earlier slice
- confirm the closed perimeter walls clearly frame the battlefield without confusing where the play space ends
- confirm the interior wall blocks add shape to the arena without making the fight feel cramped
- confirm the player and bot can move around the new wall blocks without getting stuck in a bad loop
- confirm hits no longer add extra camera displacement or shake during the fight
- confirm hits now create a short, weighty pause without feeling sticky or laggy
- confirm the struck target flashes and pulses more clearly than before
- confirm the arena floor, ring, markers, and combatants are readable without guessing positions
- confirm the arena no longer stacks too many active guides on the floor at once
- confirm the player basic-attack ring helps judge reach without cluttering the floor
- confirm the dash range ring feels useful and subtle rather than noisy
- confirm the bot threat ring becomes easy to read during approach and windup
- confirm the ground aim marker helps with facing and target reading
- confirm the player can move with `WASD`
- confirm the player can attack with mouse left or `Space`
- confirm dash works on `Shift`
- confirm the HUD makes `Ataque` and `Dash` readiness easy to judge during play
- confirm the compact HUD no longer dominates the left side of the screen during normal play
- confirm the four skills respond on `Q`, `E`, `R`, `F`
- confirm the aim reticle becomes greener when a ready manual skill preview would actually catch the bot
- confirm the aim reticle becomes redder when the cursor is clearly beyond the ready manual skill reach
- confirm only the most relevant manual skill preview is emphasized at once instead of both competing equally
- confirm `Impacto do Martelo` no longer snaps to the bot when the cursor is clearly off target
- confirm `Impacto do Martelo` only confirms when the cursor-driven impact point actually catches the bot
- confirm `Impacto do Martelo` now shows a readable impact preview radius on the floor
- confirm the projectile skill reads as a forward strike with a clear target-side impact
- confirm the self-buff skill reads as an aura around the hero instead of a generic combat flash
- confirm the area burst skill reads as a short expanding ground wave around the hero
- confirm buff and burst visuals feel lighter and no longer overwhelm nearby floor cues
- confirm `Salto Quebrador` lands where the cursor authority says rather than homing directly to the bot
- confirm `Salto Quebrador` only deals damage when the landing point actually catches the bot
- confirm `Salto Quebrador` now shows a readable landing preview radius on the floor
- confirm the leap strike reads as movement plus a distinct landing impact
- confirm skill effects stay readable during real exchanges without hiding the player, bot, or floor cues
- confirm the two potions respond on `1`, `2`
- confirm the bot chases and attacks the player
- confirm the bot exposes a readable attack telegraph before melee hits connect
- confirm the bot shows some reposition rhythm instead of feeling glued to a flat chase
- confirm the HUD reflects health, cooldown readiness, combat spacing, player status, bot intent, and recent events in a readable way
- confirm floating feedback appears for damage, heal, block, barrier, and death moments without cluttering the view
- confirm the match ends on death

## Result

- confirm the result overlay appears with `Vitoria` or `Derrota`
- confirm there is a short readable beat between the final hit and the result overlay
- confirm the final-blow beat feels stronger and slightly longer than before without becoming slow
- confirm the result overlay includes round summary stats that match the fight reasonably
- confirm the result overlay stays centered and readable without competing with the combat HUD
- confirm `Voltar ao menu local` returns cleanly
- confirm the next frontend load reflects minimal local persistence
