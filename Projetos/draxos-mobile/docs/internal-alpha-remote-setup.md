# DraxosMobile - Internal Alpha Remote Setup

- Ultima atualizacao: `2026-05-27`
- Track: `T03-P14 - Auth Email/Senha E Alpha Gate`
- Status: `auth email/senha remote green, update manifest pending`

Este runbook deixa a Internal Alpha v0 preparada para usar Supabase remoto sem colocar secrets no cliente. O projeto remoto ja foi linkado pela CLI, recebeu migrations/Edge Functions, recebeu config de Auth email/senha sem confirmacao obrigatoria e passou nos smokes remotos de healthcheck, Auth anonimo dev e email/senha com dois saves.

Tutorial detalhado para Fabio: `supabase-remote-tutorial.md`.

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
- `server/tests/internal_alpha_remote_smoke.ts` valida remoto sem service role, incluindo flags para Auth anonimo dev, account guest dev e email/senha alpha.
- `server/tests/email_auth_alpha_smoke.ts` valida localmente signup/login email/senha e `/account/bootstrap`.
- `docs/supabase-remote-tutorial.md` descreve a configuracao manual, os comandos e exatamente quais valores enviar.
- `portal/internal-alpha/` contem a base do portal unlisted para distribuir Web/APK/PC quando as builds forem exportadas.

## Projeto Remoto Observado

- Organizacao: `Bournellis's Org`.
- Projeto: `Bournellis's Project`.
- Branch/environment: `main` / `PRODUCTION`.
- Project ref: `armxgipvnbbshzqawklw`.
- Project URL: `https://armxgipvnbbshzqawklw.supabase.co`.
- Regiao: `West US (Oregon)`.
- Status no dashboard: `Healthy`.

Estado operacional: o dashboard mostrou o projeto saudavel e, em 2026-05-27, o bootstrap remoto aplicou as migrations, publicou as Edge Functions, atualizou config de Auth e validou o fluxo email/senha. Para a build, o backend remoto esta pronto para a etapa de manifest de updates.

## Resultado T03-P13

- `supabase link --project-ref armxgipvnbbshzqawklw`: concluido.
- `supabase db push`: concluiu e aplicou as 10 migrations locais no remoto.
- `supabase functions deploy healthcheck account battle base social competition monetization telemetry progression-lab`: concluiu.
- `server/tests/internal_alpha_remote_smoke.ts`: passou com `healthcheck: true`.
- `supabase migration list`: confirmou migrations locais/remotas alinhadas.
- Smokes de Auth/account remotos foram fechados em `T03-P14`.

## Resultado T03-P14

- `202605270001_alpha_email_account.sql` aplicada local/remoto.
- `account` Edge Function publicada novamente com `/account/bootstrap`.
- `supabase config push --yes` aplicou Auth remoto com `enable_confirmations = false` e Auth anonimo dev habilitado.
- `.env.internal-alpha.local` local foi corrigido com a publishable key publica atual; o arquivo segue ignorado pelo Git.
- `server/tests/email_auth_alpha_smoke.ts`: passou localmente com signup/login, save normal e save `progression_lab`.
- `server/tests/internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_EMAIL_AUTH_SMOKE=1`: passou em remoto com email/senha e os dois saves.
- `server/tests/internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_ANON_AUTH_SMOKE=1`: passou em remoto para fallback dev anonimo.

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

Para executar `T03-P13`:

1. Confirmar que o projeto remoto correto e `armxgipvnbbshzqawklw`.
2. Desativar email confirmation no projeto alpha.
3. Copiar `Project URL`.
4. Copiar a public/publishable key do cliente.
5. Criar `.env.internal-alpha.local` usando `.env.internal-alpha.example`.
6. Guardar `service_role` somente no gerenciador de secrets/local terminal.
7. Fazer login/link da Supabase CLI.
8. Aplicar migrations e Edge Functions a partir de `supabase/`.
9. Rodar o smoke remoto abaixo.
10. Preencher os valores publicos em ambiente local ou export settings.

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

Opcionalmente, para testar email/senha e os dois saves remotos:

```powershell
$env:DRAXOS_REMOTE_EMAIL_AUTH_SMOKE='1'
npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts
```

Opcionalmente, para testar account guest temporario/dev:

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

## Checklist Antes De T03-P15

- Projeto remoto confirmado.
- URL e publishable key publicas configuradas localmente.
- Service role guardada fora do Git.
- Supabase CLI logada e linkada ao projeto remoto.
- Migrations aplicadas em remoto.
- Edge Functions publicadas em remoto.
- `healthcheck` remoto verde.
- Email confirmation desligado via config remoto.
- Politica de alpha gate definida para email/senha: convite + username no primeiro save.
- Fluxo email/senha implementado no cliente/backend.
- Proximo: manifest remoto de updates e version gate.
