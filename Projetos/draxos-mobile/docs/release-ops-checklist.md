# DraxosMobile - Release Ops Checklist

- Data: `2026-05-27`
- Track: `Track 05 - Foundation Stabilization And Asset/Service Readiness`
- Status: `T05-G_READY_FOR_INTEGRATION`
- Escopo: readiness operacional de release para Android, PC e Web, sem publicar build nova.

## Guardrails T05-G

- Nao publicar, redeployar, alterar manifest remoto real ou subir arquivos para Storage nesta trilha.
- Nao gerar build final como parte da validacao T05-G.
- Nao tocar em secrets, service role, senha de banco, senha de keystore ou `.env.internal-alpha.local`.
- Usar apenas publishable/client key em smokes remotos.
- Qualquer check remoto nesta trilha deve ser somente leitura: `GET`, `HEAD` ou auth/smoke explicitamente solicitado.
- `publish_internal_alpha.ps1`, `supabase db push`, `supabase functions deploy`, `supabase secrets set`, Wrangler deploy e upload Cloudflare sao comandos de publicacao, nao validacao segura T05-G.

## Inventario Atual

| Area | Fonte | Papel | Seguro Em T05-G |
|---|---|---|---|
| Version gate client | `core/project_info.gd`, `tests/client/test_project_info.gd` | Canal, versao, version code, schema e bloqueio por `minimum_supported_version_code` | Sim, via `validate.gd`/GUT se necessario |
| Manifest contract | `docs/contracts/update-manifest.md` | Payload autoritativo de `GET /release/manifest` | Sim, leitura |
| Manifest function | `server/functions/release/index.ts`, `supabase/functions/release/index.ts` | Manifest default e override operacional por env secret | So check/lint. Deploy e secret sao publicacao |
| Manifest smoke local/remoto | `server/tests/release_manifest_smoke.ts` | Valida schema, canal, version code e metadados Android/PC/Web | Sim, se Supabase alvo estiver configurado |
| Artifact smoke remoto | `server/tests/release_artifacts_remote_smoke.ts` | Valida manifest, downloads APK/ZIP via `HEAD` ou `GET` parcial, Portal e Web HTML existentes | Sim, somente leitura, exige URL e publishable key |
| Export presets | `export_presets.cfg`, `tools/smoke_exports.gd` | Android Alpha, PC Windows Alpha e PC Browser Alpha | Sim |
| Export script | `tools/export_internal_alpha.ps1` | Gera APK, PC ZIP, Web e metadata local | Syntax check seguro. Execucao gera builds, usar so em release real |
| Publish script | `tools/publish_internal_alpha.ps1` | Prepara publish dir, publica Storage, atualiza manifest override e redeploya `release` | Syntax check seguro. Execucao publica/redeploya |
| Cloudflare package | `tools/build_cloudflare_pages_package.ps1` | Gera pacote local hibrido para Pages a partir de publish existente | Seguro se rodar sobre artefatos locais existentes; nao faz deploy |
| Static hosting doc | `docs/internal-alpha-static-hosting.md` | Regras Cloudflare Pages + Supabase Storage | Sim, leitura |
| Supabase remote doc | `docs/supabase-remote-tutorial.md` | Setup, deploy e smokes remotos | Leitura. Deploy/comandos administrativos ficam fora de T05-G |

## Checklist Comum Release-Ready

Antes de qualquer publicacao futura:

- Branch/worktree de release limpa e baseada no baseline aprovado.
- `ProjectInfo.RELEASE_CHANNEL`, `APP_VERSION`, `APP_VERSION_CODE` e `MANIFEST_SCHEMA_VERSION` revisados.
- `export_presets.cfg` mantem presets `Android Alpha`, `PC Windows Alpha` e `PC Browser Alpha`.
- `tools/smoke_exports.gd` verde.
- `tools/validate.gd` e GUT completos verdes quando houver mudanca de runtime/client.
- Deno check/lint de `server/functions` e `supabase/functions` verdes quando houver mudanca de server/manifest.
- `release_manifest_smoke.ts` verde contra o alvo de release.
- `release_artifacts_remote_smoke.ts` verde somente depois que artefatos ja existirem no remoto.
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
- Pacote Cloudflare nao contem arquivo individual com `>= 25 MiB`.
- `web/index.html` publicado no Cloudflare aponta para assets grandes no Supabase Storage.
- `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html` abre Portal.
- `https://draxos-mobile-internal-alpha.pages.dev/web/index.html` abre Web build.
- Smoke somente leitura `release_artifacts_remote_smoke.ts` valida Portal com `DraxosMobile` e Web com `GODOT_CONFIG`.

## Sequencia De Validacao Segura T05-G

