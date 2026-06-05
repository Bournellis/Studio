# DraxosMobile - Release Ops Checklist

- Data: `2026-06-01`
- Track: `Track 13 - Foundation Validation And Release Safety` + `Track 17 - Foundation Expansion Readiness` + `Foundation Final Polish` + `Foundation Hardening V2 release-ops-keystore`
- Status: `TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED` / `FOUNDATION_FINAL_POLISH_DELIVERED`
- Escopo: readiness operacional de release para Android, PC e Web, com safety por default e sem publicar build nova.

## Guardrails Track 13

- Nao publicar, redeployar, alterar manifest remoto real ou subir arquivos para Storage por default.
- Nao gerar build final como parte da validacao Track 13.
- Nao tocar em secrets, service role, senha de banco, senha de keystore ou `.env.internal-alpha.local`.
- Usar apenas publishable/client key em smokes remotos.
- Ops CLI remota deve usar `tools/ops_readonly.ts` com publishable key e JWT de usuario; service role remoto e proibido.
- Qualquer check remoto automatico deve ser somente leitura: `GET`, `HEAD` ou auth/smoke explicitamente solicitado.
- `supabase db push`, `supabase functions deploy`, `supabase secrets set`, Wrangler deploy e upload Cloudflare sao comandos de publicacao, nao validacao segura.
- `publish_internal_alpha.ps1` so pode mutar remoto em `Mode Upload`, `Mode DeployManifest` ou `Mode FullPublish` com `-ReleaseRoot` versionado e `-ConfirmRemoteMutation`.
- `validate_foundation.ps1` nao publica: `FullPublish` fica desabilitado no runner e deve orientar o operador a usar `publish_internal_alpha.ps1` diretamente.
- Manifest/config publico nao deve exigir JWT nem carregar segredo. Download privado, se voltar a ser usado, deve exigir JWT verificado pelo backend e nunca expor service role.
- Fonte viva de release e `implementation/current-status.md` + manifest/relatorios atuais; snapshots historicos devem ficar claramente historicos e nao competir com o status vivo.

## Contrato Track 13 De Modos

| Modo | Mutacao remota | Saida | Uso |
|---|---:|---|---|
| `Mode Plan` | Nao | `build/internal-alpha/release-plan.json` e `.md` | Default seguro, revisao local |
| `Mode Package` | Nao; exige `-ReleaseRoot` | `build/internal-alpha/publish/` | Preparar pacote local |
| `Mode Upload` | Sim, exige `-ReleaseRoot` + `-ConfirmRemoteMutation` | Storage Supabase | Upload de artefatos ja aprovados |
| `Mode DeployManifest` | Sim, exige `-ReleaseRoot` + `-ConfirmRemoteMutation` | Manifest override/deploy `release` | Alinhar manifest remoto |
| `Mode FullPublish` | Sim, exige `-ReleaseRoot` + `-ConfirmRemoteMutation` | Upload + manifest/deploy + verificacoes | Publicacao completa aprovada |

Comandos:

```powershell
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Plan
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Package -ReleaseRoot "internal-alpha/v0-<package-slug>-YYYYMMDD-<shortsha>"
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Upload -ReleaseRoot "internal-alpha/v0-<package-slug>-YYYYMMDD-<shortsha>" -ConfirmRemoteMutation
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode DeployManifest -ReleaseRoot "internal-alpha/v0-<package-slug>-YYYYMMDD-<shortsha>" -ConfirmRemoteMutation
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode FullPublish -ReleaseRoot "internal-alpha/v0-<package-slug>-YYYYMMDD-<shortsha>" -ConfirmRemoteMutation
```

Flags antigas (`-SkipUpload`, `-UseManifestSecret`, `-SkipManifestSecret`) sem `-Mode` ficam protegidas: executam apenas `Mode Plan` e emitem aviso. `Mode Package`, `Mode Upload`, `Mode DeployManifest` e `Mode FullPublish` exigem `-ReleaseRoot` fresco e versionado (`internal-alpha/v0-nome-YYYYMMDD-<shortsha>`). `-SkipManifestSecret` e bloqueado para `DeployManifest`/`FullPublish`; deploy normal deve atualizar o secret de override do manifest.

