# DraxosMobile - Debug Clean + Web Supabase Config

- Status: `DONE`
- Agent: Codex
- Branch: `codex/draxos-mobile/debug-clean-web-config`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-final-polish`
- Base commit: `e4f3a11`
- Objective: clean Godot debug noise found after Foundation Final Polish publication and fix the Web app login path reporting local Supabase unavailable.

## Scope

- Godot debug warnings and debug-only validation behavior.
- Session cache parsing robustness.
- Web/runtime Supabase config path for the published Internal Alpha app.
- Validation, commit and handoff after fixes.

## Guardrails

- No gameplay tuning.
- No schema/backend gameplay expansion.
- No remote mutation unless explicitly required and already approved by the user's publication/debug request.
- Do not expose secrets in client/export/portal artifacts.

## Validation Plan

- Godot main debug run.
- `tools/validate.gd` normal and debug where feasible.
- GUT client.
- Responsive smoke.
- Web export/package config inspection.
- Release/Web config smoke for Supabase URL selection.
- `git diff --check`.

## Findings

- Manual Web login failure was not local Supabase downtime. The published Web
  client sent `x-draxos-api-version: 1`, but stale published Edge Functions did
  not include that header in CORS preflight allow-list, so the browser blocked
  `account/guest` before it reached Supabase.
- Remote Edge Functions were redeployed for Internal Alpha and the remote smoke
  now checks browser `OPTIONS` preflight across auth and major function
  adapters.
- Main app debug log is clean. Debug validation/GUT still emits a final
  engine-level `GDScriptFunctionState` shutdown warning from async GUT runner
  states, not live UI nodes.

## Validation Results

- `npx -y deno check server/tests/internal_alpha_remote_smoke.ts`: PASS.
- Remote `server/tests/internal_alpha_remote_smoke.ts` with release manifest:
  PASS after Edge Function redeploy.
- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- Godot main `--headless --debug --quit-after 30`: PASS, no warning/error
  matches in `build/debug/godot_main_debug_clean_latest.log`.
- Godot `tools/validate.gd --debug`: PASS (`133/133`, `2271` asserts), with
  only the known final GUT coroutine-state shutdown warning.
- `tools/smoke_responsive_layout.gd --debug`: PASS, with the same known final
  GUT/Godot shutdown warning.
- `validate_foundation.ps1 -Profile Client`: PASS.
- `git diff --check`: PASS.
