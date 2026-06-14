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
- `Projetos/draxos-mobile/modes/boot/ui/mode_shell_overlay_host_contract.gd`
- `Projetos/draxos-mobile/modes/openworld/openworld_integrated_session_bridge.gd`
- `Projetos/draxos-mobile/modes/openworld/openworld_reward_summary.gd`
- `Projetos/draxos-mobile/tests/client/test_openworld_reward_summary.gd`
- `08_Coordenacao_Agentes/Kanban/Done/2026-06-14_codex_draxos-mobile_docs-client-hardening-pass-2.md`
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

## Resultado

- `design-pending.md` ficou com 22 entradas vivas (`ABERTO`, `CALIBRAR`, `ADIADO`); 60 `RESOLVIDO` foram preservadas em `docs/design-resolved-archive.md`.
- `documentation-index.md` passou a classificar pacotes publicados como historico quando apropriado e incluiu `docs/arena-pve-product-proof.md` como guardrail vivo.
- `test_boot_mobile_ui.gd` foi reduzido em 131 linhas; os testes puros de layer foram movidos para `test_overlay_layer_state.gd`.
- `mode_shell_overlay_controller.gd` centraliza chamadas privadas do host em `mode_shell_overlay_host_contract.gd`.
- `openworld_integrated_session_bridge.gd` removeu summary/status/perodo de recompensa para `openworld_reward_summary.gd` com testes focados.

## Commits

- `a3a4552a` `docs(draxos-mobile): start docs client hardening pass 2`
- `1acbb6f8` `docs(draxos-mobile): archive resolved design decisions`
- `0a4c3cd1` `refactor(draxos-mobile): isolate overlay shell contracts`
- `5386522a` `refactor(draxos-mobile): extract openworld reward summary helper`

## Validacao

- `git diff --check`: `PASS`
- `tools/check_doc_drift.ps1`: `PASS`
- `validate_foundation.ps1 -Profile DocsOnly -NoProjectWrites`: `PASS`
- `Godot --headless --path . -s res://tools/validate.gd`: `PASS` (`285/285`)
- `GUT client` standalone: `PASS` (`285/285`)
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: `PASS`

Observacao: uma primeira tentativa de GUT em paralelo com `validate.gd` falhou em 1 teste de navegacao por disputa de ambiente compartilhado; a repeticao standalone passou `285/285` e o `ClientQuick` final tambem passou.
