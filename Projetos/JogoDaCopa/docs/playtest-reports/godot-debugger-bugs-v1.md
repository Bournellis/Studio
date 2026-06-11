# Playtest Report - Godot Debugger Bugs V1

- Date: `2026-06-11`
- Agent: `Codex`
- Branch: `codex/jogodacopa/godot-debugger-bugs-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--godot-debugger-bugs-v1`
- Scope: run `Copa Arena Futebol` in Godot, inspect debugger/console issues, and fix any project-side bugs found.
- Constraint: no gameplay code changes unless a runtime project bug is reproduced.

## What Ran

- Fresh worktree boot of the main project scene:
  - `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --path . --quit-after 12`
- One-time headless editor import, repeated once after the GUT plugin asked for a restart:
  - `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --editor --quit --path .`
- Runtime boot of the main menu after import:
  - `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --path . --quit-after 12`
- Runtime boot of the football match scene after import:
  - `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --path . res://modes/football/football.tscn --quit-after 12`
- Full validation:
  - `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`

## Debugger Findings

| Finding | Cause | Resolution |
|---|---|---|
| `No loader found for resource` on menu SFX `.ogg` files | Fresh worktree had no local Godot import cache or imported resource metadata. | Ran one-time headless editor import in the worktree. |
| `No loader found for resource` on `Superhero_Male_FullBody.gltf` | Same import-cache issue; the raw asset file existed but had not been imported for this worktree. | Ran one-time headless editor import in the worktree. |
| `Real avatar fallback on PreviewAvatar variant=male` | Secondary symptom of the missing imported `.gltf`. | Cleared after the import cache was generated. |
| Initial validation failed with unresolved GUT/global classes | Fresh worktree had no `.godot` cache yet. | Cleared after the editor import pass. |
| GUT `ext_resource, invalid UID` warnings after validation success | Existing third-party GUT scene UID fallback; validation still passes and runtime game boot does not emit it. | Recorded as external/editor-only noise, not gameplay bug. |

## Checklist

| Item | Result | Evidence |
|---|---|---|
| Main menu runs without debugger errors after fix | PASS | Post-import runtime boot emitted only Godot/Vulkan header. |
| Football scene runs without debugger errors after fix | PASS | Post-import `res://modes/football/football.tscn` boot emitted only Godot/Vulkan header. |
| Full validation passes | PASS | `64/64` tests, `773` asserts, `[validate] success`. |
| Gameplay code untouched | PASS | No code changes were needed; fix was worktree-local Godot import cache plus documentation. |
| Main workspace dirty files untouched | PASS | Work was isolated in the dedicated worktree. |

## Observations

- The runtime project bug initially shown in the debugger was caused by missing local import cache in a new worktree, not by broken asset paths or gameplay code.
- The imported cache lives in ignored Godot files such as `.godot/`, `.uid`, and `.import`; these stay local to the worktree and are not committed.
- If a future fresh worktree shows the same loader errors before validation, run the headless editor import once before judging runtime asset failures.
