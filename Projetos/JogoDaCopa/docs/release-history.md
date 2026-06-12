# JogoDaCopa Release History

Historico de publicacoes do produto `Copa Arena Futebol`.

## Releases

| Data | Release | Canal | URL | Release root | Evidencia |
| --- | --- | --- | --- | --- | --- |
| 2026-06-12 | First-Minute Smoothness V1 (`v1.0.2+ad82384b`) | Cloudflare Pages publico | `https://copa-arena-futebol.pages.dev/` | `web/v1-copa-arena-futebol-20260612-ad82384b` | `docs/playtest-reports/track-05-data/05c-publication-report.json` + `docs/playtest-reports/track-05b-data/05b-remote-first-minute-gate.json` + `docs/playtest-reports/track-05b-data/05b-remote-stability-5min.json` |
| 2026-06-12 | Web Stability Hotfix V1 (`v1.0.1+a850045a`) | Cloudflare Pages publico | `https://copa-arena-futebol.pages.dev/` | `web/v1-copa-arena-futebol-20260612-a850045a` | `docs/playtest-reports/track-05-data/05c-publication-report.json` + `docs/playtest-reports/track-05a-data/05a-remote-stability-gate-5min-pass.json` |
| 2026-06-12 | Web Publication V1 | Cloudflare Pages publico | `https://copa-arena-futebol.pages.dev/` | `web/v1-copa-arena-futebol-20260612-31e23ea3` | `docs/playtest-reports/track-05-data/05c-publication-report.json` |

## 2026-06-12 - First-Minute Smoothness V1

- Projeto Cloudflare Pages: `copa-arena-futebol`.
- Preview publicado: `https://09ed848a.copa-arena-futebol.pages.dev`.
- URL estavel validada: `https://copa-arena-futebol.pages.dev/`.
- Publicacao remota executada por `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260612-ad82384b -ConfirmRemoteMutation`.
- Hotfix: overlay de loading so sai apos warmup completo de render/objetos/decorativos, warmup real de primeiro uso dentro do frustum e janela estavel; caminho Web corta feedback transiente de primeiro uso e nao cria `AudioStreamPlayer3D`, removendo `PositionWorklet`.
- Suporte externo: release publicado como `v1.0.2+ad82384b`.
- Causa raiz, RED e before/after por evento: `docs/playtest-reports/track-05b-first-minute-smoothness.md`.
- Smoke local oficial: `docs/playtest-reports/track-05b-data/05b-local-first-minute-gate-pass19.json` e `docs/playtest-reports/track-05b-data/05b-local-stability-5min-pass3.json`.
- Smoke remoto oficial: `docs/playtest-reports/track-05b-data/05b-remote-first-minute-gate.json` e `docs/playtest-reports/track-05b-data/05b-remote-stability-5min.json`.
- Smoke remoto: release root conferiu, page errors `0`, runtime console errors `0`, primeiro minuto `0` hitches `>100ms`, estabilidade 5min PASS com 310 browser samples e 303 Godot samples.
- Loading medido: remoto `~5.3s` PASS contra teto `8s`; local primeira visita `~13.5s-13.7s` acima do teto e registrado para decisao de Fabio.
- `tools/validate.gd --profile=full`: PASS, 86 testes, 1272 asserts, Web gzip transfer `30.32 MiB / 50.00 MiB`.

## 2026-06-12 - Web Stability Hotfix V1

- Projeto Cloudflare Pages: `copa-arena-futebol`.
- Preview publicado: `https://a8305492.copa-arena-futebol.pages.dev`.
- URL estavel validada: `https://copa-arena-futebol.pages.dev/`.
- Publicacao remota executada por `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260612-a850045a -ConfirmRemoteMutation`.
- Hotfix: reduz churn por frame no Web ao atualizar HUD/placares em cadencia de 0.1s com flush imediato em mudancas de estado, evita reatribuicao de labels iguais, remove pointer-lock do modo de captura/probe e adiciona gate Chrome de estabilidade de 5 minutos.
- Suporte externo: rodape do menu exibe `Copa Arena Futebol v1.0.1+a850045a | sem logos oficiais`.
- Causa raiz e baseline: `docs/playtest-reports/track-05a-web-stability.md`.
- Smoke local oficial: `docs/playtest-reports/track-05a-data/05a-local-stability-gate-5min-pass.json`.
- Smoke remoto oficial: `docs/playtest-reports/track-05a-data/05a-remote-stability-gate-5min-pass.json`.
- Smoke remoto: release root conferiu com cache-buster, page errors `0`, runtime console errors `0`, heap retido `+3.77%`, `object_node_count 766 -> 766`, pior janela 5s `126.0 FPS`.
- `tools/validate.gd --profile=full`: PASS, 86 testes, 1272 asserts.

