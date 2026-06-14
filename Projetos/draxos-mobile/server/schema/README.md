# server/schema/

Fonte autoral das migrations SQL do Supabase/Postgres para o DraxosMobile.

## MVP

- `migrations/202605190001_mvp_foundation.sql` cria as tabelas minimas de `players`, `resources`, `builds`, `battles`, `bot_builds`, `invite_codes`, `idempotency_keys` e `resource_transactions`.
- RLS fica habilitado desde a primeira migration.
- Mutacoes autoritativas devem ser feitas por Edge Functions com service role.

## Validacao Esperada

Antes de validar backend, confira o mirror runtime:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ..\..\tools\sync_backend_mirror.ps1 -ProjectDir ..\.. -Check
```

Se houver drift revisado, aplique `server/schema/migrations -> supabase/migrations`
com `-Apply`.

Quando Docker e Supabase CLI estiverem disponiveis:

```powershell
supabase db reset
```

O ambiente local ainda precisa de Docker, Supabase CLI e um `supabase/config.toml` oficial ou decisao equivalente de layout antes de automatizar esse comando.
