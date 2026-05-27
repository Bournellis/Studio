# DraxosMobile - Internal Alpha v0 Publication Report

- Data: `2026-05-27`
- Track: `T03-P17 - Publicacao Unlisted E QA Remoto Fechado`
- Status: `T03-P17A_REPUBLISHED_GREEN - MANUAL_SIGNOFF_PENDING`
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
| Android APK | `27811908` | `6c39ce9a63eaf4796a67a9e5a29e9252f1f03266f713ffa58c5d2333c15102d6` |
| PC Windows ZIP | `36331728` | `4b7dc516bc4c5c4895930f8732ad9e97733cca85ba7574c9a0308c705982d236` |
| Web index | `5442` | `04c8da05bcada497128a9c506092579bf47075d8da636634ffb1722e3cbd1a1b` |

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

## Pendencia Manual

A parte automatizada de backend/downloads/portal/Web esta verde. O que falta e signoff humano completo:

- abrir portal e baixar/abrir pelo menos duas plataformas;
- criar/login com email e senha;
- confirmar save comum entre plataformas;
- jogar loop normal: batalha, recompensa, base, loja, social e competicao;
- alternar para `progression_lab`, confirmar isolamento e ausencia no ranking;
- registrar problemas de ergonomia Android paisagem e qualquer bloqueio de update/login.

Depois desse signoff, seguir para `T03-P18 - Handoff Da Internal Alpha v0`.
