# DraxosMobile - Rpgsuave Publication

- Data: `2026-05-31`
- Agente: `codex`
- Branch: `codex/draxos-mobile/rpgsuave-integrated-alpha`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--rpgsuave-integrated-alpha`
- Objetivo: executar os proximos passos do pacote Rpgsuave ate o ponto de exigir playtest humano, incluindo prova live local, release safety, export/package e publicacao Internal Alpha aprovada pelo usuario.

## Docs lidos

- `AGENTS.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `Projetos/draxos-mobile/tools/README.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Arquivos pretendidos

- Testes live locais de minigames, se inexistentes.
- Handoff/status de publicacao.
- Artefatos locais em `Projetos/draxos-mobile/build/` gerados pelos scripts de release.
- Possivel commit adicional com testes/docs/status. Artefatos de build continuam fora do Git.

## Validacao planejada

- Supabase local start/reset quando possivel.
- Deno check/test/run para provas live de minigames.
- `validate_foundation.ps1 -Profile Full` quando o stack local permitir.
- Release safety: `check_release_safety.ps1`, `check_track13_readiness.ps1`, `check_agent_ops_foundation.ps1`, `check_foundation_expansion_readiness.ps1`.
- Export/package/upload/deploy conforme scripts protegidos e aprovacao explicita do usuario.

## Proximo handoff

Registrar se a publicacao foi concluida, URLs/roots, comandos executados, bloqueios de credenciais/servicos e o ponto exato onde o playtest humano passa a ser necessario.
