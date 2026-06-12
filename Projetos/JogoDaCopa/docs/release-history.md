# JogoDaCopa Release History

Historico de publicacoes do produto `Copa Arena Futebol`.

## Releases

| Data | Release | Canal | URL | Release root | Evidencia |
| --- | --- | --- | --- | --- | --- |
| 2026-06-12 | Web Publication V1 | Cloudflare Pages publico | `https://copa-arena-futebol.pages.dev/` | `web/v1-copa-arena-futebol-20260612-31e23ea3` | `docs/playtest-reports/track-05-data/05c-publication-report.json` |

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

## Hashes

| Artefato | Bytes | SHA256 |
| --- | ---: | --- |
| `pages/index.html` | 5701 | `f73fe6eb1f6c067197c89e9f68500b72e3cdf0da4c6410cf07bc22d98025294f` |
| `pages/index.pck` Brotli | 20570491 | `e146368591bf34821d23b8c5e0398b0562fad9b84d7958459d1b6c796ae75ec3` |
| `pages/index.wasm` Brotli | 6608968 | `6903dbdda02519655d94ef7fc0eb18e31336ac11b0f93a1abe696a654d2cf30f` |
| `pages/_headers` | 394 | `9c350676e1fdc1f68bc27c91170b529161b7b3fc08889814d0643304ed0aaca0` |
| `copa-arena-futebol-pages.zip` | 27311750 | `2189741b2edd34a086c2f12e093ac5645c270034d284e4ed1dd89de670d72e6c` |

## Limitacoes Conhecidas

- Existe um hitch unico de primeiro uso de VFX/audio por sessao. A Track 04F.3 continua adiada por decisao de publicacao Web e deve tratar esse residual sem alterar o release V1.
- Web V1 e publicacao jogavel em navegador desktop; mobile browser pode ser observado manualmente, mas nao e superficie oficialmente suportada nesta release.
- Kits e branding sao genericos/inspirados; nao ha logos oficiais FIFA, Copa, federacoes ou clubes.
