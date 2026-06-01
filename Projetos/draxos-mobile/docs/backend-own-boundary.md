# DraxosMobile - Backend Proprio Boundary Inventory

- Status: `CONTRATO`
- Data: `2026-06-01`
- Escopo: inventario de fronteira para uma futura saida Supabase -> Backend
  Proprio, sem refactor runtime nesta lane.

## Leitura

DraxosMobile continua usando Supabase Auth, Postgres, Edge Functions e Storage
no Internal Alpha. O caminho longo preferido e Backend Proprio + Postgres, mas
esta lane nao troca runtime, nao altera endpoints e nao migra dados.

Este documento lista o que precisa ser preservado quando a fronteira sair de
Supabase Edge Functions para um backend proprio.

## Regras De Fronteira

- Cliente Godot nunca recebe service role, senha de banco, senha de keystore ou
  token privado.
- Mutacoes economicas, sociais, mode sessions e admin ops continuam
  server-authoritative.
- `account_profiles` + `game_saves` seguem como autoridade de conta/save.
- `players.save_type` fica apenas como compatibilidade alpha.
- Idempotencia v1 (`request_id`, `request_hash`, `scope_id`) precisa sobreviver
  sem mudanca semantica.
- Registry/ruleset versionado segue a fronteira de conteudo operacional.
- Release manifest/config/download continuam read-only para o cliente, exceto
  download assinado pelo backend.

## Inventario Atual

| Area | Supabase atual | Boundary Backend Proprio | Observacao |
|---|---|---|---|
| Auth | Supabase Auth JWT | Verificador JWT/session proprio ou gateway compativel | Preservar `auth_user_id` e migracao guest/registered. |
| Conta/save | `account_profiles`, `game_saves`, `players` compat | API account/save + Postgres | Novo trabalho nao deve depender de `players.save_type`. |
| Battle/Arena | Edge `battle`, `arena` + RPCs transacionais | Servico battle/arena server-authoritative | Replays/logs e rewards precisam continuar deterministas/auditaveis. |
| Modes | Edge `modes`, `mode_registry`, `mode_sessions`, `mode_reward_claims` | Servico modes + jobs de sessao | `session_start/complete/abandon`, analytics e admin ops devem manter schema. |
| Reward Bridge | RPC/service role, `mode_reward_claims`, `resource_transactions` | Servico reward ledger | Nunca aplicar reward pelo cliente. |
| Admin audit | `admin_audit_log`, RPCs admin service-role-only | Trilha auditavel append-only | CLI read-only nao usa service role; endpoint futuro deve ser explicitamente read-only. |
| Ruleset/content | `ruleset_registry`, generated catalogs, JSON definitions | Publicacao versionada de rulesets | Conteudo continua data-driven, com hash e versao. |
| Release | Edge `release`, manifest override env, Storage, Cloudflare Pages | Release service + object storage/CDN | Manifest deve preservar hashes, URLs e guardrails de save reset/version code. |
| Labs | Edge `lab-runner` para Web, local Deno para PC/editor | Job runner isolado | Sem service role no browser; labs remotos devem continuar atras de conta alpha. |
| Telemetria | Edge `telemetry` + tabelas/eventos | Event ingest + warehouse futuro | Manter dimensoes de modo e erro sem expor PII desnecessaria. |

## Contratos Que Devem Ser Portados Primeiro

1. Auth/JWT e account/save.
2. Idempotencia transacional.
3. Resource ledger/reward claims.
4. Arena PVE e battle result application.
5. Mode registry/sessions/reward bridge.
6. Release manifest/download.
7. Admin audit e ops read-only.

## Fora Do Escopo Desta Lane

- Refactor de Edge Functions.
- Nova API Backend Proprio.
- Migracao de banco.
- Troca de Supabase Auth.
- Jobs, filas, workers ou observabilidade nova.
- Mudancas de client runtime, tuning, economia ou conteudo.

## Sinais De Prontidao Para Refactor Futuro

- Todos os endpoints mutantes documentados com idempotencia e payload canonico.
- Smokes read-only separados de smokes mutantes.
- Admin audit possui endpoint proprio read-only, sem service role no operador.
- Release manifest e artifact storage desacoplados de variaveis de Edge Function.
- Testes conseguem rodar contra backend local compativel sem Supabase CLI como
  unica opcao.
