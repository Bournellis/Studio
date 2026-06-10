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

O pacote operacional publicado atual e `Bosque Overlay Interactive Controls Authority v1` (`0.0.21-alpha.0`, version code `21`). Os downloads default do manifest continuam apontando para os artefatos configurados na funcao de release; nao derivar novos hashes ou URLs a partir do nome do pacote sem nova publicacao de artefatos. `Bosque Overlay Menu Action Authority v1` (`0.0.20-alpha.0`, version code `20`) permanece como pacote historico anterior de botoes internos do overlay.

## Payload

```json
{
  "schema_version": "internal_alpha_manifest_v1",
  "channel": "internal_alpha",
  "latest_version": "0.0.21-alpha.0",
  "latest_version_code": 21,
  "minimum_supported_version": "0.0.13-alpha.0",
  "minimum_supported_version_code": 13,
  "released_at": "2026-06-09T00:00:00Z",
  "requires_save_reset": false,
  "portal_url": "https://draxos-mobile-internal-alpha.pages.dev/",
  "notes": [
    "Bosque Overlay Interactive Controls Authority v1 publicado na URL principal de Internal Alpha.",
    "APK Android, PC ZIP e Web compartilham o mesmo backend remoto.",
    "Bosque permanece vivo e visivel enquanto Arena, Refugio/Base, Loja, Social e Perfil abrem como overlay.",
    "Voltar, Fechar e Esc/Web usam a mesma autoridade de fechamento do overlay e devolvem input ao mesmo node do Bosque sem rebootstrap.",
    "Social, Loja e Arena usam controles interativos no overlay com foco, texto, confirmacao, retomada e abandono validados no Web/canvas.",
    "Menus abertos pelo Bosque usam rota de overlay sem acao mutante fantasma.",
    "Refresh read-only nao bloqueia fechamento; respostas tardias sao ignoradas quando o overlay fecha ou muda de rota.",
    "Arena PVE roda dentro do overlay e bloqueia fechamento apenas durante replay ou mutacao critica explicita.",
    "Arena PVE exporta HP/Mana iniciais buffados no log e o replay aplica battle_start/participants antes da primeira acao.",
    "Manifesto recomenda build 0.0.21-alpha.0 e mantem build minima 0.0.13-alpha.0.",
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
      "url": "https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/download?artifact=android",
      "sha256": "fc4f414d7c1f769a0505c2ff9cef01ad919a149f28279c4ffc13cf56ce2aa06c",
      "auth_required": true
    },
    "pc_windows": {
      "label": "PC Windows ZIP",
      "url": "https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/download?artifact=pc_windows",
      "sha256": "a0621dcd27c1fa6d78f0e4c4a393b1f5ee21a2138901eba170f7558aeea94c9f",
      "auth_required": true
    },
    "web": {
      "label": "Web",
      "url": "https://draxos-mobile-internal-alpha.pages.dev/web/index.html"
    }
  },
  "known_issues": [
    "Fallback estatico deve permanecer alinhado ao manifest remoto versionado; o manifest override continua sendo a evidencia operacional de publicacao.",
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
| `ProjectInfo.APP_VERSION` | `0.0.21-alpha.0` |
| `ProjectInfo.APP_VERSION_CODE` | `21` |
| `ProjectInfo.MANIFEST_SCHEMA_VERSION` | `internal_alpha_manifest_v1` |

## Evolucao

Em `T03-P16`, os artefatos locais foram exportados e seus hashes foram registrados em `../internal-alpha-v0-export-report.md`. Em `T03-P17`, APK/PC ZIP foram publicados no Supabase Storage unlisted, Portal/Web foram publicados no Cloudflare Pages e o manifest remoto passou a usar hashes/links reais. Em `T03-P18`, o handoff final foi registrado em `../internal-alpha-v0-handoff.md`. Pacotes posteriores atualizaram o fallback versionado do repo conforme a funcao de release. Em `Bosque Diegetic Launcher Foundation v1`, o manifest remoto passou a recomendar `0.0.16-alpha.0`, manter minimo `0.0.13-alpha.0`, documentar o launcher diegetico do Bosque e apontar downloads Android/PC para `GET /release/download` com `INTERNAL_ALPHA_RELEASE_ROOT` no root publicado. Em `Bosque Overlay Navigation Hotfix v1`, o manifest passou a recomendar `0.0.18-alpha.0`, manter minimo `0.0.13-alpha.0` e documentar o hotfix de `Fechar`, `Voltar` e Esc sobre o overlay persistente do Bosque vivo. Em `Bosque Overlay Interaction Authority v1`, o manifest passou a recomendar `0.0.19-alpha.0`, manter minimo `0.0.13-alpha.0`, documentar a autoridade unica de fechamento/back/Esc no Web e preservar fechamento durante refresh read-only com guarda contra respostas tardias. Em `Bosque Overlay Menu Action Authority v1`, o manifest passou a recomendar `0.0.20-alpha.0`, manter minimo `0.0.13-alpha.0` e documentar botoes internos de Account/Base/Shop/Social/Arena executando dentro do overlay com clique real Web/canvas. Em `Bosque Overlay Interactive Controls Authority v1`, o manifest passa a recomendar `0.0.21-alpha.0`, manter minimo `0.0.13-alpha.0` e documentar foco/texto do Social, confirmacao propria da Loja e retomada/abandono da Arena dentro do overlay com smoke Web/canvas real. Em releases futuras, subir `latest_version_code` gera update recomendado, e subir `minimum_supported_version_code` torna o update obrigatorio para acoes online.
