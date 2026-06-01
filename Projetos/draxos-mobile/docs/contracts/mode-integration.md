# Mode Integration Contract V1

- Status: `COMPATIBILIDADE_VIVA`
- Canonico: `docs/contracts/minigame-integration.md`
- Identificador: `MODE_INTEGRATION_CONTRACT_V1`

Este arquivo existe para manter os gates de Foundation Expansion Readiness
compativeis com a nomenclatura V1. O contrato operacional completo vive em
`docs/contracts/minigame-integration.md`, que agora governa os cinco modos:
Basebuilder, Autobattler, Towerdefense, Cardgame e Openworld.

## Contract-first

Nenhum modo ganha tela jogavel, endpoint mutante, reward bridge, CTA publico ou
entrada no manifest sem contrato vivo. O contrato deve declarar identidade do
modo, slice, status, surface de entrada, owner de build, economia, telemetry,
rollback e criterio de Refugio.

## Migration

Qualquer mudanca de estado compartilhado deve ter migration espelhada em
`server/schema/migrations/` e `supabase/migrations/`, com schema legivel,
politica de rate/cooldown e estrategia de disable/rollback.

## Ruleset

Modo que emite progresso ou recompensa real precisa de ruleset versionado,
ledger/RPC server-authoritative e bloqueio explicito contra reward real no
`progression_lab`.

## Checklist De Integracao

- registry row completo;
- action/route client oficial;
- status claro no Hub;
- admin/ops em `admin-ops.md`;
- telemetry por modo;
- testes Deno/GUT/smoke;
- handoff humano antes de tornar `public_cta=true`.
