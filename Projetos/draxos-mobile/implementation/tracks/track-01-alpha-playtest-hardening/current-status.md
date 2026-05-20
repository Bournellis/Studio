# Track 01 - Alpha Playtest Hardening - Current Status

- Last Updated: `2026-05-20`
- Status: `COMPLETE - PC_LOCAL_ALPHA_PLAYTEST_READY`
- Baseline: Track 00 completa e alpha-ready.

## Implementado

- Hub alpha hardenizado para PC local: fluxo de entrada mais claro, busy states, erros offline, refresh de sessao, pre-condicoes visiveis e reset seguro de cache/sessao local.
- Telemetria client nao autoritativa: endpoint `POST /telemetry/client-event`, `SessionStore.session_id` persistido e chamada `SupabaseClient.send_client_telemetry`.
- Eventos client: `screen_opened`, `action_start`, `action_success`, `action_failure`, `replay_start`, `replay_skip`, `replay_end`, `network_failure` e eventos auxiliares de recuperacao/pre-condicao.
- Smokes novos: `server/tests/client_telemetry_smoke.ts` e `tools/smoke_alpha_loop.gd`.
- Documentacao: contratos atualizados, checklist de playtest alpha e status operacional reconciliado com Track 00 completa.

## Regras Mantidas

- Telemetria nunca altera gameplay, recursos, ranking, recompensas ou resultado de batalha.
- O cliente continua nao autoritativo.
- `CALIBRAVEL_ALPHA` permanece baseline-only ate existir dado real de playtest.
- `POS_SLICE` e novas mecanicas exigem sessao de design.

## Proximo Passo

Executar playtest alpha PC local com Supabase local rodando e registrar feedback em `docs/playtest-alpha.md`.
