# G4 Shared Mode Foundation Smoke

Run this smoke after `tools/validate.gd` passes.

## Preconditions

- open `res://modes/frontend/frontend.tscn`
- keep the same canonical kit for all passes by using `Montar kit`
- run the pass order `Arena Bot -> Survival -> Boss -> shared return/re-entry`
- log each section as `PASS`, `BLOCKED`, or `NOTES`

## Frontend Routing

- confirm the local mode section exposes explicit `Arena Bot`, `Survival`, and `Boss` entry buttons under `Extras`
- confirm the selected mode updates subtitle, summary, controls hint, and the start-button label
- confirm the canonical kit button still enables a valid launch without applying the saved selection automatically
- confirm a previously saved local profile reopens the frontend with the saved mode still selected
- confirm the saved-kit state names the saved mode when local persistence is available
- confirm each mode launches from the same frontend surface without scene-path guesswork or manual parameter edits

## Arena Regression

- launch `Arena Bot` from the frontend
- confirm the accepted G3 Arena baseline still opens cleanly
- confirm the camera follows the player while keeping one locked angle and fixed zoom
- confirm the match still reaches the shared result overlay with `Resumo principal`
- confirm the shared combat shell keeps `Arena Bot: treino de kit`, readable spacing, and recent-event lines without collapsing into one long sentence
- confirm the result overlay reads as `RESULTADO DO EXTRA` and frames the outcome as bot simulation / kit practice, not PvP progression
- confirm `Voltar a Campanha e Extras` returns cleanly and the next mode can still be entered from the same frontend session

## Survival Baseline

- launch `Survival` from the frontend
- confirm the playable Survival scene opens instead of falling back unexpectedly
- confirm the camera follows the player while keeping one locked angle and fixed zoom
- confirm the player spawns into `Onda de Trolls` with troll pressure arriving from multiple edge spawn points
- confirm the shared combat shell shows tempo, onda, inimigos ativos, and wave/rest state without forking into a separate HUD family
- confirm the rest state clearly flips to `intervalo antes da onda ...` with visible `Folego` time before the next push
- confirm the shared result overlay surfaces tempo, onda concluida, and the aligned `Resumo principal`
- confirm the result overlay reads as `RESULTADO DO EXTRA`, includes the `Extra` section, and says permanent progression remains in the campaign
- confirm the result return flow lands back on the frontend without stale mode or launch-context behavior

## Boss Baseline

- launch `Boss` from the frontend
- confirm the authored Boss arena opens instead of falling back unexpectedly
- confirm the camera keeps one locked angle and fixed zoom while still reframing the player-plus-boss combat space
- confirm the shared combat shell shows boss phase, boss HP, readable intent, and Boss-specific tempo data without forking into a separate HUD family
- confirm the Boss shell keeps `vida %`, readable rugido readiness, and any active tremor or invulnerability state on one shared HUD family
- confirm the Boss Troll wakes up, uses Grande Martelada, Tremor Rastejante, and Rugido Atordoante with readable transition beats between phases
- confirm both victory and defeat route through the shared result overlay and return to the frontend
- confirm the result overlay frames Boss as maestria/practice and not as a new permanent unlock path

## Shared Return Contract

- while inside any mode, confirm `Esc` returns to the frontend
- confirm each mode can be entered again from the frontend without stale launch-context behavior
- confirm the frontend still shows the correct mode copy before each re-entry instead of retaining outdated result-state messaging

## Exit Judgment

- if `tools/validate.gd` is green and this smoke finds no blockers, the local Godot base is ready for `Checkpoint G4 - Local Multi-Mode Base Acceptance`
- if a blocker appears, record whether it belongs to `frontend routing`, `runtime boot`, `shared combat shell`, `shared result overlay`, or `return/re-entry` before reopening implementation work
