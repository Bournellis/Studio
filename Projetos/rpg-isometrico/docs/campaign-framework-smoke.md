# Campaign Framework Smoke

Use this smoke after changes that touch the first campaign framework, profile persistence, or the Boss unlock path.

## Preconditions

- start from a fresh profile with no campaign completion
- open `res://modes/frontend/frontend.tscn`

## Frontend Gate

- confirm `Campanha do Troll` is enabled from the start
- confirm `Campanha` reads as the primary menu group and `Extras` reads as the secondary group
- confirm the campaign panel shows inline `Easy`, `Normal`, and `Livre` chips
- confirm `Easy` is selected by default
- confirm `Normal` is visible but disabled before `blacksmith_campaign / easy` is completed
- confirm `Livre` is visible but disabled before `blacksmith_campaign / easy` is completed, with copy pointing to `Classic - Easy`
- confirm `Arena Bot` is also enabled from the start
- confirm `Survival` is blocked before Mission 1 is completed
- confirm `Boss` is still blocked before the campaign is completed
- confirm extra-mode summaries frame `Arena Bot` as kit training, `Survival` as resistance, and `Boss` as mastery practice
- confirm `Arena PvP` / `Duelo Privado` is not presented as a normal public menu entry
- confirm the default selected mode is `Campanha do Troll`

## Tutorial Entry

- launch `Campanha do Troll`
- confirm the campaign opens through `Mission 1 / Tutorial`
- confirm a `CAMPANHA CLASSICA` briefing appears before control is released
- confirm the briefing says the Classic campaign teaches and equips the kit gradually, without requiring a full kit setup before playing
- finish the tutorial encounter and return to the frontend
- confirm `Survival` is now enabled on the same profile
- confirm `Normal` and `Livre` are still visible but remain blocked until the full `Easy` route is completed
- open `Survival`, use `Preparar kit`, and confirm later skills plus the second potion stay visible but disabled with campaign-learning copy instead of being hidden

## Campaign Pass

- launch `Campanha do Troll` again
- confirm the campaign opens with the shared combat shell instead of a fallback scene
- confirm the authored route still runs in the exact order `mission_01 -> mission_02 -> mission_03 -> mission_04 -> mission_05`
- confirm the shell reads `Campaign 1` in `Classic - Easy`
- clear each of the first four stages and confirm the reward overlay reads as `AVANCO DA CAMPANHA`
- confirm reward copy names the next journey step, permanent kit learning, extra-mode openings, and pending level-up context without ad hoc copy branches
- after the stage-4 reward, continue into the next map and confirm the barrier potion is already equipped in the second campaign potion slot
- suspend on one reward overlay, return to the frontend, resume the run, and confirm the same reward payload rebuilds without duplicating permanent unlocks
- if a legacy `Easy` suspended run exists under the old campaign-only key, confirm the frontend still surfaces it and the first compatible resume migrates it into the new route-specific key
- clear the final campaign stage and confirm the shared result overlay opens without crashing
- confirm the result overlay reads as `RESULTADO DA CAMPANHA`
- confirm the result details include the campaign section, Boss as an extra of mastery, and next-step guidance back to Campaign/Extras

## Boss Unlock Return

- return to the frontend through `Voltar a Campanha e Extras`
- confirm `Boss` is now enabled on the same local profile
- confirm `Normal` is now enabled on the same local profile
- confirm `Livre` is now enabled on the same local profile
- switch to `Normal` and confirm the CTA, summary, and suspended-run messaging all update to the selected difficulty
- launch `Normal` and confirm the authored route still resolves through 5 stages with `mission_05` as the boss stage
- suspend a `Normal` run, return to the frontend, and confirm the `Easy` and `Normal` suspend states stay independent
- switch to `Livre`, use `Preparar kit`, and confirm the builder exposes learned account content through the full `4 habilidades / 2 pocoes` contract
- launch `Livre`, clear one stage, and confirm replay reward copy does not grant or promise permanent unlocks
- confirm `Campanha do Troll`, `Survival`, and `Arena Bot` remain enabled
- confirm `Survival` or `Arena Bot` now expose the full `4 habilidades / 2 pocoes` kit learned by that profile
- launch an extra mode and confirm the result overlay reads as `RESULTADO DO EXTRA`, includes an `Extra` section, and says permanent progression remains in the campaign

## Regression

- launch `Survival` and confirm the shared local runtime still opens normally
- launch `Boss` and confirm the shared result and return flow still behave as expected after the unlock
