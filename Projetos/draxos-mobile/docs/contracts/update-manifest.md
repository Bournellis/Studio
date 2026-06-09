# Update Manifest Contract

- Ultima atualizacao: `2026-06-09`
- Status: `LIVE_INTERNAL_ALPHA_CONTRACT`
- Endpoint atual: `GET /release/manifest`
- Schema: `internal_alpha_manifest_v1`

O manifest de update e o contrato que permite Android, PC e Web saberem qual build esta vigente no canal `internal_alpha`.

## Fonte Atual

Durante a Internal Alpha v0, o manifest vive como Edge Function publica:

```text
https://<project-ref>.supabase.co/functions/v1/release/manifest
```

A funcao retorna um JSON sem secrets e sem depender de login. A implementacao possui um manifest padrao versionado no repo em `server/functions/release/index.ts` e `supabase/functions/release/index.ts`. Override operacional por `RELEASE_MANIFEST_JSON_BASE64` ou `RELEASE_MANIFEST_JSON` fica disponivel apenas quando `RELEASE_MANIFEST_OVERRIDE_ENABLED=1`, para evitar que secrets antigos mantenham links obsoletos.

O pacote operacional atual e `Bosque Bootstrap Authority v1` (`0.0.15-alpha.0`, version code `15`). Os downloads default do manifest continuam apontando para os artefatos configurados na funcao de release; nao derivar novos hashes ou URLs a partir do nome do pacote sem nova publicacao de artefatos.

## Payload

```json
{
  "schema_version": "internal_alpha_manifest_v1",
  "channel": "internal_alpha",
  "latest_version": "0.0.15-alpha.0",
  "latest_version_code": 15,
  "minimum_supported_version": "0.0.13-alpha.0",
  "minimum_supported_version_code": 13,
  "released_at": "2026-06-09T00:00:00Z",
  "requires_save_reset": false,
  "portal_url": "https://draxos-mobile-internal-alpha.pages.dev/",
  "notes": [
    "Bosque Bootstrap Authority v1 publicado na URL principal de Internal Alpha.",
    "APK Android, PC ZIP e Web compartilham o mesmo backend remoto publicado.",
    "Bosque integrado oculta o viewport ate aplicar bootstrap remoto ou cache canonico, evitando flash de full spawn.",
    "Arena PVE exporta HP/Mana iniciais buffados no log e o replay aplica battle_start/participants antes da primeira acao.",
    "Manifesto recomenda build 0.0.15-alpha.0 e mantem build minima 0.0.13-alpha.0.",
    "Coletas, deposito no Bau, craft local e orientacao so aparecem como salvos depois de ACK do servidor.",
    "Nodes do Bosque mantem cooldown por item via node_state.next_spawn_at e descartam rejeicoes terminais de cooldown sem fila infinita.",
    "Coleta ativa nao reinicia por movimento leve e ACKs de checkpoint nao fazem rollback visual da mesma sessao.",
    "Menu usa busy por escopo para nao congelar acoes independentes durante requisicoes pendentes.",
    "Fogueira Estavel I so libera station/receitas depois de checkpoint ACK com structures.fogueira_estavel_1 confirmado.",
    "Coletas locais de Resto ritual e Po cinzento nao alteram Ossos ou Po de Osso globais.",
    "Arena Preparacao aceita qualquer pocao simples disponivel sem regredir o slot unico por batalha.",
    "Battle Lab e Progression Lab no Web usam lab-runner remoto com a mesma conta alpha Supabase do jogo.",
    "Progression Lab usa save separado e nao pontua ranking."
  ],
  "artifacts": {
    "android": {
      "label": "Android APK",
      "url": "https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22/downloads/draxos-mobile-alpha.apk",
      "sha256": "207c0eb79f36f3420ca539fbffaf7ce92150c38271df5f608916d4c12b0e8d5c",
      "auth_required": "false"
    },
    "pc_windows": {
      "label": "PC Windows ZIP",
      "url": "https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22/downloads/draxos-mobile-alpha.zip",
      "sha256": "7c0206a3bc0e4b65a5f8a20524921820282904f69e9e8224aff4307bd5cfefa9",
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
| `ProjectInfo.APP_VERSION` | `0.0.15-alpha.0` |
| `ProjectInfo.APP_VERSION_CODE` | `15` |
| `ProjectInfo.MANIFEST_SCHEMA_VERSION` | `internal_alpha_manifest_v1` |

## Evolucao

Em `T03-P16`, os artefatos locais foram exportados e seus hashes foram registrados em `../internal-alpha-v0-export-report.md`. Em `T03-P17`, APK/PC ZIP foram publicados no Supabase Storage unlisted, Portal/Web foram publicados no Cloudflare Pages e o manifest remoto passou a usar hashes/links reais. Em `T03-P18`, o handoff final foi registrado em `../internal-alpha-v0-handoff.md`. Pacotes posteriores atualizaram o fallback versionado do repo conforme a funcao de release. Em `Bosque Bootstrap Authority v1`, o manifest padrao passou a recomendar `0.0.15-alpha.0`, manter minimo `0.0.13-alpha.0` e documentar a autoridade de bootstrap do Bosque. Os links de Android/PC acima refletem os artefatos default configurados no backend; em releases futuras, subir `latest_version_code` gera update recomendado, e subir `minimum_supported_version_code` torna o update obrigatorio para acoes online.
