# server/tests/

Testes Deno/TypeScript das Edge Functions e do simulador server-authoritative.

No MVP atual, o alvo inicial e validar:

- `healthcheck` responde `ok: true`.
- migrations aplicam em banco limpo.
- `battle/request` exige auth, retorna `battle_log_v1` e respeita idempotencia
  por `request_id`.

## Smokes

Com Supabase local rodando:

```powershell
npx -y deno run --allow-net --allow-env server/tests/battle_request_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/first_slice_battle_smoke.ts
```

O smoke cria uma sessao anonima, cria conta guest, solicita batalha `MVP_ONLY`,
repete o mesmo `request_id`, consulta `battle/latest` e confirma que XP/Ossos
nao duplicam.

O smoke `first_slice_battle_smoke.ts` cria sessao anonima, cria conta guest,
solicita `FIRST_SLICE_SIM` contra bots de efeito/invocacao, repete o mesmo
`request_id`, consulta `battle/latest` e confirma eventos ricos, idempotencia e
aplicacao de XP/Almas/Energia/Sangue/Ossos.

Validacao standalone de Edge Functions pode usar `npx deno`. Validacao de
runtime Supabase depende de Docker e Supabase CLI no ambiente local.
