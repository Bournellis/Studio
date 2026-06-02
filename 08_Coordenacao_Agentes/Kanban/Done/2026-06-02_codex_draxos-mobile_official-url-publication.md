# DraxosMobile Done: official URL publication alignment

Data: 2026-06-02
Agente: Codex
Branch: `codex/draxos-mobile/official-url-publication`
Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--official-url-publication`

## Resultado

O pacote integrado App/Arena/Bosque ja estava no deployment Cloudflare Pages de producao `8f2829c0` (`Branch=main`, `Source=99304ed`), mas o contrato de manifest/docs ainda tratava `/portal/index.html` como `portal_url`.

Foi publicado um hotfix de manifest/Edge Function para alinhar a URL oficial:

- Portal oficial / `portal_url`: `https://draxos-mobile-internal-alpha.pages.dev/`
- Web direto: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Deployment evidence: `https://8f2829c0.draxos-mobile-internal-alpha.pages.dev`
- Release root preservado: `internal-alpha/v0-integrated-app-arena-bosque-20260602-99304ed`
- Manifest remoto `released_at`: `2026-06-02T20:53:32Z`

## Validacao

- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`: PASS.
- Remote manifest GET: PASS, `portal_url` aponta para a raiz oficial.
- `wrangler pages deployment list`: PASS, ultimo deployment segue Production/main/source `99304ed`.
- Preview hash `/`: PASS, abre o Portal.
- Preview hash `/portal/index.html`: PASS, redireciona para `/`.
- Preview hash `/web/index.html`: PASS, redireciona para `/web`.
- Production root anonimo: retorna Cloudflare Access, esperado.
- `release_manifest_smoke.ts`: PASS.
- `release_artifacts_remote_smoke.ts` com `DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS=1`: PASS.

## Observacao

Se o browser autenticado ainda parecer antigo na URL oficial, o problema restante provavel e cache/sessao do navegador ou o usuario estar vendo a tela de Cloudflare Access antes de completar login. A publicacao e o manifest remoto agora apontam para a raiz oficial.
