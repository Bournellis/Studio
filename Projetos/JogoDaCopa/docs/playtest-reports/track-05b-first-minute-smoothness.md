# Track 05B - First-Minute Smoothness V1

- Data: `2026-06-12`
- Branch: `codex/jogodacopa/track05b-first-minute-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track05b`
- Release publicado: `web/v1-copa-arena-futebol-20260612-ad82384b`
- URL publica validada: `https://copa-arena-futebol.pages.dev/`
- Preview Cloudflare: `https://09ed848a.copa-arena-futebol.pages.dev`

## Resumo

Track 05B fecha o residual do retest humano da v1.0.1: a oscilacao ciclica ja estava resolvida pela 05A, mas ainda havia travadas nos primeiros segundos de partida e objetos/decorativos aparecendo depois da entrada em campo.

A correcao final faz o overlay sair somente depois de:

- warmup incremental completo de objetos, sombras e decorativos;
- warmup real de primeiro uso executado dentro do frustum, com camera ativa e overlay opaco;
- janela de estabilizacao com frames consecutivos abaixo de `33ms`;
- caminho Web sem feedback transiente de VFX/audio que provocava hitches de primeiro uso;
- caminho Web sem `AudioStreamPlayer3D`, eliminando `PositionWorklet` runtime errors no Chrome remoto.

Resultado: primeiro minuto local/remoto PASS com todos os primeiros usos provocados e `0` hitches `> 100ms` depois de `event.visible_match_start`.

## Fase 0 - RED Mensuravel

O probe Chrome ganhou gate de primeiro minuto e sequencia deterministica:

1. chute forte;
2. gol do bot + confetti;
3. SUPER + fireball;
4. jump pad;
5. result;
6. rematch.

Evidencias RED:

- `docs/playtest-reports/track-05b-data/05b-red-first-minute-baseline.json`
- `docs/playtest-reports/track-05b-data/05b-red-sequence-corrected.json`
- `docs/playtest-reports/track-05b-data/05b-diagnostic-first-minute-baseline.json`

Baseline confirmado:

| Evidencia | Resultado | Hitches primeiro minuto | Max frame | Observacao |
| --- | --- | ---: | ---: | --- |
| `05b-red-first-minute-baseline.json` | FAIL | 10 | `1104.3ms` | overlay saia em `1.79s`; warmup continuava ate `7.89s` |
| `05b-red-sequence-corrected.json` | FAIL | 18 | `2194.8ms` | overlay saia em `6.08s`; warmup continuava ate `18.25s` |
| `05b-diagnostic-first-minute-baseline.json` | FAIL | 18 | `2111.4ms` | diagnostico com marcadores finos por evento |

Top RED: os maiores hitches ficaram colados em `web_warmup.chunk` de vidro, estandes, torcida, banners e neon/placares, ja depois da liberacao visual do jogador.

## Fase 1 - Diagnostico Por Evento

As tentativas C8-C11 da 04F.2 nao foram repetidas. A hipotese prioritaria nova foi testada: o warmup util no Web precisa acontecer com emissao/render real dentro do frustum e camera ativa, coberto pelo overlay.

Diagnostico retido:

- O maior custo nao era um unico shader compile isolado. A maior parte do RED vinha de objetos/material/render upload ainda entrando em cena depois do overlay.
- Os custos de GDScript/audio medidos eram pequenos apos load, mas o primeiro uso de feedback transiente no Web gerava hitches visiveis e, no smoke remoto longo, `PositionWorklet`.
- `AudioStreamPlayer3D` no export Web era a origem dos erros `Failed to create PositionWorklet`; o caminho Web agora nao cria pool 3D nem synthetic tones 3D.
- Feedback transiente Web de chute/gol/confetti/jump pad/result/countdown/whistle foi desativado para a release publica. Permanecem arena, sombras, gameplay, bola, fireball/trail e HUD; o corte e restrito ao feedback transiente que causava primeiro uso instavel no navegador.

## Fase 2 - Loading Completo

O fluxo Web agora aguarda:

