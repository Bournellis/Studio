# DraxosMobile Hardening Done: Bosque Persistence Rebase v1

## Metadata

- data: `2026-06-08`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `backend-schema + session-data + mode-scaffolds + validation-release`
- mode_scope: `openworld`
- branch: `codex/draxos-mobile/bosque-persistence-rebase-v1`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-persistence-rebase-v1`

## Objetivo

Rebasear a persistencia do Bosque para ACK + retry server-authoritative, com nodes persistentes por cooldown de item, versao `0.0.10-alpha.0` e publicacao Web/APK no canal Internal Alpha.

## Latest Context

- latest remote package before this work: `Bosque Session Lifecycle & Durable Structures Hotfix v1`
- published package from this work: `Bosque Persistence Rebase v1`
- published release root: `internal-alpha/v0-bosque-persistence-rebase-v1-20260608-bc23f74`
- published preview evidence: `https://0c0a8dcf.draxos-mobile-internal-alpha.pages.dev`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`
- Openworld source: `docs/minigames/openworld.md`
- Openworld decision source: `docs/minigames/openworld-decision-pack.md`
- release source: `docs/release-ops-checklist.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/docs/minigames/openworld-decision-pack.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`

## Escopo

- Incluir:
  - progresso duravel `openworld_forest_progress_v2` com `node_state` e `applied_ops`;
  - checkpoint operations v2 para coleta, deposito, craft, guidance e posicao;
  - fila local `openworld_pending_ops_cache` e feedback honesto de ACK;
  - cooldown por item para nodes do Bosque;
  - testes client/server e docs vivas;
  - versionamento, commit, merge e publicacao Web/APK.
- Fora do escopo:
  - PVP, social, economia ampla, tuning amplo, novos mapas, NPCs, combate, quests ou novos assets finais;
  - trabalho em worktrees de outros agentes;
  - secrets em Git/docs/export.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/data/definitions/openworld/forest_ruleset_v1.json`
- `Projetos/draxos-mobile/modes/openworld/`
- `Projetos/draxos-mobile/online/session_store.gd`
- `Projetos/draxos-mobile/server/schema/migrations/`
- `Projetos/draxos-mobile/supabase/migrations/`
- `Projetos/draxos-mobile/server/functions/`
- `Projetos/draxos-mobile/supabase/functions/`
- `Projetos/draxos-mobile/tests/client/`
- `Projetos/draxos-mobile/server/tests/`
- `Projetos/draxos-mobile/docs/minigames/`
- release/version/status docs.

## Validation Plan

- `git diff --check`
- Openworld GUT targeted
- full GUT client
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- Openworld/modes Deno tests
- `validate_foundation.ps1 -Profile ClientQuick`
- `validate_foundation.ps1 -Profile ServerQuick`
- `validate_foundation.ps1 -Profile ReleaseDryRun`
- `check_release_safety.ps1`
- `check_android_release_keystore.ps1 -Mode InternalAlpha`
- `check_foundation_expansion_readiness.ps1`
- release package/upload/deploy/manifest and remote smokes after local gates.

## Handoff Point

Implementacao, validacao local, merge em `main`, publicacao Web/APK e smokes remotos concluidos. O pacote publicado usa artefatos gerados no commit `bc23f74`; depois do primeiro smoke remoto de operations v2 foi aplicada e documentada a hotfix SQL `202606080002_openworld_bosque_jsonb_object_length_hotfix_v1.sql`.

## Resultados Locais

- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- Deno modos/ruleset/ops targeted: PASS, 43 tests.
- GUT client completo: PASS, 242 tests / 3794 asserts.
- `validate_foundation.ps1 -Profile ClientQuick`: PASS.
- `validate_foundation.ps1 -Profile ServerQuick`: PASS apos atualizar o release fallback contract para o pacote novo.
- `validate_foundation.ps1 -Profile ReleaseDryRun`: PASS.
- `check_release_safety.ps1 -ProjectDir .`: PASS.
- `check_android_release_keystore.ps1 -ProjectDir . -Mode InternalAlpha`: PASS com warning esperado de `debug_fallback`.
- `check_foundation_expansion_readiness.ps1 -ProjectDir .`: PASS.
- `git diff --check`: PASS antes e depois da hotfix.
- Migracao `202606080001_openworld_bosque_persistence_rebase_v1.sql`: server/supabase byte-equivalente por SHA-256.
- Hotfix `202606080002_openworld_bosque_jsonb_object_length_hotfix_v1.sql`: server/supabase byte-equivalente por SHA-256 `85EAE02DBFB0FC7DAF42C6E4012531E39A9A1E4DC3762C724030FE361B3CC5DD`.
- Tests pos-hotfix `npx -y deno test --allow-read server/tests/modes_platform_schema_test.ts server/tests/openworld_ruleset_definition_test.ts`: PASS, 28 tests.

## Publicacao

- Commits logicos criados na branch:
  - `2b137b5 docs: register bosque persistence rebase contract`
  - `0195f2b backend: add bosque operations persistence v2`
  - `2bfe2d5 client: make bosque saves ack-backed`
  - `07f5723 test: cover bosque persistence rebase`
  - `bc23f74 release: bump internal alpha to 0.0.10`
- Branch fast-forward merged em `main` no commit `bc23f74`.
- Remote Supabase migration `202606080001_openworld_bosque_persistence_rebase_v1.sql`: aplicada.
- Remote Supabase migration `202606080002_openworld_bosque_jsonb_object_length_hotfix_v1.sql`: aplicada apos smoke remoto detectar que o runtime nao possui `jsonb_object_length(jsonb)`.
- Supabase functions `modes` e `release`: deployadas.
- `publish_internal_alpha.ps1 -Mode Plan -ReleaseRoot internal-alpha/v0-bosque-persistence-rebase-v1-20260608-bc23f74 -PublicDownloads`: PASS.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -ReleaseRoot internal-alpha/v0-bosque-persistence-rebase-v1-20260608-bc23f74 -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-bosque-persistence-rebase-v1-20260608-bc23f74 -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: PASS, preview `https://0c0a8dcf.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-bosque-persistence-rebase-v1-20260608-bc23f74 -PublicDownloads -ConfirmRemoteMutation`: PASS.

