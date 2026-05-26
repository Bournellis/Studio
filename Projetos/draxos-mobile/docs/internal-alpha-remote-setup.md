# DraxosMobile - Internal Alpha Remote Setup

- Ultima atualizacao: `2026-05-26`
- Track: `T03-P02 - Supabase Remoto E Configuracao Segura`
- Status: `repo-ready, remote project pending`

Este runbook deixa a Internal Alpha v0 preparada para usar Supabase remoto sem colocar secrets no cliente. O projeto remoto ainda precisa ser criado manualmente na conta Supabase antes do smoke real.

## Decisao

- Usar Supabase remoto Free para acelerar a Internal Alpha v0.
- Manter o cliente Godot apontando para endpoints logicos de jogo.
- Preservar Backend Proprio + Postgres como plano de saida.
- Manter Nakama apenas como alternativa futura se realtime/lobbies/matchmaking ativo virarem pilar.

## O Que Ja Esta No Repo

- `online/backend_config.gd` centraliza ambiente, URL e publishable key.
- `online/supabase_client.gd` consome `BackendConfig` e bloqueia cliente mal configurado.
- `project.godot` fica em ambiente `local` por padrao.
- `.env.internal-alpha.example` documenta as variaveis seguras.
- `.gitignore` ignora `.env` reais em projetos.
- `server/tests/internal_alpha_remote_smoke.ts` valida remoto sem service role.

## Variaveis Do Cliente

Estas variaveis podem ser usadas no editor ou em execucao local:

```powershell
$env:DRAXOS_MOBILE_BACKEND_ENV='internal_alpha_v0'
$env:DRAXOS_MOBILE_SUPABASE_URL='https://<project-ref>.supabase.co'
$env:DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY='sb_publishable_<public-key>'
```

Equivalentes em `project.godot`, apenas com valores publicos:

- `draxos_mobile/backend/environment`
- `draxos_mobile/internal_alpha/supabase_url`
- `draxos_mobile/internal_alpha/publishable_key`

Nunca usar `SUPABASE_SERVICE_ROLE_KEY` no Godot, no Web export, no APK, no zip PC ou em configuracao de cliente.

## Passos Manuais Do Projeto Remoto

Quando houver acesso a conta Supabase:

1. Criar um projeto Supabase Free para `draxos-mobile-internal-alpha-v0`.
2. Desativar email confirmation no projeto alpha.
3. Copiar `Project URL`.
4. Copiar a public/publishable key do cliente.
5. Guardar `service_role` somente no gerenciador de secrets/local terminal.
6. Aplicar migrations e Edge Functions a partir de `supabase/`.
7. Rodar o smoke remoto abaixo.
8. Preencher os valores publicos em ambiente local ou export settings.

## Smoke Remoto

```powershell
cd D:\Estudio\Projetos\draxos-mobile
$env:SUPABASE_URL='https://<project-ref>.supabase.co'
$env:SUPABASE_PUBLISHABLE_KEY='sb_publishable_<public-key>'
npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts
```

Opcionalmente, para testar Auth anonimo remoto:

```powershell
$env:DRAXOS_REMOTE_ANON_AUTH_SMOKE='1'
npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts
```

Opcionalmente, depois de migrations, functions e convite alpha aplicados:

```powershell
$env:DRAXOS_REMOTE_ACCOUNT_SMOKE='1'
$env:DRAXOS_REMOTE_INVITE_CODE='ALPHA-TEST'
npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts
```

O smoke rejeita `localhost`/`127.0.0.1` para evitar confundir remoto com runtime local.

## Deploy E Secrets

`SUPABASE_SERVICE_ROLE_KEY` e necessario para deploy, seeders, resets controlados e alguns smokes server-side. Ele deve existir somente no terminal/CI seguro.

Regras:

- Nunca commitar `.env` real.
- Nunca colocar service role em `project.godot`.
- Nunca expor service role em export presets.
- Nunca usar service role em codigo Godot.
- Publishable key e publica, mas RLS, auth, alpha flag e Edge Functions continuam obrigatorios.

## Reset Controlado

No alpha interno, reset destrutivo pode ser aceitavel, mas precisa ser explicito:

- avisar no release notes;
- preservar a possibilidade de reset separado entre `normal` e `progression_lab`;
- registrar a versao que invalidou saves;
- confirmar que o segundo testador esta ciente antes de apagar dados remotos.

## Updates

Supabase Storage pode hospedar manifest e artefatos pequenos, mas o limite do plano Free pode nao ser ideal para todos os builds. Para a Internal Alpha v0:

- manifest pode viver no Supabase;
- links podem apontar para storage externo se os artefatos ficarem grandes;
- o cliente deve depender do schema do manifest, nao do fornecedor de storage.

## Checklist Antes De T03-P03

- Projeto remoto criado.
- URL e publishable key publicas configuradas localmente.
- Service role guardada fora do Git.
- Migrations aplicadas em remoto.
- `healthcheck` remoto verde.
- Email confirmation desligado.
- Politica de alpha gate definida para email/senha.
- Smoke remoto verde.