## Default Test Publication Policy

Track 13 itself remains non-publishing by default. After Track 13, user-approved product packages that need human testing on Android, Windows or Web should treat Internal Alpha publication as the default completion step once local validation passes.

- If the user asks to execute a visible package, test it in the published app, or review it in Web/APK/PC, plan export, package, Storage upload and Cloudflare Pages deploy unless the user explicitly says local-only.
- Remote mutation still requires current-task approval plus `-ConfirmRemoteMutation`; never infer approval for schema, Edge Function, migration or secret changes from a client-only publication request.
- Use a fresh versioned release root for every Web-visible package and generate Cloudflare Pages from the same worktree/session that exported and packaged the release.
- Run `build_cloudflare_pages_package.ps1` after Storage upload with `-StaticAssetBaseUrl` pointing at the versioned Web asset root so the script can block stale `GODOT_CONFIG.fileSizes` mismatches.
- The canonical playtest host is the production Pages domain:
  `https://draxos-mobile-internal-alpha.pages.dev`. Do not publish the remote
  manifest with a hash deployment URL as `portal_url` or `artifacts.web.url`.
  `portal_url` must be the root `/`; `artifacts.web.url` must remain the direct
  Web shell path `/web/index.html`. Hash URLs such as
  `https://95f403c5...pages.dev` are evidence/debug links, not the user-facing
  playtest contract.
- Before reporting publication success, verify the deployed `/web/index.html` references the versioned asset root and that the shell `index.pck` size matches the remote `Content-Length`.
- Before reporting Web launch success, run `tools/smoke_web_launch_remote.ps1` against the hash preview returned by Cloudflare Pages. Use `-NoProjectWrites` for read-only validation jobs and `-KeepDiagnostics` when the screenshot/logs must be retained outside the project. If the stable production domain is protected by Cloudflare Access, anonymous Access is expected there and does not replace the preview launch smoke.

## Inventario Atual

