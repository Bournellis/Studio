# DraxosMobile Hardening Doing: client-shell/mode-scaffolds - main menu refactor

## Metadata

- data: `2026-06-04`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `client-shell`
- mode_scope: `multi-mode`
- branch: `codex/draxos-mobile/main-menu-refactor`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--main-menu-refactor`

## Objetivo

Refazer a navegacao principal do Refugio para remover atalhos de modos inexistentes, coleta geral e energia direta, mover Preparacao para Arena PVE e manter Bosque como entrada direta player-facing.

## Latest Context

- latest Arena loop package: `Track 21 - Arena Loop Unlock And Friction Pass`
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
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/docs/foundation-app-v0-audit.md`
- `Projetos/draxos-mobile/docs/foundation-responsive-layout-contract.md`
- `Projetos/draxos-mobile/docs/first-session-clarity-v1.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Escopo

- Incluir:
  - remover `Preparacao`, `Modos`, `Coletar` e `Energia` do menu principal do Refugio;
  - adicionar `Bosque` como botao direto para `open_mode_shell:openworld`;
  - remover coleta geral do cliente player-facing e manter backend legado fora deste pacote;
  - manter compra de energia somente dentro da Loja e renomear recompensa diaria para evitar linguagem de coleta;
  - mover Preparacao para dentro da Arena PVE abaixo de `Iniciar Arena PVE`;
  - remover `mode_hub` como rota/tela de jogador, mantendo registry tecnico e `modes_ops`;
  - remover atalhos dev `Openworld` / `Openworld Bosque`;
  - atualizar testes, smokes e docs vivos afetados.
- Fora do escopo:
  - backend/RPC legado de `collect_base`;
  - publicacao/remota;
  - tuning, economia ampla, PVP, social expandido, novos modos ou conteudo novo.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/surfaces/hub_surface_refuge_scene_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/hub_surface_refuge_popup_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/base_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/arena_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/hub_surface_preparation_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/shop_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/flows/surface_action_flow.gd`
- `Projetos/draxos-mobile/modes/boot/boot_runtime_action_dispatcher.gd`
- `Projetos/draxos-mobile/modes/boot/boot_runtime_navigation_controller.gd`
- `Projetos/draxos-mobile/modes/boot/boot_runtime_labs_controller.gd`
- `Projetos/draxos-mobile/modes/boot/boot_runtime_state.gd`
- `Projetos/draxos-mobile/modes/boot/ui/app_shell_route_contract.gd`
- `Projetos/draxos-mobile/core/project_info.gd`
- `Projetos/draxos-mobile/tests/client/`
- `Projetos/draxos-mobile/tools/`
- `Projetos/draxos-mobile/docs/minigames/`
- `Projetos/draxos-mobile/docs/contracts/`
- `Projetos/draxos-mobile/modes/boot/surfaces/README.md`

## Validation Plan

- `git diff --check`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --import`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_bosque_entry.gd`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ModePlatform`

## Handoff Point

Handoff quando o menu principal, Preparacao dentro da Arena, remocao do `mode_hub` player-facing, testes/smokes/docs e validacao local estiverem registrados; publicacao remota fica fora deste pacote ate aprovacao explicita.

## Resultado - 2026-06-04

- Menu principal do Refugio reduzido para `Arena PVE`, `Bosque`, `Refugio`, `Social` e `Loja`.
- `Bosque` abre diretamente `open_mode_shell:openworld`; `Openworld` / `Openworld Bosque` foram removidos dos atalhos dev player-facing.
- `Preparacao` foi removida do menu principal e do popup do Refugio; agora fica dentro de `Arena PVE`, abaixo de `Iniciar Arena PVE`, e vira painel somente de comportamento quando a tentativa ativa ja travou o loadout.
- `Modos`/`mode_hub` foram removidos como rota, presenter, smoke e atalho player-facing; `modes_ops` e registry tecnico permanecem.
- `Energia` saiu do menu principal; compra de energia fica dentro da Loja.
- `Coletar`/collect-all saiu do menu principal e dos fluxos cliente player-facing; coleta individual por recurso/modo permanece fora deste pacote.
- Linguagem de coleta geral no Refugio/Base/Batalha foi trocada para producao/progresso quando necessario.
- Docs vivos, smokes e testes foram alinhados ao novo contrato.

## Validacao Executada

- `git diff --check`: PASS.
- Godot headless import: PASS com avisos conhecidos do plugin GUT sobre assets/fontes.
- `Godot --headless --path . -s res://tools/validate.gd`: PASS, 214/214 testes.
- `Godot --headless --path . -s res://tools/smoke_bosque_entry.gd`: PASS.
- `Godot --headless --path . -s res://tools/smoke_responsive_layout.gd`: PASS.
- `Godot --headless --path . -s res://tools/smoke_mobile_presentation.gd`: PASS.
- `./tools/validate_foundation.ps1 -Profile DocsOnly`: PASS.
- `./tools/validate_foundation.ps1 -Profile ClientQuick`: PASS.
- `./tools/validate_foundation.ps1 -Profile ModePlatform`: PASS, 38/38 Deno mode tests and all mode smokes.
