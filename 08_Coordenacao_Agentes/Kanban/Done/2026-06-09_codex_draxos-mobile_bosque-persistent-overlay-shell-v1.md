# Bosque Persistent Overlay Shell v1

- Data: `2026-06-09`
- Agente: Codex
- Branch: `codex/draxos-mobile/bosque-persistent-overlay-shell-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-persistent-overlay-shell-v1`
- Projeto: `Projetos/draxos-mobile`
- Base: `main` em `9f67933`

## Objetivo

Implementar `Bosque Persistent Overlay Shell v1`: manter o Bosque instanciado e visivel enquanto menus e Arena abrem por cima em um overlay responsivo, com input do Bosque pausado, stack unico de navegacao interna e publicacao de novo Internal Alpha Web/APK.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/ui/mode_shell_launcher.gd`
- `Projetos/draxos-mobile/modes/boot/boot_runtime_*`
- `Projetos/draxos-mobile/modes/boot/flows/arena_lifecycle_flow.gd`
- `Projetos/draxos-mobile/modes/boot/flows/surface_action_flow.gd`
- `Projetos/draxos-mobile/modes/openworld/openworld_forest_screen.gd`
- `Projetos/draxos-mobile/tests/client/test_openworld_mode_dev.gd`
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/tests/client/test_session_shell.gd`
- Docs vivos e release/status se a etapa for publicada.

## Base Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/hardening-program.md`

## Validacao Prevista

- `git diff --check`
- `validate_foundation.ps1 -Profile DocsOnly -NoProjectWrites`
- `validate_foundation.ps1 -Profile ClientQuick`
- Godot client GUT com foco em `test_openworld_*`, `test_boot_mobile_ui.gd`, `test_session_shell.gd`
- `smoke_openworld_forest.gd`
- `smoke_modes_visual_layout.gd`
- `smoke_responsive_layout.gd` se a camada responsiva for tocada
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`
- `check_release_safety.ps1`
- `check_android_release_keystore.ps1 -Mode InternalAlpha`

## Ponto De Handoff

Entregar commits e handoff com:

- comportamento implementado;
- validacoes executadas;
- release root e hashes se publicado;
- riscos residuais;
- lista de qualquer trecho da Arena que precisou permanecer fora do overlay, se houver blocker.

## Resultado Final

`Bosque Persistent Overlay Shell v1` foi implementado e publicado como novo pacote Internal Alpha. O shell do Bosque permanece instanciado e visivel atras de Shop/Base/Social/Profile e do fluxo completo da Arena. Enquanto o overlay esta aberto, input/movimento/coleta/launcher do Bosque ficam pausados; `Voltar`, fechar, `ACTION_RETURN_REFUGE` e `open_mode_shell:openworld` devolvem foco ao mesmo node do Bosque sem rebootstrap.

Nao houve mudanca de Supabase schema, RLS, economia, tuning, conteudo, recompensas ou contratos HTTP. A funcao `release`, manifest, artefatos Web/APK/PC e docs vivos foram atualizados para o novo pacote.

## Arquivos/Areas Alterados

- Shell/rotas/runtime: `modes/boot/boot_runtime*.gd`, `modes/boot/ui/mode_shell_overlay_controller.gd`, `modes/boot/ui/mode_shell_launcher.gd`, `modes/boot/flows/surface_action_flow.gd`.
- Bosque runtime: `modes/openworld/openworld_forest_screen.gd`.
- Testes cliente/release: `tests/client/test_boot_mobile_ui.gd`, `tests/client/test_openworld_mode_dev.gd`, `tests/client/test_project_info.gd`, `server/tests/*release*`.
- Release/export/manifest: `core/project_info.gd`, `export_presets.cfg`, `tools/export_internal_alpha.ps1`, `tools/publish_internal_alpha.ps1`, `server/functions/release/index.ts`, `supabase/functions/release/index.ts`, `portal/internal-alpha/manifest.example.json`.
- Docs/status: `implementation/current-status.md`, `docs/documentation-index.md`, `docs/agent-operating-manual.md`, `docs/hardening-program.md`, `docs/contracts/update-manifest.md`, `docs/contracts/api-endpoints.md`, `docs/minigames/openworld.md`, `docs/minigames/autobattler.md`, `docs/product-brief.md`, `docs/product-vision.md`, `docs/design-pending.md`, `docs/multi-agent-workflow.md`, `docs/pve-arena-v1.md`, `README.md`, `AGENTS.md`, `../../AGENTS.md`, `../../Projetos/README.md`, `../../08_Coordenacao_Agentes/Prioridades_Estudio.md`, `../../08_Coordenacao_Agentes/Estado_Atual.md`.

## Publicacao

- Status publicado: `BOSQUE_PERSISTENT_OVERLAY_SHELL_V1_PUBLISHED_INTERNAL_ALPHA`.
- Version: `0.0.17-alpha.0`.
- Version code: `17`.
- Minimum supported version code: `13`.
- Release root: `internal-alpha/v0-bosque-persistent-overlay-shell-v1-20260609-d05081c`.
- Preview evidence: `https://a53c1d27.draxos-mobile-internal-alpha.pages.dev`.
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`.
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`.
- Android APK SHA256: `94bc88662174a5f9568672dcba9fc0a3686cf02b36ed4f8ab36f9f321b9a9f48`.
- PC Windows ZIP SHA256: `e14202f010a1d024e360322b5630f471e56254608fbe89b3e91e2d96a98039ca`.
- Web Index SHA256: `bca76e8043cac9952e338bf18694d198a9533a5b5ddb72f5f12d63a961e7476c`.

## Validacoes Executadas

- `validate_foundation.ps1 -Profile ClientQuick`: PASS, 267 testes / 3974 asserts, incluindo GUT client e smokes Openworld/layout.
- `validate_foundation.ps1 -Profile ModePlatform -NoProjectWrites`: PASS, incluindo server mode tests e smokes `smoke_bosque_entry`, `smoke_openworld_forest`, `smoke_modes_visual_layout`, `smoke_modes_ops_panel`.
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: PASS.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Package`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`: PASS.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- `wrangler pages deploy`: PASS, preview publicado em `https://a53c1d27.draxos-mobile-internal-alpha.pages.dev`.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot ... -RemoteWebUrl ... -AllowCloudflareAccess -NoProjectWrites`: PASS; Web launch smoke carregou em `4491 ms`, release root bateu e nao houve runtime errors.

## Riscos Residuais

- APK usa `debug_fallback`, aceito para Internal Alpha fechado; assinatura release continua adiada para distribuicao Android mais ampla.
- Stable Portal/Web estao protegidos por Cloudflare Access; o smoke publico foi feito pela URL preview de Pages.
- Playtest humano do pacote `Bosque Persistent Overlay Shell v1` ainda e o proximo passo operacional antes de abrir qualquer novo pacote.
- Nenhum trecho da Arena precisou ficar fora do overlay; o replay usa fullscreen relativo ao overlay.
