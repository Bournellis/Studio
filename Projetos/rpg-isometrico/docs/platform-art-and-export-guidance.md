# Platform Art And Export Guidance

This file captures the current Godot-local guidance for platform-specific rendering quality, 3D asset export, and initial content budgets.

It applies the shared canon platform posture to the active Godot implementation. It does not redefine canon.

## Canon Alignment

- shared canon remains the source of truth for platform posture in `../../canon/`
- PC and Steam-first remain the active baseline
- mobile remains a future expansion surface, not the current primary target
- mobile support should scale quality down from the same game, not fork gameplay or content rules

## Operational Rule

Use one gameplay implementation and separate quality profiles per target platform.

Do not try to hold mobile to the same rendering cost as desktop.

When platform-specific differences are needed, prefer:

1. Godot export presets per platform
2. ProjectSettings feature-tag overrides such as `.mobile`
3. asset variants or LODs when a single mesh is not cost-effective across both targets

Do not create separate gameplay branches for desktop and mobile quality differences.

## Current Quality Profiles

These are the current starting profiles. They are intentionally conservative and should be tuned after on-device profiling.

### Desktop Baseline

- renderer: `Forward+`
- 3D scaling: `1.0`
- anti-aliasing: `MSAA 4x`
- TAA: `off` by default
- directional shadow size: `4096`
- omni/spot shadow atlas: `4096`
- soft shadow quality: `Medium`
- texture target: characters `2048`, important props `1024`

Use this as the visual baseline while the project remains PC-first.

### Mobile Baseline

- renderer: `Mobile`
- 3D scaling: start at `0.67`
- acceptable fallback: `0.75` if `0.67` is too soft for readability
- anti-aliasing: `FXAA`
- MSAA 3D: `off` by default
- directional shadow size: `2048`
- omni/spot shadow atlas: `1024` to `2048`
- soft shadow quality: `Off` or `Very Low`
- prefer a single main light with shadows
- texture target: characters `1024`, enemies `512`, small props `256` to `512`

For mobile, reduce 3D scaling, shadows, and material complexity before chasing small triangle-count savings.

## Export Strategy In Godot

The same Godot project can export different quality profiles for desktop and mobile.

Use this workflow:

1. keep the gameplay and content definitions shared
2. create platform-specific export presets for desktop and mobile
3. use the default desktop renderer for the desktop preset
4. let mobile overrides and the mobile renderer drive the mobile preset
5. if a runtime graphics menu is added later, keep the same platform baselines and expose only safe user adjustments above them

Important implementation note:

- custom feature tags apply to exported builds, not to normal play-in-editor runs
- validate mobile quality with device deploys or exported builds, not desktop editor assumptions alone

## Tripo3D Asset Export Rule

Preferred import format for Godot:

- `glTF 2.0`
- prefer `.glb` as the default handoff format

Use `.gltf + .bin + textures` only when separated source assets are operationally useful.

Avoid `OBJ` for normal character or animated content because it is limited for pivots, skeletons, animation, UV2, and PBR workflows.

Use `FBX` only when a specific upstream asset behaves better there and `glTF` is not viable.

## Recommended Asset Pipeline

1. generate or refine the model in Tripo3D
2. pass the asset through Blender for cleanup, scale checks, pivot checks, material cleanup, and optional reduction
3. export a Godot-facing `glTF 2.0` `.glb`
4. import into Godot and validate the resulting materials, skeleton, and silhouette
5. add LOD or a dedicated mobile variant if the asset is too expensive across both targets

## Geometry Budgets

Measure budgets in triangles, not generic "polygons".

These are starting budgets for the current isometric camera distance and should be validated against actual combat density.

| Asset class | Desktop target | Mobile target |
| --- | --- | --- |
| Hero | `7k-12k` tris | `3k-6k` tris |
| Common enemy | `2k-4k` tris | `1k-2k` tris |
| Boss | `10k-15k` tris | `5k-8k` tris |
| Important prop | `800-3k` tris | `300-1k` tris |
| Small prop | `100-800` tris | `100-500` tris |

If many actors are visible at once, lower the per-actor budget before expanding effect density.

## Material And Texture Budgets

- prefer `1` material per character whenever practical
- avoid stacking many transparent materials on combat actors
- use `512` or `1024` textures for most gameplay-facing mobile assets
- reserve `2048` textures for desktop hero assets or unusually important close-read elements
- reduce draw calls and shader complexity before over-optimizing topology

On mobile, texture memory, material count, and overdraw can be as important as triangle count.

## LOD And Variant Rule

- prefer a single high-quality source asset when it scales well
- use Godot mesh LOD support for static or simple imported scenes where it behaves cleanly
- test automatic LOD carefully on skinned meshes
- if a character or boss still costs too much on mobile, create a dedicated mobile variant instead of forcing one mesh to serve every target badly

## Implementation Status Note

Current project status:

- this guidance is documented and approved as the initial platform-art baseline
- the initial renderer and shadow baseline now lives in `project.godot`
- initial `Windows Desktop` and `Android` export presets now live in `export_presets.cfg`
- a runtime graphics-options menu does not exist yet
- until such a menu exists, further tuning should continue through import settings, project settings, and export presets

## Review Checklist

When importing new 3D assets or setting up new platform exports, verify:

1. the asset was handed off as `glTF 2.0`, preferably `.glb`
2. the triangle budget matches the asset class and target platform
3. materials are consolidated where practical
4. textures are sized for the target platform and camera distance
5. desktop and mobile are treated as shared gameplay with different quality profiles
6. mobile validation happens on exported builds or devices, not only inside the desktop editor

## Official References

- Godot feature tags: <https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html>
- Godot ProjectSettings reference: <https://docs.godotengine.org/pt_BR/stable/classes/class_projectsettings.html>
- Godot resolution scaling: <https://docs.godotengine.org/en/stable/tutorials/3d/resolution_scaling.html>
- Godot available 3D formats: <https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html>
- Godot mesh LOD: <https://docs.godotengine.org/en/4.3/tutorials/3d/mesh_lod.html>
