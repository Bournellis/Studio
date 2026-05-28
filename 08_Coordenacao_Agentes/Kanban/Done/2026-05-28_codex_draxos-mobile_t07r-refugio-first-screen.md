# DraxosMobile - T07R Refugio First Screen Correction

- Data: `2026-05-28`
- Agente: `codex`
- Branch: `codex/draxos-mobile/t07r-refugio-first-screen`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t07r-refugio-first-screen`
- Projeto: `Projetos/draxos-mobile`

## Objetivo

Corrigir a interpretacao da Track 07: o Refugio deve ser a primeira camada visual do app, em full viewport e sem app chrome, nao apenas a rota inicial renderizada dentro do shell.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/boot.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/shell_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/hub_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/ui/app_shell_route_contract.gd`
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/tools/smoke_mobile_presentation.gd`
- `Projetos/draxos-mobile/tools/smoke_foundation_hardening.gd`
- Documentacao/status local se a correcao alterar baseline observavel.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/current-status.md`

## Validacao Planejada

- Godot `tools/validate.gd`
- GUT completo `res://tests/client`
- `tools/smoke_mobile_presentation.gd`
- `tools/smoke_foundation_hardening.gd`
- `git diff --check`

## Handoff

Status: `COMPLETE_VALIDATED`.

Entregue branch com o Refugio como first screen real, app shell reservado para telas internas e testes atualizados para proteger esse contrato.

Validacao executada:

- `tools/validate.gd`: passou com GUT integrado `95/95` testes e `1132` asserts.
- GUT completo `res://tests/client`: passou com `95/95` testes e `1132` asserts.
- `tools/smoke_mobile_presentation.gd`: passou.
- `tools/smoke_foundation_hardening.gd`: passou.
- `git diff --check`: passou.

Nota: a primeira execucao de `validate.gd` na worktree recem-criada exigiu uma importacao headless do Godot para registrar classes globais como `ProjectInfo`. Depois disso a validacao passou.
