# Unity Legacy Surface

This guide records Unity paths that are still important to RPG Isometrico history but no longer reflect current naming canon.

## Purpose

For RPG Isometrico, the active project now lives in `D:\Estudio\Projetos\rpg-isometrico` as a Godot implementation. Track 02 is the active operational line unless `implementation/current-status.md` says otherwise, and the canonical loadout has no passives.

This is not a studio-wide routing guide. For general `D:\Estudio` work, start with `AGENTS.md`, `Projetos/README.md`, and `08_Coordenacao_Agentes/Estado_Atual.md`.

Some Unity paths still carry older names because they are referenced by:
- `Resources.Load(...)`
- hardcoded scene names
- editor tooling and build verification
- historical tests and preserved validation seams

These paths belong to the paused legacy Unity surface. Treat them as historical compatibility references, not as guidance for naming new Godot systems.

## Legacy Paths Kept In Place

The following surfaces remain in their current locations because they are still path-sensitive:

- `Assets/Game/Content/Phase3/`
- `Assets/Game/Resources/Phase3/`
- `Assets/Game/Scenes/FrontEnd/FrontEnd_Phase3.unity`
- scripts, HUD classes, and editor tooling that still use the `Phase3` name

Do not rename or move these paths without updating:
- resource load strings
- scene load strings
- editor build/export tooling
- tests that validate those paths directly

## Legacy Content Isolated

The passive content assets are preserved only as legacy content under:

- `Assets/Game/Content/Legacy/Passives/`

The passive runtime and asset family remain in the repo only for historical continuity and serialized-data compatibility. They are not part of the current canonical loadout model.

## Rule for New Work

- New active content should not be placed under `Phase3`-named roots unless it must extend an existing compatibility surface.
- New work must not reintroduce passive gameplay as current canon.
- New Godot work belongs under `D:\Estudio\Projetos\rpg-isometrico` and should follow shared canon plus the active track docs.
- If a broader Unity naming cleanup is ever executed, it must be planned as a dedicated refactor with path-by-path validation.
