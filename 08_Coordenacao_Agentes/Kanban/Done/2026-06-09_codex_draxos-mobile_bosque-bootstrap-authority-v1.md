# DraxosMobile - Bosque Bootstrap Authority v1

- Data: `2026-06-09`
- Agente: `Codex`
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/bosque-bootstrap-authority-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-bootstrap-authority-v1`
- Base: `main` em `16ae233`
- Status: `DONE`

## Objetivo

Corrigir o bootstrap visual do Openworld/Bosque para impedir que a tela exiba um frame de Bosque `full spawn` antes de aplicar o estado canonico remoto ou cache canonico valido.

## Entrega

- `OpenWorldForestScreen.configure_integrated_alpha()` agora entra em bootstrap-loading antes do primeiro frame jogavel.
- O viewport jogavel integrado fica oculto enquanto `/modes/state` remoto ou cache canonico valido ainda nao chegou.
- A regressao `test_integrated_bootstrap_hides_world_until_remote_state_arrives` cobre o atraso do estado remoto e impede que um mundo full-spawn seja exposto antes do sync.
- Versao Internal Alpha atualizada para `0.0.15-alpha.0` / version code `15`.
- Scripts de export/publish e smokes remotos alinhados com version code `15`.

## Publicacao

- Release root final: `internal-alpha/v0-bosque-bootstrap-authority-v1-20260609-ba99e70`
- Commit de release: `ba99e70`
- Preview Cloudflare Pages: `https://0123894f.draxos-mobile-internal-alpha.pages.dev`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Android APK: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/download?artifact=android`
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/download?artifact=pc_windows`

## Artefatos

- Android APK SHA256: `f7406c57b1a8ef6af6496395eba25c7cde0358781c5c47e845daa457405b84f4`
- PC Windows ZIP SHA256: `b45826aaa8fbd70959795f3758c43d1b7e6f4590378d63f47a071958ed5d588b`
- Web Index SHA256: `9f410baff95d901a65f46d05eae316f7bdc203b0fcc200e8bacdf750e42dde56`
- Android export mode: `debug_fallback`

## Validacao

- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- GUT client: PASS, 252 testes / 3849 asserts.
- `validate_foundation.ps1 -Profile ClientQuick`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun`: PASS apos mover o card para Done.
- `publish_internal_alpha.ps1 -Mode Plan`: PASS.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Package`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- `wrangler pages deploy ... --branch main`: PASS.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`: PASS.
- `release_manifest_smoke.ts`: PASS.
- `release_artifacts_remote_smoke.ts`: PASS.
- `internal_alpha_remote_smoke.ts`: PASS.
- `smoke_web_launch_remote.ps1` no preview `0123894f`: PASS, `outcome = game_loaded`, release root confirmado, sem runtime errors.

## Observacoes

- Stable Portal/Web ficam protegidos por Cloudflare Access; o preview hash validou o pacote Web publicado.
- APK usa `debug_fallback`, aceito para playtest funcional de Internal Alpha enquanto release signing fica adiado.
- O publish anterior no root `internal-alpha/v0-bosque-bootstrap-authority-v1-20260609-13ecf48` foi superseded antes do manifest final; o root canonico e `ba99e70`.
