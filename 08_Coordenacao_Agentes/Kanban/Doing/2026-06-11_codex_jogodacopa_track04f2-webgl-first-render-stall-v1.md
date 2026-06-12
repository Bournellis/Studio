# Tarefa: JogoDaCopa - Track 04F.2 WebGL First-Render Stall V1

## Metadata

- id: `2026-06-11_jogodacopa-track04f2-webgl-first-render-stall-v1`
- owner: `Codex`
- status: `Doing`
- projeto: `JogoDaCopa`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/jogodacopa/track04f2-webgl-first-render-stall-v1`
- worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04f2-webgl-first-render-stall-v1`

## Goal

Eliminar o stall unico de primeiro render/upload WebGL que mantem `Play -> partida jogavel` em ~17-20s no Chrome local (primeira visita, sem shader cache), conforme residual diagnosticado e aprovado em `Projetos/JogoDaCopa/docs/code-review-track04f-web-performance-v1.md` (secao "Residual critico"). Este e o bloqueio de publicacao da build web.

## Technical Scope (ordem obrigatoria - medir antes de mudar)

- `04F2-A Contagem/baseline`: estender `modes/shared/jdc_perf_probe.gd` para contar materiais/shaders UNICOS criados na cena de jogo (suspeita: `football_field_builder.gd` duplica `StandardMaterial3D` por bloco de torcida/estande/banner -> centenas de compilacoes sincronas de programa WebGL no primeiro draw). Registrar baseline de primeira visita com `tools/track04f_chrome_probe.mjs` e cache de shader limpo.
- `04F2-B Consolidacao`: compartilhar materiais cuja unica diferenca e cor (instance uniforms/vertex colors ja existentes); avaliar `MultiMesh` para blocos de torcida SE a contagem confirmar. Cada mudanca medida isolada; reverter o que nao melhorar a medicao (metodologia 04F).
- `04F2-C Warmup incremental`: revelar a arena em ondas de visibilidade durante o loading, com `await process_frame` entre grupos e camera ativa, dividindo o stall em N frames pequenos com a barra de progresso andando; o jogador so entra com tudo compilado.
- `04F2-D Evidencia/fechamento`: re-rodar o probe de primeira visita, atualizar `docs/playtest-reports/track-04f-data/` com as novas medicoes, track doc e handoff de review.

## Out Of Scope

- Novas features de gameplay, tuning de feel ou mudanca visual perceptivel (resultado final identico ao olho).
- Threads/PWA/service worker, reducao do wasm fixo do engine, troca de renderer.
- Qualquer operacao de rede git (`push`/`fetch`/`pull` sao exclusivos do Fabio - politica `2026-06-11_estudio_git_remote_github_desktop.md`).

## Expected Files

- `Projetos/JogoDaCopa/modes/football/football_field_builder.gd` (consolidacao de materiais)
- `Projetos/JogoDaCopa/modes/football/football_root.gd` (warmup incremental/loading)
- `Projetos/JogoDaCopa/modes/shared/jdc_perf_probe.gd` (contagem de materiais/shaders)
- `Projetos/JogoDaCopa/modes/menu/main_menu_root.gd` (se o overlay de loading viver aqui)
- `Projetos/JogoDaCopa/tools/track04f_chrome_probe.mjs` (nova metrica de primeira visita, se necessario)
- `Projetos/JogoDaCopa/docs/playtest-reports/track-04f-data/` (medicoes antes/depois)
- `Projetos/JogoDaCopa/implementation/tracks/track-04f2-webgl-first-render-stall/current-status.md` (novo)
- `Projetos/JogoDaCopa/implementation/current-status.md`, `Estado_Atual.md` (fechamento)

## Acceptance Criteria

- [ ] Baseline de primeira visita registrada ANTES de qualquer mudanca (contagem de shaders/materiais unicos + timeline do stall).
- [ ] Overlay de loading sai em `<= 5s` no Chrome local, primeira visita, cache de shader limpo.
- [ ] Nenhum frame unico `> 1s` durante loading/primeiro render.
- [ ] Gate de smoothness pos-warmup da 04F continua PASS.
- [ ] Visual final inalterado (screenshots comparativas do probe contra a baseline 04F).
- [ ] PCK nao cresce alem de `+1 MiB` sobre os `26.41 MiB` da 04F sem justificativa documentada.
- [ ] `tools/validate.gd` profile full PASS; zero regressao GUT.
- [ ] Otimizacoes que nao melhorarem a medicao revertidas e documentadas.
- [ ] Handoff de review para Claude ANTES do merge em main; apos aprovacao, merge local e card movido para Done.
- [ ] Git LOCAL apenas; fechamento declara `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.

## Handoff Needed

`Yes` - review Claude (gate de merge) + playtest humano do Fabio na build web apos merge.

## Notes

- Fonte autoritativa do diagnostico e da metodologia: `docs/code-review-track04f-web-performance-v1.md`.
- O shader cache do Chrome torna a SEGUNDA visita rapida; a meta desta track e a PRIMEIRA impressao, que e a que conta na publicacao.
- Hipoteses ja descartadas por medicao na 04F (nao reinvestigar sem novo sinal): audio, animacao, region mask, SubViewport, glow on/off.

## Codex Start

- Started: `2026-06-12`
- Worktree verified at start: `D:\Estudio-worktrees\JogoDaCopa--codex--track04f2-webgl-first-render-stall-v1`
- Branch: `codex/jogodacopa/track04f2-webgl-first-render-stall-v1`
- Base docs read: `Prioridades_Estudio.md`, root `AGENTS.md`, `Projetos/README.md`, `Estado_Atual.md`, project `AGENTS.md`, `implementation/current-status.md`, `docs/code-review-track04f-web-performance-v1.md`, `docs/playtest-reports/track-04f-web-performance.md`, this card.
- Intended files: probe/material-count instrumentation, football field/root render path, track evidence/report, project status and handoff.
- Validation plan: headless editor import once, Web export as needed for probes, Chrome first-visit probes with shader cache cleared, 120s smoothness smoke, `validate.gd` full, Web export, `git diff --check`, clean status.
- Next handoff point: Claude pre-merge review after local evidence/docs commit.
