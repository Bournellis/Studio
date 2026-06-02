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

## Validacao Local

- `git diff --check`: PASS
- `tools/smoke_openworld_forest.gd`: PASS
- `tools/smoke_modes_visual_layout.gd`: PASS
- `tools/validate.gd`: PASS
- GUT client: PASS, `174` tests / `3152` asserts
- `validate_foundation.ps1 -Profile ClientQuick`: PASS
- `validate_foundation.ps1 -Profile ModePlatform`: PASS
- `validate_foundation.ps1 -Profile ReleaseDryRun`: PASS after Doing cleanup

## Proximo Handoff

Publicar novo pacote Internal Alpha, atualizar `implementation/current-status.md`
com release root/preview/validacoes e validar Web preview manualmente contra:
WASD, mouse drag livre, bau, arvores, rochas, bordas e coleta.
