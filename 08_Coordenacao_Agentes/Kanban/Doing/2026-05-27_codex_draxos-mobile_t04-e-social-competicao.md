# T04-E - DraxosMobile Social/Competicao

- Data: `2026-05-27`
- Agente sugerido: `Codex`
- Branch sugerida: `codex/draxos-mobile/t04-social-competicao`
- Worktree sugerida: `D:\Estudio-worktrees\draxos-mobile--codex--t04-social-competicao`
- Status: `DONE_INTEGRATED`

## Objetivo

Extrair renderizacao de Social e Competicao para presenters render-only.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/boot.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/`
- Testes client relevantes, se precisar cobrir a superficie extraida.

## Guardrails

- Preservar polling/chat/ranking.
- Manter `progression_lab` fora do ranking e bots fora da leaderboard.
- Nao mudar backend, schema ou contratos.

## Validacao Planejada

- Godot `tools/validate.gd`
- GUT client
- `git diff --check`

## Proximo Handoff

Entregar Social/Competicao render-only e registrar qualquer melhoria de UX como pacote separado.
