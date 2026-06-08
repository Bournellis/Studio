# DraxosMobile - Arena PVE Bonus Visual Publish

- Data: `2026-06-08`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/arena-pve-bonus-visual-publish`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-pve-bonus-visual-publish`
- Base: `main` em `7725342`
- Status: `Done - local validation complete; publication in progress`

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

Pendente nesta execucao: commit, merge, publish Web+APK, deploy remoto de `arena`, smokes remotos e registro final de release root/preview.
