# DraxosMobile - Internal Alpha v0 Publication Report

- Data: `2026-05-27`
- Track: `T03-P17 - Publicacao Unlisted E QA Remoto Fechado`
- Status: `T03-P18_COMPLETE - INTERNAL_ALPHA_V0_HANDOFF_READY`
- Canal: `internal_alpha`
- Versao in-app: `0.0.1-alpha.0`
- Version code: `1`
- Backend remoto: `https://armxgipvnbbshzqawklw.supabase.co`
- Bucket: `draxos-internal-alpha`
- Storage root: `internal-alpha/v0`

## Links Publicados

| Item | URL |
|---|---|
| Portal | `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html` |
| Web | `https://draxos-mobile-internal-alpha.pages.dev/web/index.html` |
| Android APK | `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0/downloads/draxos-mobile-alpha.apk` |
| PC ZIP | `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0/downloads/draxos-mobile-alpha.zip` |
| Manifest | `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest` |

## Artefatos

| Plataforma | Bytes | SHA256 |
|---|---:|---|
| Android APK | `27965106` | `ad6d2579ce003769cfce2536b788c1330abb283d0ae90cc785d1d016ae514ca6` |
| PC Windows ZIP | `36466312` | `ad5fb8351bb001604479d95737fc702bb9b0ff6779afb9e3e31692b7bc189031` |
| Web index | `5442` | `75fdd260b889582cb723256e87ca9867ae35b7cdd3411cbb2ca21ace5585366a` |

## Republicacao Track 10 - 2026-05-28

Depois da rework de apresentacao da batalha, as builds Internal Alpha foram republicadas sem subir version code e sem exigir reset de save.

Resultado observado:

- Android APK remoto: `200`, `27965106` bytes, SHA256 `ad6d2579ce003769cfce2536b788c1330abb283d0ae90cc785d1d016ae514ca6`.
- PC ZIP remoto: `200`, `36466312` bytes, SHA256 `ad5fb8351bb001604479d95737fc702bb9b0ff6779afb9e3e31692b7bc189031`.
- Web index local/publicado: `5442` bytes, SHA256 `75fdd260b889582cb723256e87ca9867ae35b7cdd3411cbb2ca21ace5585366a`.
- Manifest remoto: `released_at = 2026-05-28T04:50:33Z`, `requires_save_reset = false`.
- Cloudflare Pages preview: `https://36b1d46c.draxos-mobile-internal-alpha.pages.dev`.
- Dominio estavel protegido por Cloudflare Access; smokes anonimos devem usar preview ou `DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS=1` para reconhecer a tela de Access como protecao esperada, nao como Portal/Web validado.

## Resultado Tecnico

- `202605270002_internal_alpha_storage.sql` criou/configurou o bucket publico unlisted `draxos-internal-alpha`.
- `tools/publish_internal_alpha.ps1` gerou `build/internal-alpha/publish/`, publicou APK/ZIP no Storage e validou HTTP dos downloads.
- Portal/Web foram publicados no Cloudflare Pages em `https://draxos-mobile-internal-alpha.pages.dev`.
- O Web build usa hospedagem hibrida: HTML no Cloudflare Pages e assets grandes do Godot Web export no Supabase Storage.
- O manifest remoto foi atualizado via secret override com links/hashes finais de Android/PC e links finais de Portal/Web.
- Override por secret (`RELEASE_MANIFEST_JSON_BASE64` ou `RELEASE_MANIFEST_JSON`) continua possivel apenas quando `RELEASE_MANIFEST_OVERRIDE_ENABLED=1`.
- `release` Edge Function foi redeployada para ignorar secrets antigos por padrao, evitando que um override obsoleto mantenha URLs diretas de Storage para HTML/Web.
- `build/internal-alpha/publication-report.json` guarda metadata local ignorada pelo Git.

## Republicacao T03-P17A

Em 2026-05-27, apos Fabio aprovar a ergonomia Android da `T03-P17A`, os artefatos locais foram reexportados e APK/PC ZIP/manifest/Cloudflare Pages foram republicados.

Resultado:

- `tools/smoke_exports.gd`: passou.
- `tools/export_internal_alpha.ps1`: passou, Android mode `debug_fallback`.
- `tools/publish_internal_alpha.ps1 -StaticSiteBaseUrl "https://draxos-mobile-internal-alpha.pages.dev" -SkipUpload -UseManifestSecret`: passou.
- Android APK remoto: `200`, `27811908` bytes, `application/vnd.android.package-archive`.
- PC ZIP remoto: `200`, `36331728` bytes, `application/zip`.
- Manifest remoto: `200`, `application/json`, validado por `release_manifest_smoke.ts` remoto.
- `npx -y wrangler pages deploy .\build\internal-alpha\cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: passou.
- Deploy Cloudflare Pages: `https://a2383707.draxos-mobile-internal-alpha.pages.dev`.
- Portal/Web preview: `200`, `text/html`, HTML igual ao pacote local.
- Portal/Web dominio estavel: `200`, `text/html`, HTML igual ao pacote local.
- `release_manifest_smoke.ts` remoto: passou.
- `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1`: passou.
## Correcao Pos-Publicacao