| Area | Fonte | Papel | Seguro Em Track 13 |
|---|---|---|---|
| Version gate client | `core/project_info.gd`, `tests/client/test_project_info.gd` | Canal, versao, version code, schema e bloqueio por `minimum_supported_version_code` | Sim, via `validate.gd`/GUT se necessario |
| Manifest contract | `docs/contracts/update-manifest.md` | Payload autoritativo de `GET /release/manifest` | Sim, leitura |
| Manifest function | `server/functions/release/index.ts`, `supabase/functions/release/index.ts` | Manifest default e override operacional por env secret | So check/lint. Deploy e secret sao publicacao |
| Manifest smoke local/remoto | `server/tests/release_manifest_smoke.ts` | Valida schema, canal, version code e metadados Android/PC/Web | Sim, se Supabase alvo estiver configurado |
| Artifact smoke remoto | `server/tests/release_artifacts_remote_smoke.ts` | Valida manifest, downloads APK/ZIP via `HEAD` ou `GET` parcial, Portal e Web HTML existentes | Sim, somente leitura, exige URL e publishable key |
| Export presets | `export_presets.cfg`, `tools/smoke_exports.gd` | Android Alpha, PC Windows Alpha e PC Browser Alpha | Sim |
| Export script | `tools/export_internal_alpha.ps1` | Gera APK, PC ZIP, Web e metadata local | Syntax check seguro. Execucao gera builds, usar so em release real |
| Foundation runner | `tools/validate_foundation.ps1` | Runner unico `DocsOnly`/`ClientQuick`/`ServerQuick`/`ModePlatform`/`DatabaseLocal`/`FullLocal`/`ReleaseDryRun`/`RemoteReadOnly` com relatorio local; aliases antigos preservados; `FullPublish` rejeitado de proposito | Sim |
| Release safety check | `tools/check_release_safety.ps1` | Garante publish default seguro e mutacao protegida por confirmacao | Sim |
| Android release keystore gate | `tools/check_android_release_keystore.ps1` | Verifica tuple local de keystore release, ausencia de senha concreta tracked e fallback conhecido | Sim |
| Ops read-only CLI | `tools/ops_readonly.ts`, `docs/ops/read-only-cli.md` | Sumarios manifest/modes/status/audit/reward/session por `GET`, sem service role remoto | Sim |
| Backend Proprio boundary | `docs/backend-own-boundary.md` | Inventario de fronteira para futura saida Supabase -> Backend Proprio, sem refactor runtime | Sim |
| Track 13 readiness | `tools/check_track13_readiness.ps1` | Garante docs/status/mirrors/Kanban e budgets duros de shell/presenter alinhados | Sim |
| Agent ops readiness | `tools/check_agent_ops_foundation.ps1` | Garante entrada de agentes, indice documental, portfolio/Kanban e terminologia viva | Sim |
| Foundation expansion readiness | `tools/check_foundation_expansion_readiness.ps1` | Garante account/save, ruleset, admin/minigame contracts, migrations espelhadas e testes fundacionais | Sim |
| Foundation admin/RLS live smoke | `server/tests/foundation_admin_rls_live_smoke.ts` | Prova RLS de account/save/ruleset/admin audit e RPCs admin `service_role`-only em Supabase/Edge local | Sim, somente local |
| Publish script | `tools/publish_internal_alpha.ps1` | Planeja/package local por default; publica somente com modo remoto + confirmacao | `Plan`/`Package` sim; modos remotos sao publicacao |
| Cloudflare package | `tools/build_cloudflare_pages_package.ps1` | Gera pacote local hibrido para Pages a partir de publish existente | Seguro se rodar sobre artefatos locais existentes; nao faz deploy |
| Web launch smoke | `tools/smoke_web_launch_remote.ps1` | Valida hash preview real via Chrome/CDP, screenshot e logs de rede/runtime | Sim, leitura remota; usar preview liberado; `-NoProjectWrites` evita sujar `build/` |
| Static hosting doc | `docs/internal-alpha-static-hosting.md` | Regras Cloudflare Pages + Supabase Storage | Sim, leitura |
| Supabase remote doc | `docs/supabase-remote-tutorial.md` | Setup, deploy e smokes remotos | Leitura. Deploy/comandos administrativos ficam fora de validacao segura |

## Checklist Comum Release-Ready

Antes de qualquer publicacao futura:

