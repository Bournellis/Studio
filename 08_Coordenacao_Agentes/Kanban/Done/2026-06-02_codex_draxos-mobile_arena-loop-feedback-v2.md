# DraxosMobile Hardening Doing: client-shell - Arena loop feedback v2

## Metadata

- data: `2026-06-02`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `client-shell`
- mode_scope: `autobattler`
- branch: `codex/draxos-mobile/arena-loop-simplification`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-loop-simplification`
- base_commit: `f8dbdad`

## Objetivo

Adicionar feedback visual/read-only ao loop Arena PVE/autobattler: trilho de progresso dos duelos na tentativa ativa, resumo de loadout expandivel dentro da Arena e tratamento visual mais claro de combate/recompensa no replay, sem mudar backend, schema, tuning, economia ou funcoes existentes.

## Base Lida

- `C:\Users\Fabio\.codex\skills\estudio-workspace\SKILL.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-02_codex_draxos-mobile_arena-loop-simplification.md`
- `08_Coordenacao_Agentes/Handoffs/2026-06-02_codex_draxos-mobile_arena-loop-simplification.md`

## Escopo

- Incluir:
  - trilho visual textual/compacto de duelos na tentativa ativa;
  - resumo read-only expandivel do loadout travado dentro da Arena;
  - copy/paineis do replay com mais leitura de combate e recompensa para logs da Arena;
  - atualizacao de testes e capturas locais.
- Fora do escopo:
  - backend, schema, migrations ou endpoints;
  - publicacao remota;
  - tuning numerico, economia, recompensas, PVP, novas armas/spells/pocoes ou conteudo novo;
  - mudancas em worktrees de outros agentes.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/surfaces/arena_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/battle_replay_presenter.gd`
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/tools/capture_track15_mobile_ux.gd`

## Validation Plan

- `git diff --check`
- GUT client
- `tools/smoke_responsive_layout.gd`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`
- capturas locais Track 15 atualizadas para revisao visual

## Handoff Point

Handoff para Fabio apos patch local, screenshots, validacao client e commit incremental. Publicacao Internal Alpha continua fora deste pacote.

## Resultado

- trilho de progresso dos duelos entregue na tentativa ativa.
- resumo de loadout travado com toggle local somente leitura entregue dentro da Arena.
- replay/log da Arena ganhou contexto de duelo e recompensa sem mudar contrato de backend.
- screenshots atualizadas em `Projetos/draxos-mobile/build/track15_mobile_ux_checkpoint`, incluindo `12_arena_loadout_expanded.png` e `13_arena_replay.png`.
- validacao concluida: `git diff --check`, GUT client 177/177, `smoke_responsive_layout.gd`, captura Track 15 e `validate_foundation.ps1 -Profile ClientQuick`.
- handoff registrado em `08_Coordenacao_Agentes/Handoffs/2026-06-02_codex_draxos-mobile_arena-loop-feedback-v2.md`.
