# T04-H - DraxosMobile Account/Save Gate

- Data: `2026-05-27`
- Agente sugerido: `Codex`
- Branch sugerida: `codex/draxos-mobile/t04-account-save-gate`
- Worktree sugerida: `D:\Estudio-worktrees\draxos-mobile--codex--t04-account-save-gate`
- Status: `READY_AFTER_T04_A`

## Objetivo

Avaliar o modelo atual `players.save_type` depois do alpha aprovado e decidir documentadamente se ele continua ou se deve virar plano de `account_profiles` + `game_saves`.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/docs/contracts/database-schema.md`
- `Projetos/draxos-mobile/docs/architecture.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- Funcoes `account`, `social`, `competition` e `monetization` apenas para analise.

## Guardrails

- Nao implementar migration nesta trilha.
- Entregar decisao, riscos e plano de migration somente se necessario.

## Validacao Planejada

- `git diff --check`
- Checks backend apenas se houver documentacao de plano que precise validar referencias.

## Proximo Handoff

Se a decisao for migrar, abrir track/commit proprio antes de qualquer alteracao SQL/backend.
