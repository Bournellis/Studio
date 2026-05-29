# DraxosMobile - Publish Refuge And Battle Hotfix

- Data: `2026-05-28`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/foundation-responsive-guardrails`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-app-v0-audit`
- Status: `DONE`

## Objetivo

Publicado novo build Internal Alpha com os hotfixes aprovados pelo Fabio:

- Refugio como raiz da sessao pos-login e Labs Dev visiveis no Refugio.
- Splash estatica enquanto uma batalha solicitada aguarda abertura do replay.

## Publicacao

- Portal estavel: `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web estavel: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Preview Cloudflare verificado: `https://34c70f2f.draxos-mobile-internal-alpha.pages.dev`
- Android APK publico unlisted: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0/downloads/draxos-mobile-alpha.apk`
- PC ZIP publico unlisted: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0/downloads/draxos-mobile-alpha.zip`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

## Artefatos

| Artefato | Bytes | SHA256 |
|---|---:|---|
| Android APK | `31567507` | `7e96dded13578764ff2cbcb84f795830e3aab371dde7754748c898f135e4de5e` |
| PC Windows ZIP | `40035466` | `bccf2cecb4459f16cf68dcb4a43698128d76ae6fa25cd7ece3779656bbba8ecf` |
| Web index | `5442` | `7769cf8acb38daffe1006683416cebfa82d42993b5a2e3a8e51a444a01718f27` |

## Validacao

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_exports.gd
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\export_internal_alpha.ps1 -ProjectDir . -EnvFile D:\Estudio\Projetos\draxos-mobile\.env.internal-alpha.local -GodotExe D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe -AllowAndroidDebugFallback
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -EnvFile D:\Estudio\Projetos\draxos-mobile\.env.internal-alpha.local -Mode Upload -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_cloudflare_pages_package.ps1 -ProjectDir .
npx -y wrangler pages deploy .\build\internal-alpha\cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -EnvFile D:\Estudio\Projetos\draxos-mobile\.env.internal-alpha.local -Mode DeployManifest -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation
```

Resultados:

- `smoke_exports.gd`: OK.
- Export Internal Alpha: OK, Android em `debug_fallback`.
- Upload Supabase Storage: OK com `-PublicDownloads`.
- Cloudflare Pages deploy: OK, preview `https://34c70f2f.draxos-mobile-internal-alpha.pages.dev`.
- Deploy manifest Supabase Function: OK.
- `release_manifest_smoke.ts`: OK.
- `release_artifacts_remote_smoke.ts`: OK; portal/web protegidos por Cloudflare Access como esperado.
- `internal_alpha_remote_smoke.ts`: OK.
- HEAD APK: `200`, `application/vnd.android.package-archive`, `31567507` bytes.
- HEAD PC ZIP: `200`, `application/zip`, `40035466` bytes.

## Proximo Ponto

Fabio revisar manualmente no Android/Windows/Web: Labs Dev visivel, Refugio/Batalha contidos, download APK sem Bearer token, splash estatica ao solicitar batalha e retorno de recompensa para o loop de base.
