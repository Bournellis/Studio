# DraxosMobile Hardening Doing: coord-docs + client-shell - docs client hardening pass 2

## Metadata

- data: `2026-06-14`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `coord-docs` + `client-shell`
- mode_scope: `multi-mode`
- branch: `codex/draxos-mobile/docs-client-hardening-pass-2`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--docs-client-hardening-pass-2`

## Objetivo

Consolidar higiene documental e segundo passe de hardening tecnico sem abrir produto novo, tuning, PVP, economia, visual final, publicacao ou mutacao remota.

## Latest Context

- Current published package: `Bosque Overlay Layer And Readiness Authority v1`, publicado em Internal Alpha; lineage em `Projetos/draxos-mobile/docs/release-history.md`.
- Current local implemented stage: hardening integrado localmente em `2026-06-14`, sem publicacao remota.
- Preserved Arena context: `Arena PVE remains the first approved core; see docs below`.
- Open decision: `DMOB-D082` / `ARENA_CORE_NEEDS_UX_FIX` + `ARENA_CORE_NOT_PROVEN`.
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/design-pending.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/hardening-program.md`

## Escopo

- Incluir:
  - higiene do indice documental e do registro de pendencias vivas;
  - arquivamento de pendencias resolvidas sem perder rastreabilidade;
  - reducao de testes client-shell concentrados em `test_boot_mobile_ui.gd`;
  - segundo passe estreito em contratos implicitos de overlay shell e bridge Openworld quando seguro;
  - atualizacao de handoff/status somente se o estado observavel mudar.
- Fora do escopo:
  - worktrees de outros agentes;
  - JogoDaCopa e qualquer trabalho sujo fora do DraxosMobile;
  - remote mutation/publicacao;
  - tuning numerico, economia, PVP, conteudo novo, visual final ou expansao Openworld.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/design-pending.md`
- `Projetos/draxos-mobile/docs/design-resolved-archive.md`
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/tests/client/test_overlay_layer_state.gd`
- `Projetos/draxos-mobile/modes/boot/ui/mode_shell_overlay_controller.gd`
- `Projetos/draxos-mobile/modes/boot/ui/mode_shell_overlay_layer_state.gd`
- `Projetos/draxos-mobile/modes/boot/openworld_integrated_session_bridge.gd`
- `Projetos/draxos-mobile/modes/boot/openworld_persistence_state.gd`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-14_codex_draxos-mobile_docs-client-hardening-pass-2.md`
- `08_Coordenacao_Agentes/Handoffs/2026-06-14_codex_draxos-mobile_docs-client-hardening-pass-2.md`

## Validation Plan

- `git diff --check`
- `powershell -NoProfile -ExecutionPolicy Bypass -File D:\Estudio\tools\check_doc_drift.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile DocsOnly -NoProjectWrites`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick -NoProjectWrites`

## Remote Mutation / Publication

- remote mutation/publication run: `no`
- preserved boundary: `no deploy, no Supabase/Cloudflare mutation, no export/publication`

## Handoff Point

Fechar com commits separados por coordenacao inicial, docs, client hardening e coordenacao final; depois merge local no `main`. Fabio faz o push pelo GitHub Desktop.
