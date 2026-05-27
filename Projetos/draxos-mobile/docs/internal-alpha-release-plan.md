# DraxosMobile - Internal Alpha Release Plan

- Ultima atualizacao: `2026-05-27`
- Fase: `T03-P12+ - Internal Alpha Release Candidate`
- Objetivo: soltar Android, PC e Web juntos para Fabio + 1 tester, usando Supabase remoto real, conta email/senha, portal unlisted e manifest de update.

## Decisoes Travadas

| Area | Decisao |
|---|---|
| Android | APK direto por link, fora da Play Store nesta alpha; T03-P16 gerou APK `debug_fallback` enquanto a keystore release dedicada nao estiver configurada |
| PC | ZIP direto por link |
| Web | Build Web em URL unlisted |
| Portal | Site unlisted simples com downloads, changelog, instrucoes e link Web |
| Conta | Email + senha |
| Save | Dois saves por conta: `normal` e `progression_lab` |
| Updates | Manifest remoto mostra update e link de download; sem auto-update silencioso por enquanto |
| Backend | Supabase remoto Free para alpha; Backend Proprio + Postgres segue como plano de saida |
| Seguranca | `service_role`/secret key nunca entra no cliente, portal, APK, ZIP, Web build ou Git |

## Escopo Da Fase

Esta fase transforma o jogo local green em uma release interna fechada. Ela nao busca acabamento visual final. O criterio e:

- o tester consegue receber um link;
- baixar APK ou PC ZIP;
- abrir o jogo Web pelo portal;
- criar/login com email e senha;
- usar o mesmo save entre plataformas;
- testar Batalha, Base, Loja, Competicao, Social e Progression Lab;
- receber aviso claro quando houver update.

## Etapas

### T03-P12 - Alpha Release Portal

Status: `BASE_COMPLETE`.

Saida:

- portal estatico criado em `portal/internal-alpha/`;
- `README.md` do portal com como editar/publicar;
- `manifest.example.json` com schema inicial de update;
- este plano documentado.

O portal final pode ser refinado depois de `T03-P18`. Por enquanto ele existe para carregar links, notas e instrucoes.

### T03-P13 - Supabase Remoto Real

Status: `COMPLETE`.

Saida esperada:

- projeto remoto linkado pela Supabase CLI;
- migrations aplicadas com `supabase db push`;
- Edge Functions publicadas;
- `healthcheck` remoto verde;
- smoke remoto verde.

Depende de Fabio:

- confirmar `Project URL`;
- confirmar `Project ref`;
- copiar publishable/anon public key;
- fazer login ou liberar token da Supabase CLI localmente;
- confirmar que email confirmation esta desligado.

Resultado em 2026-05-27:

- projeto remoto linkado: `armxgipvnbbshzqawklw`;
- migrations aplicadas;
- Edge Functions publicadas;
- smoke remoto minimo passou contra `https://armxgipvnbbshzqawklw.supabase.co`.

### T03-P14 - Auth Email/Senha No Godot E Backend

Status: `COMPLETE`.

Saida esperada:

- tela de login/cadastro com email + senha;
- logout e recuperacao de sessao;
- backend deixa de depender apenas de Auth anonimo para o fluxo real;
- criacao/carregamento dos dois saves por conta email/senha;
- guest fica apenas como ferramenta dev/local, se ainda for util.

Resultado em 2026-05-27:

- Hub do Godot recebeu cadastro/login por email/senha, username e convite.
- Backend recebeu `/account/bootstrap` e RPC `create_alpha_account`.
- Auth remoto foi alinhado com confirmacao de email desligada.
- Smokes local/remoto validaram email/senha, save normal, save `progression_lab` e login posterior.

### T03-P15 - Release Config E Manifest

Status: `COMPLETE`.

Saida:

- build metadata definida no `ProjectInfo`: canal `internal_alpha`, versao `0.0.1-alpha.0`, version code `1` e schema `internal_alpha_manifest_v1`;
- `BackendConfig` e `SupabaseClient` resolvem `DRAXOS_MOBILE_UPDATE_MANIFEST_URL` e usam `<supabase_url>/functions/v1/release/manifest` como padrao;
- Edge Function publica `GET /release/manifest` implementada/local/remota, com manifest default versionado e override operacional opcional por `RELEASE_MANIFEST_JSON_BASE64` ou `RELEASE_MANIFEST_JSON` quando `RELEASE_MANIFEST_OVERRIDE_ENABLED=1`;
- Hub do Godot mostra status de update no boot, permite checar manualmente e bloqueia acoes online quando `minimum_supported_version_code` exige;
- manifest exemplo do portal atualizado com version codes, portal URL e placeholders de artefatos para `T03-P17`;
- smokes local/remoto validam o contrato do manifest.

### T03-P16 - Export Das Tres Builds

Status: `COMPLETE - LOCAL_ARTIFACTS_GREEN`.

Saida entregue em 2026-05-27:

- `build/android/draxos-mobile-alpha.apk`;
- `build/pc/draxos-mobile-alpha.zip`;
- `build/web/` com export Web;
- hashes SHA256 registrados em `docs/internal-alpha-v0-export-report.md`;
- metadata local em `build/internal-alpha/release-artifacts.json`;
- presets excluem ferramentas dev, docs, servidor, portal, scratch e `build/**`;
- Android export corrigido com ETC2/ASTC, icone placeholder e permissoes de rede.

Observacao Android: como nenhuma keystore release foi configurada em ambiente local, o script usou `-AllowAndroidDebugFallback` e gerou APK debug-signed. Para release-signed, configurar `DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PATH`, `DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_USER` e `DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PASSWORD` no arquivo local ignorado `.env.internal-alpha.local`.

### T03-P17 - Publicacao Unlisted E QA Remoto Fechado

Status: `COMPLETE - SIGNOFF_APPROVED`.

Saida entregue em 2026-05-27:

- APK e PC ZIP publicados em URL unlisted via Supabase Storage;
- Portal/Web publicados no Cloudflare Pages em `https://draxos-mobile-internal-alpha.pages.dev`;
- APK e PC ZIP disponiveis por link publico unlisted;
- manifest remoto reconfigurado com hashes finais de Android/PC e links finais de Portal/Web;
- QA remoto automatizado verde para release manifest, email/senha, dois saves, batalha, base, loja, social, competicao e telemetria;
- Fabio aprovou avancar para `T03-P18` em 2026-05-27; feedback posterior do tester entra como bug conhecido/handoff.

Correcao pos-publicacao: links diretos de Storage para HTML/Web nao devem ser usados como link final, porque a Supabase retorna HTML como `text/plain` com CSP sandbox. Edge Functions tambem nao servem HTML como pagina. O caminho correto e publicar `build/internal-alpha/publish/` em host estatico externo e depois rodar `publish_internal_alpha.ps1 -StaticSiteBaseUrl <url> -SkipUpload -UseManifestSecret`.

Correcao Cloudflare Pages: nao publicar `build/internal-alpha/publish/` inteira no Cloudflare, porque `web/index.wasm` ultrapassa o limite por arquivo do Pages. Gerar o pacote hibrido com `tools/build_cloudflare_pages_package.ps1` e publicar `build/internal-alpha/cloudflare-pages/` ou `build/internal-alpha/draxos-mobile-cloudflare-pages.zip`; esse pacote serve Portal/Web HTML pelo Cloudflare e continua buscando assets grandes no Supabase Storage. O deployment final validado usa o dominio estavel `https://draxos-mobile-internal-alpha.pages.dev`.

### T03-P18 - Handoff Da Internal Alpha v0

Status: `COMPLETE`.

Saida esperada:

- release notes e manifest finais atualizados;
- bugs conhecidos registrados;
- pacote de links finais pronto para Fabio + 1 tester;
- portal segue suficiente por enquanto e pode ser refinado por Fabio depois desta etapa.

Saida entregue em 2026-05-27:

- handoff final em `internal-alpha-v0-handoff.md`;
- portal source e manifest exemplo com links reais;
- defaults de `release/manifest` com hashes finais e texto pos-signoff;
- instrucoes de update e riscos conhecidos registrados.

## Valores Que Fabio Deve Enviar Ao Codex

Pode enviar:

- `SUPABASE_PROJECT_REF`;
- `SUPABASE_URL`;
- `SUPABASE_PUBLISHABLE_KEY` ou legacy `anon` public key;
- URL escolhida para portal Web, quando existir;
- URL escolhida para APK/PC ZIP, quando existir.

Nao enviar por chat se puder evitar:

- `SUPABASE_SERVICE_ROLE_KEY`;
- `sb_secret_...`;
- senha do banco;
- senha da keystore Android;
- senha de contas pessoais.

Forma preferida para secrets:

1. Fabio cria um arquivo local ignorado, por exemplo `D:\Estudio\Projetos\draxos-mobile\.env.internal-alpha.local`.
2. Fabio coloca secrets ali.
3. Fabio avisa o Codex que o arquivo existe.
4. O Codex usa o arquivo apenas para comandos locais/deploy, sem commitar.

## Gates De Release

Checklist operacional Track 05: `release-ops-checklist.md`.

Antes de publicar:

- `git status --short` limpo;
- `tools/validate.gd` verde;
- smokes Supabase remoto verdes;
- cliente exportado com `internal_alpha_v0`;
- `service_role` ausente de `project.godot`, export presets, portal, APK, ZIP e Web export;
- portal com aviso de alpha fechado;
- tester sabe que saves podem ser resetados.

## Referencias

- Setup remoto detalhado: `internal-alpha-remote-setup.md`
- Tutorial Supabase para Fabio: `supabase-remote-tutorial.md`
- Portal base: `../portal/internal-alpha/`
- Checklist QA: `playtest-internal-alpha-v0.md`
- Handoff final: `internal-alpha-v0-handoff.md`
