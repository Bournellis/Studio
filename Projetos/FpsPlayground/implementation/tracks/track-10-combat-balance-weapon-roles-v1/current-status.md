# Track 10 - Combat Balance And Weapon Roles V1

- Status: `READY_FOR_HUMAN_SMOKE`
- Started: `2026-06-19`
- Owner: Codex
- Branch: `codex/fpsplayground/track10-combat-balance-weapon-roles-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track10-combat-balance-weapon-roles-v1`
- Base: Track 09 combat sandbox implemented locally and approved by Fabio.

## Goal

Consolidate combat balance after Plasma Impact Blast V1 so rifle, direct Plasma, Plasma Blast, overcharge and bot pressure have clear and testable roles.

## Delivered Values

- Player rifle: `22` damage, `0.18` cooldown.
- Player Plasma direct: `24` damage, `0.9` cooldown.
- Player overcharge: `x1.35` damage, `x1.25` knockback.
- Plasma Blast: `1.65` radius, `46%` max damage fraction, `22%` minimum damage fraction.
- Overcharged Plasma Blast: `2.25` radius.
- Bot shot: `9` damage, `0.76` cooldown, `0.18` tell.
- Bot overcharge: `x1.25` damage, `x1.18` knockback.

## Role Contract

- Rifle remains the main precision and finishing tool.
- Direct Plasma rewards prediction and impact, but does not replace rifle DPS.
- Plasma Blast pressures cover and near misses, but does less damage than direct hits.
- Overcharge creates a meaningful one-shot advantage without deciding a duel alone.
- Bot pressure remains readable and fair.

## Guardrails

- Do not change player movement constants, acceleration, air control, jump, gravity or camera sensitivity.
- Do not change jump pad force, launch routing or arena geometry.
- Do not change bot route-control movement, pickup priority or jump pad commitment.
- Do not add new weapons, ammo, reloads, self-damage, rocket-jump behavior or UI-heavy systems.

## Delivered

- Added automated role contracts for rifle, Plasma direct, Plasma Blast, overcharge and bot shot pressure.
- Tuned direct Plasma to hit harder per shot while staying far below rifle sustained DPS.
- Tuned Plasma Blast to remain pressure/near-miss value instead of replacing direct hits or rifle shots.
- Kept bot shot pressure readable and below player burst values.
- Preserved player movement constants, jump pads, maps, bot route-control and pickup behavior.

## Validation Plan

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path "D:\Estudio-worktrees\FpsPlayground--codex--track10-combat-balance-weapon-roles-v1\Projetos\FpsPlayground" -s res://tools/validate.gd
git diff --check
powershell -ExecutionPolicy Bypass -File D:\Estudio\tools\check_doc_drift.ps1
```

Latest automated result:

```text
PASS, GUT 43/43, 396 asserts
```

## Human Smoke

- Confirm rifle still feels like the primary precision weapon.
- Confirm direct Plasma feels higher commitment than rifle and stronger than splash.
- Confirm Plasma Blast pressures cover without becoming the default best shot.
- Confirm overcharge is valuable on rifle or plasma without feeling like an instant win.
- Confirm bot shots remain readable and fair.
- Confirm movement, jump pads, maps and bot route-control feel unchanged.
