# Code Review PRE-MERGE - Track 04F Web Performance & Load V1

- Date: `2026-06-11`
- Reviewer: Claude (Fable 5)
- Branch: `codex/jogodacopa/track04f-web-performance-v1`
- Veredito: **APROVADA PARA MERGE**. Residual critico de load segue aberto e vira Track 04F.2 imediata (nao e defeito do trabalho desta branch; e a proxima camada do problema, agora corretamente diagnosticada).

## Metodologia (exemplar - vira referencia)

- Baseline completa antes de qualquer fix: tabela de etapas de load (desktop e Chrome), top hitches correlacionados a eventos do jogo, top 20 do pck.
- Cada otimizacao medida isolada; duas decisoes REVERTIDAS por contradizerem a medicao (glow-off piorou o stall -> mantido glow; mesh offline de region mask descartado apos cache medir 0.4ms). Isso e o Quality Gate funcionando como projetado.
- Instrumentacao permanente ganha: `jdc_perf_probe.gd` (etapas/eventos `[JDC_PERF]`), `track04f_chrome_probe.mjs` (CDP + rAF + screenshots), `build_avatar_runtime_assets.gd` (gera `.res` offline).

## Resultados confirmados

- HITCHES EM JOGO (queixa B de Fabio): RESOLVIDOS. Pos-warmup 120s: p50/p95/p99 = 6.9/7.0/7.1ms, max 62.5ms, ZERO hitch > 100ms. Gate de smoothness PASS.
- Custo GDScript do play: avatares 604.8+606.2ms -> 135.8+218.0ms (animation library `.res` offline + cache de region mask); menu 782 -> 380ms (preview UPDATE_ONCE).
- PCK 50.97 -> 26.41 MiB (texturas 4K limitadas/VRAM, UAL glb e audios sem ref excluidos do export, 3 duplicatas orfas removidas com licenca preservada). Transfer gzip estimada 30.29 MiB.
- Validate ganhou gate de build size; suite caiu de ~47s para ~28s (bonus do `.res`).
- F1 do review 04E entregue: captura da chase camera em gameplay web. Luminancia PASS (13.02 < 90).
- Freeze silencioso do play eliminado: loading com progresso por etapa.
- Validate PASS 86/1264; export web PASS.

## Residual critico (Track 04F.2 - proxima, foco unico)

`Play -> partida jogavel` segue ~17-20s no Chrome local: UM stall de primeiro render/upload WebGL da arena completa (glow on/off indiferente; nao e audio, animacao, region mask nem SubViewport - tudo descartado por medicao). Para jogo web casual isso mata retencao; nao publicamos assim.

Hipoteses concretas para a 04F.2 (na ordem):

1. CONTAR variantes: instrumentar quantos materiais/shaders UNICOS a cena de jogo cria (suspeita: arena 04C duplica StandardMaterial3D por bloco de torcida/estande/banner -> centenas de compilacoes sincronas de programa WebGL no primeiro draw; ubershader do Compatibility compila variante por combinacao de features).
2. CONSOLIDAR: materiais compartilhados onde a unica diferenca e cor (usar instance uniforms/vertex colors ja existentes; candidato a MultiMesh para blocos de torcida se a contagem confirmar).
3. FATIAR a primeira renderizacao: warmup incremental durante o loading - revelar a arena em ondas de visibilidade com `await process_frame` entre grupos, com camera ativa, para dividir o stall de 17s/1 frame em N frames pequenos com a barra andando; jogador entra com tudo compilado.
4. Meta 04F.2: overlay sai em <= 5s local; nenhum frame unico > 1s durante o loading; gate de smoothness continua PASS.

Nota: o shader cache do Chrome torna a SEGUNDA visita rapida; a meta acima e para a primeira impressao, que e a que conta na publicacao.

## Observacoes menores (nao bloqueiam)

- N1: gate de build size usa transfer gzip estimada (raw 62.73 MiB por causa do wasm fixo de 35.95 MiB do engine) - racional documentado no relatorio, aceito.
- N2: recodificacao OGG do ambience ficou de fora por nao ser causa medida - correto pelo escopo; pode entrar como corte de pck na 04G se quisermos (2.98 MiB no MP3 principal).
- N3: `project.godot` em main sofreu reordenacao de linhas pelo editor no export local de Fabio - restaurado pela Claude no review, sem conteudo perdido.

## Pos-merge

Merge em main + validate integrado + PUSH PENDENTE (GitHub Desktop). Em seguida Track 04F.2 (stall WebGL). Depois: 04G publicacao.
