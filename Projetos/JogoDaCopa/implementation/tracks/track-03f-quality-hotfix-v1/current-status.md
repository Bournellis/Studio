# Track 03F - Quality Hotfix V1

- Date: `2026-06-10`
- Branch: `codex/jogodacopa/track03f-quality-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03f-quality-hotfix-v1`
- Status: `IN_PROGRESS`
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

## Validation Log

- `tools/validate.gd`: PASS, 50 tests, 466 asserts.
- Source integrity: PASS, 26 `.gd/.gdshader` files loaded outside `addons/`.
- Known validation noise: GUT UID/text-path warnings ao carregar testes.

## Remaining

- Fase 3: registrar ausencia ou aplicacao de notas objetivas de playtest.
- Fase 4: rodar performance sample com metodologia registrada, atualizar planos/status, mover card para Done, mergear em `main`, prune e checagem pos-merge no worktree principal.
