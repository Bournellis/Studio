# supabase/

Layout oficial da Supabase CLI para o runtime local do DraxosMobile.

## Fonte De Execucao Local

- `config.toml` - configuracao local da Supabase CLI.
- `migrations/` - migrations aplicadas por `supabase db reset`.
- `functions/` - Edge Functions servidas por `supabase functions serve`.
- `seed.sql` - seed local opcional; no MVP atual, o bot tecnico ja e semeado pela migration inicial.

## Decisoes Atuais

- `DMOB-D040`: resolvido usando o layout oficial `supabase/` como fonte de execucao local.
- `DMOB-D042`: guest MVP usa Supabase Auth anonimo nativo; depois o cliente chama `/account/guest` com JWT anonimo e codigo de convite.
- `DMOB-D043`: escrita autoritativa fica restrita a Edge Functions com service role; cliente recebe policies de leitura proprias e nao possui insert/update direto para estado autoritativo.

## MVP Atual

- `migrations/202605190001_mvp_foundation.sql`: tabelas MVP, RLS base e bot fixture.
- `migrations/202605190002_guest_account_mvp.sql`: convite `ALPHA-TEST`, RPC `create_guest_account` e estado inicial guest.
- `functions/healthcheck/index.ts`: healthcheck sem JWT.
- `functions/account/index.ts`: `POST /account/guest` e `GET /account/state` com JWT anonimo.
- `functions/battle/index.ts`: `POST /battle/request` e `GET /battle/latest` com JWT anonimo.

## Comandos

Use `npx -y supabase` enquanto a CLI global nao estiver instalada.

```powershell
cd D:\Estudio-worktrees\draxos-mobile--<agent>--<slug>\Projetos\draxos-mobile
npx -y supabase db reset
Invoke-RestMethod -Uri 'http://127.0.0.1:54321/functions/v1/healthcheck'
```

Docker Desktop precisa estar instalado e rodando antes desses comandos.