- Branch/worktree de release limpa e baseada no baseline aprovado.
- `ProjectInfo.RELEASE_CHANNEL`, `APP_VERSION`, `APP_VERSION_CODE` e `MANIFEST_SCHEMA_VERSION` revisados.
- `export_presets.cfg` mantem presets `Android Alpha`, `PC Windows Alpha` e `PC Browser Alpha`.
- `tools/smoke_exports.gd` verde.
- `tools/validate.gd` e GUT completos verdes quando houver mudanca de runtime/client.
- Deno check/lint de `server/functions` e `supabase/functions` verdes quando houver mudanca de server/manifest.
- `tools\validate_foundation.ps1 -Profile FullLocal` verde quando a stack local estiver disponivel e os budgets de shell/presenter nao estiverem bloqueando; para release sem banco local, `ReleaseDryRun` + checks especificos do pacote.
- `tools\check_release_safety.ps1` verde.
- `tools\check_android_release_keystore.ps1 -Mode InternalAlpha` verde para builds internos; `-Mode ReleaseCandidate` verde antes de ampliar distribuicao Android para alem de teste interno.
- `tools\check_track13_readiness.ps1` verde.
- `tools\check_agent_ops_foundation.ps1` verde quando alterar a fundacao operacional de agentes.
- `tools\check_foundation_expansion_readiness.ps1` verde quando alterar account/save, ruleset, admin, minigame, migrations ou readiness.
- `server/tests/foundation_admin_rls_live_smoke.ts` verde no `DatabaseLocal`/`FullLocal` quando alterar admin, RLS, account/save ou grants.
- `publish_internal_alpha.ps1 -Mode Plan` revisado.
- `publish_internal_alpha.ps1 -Mode Package -ReleaseRoot "<root-versionado>"` revisado; modos que empacotam/publicam nao podem usar root default/generico.
- `validate_foundation.ps1 -Profile FullPublish` nao e usado como caminho de publicacao; o runner deve rejeitar esse perfil.
- `release_manifest_smoke.ts` verde contra o alvo de release.
- `release_artifacts_remote_smoke.ts` verde somente depois que artefatos ja existirem no remoto; o manifest deve apontar para o dominio production estavel, nao para hash URL.
- Em dominio Cloudflare Pages protegido, usar preview liberado ou rodar o smoke com `DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS=1` apenas para reconhecer a tela de Access como protecao esperada.
- Para conferir hashes completos de APK/ZIP, rodar o smoke com `DRAXOS_RELEASE_FULL_HASH=1`; sem essa flag ele usa `HEAD`/`GET` parcial para ser rapido.
- `service_role`, `sb_secret_`, `sb_service_`, senha de banco e senha de keystore ausentes de cliente, portal, APK, ZIP, Web build, manifest e Git.
- `build/internal-alpha/release-artifacts.json` ou relatorio equivalente contem hashes SHA256 atuais.
- Manifest remoto planejado referencia exatamente os hashes/URLs dos artefatos aprovados.
- `requires_save_reset = true` so e permitido com procedimento manual de reset documentado e aprovado.
- `minimum_supported_version_code` so sobe quando o update obrigatorio foi validado em Android, PC e Web.
- Portal deixa claro que e alpha fechado/unlisted.
- Tester sabe que alpha pode resetar saves, mas nenhum reset automatico acontece pelo manifest.

## Android

Release-ready Android exige:

- Preset `Android Alpha` com `package/signed=true`, `permissions/internet=true`, `permissions/access_network_state=true` e version code positivo.
- `rendering/textures/vram_compression/import_etc2_astc=true`.
- APK gerado por `tools/export_internal_alpha.ps1` com backend `internal_alpha_v0` e `update_manifest_url` remoto.
- Keystore release dedicada configurada para distribuicao alem do teste interno. `debug_fallback` precisa aparecer como risco conhecido se usado.
- Gate local:

```powershell
.\tools\check_android_release_keystore.ps1 -ProjectDir . -Mode InternalAlpha
.\tools\check_android_release_keystore.ps1 -ProjectDir . -Mode ReleaseCandidate
```

- Config local ignorada deve declarar a tuple completa, nunca parcial:

```powershell
DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PATH=D:\caminho\para\draxos-mobile-internal-alpha.keystore
DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_USER=draxosmobilealpha
DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PASSWORD=<senha-local>
```

- Senha real de keystore nao pode aparecer em Git, docs, manifest, portal, APK, ZIP, Web build, `release-plan.json` ou relatorios.
- SHA256 do APK registrado no relatorio local e no manifest planejado.
- Link de download existente em Supabase Storage unlisted.
- Smoke somente leitura `release_artifacts_remote_smoke.ts` valida alcance do APK e tamanho minimo via `HEAD` ou `GET` parcial.
- Passada manual no aparelho Android antes de ampliar teste, incluindo login, update panel, batalha, Base, Social, Competicao e Loja.

## PC Windows

Release-ready PC exige:

