# DraxosMobile - Arena PVE Bonus Visual Publish

- Data: `2026-06-08`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/arena-pve-bonus-visual-publish`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-pve-bonus-visual-publish`
- Base: `main` em `7725342`
- Status: `Done - published Web+APK`

## Objetivo

Corrigir a regressao reportada em que bonus temporarios da Arena PVE, especialmente `max_hp`, eram calculados no simulador mas nao apareciam de forma confiavel na proxima luta/replay, publicar novo pacote Web+APK e redeployar a Edge Function `arena`.

## Resultado Local

- O simulador server/supabase agora grava `hp`, `max_hp`, `max_mana` e `stat_modifiers` em `battleLog.participants`.
- O replay visual da Arena PVE aplica `battle_start` antes da primeira acao e usa os valores iniciais buffados para HP/Mana.
- O contrato de `battle-event-log` documenta o estado inicial calculado e a compatibilidade com logs antigos.
- O pacote candidato foi bumpado para `0.0.14-alpha.0` / version code `14`, mantendo `minimum_supported_version_code` em `13`.

## Validacao Local

- `npx -y deno test --allow-read server/tests/first_slice_simulator_test.ts server/tests/arena_loop_unlock_friction_test.ts`
- Godot import headless.
- GUT focado: `res://tests/client/test_battle_visual_mockup.gd`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `tools/validate.gd`
- `tools/smoke_responsive_layout.gd`
- `git diff --check`
- Mirror hash `server/functions/_shared/battle_simulator.ts` == `supabase/functions/_shared/battle_simulator.ts`

## Publicacao

- Commit de implementacao: `e625808`
- Merge em `main`: `e281d63`
- Release root: `internal-alpha/v0-arena-pve-bonus-visual-v1-20260608-e281d63`
- Preview evidence: `https://6c8bf8e1.draxos-mobile-internal-alpha.pages.dev`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- APK/manifest: `0.0.14-alpha.0` / version code `14`; minimum supported version code `13`
- Android APK SHA256: `1f78020ae1ec5101c9d7b6bc41ca0727d57f4ffa84d769e6fadf076165593720`
- PC Windows ZIP SHA256: `60c4101e0c23f83e16d9bc2307c7da32d4052091807a85cae80b84fa6e954a93`
- Web Index SHA256: `6703e00323874c127cf49bf1db0afeb8a02068d8fed5f093df3b00d4b58febc9`
- Remote functions deployed: `arena`, `release`
- RemoteReadOnly: PASS; Web launch smoke loaded preview in `4568 ms`.
