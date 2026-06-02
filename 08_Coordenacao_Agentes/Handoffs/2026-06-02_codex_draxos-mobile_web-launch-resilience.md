# Handoff - DraxosMobile Web Launch Resilience

Data: 2026-06-02
Agente: Codex
Projeto: DraxosMobile
Branch: `codex/draxos-mobile/web-launch-resilience`
Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--web-launch-resilience`
Base: `f7e0035`
Implementacao: `49dc5ea`
Status: publicado como Internal Alpha

## Resumo

Foi publicada uma correcao estrutural para o Web nao parecer preso em
"carregando para sempre". O contrato foi mantido: o manifest continua apontando
para o dominio fixo protegido por Cloudflare Access, e o preview hash liberado
serve como evidencia tecnica de que o Godot Web abre.

## Release

- Release root: `internal-alpha/v0-web-launch-resilience-20260602-49dc5ea`
- Production URL oficial: `https://draxos-mobile-internal-alpha.pages.dev`
- Web oficial: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Portal oficial: `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Preview tecnico: `https://9ba71c4e.draxos-mobile-internal-alpha.pages.dev`
- Web preview tecnico: `https://9ba71c4e.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Remote manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Screenshot pos-load: `D:\Estudio-worktrees\draxos-mobile--codex--web-launch-resilience\Projetos\draxos-mobile\build\diagnostics\web-launch-remote-20260602-042353\web-launch-remote.png`

## Entregue

- Shell Web gerado por `tools/build_cloudflare_pages_package.ps1` embute
  `DRAXOS_RELEASE_ROOT`, `DRAXOS_WEB_ASSET_ROOT` e
  `window.DRAXOS_WEB_RELEASE`.
- `/web/index.js`, splash e icones locais recebem cache-bust por release root.
- Watchdog de 20s mostra troubleshooting legivel quando a splash permanece
  visivel, sem interromper `engine.startGame`.
- Rejeicao de `engine.startGame` agora aparece com erro legivel na pagina e
  detalhes no console.
- Mudanca de release root limpa seletivamente caches/service workers antigos
  relacionados a Draxos/Godot/Internal Alpha, preservando sessao Supabase e
  localStorage do jogo.
- Novo `tools/smoke_web_launch_remote.ps1` valida abertura real via
  Chrome/Edge CDP, captura screenshot/logs em `build/diagnostics/`, espera
  `#status` sumir e falha se o Web ficar preso na splash, se assets criticos
  falharem ou se a release root esperada nao aparecer.

## Validacao

- `git diff --check`: passou.
- `tools/smoke_responsive_layout.gd`: passou.
- GUT client: passou, `174/174`, `3182` asserts.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: passou.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: passou.
- Export Android/PC/Web: passou; Android usa `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan`: passou.
- `publish_internal_alpha.ps1 -Mode Package`: passou.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`: passou.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl <versioned-web-root>`: passou.
- Cloudflare Pages deploy para `main`: passou, deployment
  `https://9ba71c4e.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -ConfirmRemoteMutation`: passou.
- `tools/smoke_web_launch_remote.ps1` no preview com `-ExpectedReleaseRoot`:
  passou, outcome `game_loaded`, splash saiu em `6715` ms.
- Preview HTML contem a release root esperada e `/web/index.js` cache-busted.
- GET anonimo no production fixo retorna Cloudflare Access, esperado.
- `index.pck` remoto: `4611048` bytes, igual ao local.
- `index.wasm` remoto: `37695054` bytes, igual ao local.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly -AllowCloudflareAccess`: passou.

## Observacoes

- Nenhum gameplay, backend, schema, migration, economia, tuning, conteudo,
  fluxo de login ou Reward Bridge foi alterado.
- `.env.internal-alpha.local` foi copiado para o worktree apenas para operacao
  local e segue ignorado.
- O worktree precisou de `supabase link --project-ref armxgipvnbbshzqawklw`
  antes do Upload.
- O primeiro responsive smoke no worktree novo encontrou cache `.godot`
  ausente; `Godot --headless --editor --quit --path .` regenerou o cache com
  warnings conhecidos de import dos assets GUT, e a validacao passou depois.

## Proximo Passo Humano

Abrir `https://draxos-mobile-internal-alpha.pages.dev/web/index.html` em uma
sessao Cloudflare Access autenticada e validar lancamento Web em navegador com
cache frio e cache quente. Usar o preview hash apenas como evidencia tecnica
liberada, nao como URL oficial do manifest.
