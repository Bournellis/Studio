# Code Review PRE-MERGE - Track 05A Web Stability Hotfix V1

- Date: `2026-06-12`
- Reviewer: Claude (Fable 5)
- Branch: `codex/jogodacopa/track05a-web-stability-v1`
- Veredito: **APROVADA PARA MERGE** - com caveat explicito: a causa nao foi confirmada por reproducao; a validacao decisiva e o retest humano (Fabio + tester externo) na v1.0.1 publicada.

## O que foi bem feito

- Eliminacao por dados de TODOS os suspeitos da review: caches 04F.2 constantes (144 entries, zero crescimento), zero orphan nodes, transients/particulas voltando ao baseline, video mem estavel - nenhum vazamento RETIDO existe.
- Isolamento do proprio harness: com `jdc_perf=1` o probe acumula heap; controle sem flag ficou estavel - o jogo publicado nao carrega esse custo.
- Fix aplicado no alvo mais plausivel medivel: churn por frame no loop quente (`_build_hud_snapshot` criando Dictionary+strings por frame, placares de estadio reformatando textos por frame para 2 SubViewports, HUD reatribuindo valores identicos). Agora: cadencia 0.1s + skip de valores identicos; fisica/input/VFX intocados por frame.
- M1/M2 entregues: rodape `Copa Arena Futebol v1.0.1+<hash>`, `PC Windows editor-first` removido, `release_info.json` embutido no pacote.
- Gate permanente de estabilidade (5 min, pos-warmup 60s): heap retido < 10%, contadores estaveis, nenhuma janela de 5s < 30 FPS. PASS local (2.25% retido, pior janela 139.6 FPS) e PASS REMOTO na v1.0.1 publicada (3.77%, pior janela 126.0 FPS).
- Republicacao executada conforme decisao vigente; release root `web/v1-copa-arena-futebol-20260612-a850045a` no ar.

## Caveat de processo (registrado, nao bloqueia)

A oscilacao 3-4s relatada NUNCA apareceu no harness (p99 7.1ms ate na producao pre-fix). O "vermelho antes do fix" do Quality Gate nao foi alcancavel aqui - a falha so se manifesta em maquinas/ambientes de jogadores reais. O fix reduz pressao de GC real e mensuravel (heap peak por ciclo segue ~43-46% - serra de GC menor mas existente), e a confirmacao final e necessariamente humana.

## Plano B ja desenhado (se o retest humano ainda oscilar)

1. Telemetria na maquina afetada: overlay leve ativavel por query param (`?jdc_stats=1`) com FPS/heap/GC ao vivo + botao de exportar log - o tester externo coleta o dado que o harness nao alcanca.
2. Churn-zero no snapshot: mutacao in-place de um Dictionary reutilizado + cache de strings formatadas (so muda quando placar/tempo muda).
3. Investigar camadas fora do heap JS: composite/raster do browser, audio worklet, throttling termico/energia (Chrome `chrome://discards`, energy saver), que nenhum probe nosso ve.

## Pos-merge

Merge local + card Done + PUSH PENDENTE (GitHub Desktop). RETEST HUMANO na URL publica (aba anonima, conferir `v1.0.1` no rodape): Fabio + tester externo, mesmas maquinas do relato. Resultado do retest define: encerrar ou ativar Plano B como Track 05B.