- Preset `PC Windows Alpha` exporta executavel e `tools/export_internal_alpha.ps1` compacta o ZIP final.
- ZIP contem o executavel e dependencias esperadas, sem `docs/`, `tools/`, `server/`, `supabase/`, `tests/`, `implementation/`, scratch ou `build/**`.
- SHA256 do ZIP registrado no relatorio local e no manifest planejado.
- Link de download existente em Supabase Storage unlisted.
- Smoke somente leitura `release_artifacts_remote_smoke.ts` valida alcance do ZIP e tamanho minimo via `HEAD` ou `GET` parcial.
- Passada manual em Windows abre o exe, faz login, checa update panel e executa pelo menos uma acao online.

## Web

Release-ready Web exige:

- Preset `PC Browser Alpha` exporta `build/web/index.html` e assets Godot.
- APK/ZIP e assets grandes continuam em Supabase Storage; HTML final de Portal/Web fica no Cloudflare Pages.
- `tools/build_cloudflare_pages_package.ps1` gera `build/internal-alpha/cloudflare-pages/` e `build/internal-alpha/draxos-mobile-cloudflare-pages.zip`.
- Gerar o pacote Cloudflare a partir do mesmo worktree/sessao que exportou e empacotou a release. Nao redeployar a partir de `build/` local antigo do workspace principal.
- Quando `-StaticAssetBaseUrl` apontar para Supabase/HTTP, o script confere `GODOT_CONFIG.fileSizes` do shell Web contra `Content-Length` remoto de `index.pck` e `index.wasm`; mismatch bloqueia o pacote porque indica `publish/web/index.html` stale.
- Pacote Cloudflare nao contem arquivo individual com `>= 25 MiB`.
- `web/index.html` publicado no Cloudflare aponta para assets grandes no Supabase Storage.
- `web/index.html` publicado tem `GODOT_CONFIG.fileSizes.index.pck` igual ao `Content-Length` remoto do `index.pck` versionado.
- `web/index.html` publicado embute `DRAXOS_RELEASE_ROOT`, `DRAXOS_WEB_ASSET_ROOT`, cache-bust nos assets pequenos locais e watchdog legivel para splash acima de 20 segundos.
- `https://draxos-mobile-internal-alpha.pages.dev/` abre o Portal oficial.
- `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html` redireciona para o Portal oficial.
- `https://draxos-mobile-internal-alpha.pages.dev/web/index.html` abre Web build.
- Deploy Cloudflare Pages deve ir para a branch production `main`. O comando
  recomendado e:

```powershell
npx -y wrangler@latest pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main
```

- O comando acima ainda retorna um deployment hash. Registrar esse hash em
  `implementation/current-status.md` como evidencia tecnica, mas manter
  `StaticSiteBaseUrl` e o manifest remoto apontando para
  `https://draxos-mobile-internal-alpha.pages.dev`.
- Se Cloudflare Access estiver ativo, uma validacao anonima do dominio
  production pode retornar a tela de Access. Isso nao prova conteudo Godot.
  Para validar conteudo, use sessao autenticada no browser ou confirme via
  `wrangler pages deployment list --project-name draxos-mobile-internal-alpha`
  que o ultimo deployment `Production` da branch `main` corresponde ao source
  publicado, e valide o hash URL apenas como espelho tecnico desse deployment.
- O hash URL deve passar em `tools/smoke_web_launch_remote.ps1 -ExpectedReleaseRoot <release-root> -NoProjectWrites`: o overlay `#status` precisa sumir em ate 60 segundos, `index.pck` e `index.wasm` nao podem falhar e o screenshot final precisa mostrar o jogo, nao a splash.
- Smoke somente leitura `release_artifacts_remote_smoke.ts` valida Portal com `DraxosMobile` e Web com `GODOT_CONFIG`.

## Web CORS Troubleshooting

Sintoma confirmado em browser:

- O cliente mostra "Servidor Supabase indisponivel ou bloqueado pelo navegador".
- Network/console aponta bloqueio CORS em chamadas para
  `https://<project-ref>.supabase.co/functions/v1/...`.
- O mesmo endpoint pode responder `200` em `curl`, porque o erro esta na
  negociacao do header `Origin`, nao necessariamente no servidor ou na funcao.

Causa raiz do hotfix de `2026-06-01`:

