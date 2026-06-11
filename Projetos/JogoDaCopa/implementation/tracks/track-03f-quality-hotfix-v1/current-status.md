# Track 03F - Quality Hotfix V1

- Date: `2026-06-10`
- Branch: `codex/jogodacopa/track03f-quality-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03f-quality-hotfix-v1`
- Status: `COMPLETE`
- Source reviews: `docs/code-review-track03-series-v1.md`, `docs/code-review-track02cbis-02dbis-v1.md`

## Goal

Consolidar fixes dos reviews das series Track 03 e 02C-bis/02D-bis, registrar tuning objetivo de playtest quando houver notas de Fabio, reforcar validacao de fechamento e preparar o proximo playtest humano.

## Review Fixes Applied

- Super shot do player agora so consome `player_super_meter` e `player_super_used_this_kickoff` depois de chute conectado.
- Novo teste cobre RMB com super cheio e bola fora de alcance sem gasto de barra/cota.
- Avatar real deixou de usar `material_override` flat por mesh.
- Cada surface do modelo Quaternius recebe duplicata do material PBR original com tint de kit sobre `albedo_color`, preservando `albedo_texture` e demais mapas do material duplicado.
- Sobrancelha usa tint escuro neutro/cabelo, sem depender da cor secundaria do kit.
- Novo teste garante que surfaces texturizadas preservam `albedo_texture != null` apos tint.
- `tools/performance_sample.gd` documenta metodologia representativa: janela real, 1920x1080, vsync off.
- Sampler passa a imprimir display, resolucao e modo de janela junto dos FPS.
- `tools/validate.gd` passa a carregar todos os `.gd` e `.gdshader` fora de `addons/`, detectando fonte truncada antes do fechamento.

## Accepted Tradeoffs

- Tint global de kit sobre o modelo real e o aceite desta fase.
- Distincao por regiao de roupa, como camisa vs shorts/meias via texture mask custom, fica como melhoria futura.
- Os numeros de performance da serie Track 03 (`1097-1275fps`) foram medidos sem rasterizacao representativa registrada e nao sao baseline. A baseline valida deve vir de janela real 1920x1080 com vsync off.

## Playtest Tuning

- Fabio nao forneceu notas objetivas de playtest nesta thread alem do placeholder da tarefa.
- Nenhum ajuste de constante, clipe, toggle, stun, dash, audio ou dificuldade foi aplicado na Fase 3.
- O toon permanece como experimento em toggle OFF por padrao ate decisao humana explicita.
- Contratos de tap LMB/RMB, fisica base da bola e paridade de bot permanecem inalterados.

## Validation Log

- `tools/validate.gd`: PASS, 50 tests, 466 asserts.
- Source integrity: PASS, 26 `.gd/.gdshader` files loaded outside `addons/`.
- Performance sample: PASS, windowed 1920x1080, vsync off, display `Windows`, average `730.8fps`, min warmed instant `488.8fps`, `0/360` frames below 60.
- Known validation noise: GUT UID/text-path warnings ao carregar testes.

## Delivery

- Review fix commit: `6c6bf73 fix(jogodacopa): apply track 03f review hotfixes`.
- Playtest tuning record commit: `8e35a62 docs(jogodacopa): record track 03f playtest tuning status`.
- Next step: playtest de confirmacao do hotfix + decisao da proxima serie com Claude.
