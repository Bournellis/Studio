# DraxosMobile - Runtime Config Online Actions Hotfix

- Data: `2026-06-05`
- Agente: `codex`
- Branch: `codex/draxos-mobile/runtime-config-online-actions`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--runtime-config-online-actions`
- Status: implementado, mesclado em `master` e publicado remotamente no endpoint `release/config`.

## Problema

O endpoint remoto `GET /release/config` estava retornando:

- `guardrails.read_only: true`
- `guardrails.mutable_gameplay_state: false`

Com isso, o cliente exibia `Acoes online de progresso estao pausadas pela configuracao remota.` e bloqueava servicos de jogo mesmo com o pacote Arena PVE First Real Run + Update Recovery publicado.

## Entrega

- `server/functions/release/index.ts` e `supabase/functions/release/index.ts` agora usam `config_version: track23-online-actions-hotfix`.
- Runtime config publicada passa a retornar `read_only: false` e `mutable_gameplay_state: true`.
- Fallback do cliente permanece conservador quando a config remota falha: sem config valida, acoes online continuam bloqueadas.
- `server/tests/runtime_config_smoke.ts`, `release_auth_contract_test.ts`, `tools/smoke_runtime_config.gd` e `docs/contracts/api-endpoints.md` foram alinhados ao contrato correto.

## Validacao Local

- `git diff --check`: PASS.
- `deno test --allow-read server/tests/release_auth_contract_test.ts`: PASS, 4 tests.
- `deno check server/functions/release/index.ts supabase/functions/release/index.ts server/tests/runtime_config_smoke.ts server/tests/release_auth_contract_test.ts`: PASS.
- `tools/smoke_runtime_config.gd`: PASS.
- `validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`: PASS.
- Primeira tentativa de `ClientQuick`: falhou por cache de import ausente no worktree novo (`GutUtils`, class_names e `.ctex`), antes do hotfix.
- `Godot --headless --import`: PASS.
- Segunda tentativa de `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS, incluindo GUT `229/229`, runtime config, responsive layout, visual modes e exports.

## Handoff

- `ReleaseDryRun`: PASS depois deste cartao sair de `Doing`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `GET /release/config` remoto validado com `config_version: track23-online-actions-hotfix`, `read_only: false`, `mutable_gameplay_state: true`, `no_service_role: true` e `no_secrets: true`.
- `runtime_config_smoke.ts` remoto: PASS contra `https://armxgipvnbbshzqawklw.supabase.co`.
