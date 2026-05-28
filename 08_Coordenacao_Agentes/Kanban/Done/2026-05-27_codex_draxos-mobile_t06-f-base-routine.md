# DraxosMobile - T06-F Base Routine

- Data: `2026-05-27`
- Agente: Codex
- Projeto: `Projetos/draxos-mobile/`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t06-base-routine`
- Branch: `codex/draxos-mobile/t06-base-routine`
- Status: `READY_FOR_INTEGRATION`

## Objetivo

Instalar painel de rotina/proximo objetivo da Base usando apenas payload existente de `GET /base/state`, cobrindo coleta pronta, jobs em andamento, slots livres e proximo upgrade legivel.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/implementation-plan.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/feature-registry.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/agent-registry.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/surfaces/base_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/boot.gd` somente se for necessaria chamada render-only
- `Projetos/draxos-mobile/tests/client/`
- `Projetos/draxos-mobile/tools/smoke_foundation_surfaces.gd`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/feature-registry.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/current-status.md`

## Validacao Planejada

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-base-routine\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-base-routine\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-base-routine\Projetos\draxos-mobile -s res://tools/smoke_foundation_surfaces.gd
git diff --check
```

## Validacao Executada

- `validate.gd`: passou.
- GUT completo `res://tests/client`: passou com `64/64` testes e `709` asserts.
- `tools/smoke_foundation_surfaces.gd`: passou cobrindo Base/Social/Competicao/Loja e probe de rotina da Base.
- `git diff --check`: passou.

## Handoff

T06-I deve verificar que a rotina da Base continua derivada do payload existente, sem endpoint novo, sem mudanca de economia/custos/tempos/recursos/schema e sem alterar fila dupla ou mensagens atuais.
