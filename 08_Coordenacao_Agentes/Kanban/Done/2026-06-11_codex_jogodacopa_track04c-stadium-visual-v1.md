# Track 04C - Stadium Visual Upgrade V1

- Data: 2026-06-11
- Agente: Codex
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/JogoDaCopa/track04c-stadium-visual-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04c-stadium-visual-v1`
- Base: `main` em `b715f743` (`docs(jogodacopa): close track04b3 after merge`)
- Status: `DONE - aprovado pelo review e mergeado em main`

## Objetivo

Executar o upgrade visual do estadio antes do web publish, mantendo modos para pos-lancamento: arquibancadas profundas, torcida viva com `crowd_excitement`, teloes/bandeiroes/mastros/refletores, horizonte low-poly, evidencia visual e budget web.

## Escopo Permitido

- `Projetos/JogoDaCopa/modes/football/football_field_builder.gd`
- Shaders de arena novos/existentes em `Projetos/JogoDaCopa/modes/football/`
- Shader de regiao em `Projetos/JogoDaCopa/gameplay/avatar/` somente para suavizacao de borda, se a comparacao visual justificar
- Testes proprios da track
- `Projetos/JogoDaCopa/implementation/tracks/track-04c-stadium-visual-v1/current-status.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-04c-stadium-visual-v1.md`
- `Projetos/JogoDaCopa/docs/screenshots/track-04c-stadium-visual-v1/`
- Card Kanban e handoff/review proprio da track

Fora de escopo durante a implementacao: `football_root`, HUD, menu, fluxo de partida, camera runtime, publicacao web, merge em `main`, rede git (`push`/`fetch`/`pull`) e `git clean`.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/release-plan.md` (`ROTA FINAL PRE-RELEASE`)

## Plano De Validacao

- Import headless unico da worktree nova antes da validacao.
- Testes proprios para montagem do estadio, `set_crowd_excitement`, material/uniform de torcida e elementos novos sem luz/sombra nova.
- Evidencia windowed: 4 angulos do estadio novo, frame com `crowd_excitement=1.0`, comparacao borda do uniforme antes/depois ou registro de reversao.
- Perf sample windowed 1080p com media > 300fps como proxy de viabilidade web.
- `git diff --check`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`

## Proximo Handoff

Review aprovado em `Projetos/JogoDaCopa/docs/code-review-track04c-04d-v1.md`; merge local em `main` concluido apos a 04D. Push fica pendente para Fabio via GitHub Desktop.

## Fechamento Codex

- Implementado upgrade visual config-driven em `football_field_builder.gd`.
- Torcida recebe cores dos dois kits e material com `crowd_excitement`; metodo `set_crowd_excitement(parent, value)` exposto para integracao futura no root.
- Teloes, bandeiroes, mastros com shader de onda, halos emissive e skyline low-poly adicionados sem novas luzes com sombra.
- Suavizacao opcional do shader de uniforme foi testada, comparada em screenshot e revertida por nao melhorar o resultado.
- Validacao completa PASS: 77 testes, 1128 asserts.
- `git diff --check` PASS.
- Perf sample windowed 1080p PASS: media 728.8fps, minimo aquecido 452.3fps, 0/360 frames abaixo de 60fps.
- Evidencias em `Projetos/JogoDaCopa/docs/screenshots/track-04c-stadium-visual-v1/`.
- Handoff criado para review de Claude + aprovacao visual de Fabio.
- Review aprovado e merge local em `main` concluido apos a 04D.

## Resultado Pos-Merge

- Merge local em `main` concluido depois da 04D.
- `tests/unit/test_bootstrap.gd` preserva os testes da 04C e da 04D.
- Validacao integrada: PASS, 81 testes, 1216 asserts, source integrity 30 `.gd/.gdshader`.
- `git diff --check`: PASS.
- `tools/check_doc_drift.ps1`: PASS.
- `PUSH PENDENTE`: Fabio - GitHub Desktop - Push origin.
- `WORKTREE_VERIFIED`: sim, merge local concluido em `main`; sem `push`/`fetch`/`pull` e sem `git clean`.