- As Edge Functions ja calculavam CORS por request com
  `corsHeadersForRequest(request)`.
- Parte das respostas ainda retornava o bloco estatico `corsHeaders`, cujo
  `Access-Control-Allow-Origin` ficava preso no primeiro origin allowlisted.
- Quando o Web build era aberto por outro preview Cloudflare Pages, dominio
  estavel protegido ou preview anterior, o browser rejeitava a resposta por
  mismatch de origin e o cliente exibia a mensagem generica de Supabase
  indisponivel/bloqueado.

Solucao aplicada:

- Todas as respostas finais das Edge Functions devem passar por
  `withCorsResponse(request, response)`.
- `withCorsResponse` sobrescreve os headers CORS finais com o origin
  allowlisted da propria request.
- A allowlist deve aceitar previews do projeto Cloudflare Pages por uma regra
  restrita a `https://<hash>.draxos-mobile-internal-alpha.pages.dev`, alem dos
  origins fixos conhecidos, incluindo
  `https://draxos-mobile-internal-alpha.pages.dev`. Nao use wildcard geral de
  CORS.
- `OPTIONS` deve continuar respondendo com os headers calculados para o origin
  recebido.

Validacao recomendada apos qualquer novo preview Pages ou alteracao em Edge
Functions:

```powershell
$origin = "https://draxos-mobile-internal-alpha.pages.dev"
$function = "https://<project-ref>.supabase.co/functions/v1/healthcheck"
curl.exe -i -H "Origin: $origin" $function
curl.exe -i -X OPTIONS `
  -H "Origin: $origin" `
  -H "Access-Control-Request-Method: POST" `
  -H "Access-Control-Request-Headers: authorization,apikey,content-type,x-draxos-api-version,x-draxos-request-id,x-draxos-request-hash" `
  "https://<project-ref>.supabase.co/functions/v1/modes/state"
```

Aceitacao:

- `Access-Control-Allow-Origin` deve ser exatamente o `$origin` enviado.
- `Access-Control-Allow-Headers` deve incluir os headers usados pelo cliente.
- `validate_foundation.ps1 -Profile RemoteReadOnly` deve passar com
  `DRAXOS_REMOTE_CORS_ORIGIN=https://draxos-mobile-internal-alpha.pages.dev`.
  Previews hash podem ser validados em paralelo, mas nao substituem o dominio
  production fixo.
- `internal_alpha_remote_smoke.ts` deve passar em modo read-only quando o alvo
  remoto e a publishable key estiverem configurados.

Como diferenciar CORS de Supabase realmente indisponivel:

- CORS: endpoint responde fora do browser, mas o browser bloqueia por
  `Access-Control-Allow-Origin` ausente/incorreto ou preflight rejeitado.
- Supabase/Edge indisponivel: `curl` tambem falha, retorna `5xx`, timeout,
  DNS/TLS error ou funcao nao encontrada.
- Auth/save indisponivel: CORS passa, mas o body retorna erro de auth, save,
  invite, permissao ou conta alpha.

## Sequencia De Validacao Segura Track 13

Use esta sequencia em worktree de Track 13 sem publicar nada:

```powershell
cd <WORKTREE>\Projetos\draxos-mobile
.\tools\validate_foundation.ps1 -ProjectDir . -Profile FullLocal -RequireClean:$false
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/smoke_exports.gd
npx -y deno check server/tests/release_manifest_smoke.ts
npx -y deno check server/tests/release_artifacts_remote_smoke.ts
npx -y deno check server/tests/release_auth_contract_test.ts
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_release_safety.ps1 -ProjectDir .
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_android_release_keystore.ps1 -ProjectDir . -Mode InternalAlpha
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_track13_readiness.ps1 -ProjectDir .
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_agent_ops_foundation.ps1 -ProjectDir .
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .
```

PowerShell syntax check seguro dos scripts de release:

