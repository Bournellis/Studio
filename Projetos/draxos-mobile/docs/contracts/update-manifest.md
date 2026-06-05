# Update Manifest Contract

- Ultima atualizacao: `2026-06-05`
- Status: `LIVE_INTERNAL_ALPHA_CONTRACT`
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
  "released_at": "2026-06-05T07:40:08Z",
  "requires_save_reset": false,
  "portal_url": "https://draxos-mobile-internal-alpha.pages.dev/",
  "notes": [
    "Bosque v3 UX/Feel publicado na URL principal de Internal Alpha.",
    "APK Android, PC ZIP e Web compartilham o mesmo backend remoto publicado.",
    "Portal/Web rodam no Cloudflare Pages; downloads e assets grandes continuam no Supabase Storage.",
    "Bosque v3 UX/Feel melhora colisao/spawn, feedback de coleta, deposito, craft, fogueira, landmarks e resumo de visita no Bosque.",
    "Technical Hardening e Openworld Main Menu Sync seguem preservados dentro deste pacote.",
    "Battle Lab e Progression Lab no Web usam lab-runner remoto com a mesma conta alpha Supabase do jogo.",
    "Progression Lab usa save separado e nao pontua ranking."
  ],
  "artifacts": {
    "android": {
      "label": "Android APK",
      "url": "https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45/downloads/draxos-mobile-alpha.apk",
      "sha256": "4455af96d285a2ac3f5d8268d5d044ff4933eb10303dfbe113d3aba0811efaa5",
      "auth_required": "false"
    },
    "pc_windows": {
      "label": "PC Windows ZIP",
      "url": "https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45/downloads/draxos-mobile-alpha.zip",
      "sha256": "bd2ce982a4bba80eedbd8ff165537dbe4bdc49183139d6e5b8e7e598cff85f93",
      "auth_required": "false"
    },
    "web": {
      "label": "Web",
      "url": "https://draxos-mobile-internal-alpha.pages.dev/web/index.html"
    }
  },
  "known_issues": [
    "Fallback estatico nao substitui o manifest remoto versionado para hashes exatos de artefatos.",
    "Layout Android paisagem ainda precisa de ergonomia real no aparelho.",
    "APK desta publicacao usa debug_fallback enquanto a keystore release dedicada nao estiver configurada.",
    "Web usa hospedagem hibrida Cloudflare Pages + Supabase Storage; validar / e /web/index.html apos cada deploy.",
    "Dominio production fixo do Cloudflare Pages e o link oficial de playtest; se Cloudflare Access estiver ativo, validar conteudo com sessao autenticada."
  ]
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

Em `T03-P16`, os artefatos locais foram exportados e seus hashes foram registrados em `../internal-alpha-v0-export-report.md`. Em `T03-P17`, APK/PC ZIP foram publicados no Supabase Storage unlisted, Portal/Web foram publicados no Cloudflare Pages e o manifest remoto passou a usar hashes/links reais. Em `T03-P18`, o handoff final foi registrado em `../internal-alpha-v0-handoff.md`. Em `Openworld Main Menu Sync`, o fallback versionado do repo passou a apontar para o release root de conteudo publicado. Em `Technical Hardening`, o fallback versionado do repo passou a apontar para `internal-alpha/v0-technical-hardening-20260605-8e54a1f` com hashes dos artefatos publicados. Em `Bosque v3 UX/Feel`, o fallback versionado passou a apontar para `internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45` com hashes dos artefatos publicados. Em releases futuras, subir `latest_version_code` gera update recomendado; subir `minimum_supported_version_code` torna o update obrigatorio para acoes online.
