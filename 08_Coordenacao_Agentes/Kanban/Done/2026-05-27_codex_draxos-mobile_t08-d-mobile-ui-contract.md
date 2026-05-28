# DraxosMobile - T08-D Mobile UI Contract

- Data: `2026-05-27`
- Agente: `Codex`
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/t08-mobile-ui-contract`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t08-mobile-ui-contract`
- Objetivo: centralizar regras de UI mobile para alvo minimo de toque, drag threshold, politica de scroll/touch e layout portrait/landscape, reaplicando no shell sem redesign visual.
- Status: `COMPLETE`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/implementation-plan.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/ui/touch_scroll_container.gd`
- `Projetos/draxos-mobile/modes/boot/ui/mobile_ui_contract.gd`
- `Projetos/draxos-mobile/modes/boot/boot.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/base_surface_presenter.gd`
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/tools/smoke_mobile_presentation.gd`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/current-status.md`

## Validacao Planejada

- GUT focado em `tests/client/test_boot_mobile_ui.gd`
- `tools/smoke_mobile_presentation.gd`
- `tools/validate.gd`
- `git diff --check`

## Handoff

T08-D entregue em `codex/draxos-mobile/t08-mobile-ui-contract`.

Entregas:

- `DraxosMobileUiContract` criado como helper comum para alvo minimo de toque, drag threshold, scrollbar/touch policy e layout portrait/landscape.
- `DraxosTouchScrollContainer` passou a consumir o contrato comum.
- `boot.gd` delega tamanho minimo, colunas responsivas, input minimo e preparo de botoes ao helper.
- Botoes manuais da Base reutilizam `_prepare_touch_button`.
- GUT e smoke mobile cobrem contrato de botao, scroll, drag e layout.

Validacao:

- GUT client com `-gtest=res://tests/client/test_boot_mobile_ui.gd`: passou; o config carregou a suite client inteira com `85/85` testes e `985` asserts.
- `tools/smoke_mobile_presentation.gd`: passou.
- `tools/validate.gd`: passou com `DraxosMobile validate: OK`, `85/85` testes e `985` asserts.
- `git diff --check`: passou.

Guardrails preservados: sem redesign visual, troca de assets, backend/schema, tuning ou gameplay novo.
