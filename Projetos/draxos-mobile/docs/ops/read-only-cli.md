# DraxosMobile - Ops Read-Only CLI

- Status: `RUNBOOK`
- Data: `2026-06-01`
- Escopo: consulta operacional local/remota sem service role, sem mutation e sem publicacao.

## Objetivo

`tools/ops_readonly.ts` gera sumarios read-only para release manifest, modos,
status de modo, auditoria, rewards e sessoes. A CLI existe para release-ops e
suporte interno conseguirem olhar o estado publicado sem usar service role remoto
e sem chamar rotas mutantes.

## Guardrails

- Usa somente `GET`.
- Recusa `sb_secret_`, `sb_service_`, JWT com role `service_role` e valores que
  contenham `service_role`.
- Nao chama `/modes/admin/*` mutante, `publish_internal_alpha.ps1`,
  Supabase CLI, Wrangler, Storage upload ou secrets.
- `manifest` pode rodar apenas com URL + publishable key.
- `modes`, `status`, `audit`, `rewards` e `sessions` exigem JWT de usuario
  Supabase em `DRAXOS_OPS_ACCESS_TOKEN`; esse JWT pode ser admin humano, mas
  nunca service role.
- `audit` tenta leitura REST de `admin_audit_log` com o mesmo JWT. Se RLS
  bloquear, o resultado correto e `blocked_or_empty`; nao escalar para service
  role remoto nesta CLI.

## Variaveis

```powershell
$env:SUPABASE_URL = "https://<project-ref>.supabase.co"
$env:SUPABASE_PUBLISHABLE_KEY = "sb_publishable_<public-key>"
$env:DRAXOS_OPS_ACCESS_TOKEN = "<supabase-user-jwt>"
$env:DRAXOS_OPS_SAVE_TYPE = "normal"
```

Alternativas aceitas:

- `DRAXOS_MOBILE_SUPABASE_URL`
- `DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY`
- `DRAXOS_MOBILE_OPS_ACCESS_TOKEN`
- `DRAXOS_OPS_MODE_ID`
- `DRAXOS_OPS_TARGET`
- `DRAXOS_OPS_LIMIT`
- `DRAXOS_OPS_FORMAT`

## Comandos

Manifest remoto publicado:

```powershell
npx -y deno run --allow-net --allow-env tools/ops_readonly.ts --target manifest --format pretty
```

Pacote completo de leitura operacional:

```powershell
npx -y deno run --allow-net --allow-env tools/ops_readonly.ts --target all --mode-id openworld --save-type normal --format json
```

Somente sessoes e rewards de um modo:

```powershell
npx -y deno run --allow-net --allow-env tools/ops_readonly.ts --target sessions,rewards --mode-id openworld --limit 20
```

Auditoria sem service role:

```powershell
npx -y deno run --allow-net --allow-env tools/ops_readonly.ts --target audit --limit 20
```

Se `audit.status` voltar `blocked_or_empty`, isso indica que a leitura direta
esta protegida por RLS ou nao retornou linhas para o JWT usado. Nao e erro de
release; e a fronteira segura esperada ate existir endpoint proprio read-only
auditado para ops.

## Targets

| Target | Origem | Credencial | Mutacao |
|---|---|---|---:|
| `manifest` | `GET /functions/v1/release/manifest` | publishable key | Nao |
| `modes` | `GET /functions/v1/modes/registry` | publishable key + user JWT | Nao |
| `status` | `GET /functions/v1/modes/state?mode_id=<id>` | publishable key + user JWT | Nao |
| `sessions` | mesmo payload de `state` | publishable key + user JWT | Nao |
| `rewards` | mesmo payload de `state` | publishable key + user JWT | Nao |
| `audit` | `GET /functions/v1/modes/admin/me` + `GET /rest/v1/admin_audit_log` | publishable key + user JWT | Nao |

## Validacao

```powershell
npx -y deno check tools/ops_readonly.ts server/tests/ops_readonly_cli_test.ts
npx -y deno test --allow-read server/tests/ops_readonly_cli_test.ts
```

O teste usa `fetch` mockado, prova que todos os requests sao `GET` e confirma
que a CLI recusa credenciais service-role-like.
