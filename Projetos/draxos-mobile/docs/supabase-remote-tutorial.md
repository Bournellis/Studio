# DraxosMobile - Tutorial Supabase Remoto

- Ultima atualizacao: `2026-05-27`
- Alvo: preparar o projeto Supabase remoto para `internal_alpha_v0`.
- Ponto de partida: screenshot enviada em 2026-05-26 com projeto Supabase novo, status `Healthy`.
- Estado atual: projeto `armxgipvnbbshzqawklw` linkado, migrations/functions publicadas, Auth email/senha configurado sem confirmacao obrigatoria, manifest remoto de updates publicado e smokes remotos verdes.

## O Que Ja Da Para Identificar Pela Screenshot

| Campo | Valor observado |
|---|---|
| Organizacao | `Bournellis's Org` |
| Projeto | `Bournellis's Project` |
| URL do projeto | `https://armxgipvnbbshzqawklw.supabase.co` |
| Project ref provavel | `armxgipvnbbshzqawklw` |
| Branch | `main` |
| Ambiente | `PRODUCTION` |
| Regiao | `West US (Oregon)` |
| Status | `Healthy` |

Confirme estes valores no dashboard antes de executar deploy.

## Regra De Seguranca

Pode mandar para o Codex:

- Project URL;
- Project ref;
- publishable key `sb_publishable_...`;
- legacy `anon` public key, se o dashboard ainda mostrar esta chave.

Nao mande em chat, email ou documento publico:

- `service_role`;
- `sb_secret_...`;
- senha do banco;
- token de acesso Supabase;
- senha de keystore.

O cliente Godot, APK, PC ZIP, Web build e portal so podem conter chave publica. A chave publica nao e segredo, mas RLS, Auth e Edge Functions continuam obrigatorios.

## Passo 1 - Confirmar URL E Project Ref

1. No dashboard do Supabase, mantenha o projeto aberto.
2. Na tela principal, copie a URL exibida abaixo do nome do projeto.
3. Para este projeto, a URL vista na screenshot e:

```text
https://armxgipvnbbshzqawklw.supabase.co
```

4. O trecho antes de `.supabase.co` e o `project ref`:

```text
armxgipvnbbshzqawklw
```

5. Envie ao Codex:

```text
SUPABASE_PROJECT_REF=armxgipvnbbshzqawklw
SUPABASE_URL=https://armxgipvnbbshzqawklw.supabase.co
```

## Passo 2 - Copiar A Chave Publica

Pela UI atual do Supabase, existem dois caminhos comuns:

### Caminho A - Connect

1. Clique no botao verde `Connect` no topo da tela.
2. Escolha um modo de conexao de app/framework.
3. Copie a chave publica/publishable key exibida para cliente.
4. Ela normalmente comeca com `sb_publishable_`.

### Caminho B - API Keys

1. Na barra lateral esquerda, clique no icone de engrenagem `Project Settings`.
2. Abra `API Keys`.
3. Copie a `Publishable key`.
4. Se o dashboard mostrar apenas chaves legacy, copie a `anon public`.

Envie ao Codex apenas:

```text
SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
```

ou, se for legacy:

```text
SUPABASE_PUBLISHABLE_KEY=<anon-public-jwt>
```

Se o Supabase mostrar a chave com nome de framework, como `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, copie apenas o valor e use nos nomes do DraxosMobile: `DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY` e `SUPABASE_PUBLISHABLE_KEY`.

Nunca envie a `service_role` para o cliente. Se ela for necessaria para um comando de deploy, use arquivo local ignorado.

## Passo 3 - Desligar Confirmacao De Email

Para esta alpha fechada vamos usar email/senha sem obrigar confirmacao de email.

1. Na barra lateral esquerda, abra `Authentication`.
2. Entre em `Sign In / Providers` ou `Providers`.
3. Abra o provider `Email`.
4. Confirme que email/password esta habilitado.
5. Desligue `Confirm email`.
6. Salve.

Se a UI estiver diferente, procure em `Authentication` por `Providers`, `Email`, `Confirm email` ou `Email confirmations`.

Observacao: a documentacao oficial indica que, com `Confirm Email` desligado, o email e considerado confirmado para login. Isso e adequado para a alpha interna, mas nao e recomendacao automatica para producao publica.

Resultado real em 2026-05-27: alem do ajuste manual, `npx -y supabase config push --yes` foi usado para alinhar o Auth remoto ao `supabase/config.toml` local, com `enable_confirmations = false`.

## Passo 4 - Criar Arquivo Local Ignorado

Crie este arquivo local:

```text
D:\Estudio\Projetos\draxos-mobile\.env.internal-alpha.local
```

Conteudo sugerido:

```dotenv
DRAXOS_MOBILE_BACKEND_ENV=internal_alpha_v0
DRAXOS_MOBILE_SUPABASE_URL=https://armxgipvnbbshzqawklw.supabase.co
DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_COLE_AQUI

SUPABASE_PROJECT_REF=armxgipvnbbshzqawklw
SUPABASE_URL=https://armxgipvnbbshzqawklw.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_COLE_AQUI

