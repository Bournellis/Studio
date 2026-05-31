# Track 19 - Remote Deploy

- Data: `2026-05-31`
- Agente: Codex
- Branch: `codex/draxos-mobile/arena-consistency-pass`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-consistency-pass`
- Status: `ENTREGUE_PUBLICADO`

## Objetivo

Publicar remotamente o pacote Track 19 Arena Consistency Pass ja validado e
empacotado localmente, mantendo o fluxo seguro de release: upload Storage,
pacote Cloudflare Pages, deploy do preview, manifest e smokes remotos.

## Validacao Planejada

- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`
- `build_cloudflare_pages_package.ps1`
- `wrangler pages deploy`
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`
- smokes remotos read-only de manifest, artefatos e internal alpha

## Handoff

Track 19 Arena Consistency Pass foi publicado remotamente.

- Release root: `internal-alpha/v0-arena-consistency-pass-20260531-0865e43`
- Portal: `https://168dc669.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web: `https://168dc669.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-arena-consistency-pass-20260531-0865e43/downloads/draxos-mobile-alpha.apk`
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-arena-consistency-pass-20260531-0865e43/downloads/draxos-mobile-alpha.zip`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

Validacoes concluidas: export, package, upload Storage, Cloudflare Pages deploy,
DeployManifest e smokes remotos read-only de manifest, artefatos e Internal
Alpha.
