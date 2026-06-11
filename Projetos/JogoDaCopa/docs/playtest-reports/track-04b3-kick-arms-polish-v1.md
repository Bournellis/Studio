# Playtest Report - Track 04B3 Kick Arms Polish V1

- Date: `2026-06-11`
- Agent: `Codex`
- Scene: isolated `PlayerAvatar3D` capture of `JogoDaCopa_Kick`
- Branch: `codex/jogodacopa/track04b3-kick-arms-polish-v1`
- Status: `READY_FOR_CLAUDE_REVIEW - not merged`

## What Ran

- Played the authored `JogoDaCopa_Kick` clip with `AnimationTree` disabled.
- Sampled the full `0.36s` clip for objective hand/head and upperarm-abduction metrics.
- Rendered four lateral frames and four frontal frames with the arms visible.
- Ran full headless validation after the arm retune.

## Evidence Captures

Lateral sequence:

- `docs/screenshots/track-04b3-kick-arms/side-frame-00.png`
- `docs/screenshots/track-04b3-kick-arms/side-frame-01.png`
- `docs/screenshots/track-04b3-kick-arms/side-frame-02.png`
- `docs/screenshots/track-04b3-kick-arms/side-frame-03.png`

Frontal sequence:

- `docs/screenshots/track-04b3-kick-arms/front-frame-00.png`
- `docs/screenshots/track-04b3-kick-arms/front-frame-01.png`
- `docs/screenshots/track-04b3-kick-arms/front-frame-02.png`
- `docs/screenshots/track-04b3-kick-arms/front-frame-03.png`

## Checklist

| Item | Result | Evidence |
|---|---|---|
| Arms stay close to body through the kick | PASS | Screenshot sequence and `test_authorial_kick_keeps_hands_below_head_and_upperarms_close` |
| No hand rises above the head | PASS | Minimum hand/head margin: left `0.579m`, right `0.537m` |
| Upperarm abduction stays below configured limit | PASS | Max left `22.26 deg`, max right `21.01 deg`, limit `25.00 deg` |
| Approved leg/trunk timing remains untouched | PASS | Diff only changes arm tracks plus lowerarm flexion tracks |
| Foot remains below pelvis regression | PASS | `test_authorial_kick_keeps_right_foot_below_pelvis` |

## Validation

Command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Result:

- PASS
- `75/75` tests
- `1098` asserts
- Source integrity checked: `29` `.gd/.gdshader` files outside `addons/`

## Notes For Review

- Codex is not making the final aesthetic call.
- Review target is the arm silhouette only: close to body, subtle counter-balance, no shoulder-height windmill.
- This branch is intentionally stopped before merge for Claude review and Fabio visual approval.
