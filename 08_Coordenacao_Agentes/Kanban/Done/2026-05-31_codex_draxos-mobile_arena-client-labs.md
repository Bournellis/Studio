# Multi-Agent Doing: DraxosMobile Arena Client And Labs

## Metadata

- data: `2026-05-31`
- agente: `Codex worker`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/arena-client-labs`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-client-labs`

## Objetivo

Adicionar shell jogavel da Arena PVE no cliente e adaptar labs para medir tentativas de arena.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/docs/foundation-responsive-layout-contract.md`

## Escopo

- Incluir: Supabase client `arena/*`, `SessionStore` com estado de arena, fluxo/telas de Arena PVE, testes Godot e ajustes Battle/Progression Lab.
- Fora do escopo: SQL/RPCs backend e novos assets finais.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/online/`
- `Projetos/draxos-mobile/modes/`
- `Projetos/draxos-mobile/core/`
- `Projetos/draxos-mobile/tools/battle_lab/`
- `Projetos/draxos-mobile/tools/progression_lab/`
- `Projetos/draxos-mobile/tests/client/`

## Plano De Commit

- `client: add pve arena shell`
- `labs: model pve arena attempts`
- `test: cover arena client flow`

## Validacao

- `git diff --check`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd`

## Proximo Handoff

Entregue e integrado na branch `codex/draxos-mobile/pve-arena-integration`.

## Resultado

- Refugio aponta para Arena PVE como CTA principal.
- Cliente tem rotas de selecao, loadout, tentativa ativa, replay, buff choice e resumo.
- `SessionStore` separa estado de Arena de `competition_state`.
- Battle Lab e Progression Lab geram evidencia de sequencias/tentativas de Arena.
