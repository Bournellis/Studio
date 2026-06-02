# DraxosMobile Handoff - Openworld QoL Regression Fix

## Metadata

- data: `2026-06-01`
- agente: `Codex`
- projeto: `draxos-mobile`
- branch: `codex/draxos-mobile/openworld-node2d-qol`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--openworld-node2d-qol`
- mode_scope: `openworld`
- lane: `mode-scaffolds` + `client-shell` + `validation-release`

## Objetivo

Corrigir regressao do Openworld publicado: WASD no Web, joystick livre real,
colisao de bau/arvores/rochas, validacao mais forte e runbook do hotfix CORS
Web/Supabase confirmado pelo teste humano.

## Entregue Localmente

- `docs/release-ops-checklist.md` documenta sintoma, causa raiz, solucao e
  validacao do CORS dynamic origin echo.
- `OpenworldForestScreen` agora usa foco, `_input(event)` global e fallback
  manual por `keycode`/`physical_keycode` para WASD/setas.
- Joystick livre fica oculto em repouso e nasce no ponto de clique/toque em
  area livre.
- HUD, botoes e sheet nao ativam joystick.
- Obstaculos bloqueantes passaram para `OpenworldObjectBlockers`, um
  `StaticBody2D` fisico dedicado, separado dos nodes visuais y-sorted.
- Catalogo do Bosque declara `collision_shape`, `collision_size`,
  `collision_radius` e `collision_offset` para bau, arvores e rochas.
- GUT e smokes exercitam eventos reais de tecla/mouse e colisao por varios
  lados, reduzindo falso verde.

## Commits

- `b97fdc6` - `Document web CORS hotfix runbook`
- `baabcb8` - `Fix Openworld controls collisions and validation`
- `ba6f129` - `Record Openworld regression fix handoff`
- final publication/status commit pending in this handoff update.

## Validacao Local

- `git diff --check`: PASS
- `tools/smoke_openworld_forest.gd`: PASS
- `tools/smoke_modes_visual_layout.gd`: PASS
- `tools/validate.gd`: PASS
- GUT client: PASS, `174` tests / `3152` asserts
- `validate_foundation.ps1 -Profile ClientQuick`: PASS
- `validate_foundation.ps1 -Profile ModePlatform`: PASS
- `validate_foundation.ps1 -Profile ReleaseDryRun`: PASS after Doing cleanup
- `validate_foundation.ps1 -Profile ServerQuick`: PASS after CORS helper and
  `modes` entrypoint alignment
- `validate_foundation.ps1 -Profile RemoteReadOnly`: PASS against
  `https://95f403c5.draxos-mobile-internal-alpha.pages.dev`

## Publicacao

- release root:
  `internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129`
- Cloudflare preview:
  `https://95f403c5.draxos-mobile-internal-alpha.pages.dev`
- Portal:
  `https://95f403c5.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web:
  `https://95f403c5.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129/downloads/draxos-mobile-alpha.apk`
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129/downloads/draxos-mobile-alpha.zip`
- Remote manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Nota operacional: `publish_internal_alpha.ps1 -Mode Upload` travou no
  `storage rm` opcional de um arquivo Web depois de subir a maior parte do
  pacote. O root era novo, entao os tres objetos Web faltantes foram enviados
  por `supabase storage cp` direto e todos os 25 arquivos passaram HEAD publico
  por tamanho.
- CORS: Edge Functions redeployadas com preview atual e regra restrita para
  hash previews do projeto Pages; `RemoteReadOnly` passou para o preview novo.
- Web headless: Chrome carregou `/web/index.html`, encontrou canvas 1280x720 e
  nao registrou `pageerror` ou logs suspeitos de CORS/Supabase.

## Proximo Handoff

Pacote publicado. Proximo passo e playtest humano do Bosque publicado contra:
WASD, mouse drag livre, bau, arvores, rochas, bordas, coleta/deposito e
layering, porque a automacao headless carregou o app shell mas nao concluiu
login/guest route ate o Openworld.
