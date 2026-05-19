# server/tests/

Testes Deno/TypeScript das Edge Functions e do simulador server-authoritative.

No MVP atual, o alvo inicial e validar:

- `healthcheck` responde `ok: true`.
- migrations aplicam em banco limpo.
- endpoints futuros respeitam idempotencia por `request_id`.

Validacao standalone de Edge Functions pode usar `npx deno`. Validacao de runtime Supabase depende de Docker e Supabase CLI no ambiente local.
