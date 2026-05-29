# DraxosMobile - Publish Entry Dev Labs Hotfix

- Data: `2026-05-28`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/foundation-responsive-guardrails`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-app-v0-audit`
- Status: `DONE`

## Resultado

Publicado novo Internal Alpha com Battle Lab e Progression Lab de volta ao menu inicial exportado. O build tambem preserva os hotfixes anteriores: Refugio como raiz pos-login, Labs Dev no Refugio, Entry/Refugio/Batalha contidos, splash estatico ao solicitar batalha e downloads publicos unlisted para APK/PC.

## Links

- Portal estavel: `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web estavel: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Preview verificado: `https://a1c7524d.draxos-mobile-internal-alpha.pages.dev`
- Android APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0/downloads/draxos-mobile-alpha.apk`
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0/downloads/draxos-mobile-alpha.zip`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

## Artefatos

| Artifact | Bytes | SHA256 |
|---|---:|---|
| Android APK | `31621141` | `75e2f4e142c8d1def559cded4633f2606f2934c8609608a455d107b5ab8279eb` |
| PC Windows ZIP | `40088244` | `3a4915fd826f2bf9f5516ea0e85f1718b1a09ab66ba8d3e27c858d750879cb9c` |
| Web index | `5442` | `9d61d47cefb84de260c4b4009c8c98cd9bf7648e4ed137d1b3d4a93043bc09b8` |

## Validacao Executada

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_exports.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\export_internal_alpha.ps1 -ProjectDir . -EnvFile D:\Estudio\Projetos\draxos-mobile\.env.internal-alpha.local -GodotExe D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe -AllowAndroidDebugFallback
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -EnvFile D:\Estudio\Projetos\draxos-mobile\.env.internal-alpha.local -Mode Upload -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_cloudflare_pages_package.ps1 -ProjectDir .
npx -y wrangler pages deploy .\build\internal-alpha\cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -EnvFile D:\Estudio\Projetos\draxos-mobile\.env.internal-alpha.local -Mode DeployManifest -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation
npx -y deno run --allow-net --allow-env --allow-read server/tests/release_manifest_smoke.ts
npx -y deno run --allow-net --allow-env --allow-read server/tests/release_artifacts_remote_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts
```

Downloads verificados por HEAD:

- APK: `200`, `application/vnd.android.package-archive`, `31621141` bytes.
- PC ZIP: `200`, `application/zip`, `40088244` bytes.

## Proximo Passo

Revisar manualmente Android/Windows/Web publicados: Labs Dev no menu inicial, Refugio/Batalha contidos, APK sem Bearer-token, splash estatico antes da batalha, loop pos-login claro e retorno de recompensa para a intencao de base.
