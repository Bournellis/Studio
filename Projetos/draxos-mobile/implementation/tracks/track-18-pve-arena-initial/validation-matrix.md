# Track 18 - PVE Arena Validation Matrix

- Status: `ACTIVE`
- Applies to: `PVE_ARENA_INITIAL`
- Last updated: `2026-05-31`

## Acceptance Scenarios

| Scenario | Expected Result | Evidence |
|---|---|---|
| Tutorial arena start | Server creates a 1-duel PVE attempt with locked loadout snapshot. | API test plus client smoke. |
| Tutorial arena complete | Winning the duel completes the attempt and applies first-clear reward once. | Backend idempotency test. |
| Three-duel arena complete | Player resolves three duels with HP reset each duel and completion reward after final win. | API test plus battle log metadata. |
| Loss on step 1 | Attempt ends as failed and does not grant completion reward. | Backend test. |
| Loss on middle step | Previous step logs remain readable; attempt ends without completion reward. | Backend test. |
| Loss on final step | Attempt records best progress and no completion reward. | Backend test. |
| Buff choice valid | A buff offered after victory can be chosen once and is applied to later duels only. | API test. |
| Buff choice invalid | A non-offered buff is rejected and state remains unchanged. | API idempotency/state test. |
| Repeat request | Reusing `request_id` returns same result and does not duplicate resources. | RPC/Edge idempotency test. |
| PVE without ranking | Arena PVE never inserts or updates `ranking`. | DB test. |
| Reset save | Reset clears arena attempts, steps and progress for that save. | DB reset test. |
| Replay old battle | Replay reads saved `battle_log_v1` and does not rerun simulator or rewards. | API test. |
| Locked loadout | Loadout snapshot remains stable for the whole attempt. | API state test. |
| Behavior between duels | Behavior can change between duels without changing loadout. | Client/API test. |
| Repeat reward factor | Repeat completion reward is reduced or capped by server rules. | Economy test. |

## Local Gate

Run from `Projetos/draxos-mobile`:

```powershell
git diff --check
npx -y deno task --cwd server/functions check
npx -y deno task --cwd supabase/functions check
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Full -RequireClean
```

## Release Gate

- `publish_internal_alpha.ps1 -Mode Plan` must pass before packaging.
- `publish_internal_alpha.ps1 -Mode Package` may run after local Full gate.
- `Upload`, `DeployManifest` and `FullPublish` remain blocked until explicit user approval with `-ConfirmRemoteMutation`.

## Human Playtest Script

1. Enter with a normal save.
2. Open Arena from Refugio.
3. Start tutorial arena.
4. Confirm loadout lock screen is understandable.
5. Complete tutorial duel.
6. Choose a temporary stat buff when offered.
7. Start the 3-duel arena.
8. Confirm next enemy preview appears before each duel.
9. Complete or lose the arena.
10. Return to Refugio and confirm reward/progression copy points to upgrades, not PVP.