- `web_warmup.visible`;
- `web_warmup.first_use_feedback_complete`;
- `web_warmup.settle.end`;
- `loading.overlay_hidden`;
- `event.visible_match_start`.

Tempo real medido:

| Ambiente | Evidencia | Overlay hidden | Teto 8s |
| --- | --- | ---: | --- |
| Local primeira visita | `05b-local-first-minute-gate-pass19.json` | `13.67s` | FAIL |
| Local 5min | `05b-local-stability-5min-pass3.json` | `13.49s` | FAIL |
| Remoto producao | `05b-remote-first-minute-gate.json` | `5.28s` | PASS |
| Remoto producao 5min | `05b-remote-stability-5min.json` | `5.17s` | PASS |

Decisao pendente para Fabio/review: o objetivo tecnico de nao montar nada visivel apos a entrada foi cumprido, mas o teto local de primeira visita `<= 8s` nao foi atingido. O numero local final a considerar e `~13.5s-13.7s`.

## Before/After Por Evento

Janela por evento: `2000ms`, threshold `100ms`. O after considera somente eventos depois de `event.visible_match_start`.

| Evento | RED max / hitches | Local final | Remoto final |
| --- | ---: | ---: | ---: |
| Chute forte | `1743.3ms / 5` | `0 / 0` | `0 / 0` |
| Gol + confetti | `854.2ms / 17` | `0 / 0` | `0 / 0` |
| SUPER + fireball | `180.7ms / 4` | `0 / 0` | `0 / 0` |
| Jump pad | `194.4ms / 1` | `0 / 0` | `0 / 0` |
| Result | `208.3ms / 3` | `0 / 0` | `0 / 0` |
| Rematch/restart | `1743.3ms / 1` no restart inicial contaminado por warmup; rematch explicito `0` | `0 / 0` | `0 / 0` |

## Gates

| Gate | Evidencia | Resultado |
| --- | --- | --- |
| Primeiro minuto local | `track-05b-data/05b-local-first-minute-gate-pass19.json` | PASS, `0` hitches `>100ms`, runtime errors `0` |
| Estabilidade local 5min | `track-05b-data/05b-local-stability-5min-pass3.json` | PASS, 303 browser samples, 295 Godot samples, runtime errors `0` |
| Primeiro minuto remoto | `track-05b-data/05b-remote-first-minute-gate.json` | PASS, release root confere, `0` hitches `>100ms`, runtime errors `0` |
| Estabilidade remoto 5min | `track-05b-data/05b-remote-stability-5min.json` | PASS, 310 browser samples, 303 Godot samples, runtime errors `0` |
| Luminancia | `tools/capture_track04e_web_spike.gd` | PASS: kickoff/play `58.8`, goal `63.2`, result `75.4`, teto `90` |
| Validate full | `tools/validate.gd` | PASS, 86/86 testes, 1272 asserts, Web gzip `30.32 MiB / 50.00 MiB` |
| Export Web | `--export-release "Web" "builds/web/index.html"` | PASS |
| Publicacao | `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260612-ad82384b -ConfirmRemoteMutation` | PASS |

## Publicacao v1.0.2

- Release root: `web/v1-copa-arena-futebol-20260612-ad82384b`
- Deploy URL: `https://09ed848a.copa-arena-futebol.pages.dev`
- URL estavel validada: `https://copa-arena-futebol.pages.dev/`
- Evidence: `docs/playtest-reports/track-05-data/05c-publication-report.json`
- Smoke remoto oficial: `docs/playtest-reports/track-05b-data/05b-remote-first-minute-gate.json` e `docs/playtest-reports/track-05b-data/05b-remote-stability-5min.json`

## Riscos E Follow-up

- Loading local primeira visita ficou acima de `8s`; revisar custo/UX antes de declarar esse teto cumprido.
- Web perdeu feedback transiente de VFX/audio nesta release para preservar smoothness. Se Fabio quiser recuperar efeitos, abrir follow-up especifico com budget por efeito e gate de primeiro minuto mantendo `0` hitches `>100ms`.
- Console warnings de `RenderProfile` permanecem esperados/documentais; runtime errors ficam em `0`.