Na primeira abertura manual, o link direto do Storage exibiu o HTML do portal como texto puro porque a resposta veio com `Content-Type: text/plain`, `nosniff` e CSP sandbox. A tentativa de servir por Edge Function confirmou a mesma politica para `text/html`. A solucao final de `T03-P17` foi manter Supabase como backend/downloads/assets grandes e publicar Portal/Web HTML no Cloudflare Pages.

## QA Remoto Automatizado

Executado contra `https://armxgipvnbbshzqawklw.supabase.co`:

- `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1` e `DRAXOS_REMOTE_EMAIL_AUTH_SMOKE=1`: passou.
- `release_manifest_smoke.ts`: passou.
- `first_slice_battle_smoke.ts`: passou.
- `base_manager_smoke.ts`: passou.
- `monetization_rewards_smoke.ts`: passou.
- `social_competition_smoke.ts`: passou.
- `battle_request_smoke.ts`: passou.
- `client_telemetry_smoke.ts`: passou.

Os smokes foram ajustados para aceitar o comportamento remoto do gateway Supabase quando uma chamada sem JWT e barrada antes da Edge Function.

Hotfix de 2026-05-27: as rotas de gameplay `battle`, `base`, `social`, `competition` e `monetization` ainda rejeitavam JWT registrado de email/senha com `AUTH_NOT_ANONYMOUS`, herdado do MVP guest. O guard foi removido dessas rotas, mantendo `/account/guest` como a unica rota exclusiva de guest dev. As cinco Edge Functions foram redeployadas e a bateria remota confirmou email/senha + batalha, alem dos smokes de batalha/base/social/competicao/loja/telemetria.

## Host Estatico Cloudflare Pages

O Cloudflare Pages nao deve receber `build/internal-alpha/publish/` inteiro, porque o `web/index.wasm` do Godot excede o limite por arquivo do Pages. A publicacao correta usa um pacote hibrido:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_cloudflare_pages_package.ps1 -ProjectDir .
```

Publicar uma destas saidas no Cloudflare Pages:

- `build/internal-alpha/cloudflare-pages/`
- `build/internal-alpha/draxos-mobile-cloudflare-pages.zip`

Esse pacote deixa Portal/Web HTML no Cloudflare e mantem APK/PC/Web assets grandes apontando para Supabase Storage.

Observacao operacional: se `/` nao retornar o portal completo, ou `/web` nao retornar HTML com `GODOT_CONFIG`, o deploy nao recebeu os arquivos esperados. Regenerar o pacote e criar um novo deploy no Pages. O pacote atual inclui `_redirects`, `index.html` e `web.html` na raiz; `/portal/index.html` redireciona para `/` e `/web/index.html` redireciona para `/web`.

Validacao final em 2026-05-27:

- `https://a2383707.draxos-mobile-internal-alpha.pages.dev/portal/index.html`: Portal, `200`, `text/html`, HTML igual ao pacote local.
- `https://a2383707.draxos-mobile-internal-alpha.pages.dev/web/index.html`: Web HTML com `GODOT_CONFIG`, `200`, `text/html`, HTML igual ao pacote local.
- `https://469c4169.draxos-mobile-internal-alpha.pages.dev/`: portal completo, `200`, `text/html`.
- `https://469c4169.draxos-mobile-internal-alpha.pages.dev/web`: Web HTML com `GODOT_CONFIG`, `200`, `text/html`.
- `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`: Portal, `200`, `text/html`, HTML igual ao pacote local.
- `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`: Web HTML com `GODOT_CONFIG`, `200`, `text/html`, HTML igual ao pacote local.
- `https://8f43a34a.draxos-mobile-internal-alpha.pages.dev`: deploy antigo invalido, nao usar.

## Signoff E Proxima Etapa

A parte automatizada de backend/downloads/portal/Web esta verde. Em 2026-05-27, Fabio aprovou avancar para `T03-P18`, e o handoff final foi fechado em `internal-alpha-v0-handoff.md`. Feedback posterior do tester deve entrar no backlog pos-handoff:

- abrir portal e baixar/abrir pelo menos duas plataformas;
- criar/login com email e senha;
- confirmar save comum entre plataformas;
- jogar loop normal: batalha, recompensa, base, loja, social e competicao;
- alternar para `progression_lab`, confirmar isolamento e ausencia no ranking;
- registrar problemas de ergonomia Android paisagem e qualquer bloqueio de update/login.

