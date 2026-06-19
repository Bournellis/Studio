# Track 09 - Combat Sandbox Expansion V1

- Status: `IN_PROGRESS`
- Started: `2026-06-19`
- Owner: Codex
- Branch: `codex/fpsplayground/track09-combat-sandbox-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track09-combat-sandbox-v1`
- Base: Track 07 implemented locally; Track 08 movement feel experiment discarded before merge.

## Goal

Add one small combat sandbox experiment without changing the approved player movement feel.

The selected experiment is `Plasma Impact Blast V1`: Plasma Bolt keeps its direct-hit role, but a missed bolt that hits world geometry can create a short, readable blast that applies partial area damage near the impact point.

## Guardrails

- Do not change player movement constants, acceleration, air control, jumping, gravity or camera sensitivity.
- Do not change jump pad force, launch routing or arena geometry.
- Do not change bot route-control movement, jump pad commitment or pickup priority.
- Do not add self-damage or rocket-jump behavior in this track.
- Do not add a new weapon input, ammo economy, weapon wheel or full art pass.

## Planned Delivery

- Add deterministic blast damage/falloff helper coverage.
- Resolve Plasma Bolt world impact as a readable blast.
- Keep direct plasma hits and rifle behavior intact.
- Add compact HUD/feedback events for normal and overcharged blasts.
- Add automated regression coverage for blast behavior and movement guardrails.

## Validation Plan

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
git diff --check
powershell -ExecutionPolicy Bypass -File D:\Estudio\tools\check_doc_drift.ps1
```

## Human Smoke

- Confirm rifle and direct Plasma Bolt still feel unchanged.
- Fire Plasma Bolt into floor/walls near the bot and confirm a readable partial blast.
- Confirm overcharged Plasma Bolt blast is more visible and stronger.
- Confirm player movement, jump pads and all three arena routes feel unchanged.
- Confirm bot remains route-first and does not gain unfair aim or reaction.
- Confirm round flow, score, restart and pause-menu reset still work.
