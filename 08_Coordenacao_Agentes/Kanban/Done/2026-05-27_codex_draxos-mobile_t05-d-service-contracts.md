# T05-D Service Contracts - Codex

- Data: `2026-05-27`
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/t05-service-contracts`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t05-service-contracts`
- Status: `READY_FOR_INTEGRATION`

## Objetivo

Preparar a fundacao de contratos de servico da Track 05 sem implementar servico novo, sem migration e sem alterar payload publico.

## Escopo Pretendido

- Classificar endpoints/funcoes atuais como `save-scoped`, `account-scoped`, `release`, `telemetry` ou `admin-future`.
- Documentar que endpoints futuros devem declarar escopo explicitamente.
- Registrar o escopo em `docs/contracts/api-endpoints.md`, `docs/contracts/database-schema.md` se necessario, `docs/architecture.md` apenas como resumo, e `implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/service-contract-scope.md`.
- Adicionar testes Deno somente se forem checks de contrato/escopo/idempotencia sobre comportamento existente.

## Fora De Escopo

- Criar `account_profiles` ou `game_saves`.
- Alterar schema, migrations, economia, ranking, servicos novos ou payload publico.
- Publicar remoto ou mudar estado de release.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/implementation-plan.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/agent-prompts.md`
- `Projetos/draxos-mobile/docs/contracts/api-endpoints.md`
- `Projetos/draxos-mobile/docs/contracts/database-schema.md`
- `Projetos/draxos-mobile/docs/architecture.md`

## Validacao Planejada

- `npx -y deno task check` em `Projetos/draxos-mobile/supabase/functions`
- `npx -y deno task check` em `Projetos/draxos-mobile/server/functions`
- Testes Deno adicionados, se houver.
- `git diff --check`

## Proximo Handoff

Entregar branch com contratos classificados, resumo de escopo da T05-D, validacoes executadas e commit coerente para futura integracao T05-H.

## Resultado

- Endpoints e Edge Functions atuais classificados como `save-scoped`, `account-scoped`, `release`, `telemetry` ou `admin-future`.
- Regra adicionada: endpoint futuro precisa declarar escopo, save header, dono de idempotencia e cobertura antes de codigo/migration/smoke.
- Nenhum schema, payload publico, ranking, economia ou servico novo foi alterado.
- Validado com `npx -y deno task --cwd supabase/functions check`, `npx -y deno task --cwd server/functions check` e `git diff --check`.
