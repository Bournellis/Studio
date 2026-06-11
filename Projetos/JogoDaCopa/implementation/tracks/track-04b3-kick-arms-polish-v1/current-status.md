# Track 04B3 - Kick Arms Polish V1

- Date: `2026-06-11`
- Branch: `codex/jogodacopa/track04b3-kick-arms-polish-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04b3-kick-arms-polish-v1`
- Status: `COMPLETE - approved and merged to main`
- Source: Fabio playtest verdict after Track 04B1 + 04B2 integration

## Objective

Polish only the arm tracks in the authored `JogoDaCopa_Kick` clip. Fabio approved the kick legs, trunk and timing; those tracks remain untouched.

## Root Cause

The previous kick arm tracks used near-neutral upperarm rotations plus lateral swing. On the Quaternius skeleton bind pose, that pushed the upperarms into wide abduction and lifted the hands near/above the head during the mid-kick, producing the "moinho de vento" silhouette seen in `docs/screenshots/track-04b1-character-presentation-v1/kick-frame-02.png`.

## Implementation

- Retuned only `upperarm_l` and `upperarm_r` in `_build_authorial_kick_animation()`.
- Added `lowerarm_l` and `lowerarm_r` tracks for mild elbow flexion.
- Kept the approved `spine_02`, `thigh_r`, `calf_r`, `foot_r`, clip length and `KICK_TIMES` unchanged.
- Counter-balance now stays close to the body: opposite arm subtly forward, same-side arm subtly back, no upperarm raised above shoulder line.

## Before To After

| Measurement | Before | After |
|---|---:|---:|
| Upperarm abduction range observed by the new red test | `~77.29-107.93 deg` | `left max 22.26 deg`, `right max 21.01 deg` |
| Limit | none | `25.00 deg` |
| Hand/head vertical relation | hands could rise above head | left hand at least `0.579m` below head, right hand at least `0.537m` below head |

## Tests

Added in `tests/unit/test_avatar_system.gd`:

- `test_authorial_kick_keeps_hands_below_head_and_upperarms_close`

Coverage:

- Samples the whole `0.36s` clip at `0.045s` intervals.
- Asserts `hand_l` and `hand_r` stay below `Head`.
- Asserts `upperarm_l` and `upperarm_r` abduction stay `<= 25.0 deg`.
- Existing regression `test_authorial_kick_keeps_right_foot_below_pelvis` remains PASS.

## Evidence

Playtest report:

- `docs/playtest-reports/track-04b3-kick-arms-polish-v1.md`

Rendered frames:

- `docs/screenshots/track-04b3-kick-arms/side-frame-00.png`
- `docs/screenshots/track-04b3-kick-arms/side-frame-01.png`
- `docs/screenshots/track-04b3-kick-arms/side-frame-02.png`
- `docs/screenshots/track-04b3-kick-arms/side-frame-03.png`
- `docs/screenshots/track-04b3-kick-arms/front-frame-00.png`
- `docs/screenshots/track-04b3-kick-arms/front-frame-01.png`
- `docs/screenshots/track-04b3-kick-arms/front-frame-02.png`
- `docs/screenshots/track-04b3-kick-arms/front-frame-03.png`

## Validation

- One-time headless editor import ran for the new worktree cache.
- Red test reproduced the issue before the production retune.
- Rendered capture ran with Vulkan/Forward+ on NVIDIA GeForce RTX 4070 Ti.
- `tools/validate.gd`: PASS, `75/75` tests, `1098` asserts.
- Source integrity: PASS, `29` `.gd/.gdshader` files outside `addons/`.
- Known validation noise: existing GUT UID/text-path warnings.

## Handoff

Claude review and Fabio visual approval accepted the new kick arm silhouette. The branch was merged locally into `main`; network push remains Fabio/GitHub Desktop only.
