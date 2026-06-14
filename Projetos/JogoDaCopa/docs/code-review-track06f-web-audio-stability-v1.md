# Code Review - JogoDaCopa Track 06F - Web Audio Stability V1

- Data: `2026-06-13`
- Revisor: Claude (review pre-merge da hotfix da regressao remota da 06E)
- Branch: `codex/jogodacopa/track06f-web-audio-stability-v1` (commit `3e0e542b`)
- Base: `main` (com 06A-06E mergeadas; baseline publica revertida para `v1.0.3+ef9c5baa`)
- Veredito: `APROVADO no code review`. Causa raiz correta, sem leak de engine, gate 5min local verde. Prova decisiva fica no gate REMOTO pos-republicacao.

## Causa raiz (correta e documentada)

A 06E falhou o gate remoto de 5 min com 2x `DOMException: AbortError: Unable to load a worklet's module` (worklet de audio do Web) + heap pre-GC `+15.24%`. A regressao veio da Serie 06 tocar `AudioServer`/volumes no Web ANTES do gesto do usuario (o autoload `GameSettings` da 06B no boot, e aplicacao de volume no menu/HUD), o que dispara o carregamento do worklet de audio antes do navegador permitir - abortando.

## Fix (solido, sem degradar humano)

- `GameSettings._can_touch_audio_server()`: no Web, so toca `AudioServer` se `_web_audio_unlocked`, confirmado via `JavaScriptBridge` lendo `navigator.userActivation.hasBeenActive` (poll de 500ms). Fora do Web, sempre permitido.
- `_ready` nao cria buses no boot; `apply_audio_settings(from_user_gesture)` sai cedo no Web sem gesto; `set_volume` reaplica volumes persistidos no primeiro gesto.
- `main_menu_root.gd` e `football_hud.gd`: `_ensure_audio_buses` so fora do Web; `_set_bus_volume` no Web exige gesto; `_play_ui_sound`/troca de volume reaplicam os volumes apos unlock; `_get_bus_volume_linear` no Web retorna `1.0` sem tocar `AudioServer`.
- Efeito: headless/probe (sem gesto) nao carrega worklet -> sem `AbortError`. Jogador humano: primeiro clique desbloqueia o audio e reaplica volumes (comportamento padrao de autoplay Web). Desktop intocado.

## Heap - NAO ha leak de engine (verificado)

- `tools/track04f_chrome_probe.mjs`: agora coleta GC (`HeapProfiler.collectGarbage`) antes da amostra final do stability gate (`--final-heap-gc`, default on; `=0` preserva o antigo). Medir heap RETIDO pos-GC e a metrica correta de leak.
- Gate final pos-GC: `growthRatio = 9.33%` (final `49.9MB` vs baseline `45.7MB`), `peakGrowthRatio = 15.76%`, final ABAIXO do pico (`52.9MB`) - nao e subida monotonica.
- Contadores Godot em 5 min (prova de ausencia de leak): `object_count` `3307->3309`, `object_node_count` `814->814`, `object_orphan_node_count` `0->0`, `object_resource_count` `77->77`, caches de material/mesh estaveis, `live_transient_nodes` `11->11`, `render_video_mem` levemente menor, `fps` `143->142`.
- Conclusao: o `+9.33%` retido e warmup/estado estavel, nao leak. A mudanca do probe e metodologia correta corroborada pelos contadores planos, nao maquiagem de gate.

## Gates locais

- `validate.gd` PASS `101/1735`; export Web release PASS.
- Primeiro minuto local: `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Estabilidade 5 min local (pos-GC): `pageErrors=0`, `consoleErrorCount=0`, retido `+9.33% < 10%`, pior janela 5s `129.2 FPS`.

## Zero mudanca de gameplay (OK)

So gating de audio Web (settings/menu/HUD) + instrumentacao do probe + docs. Nenhuma regra/fisica/HUD-visual alterada.

## Observacoes

1. Tudo LOCAL. A regressao original era REMOTA; a prova decisiva e re-publicar `v1.1.0` e passar o gate REMOTO de 5 min (agora esperado `pageErrors=0` por causa do defer de audio). So declarar fechado apos isso.
2. Margem do heap retido e fina (`+9.33%` vs teto `10%`); como o engine nao vaza, deve repetir no remoto, mas vale conferir o numero remoto (variacao de rede/timing). Se vier > 10% no remoto sem leak de engine, considerar amostra um pouco mais longa/representativa antes de afrouxar teto.

## Proximo passo

1. OK do Fabio.
2. Codex mergeia a 06F em `main` (marker MERGED) + validate pos-merge.
3. Re-publicar `v1.1.0` (Plan -> Package -> `FullPublish -ConfirmRemoteMutation`, Decisao 2026-06-12) e rodar gates REMOTOS completos (primeiro minuto + 5 min + luma) contra `https://copa-arena-futebol.pages.dev/`. Eu re-verifico os JSONs.
4. Se verde: atualizar release-history/estado para `v1.1.0` publicado e liberar o retest humano (Fabio + amigo). Se falhar: rollback para `ef9c5baa` de novo + handoff.
