# DraxosMobile Handoff: Publish Latest Main URL

## Snapshot

- agente: `Codex`
- data local: `2026-06-03`
- released/generated UTC: `2026-06-04T02:03:20Z`
- branch: `codex/draxos-mobile/publish-latest-main-url`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--publish-latest-main-url`
- status: `LATEST_MAIN_URL_PUBLISHED_INTERNAL_ALPHA`
- status em `master`: historico preservado; superseded por `Bosque Mecanico
  Basico v2` (`internal-alpha/v0-bosque-v2-guidance-20260604-7c2d981`)

## Release

- release root:
  `internal-alpha/v0-latest-main-url-20260603-a056445`
- source `master` no inicio do worktree: `a056445`
- Portal oficial:
  `https://draxos-mobile-internal-alpha.pages.dev/`
- Web direto:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Cloudflare preview/evidence:
  `https://d63aa165.draxos-mobile-internal-alpha.pages.dev`
- Cloudflare production deployment id:
  `d63aa165-7468-4645-8290-7580297a1431`
- manifest remoto:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

## O Que Foi Publicado

- Ultimo `master` integrado, incluindo Openworld Sync Stability e DraxosMobile
  lag delay responsiveness.
- Android APK, PC ZIP e Web assets no Storage root versionado.
- Cloudflare Pages production branch `main`.
- Manifest remoto apontando para a URL production estavel.
- Supabase Edge Functions redeployed; Supabase DB confirmado como up to date.

## Validacao

- `ReleaseDryRun`: passou.
- `ServerQuick`: passou.
- `ClientQuick`: passou com 208/208 GUT tests e 3422 asserts.
- `release_manifest_smoke.ts`: passou.
- `release_artifacts_remote_smoke.ts`: passou com Cloudflare Access permitido.
- `internal_alpha_remote_smoke.ts` com release manifest: passou.
- `RemoteReadOnly` consolidado com preview Web: passou.
- Web launch smoke no preview `d63aa165`: `game_loaded`, release root e asset
  root corretos, sem runtime errors.

## Observacoes

- O dominio fixo production esta protegido por Cloudflare Access para GET
  anonimo; isso e esperado neste Internal Alpha.
- O APK permanece em `debug_fallback`; release signing continua adiado para
  distribuicao Android mais ampla.
- Uma assercao obsoleta em
  `server/tests/arena_loop_unlock_friction_test.ts` foi alinhada ao texto atual
  do presenter antes do `ServerQuick`.

## Proximo Passo

Historico preservado para auditoria de publicacao. O proximo passo vivo foi
substituido pelo playtest/revisao de Bosque Mecanico Basico v2 e pela decisao de
publicacao/hotfix da integracao `Openworld Collection Sync Local Fix` + `Main
Menu Refactor`.
