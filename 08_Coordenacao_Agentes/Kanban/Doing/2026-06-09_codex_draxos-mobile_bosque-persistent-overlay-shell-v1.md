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