## Smokes Remotos

- `release_manifest_smoke.ts`: PASS, manifest `0.0.10-alpha.0` / code `10` / minimum `10`.
- `release_artifacts_remote_smoke.ts`: PASS; APK, ZIP, Portal e Web URLs corretos; stable Portal/Web protegidos por Cloudflare Access.
- `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS.
- `smoke_web_launch_remote.ps1` no preview hash: PASS, `game_loaded` em `6658 ms`, release root correto, assets principais 200, sem runtime errors.
- `smoke_web_launch_remote.ps1` na URL principal direta: PASS como `cloudflare_access_expected`.
- Remote Openworld operations-v2 smoke: PASS; `collect_node` ACK persistiu pocket/cooldown, coleta duplicada retornou `OPENWORLD_NODE_ON_COOLDOWN`, `deposit_all + craft_recipe:fogueira_estavel_1` persistiu `upgrades` + `structures`, `/modes/state` recarregou cooldown e Fogueira.

## Artefatos

- APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-persistence-rebase-v1-20260608-bc23f74/downloads/draxos-mobile-alpha.apk`
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-persistence-rebase-v1-20260608-bc23f74/downloads/draxos-mobile-alpha.zip`
- Android APK SHA256: `1679e8db843331707d22bb083c29eeb5182cb92cf141b4d6f46fd2ddeee3c858`
- PC Windows ZIP SHA256: `49d080f57a31f2ceead45f678a60c57e27f89a9d8964114a3499bc42ca8e63e3`
- Web Index SHA256: `a79ce8e74a64468611806cdaa41e73cfbbf6671180d33a9b7d422503ff91c2d9`

## Pendencias Humanas

- Smoke humano in-game na URL principal ainda depende de autenticar pelo Cloudflare Access no navegador do jogador/testador.
- Playtest recomendado: ACK/retry, cooldown apos relog, Fogueira somente apos ACK, aviso ao sair durante `Salvando...`, descarte claro de ops pendentes quando a sessao expira, e regressao Arena/Bosque.
