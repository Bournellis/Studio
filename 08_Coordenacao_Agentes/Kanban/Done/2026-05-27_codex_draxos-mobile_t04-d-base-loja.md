# T04-D - DraxosMobile Base/Loja

- Data: `2026-05-27`
- Agente sugerido: `Codex`
- Branch sugerida: `codex/draxos-mobile/t04-base-loja`
- Worktree sugerida: `D:\Estudio-worktrees\draxos-mobile--codex--t04-base-loja`
- Status: `DONE_INTEGRATED`

## Objetivo

Extrair renderizacao da Base e da Loja para presenters render-only, preservando comportamento.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/boot.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/`
- Testes client relevantes, se precisar cobrir a superficie extraida.

## Guardrails

- Preservar endpoints `base/*` e `monetization/*`.
- Nao mudar economia, fila dupla, redeems, schema ou contratos.

## Validacao Planejada

- Godot `tools/validate.gd`
- GUT client
- Smoke alpha loop relevante, se existir
- `git diff --check`

## Proximo Handoff

Entregar Base/Loja render-only e registrar qualquer lacuna de UX separada de refatoracao.
