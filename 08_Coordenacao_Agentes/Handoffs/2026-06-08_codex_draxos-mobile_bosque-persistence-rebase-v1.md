# Handoff: DraxosMobile Bosque Persistence Rebase v1

- Data: `2026-06-08`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/bosque-persistence-rebase-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-persistence-rebase-v1`
- Projeto: `Projetos/draxos-mobile`
- Status: implementacao, validacoes locais, merge em `main`, publish Web/APK, manifest e smokes remotos concluidos.

## Entregue Ate Aqui

- Backend Openworld aceita `operations` em `/modes/session/checkpoint` e canoniza progresso em `openworld_forest_progress_v2`.
- Migração espelhada `202606080001_openworld_bosque_persistence_rebase_v1.sql` adiciona `node_state`, `applied_ops`, cooldown por item, operacoes idempotentes e compatibilidade v1 -> v2.
- Client Bosque usa fila `openworld_pending_ops_cache`, estados ACK/retry e bloqueio honesto de saida com operacao duravel pendente.
- Nodes do Bosque usam `next_spawn_at` por item em vez de full reset por visita.
- Versionamento local atualizado para `0.0.10-alpha.0` / version code `10`.
- Docs de Openworld e decision pack documentam ACK + retry, cooldown por item e abandono do full-spawn-reset como modelo principal.
- Release publicado: `internal-alpha/v0-bosque-persistence-rebase-v1-20260608-bc23f74`, preview `https://0c0a8dcf.draxos-mobile-internal-alpha.pages.dev`, official Portal `https://draxos-mobile-internal-alpha.pages.dev/`, Web `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`.
- Hotfix SQL aplicada apos smoke remoto: `202606080002_openworld_bosque_jsonb_object_length_hotfix_v1.sql`, fornecendo shim `public.jsonb_object_length(jsonb)` para o runtime Supabase/PostgREST.
- Remote Openworld operations-v2 smoke passou: coleta com ACK, cooldown `OPENWORLD_NODE_ON_COOLDOWN`, `deposit_all + craft_recipe:fogueira_estavel_1`, e reload por `/modes/state`.

## Validacoes Ja Verdes

- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `npx -y deno test --allow-read server/tests/modes_domain_test.ts server/tests/modes_platform_schema_test.ts server/tests/openworld_ruleset_definition_test.ts server/tests/ops_readonly_cli_test.ts`
- GUT client completo: 242 testes / 3794 asserts.
- `validate_foundation.ps1 -Profile ClientQuick`
- `validate_foundation.ps1 -Profile ServerQuick`
- `validate_foundation.ps1 -Profile ReleaseDryRun`
- `check_release_safety.ps1`
- `check_android_release_keystore.ps1 -Mode InternalAlpha` com warning esperado de `debug_fallback`
- `check_foundation_expansion_readiness.ps1`
- `release_manifest_smoke.ts`
- `release_artifacts_remote_smoke.ts`
- `internal_alpha_remote_smoke.ts`
- `smoke_web_launch_remote.ps1` preview: `game_loaded`
- `smoke_web_launch_remote.ps1` stable Web: `cloudflare_access_expected`
- Remote operations-v2 smoke: PASS

## Proximos Passos

- Commitar este fechamento documental/hotfix no `main`.
- Push nao foi executado porque `git remote -v` nao retornou remote configurado no repo local.
- Smoke humano in-game pela URL principal ainda exige login Cloudflare Access; validar manualmente ACK/retry, cooldowns, Fogueira apos ACK e aviso ao sair durante `Salvando...`.
