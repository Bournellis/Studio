# DraxosMobile - Internal Alpha v0 Handoff

- Data: `2026-05-31`
- Status: `RPGSUAVE_INTEGRATED_ALPHA_PUBLISHED - AWAITING_HUMAN_PLAYTEST`
- Canal: `internal_alpha`
- Versao: `0.0.1-alpha.0`
- Version code: `1`
- Backend remoto: `https://armxgipvnbbshzqawklw.supabase.co`
- Portal atual: `https://d1e73b74.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web atual: `https://d1e73b74.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

## Pacote Para Teste

| Item | URL |
|---|---|
| Portal | `https://d1e73b74.draxos-mobile-internal-alpha.pages.dev/portal/index.html` |
| Web | `https://d1e73b74.draxos-mobile-internal-alpha.pages.dev/web/index.html` |
| Android APK | `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-rpgsuave-integrated-alpha-20260531-0aa3969/downloads/draxos-mobile-alpha.apk` |
| PC ZIP | `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-rpgsuave-integrated-alpha-20260531-0aa3969/downloads/draxos-mobile-alpha.zip` |

| Artefato | Bytes | SHA256 |
|---|---:|---|
| Android APK | `31725206` | `041dc7ff351214b77b0835991639b67c239152e0643237c4ef8ca7bc7b7933ee` |
| PC Windows ZIP | `40188217` | `669013b975e9611e9b2e526fae1f2030afd42c2f027705e142a0fc81e41eabe9` |
| Web index | `5442` | `fba1727cfa5bbf0c46c859c5581773378a2ca55004774b1c3ee08623c117fe2c` |

## Atualizacao Rpgsuave Integrated Alpha - 2026-05-31

- Release root atual:
  `internal-alpha/v0-rpgsuave-integrated-alpha-20260531-0aa3969`.
- Portal:
  `https://d1e73b74.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web:
  `https://d1e73b74.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-rpgsuave-integrated-alpha-20260531-0aa3969/downloads/draxos-mobile-alpha.apk`
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-rpgsuave-integrated-alpha-20260531-0aa3969/downloads/draxos-mobile-alpha.zip`

| Artefato | Bytes | SHA256 |
|---|---:|---|
| Android APK | `31725206` | `041dc7ff351214b77b0835991639b67c239152e0643237c4ef8ca7bc7b7933ee` |
| PC Windows ZIP | `40188217` | `669013b975e9611e9b2e526fae1f2030afd42c2f027705e142a0fc81e41eabe9` |
| Web index | `5442` | `fba1727cfa5bbf0c46c859c5581773378a2ca55004774b1c3ee08623c117fe2c` |

Escopo publicado: Rpgsuave Bosque em Labs Dev, Minigame Platform v0,
Reward Bridge v0, manifest remoto atualizado e Portal/Web no Cloudflare Pages
preview acima. Validacao: Full gate local, smokes remotos de manifest,
artefatos, minigame integrado e hash completo de APK/ZIP verdes.

## Atualizacao Pos-Handoff Track 10 - 2026-05-28

- Builds Android/PC/Web foram republicadas apos a rework de apresentacao da batalha.
- Manifest remoto atual: `released_at = 2026-05-28T04:50:33Z`, version code `1`, `requires_save_reset = false`.
- Deploy Cloudflare Pages verificado: `https://36b1d46c.draxos-mobile-internal-alpha.pages.dev`.
- Dominio estavel `https://draxos-mobile-internal-alpha.pages.dev` esta protegido por Cloudflare Access; validacao publica anonima deve usar preview liberado ou sessao autenticada.
- Este handoff continua valido como pacote Internal Alpha v0, mas a experiencia visual atual corresponde a Track 10 + Track 11.

## Release Notes

- Batalha server-authoritative com replay visual 2D procedural.
- Conta alpha por email/senha, username e convite.
- Dois saves por conta: `normal` e `progression_lab`.
- Save `progression_lab` fica isolado e nao pontua ranking.
- Base Manager, Social, Competicao e Loja estao jogaveis em nivel alpha.
- Loja usa redeems diarios de Diamante e produtos proof-of-concept, sem pagamento real.
- Portal/Web rodam no Cloudflare Pages; downloads e assets grandes ficam no Supabase Storage.
- O app consulta `release/manifest` no boot e bloqueia acoes online se `minimum_supported_version_code` subir.

## Validacao De Handoff

- Godot validate/GUT: verde em 2026-05-27 com `54/54` testes e `367` asserts.
- Exports Android/PC/Web: verdes em 2026-05-27.
- Smokes remotos: release manifest, email/senha, batalha, base, social, competicao, monetizacao e telemetria verdes em 2026-05-27.
- Cloudflare Pages: `portal-preview`, `web-preview`, `portal-stable` e `web-stable` retornaram `200 text/html` e HTML igual ao pacote local.
- Downloads: Android APK e PC ZIP retornaram `200` com tamanhos esperados.
- T03-P18: `release/manifest` redeployado com texto pos-signoff; Cloudflare Pages redeployado em `https://3a994d39.draxos-mobile-internal-alpha.pages.dev`.
- T03-P18 smokes: `release_manifest_smoke.ts` remoto e `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1` passaram.
- Fabio aprovou avancar para handoff em 2026-05-27.

## Bugs Conhecidos E Riscos

- Android APK usa `debug_fallback`; configurar keystore release dedicada antes de uma distribuicao mais ampla.
- Layout Android paisagem foi aprovado como suficiente, mas ainda deve ser observado em aparelho real.
- O menu rolavel pode ficar cansativo no celular; feedback real deve virar item de UX posterior.
- Nao ha arte final, animacoes, icones definitivos ou efeitos visuais finais.
- Loja nao possui pagamento real e serve apenas como simulacao premium/proof-of-concept.
- Portal visual e suficiente para handoff, mas Fabio pretende refinar depois de `T03-P18`.
- Web usa hospedagem hibrida Cloudflare Pages + Supabase Storage; validar `/portal/index.html` e `/web/index.html` apos cada deploy.
- Dominio estavel do Cloudflare Pages pode exigir Cloudflare Access; usar preview liberado ou login Access para validacao Web anonima.
- Supabase Free e adequado para esta alpha; Backend Proprio + Postgres segue como plano de saida preferido.

## Instrucoes De Update

1. Implementar a mudanca e atualizar versionamento se necessario em `ProjectInfo` e no manifest.
2. Rodar validacao Godot e smokes relevantes.
3. Exportar Android, PC e Web com `tools/export_internal_alpha.ps1`.
4. Publicar APK/PC e atualizar manifest com `tools/publish_internal_alpha.ps1 -StaticSiteBaseUrl "https://draxos-mobile-internal-alpha.pages.dev" -UseManifestSecret`.
5. Gerar pacote Cloudflare com `tools/build_cloudflare_pages_package.ps1`.
6. Publicar Cloudflare Pages e validar Portal/Web no preview e dominio estavel.
7. Rodar `release_manifest_smoke.ts` e smoke remoto de release.
8. Se o update quebrar save, marcar isso explicitamente nas notas e definir plano de reset antes de subir `minimum_supported_version_code`.

## Proximo Ciclo

- Usar a build fechada com Fabio + tester e registrar bugs reais.
- Priorizar feedback de usabilidade Android, fluxo de onboarding/login, clareza dos tooltips e loop batalha -> base -> loja/social/competicao.
- Definir a proxima fase apos a rodada de feedback: polish de UI/UX, bugs bloqueantes ou expansao de sistema.
