# Handoff - Track 05B.1 Sensory Feedback Re-Introduction V1

- Data: `2026-06-12`
- Agente: `Codex`
- Branch: `codex/jogodacopa/track05b1-sensory-feedback-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track05b1`
- Projeto: `Projetos/JogoDaCopa/`
- Status: `MERGED_LOCAL_AFTER_CLAUDE_APPROVAL`

## Escopo

Fabio decidiu devolver ao Web os efeitos sensoriais cortados na 05B sem reabrir travadas no primeiro minuto. A implementacao reativou os efeitos na ordem APITO, `CONFETTI de gol`, VFX/audio de chute, countdown, jump pad e result/rematch, sempre com gate curto de `60s` antes de avancar.

## Resultado

- Publicado como `v1.0.3+ef9c5baa`.
- Release root: `web/v1-copa-arena-futebol-20260612-ef9c5baa`.
- URL estavel: `https://copa-arena-futebol.pages.dev/`.
- Preview: `https://f66e2003.copa-arena-futebol.pages.dev`.
- Relatorio principal: `Projetos/JogoDaCopa/docs/playtest-reports/track-05b1-sensory-feedback.md`.
- Release history atualizado: `Projetos/JogoDaCopa/docs/release-history.md`.

## Pontos Para Review

- `Projetos/JogoDaCopa/presentation/feedback/fps_feedback_controller.gd`: filtro Web de feedback, reintroducao Web-safe dos efeitos e bloqueio de audio ate ativacao do navegador.
- `Projetos/JogoDaCopa/modes/menu/main_menu_root.gd`: pool de audio do menu adiado no Web para remover `PositionWorklet` antes de gesto humano.
- `Projetos/JogoDaCopa/modes/football/football_root.gd`: warmup real dentro do frustum atras do overlay, incluindo caminhos reais de gol/confetti e jump pad.
- `Projetos/JogoDaCopa/tools/track04f_chrome_probe.mjs`: cenario de primeiro minuto por evento, `--web-feedback`, janelas de hitch por evento e limite de armazenamento de frames em gate longo.
- `Projetos/JogoDaCopa/tools/publish_web.ps1`: versao visivel `v1.0.3`.

## Evidencia

- Primeiro minuto local: `Projetos/JogoDaCopa/docs/playtest-reports/track-05b1-data/05b1-local-final-first-minute-after-menu-audio-defer.json` - PASS, `0` hitches `>100ms`, runtime/page errors `0`.
- Estabilidade local 5min: `Projetos/JogoDaCopa/docs/playtest-reports/track-05b1-data/05b1-local-final-stability-5min.json` - PASS.
- Primeiro minuto remoto: `Projetos/JogoDaCopa/docs/playtest-reports/track-05b1-data/05b1-remote-first-minute-gate-final-ef9c5baa.json` - PASS, release root conferiu, `event.rematch` visto, runtime/page errors `0`.
- Estabilidade remota 5min: `Projetos/JogoDaCopa/docs/playtest-reports/track-05b1-data/05b1-remote-stability-5min-final-ef9c5baa-pass2.json` - PASS, release root conferiu, runtime/page errors `0`.
- Luminancia: `tools/capture_track04e_web_spike.gd` - PASS, kickoff/play `58.8`, goal `63.2`, result `75.4`, teto `90`.
- Validate full: PASS, 86 testes, 1272 asserts, Web gzip `30.32 MiB / 50.00 MiB`.
- Export Web: PASS.

## Observacoes

- O pacote pesado completo de `goal` continua fora do default Web; o requisito `CONFETTI de gol` foi reativado.
- Audio automatizado em Web permanece silencioso ate ativacao do navegador para obedecer autoplay e evitar `PositionWorklet`; em sessao humana, o clique do menu desbloqueia os players 2D.
- Loading local primeira visita ficou em `~17.8s-18.3s`, acima do teto `8s`; registrado para decisao de Fabio.
- Durante smoke remoto, uma falha de heap no gate 5min foi atribuida ao proprio probe acumulando `47.546` objetos de frame; a instrumentacao foi limitada em gates longos e o pass2 ficou verde.

## Fechamento Pos-Review

- Review Claude aprovado: `Projetos/JogoDaCopa/docs/code-review-track05b1-sensory-feedback-v1.md`.
- Merge local em `main`: `f759dd34`.
- Validate integrado pos-merge: PASS, 86 testes, 1272 asserts.
- Proximo passo: retest humano `v1.0.3`; follow-ups O1/O2 apenas se necessario.

`PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