```powershell
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path .\tools\export_internal_alpha.ps1), [ref]$null, [ref]$errors) | Out-Null
if ($errors.Count -gt 0) { throw $errors }
[System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path .\tools\publish_internal_alpha.ps1), [ref]$null, [ref]$errors) | Out-Null
if ($errors.Count -gt 0) { throw $errors }
[System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path .\tools\build_cloudflare_pages_package.ps1), [ref]$null, [ref]$errors) | Out-Null
if ($errors.Count -gt 0) { throw $errors }
[System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path .\tools\validate_foundation.ps1), [ref]$null, [ref]$errors) | Out-Null
if ($errors.Count -gt 0) { throw $errors }
[System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path .\tools\check_release_safety.ps1), [ref]$null, [ref]$errors) | Out-Null
if ($errors.Count -gt 0) { throw $errors }
```

Opcional, somente se `build/internal-alpha/publish/` ja existir localmente de um export/publication package anterior e voce nao for publicar:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_cloudflare_pages_package.ps1 -ProjectDir . -StaticAssetBaseUrl "https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/<release-root>/web"
```

Remote read-only smoke, somente com URL remota e publishable key local:

```powershell
$env:SUPABASE_URL='https://<project-ref>.supabase.co'
$env:SUPABASE_PUBLISHABLE_KEY='sb_publishable_<public-key>'
$env:DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS='1'
.\tools\validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly
```

Ops read-only, sem mutation e sem service role remoto:

```powershell
$env:DRAXOS_OPS_ACCESS_TOKEN='<supabase-user-jwt>'
npx -y deno run --allow-net --allow-env tools/ops_readonly.ts --target manifest,modes,status,audit,rewards,sessions --mode-id openworld --format json
```

Hash completo opcional para APK/ZIP:

```powershell
$env:DRAXOS_RELEASE_FULL_HASH='1'
npx -y deno run --allow-net --allow-env --allow-read server/tests/release_artifacts_remote_smoke.ts
```

Encerrar sempre com:

```powershell
git diff --check
```

Validado nesta branch em `2026-05-28`:

- Pass: `tools/validate.gd` e GUT client 103 tests / 1662 asserts.
- Pass: `tools/validate_foundation.ps1 -Profile Client`.
- Pass: `tools/check_release_safety.ps1`.
- Pass: `publish_internal_alpha.ps1 -Mode Plan` sem mutacao remota.
- Pass: `publish_internal_alpha.ps1 -Mode Package` sem `-ReleaseRoot` bloqueia antes de empacotar.
- Pass: `publish_internal_alpha.ps1 -Mode Upload` sem confirmacao bloqueia antes de rede.
- Pass: Deno check de smokes de release.
- Pass: `git diff --check`.

## Sequencia De Publicacao Futura

Esta sequencia fica fora da validacao automatica segura e deve ser usada apenas em uma tarefa de release aprovada:

1. Rodar validacao full/release local.
2. Exportar Android, PC e Web com `tools/export_internal_alpha.ps1`.
3. Revisar hashes em `build/internal-alpha/release-artifacts.json`.
4. Rodar `tools/publish_internal_alpha.ps1 -ProjectDir . -Mode Plan -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev` e revisar o plano.
5. Rodar `tools/publish_internal_alpha.ps1 -ProjectDir . -Mode Package -ReleaseRoot <root-versionado> -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev` para preparar pacote local.
6. Rodar `tools/publish_internal_alpha.ps1 -ProjectDir . -Mode Upload -ReleaseRoot <root-versionado> -ConfirmRemoteMutation -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev` para Storage.
7. Gerar pacote Cloudflare no mesmo worktree com `tools/build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl <asset-root-versionado>/web`; este passo deve acontecer depois do upload porque o script compara o shell local com os assets remotos.
8. Publicar pacote no Cloudflare Pages production com `npx -y wrangler@latest pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`.
9. Validar o hash retornado pelo Cloudflare como evidencia tecnica e validar o dominio production fixo como alvo oficial. `/web` deve conter o asset root versionado e `GODOT_CONFIG.fileSizes.index.pck` deve bater com o `Content-Length` de `<asset-root-versionado>/web/index.pck`. Se production estiver sob Access, usar sessao autenticada ou registrar que a validacao anonima encontrou Access esperado.
10. Rodar `tools/publish_internal_alpha.ps1 -ProjectDir . -Mode DeployManifest -ReleaseRoot <root-versionado> -ConfirmRemoteMutation -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev` para manifest/deploy.
11. Rodar smokes remotos, incluindo `release_manifest_smoke.ts`, `release_artifacts_remote_smoke.ts` e `internal_alpha_remote_smoke.ts` com flags necessarias.
12. Registrar relatorio de export/publicacao e atualizar handoff.

## Validacoes Remotas Que Exigem Credenciais

| Validacao | Credencial | Mutacao Remota | Observacao |
|---|---|---:|---|
| `release_artifacts_remote_smoke.ts` | `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` | Nao | Somente `GET`/`HEAD`, com `GET` parcial para endpoints que recusam `HEAD`; recusa URL local e service role |
| `tools/ops_readonly.ts` | `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`; user JWT para targets protegidos | Nao | Somente `GET`; recusa service role, `sb_secret_` e JWT service-role-like |
| `release_manifest_smoke.ts` remoto | `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` | Nao | Pode rodar contra local ou remoto conforme env |
| `internal_alpha_remote_smoke.ts` healthcheck/release | `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` | Nao | Sem flags de auth, so healthcheck; com `DRAXOS_REMOTE_RELEASE_SMOKE=1`, tambem manifest |
| `internal_alpha_remote_smoke.ts` email/account | `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, convite alpha | Sim, cria usuario/save de teste | Usar so quando explicitamente autorizado |
| `publish_internal_alpha.ps1 -Mode Plan` | Opcional URL/project ref para plano completo | Nao | Gera plano local e nao chama Supabase mutante |
| `publish_internal_alpha.ps1 -Mode Package -ReleaseRoot <root-versionado>` | Artefatos locais e opcional URL/project ref | Nao | Prepara pacote local |
| `publish_internal_alpha.ps1 -Mode Upload/DeployManifest/FullPublish -ReleaseRoot <root-versionado> -ConfirmRemoteMutation` | Project ref, Supabase CLI auth, publishable key e possivel manifest override | Sim | Publica somente em tarefa aprovada |
| Cloudflare Pages deploy | Conta Cloudflare | Sim | Publica Portal/Web |

