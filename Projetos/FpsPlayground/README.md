# FpsPlayground

## Metadata

- status: `active`
- authority: `router`
- last_verified: `2026-07-16`
- review_when: `project identity or entry points change`
- supersedes: `FpsPlayground README before Governance v2`
- superseded_by: `none`

`FpsPlayground` is the studio's independent Godot first-person arena gameplay laboratory for PC Windows, editor first. Football/TPS work lives in `../JogoDaCopa`.

## Start Here

1. `AGENTS.md`
2. `implementation/current-status.md`
3. `08_Coordenacao/README.md`
4. `docs/documentation-index.md`
5. `qa/QA_INDEX.md`

## Run

Open `project.godot` in Godot `4.6.2-stable` and press Play.

## Validate

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd -- --profile=full
```

The QA manifest defines the typed workspace runners. No build, publication, remote service or physical-device authority is configured here.