Proximo passo: rodada fechada Fabio + tester e backlog de feedback pos-handoff.

## T03-P18 Handoff

Em 2026-05-27, o handoff final atualizou o portal source, o manifest exemplo, os defaults de `release/manifest`, as notas pos-signoff e o pacote Cloudflare.

Validacao T03-P18:

- `npx -y deno check supabase/functions/release/index.ts server/functions/release/index.ts`: passou.
- `npx -y deno lint supabase/functions/release/index.ts server/functions/release/index.ts`: passou.
- `tools/publish_internal_alpha.ps1 -StaticSiteBaseUrl "https://draxos-mobile-internal-alpha.pages.dev" -SkipUpload -UseManifestSecret`: passou.
- `tools/build_cloudflare_pages_package.ps1`: passou.
- `npx -y wrangler pages deploy .\build\internal-alpha\cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: passou, deploy `https://3a994d39.draxos-mobile-internal-alpha.pages.dev`.
- Portal/Web preview e dominio estavel: `200 text/html` e HTML igual ao pacote local.
- Manifest remoto: `200 application/json` com known issue atualizado para validacao apos cada deploy.
- `release_manifest_smoke.ts` remoto: passou.
- `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1`: passou.

## Foundation Responsive Hotfix - 2026-05-28

Depois da revisao manual do Foundation Loop UX Pass 01, Fabio reportou que Labs Dev sumiram do menu inicial interno, Refugio/Batalha estavam escapando do tamanho da tela em Web/Android e o APK no celular abria endpoint protegido com erro `Bearer token is required`.

Publicacao executada a partir da branch `codex/draxos-mobile/foundation-responsive-guardrails`, commit `01e6237`:

- `smoke_exports.gd`: passou.
- `export_internal_alpha.ps1`: passou, Android mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: passou.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: passou.
- `build_cloudflare_pages_package.ps1`: passou.
- `publish_internal_alpha.ps1 -Mode Upload -PublicDownloads -ConfirmRemoteMutation`: passou.
- `npx -y wrangler pages deploy .\build\internal-alpha\cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: passou.
- Deploy Cloudflare Pages: `https://c8dc997b.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`: passou.
- `release_manifest_smoke.ts`: passou.
- `release_artifacts_remote_smoke.ts`: passou; dominio estavel reconhecido como protegido por Cloudflare Access.
- `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1`: passou.
- APK anonimo via `HEAD`: `200`, `31563411` bytes, `application/vnd.android.package-archive`.
- PC ZIP anonimo via `HEAD`: `200`, `40032213` bytes, `application/zip`.

Artefatos publicados:

- Android APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0/downloads/draxos-mobile-alpha.apk`
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0/downloads/draxos-mobile-alpha.zip`
- Portal estavel: `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web estavel: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`

Hashes planejados no manifest:

- Android APK: `e13974b4adebae0646f536f09088f4af14e52bfb38940aa31e8133fcf5c0334f`
- PC Windows ZIP: `4ec31aba91415ee6f6dac4f21bab8fc366bef6d5af916df2abeff86e3706ec23`
- Web Index: `30802917fa9d0abc8b7cfcec922a3e93001f744e89a31dce1998cab9d5d98d81`

## Visual Direction v1 - 2026-05-29

Depois da implementacao de Visual Direction v1, Fabio aprovou exportar e subir novas versoes para o site. A publicacao foi executada a partir da branch `codex/draxos-mobile/visual-direction-v1-publish`.

Resultado:

- `validate_foundation.ps1 -Profile Client`: passou apos import Godot inicial da worktree.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: passou, Android mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan`: passou.
- `publish_internal_alpha.ps1 -Mode Package`: passou.
- `build_cloudflare_pages_package.ps1`: passou.
- `npx -y wrangler pages deploy .\build\internal-alpha\cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: passou.
- Deploy Cloudflare Pages: `https://6a6ae522.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`: passou com downloads protegidos.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`: passou.
- `release_manifest_smoke.ts`: passou.
- `release_download_smoke.ts`: passou com signed HEAD para Android e PC.
- `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1`: passou.
- Preview Portal/Web: passou para `/portal/index.html` (`Draxos Alpha`) e `/web/index.html` (`GODOT_CONFIG`).

Hashes planejados no manifest:

- Android APK: `2a6bff4f927dbb835c667347fa9f3b54d0c947f95b3454c65b8a561d57678200`
- PC Windows ZIP: `a29f7341c676866fda421d3ee9cf13cdf26a216644b0ce98ba3614964e9b8875`
- Web Index: `ac43ff4352f206822b54f199ff6eddabe0b72a6d4d1b41622e4f6e70148be40c`
