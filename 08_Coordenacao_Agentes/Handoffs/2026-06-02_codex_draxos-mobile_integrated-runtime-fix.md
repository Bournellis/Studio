# DraxosMobile Handoff: Integrated Runtime Fix

## Metadata

- data: `2026-06-02`
- agente: `Codex`
- projeto: `draxos-mobile`
- branch: `codex/draxos-mobile/integrated-runtime-fix`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--integrated-runtime-fix`
- base_commit: `eff0997`
- status: `PUBLISHED_INTERNAL_ALPHA`

## Objetivo

Corrigir o pacote integrado App/Arena/Bosque, validar o runtime real e publicar um unico Internal Alpha integrado na URL principal.

## Escopo Aplicado

- Bosque online:
  - serializa eventos autoritativos em fila;
  - usa a revisao mais recente depois de cada ACK;
  - evita mutacao local otimista de coleta, deposito e craft antes do servidor confirmar;
  - ressincroniza em erro nao transient e tenta novamente em erro de rede.
- Mode Platform:
  - `/modes/session/event` agora retorna envelope comum `stateEnvelope(...)`, igual aos outros endpoints de modo.
- Arena:
  - battle log autoritativo de duelo PVE agora inclui `metadata.mode = "PVE_ARENA_V1"`, permitindo que o cliente reconheca replay/resumo de Arena.
- Validacao:
  - smokes Bosque remoto/local agora exercitam `collect_start` antes de `collect_complete`;
  - contratos Deno exigem envelope em session/event, fila serial no client e metadata de Arena.

## Evidencia Local Ate Aqui

- `npx -y deno test --allow-read server/tests/modes_platform_schema_test.ts server/tests/arena_consistency_pass_schema_test.ts server/tests/modes_domain_test.ts`: PASS, 22 testes.
- `npx -y deno check server/functions/modes/mode_handler.ts supabase/functions/modes/mode_handler.ts server/functions/arena/index.ts supabase/functions/arena/index.ts server/tests/internal_alpha_remote_smoke.ts server/tests/modes_platform_live_test.ts`: PASS.
- Godot import headless: PASS.
- `Godot --headless --path . -s res://tools/validate.gd`: PASS, 179 testes.
- `Godot --headless --path . -s res://tools/smoke_openworld_forest.gd`: PASS.
- `Godot --headless --path . -s res://tools/smoke_responsive_layout.gd`: PASS.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`: PASS.

## Publicacao Final

- release root:
  `internal-alpha/v0-integrated-runtime-fix-20260602-ab5834c`;
- official Portal URL:
  `https://draxos-mobile-internal-alpha.pages.dev/`;
- direct Web URL:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`;
- Cloudflare deployment evidence:
  `https://888320f4.draxos-mobile-internal-alpha.pages.dev`;
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-integrated-runtime-fix-20260602-ab5834c/downloads/draxos-mobile-alpha.apk`;
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-integrated-runtime-fix-20260602-ab5834c/downloads/draxos-mobile-alpha.zip`;
- remote manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`.

## Evidencia Remota Final

- `supabase db push --linked --yes`: PASS; aplicou
  `202606020002_openworld_bosque_policy_active_compat.sql`.
- `supabase functions deploy`: PASS para `modes`, `arena` e `release`.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- `wrangler pages deploy ... --branch main --commit-hash ab5834c`: PASS.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`:
  PASS.
- `release_manifest_smoke.ts`: PASS.
- `release_artifacts_remote_smoke.ts`: PASS; production fixo retorna
  Cloudflare Access para leituras anonimas, como esperado.
- `internal_alpha_remote_smoke.ts` com release, anon auth, account, email auth,
  mode e Arena habilitados: PASS.
- `smoke_web_launch_remote.ps1` na URL principal: PASS como
  `cloudflare_access_expected`.
- `smoke_web_launch_remote.ps1` no preview:
  PASS como `game_loaded`, release root e asset root corretos.

## Pendencias Antes De Fechar

- Playtest humano do pacote integrado corrigido:
  login/cache refresh, primeira Arena real, Arena replay/reward e Bosque online
  start/event/deposit/complete.
- Android segue em `debug_fallback`; release signing permanece pendente para
  distribuicao Android mais ampla.

## Remote Mutation Approval

Fabio aprovou em `2026-06-02` um unico release integrado na URL principal:

- `https://draxos-mobile-internal-alpha.pages.dev/`

Inclui Supabase DB push se necessario, Edge Functions, Supabase Storage, Cloudflare Pages, release manifest e contas/saves descartaveis de teste. Todos os comandos remotos ainda devem usar `-ConfirmRemoteMutation` quando exigido pelos scripts.
