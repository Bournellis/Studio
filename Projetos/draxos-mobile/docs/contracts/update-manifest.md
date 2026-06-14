# Update Manifest Contract

- Ultima atualizacao: `2026-06-14`
- Status: `LIVE_INTERNAL_ALPHA_CONTRACT`
- Endpoint atual: `GET /release/manifest`
- Schema: `internal_alpha_manifest_v1`

O manifest de update e o contrato que permite Android, PC e Web saberem qual
build esta vigente no canal `internal_alpha`.

Estado operacional atual, pacote publicado, valores de versao, version codes,
hashes, URLs e release root vivem em `../../implementation/current-status.md`.
Historico de pacotes, endpoints estaveis e downloads vivem em
`../release-history.md`. Este contrato descreve formato e regras; exemplos aqui
nao declaram a publicacao atual.

## Fonte Atual

Durante a Internal Alpha v0, o manifest vive como Edge Function publica:

```text
https://<project-ref>.supabase.co/functions/v1/release/manifest
```

A funcao retorna um JSON sem secrets e sem depender de login. A implementacao
possui um manifest padrao versionado no repo em `server/functions/release/index.ts`
e `supabase/functions/release/index.ts`. Override operacional por
`RELEASE_MANIFEST_JSON_BASE64` ou `RELEASE_MANIFEST_JSON` fica disponivel apenas
quando `RELEASE_MANIFEST_OVERRIDE_ENABLED=1`, para evitar que secrets antigos
mantenham links obsoletos.

Downloads default do manifest apontam para os artefatos configurados na funcao
de release. Nao derivar novos hashes ou URLs a partir do nome do pacote sem nova
publicacao de artefatos.

## Payload

Exemplo de schema, nao estado operacional atual:

```json
{
  "schema_version": "internal_alpha_manifest_v1",
  "channel": "internal_alpha",
  "latest_version": "0.0.x-alpha.0",
  "latest_version_code": 0,
  "minimum_supported_version": "0.0.y-alpha.0",
  "minimum_supported_version_code": 0,
  "released_at": "2026-01-01T00:00:00Z",
  "requires_save_reset": false,
  "portal_url": "https://example.invalid/",
  "notes": [
    "Resumo curto da publicacao atual.",
    "Notas de compatibilidade e gates de update."
  ],
  "artifacts": {
    "android": {
      "label": "Android APK",
      "url": "https://example.invalid/download.apk",
      "sha256": "<sha256>",
      "auth_required": true
    },
    "pc_windows": {
      "label": "PC Windows ZIP",
      "url": "https://example.invalid/download.zip",
      "sha256": "<sha256>",
      "auth_required": true
    },
    "web": {
      "label": "Web",
      "url": "https://example.invalid/web/index.html"
    }
  },
  "known_issues": [
    "Fallback estatico deve permanecer alinhado ao manifest remoto versionado."
  ]
}
```

## Regras Do Cliente

- `channel` precisa ser igual a `internal_alpha`.
- `schema_version` precisa ser igual a `internal_alpha_manifest_v1`.
- `latest_version_code` maior que o code local mostra update recomendado.
- `minimum_supported_version_code` maior que o code local bloqueia acoes online.
- `requires_save_reset = true` nao apaga save automaticamente; apenas mostra
  aviso e exige procedimento manual/documentado.
- Se o manifest estiver indisponivel, o cliente permite jogar e mostra aviso de
  checagem falha. Isso evita bloquear o teste por uma falha temporaria de rede.

## Versao Local Atual

Valores atuais de `ProjectInfo.RELEASE_CHANNEL`, `ProjectInfo.APP_VERSION`,
`ProjectInfo.APP_VERSION_CODE` e `ProjectInfo.MANIFEST_SCHEMA_VERSION` devem
ficar alinhados com o manifest real e com
`../../implementation/current-status.md`. Este contrato nao duplica esses
valores.

## Evolucao

Historico de manifest, pacotes, release roots, previews, downloads e version
codes vive em `../release-history.md` e nos tracks historicos. Em releases
futuras, subir `latest_version_code` gera update recomendado, e subir
`minimum_supported_version_code` torna o update obrigatorio para acoes online.
