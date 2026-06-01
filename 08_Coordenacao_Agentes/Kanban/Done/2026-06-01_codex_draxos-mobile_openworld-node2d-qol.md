# Openworld Node2D QoL Foundation

- Data: 2026-06-01
- Agente: Codex
- Projeto: `Projetos/draxos-mobile`
- Branch: `codex/draxos-mobile/openworld-node2d-qol`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--openworld-node2d-qol`
- Status: publicado em Internal Alpha e validado remotamente

## Objetivo

Migrar o Bosque Openworld para uma fundacao runtime 2D com wrapper `Control` compativel com o shell atual, adicionando controles PC/web/mobile, joystick livre, colisao justa em objetos grandes, bordas bloqueantes, ordenacao visual por profundidade e preservacao integral do `OpenworldForestModel`.

## Escopo Fechado

- Permitido: QoL, runtime local, input, colisao, bordas, layering, testes, smokes e documentacao local do Openworld.
- Bloqueado no escopo de implementacao original: inimigos, combate, mapa novo,
  recompensas novas, economia nova, backend novo, endpoint novo, migration nova
  e mudanca no Reward Bridge. Publicacao de Internal Alpha foi autorizada
  separadamente pelo usuario em 2026-06-01.

## Base Docs Lidos

- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `canon/canon-brief.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/docs/minigames/openworld-decision-pack.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/openworld/openworld_forest_screen.gd`
- `Projetos/draxos-mobile/modes/openworld/openworld_virtual_joystick.gd`
- `Projetos/draxos-mobile/modes/openworld/openworld_forest_world_2d.gd`
- `Projetos/draxos-mobile/modes/openworld/openworld_player_controller.gd`
- `Projetos/draxos-mobile/modes/openworld/openworld_world_catalog.gd`
- `Projetos/draxos-mobile/modes/openworld/openworld_world_object.gd`
- `Projetos/draxos-mobile/tests/client/test_openworld_mode_dev.gd`
- `Projetos/draxos-mobile/tools/smoke_openworld_forest.gd`
- `Projetos/draxos-mobile/tools/smoke_modes_visual_layout.gd`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/docs/minigames/openworld-decision-pack.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Validacao Esperada

- `ClientQuick`
- Smoke Openworld
- Smoke visual layout
- Validacao documental se os docs forem alterados
- Validacao de mode definitions somente se descriptors/registry forem alterados

## Validacao Executada

- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: passou.
- `tools/smoke_openworld_forest.gd`: passou.
- `tools/smoke_modes_visual_layout.gd`: passou.
- Mode definitions nao foram alterados; validacao especifica de descriptors nao
  foi necessaria.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: passou.
- Android/PC/Web export: passou; Android `debug_fallback` aceito para playtest
  funcional.
- `publish_internal_alpha.ps1 -Mode Plan/Package/Upload -ReleaseRoot internal-alpha/v0-openworld-node2d-qol-20260601-5707167 -PublicDownloads`: passou.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl <versioned-web-root>`:
  passou.
- Cloudflare Pages deploy: passou.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-openworld-node2d-qol-20260601-5707167 -StaticSiteBaseUrl https://2cca25db.draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation`: passou.
- Supabase Edge Functions redeploy com CORS default para
  `https://2cca25db.draxos-mobile-internal-alpha.pages.dev`: passou.
- CORS GET check do preview atual contra `healthcheck`: passou.
- `DRAXOS_REMOTE_CORS_ORIGIN=https://2cca25db.draxos-mobile-internal-alpha.pages.dev`
  `tools/validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly`:
  passou.

## Publicacao

- release root:
  `internal-alpha/v0-openworld-node2d-qol-20260601-5707167`;
- Cloudflare preview:
  `https://2cca25db.draxos-mobile-internal-alpha.pages.dev`;
- Portal:
  `https://2cca25db.draxos-mobile-internal-alpha.pages.dev/portal/index.html`;
- Web:
  `https://2cca25db.draxos-mobile-internal-alpha.pages.dev/web/index.html`;
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-openworld-node2d-qol-20260601-5707167/downloads/draxos-mobile-alpha.apk`;
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-openworld-node2d-qol-20260601-5707167/downloads/draxos-mobile-alpha.zip`;
- manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`.

## Handoff Point

Runtime Node2D integrado, testes e smokes atualizados, publicacao remota
executada, snapshots atualizados e docs locais refletem que o pacote e
QoL/fundacao sem expansao de conteudo. Proximo passo: playtest humano do
preview publicado, especialmente movimento, colisao, bordas, y-depth e
interferencia de HUD/input.
