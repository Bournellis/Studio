# DraxosMobile - Web Launch Resilience

Data: 2026-06-02
Agente: Codex
Projeto: DraxosMobile
Branch: codex/draxos-mobile/web-launch-resilience
Worktree: D:\Estudio-worktrees\draxos-mobile--codex--web-launch-resilience
Base: f7e0035
Status: Done - publicado e validado

## Objetivo

Implementar uma correcao estrutural para o Web nao parecer "carregando para sempre", mantendo o contrato atual de dominio fixo protegido por Cloudflare Access e preview hash liberado para validacao tecnica.

## Escopo Permitido

- Shell Web gerado por `tools/build_cloudflare_pages_package.ps1`.
- Smoke remoto real para validar abertura do Godot Web via Chrome/CDP.
- Documentacao operacional de release, validacao e handoff.
- Publicacao Internal Alpha com novo release root versionado.

## Fora de Escopo

- Gameplay, balanceamento, economia, conteudo ou fluxo de login.
- Backend, Supabase schema, migrations, functions ou secrets.
- Mudanca do contrato de Cloudflare Access no dominio fixo.
- Mudanca do `web.url` oficial do manifest para preview hash.

## Documentos Base Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `canon/canon-brief.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `Projetos/draxos-mobile/docs/internal-alpha-static-hosting.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Entrega Tecnica

- `tools/build_cloudflare_pages_package.ps1` agora embute `DRAXOS_RELEASE_ROOT`, `DRAXOS_WEB_ASSET_ROOT` e `window.DRAXOS_WEB_RELEASE`.
- O shell Web adiciona cache-bust por release root em `index.js`, splash e icones locais.
- O shell Web limpa seletivamente caches/service workers antigos quando o release root muda, sem apagar sessao Supabase/localStorage do jogo.
- O shell Web mostra uma mensagem legivel se a splash continuar visivel depois de 20 segundos e tambem exibe erro legivel quando `engine.startGame` rejeitar.
- `tools/smoke_web_launch_remote.ps1` valida o preview hash via Chrome/Edge CDP, captura screenshot/logs e falha se o jogo ficar preso no overlay, se assets criticos falharem ou se a release root esperada nao aparecer.

## Validacao Planejada

1. `git diff --check`
2. Godot headless responsive smoke.
3. GUT client tests.
4. `validate_foundation.ps1 -Profile ClientQuick`
5. `validate_foundation.ps1 -Profile ReleaseDryRun`
6. Publicar Internal Alpha nova com release root `internal-alpha/v0-web-launch-resilience-20260602-<shortsha>`.
7. Rodar `tools/smoke_web_launch_remote.ps1` no preview hash com `-ExpectedReleaseRoot`.
8. Rodar `validate_foundation.ps1 -Profile RemoteReadOnly -AllowCloudflareAccess`.

## Resultado

- Commit tecnico: `49dc5ea` (`Harden Web launch diagnostics`).
- Release root publicado: `internal-alpha/v0-web-launch-resilience-20260602-49dc5ea`.
- Production URL oficial preservada no manifest: `https://draxos-mobile-internal-alpha.pages.dev`.
- Preview hash usado como evidencia tecnica: `https://9ba71c4e.draxos-mobile-internal-alpha.pages.dev`.
- Web launch smoke no preview: `game_loaded`, splash saiu em `6715` ms.
- Screenshot pos-load: `D:\Estudio-worktrees\draxos-mobile--codex--web-launch-resilience\Projetos\draxos-mobile\build\diagnostics\web-launch-remote-20260602-042353\web-launch-remote.png`.
- `index.pck` (`4611048`) e `index.wasm` (`37695054`) bateram com `Content-Length` remoto.
- GET anonimo no production fixo retorna Cloudflare Access, esperado pelo contrato atual.
- Validacao humana: usuario confirmou em 2026-06-02 que o Web esta funcionando.

## Validacao Executada

- `git diff --check`: passou.
- `tools/smoke_responsive_layout.gd`: passou.
- GUT client: passou, `174/174`, `3182` asserts.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: passou.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: passou.
- Export Android/PC/Web: passou; Android em `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan`: passou.
- `publish_internal_alpha.ps1 -Mode Package`: passou.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`: passou apos `supabase link --project-ref armxgipvnbbshzqawklw` no worktree.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl <versioned-web-root>`: passou.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: passou, deployment `https://9ba71c4e.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -ConfirmRemoteMutation`: passou.
- `tools/smoke_web_launch_remote.ps1` no preview hash com `-ExpectedReleaseRoot`: passou.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly -AllowCloudflareAccess`: passou.

## Handoff

Check humano concluido em 2026-06-02: usuario confirmou que o Web esta funcionando. O preview hash fica apenas como evidencia tecnica liberada. Nenhuma funcao de jogo, backend, schema, migration, economia, tuning ou conteudo foi alterada.
