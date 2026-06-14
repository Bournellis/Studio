# JogoDaCopa Release History

Historico de publicacoes do produto `Copa Arena Futebol`.

## Releases

| Data | Release | Canal | URL | Release root | Evidencia |
| --- | --- | --- | --- | --- | --- |
| 2026-06-13 | Match Polish & Broadcast Identity V1 (`v1.1.0+22850c06`) | Cloudflare Pages publico | `https://copa-arena-futebol.pages.dev/` | `web/v1-copa-arena-futebol-20260613-22850c06` | `docs/playtest-reports/track-06e-data/06e-publication-report.json` + `docs/playtest-reports/track-06f-data/06f-remote-first-minute-22850c06.json` + `docs/playtest-reports/track-06f-data/06f-remote-stability-5min-22850c06.json` + `docs/playtest-reports/track-06f-data/06f-remote-night-luma-gate-22850c06.json` + `docs/playtest-reports/track-06f-data/06f-remote-menu-footer-22850c06.png` |
| 2026-06-12 | Sensory Feedback Re-Introduction V1 (`v1.0.3+ef9c5baa`) | Cloudflare Pages publico | `https://copa-arena-futebol.pages.dev/` | `web/v1-copa-arena-futebol-20260612-ef9c5baa` | `docs/playtest-reports/track-05-data/05c-publication-report.json` + `docs/playtest-reports/track-05b1-data/05b1-remote-first-minute-gate-final-ef9c5baa.json` + `docs/playtest-reports/track-05b1-data/05b1-remote-stability-5min-final-ef9c5baa-pass2.json` |
| 2026-06-12 | First-Minute Smoothness V1 (`v1.0.2+ad82384b`) | Cloudflare Pages publico | `https://copa-arena-futebol.pages.dev/` | `web/v1-copa-arena-futebol-20260612-ad82384b` | `docs/playtest-reports/track-05-data/05c-publication-report.json` + `docs/playtest-reports/track-05b-data/05b-remote-first-minute-gate.json` + `docs/playtest-reports/track-05b-data/05b-remote-stability-5min.json` |
| 2026-06-12 | Web Stability Hotfix V1 (`v1.0.1+a850045a`) | Cloudflare Pages publico | `https://copa-arena-futebol.pages.dev/` | `web/v1-copa-arena-futebol-20260612-a850045a` | `docs/playtest-reports/track-05-data/05c-publication-report.json` + `docs/playtest-reports/track-05a-data/05a-remote-stability-gate-5min-pass.json` |
| 2026-06-12 | Web Publication V1 | Cloudflare Pages publico | `https://copa-arena-futebol.pages.dev/` | `web/v1-copa-arena-futebol-20260612-31e23ea3` | `docs/playtest-reports/track-05-data/05c-publication-report.json` |

## 2026-06-13 - Match Polish & Broadcast Identity V1

