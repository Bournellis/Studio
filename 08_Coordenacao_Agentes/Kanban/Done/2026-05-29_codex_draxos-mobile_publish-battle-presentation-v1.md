# Publicar Battle Presentation v1

- Data: `2026-05-29`
- Projeto: `Projetos/draxos-mobile`
- Agente: Codex
- Branch: `codex/draxos-mobile/publish-battle-presentation-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--publish-battle-presentation-v1`
- Base: `master` em `f5a68af`
- Resultado: `BATTLE_PRESENTATION_V1_PUBLISHED`

## Entrega

Battle Presentation v1 foi publicado para Internal Alpha como pacote client-only. A publicacao atualizou Android APK, PC Windows ZIP, Web/site e portal, sem backend, schema, migration, API, simulador, economia ou `battle_log_v1` novo.

Links principais:

- Stable portal: `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Stable Web: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Preview verificado: `https://2a470539.draxos-mobile-internal-alpha.pages.dev`
- Web asset root: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-presentation-20260529/web`

Artefatos:

- Android APK: `31633429` bytes, SHA256 `e4789c43d83a4ae931d575daca27b10591c5d8f790b9ca2d1e968f8c089ded97`
- PC Windows ZIP: `40101277` bytes, SHA256 `82b3b493ec5384fd18f7f3334d70297997489da7935c84dc193019ddcc6428a5`
- Web index: `5442` bytes, SHA256 `4a80d29956931a8363587ed01b4e1a7890b3858205dd243b41432ccd8d9e7582`

## Validacao

- `validate_foundation.ps1 -Profile Client`: PASS (`119/119`, `1895` GUT asserts mais smokes runtime/hardening/responsive/export).
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: PASS.
- Supabase Storage upload: PASS para `internal-alpha/v0-battle-presentation-20260529` e `internal-alpha/v0`.
- `build_cloudflare_pages_package.ps1`: PASS com Web asset root versionado.
- Cloudflare Pages deploy: PASS; preview final `https://2a470539.draxos-mobile-internal-alpha.pages.dev`.
- `server/tests/release_manifest_smoke.ts`: PASS.
- `server/tests/internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS.
- Preview GET checks: PASS para portal, `manifest.example.json` empacotado e Web com `GODOT_CONFIG`.
- Remote HEAD checks: PASS para versioned `index.js`, `index.pck`, `index.wasm`, APK versionado e APK estavel sem Bearer token.

## Observacao

`publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation` foi bloqueado antes de alterar secrets porque o ambiente local nao tinha `SUPABASE_ACCESS_TOKEN`. O endpoint remoto de manifest continua saudavel, e o portal publicado foi ajustado para ler o `manifest.example.json` empacotado com os links/hashes desta publicacao.

## Handoff

Proximo passo recomendado: revisar Battle Presentation v1 publicado em Android, Windows e Web, entao escolher o proximo pacote de produto. Manter direct chat, ajudas, contribuicoes, moderacao, tuning numerico, armas, spells, economia e controles avancados de replay fora de escopo ate decisao explicita.
