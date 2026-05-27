# DraxosMobile - Internal Alpha v0 Publication Report

- Data: `2026-05-27`
- Track: `T03-P17 - Publicacao Unlisted E QA Remoto Fechado`
- Status: `DOWNLOADS_GREEN - PORTAL_WEB_GREEN - AUTOMATED_REMOTE_QA_GREEN - MANUAL_SIGNOFF_PENDING`
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
| Android APK | `27795524` | `87533f150ffb773ef3bb7e41f6d69e98c7fdd4a85cbbf1e28544040aaade2448` |
| PC Windows ZIP | `36315593` | `e678fb7e2d2e984ad7356a47cbdcf4fdb12628ebe23636ab1a3b976365111082` |
| Web index | `5442` | `66b279ad9c9d9e1a5ae27f78880b98c8ba0dc8d788da955f1955754ab0cff71e` |

## Resultado Tecnico

- `202605270002_internal_alpha_storage.sql` criou/configurou o bucket publico unlisted `draxos-internal-alpha`.
- `tools/publish_internal_alpha.ps1` gerou `build/internal-alpha/publish/`, publicou APK/ZIP no Storage e validou HTTP dos downloads.
- Portal/Web foram publicados no Cloudflare Pages em `https://draxos-mobile-internal-alpha.pages.dev`.
- O Web build usa hospedagem hibrida: HTML no Cloudflare Pages e assets grandes do Godot Web export no Supabase Storage.
- O manifest remoto foi atualizado via secret override com links/hashes finais de Android/PC e links finais de Portal/Web.
- Override por secret (`RELEASE_MANIFEST_JSON_BASE64` ou `RELEASE_MANIFEST_JSON`) continua possivel apenas quando `RELEASE_MANIFEST_OVERRIDE_ENABLED=1`.
- `release` Edge Function foi redeployada para ignorar secrets antigos por padrao, evitando que um override obsoleto mantenha URLs diretas de Storage para HTML/Web.
- `build/internal-alpha/publication-report.json` guarda metadata local ignorada pelo Git.

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

- `https://469c4169.draxos-mobile-internal-alpha.pages.dev/`: portal completo, `200`, `text/html`.
- `https://469c4169.draxos-mobile-internal-alpha.pages.dev/web`: Web HTML com `GODOT_CONFIG`, `200`, `text/html`.
- `https://draxos-mobile-internal-alpha.pages.dev/`: portal completo, `200`, `text/html`.
- `https://draxos-mobile-internal-alpha.pages.dev/web`: Web HTML com `GODOT_CONFIG`, `200`, `text/html`.
- `https://8f43a34a.draxos-mobile-internal-alpha.pages.dev`: deploy antigo invalido, nao usar.

## Pendencia Manual

A parte automatizada de backend/downloads/portal/Web esta verde. O que falta e signoff humano completo:

- abrir portal e baixar/abrir pelo menos duas plataformas;
- criar/login com email e senha;
- confirmar save comum entre plataformas;
- jogar loop normal: batalha, recompensa, base, loja, social e competicao;
- alternar para `progression_lab`, confirmar isolamento e ausencia no ranking;
- registrar problemas de ergonomia Android paisagem e qualquer bloqueio de update/login.

Depois desse host estatico e signoff, seguir para `T03-P18 - Handoff Da Internal Alpha v0`.
