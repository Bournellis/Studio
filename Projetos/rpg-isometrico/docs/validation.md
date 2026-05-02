# Validation

Run the project-standard validation entrypoint from the workspace root or directly from the Godot project.

## Headless Command

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-isometrico -s res://tools/validate.gd
```

## What It Does

- generates gameplay resources and campaign catalogs from `definitions/*.json`
- generates the bootstrap scenes for `boot`, `frontend`, `tutorial`, `campaign`, and the local `Arena`, `Survival`, and `Boss` mode surfaces
- validates the canonical `Race -> 1 Weapon -> 4 Skills -> 2 Potions` contract before launching any mode
- runs the GUT suite under `res://tests/unit`, including boot routing, profile persistence, tutorial completion, campaign catalog resolution, campaign completion, shared routing, launch-context, Arena, Survival, Boss, and presentation parity regression coverage
- points manual follow-up to `docs/canonical-product-foundation-smoke.md`, `docs/campaign-framework-smoke.md`, and `docs/g4-shared-mode-foundation-smoke.md`
