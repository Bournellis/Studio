# T08-G - Validation Harness

- Data: `2026-05-27`
- Agente: `codex`
- Projeto: `draxos-mobile`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t08-integration`
- Branch: `codex/draxos-mobile/t08-integration`
- Status: `DONE_INTEGRATION_BRANCH`

## Objetivo

Criar o smoke final de hardening da Track 08 e registrar a matriz de validacao quick/full/release sem alterar produto, backend, schema, economia ou assets finais.

## Entrega

- `tools/smoke_foundation_hardening.gd` cobre rotas/back, UI mobile, session/save boundary e battle mode sem depender de rede.
- `tools/README.md` documenta o novo smoke.
- `tools/validate.gd` passa a checar a existencia do smoke.
- Track 08 registra o harness como etapa pronta para validacao final T08-H.

## Validacao Local

- `smoke_foundation_hardening.gd`: passou em headless na worktree de integracao.

## Handoff

Seguir para validacao final T08-H: `validate.gd`, GUT completo, smokes Track 08/Track 07/Track 06 e checks Deno quando aplicavel.
