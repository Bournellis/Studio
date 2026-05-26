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
npx -y deno run --allow-net --allow-env server/tests/two_save_context_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/reset_save_context_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/progression_lab_apply_smoke.ts
```

O smoke cria uma sessao anonima, cria conta guest, solicita batalha `MVP_ONLY`,
repete o mesmo `request_id`, consulta `battle/latest` e confirma que XP/Ossos
nao duplicam.

O smoke `first_slice_battle_smoke.ts` cria sessao anonima, cria conta guest,
solicita `FIRST_SLICE_SIM` contra bots de efeito/invocacao, repete o mesmo
`request_id`, consulta `battle/latest` e confirma eventos ricos, idempotencia e
aplicacao de XP/Almas/Energia/Sangue/Ossos.

O smoke `base_manager_smoke.ts` valida auth obrigatoria, inicializacao dos seis
predios, payload de UI com custo/tempo/status, coleta idempotente, compra alpha
de Energia, upgrade server-authoritative por predio e bloqueio de segunda
construcao quando a fila esta cheia.

O smoke `social_competition_smoke.ts` valida social basico com dois testadores:
auth obrigatoria, identidade social de conta, amizade por username, guilda
create/join, membros enriquecidos, chat de guilda idempotente, rate limit,
polling com usernames, matchmaking com bot fora do ranking e RLS contra insert
direto em guilda.

O smoke `client_telemetry_smoke.ts` valida auth obrigatoria, evento pre-conta
com `player_id = null`, evento pos-conta, rejeicao de schema desconhecido e
bloqueio de insert direto em `telemetry_events` com JWT anonimo.

O smoke `two_save_context_smoke.ts` valida o contexto `normal` e
`progression_lab` usando o header `x-draxos-save-type`: dois players isolados
na mesma sessao auth, batalha/base/loja no save Lab e ranking bloqueado para
`progression_lab`.

O smoke `reset_save_context_smoke.ts` valida `POST /account/saves/reset`:
reset do Lab preserva Normal, reset do Normal preserva Lab, `request_id` e
idempotente e `save_type` divergente entre body/header e rejeitado.

O smoke `progression_lab_apply_smoke.ts` valida `POST /progression-lab/apply`:
perfil/milestone versionado aplicado no save `progression_lab`, save normal
preservado, idempotencia por `request_id`, ranking do Lab bloqueado e batalha
do Lab ainda jogavel apos a aplicacao.

Validacao standalone de Edge Functions pode usar `npx deno`. Validacao de
runtime Supabase depende de Docker e Supabase CLI no ambiente local.

## Remote Internal Alpha

Depois de criar um projeto Supabase remoto e publicar o healthcheck:

```powershell
$env:SUPABASE_URL='https://<project-ref>.supabase.co'
$env:SUPABASE_PUBLISHABLE_KEY='sb_publishable_<public-key>'
npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts
```

O smoke remoto rejeita URLs locais e service role no lugar da publishable key.
Use `DRAXOS_REMOTE_ANON_AUTH_SMOKE=1` para incluir Auth anonimo e
`DRAXOS_REMOTE_ACCOUNT_SMOKE=1` depois que migrations, Edge Functions e convite
alpha estiverem publicados.
