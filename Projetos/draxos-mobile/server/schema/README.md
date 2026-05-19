# server/schema/

Migrations SQL do Supabase/Postgres para o DraxosMobile.

## MVP

- `migrations/202605190001_mvp_foundation.sql` cria as tabelas minimas de `players`, `resources`, `builds`, `battles`, `bot_builds`, `invite_codes`, `idempotency_keys` e `resource_transactions`.
- RLS fica habilitado desde a primeira migration.
- Mutacoes autoritativas devem ser feitas por Edge Functions com service role.

## Validacao Esperada

Quando Docker e Supabase CLI estiverem disponiveis:

```powershell
supabase db reset
```

O ambiente local ainda precisa de Docker, Supabase CLI e um `supabase/config.toml` oficial ou decisao equivalente de layout antes de automatizar esse comando.
