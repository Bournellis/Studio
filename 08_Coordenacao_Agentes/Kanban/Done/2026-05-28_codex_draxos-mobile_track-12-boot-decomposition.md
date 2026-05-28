# Multi-Agent Done: DraxosMobile Track 12 Boot Decomposition

## Metadata

- data: `2026-05-28`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/track-12-boot-decomposition`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--track-12-boot-decomposition`

## Objetivo

Extrair responsabilidades reais de `modes/boot/boot.gd` para contratos, flows e helpers menores sem alterar UX, backend, economia, rotas ou comportamento jogavel.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-11-product-foundation-consolidation/foundation-audit.md`

## Escopo

- Incluir: contrato de actions do app shell, fluxos de conta/sessao/update, fluxos online de Base/Social/Competicao/Loja, ciclo de batalha/replay, helpers de superficie e guardas de regressao.
- Fora do escopo: UX nova, cenas `.tscn`, schema/backend, tuning de economia/progressao, assets finais, publicacao de builds e migracao `account_profiles` + `game_saves`.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/boot.gd`
- `Projetos/draxos-mobile/modes/boot/ui/`
- `Projetos/draxos-mobile/modes/boot/flows/`
- `Projetos/draxos-mobile/modes/boot/surfaces/`
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-12-boot-decomposition/`
- `08_Coordenacao_Agentes/`

## Plano De Commit

- `coordination: register DraxosMobile Track 12 boot decomposition`
- `contracts: extract DraxosMobile boot action contract`
- `client: extract DraxosMobile account session flow`
- `client: extract DraxosMobile surface action flow`
- `client: extract DraxosMobile battle lifecycle flow`
- `client: tighten DraxosMobile boot surface boundaries`
- `test/docs: document and guard DraxosMobile boot decomposition`

## Validacao

- `git diff --check`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`

## Proximo Handoff

Track entregue com decomposicao validada, commits logicos aplicados, status/documentacao atualizados e worktree limpa.

## Resultado

- `boot.gd` reduziu para `1301` linhas.
- Contratos/flows/helpers novos adicionados sem alterar UX, schema, backend, economia ou cenas `.tscn`.
- GUT client e `tools/validate.gd` verdes.
