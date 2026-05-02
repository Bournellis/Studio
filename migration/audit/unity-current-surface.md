# Unity Current Surface Audit

This file preserves the audit captured when the workspace still needed an explicit legacy-runtime comparison.

It is historical context only.

## Archived Status

- Legacy workspace: `D:\RPG Isometrico`
- Historical role at cutover: paused reference implementation
- Authority during and after cutover: shared canon in `D:\Estudio\canon`

## What The Legacy Workspace Still Represents

- runtime C# implementation from the older line
- scenes, assets, prefabs, and engine-local content from that line
- operational history under `implementation/phase-*`
- legacy validation/build tooling under `tools/`
- engine-specific compatibility notes from the old stack

## What It Does Not Own

- product identity
- shared gameplay contract
- shared architecture boundaries
- shared mode standard
- active operational direction

## Archived Runtime Snapshot

- The legacy project contained a playable baseline with `Boot`, `FrontEnd`, `Arena`, `MissionSandbox`, `Survival`, and `Boss`.
- Its gameplay contract aligned with `Race -> 1 Weapon -> 4 Skills -> 2 Potions`.
- Its later operational docs recorded a broader bounded content package than the Godot validation cycle currently proves.

Use this file only to understand the cutover context, not to drive new work.