Use esta sequencia em worktree de Track 05 sem publicar nada:

```powershell
cd <WORKTREE>\Projetos\draxos-mobile
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/smoke_exports.gd
npx -y deno check server/tests/release_manifest_smoke.ts
npx -y deno check server/tests/release_artifacts_remote_smoke.ts
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_track11_readiness.ps1 -ProjectDir .
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
```

Opcional, somente se `build/internal-alpha/publish/` ja existir localmente de um export/publication package anterior e voce nao for publicar:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_cloudflare_pages_package.ps1 -ProjectDir .
```

Remote read-only smoke, somente com URL remota e publishable key local:

```powershell
$env:SUPABASE_URL='https://<project-ref>.supabase.co'
$env:SUPABASE_PUBLISHABLE_KEY='sb_publishable_<public-key>'
$env:DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS='1'
npx -y deno run --allow-net --allow-env server/tests/release_artifacts_remote_smoke.ts
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

Validado nesta branch em `2026-05-27`:

- Pass: `tools/smoke_exports.gd` (com avisos de cache/autoload pre-existentes em worktree fresca antes do OK).
- Pass: `npx -y deno task --cwd supabase/functions check`.
- Pass: `npx -y deno task --cwd server/functions check`.
- Pass: `npx -y deno check server/tests/release_artifacts_remote_smoke.ts`.
- Pass: `npx -y deno lint server/tests/release_artifacts_remote_smoke.ts`.
- Pass: parse seguro de `export_internal_alpha.ps1`, `publish_internal_alpha.ps1` e `build_cloudflare_pages_package.ps1`.
- Pass: `git diff --check`.

## Sequencia De Publicacao Futura

Esta sequencia fica fora de T05-G e deve ser usada apenas em uma tarefa de release aprovada:

1. Rodar validacao full/release local.
2. Exportar Android, PC e Web com `tools/export_internal_alpha.ps1`.
3. Revisar hashes em `build/internal-alpha/release-artifacts.json`.
4. Publicar APK/PC ZIP e preparar publish dir com `tools/publish_internal_alpha.ps1`.
5. Gerar pacote Cloudflare com `tools/build_cloudflare_pages_package.ps1`.
6. Publicar pacote no Cloudflare Pages por fluxo aprovado.
7. Rodar `tools/publish_internal_alpha.ps1 -StaticSiteBaseUrl <url> -SkipUpload -UseManifestSecret` para alinhar manifest remoto.
8. Rodar smokes remotos, incluindo `release_manifest_smoke.ts`, `release_artifacts_remote_smoke.ts` e `internal_alpha_remote_smoke.ts` com flags necessarias.
9. Registrar relatorio de export/publicacao e atualizar handoff.

## Validacoes Remotas Que Exigem Credenciais

| Validacao | Credencial | Mutacao Remota | Observacao |
|---|---|---:|---|
| `release_artifacts_remote_smoke.ts` | `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` | Nao | Somente `GET`/`HEAD`, com `GET` parcial para endpoints que recusam `HEAD`; recusa URL local e service role |
| `release_manifest_smoke.ts` remoto | `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` | Nao | Pode rodar contra local ou remoto conforme env |
| `internal_alpha_remote_smoke.ts` healthcheck/release | `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` | Nao | Sem flags de auth, so healthcheck; com `DRAXOS_REMOTE_RELEASE_SMOKE=1`, tambem manifest |
| `internal_alpha_remote_smoke.ts` email/account | `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, convite alpha | Sim, cria usuario/save de teste | Usar so quando explicitamente autorizado |
| `publish_internal_alpha.ps1` | Project ref, Supabase CLI auth, publishable key e possivel manifest secret | Sim | Publica Storage, secrets e redeploya `release` |
| Cloudflare Pages deploy | Conta Cloudflare | Sim | Publica Portal/Web |

## Red Flags

- Manifest remoto aponta para hash diferente do artefato local aprovado.
- `minimum_supported_version_code` maior que o app atual sem build nova validada.
- Portal/Web final hospedado diretamente no Supabase Storage.
- APK debug fallback usado sem estar em `known_issues`.
- Smoke remoto usa `service_role` ou URL local.
- Script de publicacao foi executado em tarefa marcada como "sem publicar".
- Release altera schema, economia, assets finais ou servicos novos junto com artefatos.

## Handoff Para T05-H

- Integrar este checklist com a matriz de validacao da Track 05.
- Decidir se `release_artifacts_remote_smoke.ts` entra no pacote `remote` oficial.
- Manter `publish_internal_alpha.ps1` fora dos checks automaticos de T05, salvo tarefa de release explicitamente aprovada.
- Atualizar o status da Track 05 somente na integracao final, para evitar conflito com worktrees paralelas.
