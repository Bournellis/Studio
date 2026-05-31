# DraxosMobile - Track 18 PVE Arena Initial Published

- Status: Done.
- Branch: `codex/draxos-mobile/pve-arena-integration`.
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--pve-arena-integration`.
- Release root: `internal-alpha/v0-pve-arena-entry-20260531-6cbc853`.
- Preview Web: `https://c185369d.draxos-mobile-internal-alpha.pages.dev/web/index.html`.
- Portal: `https://c185369d.draxos-mobile-internal-alpha.pages.dev/portal/index.html`.
- Android APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-pve-arena-entry-20260531-6cbc853/downloads/draxos-mobile-alpha.apk`.
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-pve-arena-entry-20260531-6cbc853/downloads/draxos-mobile-alpha.zip`.

## Entrega

- Refugio agora prioriza `Arena PVE` no loop normal.
- Atalhos legados de `Batalha` e `Competicao` sairam do mapa principal e ficam acessiveis apenas por ferramentas internas/dev.
- Preparacao orienta o jogador para abrir Arena, nao pedir batalha PVP/legada.
- Track 18 PVE Arena Initial foi exportado, empacotado, publicado no Supabase Storage, publicado no Cloudflare Pages e teve manifest remoto atualizado.

## Validacao

- `git diff --check`: PASS.
- Godot GUT client: 134/134 tests PASS.
- `tools/validate.gd`: PASS.
- `tools/smoke_responsive_layout.gd`: PASS.
- `tools/validate_foundation.ps1 -Profile Full -RequireClean`: PASS.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS (`debug_fallback`).
- `publish_internal_alpha.ps1 -Mode Plan`: PASS.
- `publish_internal_alpha.ps1 -Mode Package`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- `wrangler pages deploy`: PASS.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `release_manifest_smoke.ts`: PASS remoto.
- `release_artifacts_remote_smoke.ts`: PASS remoto.
- `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS remoto.

## Handoff

- Proximo passo humano: testar Web/APK/PC focando tutorial de 1 duelo, arena de 3 duelos, preparacao/loadout, escolha de buff, derrota/conclusao, recompensa e retorno ao Refugio.
- Known release risk: APK usa `debug_fallback` enquanto a keystore release dedicada nao estiver configurada.
