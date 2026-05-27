# DraxosMobile - Internal Alpha v0 Publication Report

- Data: `2026-05-27`
- Track: `T03-P17 - Publicacao Unlisted E QA Remoto Fechado`
- Status: `PUBLICATION_GREEN - AUTOMATED_REMOTE_QA_GREEN - MANUAL_SIGNOFF_PENDING`
- Canal: `internal_alpha`
- Versao in-app: `0.0.1-alpha.0`
- Version code: `1`
- Backend remoto: `https://armxgipvnbbshzqawklw.supabase.co`
- Bucket: `draxos-internal-alpha`
- Storage root: `internal-alpha/v0`

## Links Publicados

| Item | URL |
|---|---|
| Portal | `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0/portal/index.html` |
| Web | `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0/web/index.html` |
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
- `tools/publish_internal_alpha.ps1` gerou `build/internal-alpha/publish/`, publicou portal/Web/APK/ZIP no Storage e validou HTTP dos links.
- O manifest remoto usa `RELEASE_MANIFEST_JSON_BASE64` para evitar quebra de escaping no CLI.
- `release` Edge Function foi redeployada com suporte a override base64.
- `build/internal-alpha/publication-report.json` guarda metadata local ignorada pelo Git.

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

## Pendencia Manual

A parte automatizada de `T03-P17` esta verde, mas o signoff humano ainda precisa ser feito por Fabio + 1 tester:

- abrir portal e baixar/abrir pelo menos duas plataformas;
- criar/login com email e senha;
- confirmar save comum entre plataformas;
- jogar loop normal: batalha, recompensa, base, loja, social e competicao;
- alternar para `progression_lab`, confirmar isolamento e ausencia no ranking;
- registrar problemas de ergonomia Android paisagem e qualquer bloqueio de update/login.

Depois desse signoff, seguir para `T03-P18 - Handoff Da Internal Alpha v0`.
