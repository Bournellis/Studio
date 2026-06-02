# Handoff: DraxosMobile Arena loop simplification

## Metadata

- data: `2026-06-02`
- agente: `Codex`
- projeto: `draxos-mobile`
- branch: `codex/draxos-mobile/arena-loop-simplification`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-loop-simplification`
- lane: `client-shell`
- mode_scope: `autobattler`

## Objetivo entregue

Simplificacao client-only do loop Refugio -> Preparacao/loadout -> Arena PVE -> tentativa ativa -> comportamento/batalha -> buff/recompensa -> continuar, sem remover funcoes existentes e sem tocar backend, schema, economia, tuning numerico ou publicacao.

## Mudancas principais

- Arena PVE agora usa nomes amigaveis de arena/dificuldade, esconde ids crus como `s1_d00_intro` e evita botoes longos em mobile.
- Selecao da Arena destaca o proximo desafio com CTA `Comecar`, mantendo a lista completa de opcoes abaixo.
- Tentativa ativa ganhou painel compacto com duelo atual, estado, proximo inimigo, loadout travado, comportamento ajustavel e buffs ativos.
- Preparacao passou a mostrar primeiro o loadout que sera travado na Arena, mantendo todas as secoes completas de edicao abaixo.
- Refugio ganhou hierarquia visual mais direta: Arena PVE como acao central, Preparacao/Refugio como secundarias, Social/Modos/Loja como atalhos.
- Resumo de batalha da Arena separa `Recompensa aplicada` e remove ranking apenas para logs da Arena; resumo geral de batalha segue com ranking.
- Base troca marcadores tecnicos por rotulos humanos nos cards de rotina.
- Script de captura Track 15 agora inclui telas especificas da Arena PVE.

## Arquivos alterados

- `Projetos/draxos-mobile/modes/boot/surfaces/arena_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/hub_surface_refuge_scene_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/hub_surface_preparation_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/battle_replay_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/base_surface_presenter.gd`
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/tools/capture_track15_mobile_ux.gd`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-02_codex_draxos-mobile_arena-loop-simplification.md`

## Evidencias visuais

Capturas locais geradas em:

`D:\Estudio-worktrees\draxos-mobile--codex--arena-loop-simplification\Projetos\draxos-mobile\build\track15_mobile_ux_checkpoint`

- `01_entry.png`
- `02_refugio.png`
- `03_batalha.png`
- `04_summary.png`
- `05_base.png`
- `06_loja.png`
- `07_preparacao.png`
- `08_arena_selection.png`
- `09_arena_active.png`
- `10_arena_buff.png`
- `11_arena_summary.png`

## Validacao

- `git diff --check` - PASS
- Godot import headless - PASS
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit` - PASS, 175/175
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd` - PASS
- `.\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick` - PASS

## Observacoes

- Sem multiagente: escopo ficou local e cabia em um patch client-shell.
- Sem publicacao remota; portanto `Prioridades_Estudio.md`, `Estado_Atual.md` e `Projetos/README.md` nao foram alterados.
- Capturas ficam como artefato local de build e nao foram forcadas para o indice Git.
