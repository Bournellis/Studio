# Handoff: DraxosMobile Arena loop feedback v2

## Metadata

- data: `2026-06-02`
- agente: `Codex`
- projeto: `draxos-mobile`
- branch: `codex/draxos-mobile/arena-loop-simplification`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-loop-simplification`
- base_commit: `f8dbdad`
- lane: `client-shell`
- mode_scope: `autobattler`

## Objetivo entregue

Segundo pacote client-only para melhorar feedback do loop Arena PVE/autobattler: trilho de progresso dos duelos, resumo expandivel de loadout travado e tratamento mais claro de combate/recompensa no replay/log da Arena.

## Mudancas principais

- Tentativa ativa agora mostra `Progresso dos duelos` com trilho compacto: ganho, agora e espera.
- Arena ativa ganhou painel `Loadout travado` com resumo sempre visivel e detalhes locais somente leitura via toggle.
- Detalhes do loadout mostram origem, resumo e hash curto sem permitir edicao.
- Tentativa ativa passou a ter fallback humano para proximo inimigo quando o estado normalizado nao trouxer nome.
- Replay fullscreen da Arena mostra contexto `Duelo X/Y da Arena` e linha `Recompensa do duelo`.
- Resumo fullscreen de log da Arena ganhou painel `Combate`, mantem `Recompensa aplicada` e continua ocultando Ranking para Arena PVE.
- Captura Track 15 ganhou imagens novas: loadout expandido e replay da Arena.

## Arquivos alterados

- `Projetos/draxos-mobile/modes/boot/surfaces/arena_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/battle_replay_presenter.gd`
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/tools/capture_track15_mobile_ux.gd`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-02_codex_draxos-mobile_arena-loop-feedback-v2.md`

## Evidencias visuais

Capturas locais em:

`D:\Estudio-worktrees\draxos-mobile--codex--arena-loop-simplification\Projetos\draxos-mobile\build\track15_mobile_ux_checkpoint`

- `09_arena_active.png`
- `12_arena_loadout_expanded.png`
- `13_arena_replay.png`
- alem das capturas anteriores `01` a `11`.

## Validacao

- `git diff --check` - PASS
- GUT client - PASS, 177/177, 3220 asserts
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd` - PASS
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --path . -s res://tools/capture_track15_mobile_ux.gd` - PASS
- `.\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick` - PASS

## Observacoes

- Sem backend, schema, migrations, endpoints, economia, tuning, PVP ou publicacao.
- Sem novas acoes do app shell; o toggle de loadout e local/read-only.
- Capturas continuam como artefato local de build e nao foram forcadas para o indice Git.
