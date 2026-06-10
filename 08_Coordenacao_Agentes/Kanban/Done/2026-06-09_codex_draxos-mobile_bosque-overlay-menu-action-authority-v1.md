# Bosque Overlay Menu Action Authority v1

- Data: 2026-06-09
- Agente: Codex
- Branch: `codex/draxos-mobile/bosque-overlay-menu-action-authority-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-overlay-menu-action-authority-v1`
- Base: `main` em `002a851` (`Merge Bosque overlay interaction authority v1`)

## Objetivo

Corrigir a proxima etapa do overlay do Bosque para que os menus sejam superficies plenamente interativas: `Voltar`, Esc/back e botoes internos de Account/Base/Shop/Social/Arena devem funcionar no overlay sem recriar o Bosque.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/boot_runtime_surface_api.gd`
- `Projetos/draxos-mobile/modes/boot/boot_runtime_action_dispatcher.gd`
- `Projetos/draxos-mobile/modes/boot/boot_runtime_navigation_controller.gd`
- `Projetos/draxos-mobile/modes/boot/ui/mode_shell_overlay_controller.gd`
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/tools/smoke_web_overlay_controls.ps1` ou novo smoke dedicado para acoes internas
- Metadados de versao/release e docs/status apos publicacao real

## Validacao Prevista

- Reproducao do pacote `0.0.19-alpha.0` com cache disabled e registro de release state.
- GUT/client com input real por coordenadas para botoes internos.
- Smoke Web local por coordenadas reais para CTAs internos.
- `git diff --check`
- `validate_foundation.ps1 -Profile DocsOnly -NoProjectWrites`
- `validate_foundation.ps1 -Profile ClientQuick`
- Smokes `smoke_openworld_forest.gd`, `smoke_modes_visual_layout.gd`, `smoke_responsive_layout.gd`
- `ReleaseDryRun`, `check_release_safety.ps1`, `check_android_release_keystore.ps1 -Mode InternalAlpha`
- Publicacao Internal Alpha `0.0.20-alpha.0` somente depois do smoke interativo local passar.

## Ponto De Handoff

Entregar commits separados para runtime, smoke, publicacao e handoff, com release root, hashes, validacoes e riscos residuais registrados.

## Fechamento

- Status: concluido e publicado como Internal Alpha.
- Pacote: `Bosque Overlay Menu Action Authority v1`.
- Release root: `internal-alpha/v0-bosque-overlay-menu-action-authority-v1-20260609-aa9402d`.
- Preview validado: `https://5f04e6ae.draxos-mobile-internal-alpha.pages.dev`.
- Versao: `0.0.20-alpha.0`; version code `20`; minimum supported version code `13`.
- APK SHA256: `1f3aa89eebdf6296dca222f3d0f128feb532dd26a315245d5cbc4dc9c39f0da2`.
- PC ZIP SHA256: `024d402d8355bea0d92b7b8b77de7c7a30cdda16724064fe92872cc35c2a9920`.
- Web Index SHA256: `6f668a968a7f18d5a2b55ed753a7f61b767875f25c64a8b0d10a62cd5beb9596`.
- Cobertura: Account `Checar update`, Base `Sincronizar Refugio`, Shop `Atualizar loja`, Social `Atualizar social`, Arena `Voltar ao Refugio`, alem de `Fechar`, `Voltar` e Esc.
- URL oficial anonima: bloqueada por Cloudflare Access; validacao automatizada usou preview hash publico e release root injetado.
