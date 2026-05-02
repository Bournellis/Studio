# Canonical Product Foundation Smoke

Use this smoke after changes that touch the canonical bootstrap, tutorial, profile persistence, or product mode gating.

## Bootstrap

- delete the local profile if present
- launch the project
- confirm the first boot enters the frontend instead of a pre-menu tutorial

## Frontend Entry

- confirm `Campanha do Troll` is enabled and selected as the default journey
- confirm the mode section presents `Campanha` as the primary group and `Extras` as the secondary group
- confirm the campaign panel shows inline `Easy`, `Normal`, and `Livre` chips
- confirm `Easy` is selected by default
- confirm `Normal` is visible but blocked before `Easy` is completed
- confirm `Livre` is visible but blocked before `Easy` is completed, with copy pointing to `Classic - Easy`
- confirm `Arena Bot` is enabled from the start
- confirm `Survival` is blocked before Mission 1
- confirm `Boss` is still blocked by campaign progress
- confirm `Arena Bot`, `Survival`, and `Boss` copy reads as training, resistance, or mastery extras rather than alternate campaign pillars
- confirm `Arena PvP` / `Duelo Privado` is not presented as a normal public menu entry

## Tutorial Entry

- launch `Campanha do Troll`
- confirm it opens through `Mission 1 / Tutorial`
- confirm a `CAMPANHA CLASSICA` briefing appears before control is released
- confirm the briefing frames the route as gradual kit learning instead of requiring a full pre-run kit
- confirm the tutorial opens with the Blacksmith wrapper and no combat HUD
- confirm the player starts with movement and basic attack only
- defeat one troll and confirm the first-skill unlock copy appears
- finish the encounter and confirm the tutorial completes without crashing

## Product Return

- confirm the next surface after tutorial completion is the frontend
- confirm `Campanha do Troll` remains enabled and selected as the default journey
- confirm `Easy` remains selected by default and `Normal` / `Livre` are still visible but blocked until the full `Easy` route is completed
- confirm `Survival` is now enabled
- confirm `Boss` is still blocked by campaign progress
- confirm `Arena Bot` remains enabled
- confirm `Arena PvP` / `Duelo Privado` remains absent from normal public navigation
- open `Survival` or `Arena Bot`, use `Preparar kit`, and confirm later skills plus the second potion remain visible as disabled kit entries with campaign-learning guidance copy
- confirm extra-mode result copy reads as `RESULTADO DO EXTRA` and separates score/mastery results from permanent campaign progression

## Campanha Livre Return

- after completing `Easy`, return to the frontend and confirm `Livre` is enabled
- select `Livre` and confirm it reads as `Campanha Livre` replay/buildcraft, not as the primary unlock path
- use `Preparar kit`, confirm the builder requires `1 raca`, `1 arma`, `4 habilidades`, and `2 pocoes` from learned account content
- launch `Livre` and confirm the runtime starts at `Mapa 1` with the prepared kit, `CAMPANHA LIVRE` briefing, and no Classic tutorial prompts
- clear a replay stage and confirm reward copy reads as `REPLAY LIVRE` and does not promise permanent unlocks

## Regression

- run the campaign flow smoke in `campaign-framework-smoke.md`
- run the existing local runtime smoke in `g4-shared-mode-foundation-smoke.md`
- confirm Arena Bot, Survival, and Boss still boot correctly when launched through valid requests
- confirm extra-mode results return through `Voltar a Campanha e Extras`
