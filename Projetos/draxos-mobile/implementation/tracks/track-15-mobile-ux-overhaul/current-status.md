# Track 15 - Mobile UX Overhaul Current Status

- Last updated: `2026-05-28`
- Status: `TRACK_15_MOBILE_UX_OVERHAUL_ACTIVE`
- Branch: `codex/draxos-mobile/track-15-mobile-ux-overhaul`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--track-15-mobile-ux-overhaul`
- Base: `codex/draxos-mobile/agent-ops-foundation` at `ed63a65`

## Current State

The first integrated Track 15 package is implemented in the Codex worktree. It focuses on UX shell, Entry/Login/Save, Refugio hub, battle/reward flow and the main secondary surfaces. It preserves backend, schema, simulator, economy and authoritative presenter boundaries.

Implemented:

- `assets/ux_overhaul/` runtime references for Entry, Refugio and Battle backgrounds.
- Dark premium/gore UI tokens, larger mobile touch targets and reusable panel/button/shell sizing.
- Premium pre-login Entry with fullscreen background art, login as first focus, save selector below login, collapsed internal tools and separated danger actions.
- Direct login/signup/guest routing to Refugio.
- Refugio visual hub with contextual CTA priority: result, collect, upgrade, battle.
- Surface actions opened from Refugio, including Loja, now return to Refugio on back instead of Entry.
- Floating Perfil/Ajustes post-login surface without login/signup form.
- Base, Loja, Social and Competicao copy/CTA cleanup.
- Fullscreen Battle stage with discreet `Pular`, non-overlapping portrait HP labels, reward summary and primary return CTA.
- Tests covering save/login routing, lab visibility, copy hygiene, touch targets, CTA priority and summary reward.

## Intended Files

- `Projetos/draxos-mobile/core/`
- `Projetos/draxos-mobile/assets/ux_overhaul/`
- `Projetos/draxos-mobile/modes/boot/`
- `Projetos/draxos-mobile/ui/`
- `Projetos/draxos-mobile/tests/client/`
- `Projetos/draxos-mobile/tools/`
- `Projetos/draxos-mobile/docs/`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-15-mobile-ux-overhaul/`
- `08_Coordenacao_Agentes/`
- `Projetos/README.md`

## Validation Result - 2026-05-28

Result: `PASS` for client/foundation scope.

Commands executed:

```powershell
git diff --check
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --import
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_hardening.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_exports.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --path . -s res://tools/capture_track15_mobile_ux.gd
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { .\tools\validate_foundation.ps1 -ProjectDir . -Profile Client -RequireClean:`$false }"
```

Results:

- `tools/validate.gd`: pass, 109 tests / 1762 asserts.
- Direct GUT client run: pass, 109 tests / 1762 asserts.
- `smoke_foundation_hardening.gd`: pass.
- `smoke_exports.gd`: pass.
- `capture_track15_mobile_ux.gd`: pass; screenshots generated in `build/track15_mobile_ux_checkpoint/`.
- `validate_foundation.ps1 -Profile Client`: pass.
- `git diff --check`: pass.

Known validation noise:

- GUT/Godot prints existing resource UID/orphan warning noise on exit. Tests exit green.

## Open Review

- Human review is still required for the Track 15 Android portrait checkpoint.
- Visual screenshots were generated for Entry, Refugio, Battle, Summary, Base and Loja in `build/track15_mobile_ux_checkpoint/`.
- After review, continue focused UX polish or run the Track 13 manual walkthrough before gameplay/tuning/release work.

## Next Handoff

Keep this branch as the Track 15 integration branch. Do not mix gameplay, tuning, backend/schema, account/save migration or remote publication into this package.