- Release publicado: `v1.1.0+22850c06` em `https://copa-arena-futebol.pages.dev/`.
- Release root publico: `web/v1-copa-arena-futebol-20260613-22850c06`.
- Preview do deploy: `https://6e95ff95.copa-arena-futebol.pages.dev`.
- Serie 06 resumida: 06A corrigiu inicio de partida (countdown unico, facing inicial/pos-gol e HUD sem hints/crosshair); 06B adicionou menu ESC completo com settings persistentes; 06C elevou o menu principal para identidade broadcast com fontes Kenney e CTA dominante; 06D aplicou scorebug/HUD broadcast, relogio, badges, STAMINA/SUPER e anuncios visuais.
- Escopo da 06E/06F: release/publicacao + hotfix de estabilidade Web; sem mudanca de gameplay.
- Primeira tentativa 06E: merge local `ea15d5dd`, `tools/validate.gd` PASS `101/1735`, publicacao `web/v1-copa-arena-futebol-20260613-ea15d5dd`; primeiro minuto remoto PASS, mas estabilidade 5min remoto FAIL com `pageErrors=2` (`AbortError: Unable to load a worklet's module.`) e heap `+19.43%`.
- Rollback 06E executado imediatamente para `v1.0.3+ef9c5baa` (`web/v1-copa-arena-futebol-20260612-ef9c5baa`) pela mesma decisao de publicacao Cloudflare.
- Hotfix 06F: merge local em `main` como `22850c06` (`merge(jogodacopa): track06f web audio stability`); `GameSettings`/menu/HUD deixam audio Web para ativacao do usuario e o probe passa a medir heap retido pos-GC no gate final.
- `tools/validate.gd` pos-merge 06F: PASS com `101` testes / `1735` asserts.
- Publicacao final: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260613-22850c06 -ConfirmRemoteMutation`; projeto Cloudflare Pages `copa-arena-futebol`.
- Gate remoto primeiro minuto: PASS, release root conferiu, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Gate remoto estabilidade 5min: PASS, release root conferiu, `pageErrors=0`, `consoleErrorCount=0`, heap retido `109,879,952 -> 111,135,074` bytes (`+1.14%`, limite `<10%`), `object_node_count 823 -> 823`, caches estaveis e pior janela 5s `105.2 FPS`.
- Gate remoto de luminancia: PASS, `luma_0_255=10.3 < 90` na captura `06f-remote-first-minute-22850c06.png`.
- Sanity do menu publico: captura `06f-remote-menu-footer-22850c06.png` mostra rodape `Copa Arena Futebol v1.1.0+22850c06 | sem logos oficiais`.
- Proximo passo: retest humano do Fabio + tester externo na URL publica, cobrindo menu broadcast, ESC completo, HUD scorebug e primeiro minuto.

## 2026-06-12 - Sensory Feedback Re-Introduction V1

- Projeto Cloudflare Pages: `copa-arena-futebol`.
- Preview publicado: `https://f66e2003.copa-arena-futebol.pages.dev`.
- URL estavel validada: `https://copa-arena-futebol.pages.dev/`.
- Publicacao remota executada por `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260612-ef9c5baa -ConfirmRemoteMutation`.
- Release publicado como `v1.0.3+ef9c5baa`.
- Mudanca: reintroduz no Web default APITO, `CONFETTI de gol`, VFX/audio 2D de chute, countdown tick, jump pad e result/rematch, com warmup real dentro do frustum atras do overlay.
- Audio Web: sem `AudioStreamPlayer3D`; players 2D de menu e partida sao criados/tocados apenas apos ativacao do navegador para evitar `PositionWorklet`.
- Relatorio completo e tabela efeito/custo/status: `docs/playtest-reports/track-05b1-sensory-feedback.md`.
- Smoke local oficial: `docs/playtest-reports/track-05b1-data/05b1-local-final-first-minute-after-menu-audio-defer.json` e `docs/playtest-reports/track-05b1-data/05b1-local-final-stability-5min.json`.
- Smoke remoto oficial: `docs/playtest-reports/track-05b1-data/05b1-remote-first-minute-gate-final-ef9c5baa.json` e `docs/playtest-reports/track-05b1-data/05b1-remote-stability-5min-final-ef9c5baa-pass2.json`.
- Smoke remoto: release root conferiu, `event.rematch` observado, page errors `0`, runtime console errors `0`, primeiro minuto `0` hitches `>100ms`, estabilidade 5min PASS.
- Loading local primeira visita medido em `~17.8s-18.3s`, acima do teto `8s`; registrado para decisao de Fabio.
- `tools/validate.gd --profile=full`: PASS, 86 testes, 1272 asserts, Web gzip transfer `30.32 MiB / 50.00 MiB`.

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

## Hashes - Sensory Feedback Re-Introduction V1

| Artefato | Bytes | SHA256 |
| --- | ---: | --- |
| `pages/index.html` | 5701 | `ace3cf0a5ac559a7d01a940b1a0d4f3efd5aee73cc8e12669a4607b319f489e6` |
| `pages/index.pck` Brotli | 20587717 | `05043661b06699c96ba97feeec026a4a7a1e56aa7ef984d9eda8edeaa2f27b56` |
| `pages/index.wasm` Brotli | 6608968 | `6903dbdda02519655d94ef7fc0eb18e31336ac11b0f93a1abe696a654d2cf30f` |
| `pages/_headers` | 394 | `9c350676e1fdc1f68bc27c91170b529161b7b3fc08889814d0643304ed0aaca0` |
| `copa-arena-futebol-pages.zip` | 27328981 | `cf6734b6c1d98b20cc14ae234a6d0c8cb182c82ec3701b95bf1b5f2d0abe7e81` |

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

- A Track 05B.1 reintroduziu os feedbacks transientes Web-safe no default publico, mas manteve o pacote pesado completo de `goal` fora do default; o `CONFETTI de gol` esta ativo.
- Audio Web automatizado fica silencioso ate ativacao do navegador para evitar `PositionWorklet`; sessoes humanas desbloqueiam os players 2D ao clicar no menu.
- Loading remoto de producao ficou abaixo de `8s` na 05B, mas a 05B.1 mediu loading local primeira visita em `~17.8s-18.3s`, acima do teto solicitado, por causa do warmup real dos efeitos reintroduzidos.
- Web V1 e publicacao jogavel em navegador desktop; mobile browser pode ser observado manualmente, mas nao e superficie oficialmente suportada nesta release.
- Kits e branding sao genericos/inspirados; nao ha logos oficiais FIFA, Copa, federacoes ou clubes.