# Use somente se for executar comandos administrativos localmente.
# Nao commitar e nao colocar no cliente.
SUPABASE_SERVICE_ROLE_KEY=COLE_AQUI_APENAS_SE_NECESSARIO
```

Este arquivo e ignorado pelo Git por regra da raiz do workspace.

## Passo 5 - Login Da Supabase CLI

Opcao recomendada:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y supabase login
```

O comando abre o fluxo de login da Supabase CLI. Depois disso, a CLI consegue listar/linkar projetos.

Opcao alternativa:

1. No dashboard/conta Supabase, crie um access token pessoal.
2. No PowerShell local:

```powershell
$env:SUPABASE_ACCESS_TOKEN='COLE_TOKEN_AQUI'
```

Nao commitar o token.

## Passo 6 - Linkar O Projeto Remoto

Depois do login:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y supabase projects list
npx -y supabase link --project-ref armxgipvnbbshzqawklw
```

Se a CLI pedir senha do banco e voce nao lembrar:

1. No dashboard Supabase, abra `Project Settings`.
2. Abra `Database`.
3. Procure a opcao de reset/alteracao da database password.
4. Guarde a senha fora do Git.

## Passo 7 - Aplicar Migrations

Quando o Codex iniciar `T03-P13`, o comando esperado sera:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y supabase db push
```

Este comando aplica as migrations de `supabase/migrations/` no projeto remoto linkado.

Nao execute em projeto errado. Antes, confirme:

```powershell
npx -y supabase status
```

ou veja se o link aponta para `armxgipvnbbshzqawklw`.

## Passo 8 - Publicar Edge Functions

Depois das migrations, o comando esperado sera:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y supabase functions deploy
```

Se precisarmos publicar individualmente:

```powershell
npx -y supabase functions deploy healthcheck
npx -y supabase functions deploy account
npx -y supabase functions deploy battle
npx -y supabase functions deploy base
npx -y supabase functions deploy social
npx -y supabase functions deploy competition
npx -y supabase functions deploy monetization
npx -y supabase functions deploy telemetry
npx -y supabase functions deploy progression-lab
npx -y supabase functions deploy release
```

A configuracao de `verify_jwt` vive em `supabase/config.toml`.

## Passo 9 - Smoke Remoto Minimo

Sem conta:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
$env:SUPABASE_URL='https://armxgipvnbbshzqawklw.supabase.co'
$env:SUPABASE_PUBLISHABLE_KEY='sb_publishable_COLE_AQUI'
npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts
```

Com Auth anonimo temporario/dev:

```powershell
$env:DRAXOS_REMOTE_ANON_AUTH_SMOKE='1'
npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts
```

Com account guest temporario/dev:

```powershell
$env:DRAXOS_REMOTE_ACCOUNT_SMOKE='1'
$env:DRAXOS_REMOTE_INVITE_CODE='ALPHA-TEST'
npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts
```

Com email/senha real da Internal Alpha v0:

```powershell
$env:DRAXOS_REMOTE_EMAIL_AUTH_SMOKE='1'
npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts
```

Com manifest remoto de updates:

```powershell
$env:DRAXOS_REMOTE_RELEASE_SMOKE='1'
npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts
```

Observacao: o fluxo final agora e email/senha. Os smokes guest continuam existindo como fallback dev/local.

## Passo 10 - O Que Enviar Para O Codex Agora

Envie uma mensagem com:

```text
SUPABASE_PROJECT_REF=armxgipvnbbshzqawklw
SUPABASE_URL=https://armxgipvnbbshzqawklw.supabase.co
SUPABASE_PUBLISHABLE_KEY=<publishable ou anon public>
Email confirmation desligado: sim/nao
Supabase CLI login feito: sim/nao
Arquivo .env.internal-alpha.local criado: sim/nao
```

Se preferir nao colar a chave publica no chat, coloque no arquivo local ignorado e avise:

```text
Valores publicos e secrets foram colocados em .env.internal-alpha.local
```

## Passo 11 - Depois Que O Remoto Estiver Verde

O Codex executa a proxima etapa:

1. `T03-P13`: link/deploy/smoke remoto. **Feito**.
2. `T03-P14`: implementar email/senha no Godot e backend. **Feito**.
3. `T03-P15`: manifest de updates. **Feito**.
4. `T03-P16`: exportar APK, PC ZIP e Web.
5. `T03-P17`: publicar portal/Web/downloads e rodar QA remoto fechado.
6. `T03-P18`: handoff final da Internal Alpha v0.

## Referencias Oficiais Consultadas

- Supabase API keys: https://supabase.com/docs/guides/getting-started/api-keys
- Supabase Edge Function deploy: https://supabase.com/docs/guides/functions/deploy
- Supabase Edge Function environment variables: https://supabase.com/docs/guides/functions/secrets
- Supabase Auth general configuration: https://supabase.com/docs/guides/auth/general-configuration
- Supabase password auth: https://supabase.com/docs/guides/auth/passwords
