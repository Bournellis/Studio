# DraxosMobile - Internal Alpha Release Plan

- Ultima atualizacao: `2026-05-27`
- Fase: `T03-P12+ - Internal Alpha Release Candidate`
- Objetivo: soltar Android, PC e Web juntos para Fabio + 1 tester, usando Supabase remoto real, conta email/senha, portal unlisted e manifest de update.

## Decisoes Travadas

| Area | Decisao |
|---|---|
| Android | APK direto por link, fora da Play Store nesta alpha |
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

Status: `NEXT`.

Saida esperada:

- tela de login/cadastro com email + senha;
- logout e recuperacao de sessao;
- backend deixa de depender apenas de Auth anonimo para o fluxo real;
- criacao/carregamento dos dois saves por conta email/senha;
- guest fica apenas como ferramenta dev/local, se ainda for util.

### T03-P15 - Release Config E Manifest

Status: `PENDING_IMPLEMENTATION`.

Saida esperada:

- versao `internal_alpha_v0` definida em build metadata;
- ambiente `internal_alpha_v0` apontando para Supabase remoto;
- manifest remoto com `latest_version`, `minimum_supported_version`, links e notas;
- cliente mostra update recomendado/obrigatorio.

### T03-P16 - Export Das Tres Builds

Status: `PENDING_REMOTE_AND_AUTH`.

Saida esperada:

- `build/android/draxos-mobile-alpha.apk`;
- `build/pc/draxos-mobile-alpha.zip`;
- `build/web/` com export Web;
- hashes SHA256 registrados para APK e PC ZIP;
- presets continuam excluindo ferramentas dev e scratch.

### T03-P17 - Publicacao Unlisted E QA Remoto Fechado

Status: `PENDING_ARTIFACTS`.

Saida esperada:

- portal publicado em URL unlisted;
- Web build publicada;
- APK e PC ZIP disponiveis por link;
- manifest publicado e referenciado pelo portal.
- Fabio e tester validam pelo menos duas plataformas cada;
- login, save cross-platform, batalha, base, loja, social, ranking, Lab e update notice passam;
- bugs viram backlog curto antes de nova release.

### T03-P18 - Handoff Da Internal Alpha v0

Status: `PENDING_REMOTE_QA`.

Saida esperada:

- release notes e manifest finais atualizados;
- bugs conhecidos registrados;
- pacote de links finais pronto para Fabio + 1 tester;
- portal segue suficiente por enquanto e pode ser refinado por Fabio depois desta etapa.

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
