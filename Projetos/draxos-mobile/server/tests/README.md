# server/tests/

Testes Deno/TypeScript das Edge Functions e do simulador server-authoritative.

No MVP atual, o alvo inicial e validar:

- `healthcheck` responde `ok: true`.
- migrations aplicam em banco limpo.
- `battle/request` exige auth, retorna `battle_log_v1` e respeita idempotencia
  por `request_id`.
- `telemetry/client-event` exige auth, grava eventos client nao autoritativos e
  continua protegido por RLS contra insert direto.

## Smokes

Com Supabase local rodando:

```powershell
npx -y deno run --allow-net --allow-env server/tests/battle_request_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/first_slice_battle_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/base_manager_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/social_competition_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/monetization_rewards_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/client_telemetry_smoke.ts
```

O smoke cria uma sessao anonima, cria conta guest, solicita batalha `MVP_ONLY`,
repete o mesmo `request_id`, consulta `battle/latest` e confirma que XP/Ossos
nao duplicam.

O smoke `first_slice_battle_smoke.ts` cria sessao anonima, cria conta guest,
solicita `FIRST_SLICE_SIM` contra bots de efeito/invocacao, repete o mesmo
`request_id`, consulta `battle/latest` e confirma eventos ricos, idempotencia e
aplicacao de XP/Almas/Energia/Sangue/Ossos.

O smoke `client_telemetry_smoke.ts` valida auth obrigatoria, evento pre-conta
com `player_id = null`, evento pos-conta, rejeicao de schema desconhecido e
bloqueio de insert direto em `telemetry_events` com JWT anonimo.

Validacao standalone de Edge Functions pode usar `npx deno`. Validacao de
runtime Supabase depende de Docker e Supabase CLI no ambiente local.