## Red Flags

- Manifest remoto aponta para hash diferente do artefato local aprovado.
- Manifest remoto aponta para `https://<hash>.draxos-mobile-internal-alpha.pages.dev` em vez do production fixo `https://draxos-mobile-internal-alpha.pages.dev`.
- `minimum_supported_version_code` maior que o app atual sem build nova validada.
- Portal/Web final hospedado diretamente no Supabase Storage.
- Cloudflare Pages foi redeployado a partir de `build/` local antigo ou de worktree diferente da exportacao aprovada.
- `web/index.html` publicado aponta para asset root novo, mas `GODOT_CONFIG.fileSizes.index.pck` nao bate com o `index.pck` remoto.
- APK debug fallback usado sem estar em `known_issues`.
- Smoke remoto usa `service_role` ou URL local.
- Script de publicacao remota foi executado sem `-ConfirmRemoteMutation`.
- Script sem `-Mode` publicou algo em vez de gerar apenas `Plan`.
- Release altera schema, economia, assets finais ou servicos novos junto com artefatos.

## Handoff Pos-Track 13

- Executar walkthrough manual real via `docs/track-13-manual-walkthrough-gate.md`.
- Rodar uma rodada real de `Mode Package` com artefatos frescos antes de qualquer nova publicacao.
- Manter remoto read-only opt-in no runner; mutacao remota continua exigindo tarefa aprovada e `-ConfirmRemoteMutation`.
