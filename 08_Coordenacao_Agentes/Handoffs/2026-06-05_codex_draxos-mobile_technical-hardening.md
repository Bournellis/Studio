# Handoff - DraxosMobile Technical Hardening

## Estado

- Branch: `codex/draxos-mobile/technical-hardening`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--technical-hardening`
- Status: `ACTIVE_LOCAL_HARDENING_PHASE_1_DELIVERED`
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
  - `base_surface_presenter.gd`: 773 -> 590 linhas medidas.

## Validacoes Executadas

- `git diff --check`
- `npx -y deno check server/functions/progression-lab/index.ts supabase/functions/progression-lab/index.ts server/functions/_shared/auth_context.ts supabase/functions/_shared/auth_context.ts`
- `npx -y deno test --allow-read server/tests/auth_context_contract_test.ts`
- `powershell -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`
- `powershell -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`

Observacao: `ClientQuick` segue imprimindo warnings conhecidos de ObjectDB leak no encerramento do Godot, mas a suite passa.

## Proxima Fase Recomendada

- Auth phase 2: migrar endpoints mutaveis restantes para `verifiedAuthContext` em pacotes pequenos, com espelhos `server/` e `supabase/`:
  - candidatos provaveis: `base`, `build`, `crafting`, `monetization`, `battle`, `social`, `competition`, `arena` e `modes`.
- Refactor phase 2: se houver tempo antes de novas features, extrair parser de equip/build e depois social/base controls/panels.
- Release: antes de qualquer publicacao, rodar release dry-run e usar apenas `publish_internal_alpha.ps1` com confirmacao explicita de remote mutation.
