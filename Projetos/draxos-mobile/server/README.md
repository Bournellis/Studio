# server/

Backend do DraxosMobile. Contem espelho organizado do schema Postgres e das Edge Functions.

- `schema/` - migrations SQL e definicao de tabelas.
- `functions/` - Edge Functions TypeScript/Deno para batalha, conta, base e social.
- `.env.example` - variaveis esperadas sem secrets reais.
- `tests/` - testes server-side.

Todo estado autoritativo do jogo passa por aqui. O cliente Godot nunca altera recursos diretamente.

Fonte de execucao local da Supabase CLI: `../supabase/`.

## MVP Atual

- Migration inicial: `schema/migrations/202605190001_mvp_foundation.sql`
- Migration conta guest: `schema/migrations/202605190002_guest_account_mvp.sql`
- Edge Functions: `functions/healthcheck/index.ts`, `functions/account/index.ts`, `functions/battle/index.ts`
- Conta guest MVP: Auth anonimo + `account/guest` + `account/state`, com escrita autoritativa via service role.
- Battle request MVP: `battle/request` + `battle/latest`, com simulacao fixture server-authoritative e recompensa idempotente.

## Validacao Esperada

Healthcheck ja pode ser validado com `npx deno`:

```powershell
cd D:\Estudio\Projetos\draxos-mobile\server\functions
npx -y deno task check
npx -y deno task lint
npx -y deno run --allow-net healthcheck/index.ts
```

Runtime Supabase validado com Docker Desktop e Supabase CLI via `npx`:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y supabase start
npx -y supabase db reset
Invoke-RestMethod -Uri 'http://127.0.0.1:54321/functions/v1/healthcheck'
```

`DMOB-D040` foi resolvido usando `supabase/` como layout oficial de runtime local.
`DMOB-D042` e `DMOB-D043` foram resolvidos em T00-P05: guest usa Supabase Auth anonimo e o cliente nao recebe policies de escrita direta para estado autoritativo.

Smoke P07:

```powershell
npx -y deno run --allow-net --allow-env server/tests/battle_request_smoke.ts
```
