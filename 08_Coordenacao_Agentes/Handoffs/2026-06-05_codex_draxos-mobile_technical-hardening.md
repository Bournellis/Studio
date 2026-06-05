# Handoff - DraxosMobile Technical Hardening

## Estado

- Branch: `codex/draxos-mobile/technical-hardening`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--technical-hardening`
- Status: `TRACK_22_TECHNICAL_HARDENING_DELIVERED_LOCAL`
- Remote mutation/publicacao: nenhuma
- Labs: preservados
- Android keystore: fora do escopo desta alpha fechada

## Commits Entregues

- `f922d01` Register DraxosMobile technical hardening
- `a9e3b71` Compact DraxosMobile live status docs
- `5fff39f` Disable release publishing from validation runner
- `63fd088` Isolate mode ops from Godot client
- `89ca721` Extract arena endpoint types
- `437d753` Seed arena reward profiles in database
- `e2fad4e` Harden account save reset idempotency
- `5fd5468` Add shared verified auth context
- `cc83c56` Extract battle replay summary helpers
- `ed4f984` Extract account form contract
- `3f2d224` Extract preparation action contract
- `a0c8ab1` Extract base surface summary helpers
- `676265d` Verify progression lab auth context
- `658f32c` Register technical hardening phase 2
- `3ed38a3` Extend verified auth context for email accounts
- `fcc3f35` Verify content and lab runner auth context
- `2d801ee` Verify base and competition auth context
- `dd12839` Verify economy and social auth context
- `b02f2af` Verify battle and arena auth context
- `671f8b6` Verify modes auth context
- `417d231` Verify release auth context
- `ef50d96` Extract base surface text helpers
- `61deadc` Extract base surface visual helpers
- `498c65e` Extract base crafting surface helpers
- `17f699a` Extract arena surface text helpers

## Entregas Tecnicas

- `implementation/current-status.md` compactado para snapshot vivo; historico longo ficou em tracks/release/docs.
- `validate_foundation.ps1` nao publica mais; `FullPublish` agora exige `publish_internal_alpha.ps1 -ReleaseRoot ... -ConfirmRemoteMutation`.
- `Modes Ops` removido do cliente Godot; Battle Lab e Progression Lab continuam acessiveis.
- Arena endpoint abaixo do budget com tipos extraidos e claim guard read-only.
- `arena_reward_profiles` criado/seeded DB-side e espelhado em `server/schema`.
- Reset de save usa `reset_player_save_v1` com `request_hash`, cleanup DB-side e preservacao de estado social/guild/account-wide.
- Auth compartilhado com verificacao real via Supabase Auth em `account`, `telemetry` e `progression-lab`.
- Hotspots refatorados:
  - `battle_replay_presenter.gd`: 748 -> 528 linhas medidas.
  - `account_session_flow.gd`: 489 -> 408 linhas medidas.
  - `surface_action_flow.gd`: 809 -> 743 linhas medidas.
  - `base_surface_presenter.gd`: 773 -> 420 linhas medidas.
  - `arena_surface_presenter.gd`: 424 linhas medidas apos extracao textual.
- Auth phase 2:
  - `content`, `lab-runner`, `base`, `competition`, `build`, `crafting`, `monetization`, `social`, `battle`, `arena`, `modes` e `release` migrados para `verifiedAuthContext`.
  - `content`, `lab-runner` e `release` exigem conta de email onde aplicavel.
  - `modes` preserva `x-draxos-save-type` obrigatorio em endpoints de modo.

## Validacoes Executadas

- `git diff --check`
- `npx -y deno check server/functions/progression-lab/index.ts supabase/functions/progression-lab/index.ts server/functions/_shared/auth_context.ts supabase/functions/_shared/auth_context.ts`
- `npx -y deno test --allow-read server/tests/auth_context_contract_test.ts`
- `powershell -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`
- `powershell -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`
- `powershell -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -Profile ModePlatform -NoProjectWrites`
- `powershell -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`
- `powershell -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -Profile DatabaseLocal -NoProjectWrites`

Observacao: `ClientQuick` segue imprimindo warnings conhecidos de ObjectDB leak no encerramento do Godot, mas a suite passa.

## Validacao Final Da Fase 2

- `ServerQuick`: PASS (`112` foundation tests + `19` PVE Arena tests).
- `ClientQuick`: PASS (`223/223`, `3608` asserts, smokes responsive/export incluidos).
- `ModePlatform`: PASS (`38/38` mode tests + smokes Bosque/Openworld/Modes Ops).
- `DatabaseLocal`: PASS apos iniciar Docker Desktop, Supabase local e Edge Functions local.
- `ReleaseDryRun`: PASS apos mover Doing para Done.

## Proxima Fase Recomendada

- Fazer review humano da branch e decidir merge.
- `DatabaseLocal` ja foi rerodado com stack local ativa; repetir apenas se houver alteracao DB/Edge antes do merge.
- Proximas features devem partir dos helpers extraidos, sem reabrir presenters grandes.
- Release: antes de qualquer publicacao, rodar release dry-run e usar apenas `publish_internal_alpha.ps1` com confirmacao explicita de remote mutation.
