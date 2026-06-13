# Code Review - JogoDaCopa Track 06C - Menu Principal Broadcast V1

- Data: `2026-06-13`
- Revisor: Claude (review pre-merge de UI/visual)
- Branch: `codex/jogodacopa/track06c-menu-broadcast-v1` (commits `e0cefceb` feat, `ea498f57` handoff)
- Base: `main` em `c894dc0d` (com as fontes Kenney commitadas)
- Veredito: `APROVADO no code review`; Fabio aprovou o feel visual e autorizou merge local da 06C.

## Escopo verificado / disciplina de paralelismo (OK)

Tocou SOMENTE a area da 06C: `modes/menu/main_menu_root.gd`, `tests/unit/test_menu_visual.gd` (novo), `docs/asset-licenses.md` (entrada Kenney) e `docs/screenshots/track-06c/`. NAO tocou `presentation/hud/*`, `autoloads/*`, `project.godot` nem `test_bootstrap`. Areas disjuntas da 06D respeitadas.

## Fonte e licenca (OK)

- Carrega 3 fontes Kenney (`Kenney Future`, `Kenney Future Narrow`, `Kenney Mini Square Mono`) via `res://assets/fonts/kenney/`, aplicadas por theme/override local. Sem theme global em `project.godot`.
- Falha silenciosa proibida respeitada: fonte principal/mono ausente => `push_error`; narrow ausente => `push_warning`.
- Licenca registrada em `docs/asset-licenses.md` (secao "Track 06C - Broadcast Menu Fonts V1", `CC0 1.0 Universal`). 06C e dona da entrada, como combinado.

## Match card de transmissao (OK)

- Header: faixa de Copa com `GradientTexture2D` (verde -> vermelho -> azul), titulo `Copa Arena Futebol` em Kenney + cor creme, linha `FINAL 1x1 | ARENA DE VIDRO` em mono, linha dourada de detalhe, status.
- Secoes claras com rotulos dourados: `TRANSMISSAO DA PARTIDA`, `UNIFORME DO PLAYER`, `CONTROLE DA TRANSMISSAO`.
- CTA dominante: `Jogar Futebol 1x1` com altura `52` e fonte `20` (vs `34`/menores dos demais), estilo verde com borda dourada.
- Kit com bandeira de 3 swatches (primaria/secundaria/shorts) e ciclos de pele/kit que refletem no hero shot.
- Hero shot 3D aprovado preservado; o upgrade e moldura/painel/tipografia/hierarquia, como pedido. Zero luz nova.

## Testes (clique real + estrutura) (OK)

- `test_menu_visual.gd`: clique REAL (`InputEventMouseButton` via `viewport.push_input` + `flush_buffered_events`) em TODOS os controles (CTA, Sair, prev/next de bot/modo/pele/kit, 4 sliders de volume, toggle toon, dropdown de qualidade), assertando o sinal de cada um.
- Valida estrutura do card (paths de header/secoes/rows), fonte Kenney carregada, hero shot em uso, CTA com altura minima `>= 42`, e fit responsivo do menu.
- Teste de ciclo de aparencia (pele/kit) refletindo no hero shot.

## Zero mudanca de gameplay (OK)

Tudo apresentacao de menu. Nenhuma regra/fisica/entrada de partida tocada.

## Evidencia visual (analisada)

`docs/screenshots/track-06c/menu-broadcast-web-{1920x1080,1366x768,1280x720}.png` (PNGs) + boot Web. Conferido: card de transmissao com faixa de Copa, tipografia Kenney, secoes douradas, CTA verde dominante e hero shot intacto; layout estavel ate `1280x720`. Visual claramente "transmissao", coerente com o objetivo.

Gates (handoff): validate PASS, export Web release PASS, boot Web local PASS sem tela preta.

## Observacoes (nao bloqueantes)

1. Conjunto de resolucoes: os testes/capturas usam `1920x1080`, `1280x720` e `960x540`. O gate padrao da casa pede `1920x1080`, `1366x768`, `1280x720`. Falta o `1366x768` (laptop comum); o `960x540` extra e bom para fit, mas recomendo incluir `1366x768` para paridade com o gate. Layout entre 1280 e 1920 deve estar ok, mas fica a recomendacao.
2. No `1920x1080` o painel fica a direita e relativamente compacto ao lado do hero shot (layout pre-existente, nao regressao da 06C). Veredito de composicao e do Fabio.

## Proximo passo

1. Track 06C mergeada localmente em `main` como `c14bf5a5`.
2. Card movido para `Kanban/Done/` e este review registrado no commit de fechamento.
3. 06D permanece separada; publicacao Web so na 06E.
