# Update Manifest Contract

- Ultima atualizacao: `2026-05-27`
- Status: `T03-P17_PUBLISHED_UNLISTED`
- Endpoint atual: `GET /release/manifest`
- Schema: `internal_alpha_manifest_v1`

O manifest de update e o contrato que permite Android, PC e Web saberem qual build esta vigente no canal `internal_alpha`.

## Fonte Atual

Durante a Internal Alpha v0, o manifest vive como Edge Function publica:

```text
https://<project-ref>.supabase.co/functions/v1/release/manifest
```

A funcao retorna um JSON sem secrets e sem depender de login. A implementacao possui um manifest padrao versionado no repo. Override operacional por `RELEASE_MANIFEST_JSON_BASE64` ou `RELEASE_MANIFEST_JSON` fica disponivel apenas quando `RELEASE_MANIFEST_OVERRIDE_ENABLED=1`, para evitar que secrets antigos mantenham links obsoletos.

## Payload

```json
{
  "schema_version": "internal_alpha_manifest_v1",
  "channel": "internal_alpha",
  "latest_version": "0.0.1-alpha.0",
  "latest_version_code": 1,
  "minimum_supported_version": "0.0.1-alpha.0",
  "minimum_supported_version_code": 1,
  "released_at": "2026-05-27T00:00:00Z",
  "requires_save_reset": false,
  "portal_url": "PORTAL_URL_PENDING_T03_P17",
  "notes": ["Primeira release candidate interna."],
  "artifacts": {
    "android": {
      "label": "Android APK",
      "url": "ANDROID_APK_URL_PENDING_T03_P17",
      "sha256": "ANDROID_APK_SHA256_PENDING_T03_P17"
    },
    "pc_windows": {
      "label": "PC Windows ZIP",
      "url": "PC_ZIP_URL_PENDING_T03_P17",
      "sha256": "PC_ZIP_SHA256_PENDING_T03_P17"
    },
    "web": {
      "label": "Web",
      "url": "WEB_GAME_URL_PENDING_T03_P17"
    }
  },
  "known_issues": []
}
```

## Regras Do Cliente

- `channel` precisa ser igual a `internal_alpha`.
- `schema_version` precisa ser igual a `internal_alpha_manifest_v1`.
- `latest_version_code` maior que o code local mostra update recomendado.
- `minimum_supported_version_code` maior que o code local bloqueia acoes online.
- `requires_save_reset = true` nao apaga save automaticamente; apenas mostra aviso e exige procedimento manual/documentado.
- Se o manifest estiver indisponivel, o cliente permite jogar e mostra aviso de checagem falha. Isso evita bloquear o teste por uma falha temporaria de rede.

## Versao Local Atual

| Campo | Valor |
|---|---|
| `ProjectInfo.RELEASE_CHANNEL` | `internal_alpha` |
| `ProjectInfo.APP_VERSION` | `0.0.1-alpha.0` |
| `ProjectInfo.APP_VERSION_CODE` | `1` |
| `ProjectInfo.MANIFEST_SCHEMA_VERSION` | `internal_alpha_manifest_v1` |

## Evolucao

Em `T03-P16`, os artefatos locais foram exportados e seus hashes foram registrados em `../internal-alpha-v0-export-report.md`. Em `T03-P17`, APK/PC ZIP foram publicados no Supabase Storage unlisted e o manifest remoto passou a usar hashes reais para downloads. A correcao pos-publicacao registrou que Portal/Web precisam de host estatico externo, pois Supabase Storage/Edge Functions nao servem HTML como pagina. Detalhes em `../internal-alpha-v0-publication-report.md`. Em releases futuras, subir `latest_version_code` gera update recomendado; subir `minimum_supported_version_code` torna o update obrigatorio para acoes online.