## 2026-06-12 - Web Publication V1

- Projeto Cloudflare Pages: `copa-arena-futebol`.
- Preview publicado: `https://7a19a00f.copa-arena-futebol.pages.dev`.
- URL estavel: `https://copa-arena-futebol.pages.dev/`.
- Publicacao remota executada por `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260612-31e23ea3 -ConfirmRemoteMutation`.
- Pacote Pages usa `index.pck` e `index.wasm` pre-comprimidos com Brotli, mantendo os nomes publicos e servindo com `Content-Encoding: br`, para respeitar o limite de `25 MiB` por asset do Cloudflare Pages.
- Smoke remoto oficial: `docs/playtest-reports/track-05-data/05c-remote-menu-smoke.json`.
- Screenshot do smoke: `docs/playtest-reports/track-05-data/05c-remote-menu-smoke.png`.
- Smoke remoto: release root conferiu, `menu.ready.end` observado, page errors `0`, runtime console errors `0`.
- `tools/validate.gd`: PASS, 86 testes, 1264 asserts, Web gzip transfer `30.30 MiB / 50.00 MiB`.

## Hashes - First-Minute Smoothness V1

| Artefato | Bytes | SHA256 |
| --- | ---: | --- |
| `pages/index.html` | 5701 | `6714a1d8e6147dbe8b81a88b905f43f9c64d2d8bc5019ae61ad8df9181f46315` |
| `pages/index.pck` Brotli | 20580742 | `b8e3b97bb174fbcc1d16ba38319a608e5e0d86bab8097e3ca9ce2d3461825820` |
| `pages/index.wasm` Brotli | 6608968 | `6903dbdda02519655d94ef7fc0eb18e31336ac11b0f93a1abe696a654d2cf30f` |
| `pages/_headers` | 394 | `9c350676e1fdc1f68bc27c91170b529161b7b3fc08889814d0643304ed0aaca0` |
| `copa-arena-futebol-pages.zip` | 27321981 | `825c34e5d117cbee96ed891d38d6bdf3184b0d8c2e8ffc82e3f534dc55f67880` |

## Hashes - Web Stability Hotfix V1


| Artefato | Bytes | SHA256 |
| --- | ---: | --- |
| `pages/index.html` | 5701 | `658af55aea1ac9ffc571e873e3aca1c47f1c8986f52f9f3544890059cbc8892c` |
| `pages/index.pck` Brotli | 20584773 | `935d9a2402474ed6f7d6e7e9fd3e72e982826829c0d749e92cebbd4c2eb288b7` |
| `pages/index.wasm` Brotli | 6608968 | `6903dbdda02519655d94ef7fc0eb18e31336ac11b0f93a1abe696a654d2cf30f` |
| `pages/_headers` | 394 | `9c350676e1fdc1f68bc27c91170b529161b7b3fc08889814d0643304ed0aaca0` |
| `copa-arena-futebol-pages.zip` | 27325962 | `670611a6d8866ad8a52e3b4aff26bb474a4fd02d267fae7b62912df79096fe16` |

## Hashes - Web Publication V1

| Artefato | Bytes | SHA256 |
| --- | ---: | --- |
| `pages/index.html` | 5701 | `f73fe6eb1f6c067197c89e9f68500b72e3cdf0da4c6410cf07bc22d98025294f` |
| `pages/index.pck` Brotli | 20570491 | `e146368591bf34821d23b8c5e0398b0562fad9b84d7958459d1b6c796ae75ec3` |
| `pages/index.wasm` Brotli | 6608968 | `6903dbdda02519655d94ef7fc0eb18e31336ac11b0f93a1abe696a654d2cf30f` |
| `pages/_headers` | 394 | `9c350676e1fdc1f68bc27c91170b529161b7b3fc08889814d0643304ed0aaca0` |
| `copa-arena-futebol-pages.zip` | 27311750 | `2189741b2edd34a086c2f12e093ac5645c270034d284e4ed1dd89de670d72e6c` |

## Limitacoes Conhecidas

- A Track 05B removeu o hitch visivel de primeiro uso no primeiro minuto publicado, mas fez isso cortando feedback transiente de VFX/audio no perfil Web. Fabio aprovou o follow-up `Track 05B.1` para reintroduzir esses efeitos um por vez com budget por efeito.
- Loading remoto de producao ficou abaixo de `8s`, mas loading local primeira visita medido em `~13.5s-13.7s` continua acima do teto solicitado e fica registrado para acompanhamento em follow-up.
- Web V1 e publicacao jogavel em navegador desktop; mobile browser pode ser observado manualmente, mas nao e superficie oficialmente suportada nesta release.
- Kits e branding sao genericos/inspirados; nao ha logos oficiais FIFA, Copa, federacoes ou clubes.
